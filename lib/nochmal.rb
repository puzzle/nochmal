# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

# This module is the base of the nochmal gem
module Nochmal
  module Adapters
    autoload :Base,                 "nochmal/adapters/base"
    autoload :ActiveStorage,        "nochmal/adapters/active_storage"
    autoload :CarrierwaveMigration, "nochmal/adapters/carrierwave_migration"
  end

  autoload :Reupload, "nochmal/reupload"
  autoload :Output, "nochmal/output"

  autoload :VERSION, "nochmal/version"
end

require_relative "nochmal/railtie" if defined?(Rails)
