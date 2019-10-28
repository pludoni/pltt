require_relative './base'
# rubocop:disable Naming/UncommunicativeMethodParamName
class Pltt::Actions::List < Pltt::Actions::Base
  def run(my: false, label: nil)
    require 'terminal-table'

    table = Terminal::Table.new
    gitlab_api.issues(scope: my ? 'assigned-to-me' : 'all', label: label).each do |issue|
      table.add_row [
        issue.iid.to_s.magenta,
        issue.title.green + "\n#{issue.web_url.dark_gray}",
        issue.state.gray,
        issue.milestone&.title,
        issue.labels.map { |i| "[~#{i}]" }.join
      ]
    end
    puts table
  end
end
