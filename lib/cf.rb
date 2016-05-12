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
  private_constant :Credentials

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
  private_constant :DnsRecord

  class Result
    def initialize(result)
      @result = result
    end

    def ocurrences
      JSON.parse(@result)['result_info']['count'].to_i
    end

    def first_result_id
      JSON.parse(@result)['result'].first['id']
    end
  end
  private_constant :Result

  class << self
    def register(fqdn, destination, type)
      client = build_client
      zone_id = zone_id(client, fqdn)
      dns_record = DnsRecord.new(type: type, name: fqdn, content: destination)
      records = record_search(client, zone_id, fqdn)
      result = Result.new(records)

      if result.ocurrences == 0
        create(client, zone_id, dns_record)
        return
      end

      existing_record_id = result.first_result_id
      update(client, zone_id, dns_record, existing_record_id)
    end

    def resolve(domain); end

    private

    CF_EMAIL = 'CF_EMAIL'.freeze
    CF_AUTH_KEY = 'CF_AUTH_KEY'.freeze

    def record_search(client, zone_id, fqdn)
      client.get("/zones/#{zone_id}/dns_records", name: fqdn)
    end

    def create(client, zone_id, dns_record)
      client.post("/zones/#{zone_id}/dns_records", dns_record.to_h)
    end

    def update(client, zone_id, dns_record, record_id)
      client.put("/zones/#{zone_id}/dns_records/#{record_id}", dns_record.to_h)
    end

    def zone_id(client, fqdn)
      zone_search = client.get('/zones', name: registered_domain(fqdn))
      Result.new(zone_search).first_result_id
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
