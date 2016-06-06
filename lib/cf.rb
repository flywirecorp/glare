require 'public_suffix'
require 'json'
require 'httpclient'
require 'cf/credentials'
require 'cf/client'
require 'cf/domain'

module Cf
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
    attr_reader :content
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

    def ids
      JSON.parse(@result)['result'].map { |result| result['id'] }
    end
  end
  private_constant :Result

  class CfDnsRecord
    def initialize(id:, name:, type:, content:)
      @id = id
      @name = name
      @type = type
      @content = content
    end
    attr_reader :id, :name, :type, :content
  end

  class DnsResult < Result
    def initialize(result)
      super(result)
      @existing_records = records
    end

    def records_to_update(desired_records)
      records.reject do |record|
        desired_records.any? { |r| r.content == record.content }
      end
    end

    private

    def records
      JSON.parse(@result)['result'].map do |item|
        CfDnsRecord.new(
          id: item['id'],
          name: item['name'],
          type: item['type'],
          content: item['content']
        )
      end
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
