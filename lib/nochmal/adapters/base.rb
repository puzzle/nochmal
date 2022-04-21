# frozen_string_literal: true

module Nochmal
  module Adapters
    # base-class for storage-adapters
    #
    # currently, it provides a comon interface and some support for STI
    class Base
      def initialize(from: nil, to: nil)
        @from = from
        @to = to

        @types = {}
        @uploaders = {}

        validate
      end

      def validate
        true
      end

      def to_storage_service(service = @from); end

      def from_storage_service(service = @to); end

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

      # hooks

      # called before doing any action or even lookup
      def setup(_reupload_mode); end

      # called after outputing the final notes, before returning from the last method
      def teardown; end

      # called after all reuploading/listing/counting
      def general_notes; end

      # called before uploading a type
      def type_notes(_model, _type); end

      # called after each model (class)
      def model_completed(_model); end

      # called after handling each type (uploader/attachment-type)
      def type_completed(_model, _type); end

      # called after reuploading/listing/counting each record/attachment
      def item_completed(_item, _type, _status); end

      # actions

      def reupload(_attachment, _type)
        raise <<~ERROR
          Upload the attachment (of a certain type) NOCHMAL!!! in your adapter subclass

          Please return a Hash with a least a :status-key. If everything is ok, I suggest :ok as value.
        ERROR
      end

      def count
        { status: :ok }
      end

      def list(attachment)
        filename = blob(attachment)

        Output.attachment(filename.try(:key) || filename)

        { status: :noop }
      end

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
