require 'public_suffix'
require 'json'

module Cf
  class Client
    BASE_URL = '/client/v4'.freeze

    def initialize(email, auth_key)

    end

    def get(query, params)
      # wadus.get(BASE_URL + query)
    end

    def post(query, data)
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

  class DnsRecord
    def initialize(name:, type:, content:)
      @name = name
      @type = type
      @content = content
    end

    def to_h
      {
        type: @type,
        name: @name,
        content: @content
      }
    end
  end

  class << self
    def register(fqdn, destination, type)
      @client = build_client
      zone_id = zone_id(fqdn)
      dns_record = DnsRecord.new(type: type, name: fqdn, content: destination)
      @client.post("/zones/#{zone_id}/dns_records", dns_record.to_h)
    end

    def resolve(domain); end

    private

    CF_EMAIL = 'CF_EMAIL'.freeze
    CF_AUTH_KEY = 'CF_AUTH_KEY'.freeze

    def zone_id(fqdn)
      zone_info = @client.get('/zones', name: registered_domain(fqdn))
      JSON.parse(zone_info)['result'].first['id']
    end

    def registered_domain(fqdn)
      PublicSuffix.parse(fqdn).domain
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
