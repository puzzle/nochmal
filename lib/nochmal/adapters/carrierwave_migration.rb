# frozen_string_literal: true

module Nochmal
  module Adapters
    # Wrap ActiveStorageHelper and use carrierwave as simulated from_storage_service
    class CarrierwaveMigration < Base
      def to_storage_service(service = nil)
        @to_storage_service ||= ActiveStorage.new.to_storage_service(service)
      end

      def models_with_attachments
        @models_with_attachments ||= begin
          Rails.application.eager_load!

          ActiveRecord::Base
            .descendants
            .reject(&:abstract_class?)
            .select { |model| carrierwave?(model) }
        end
      end

      def attachment_types_for(model)
        @types[model] ||= model.uploaders.map do |uploader, uploader_class|
          @uploaders[model] = { uploader => uploader_class }
          model.has_one_attached migration_method(uploader), service: @to_storage_service.name

          uploader
        end
      end

      def collection(model, uploader)
        maybe_sti_scope(model).where.not(uploader => nil)
      end

      def blob(attachment)
        [attachment.model, Pathname.new(attachment.file.file)]
      end

      def notes(model = nil, type = nil)
        return display_helper_notes unless model && type

        uploader = uploader(model, type)

        [
          carrierwave_change(model, type, uploader),
          active_storage_change(type, uploader),
          "\n"
        ].join
      end

      def cleanup(model = nil, type = nil)
        ::ActiveStorage::Attachment
          .where(record_type: model.base_class, name: migration_method(type).to_s)
          .update_all(name: type.to_s)
      end

      private

      def carrierwave_change(model, type, uploader)
      end

      def active_storage_change(type, uploader)
      end

      def display_helper_notes
      end

      def migration_method(type)
        :"carrierwave_#{type}"
      end

      def uploader(model, type)
        @uploaders[model][type]
      end

      def carrierwave?(model)
        model.uploaders.any? do |_name, uploader|
          uploader.new.is_a? CarrierWave::Uploader::Base
        end
      end
    end
  end
end
