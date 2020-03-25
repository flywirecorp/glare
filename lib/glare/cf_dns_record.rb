# frozen_string_literal: true

module Glare
  class CfDnsRecord
    def initialize(id:, name:, type:, content:, proxied: false, ttl:)
      @id = id
      @name = name
      @type = type
      @content = content
      @proxied = proxied
      @ttl = ttl
    end

    def ==(other)
      @type == other.type &&
        @name == other.name &&
        @content == other.content &&
        @proxied == other.proxied &&
        @ttl == other.ttl
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

    attr_reader :id, :name, :type
    attr_accessor :content, :proxied, :ttl
  end
end
