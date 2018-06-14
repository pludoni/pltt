require 'yaml'
require 'oj'
require_relative '../entry'
require_relative '../colorize'

class Pltt::Actions::Base
  def self.run(*args)
    new.run(*args)
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

  def exit_if_running!
    if current_entry
      puts "Already started!".red
      puts current_entry.status
      exit 1
    end
  end
end
