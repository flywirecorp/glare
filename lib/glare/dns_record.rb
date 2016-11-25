module Glare
  class DnsRecord
    include Comparable

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

    def <=>(dns_record)
      @type <=> dns_record.type &&
        @name <=> dns_record.name &&
        @content <=> dns_record.content
    end

    attr_reader :content, :type, :name
  end
end
