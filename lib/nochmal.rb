# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

# This module is the base of the nochmal gem
module Nochmal
  autoload :Reupload, "nochmal/reupload.rb"
  autoload :ActiveStorageHelper, "nochmal/active_storage_helper"
  autoload :Output, "nochmal/output"

  autoload :VERSION, "nochmal/version"
end

require_relative "nochmal/railtie" if defined?(Rails)
