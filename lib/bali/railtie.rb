require "bali"
require "rails"

module Bali
  class Railtie < ::Rails::Railtie
    railtie_name :bali

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end
