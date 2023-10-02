require_relative './base'
require 'httparty'
require 'pastel'
require_relative 'sentry_base'

class Pltt::Actions::Errors < Pltt::Actions::SentryBase
  class Issue
    def pastel
      Pltt::Actions::SentryBase.pastel
    end

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
        #{pastel.red(id)} #{title}
          Last: #{pastel.green(last_seen_relative)} Count/Users: #{pastel.green(@sentry['count'])} / #{@sentry['userCount']}
          #{pastel.dim(url)}
      DOC
    end
  end

  def run
    url = "projects/#{organisation}/#{project}/issues/"
    response = get(url, query: { statsPeriod: '14d', query: 'is:unresolved' })
    issues = response.map { |i| Issue.new(i) }
    cutoff = (Date.today - 4).to_time
    puts issues.select { |i| i.last_seen > cutoff }.reverse
  end

  def project
    yaml = YAML.load_file('.gtt.yml')
    yaml['sentry_project'] || yaml['project'].split('/').last
  end
end
