# frozen_string_literal: true

module Nochmal
  module Adapters
    # Resume a started migration
    class CarrierwaveResume < CarrierwaveMigration
      # action

      def reupload(record, type)
        _, pathname = blob(record.send(type))

        status = MigrationData::Status.find_by(record: record, uploader_type: type, filename: pathname.to_s)

        if status&.migrated?
          { status: :skip }
        else
          super(record, type)
        end
      end

      # hooks

      def setup
        return true if MigrationData::Status.table_exists? && MigrationData::Meta.table_exists?

        Output.notes [
          "It appears that no previous migration has been running.",
          'Creating the needed tables and "resume from spare 1"...'
        ]
        super
      end
    end
  end
end
