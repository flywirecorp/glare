require 'glare/cf_dns_record'
require 'glare/cf_dns_records/updater'

module Glare
  class CfDnsRecords
    class << self
      def from_result(api_response)
        result = api_response.result

        records = result.map do |item|
          CfDnsRecord.new(
            id: item['id'],
            name: item['name'],
            type: item['type'],
            content: item['content'],
            proxied: item['proxied']
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

    def calculate(desired_records)
      Updater.new(@records.dup, desired_records.dup).calculate
    end

    def dup
      CfDnsRecords.new(@records.dup)
    end

    def contents
      @records.map(&:content)
    end

    def all_proxied?
      @records.all? { |r| r.proxied == true }
    end

    def each
      @records.each { |record| yield(record) }
    end

    def map
      @records.map { |record| yield(record) }
    end

    def any?
      @records.any? { |record| yield(record) }
    end

    def delete_if
      @records.delete_if { |record| yield(record) }
    end
  end
end
