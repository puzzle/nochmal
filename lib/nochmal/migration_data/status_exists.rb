# frozen_string_literal: true

module Nochmal
  module MigrationData
    # Provide some help when a migration got aborted.
    #
    # This might happen if the OS or the user kills the process.
    #
    # I suspect an OOM-Kill by the OS or Container-Runtime (K8s/OCP).
    class StatusExists < StandardError
      def initialize
        super <<~ERROR
          It seems like the migration has already been started.

          You may want to resume with
            rails nochmal:carrierwave:resume

          Alternatively, you can manually delete the tables
            - #{Status.table_name}
            - #{Meta.table_name}
          and rerun the migration completely.

          If you want, you can examine the status by interacting with
            - Nochmal::MigrationData::Meta # class/attachment-level stats
            - Nochmal::MigrationData::Status # individual upload stats
          in your rails console.
        ERROR
      end
    end
  end
end
