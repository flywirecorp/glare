module Glare
  class CfDnsRecord
    include Comparable

    def initialize(id:, name:, type:, content:)
      @id = id
      @name = name
      @type = type
      @content = content
    end

    def <=>(cf_dns_record)
      @type <=> cf_dns_record.type &&
        @name <=> cf_dns_record.name &&
        @content <=> cf_dns_record.content
    end

    def to_h
      {
        type: @type,
        name: @name,
        content: @content
      }
    end

    attr_reader :id, :name, :type
    attr_accessor :content
  end
end
