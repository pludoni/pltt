require_relative './base'
class Pltt::Actions::Start < Pltt::Actions::Base
  def run(iid)
    exit_if_running!

    issue = nil
    if iid
      issue = gitlab_api.issue(iid.to_i)
      puts "Issue: #{issue.title.green}"
    else
      require 'tty-prompt'
      prompt = TTY::Prompt.new
      recent = gitlab_api.issues.take(30)
      issue = prompt.select("Select issue to start on", per_page: 20) do |menu|
        recent.each do |this_issue|
          menu.choice "#{this_issue.iid.to_s.magenta} #{this_issue.title}", this_issue
        end
      end
    end
    start_by_issue(issue)
  rescue StandardError => e
    puts "Issue #{issue.iid} not found in project #{config['project']}".red
    puts e.inspect
    exit 1
  end

  def start_by_issue(issue)
    if issue.closed?
      puts "This issue is closed"
      exit 1
    end
    Pltt::Entry.create_new_for_gitlab_issue(config['project'], issue)
  end
end
