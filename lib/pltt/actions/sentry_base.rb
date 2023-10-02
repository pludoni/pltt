require_relative './base'
require 'httparty'
require 'pastel'
require 'yaml'

class Pltt::Actions::SentryBase
  PASTEL = Pastel.new

  def self.pastel
    PASTEL
  end

  def pastel
    PASTEL
  end

  def token
    @token ||= ENV['SENTRY_TOKEN'] || YAML.load_file(File.expand_path('/etc/pludoni_cli.yml'))['sentry_token']
  end

  def server
    'https://sentry.pludoni.com/api/0/'
  end

  def get(path, query:)
    url = URI.join(server, path).to_s
    puts url
    HTTParty.get(
      url,
      query: query,
      format: :json,
      headers: { "Authorization" => "Bearer #{token}" },
    )
  end

  def organisation
    'pludoni'
  end
end
