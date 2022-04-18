# frozen_string_literal: true

module Nochmal
  module MigrationData
    # Track the status of the whole migration
    class Meta < ActiveRecord::Base
      self.table_name = :nochmal_migration_data_meta

      def update_status
        self.status =
          case migrated <=> expected
          when -1 then :partial
          when 0  then :done
          when 1  then :too_much
          end
      end

      def update_status!
        update_status
        save!
      end

      def done?
        status.to_s == "done"
      end
    end
  end
end
