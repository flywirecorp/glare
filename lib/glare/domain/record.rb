module Glare
  class Domain
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
          delete_uneeded_records(zone_id, dns_records, existing_records)
          update_current_records(zone_id, dns_records, existing_records)
          create_new_records(zone_id, dns_records, existing_records)
        end

        def update_current_records(zone_id, dns_records, existing_records)
          records_to_update = existing_records.to_update(dns_records)
          updates = records_to_update.zip(dns_records)
          updates.each do |existing_record, dns_record|
            @client.put("/zones/#{zone_id}/dns_records/#{existing_record.id}", dns_record.to_h)
          end
        end

        def delete_uneeded_records(zone_id, dns_records, existing_records)
          records_to_delete = existing_records.to_delete(dns_records.count)
          records_to_delete.each do |record|
            @client.delete("/zones/#{zone_id}/dns_records/#{record.id}")
          end
        end

        def create_new_records(zone_id, dns_records, existing_records)
          records_to_create = existing_records.to_create(dns_records)
          create(zone_id, records_to_create)
        end

        def create(zone_id, dns_records)
          dns_records.each do |dns_record|
            @client.post("/zones/#{zone_id}/dns_records", dns_record.to_h)
          end
        end
      end
    end
  end
end
