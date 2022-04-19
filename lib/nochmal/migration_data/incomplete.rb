# frozen_string_literal: true

module Nochmal
  module MigrationData
    # A migration may not be complete...
    class Incomplete < StandardError
      def initialize(*_args)
        super <<~MESSAGE
          This did not end well...

            #{Meta.all.map(&:inspect).join("\n  ")}

          Care to clean up the mess?
        MESSAGE
      end
    end
  end
end
