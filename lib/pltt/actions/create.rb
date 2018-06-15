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
    Pltt::Entry.create_new_for_gitlab_issue(config['project'], issue)
  end
end
