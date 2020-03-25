# frozen_string_literal: true

module Glare
  class DnsRecord
    def initialize(name:, type:, content:, proxied:, ttl:)
      @name = name
      @type = type
      @content = content
      @proxied = proxied
      @ttl = ttl
    end

    def to_h
      {
        type: @type,
        name: @name,
        content: @content,
        proxied: @proxied,
        ttl: @ttl
      }
    end

    def ==(other)
      @type == other.type &&
        @name == other.name &&
        @content == other.content &&
        @proxied == other.proxied &&
        @ttl == other.ttl
    end

    attr_reader :content, :type, :name, :proxied, :ttl
  end
end
