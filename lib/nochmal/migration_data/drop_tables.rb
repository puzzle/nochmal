# frozen_string_literal: true

module Nochmal
  module MigrationData
    class DropMigrationTables < ActiveRecord::Migration[6.0] # :nodoc:
      def up
        drop_table :nochmal_migration_data_status, if_exists: true
        drop_table :nochmal_migration_data_meta, if_exists: true
      end
    end
  end
end
