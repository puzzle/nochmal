# frozen_string_literal: true

module Nochmal
  module Adapters
    # Wrap ActiveStorageHelper and use carrierwave as simulated from_storage_service
    class CarrierwaveAnalyze < Carrierwave # rubocop:disable Metrics/ClassLength
      def initialize
        super

        @carrierwave_changed = []
        @variants_present = false
      end

      def attachment_types_for(model)
        @types[model] ||= model.uploaders.map do |uploader, uploader_class|
          @uploaders[model] = { uploader => uploader_class }
          model.has_one_attached prefixed(uploader), service: @to_storage_service.name

          uploader
        end
      end

      def empty_collection?(_model, _uploader)
        false # simulate that uploads exist
      end

      def notes(model = nil, type = nil)
        return [display_helper_notes, gemfile_additions].join("\n") unless model && type
        return nil if @carrierwave_changed.include?(model.base_class.sti_name)

        @carrierwave_changed << model.base_class.sti_name
        uploader = uploader(model, type)

        [
          carrierwave_change(model, type, uploader),
          active_storage_change(type, uploader),
          validation_notes(model, type, uploader),
          uploader_change(uploader), "\n"
        ].join
      end

      def reupload(_record, _type)
        Output.print_progress_indicator
      end

      private

      def carrierwave_change(model, type, uploader)
        <<~TEXT
          # replace #{model.name.underscore}.#{type}_url in your views
          # Change carrierwave-uploader in #{model.name}:
          class #{model.name}
            mount_uploader :#{prefixed(type)}, #{uploader.name}, mount_on: '#{type}'
        TEXT
      end

      def active_storage_change(type, uploader)
        versions = uploader.versions.map do |name, version|
          "attachable.variant :#{name}, #{version.processors.map(&:compact).to_h}"
        end

        return "  has_one_attached :#{type}" if versions.none?

        @variants_present = true

        <<~TEXT
            has_one_attached :#{type} do |attachable|
              #{versions.join}
            end
          # uploader #{type} has #{versions.size} versions
        TEXT
      end

      def validation_notes(model, type, uploader)
        <<~TEXT
          # Check for #{type} validations in #{model} and #{uploader}
          # Take a look at https://github.com/igorkasyanchuk/active_storage_validations
          #
          # Please make your validation switchable, the validation does not
          # work properly for the migration.
            if ENV['NOCHMAL_MIGRATION'].blank? # if not migrating RIGHT NOW, i.e. normal case
              validates :picture, dimension: { width: { max: 8_000 }, height: { max: 8_000 } },
                                  content_type: ['image/jpeg', 'image/gif', 'image/png']
            end
          end
        TEXT
      end

      def uploader_change(uploader)
        <<~TEXT
          # Ensure that #{uploader}#store_dir does not have a prefix of
          # "carrierwave_".  To find the existing files, you need to add
          # "mounted_as.to_s.delete_prefix('carrierwave_')" at the appropriate
          # location. If there is no "carrierwave_"-prefix in the generated path,
          # everything is fine.
        TEXT
      end

      def display_helper_notes
        <<~RUBY
          module UploadDisplayHelper
            # This method provides a facade to serve uploads either from ActiveStorage or
            # CarrierWave
            #
            # Usage:
            #
            # upload_url(person, :picture)
            # upload_url(person, :picture, size: '72x72')
            # upload_url(person, :picture, size: '72x72')
            # upload_url(person, :picture, variant: :thumb)
            # upload_url(person, :picture, variant: :thumb, default: 'profil')
            #
            # could be
            #
            # person.picture or
            # person.picture.variant(resize_to_limit: [72, 72]) or
            # person.picture.variant(:thumb)
            #
            # This helper returns a suitable first argument for image_tag (the image location),
            # but also for the second arg of link_to (the target).
            def upload_url(model, name, size: nil, default: model.class.name.underscore, variant: nil) # rubocop:disable Metrics/MethodLength,Metrics/PerceivedComplexity
              return upload_variant(model, name, variant, default: default) if variant.present?

              if model.send(name.to_sym).attached?
                model.send(name.to_sym).yield_self do |pic|
                  if size
                    # variant passes to mini_magick or vips, I assume mini_magick here
                    pic.variant(resize_to_limit: extract_image_dimensions(size))
                  else
                    pic
                  end
                end
              elsif model.respond_to?(:"carrierwave_#{name}") && model.send(:"carrierwave_#{name}")
                model.send(:"carrierwave_#{name}_url")
              else
                upload_default(default)
              end
            end

            # return the filename of the uploaded file
            def upload_name(model, name)
              if model.send(name.to_sym).attached?
                model.send(name.to_sym).filename.to_s
              elsif model.respond_to?(:"carrierwave_#{name}_identifier")
                model.send(:"carrierwave_#{name}_identifier")
              end
            end

            def upload_exists?(model, name)
              return true if model.send(name.to_sym).attached?

              if model.respond_to?(:"carrierwave_#{name}")
                model.send(:"carrierwave_#{name}").present?
              else
                false
              end
            end

            private

            def upload_variant(model, name, variant, default: model.name.underscore)
              if model.send(name.to_sym).attached?
                model.send(name.to_sym).variant(variant.to_sym)
              elsif model.respond_to?(:"carrierwave_#{name}")
                model.send(:"carrierwave_#{name}").send(variant.to_sym).url
              else
                upload_default([default, variant].compact.map(&:to_s).join('_'))
              end
            end

            def upload_default(png_name = 'profil')
              ActionController::Base.helpers.asset_pack_path("media/images/#{png_name}.png")
            end

            def extract_image_dimensions(width_x_height)
              case width_x_height
              when /^\d+x\d+$/ then width_x_height.split('x')
              end
            end
          end
        RUBY
      end

      def gemfile_additions
        variants_dependencies = <<~TEXT
          gem 'active_storage_variant' # provides person.avatar.variant(:thumb) for Rails < 7
        TEXT

        validation_dependencies = <<~TEXT
          gem 'active_storage_validations' # validate filesize, dimensions and content-type
          # sadly, both mini_magick AND vips need to be here, because the gem
          # references those constants in the source, even if they are not used
          # See https://github.com/igorkasyanchuk/active_storage_validations
          gem 'mini_magick'
          gem 'vips'
        TEXT

        <<~TEXT
          The following gems are suggested to have in your Gemfile:

          gem 'nochmal' # only needed until the migration to the desired ActiveStorage-Backend is complete
          #{variants_dependencies if @variants_present}
          #{validation_dependencies}
        TEXT
      end
    end
  end
end
