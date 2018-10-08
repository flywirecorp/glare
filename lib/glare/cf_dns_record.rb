module Glare
  class CfDnsRecord
    def initialize(id:, name:, type:, content:, proxied: false)
      @id = id
      @name = name
      @type = type
      @content = content
      @proxied = proxied
    end

    def ==(cf_dns_record)
      @type == cf_dns_record.type &&
        @name == cf_dns_record.name &&
        @content == cf_dns_record.content &&
        @proxied == cf_dns_record.proxied
    end

    def to_h
      {
        type: @type,
        name: @name,
        content: @content,
        proxied: @proxied
      }
    end

    attr_reader :id, :name, :type
    attr_accessor :content, :proxied
  end
end
