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

    def migrate
      handle_each_model(:migrate)
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
        model.count.zero? || # no records
        types(model).all? do |type| # no uploads of any kind (type)
          active_storage.collection(model, type).count.zero?
        end
    end

    def reupload_type(model, type)
      collection = active_storage.collection(model, type)

      @notes << active_storage.notes(model, type)

      Output.type(type, collection.count, @mode) do
        collection.find_each do |item|
          perform(item, type)
        end
      end

      active_storage.cleanup(model, type)
    end

    def perform(attachment, type)
      case @mode
      when :reupload then do_reupload(attachment)
      when :migrate  then do_migrate(attachment, type)
      when :list     then do_list(attachment)
      when :count    then Output.print_progress_indicator
      end
    end

    # individual actions to be performed

    def do_reupload(attachment)
      blob = active_storage.blob(attachment)

      StringIO.open(@from_service.download(blob.key)) do |temp|
        @to_service.upload(blob.key, temp)
      end

      Output.print_progress_indicator
    end

    def do_migrate(record, type)
      model, pathname = active_storage.blob(record.send(type))

      if pathname.exist?
        StringIO.open(pathname.read) do |temp|
          model.send(active_storage.migration_method(type)).attach(io: temp, filename: pathname.basename)
        end

        Output.print_progress_indicator
      else
        @notes << "#{pathname} was not found, but was attachted to #{model}"
        Output.print_failure_indicator
      end
    end

    def do_list(attachment)
      filename = Array.wrap(active_storage.blob(attachment)).last

      Output.attachment(filename.try(:key) || filename)
    end
  end
end
