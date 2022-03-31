# frozen_string_literal: true

module Nochmal
  module Adapters
    # base-class for storage-adapters
    #
    # currently, it provides a comon interface and some support for STI
    class Base
      def initialize
        @types = {}
        @uploaders = {}
      end

      def to_storage_service(service = nil); end

      def from_storage_service(service = nil); end

      def models_with_attachments
        raise "Return an Array of model-classes in your adapter-subclass"
      end

      def attachment_types_for(_model)
        raise "Return an Array of attachment type (e.g. avatar, embeds) this in your adapter-subclass"
      end

      def collection(_model, _type)
        raise "Return a Scope or Enumerable of Records with attachments of a type in your adapter-subclass"
      end

      def empty_collection?(model, type)
        model.count.zero? || # no records
          collection(model, type).count.zero? # no uploads of a type
      end

      def blob(_attachment)
        raise "Return the data of the attachment in your adapter-subclass"
      end

      def notes(_model = nil, _type = nil); end

      def reupload(_attachment, _type)
        raise "Upload the attachment (of a certain type) NOCHMAL!!! in your adapter subclass"
      end

      def count
        Output.print_progress_indicator
      end

      def list(attachment)
        filename = Array.wrap(blob(attachment)).last

        Output.attachment(filename.try(:key) || filename)
      end

      # called after handling each type
      def cleanup(_model = nil, _type = nil); end

      private

      def maybe_sti_scope(model)
        if !model.descends_from_active_record? || model.descendants.any?
          model.where(type: model.sti_name)
        else
          model
        end
      end
    end
  end
end
