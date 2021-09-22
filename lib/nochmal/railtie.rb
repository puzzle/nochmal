# frozen_string_literal: true

module Nochmal
  # This class handles including our rake task
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/nochmal.rake"
    end
  end
end
