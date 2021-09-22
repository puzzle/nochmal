# frozen_string_literal: true

require_relative "nochmal/version"

require_relative "nochmal/railtie" if defined?(Rails)

require_relative "nochmal/active_storage_helper"
require_relative "nochmal/reupload"
require_relative "nochmal/output"

# This module is the base of the nochmal gem
module Nochmal
end
