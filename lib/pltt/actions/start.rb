require_relative './base'
class Pltt::Actions::Start < Pltt::Actions::Base
  def run(iid)
    exit_if_running!

    issue = gitlab_api.issue(iid.to_i)
    puts "Issue: #{issue.title.green}"
    if issue.closed?
      puts "This issue is closed"
      exit 1
    end
    Pltt::Entry.create_new_for_gitlab_issue(config['project'], issue)
  rescue Gitlab::Error::NotFound
    puts "Issue #{iid} not found in project #{config['project']}".red
    exit 1
  end
end
