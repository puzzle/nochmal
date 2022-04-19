# frozen_string_literal: true

module Nochmal
  module Adapters
    # Wrap ActiveStorageHelper and use carrierwave as simulated from_storage_service
    class CarrierwaveMigration < Carrierwave
      def attachment_types_for(model)
        @types[model] ||= model.uploaders.map do |uploader, uploader_class|
          @uploaders[model] = { uploader => uploader_class }
          uploader
        end
      end

      def reupload(record, type)
        _record, pathname = blob(record.send(type))

        if pathname.exist?
          StringIO.open(pathname.read) do |temp|
            record.send(not_prefixed(type)).attach(io: temp, filename: pathname.basename)
          end

          { status: :ok }
        else
          { status: :missing, message: "#{pathname} was not found, but was attached to #{record}" }
        end
      end

      def collection(model, uploader)
        super(model, uploader).tap do |scope|
          MigrationData::Meta.find_or_create_by(
            record_type: maybe_sti_scope(model).sti_name,
            uploader_type: uploader
          ).update(expected: scope.count)
        end
      end

      # hooks

      def setup(action)
        @mode = action

        return if @mode == :count
        raise MigrationData::StatusExists if MigrationData::Status.table_exists?

        MigrationData::CreateMigrationTables.new.up
      end

      def teardown
        return if @mode == :count
        raise MigrationData::Incomplete unless completely_done?

        MigrationData::DropMigrationTables.new.up
      end

      def item_completed(record, type, status)
        return if @mode == :count
        return unless %i[ok].include? status

        _, pathname = blob(record.send(type))
        MigrationData::Status.track(record, type, pathname)
      end

      def type_completed(model, type)
        return if @mode == :count

        MigrationData::Meta
          .find_or_create_by(record_type: model.sti_name, uploader_type: type)
          .update(migrated: migrated(model, type))
      end

      private

      def completely_done?
        MigrationData::Meta.all.all?(&:done?)
      end

      def migrated(model, type)
        MigrationData::Status
          .where(record_type: model.sti_name, uploader_type: type)
          .where(status: MigrationData::Status::DONE)
          .count
      end
    end
  end
end
