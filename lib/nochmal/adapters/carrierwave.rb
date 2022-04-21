# frozen_string_literal: true

module Nochmal
  module Adapters
    # collect common things for the carrierwave analysis and migration
    class Carrierwave < Base
      PREFIX = "carrierwave_"

      def models_with_attachments
        @models_with_attachments ||= begin
          Rails.application.eager_load!

          ActiveRecord::Base
            .descendants
            .reject(&:abstract_class?)
            .select { |model| carrierwave?(model) }
        end
      end

      def collection(model, uploader)
        maybe_sti_scope(model).where.not(db_column(uploader) => nil)
      end

      def blob(attachment)
        Pathname.new(
          attachment.file.file.gsub(
            attachment.mounted_as.to_s,
            not_prefixed(attachment.mounted_as).to_s
          )
        )
      end

      private

      def db_column(uploader_name)
        not_prefixed(uploader_name)
      end

      def not_prefixed(type)
        type.to_s.delete_prefix(PREFIX).to_sym
      end

      def prefixed(type)
        :"#{PREFIX}#{not_prefixed(type)}"
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
