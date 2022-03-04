# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

# This module is the base of the nochmal gem
module Nochmal
  autoload :ActiveStorageHelper, "nochmal/active_storage_helper"
  autoload :CarrierwaveMigrationHelper, "nochmal/carrierwave_migration_helper.rb"

  autoload :Reupload, "nochmal/reupload.rb"
  autoload :Output, "nochmal/output"

  autoload :VERSION, "nochmal/version"
end

require_relative "nochmal/railtie" if defined?(Rails)
