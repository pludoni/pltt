require 'thor'

class Pltt::Runner < Thor
  desc "resume", "resume last issue in current project"
  def resume
    require_relative './actions/resume'
    Pltt::Actions::Resume.run
  end

  desc "create", "create new issue in current project"
  def create
  end

  # TODO
  desc "start ID", "start tracking for issue #ID"
  def start(id)
    puts "Start #{id}"
  end

  # TODO
  desc "stop", "Stop"
  def stop
    puts "Start #{id}"
  end

  desc "status", "Status"
  def status
    require_relative './actions/base'
    if (c = Pltt::Actions::Base.new.current_entry)
      puts c.status
    else
      puts "No tracking is running"
      exit 1
    end
    Pltt::Actions::Status.run
  end

  desc "edit [ID]", "start tracking for issue #ID"
  def edit(id = nil)
    puts "Start #{id}"
  end

  desc "cancel", "cancel current entry"
  def cancel
    require_relative './actions/base'
    if (c = Pltt::Actions::Base.new.current_entry)
      c.cancel!
    else
      puts "No running entry to cancel"
      exit 1
    end
  end
end

Pltt::Runner.start(ARGV)
