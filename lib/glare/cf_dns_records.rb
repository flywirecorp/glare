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
    class << self
      def from_result(api_response)
        result = api_response.result

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

      def empty
        new([])
      end
    end

    def initialize(records)
      @records = records
    end

    def to_update(desired_records)
      records_to_update = desired_records.count
      records = @records.first(records_to_update)
      records.reject do |record|
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
      return CfDnsRecords.empty if records_to_delete < 0

      @records.last(records_to_delete)
    end

    def to_create(desired_records)
      desired_records.drop(count)
    end
  end
end
