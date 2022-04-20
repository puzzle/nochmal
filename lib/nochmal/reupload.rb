# frozen_string_literal: true

module Nochmal
  # Handles Reuploading of all attachments
  # from: (required) = ActiveStorage service name (e.g. local)
  # to: (optional) = ActiveStorage service name (e.g. aws) if left empty,
  #                  the currently configured service will be used.
  class Reupload
    attr_reader :active_storage, :from_service, :to_service

    def initialize(from:, to: nil, helper: nil)
      @active_storage = helper || Adapters::ActiveStorage.new
      @from_service = active_storage.from_storage_service(from.to_sym)
      @to_service = active_storage.to_storage_service(to&.to_sym)
      @notes = []
    end

    def all
      handle_each_model(:reupload)
    end

    def list
      handle_each_model(:list)
    end

    def count
      handle_each_model(:count)
    end

    private

    def handle_each_model(action)
      @mode = action

      Output.reupload(models) do
        models.each do |model|
          # Output.model(model, skipping: true) &&
          next if skip_model?(model)

          reupload_model(model)
        end
      end
      @notes << active_storage.notes
      Output.notes(@notes.compact)
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

    def skip_model?(model)
      !model.table_exists? || # no table
        types(model).all? do |type| # no uploads of any kind (type)
          active_storage.empty_collection?(model, type)
        end
    end

    def reupload_type(model, type)
      collection = active_storage.collection(model, type)

      @notes << active_storage.notes(model, type)

      Output.type(type, collection.count, @mode) do
        collection.find_each do |item|
          result = perform(item, type)
          @notes << result if result.present?
        end
      end

      active_storage.cleanup(model, type)
    end

    def perform(attachment, type)
      case @mode
      when :reupload then active_storage.reupload(attachment, type)
      when :list     then active_storage.list(attachment)
      when :count    then active_storage.count
      end
    end
  end
end
