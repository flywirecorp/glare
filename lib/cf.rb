require 'public_suffix'
require 'json'
require 'httpclient'

# Test Cf::Client unitary

module Cf
  class Client
    BASE_URL = 'https://api.cloudflare.com/client/v4'.freeze

    def initialize(email, auth_key)
      @headers = {
        'Content-Type' => 'application/json',
        'X-Auth-Email' => email,
        'X-Auth-Key' => auth_key
      }
    end

    def get(query, params)
      http = HTTPClient.new
      http.get_content(BASE_URL + query, params, @headers)
    end

    def post(query, data)
      http = HTTPClient.new
      json_data = JSON.generate(data)
      http.post(BASE_URL + query, json_data, @headers)
    end

    def put(query, data)
      http = HTTPClient.new
      json_data = JSON.generate(data)
      http.put(BASE_URL + query, json_data, @headers)
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

    def first_result_content
      return if ocurrences == 0
      JSON.parse(@result)['result'].first['content']
    end
  end
  private_constant :Result

  class Domain
    class Zone
      def initialize(client, fqdn)
        @client = client
        @fqdn = fqdn
      end

      def records
        records = record_search
        Result.new(records)
      end

      def id
        return @id if @id
        zone_search = @client.get('/zones', name: registered_domain)
        @id = Result.new(zone_search).first_result_id
      end

      private

      def registered_domain
        PublicSuffix.parse(@fqdn).domain
      end

      def record_search
        @client.get("/zones/#{id}/dns_records", name: @fqdn)
      end
    end

    class Record
      class << self
        def register(client, zone, dns_record)
          @client = client
          result = zone.records
          zone_id = zone.id

          if result.ocurrences == 0
            create(zone_id, dns_record)
            return
          end

          existing_record_id = result.first_result_id
          update(zone_id, dns_record, existing_record_id)
        end

        private

        def create(zone_id, dns_record)
          @client.post("/zones/#{zone_id}/dns_records", dns_record.to_h)
        end

        def update(zone_id, dns_record, record_id)
          @client.put("/zones/#{zone_id}/dns_records/#{record_id}", dns_record.to_h)
        end
      end
    end

    def initialize(client)
      @client = client
    end

    def register(fqdn, destination, type)
      dns_record = DnsRecord.new(type: type, name: fqdn, content: destination)

      zone = Zone.new(@client, fqdn)
      Record.register(@client, zone, dns_record)
    end

    def resolve(fqdn)
      zone = Zone.new(@client, fqdn)
      result = zone.records
      result.first_result_content
    end
  end

  class << self
    def register(fqdn, destination, type)
      client = build_client
      Domain.new(client).register(fqdn, destination, type)
    end

    def resolve(fqdn)
      client = build_client
      Domain.new(client).resolve(fqdn)
    end

    private

    CF_EMAIL = 'CF_EMAIL'.freeze
    CF_AUTH_KEY = 'CF_AUTH_KEY'.freeze

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
