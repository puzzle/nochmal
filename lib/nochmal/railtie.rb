module Nochmal
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/nochmal.rake"
    end
  end
end
