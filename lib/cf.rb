require 'public_suffix'
require 'cf/version'
require 'cf/credentials'
require 'cf/client'
require 'cf/domain'
require 'cf/result'
require 'cf/dns_record'
require 'cf/dns_records'

module Cf
  class << self
    def register(fqdn, destination, type)
      client = build_client
      Domain.new(client).register(fqdn, destination, type)
    end

    def resolve(fqdn, type)
      client = build_client
      Domain.new(client).resolve(fqdn, type)
    end

    def deregister(fqdn, type)
      client = build_client
      Domain.new(client).deregister(fqdn, type)
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
