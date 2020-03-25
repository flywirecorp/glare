# frozen_string_literal: true

module Glare
  class CfDnsRecords
    class Updater
      class Operations
        def initialize
          @updates = []
          @insertions = []
          @deletions = []
          @count = 0
        end

        attr_reader :updates, :insertions, :deletions, :count

        def add_updates(updates)
          @count += updates.count
          @updates += updates
        end

        def add_insertions(insertions)
          @count += insertions.count
          @insertions += insertions
        end

        def add_deletions(deletions)
          @count += deletions.count
          @deletions += deletions
        end
      end

      class Operation
        def initialize(record, action)
          @record = record.dup
          @action = action
        end

        def ==(other)
          @record == other.record &&
            @action == other.action
        end

        attr_reader :action, :record
      end

      def initialize(current_records, new_contents)
        @current_records = current_records.dup
        @new_contents = new_contents.dup
      end

      def calculate
        drop_same_records

        operations = Operations.new
        operations.add_updates(updated_records)
        operations.add_insertions(new_records)
        operations.add_deletions(deleted_records)

        operations
      end

      private

      def drop_same_records
        new_contents =  @new_contents.dup
        current_records = @current_records.dup

        @new_contents.delete_if do |new_content|
          current_records.any? { |x| x == new_content }
        end

        @current_records.delete_if do |current_record|
          new_contents.any? { |x| x == current_record }
        end
      end

      def updated_records
        operations = []

        @current_records.delete_if do |record|
          if (new_record = @new_contents.shift)
            final_record = record.dup
            final_record.content = new_record.content
            final_record.proxied = new_record.proxied
            final_record.ttl = new_record.ttl
            operations << Operation.new(final_record, :update)
            true
          else
            false
          end
        end

        operations
      end

      def new_records
        @new_contents.map do |new_record|
          Operation.new(new_record, :add)
        end
      end

      def deleted_records
        @current_records.map do |record|
          Operation.new(record, :delete)
        end
      end
    end
  end
end
