# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

# This module is the base of the nochmal gem
module Nochmal
  module Adapters
    autoload :Base,                 "nochmal/adapters/base"
    autoload :ActiveStorage,        "nochmal/adapters/active_storage"
    autoload :Carrierwave,          "nochmal/adapters/carrierwave"
    autoload :CarrierwaveAnalyze,   "nochmal/adapters/carrierwave_analyze"
    autoload :CarrierwaveMigration, "nochmal/adapters/carrierwave_migration"
  end

  module MigrationData
    # ar-models to track data
    autoload :Meta,   "nochmal/migration_data/meta"
    autoload :Status, "nochmal/migration_data/status"

    # migration to back ar-models
    autoload :CreateMigrationTables, "nochmal/migration_data/create_tables"
    autoload :DropMigrationTables,   "nochmal/migration_data/drop_tables"

    # exceptions
    autoload :Incomplete,   "nochmal/migration_data/incomplete"
    autoload :StatusExists, "nochmal/migration_data/status_exists"
  end

  autoload :Reupload, "nochmal/reupload"
  autoload :Output, "nochmal/output"

  autoload :VERSION, "nochmal/version"
end

require_relative "nochmal/railtie" if defined?(Rails)
