require_relative './base'
require 'tty-prompt'
# rubocop:disable Style/NegatedIf
class Pltt::Actions::Stop < Pltt::Actions::Base
  def run
    exit_if_not_running!
    c = current_entry

    minutes = (c.duration_seconds / 60).round
    puts "Currently running for #{minutes.to_s.green} min"
    prompt = TTY::Prompt.new
    too_large = minutes > 480
    if !prompt.no?(" Was started on #{c.start.localtime.to_s.green}, fix beginning?")
      time = prompt.ask(" Enter beginning *time* only (HH:MM)") do |q|
        q.required true
        q.validate(/\A\d+:\d+\Z/)
        q.convert :string
      end
      h, m = time.split(':').map(&:to_i)
      c.start = Time.new(c.start.year, c.start.month, c.start.day, h, m)
      minutes = (c.duration_seconds / 60).round
      puts "Currently running for #{minutes.to_s.green} min"
    end
    if too_large || !prompt.no?("Fix duration before saving? (#{minutes}min)")
      puts "Error: To many minutes, must be not greater than 8h (480min)" if too_large
      new_minutes = prompt.ask("New Minutes, beginning from #{c.start.localtime}") do |q|
        q.required true
        q.convert :int
      end
      stop = (c.start + new_minutes * 60).utc
    else
      stop = Time.now.utc
    end
    c.stop = stop

    c.persist!

    sync_all_unsaved_entries
  rescue StandardError => e
    puts "Issue #{c.id} not found in project #{config['project']}".red
    puts e.inspect
    exit 1
  end
end
