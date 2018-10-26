require_relative './base'
class Pltt::Actions::Start < Pltt::Actions::Base
  def run(iid)
    exit_if_running!
    require 'tty-prompt'
    require 'stringex'
    require 'git'

    issue = nil
    if iid
      issue = gitlab_api.issue(iid.to_i)
      puts "Issue: #{issue.title.green}"
    else
      prompt = TTY::Prompt.new
      recent = gitlab_api.issues.take(30)
      issue = prompt.select("Select issue to start on", per_page: 20) do |menu|
        recent.each do |this_issue|
          menu.choice "#{this_issue.iid.to_s.magenta} #{this_issue.title}", this_issue
        end
      end
    end
    branch_name = "#{issue.iid}-#{issue.title.downcase.to_url}"
    g = Git.open('.')
    unless g.branches.find(&:current)&.name == branch_name
      checkout_branch(g, branch_name)
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

  def checkout_branch(git, branch_name)
    git.fetch
    existing_branch = git.branches.find { |i| i.name == branch_name }

    prompt = TTY::Prompt.new
    if existing_branch && prompt.yes?("Branch #{branch_name.blue} already exists. should we check out to?")
      puts git.checkout(branch_name)
    elsif prompt.yes?("Automatically create a branch #{branch_name.blue} and check out locally?")
      gitlab_api.create_branch_and_merge_request(branch_name, issue)
      git.fetch
      puts git.checkout(branch_name)
    end
  end
end
