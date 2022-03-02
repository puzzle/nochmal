# frozen_string_literal: true

module Nochmal
  # Handles active storage specifics for the Reupload Task
  class ActiveStorageHelper
    def storage_service(service = nil)
      service ||= Rails.configuration.active_storage.service

      @storage_service ||= {}
      @storage_service[service] ||= ActiveStorage::Service.configure(service, configurations)
    end
    alias to_storage_service storage_service
    alias from_storage_service storage_service

    def models_with_attachments
      @models_with_attachments ||= begin
        Rails.application.eager_load!

        ActiveRecord::Base
          .descendants
          .reject(&:abstract_class?)
          .reject { |model| polymorphic?(model) }
          .reject { |model| storage_model?(model) }
          .select { |model| attachment?(model) }
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

    def polymorphic?(model)
      model.reflect_on_all_associations.map(&:options).any? do |options|
        options[:polymorphic]
      end
    end

    def storage_model?(model)
      attachment_models = [ActiveStorage::Blob, ActiveStorage::Attachment]

      attachment_models.any? do |am|
        model == am || model.is_a?(am)
      end
    end

    def attachment?(model)
      model.reflect_on_all_associations.any? do |assoc|
        assoc.klass == ActiveStorage::Attachment
      end
    end
  end
end
