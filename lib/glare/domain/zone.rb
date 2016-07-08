module Glare
  class Domain
    class Zone
      def initialize(client, fqdn)
        @client = client
        @fqdn = fqdn
      end

      def records(type)
        api_result = record_search(type)
        CfDnsRecords.from_result(api_result)
      end

      def id
        return @id if @id
        zone_search = @client.get('/zones', name: registered_domain)
        @id = ApiResponse.new(zone_search).first_result_id
      end

      private

      def registered_domain
        PublicSuffix.parse(@fqdn).domain
      end

      def record_search(type)
        @client.get("/zones/#{id}/dns_records", name: @fqdn, type: type)
      end
    end
  end
end
