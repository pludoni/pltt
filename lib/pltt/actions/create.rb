require_relative './base'
require 'tty-prompt'
class Pltt::Actions::Create < Pltt::Actions::Base
  def run
    puts "New issue in project #{config['project'].green}:"
    prompt = TTY::Prompt.new
    title = prompt.ask('Enter issue title:') do |q|
      q.required true
    end
    description = prompt.multiline("Description").join("\n")
    labels = gitlab_api.labels.map(&:name)
    selected_labels = if labels.length > 0
                        prompt.multi_select("Select labels", labels, per_page: 20)
                      else
                        []
                      end
    issue = gitlab_api.create_issue(title, description, selected_labels)
    _entry = Pltt::Entry.create_new_for_gitlab_issue(config['project'], issue)

    require 'stringex'
    branch_name = "#{issue.iid}-#{issue.title.downcase.to_url)}"
    if prompt.yes?("Automatically create a branch #{branch_name} and check out locally?")
      gitlab_api.create_branch_and_merge_request(branch_name, issue)
      system 'git fetch'
      system "git checkout #{branch_name}"
    end
  end
end
