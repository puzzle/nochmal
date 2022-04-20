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
        model, pathname = blob(record.send(type))

        if pathname.exist?
          StringIO.open(pathname.read) do |temp|
            model.send(not_prefixed(type)).attach(io: temp, filename: pathname.basename)
          end

          Output.print_progress_indicator
        else
          Output.print_failure_indicator
          "#{pathname} was not found, but was attachted to #{model}"
        end
      end
    end
  end
end
