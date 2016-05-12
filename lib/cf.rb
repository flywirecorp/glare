require 'public_suffix'
require 'json'

module Cf
  class Client
    BASE_URL = '/client/v4'.freeze

    def initialize(email, auth_key)

    end

    def post(query)
      # wadus.post(BASE_URL + query)
    end
  end

  class Credentials
    def initialize(email, auth_key)
      @email = email
      @auth_key = auth_key
    end

    attr_reader :email, :auth_key
  end

  class << self
    def register(fqdn, destination)
      client = build_client
      zone_info = client.get('/zones', name: domain(fqdn))
      zone_id = JSON.parse(zone_info)['result'].first['id']
      client.post("/zones/#{zone_id}/dns_records")
    end

    def resolve(domain); end

    private

    CF_EMAIL = 'CF_EMAIL'.freeze
    CF_AUTH_KEY = 'CF_AUTH_KEY'.freeze

    def domain(fqdn)
      parsed_domain = PublicSuffix.parse(fqdn)
      [parsed_domain.sld, parsed_domain.tld].compact.join('.')
    end

    def client(credentials)
      Cf::Client.new(credentials.email, credentials.auth_key)
    end

    def default_credentials
      email = ENV[CF_EMAIL]
      auth_key = ENV[CF_AUTH_KEY]
      Credentials.new(email, auth_key)
    end

    def build_client
      credentials = default_credentials
      client(credentials)
    end
  end
end
