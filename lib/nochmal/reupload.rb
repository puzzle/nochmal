# frozen_string_literal: true

# Handles Reuploading of all attachments
# from: (required) = ActiveStorage service name (e.g. local)
# to: (optional) = ActiveStorage service name (e.g. aws) if left empty,
#                  the currently configured service will be used.
class Reupload
  attr_reader :active_storage, :from_service, :to_service

  def initialize(from:, to: nil, helper: nil)
    @active_storage = helper || ActiveStorageHelper.new
    @from_service = active_storage.storage_service(from.to_sym)
    @to_service = active_storage.storage_service(to&.to_sym)
  end

  def all
    Output.reupload(models) do
      models.each do |model|
        reupload_model(model)
      end
    end
  end

  private

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

    Output.type(type, collection.count) do
      collection.find_each do |item|
        reupload(item.send(type))
      end
    end
  end

  def reupload(attachment)
    blob = attachment.blob

    Tempfile.create(binmode: true) do |temp|
      content = @from_service.download(blob.key)
      temp.write(content)

      @to_service.upload(blob.key, Pathname.new(temp))
    end

    Output.print_progress_indicator
  end
end
