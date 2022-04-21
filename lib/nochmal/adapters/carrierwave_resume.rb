# frozen_string_literal: true

module Nochmal
  module Adapters
    # Resume a started migration
    class CarrierwaveResume < CarrierwaveMigration
      # action

      def reupload(record, type)
        status = MigrationData::Status.find_by(
          record_id: record.id, record_type: record.class.sti_name,
          uploader_type: type, filename: blob(record.send(type)).to_s
        )

        if status&.migrated?
          message = status.missing_message if status.missing?
          { status: :skip, message: message }
        else
          super(record, type)
        end
      end

      # hooks

      def setup(action)
        if MigrationData::Status.table_exists? && MigrationData::Meta.table_exists?
          @mode = action
          return true
        end

        Output.notes [
          "It appears that no previous migration has been running.",
          'Creating the needed tables and "resuming from square 1"...'
        ]
        super
      end
    end
  end
end
