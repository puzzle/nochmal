# frozen_string_literal: true

module Nochmal
  module MigrationData
    class CreateMigrationTables < ActiveRecord::Migration[6.0] # :nodoc:
      def up # rubocop:disable Metrics/MethodLength
        create_table :nochmal_migration_data_status do |t|
          t.belongs_to :record, polymorphic: true

          t.string :uploader_type
          t.string :filename

          t.string :status
        end

        return if table_exists?(:nochmal_migration_data_meta)

        create_table :nochmal_migration_data_meta do |t|
          t.string :record_type
          t.string :uploader_type
          t.integer :expected
          t.integer :migrated
          t.string :status
        end
      end
    end
  end
end
