# frozen_string_literal: true

module Nochmal
  # Handles Reuploading of all attachments
  # from: (required) = ActiveStorage service name (e.g. local)
  # to: (optional) = ActiveStorage service name (e.g. aws) if left empty,
  #                  the currently configured service will be used.
  class Reupload
    attr_reader :active_storage, :from_service, :to_service

    def initialize(from:, to: nil, helper: nil)
      @active_storage = helper || ActiveStorageHelper.new
      @from_service = active_storage.from_storage_service(from.to_sym)
      @to_service = active_storage.to_storage_service(to&.to_sym)
    end

    def all
      handle_each_model(:reupload)
    end

    def list
      handle_each_model(:list)
    end

    private

    def handle_each_model(action)
      @mode = action

      Output.reupload(models) do
        models.each do |model|
          reupload_model(model)
        end
      end
    end

    def models
      active_storage.models_with_attachments
    end

    def types(model)
      active_storage.attachment_types_for(model)
    end

    def reupload_model(model)
      Output.model(model) do
        types(model).each do |type|
          reupload_type(model, type)
        end
      end
    end

    def reupload_type(model, type)
      collection = model.send("with_attached_#{type}")
      return false unless collection.table_exists?

      Output.type(type, collection.count, @mode) do
        collection.find_each do |item|
          perform(item.send(type))
        end
      end
    end

    def perform(attachment)
      blob = attachment.blob

      case @mode
      when :reupload
        StringIO.open(@from_service.download(blob.key)) do |temp|
          @to_service.upload(blob.key, temp)
        end

        Output.print_progress_indicator
      when :list
        Output.attachment(blob)
      end
    end
  end
end
