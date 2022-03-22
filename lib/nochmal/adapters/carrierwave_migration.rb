# frozen_string_literal: true

module Nochmal
  module Adapters
    # Wrap ActiveStorageHelper and use carrierwave as simulated from_storage_service
    class CarrierwaveMigration
      def from_storage_service(_service = nil); end

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
        @types ||= {}
        @types[model] ||= model.uploaders.keys.each do |uploader| # rubocop:disable Style/HashEachMethods I want to return the keys
          model.has_one_attached migration_method(uploader), service: @to_storage_service.name
        end
      end

      def collection(model, uploader)
        maybe_sti_scope = if !model.descends_from_active_record? || model.descendants.any?
                            model.where(type: model.sti_name)
                          else
                            model
                          end
  
        maybe_sti_scope.where.not(uploader => nil)
      end
  
      def blob(attachment)
        [attachment.model, Pathname.new(attachment.file.file)]
      end
  
      def migration_method(type)
        :"carrierwave_#{type}"
      end

      private

      def carrierwave?(model)
        model.uploaders.any? do |_name, uploader|
          uploader.new.is_a? CarrierWave::Uploader::Base
        end
      end
    end
  end
end
