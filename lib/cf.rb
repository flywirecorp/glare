module Cf
  class Client
    def initialize(email, auth_key, base_url)
      @base_url = base_url
    end

    def post(query)
      # wadus.post(base_url + query)
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
    def register(domain, destination)
     client = build_client
     client.post('/zones/zone_id/dns_records')
    end

    def resolve(domain); end

    private

    CF_EMAIL = 'CF_EMAIL'.freeze
    CF_AUTH_KEY = 'CF_AUTH_KEY'.freeze
    BASE_URL = '/client/v4'.freeze

    def client(credentials)
      Cf::Client.new(credentials.email, credentials.auth_key, BASE_URL)
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
