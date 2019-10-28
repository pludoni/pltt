require_relative './base'
class Pltt::Actions::Resume < Pltt::Actions::Base
  def run
    exit_if_running!

    last_one = all_frames.sort_by { |i| File.mtime(i) }.reverse.lazy.
      map { |i| load_entry(i) }.
      select { |i| i.project == config['project'] }.
      take(5).max_by { |i| i.stop }

    unless last_one
      puts "No previous entry found for #{config['project']}!".red
      exit 1
    end

    new_entry = Pltt::Entry.from_resume(last_one)
    new_entry.persist!
  end
end
