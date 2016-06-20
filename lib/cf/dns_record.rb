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
    attr_reader :content, :type
  end
  private_constant :DnsRecord
end
