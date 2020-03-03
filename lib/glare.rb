# frozen_string_literal: true

require 'public_suffix'
require 'glare/version'
require 'glare/credentials'
require 'glare/client'
require 'glare/domain'
require 'glare/api_response'
require 'glare/dns_record'
require 'glare/cf_dns_records'
require 'glare/errors'

module Glare
  class << self
    def register(fqdn, destination, type, proxied: false, ttl: 1)
      client.register(fqdn, destination, type, proxied: proxied, ttl: ttl)
    end

    def resolve(fqdn, type)
      client.resolve(fqdn, type)
    end

    def deregister(fqdn, type)
      client.deregister(fqdn, type)
    end

    def proxied?(fqdn, type)
      client.roxied?(fqdn, type)
    end

    def records(fqdn, type)
      client.records(fqdn, type)
    end

    def client
      Instance.new
    end
  end

  class Instance
    def initialize
      @client = Domain.new(build_client)
    end

    def register(fqdn, destination, type, proxied: false, ttl: 1)
      @client.register(fqdn, destination, type, proxied: proxied, ttl: ttl)
    end

    def resolve(fqdn, type)
      @client.resolve(fqdn, type)
    end

    def deregister(fqdn, type)
      @client.deregister(fqdn, type)
    end

    def proxied?(fqdn, type)
      @client.proxied?(fqdn, type)
    end

    def records(fqdn, type)
      @client.records(fqdn, type)
    end

    private

    CF_EMAIL = 'CF_EMAIL'
    CF_AUTH_KEY = 'CF_AUTH_KEY'
    CF_API_TOKEN = 'CF_API_TOKEN'

    def default_credentials
      email = ENV.fetch(CF_EMAIL)
      auth_key = ENV.fetch(CF_AUTH_KEY)
      Credentials.new(email, auth_key)
    end

    def client_with_api_key
      credentials = default_credentials
      Glare::Client.new.from_global_api_key(credentials.email, credentials.auth_key)
    end

    def client_with_api_token
      return nil unless ENV.key?(CF_API_TOKEN)

      api_token = ENV.fetch(CF_API_TOKEN)
      Glare::Client.new.from_scoped_api_token(api_token)
    end

    def build_client
      client_with_api_token || client_with_api_key
    end
  end
end
