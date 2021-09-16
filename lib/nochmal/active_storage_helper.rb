# frozen_string_literals: true

# Handles active storage specifics for the Reupload Task
class ActiveStorageHelper
  def storage_service(service)
    service ||= Rails.configuration.active_storage.service

    @storage_service ||= {}
    @storage_service[service] ||= ActiveStorage::Service.configure(service, configurations)
  end

  def models_with_attachments
    @models_with_attachments ||= begin
      Rails.application.eager_load!

      ActiveRecord::Base
        .descendants
        .select { |model| attachment?(model) }
        .reject { |model| blob_model?(model) }
    end
  end

  def attachment_types_for(model)
    @types ||= {}
    @types[model] ||=
      model
      .methods
      .map { |method| method.to_s.match(/^with_attached_(\w+)$/)&.captures&.first }
      .compact
  end

  private

  def configurations
    @configurations ||= begin
      file = Rails.root.join("config/storage.yml")
      erb = ERB.new(file.read).result
      yaml = YAML.safe_load(erb)
      ActiveStorage::Service::Configurator.new(yaml).configurations
    end
  end

  def blob_model?(model)
    model.is_a? ActiveStorage::Blob
  end

  def attachment?(model)
    model.reflect_on_all_associations.any? do |assoc|
      assoc.klass == ActiveStorage::Attachment
    end
  end
end
