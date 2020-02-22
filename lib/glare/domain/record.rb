# frozen_string_literal: true

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
          operations = existing_records.calculate(dns_records)
          update_current_records(zone_id, operations.updates)
          delete_uneeded_records(zone_id, operations.deletions)
          create_new_records(zone_id, operations.insertions)
        end

        def update_current_records(zone_id, updates)
          updates.each do |update|
            @client.put("/zones/#{zone_id}/dns_records/#{update.record.id}", update.record.to_h)
          end
        end

        def delete_uneeded_records(zone_id, deletions)
          deletions.each do |deletion|
            @client.delete("/zones/#{zone_id}/dns_records/#{deletion.record.id}")
          end
        end

        def create_new_records(zone_id, insertions)
          insertions.each do |insertion|
            @client.post("/zones/#{zone_id}/dns_records", insertion.record.to_h)
          end
        end
      end
    end
  end
end
