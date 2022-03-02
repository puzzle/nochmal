# frozen_string_literal: true

module Nochmal
  # Handles output for the Reupload Task
  class Output
    class << self
      def reupload(models)
        puts reupload_header(models)
        yield
        puts reupload_footer
      end

      def model(model)
        puts model_header(model)
        yield
        puts model_footer
      end

      def type(type, count, mode)
        puts type_header(type)
        action = "#{ActiveSupport::Inflector.titleize(mode)}ing" # Listing, Processing, Reuploading
        print attachment_summary(count, action)
        yield
        puts type_footer
      end

      def attachment(blob)
        puts attachment_detail(blob)
      end

      def print_progress_indicator
        print green(".")
      end

      private

      def reupload_header(models)
        model_text = "model".pluralize(models.count)
        model_names = models.map { |model| green(model) }.join(", ")

        <<~HEADER


          ================================================================================
          I have found #{models.count} #{model_text} to process: #{model_names}

        HEADER
      end

      def model_header(model)
        "Model #{green(model)}"
      end

      def type_header(type)
        "  Type #{green(type)}"
      end

      def attachment_summary(count, action)
        "    #{action} #{count} #{"attachment".pluralize(count)}: "
      end

      def attachment_detail(blob)
        "      - #{blob.key}"
      end

      def type_footer
        "\n  Done!"
      end

      def model_footer
        "Done!"
      end

      def reupload_footer
        "\nAll attachments have been processed!"
      end

      def green(string)
        "\033[32m#{string}\033[0m"
      end
    end
  end
end
