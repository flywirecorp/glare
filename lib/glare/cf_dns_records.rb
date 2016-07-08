module Glare
  class CfDnsRecord
    def initialize(id:, name:, type:, content:)
      @id = id
      @name = name
      @type = type
      @content = content
    end
    attr_reader :id, :name, :type, :content
  end

  class CfDnsRecords
    def self.from_result(api_result)
      response = ApiResponse.new(api_result)
      result = response.result

      records = result.map do |item|
        CfDnsRecord.new(
          id: item['id'],
          name: item['name'],
          type: item['type'],
          content: item['content']
        )
      end

      new(records)
    end

    def initialize(records)
      @records = records
    end

    def to_update(desired_records)
      @records.reject do |record|
        desired_records.any? { |r| r.content == record.content }
      end
    end

    def count
      @records.count
    end

    def contents
      @records.map(&:content)
    end

    def each
      @records.each { |record| yield(record) }
    end

    def to_delete(target_number)
      records_to_delete = count - target_number
      return CfDnsRecords.new([]) if records_to_delete < 0

      @records.last(records_to_delete)
    end

    def to_create(desired_records)
      desired_records.drop(count)
    end
  end
end
