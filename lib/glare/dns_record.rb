module Glare
  class DnsRecord
    include Comparable

    def initialize(name:, type:, content:, proxied:)
      @name = name
      @type = type
      @content = content
      @proxied = proxied
    end

    def to_h
      {
        type: @type,
        name: @name,
        content: @content,
        proxied: @proxied
      }
    end

    def <=>(dns_record)
      @type <=> dns_record.type &&
        @name <=> dns_record.name &&
        @content <=> dns_record.content &&
        @proxied <=> dns_record.proxied
    end

    attr_reader :content, :type, :name, :proxied
  end
end
