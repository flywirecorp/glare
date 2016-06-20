module Cf
  class CfDnsRecord
    def initialize(id:, name:, type:, content:)
      @id = id
      @name = name
      @type = type
      @content = content
    end
    attr_reader :id, :name, :type, :content
  end

  class DnsRecords < Result
    def initialize(result)
      super(result)
      @records = records
    end

    def records_to_update(desired_records)
      @records.reject do |record|
        desired_records.any? { |r| r.content == record.content }
      end
    end

    def count
      @records.count
    end

    def each
      @records.each { |record| yield(record) }
    end

    def records_to_delete(targer_number)
      records_to_delete = count - targer_number
      return [] if records_to_delete < 0

      @records.pop(records_to_delete)
    end

    def records_to_create(desired_records)
      desired_records.drop(count)
    end

    private

    def records
      result['result'].map do |item|
        CfDnsRecord.new(
          id: item['id'],
          name: item['name'],
          type: item['type'],
          content: item['content']
        )
      end
    end
  end
end
