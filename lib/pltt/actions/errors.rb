require_relative './base'
require 'httparty'
require 'pastel'

class Pltt::Actions::Errors
  PASTEL = Pastel.new
  class Issue
    def title
      @sentry['title']
    end

    def id
      @sentry["shortId"]
    end

    def url
      @sentry['permalink']
    end

    def culprit
      @sentry["culprit"]
    end

    def initialize(sentry_response)
      @sentry = sentry_response
    end

    def last_seen
      @last_seen ||= Time.parse(@sentry['lastSeen'])
    end

    def last_seen_relative
      minutes = (Time.now - last_seen) / 60
      if minutes < 60
        "#{minutes.to_i}min"
      elsif minutes < 60 * 24 * 2
        "#{(minutes / 60).ceil}h"
      else
        "#{(minutes / (60 * 24)).ceil}d"
      end
    end

    def to_s
      <<~DOC
        #{PASTEL.red(id)} #{title}
          Last: #{PASTEL.green(last_seen_relative)} Count/Users: #{PASTEL.green(@sentry['count'])} / #{@sentry['userCount']}
          #{PASTEL.dim(url)}
      DOC
    end
  end

  def run
    url = "https://sentry.pludoni.com/api/0/projects/pludoni/#{project}/issues/"
    response = HTTParty.get(url, format: :json, headers: { "Authorization" => "Bearer #{token}" }, query: { statsPeriod: '14d', query: 'is:unresolved' })
    issues = response.map { |i| Issue.new(i) }
    cutoff = (Date.today - 4).to_time
    puts issues.select { |i| i.last_seen > cutoff }.reverse
  end

  def project
    yaml = YAML.load_file('.gtt.yml')
    yaml['sentry_project'] || yaml['project'].split('/').last
  end

  def token
    "627cd87b170a4a40af5fa607525613c61da4d26f8eab45c19dd915a1e3eeac49"
  end
end
