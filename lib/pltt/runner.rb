require 'thor'

class Pltt::Runner < Thor
  desc "resume", "resume last issue in current project"
  def resume
    require_relative './actions/resume'
    Pltt::Actions::Resume.run
  end

  desc "create", "create new issue in current project"
  def create
    require_relative './actions/create'
    Pltt::Actions::Create.run
  end

  desc "start ID", "start tracking for issue #ID"
  def start(id)
    require_relative './actions/start'
    Pltt::Actions::Start.run(id)
  end

  desc "stop", "Stop"
  def stop
    require_relative './actions/stop'
    Pltt::Actions::Stop.run
  end

  desc "list", "List all project issues"
  option :my, type: :boolean
  option :label, type: :string
  def list
    require_relative './actions/list'
    Pltt::Actions::List.run(my: options[:my], label: options[:label])
  end

  desc "status", "Status"
  def status
    require_relative './actions/status'
    Pltt::Actions::Status.run
  end

  desc "edit [ID = CURRENT]", "start tracking for issue #ID"
  def edit(id = nil)
    require_relative './actions/edit'
    Pltt::Actions::Edit.run(id)
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

  desc 'sync', 'sync all unsaved entries'
  def sync
    require_relative './actions/base'
    Pltt::Actions::Base.new.sync_all_unsaved_entries
  end
end

Pltt::Runner.start(ARGV)
