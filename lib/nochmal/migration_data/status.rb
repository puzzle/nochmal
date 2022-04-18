# frozen_string_literal: true

module Nochmal
  module MigrationData
    # Track the status of individual uploads to be migrated
    class Status < ActiveRecord::Base
      self.table_name = :nochmal_migration_data_status

      belongs_to :record, polymorphic: true

      DONE = "done"

      def self.track(record, type, pathname)

        new(
          record: record,
          uploader_type: type,
          filename: pathname,
          status: DONE
        ).save!
      end

      def migrated?(record, type, pathname)
        where(
          record: record,
          uploader_type: type,
          filename: pathname,
          status: DONE
        ).count == 1
      end
    end
  end
end
