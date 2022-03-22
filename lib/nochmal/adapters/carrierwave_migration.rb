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
        <<~TEXT
          # replace #{model.name.underscore}.#{type}_url in your views
          # Change carrierwave-uploader in #{model.name}:
            mount_uploader :#{migration_method(type)}, #{uploader.name}, mount_on: '#{type}'
        TEXT
      end

      def active_storage_change(type, uploader)
        versions = uploader.versions.map do |name, version|
          "attachable.variant :#{name}, #{version.processors.flat_map(&:compact)}"
        end

        return "  has_one_attached :#{type}" if versions.none?

        <<~TEXT
            has_one_attached :#{type} do |attachable|
              #{versions.join}
            end
          # uploader #{type} has #{versions.size} versions
        TEXT
      end

      def display_helper_notes
        <<~RUBY
          module ImageDisplayHelper
            # Usage: image_tag(image_url(person, picture, '72x72'))
            def image_url(model, name, size = nil) # rubocop:disable Metrics/MethodLength
              if model.send(name.to_sym).attached?
                model.send(name.to_sym).yield_self do |pic|
                  if size
                    # variant passes to mini_magick or vips, I assume mini_magick here
                    pic.variant(resize_to_limit: [size, size])
                  else
                    pic
                  end
                end
              elsif model.send(:"carrierwave_\#{name}")
                if size
                  model.send(:"carrierwave_\#{name}_url")
                else
                  model.send(:"carrierwave_\#{name}_url", size: "\#{size}x\#{size}")
                end
              end
            end

            # Usage: image_tag(image_variant(person, picture, :thumb))
            def image_variant(model, name, variant)
              if model.send(name.to_sym).attached?
                model.send(name.to_sym).variant(variant.to_sym)
              else
                model.send(:"carrierwave_\#{name}").send(variant.to_sym).url
              end
            end
          end
        RUBY
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
