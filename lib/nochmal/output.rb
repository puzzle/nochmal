# frozen_string_literals: true

# Handles output for the Reupload Task
class Output
  class << self
    def reupload
      puts reupload_header
      yield
      puts reupload_footer
    end

    def model(model)
      puts model_header(model)
      yield
      puts model_footer
    end

    def type(type, count)
      puts type_header(type)
      print attachment_summary(count)
      yield
      puts type_footer
    end

    def print_progress_indicator
      print green(".")
    end

    private

    def reupload_header
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

    def attachment_summary(count)
      "    Reuploading #{count} #{"attachment".pluralize(count)}: "
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
