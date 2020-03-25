# frozen_string_literal: true

require 'glare/domain/zone'
require 'glare/domain/record'

module Glare
  class Domain
    def initialize(client)
      @client = client
    end

    def register(fqdn, destinations, type, proxied:, ttl:)
      dns_records = Array(destinations).map do |destination|
        DnsRecord.new(type: type, name: fqdn, content: destination, proxied: proxied, ttl: ttl)
      end

      zone = Zone.new(@client, fqdn)
      Record.register(@client, zone, dns_records)
    end

    def resolve(fqdn, type)
      zone = Zone.new(@client, fqdn)
      records = zone.records(type)
      records.contents
    end

    def deregister(fqdn, type)
      zone = Zone.new(@client, fqdn)
      dns_records = zone.records(type)
      Record.deregister(@client, zone, dns_records)
    end

    def proxied?(fqdn, type)
      zone = Zone.new(@client, fqdn)
      records = zone.records(type)
      records.all_proxied?
    end

    def records(fqdn, type)
      zone = Zone.new(@client, fqdn)
      zone.records(type)
    end
  end
end
