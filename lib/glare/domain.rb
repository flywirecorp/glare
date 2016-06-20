module Glare
  class Domain
    class Zone
      def initialize(client, fqdn)
        @client = client
        @fqdn = fqdn
      end

      def records(type)
        records = record_search(type)
        DnsRecords.new(records)
      end

      def id
        return @id if @id
        zone_search = @client.get('/zones', name: registered_domain)
        @id = Result.new(zone_search).first_result_id
      end

      private

      def registered_domain
        PublicSuffix.parse(@fqdn).domain
      end

      def record_search(type)
        @client.get("/zones/#{id}/dns_records", name: @fqdn, type: type)
      end
    end

    class Record
      class << self
        def register(client, zone, dns_records)
          @client = client
          existing_records = zone.records(dns_records.first.type)
          zone_id = zone.id

          update(zone_id, dns_records, existing_records)
        end

        def deregister(client, zone, dns_records)
          @client = client
          zone_id = zone.id

          delete(zone_id, dns_records)
        end

        private

        def delete(zone_id, dns_records)
          dns_records.each do |record|
            @client.delete("/zones/#{zone_id}/dns_records/#{record.id}")
          end
        end

        def update(zone_id, dns_records, existing_records)
          update_current_records(zone_id, dns_records, existing_records)
          delete_uneeded_records(zone_id, dns_records, existing_records)
          create_new_records(zone_id, dns_records, existing_records)
        end

        def update_current_records(zone_id, dns_records, existing_records)
          records_to_update = existing_records.records_to_update(dns_records)
          updates = records_to_update.zip(dns_records)
          updates.each do |existing_record, dns_record|
            @client.put("/zones/#{zone_id}/dns_records/#{existing_record.id}", dns_record.to_h)
          end
        end

        def delete_uneeded_records(zone_id, dns_records, existing_records)
          records_to_delete = existing_records.records_to_delete(dns_records.count)
          records_to_delete.each do |record|
            @client.delete("/zones/#{zone_id}/dns_records/#{record.id}")
          end
        end

        def create_new_records(zone_id, dns_records, existing_records)
          records_to_create = existing_records.records_to_create(dns_records)
          create(zone_id, records_to_create)
        end

        def create(zone_id, dns_records)
          dns_records.each do |dns_record|
            @client.post("/zones/#{zone_id}/dns_records", dns_record.to_h)
          end
        end
      end
    end

    def initialize(client)
      @client = client
    end

    def register(fqdn, destinations, type)
      dns_records = Array(destinations).map do |destination|
        DnsRecord.new(type: type, name: fqdn, content: destination)
      end

      zone = Zone.new(@client, fqdn)
      Record.register(@client, zone, dns_records)
    end

    def resolve(fqdn, type)
      zone = Zone.new(@client, fqdn)
      result = zone.records(type)
      result.contents
    end

    def deregister(fqdn, type)
      zone = Zone.new(@client, fqdn)
      dns_records = zone.records(type)
      Record.deregister(@client, zone, dns_records)
    end
  end
end
