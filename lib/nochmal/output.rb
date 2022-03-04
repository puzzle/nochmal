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

      def type(type, count, action)
        puts type_header(type)
        print attachment_summary(count, action)
        yield
        puts type_footer
      end

      def attachment(filename)
        print attachment_detail(filename)
      end

      def notes(notes)
        notes = Array.wrap(notes)
        return unless notes.any?

        puts reupload_notes(notes)
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
        "    Going to #{action} #{count} #{"attachment".pluralize(count)}: "
      end

      def attachment_detail(filename)
        "\n      - #{filename}"
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

      def reupload_notes(notes)
        <<~NOTES

          ================================================================================
          #{notes.join("\n")}
          ================================================================================
        NOTES
      end

      def green(string)
        "\033[32m#{string}\033[0m"
      end
    end
  end
end
