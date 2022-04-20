# frozen_string_literal: true

module Nochmal
  module MigrationData
    # Track the status of the whole migration
    class Meta < ActiveRecord::Base
      self.table_name = :nochmal_migration_data_meta

      before_save :update_status

      def done?
        status.to_s == "done"
      end

      def to_s
        [
          record_type, "#", uploader_type, ": ",
          migrated, "/", expected, " -> ", status
        ].join
      end

      private

      def update_status
        self.status = current_status
      end

      def current_status # rubocop:disable Metrics/CyclomaticComplexity
        return nil if migrated.nil? && expected.nil?

        if expected.positive? && migrated.nil?
          "not migrated"
        else
          case migrated.to_i <=> expected
          when -1 then "partial"
          when 0  then "done"
          when 1  then "too much"
          end
        end
      end
    end
  end
end
