require 'yaml'
require 'oj'
require_relative '../entry'
require_relative '../colorize'

class Pltt::Actions::Base
  def self.run(**args)
    new.run(**args)
  end

  def config
    self.class.config
  end

  def self.config
    return @config if @config
    master = File.expand_path('~/.gtt/config.yml')
    unless File.exist?(master)
      raise ".gtt/config.yml existiert nicht!"
    end
    config = YAML.load_file(master)
    locale = File.join(Dir.pwd, '.gtt.yml')
    if File.exist?(locale)
      config = config.merge(YAML.load_file(locale))
    end
    config['frame_dir'] ||= '~/.gtt/frames/'
    config['gitlab_url'] ||= config['url'].sub(%r{/api/v4/?}, '')
    @config = config
  end

  def current_entry
    max = Time.now - 3600 * 24 * 7
    recent_entries = all_frames.select { |i| File.mtime(i) > max }
    recent_entries.each do |entry|
      e = load_entry(entry)
      return e if e.current?
    end
    nil
  end

  def load_entry(path_to_frame)
    File.read(path_to_frame).yield_self { |i| Oj.load(i) }.yield_self(&Pltt::Entry.method(:new))
  end

  def all_frames
    Dir[File.join(File.expand_path(config['frame_dir']), '*.json')]
  end

  def stop_if_running!(default: false)
    if current_entry
      require 'tty-prompt'
      prompt = TTY::Prompt.new
      puts current_entry.status
      if prompt.yes?("Es läuft bereits ein Issue, soll dieses vorher beendet werden? ", default: default)
        require_relative './stop'
        Pltt::Actions::Stop.run
      else
        exit 1
      end
    end
  end

  def exit_if_running!
    if current_entry
      puts "Already started!".red
      puts current_entry.status
      exit 1
    end
  end

  def exit_if_not_running!
    unless current_entry
      puts "Not started!".red
      exit 1
    end
  end

  def gitlab_api
    @gitlab_api ||=
      begin
        require_relative '../gitlab_wrapper'
        Pltt::GitlabWrapper.new(config['url'], config['token'], config['project'])
      end
  end

  def sync_all_unsaved_entries
    gitlab_api
    max = Time.now - 3600 * 24 * 7
    recent_entries = all_frames.select { |i| File.mtime(i) > max }
    recent_entries.each do |e|
      entry = load_entry(e)
      next if entry.synced? || entry.stop.nil?
      sync!(entry)
    end
  end

  def sync!(entry)
    c = entry
    minutes = c.duration_seconds.round / 60

    min_part = minutes % 60
    hour_part = minutes / 60

    gitlab_time_format =
      case [hour_part > 0, min_part > 0]
      when [true, true] then "#{hour_part}h#{min_part}m"
      when [false, true] then "#{min_part}m"
      when [true, false] then "#{hour_part}h"
      else return
      end
    puts "Synching: #{gitlab_time_format.inspect} on #{c.project}##{c.iid}"

    gitlab_api.add_time_spent_on_issue(c.project, c.iid, gitlab_time_format)

    note_id = Gitlab.issue_notes(entry.project, entry.iid).auto_paginate.max_by { |i| i.created_at }.id
    c.add_note(note_id, c.duration_seconds.round)
    c.persist!
  end
end
