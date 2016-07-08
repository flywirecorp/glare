require 'glare/domain/cf_zones'

module Glare
  class Domain
    class CfZones
      def self.from_result(api_response)
        response = ApiResponse.new(api_response)
        result = response.result

        zones = result.map do |item|
          CfZone.new(
            id: item['id'],
            name: item['name']
          )
        end

        new(zones)
      end

      def initialize(zones)
        @zones = zones
      end

      def first
        @zones.first
      end
    end

    class CfZone
      def initialize(id:, name:)
        @id = id
        @name = name
      end
      attr_reader :id, :name
    end
  end
end
