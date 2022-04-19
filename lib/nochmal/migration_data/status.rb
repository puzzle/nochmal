# frozen_string_literal: true

module Nochmal
  module MigrationData
    # Track the status of individual uploads to be migrated
    class Status < ActiveRecord::Base
      self.table_name = :nochmal_migration_data_status

      belongs_to :record, polymorphic: true

      scope :missing, -> { where(status: "missing") }
      scope :ok, -> { where(status: "ok") }

      def migrated?
        status.present?
      end

      def missing?
        status.to_s == "missing"
      end

      def missing_message
        "#{filename} was not found, but was attached to #{record}"
      end
    end
  end
end
