require_relative './base'
require 'httparty'
require 'pastel'
require_relative 'sentry_base'

class Pltt::Actions::CommitSentry < Pltt::Actions::SentryBase
  PASTEL = Pastel.new
  attr_reader :issue_id

  def initialize(issue_id)
    @issue_id = issue_id
  end

  def run
    case @issue_id
    when %r{https://sentry\.pludoni\.com/organizations/.*/issues/(\d+)/}
      @issue_id = Regexp.last_match(1)
    end

    issue_data = get("organizations/#{organisation}/issues/#{issue_id}/events/latest/", query: nil)
    unless issue_data.success?
      warn pastel.red("Error: #{issue_data.code} #{issue_data.body}")
      p issue_data
      exit 1
    end
    issue_data = JSON.parse(issue_data.body)

    title = issue_data['title']
    culprit = issue_data['culprit']

    message = "ExceptionFix: #{culprit}\n\nFix #{title}\nFixes #{issue_id}"

    puts pastel.green("Starting commit for #{issue_id} #{title}")
    puts pastel.green("Commit message: #{message}")

    exec("git commit -m #{Shellwords.escape(message)} -e")
  end
end

