# frozen_string_literal: true

module Nochmal
  module Adapters
    # Handles active storage specifics for the Reupload Task
    class ActiveStorage < Base
      def validate
        services_differ = (@to != @from)
        message = "It does not make sense to migrate from one service to the same one. from and to should differ."

        raise message unless services_differ
      end

      def to_storage_service(service = @to)
        storage_service(service)
      end

      def from_storage_service(service = @from)
        storage_service(service)
      end

      def models_with_attachments
        @models_with_attachments ||= begin
          Rails.application.eager_load!

          ::ActiveStorage::Attachment
            .select(:record_type).distinct.pluck(:record_type)
            .compact.map(&:constantize)
            .map do |model|
              ([model] + model.descendants).find { |child_or_self| attachment?(child_or_self) }
            end
        end
      end

      def attachment_types_for(model)
        @types[model] ||=
          model
          .methods
          .map { |method| method.to_s.match(/^with_attached_(\w+)$/)&.captures&.first }
          .compact
      end

      def collection(model, type)
        ::ActiveStorage::Attachment
          .where(name: type)
          .where(record_type: model.base_class.sti_name)
      end

      def blob(attachment)
        attachment.blob
      end

      # actions

      def reupload(attachment, _type)
        blob = blob(attachment)

        StringIO.open(from_storage_service.download(blob.key)) do |temp|
          to_storage_service.upload(blob.key, temp)
        end

        { status: :ok }
      end

      private

      def storage_service(service = nil)
        service ||= Rails.configuration.active_storage.service

        @storage_service ||= {}
        @storage_service[service] ||= ::ActiveStorage::Service.configure(service, configurations)
      end

      def configurations
        @configurations ||= begin
          file = Rails.root.join("config/storage.yml")
          erb = ERB.new(file.read).result
          yaml = YAML.safe_load(erb)
          ::ActiveStorage::Service::Configurator.new(yaml).configurations
        end
      end

      def attachment?(model)
        model.reflect_on_all_associations.any? do |assoc|
          next if assoc.options[:polymorphic] # the class cannot be checked for polymorphic associactions

          assoc.klass == ::ActiveStorage::Attachment
        end
      end
    end
  end
end
