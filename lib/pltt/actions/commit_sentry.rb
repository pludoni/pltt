require_relative './base'
require 'httparty'
require 'pastel'

class Pltt::Actions::CommitSentry
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

    issue_data = HTTParty.get("#{server}/organizations/#{organisation}/issues/#{issue_id}/events/latest/",
                              headers: { 'Authorization' => "Bearer #{token}" })
    unless issue_data.success?
      warn PASTEL.red("Error: #{issue_data.code} #{issue_data.body}")
      p issue_data
      exit 1
    end
    issue_data = JSON.parse(issue_data.body)

    title = issue_data['title']
    culprit = issue_data['culprit']

    message = "ExceptionFix: #{culprit}\n\nFix #{title}\nFixes #{issue_id}"

    exec("git commit -m #{Shellwords.escape(message)} -e")
  end

  def token
    "627cd87b170a4a40af5fa607525613c61da4d26f8eab45c19dd915a1e3eeac49"
  end

  def server
    'https://sentry.pludoni.com/api/0'
  end

  def organisation
    'pludoni'
  end
end

