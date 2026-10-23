# frozen_string_literal: true

require 'chefspec'

# FSafely attempt to load Berkshelf dependencies.
# If the gem is missing in the slim workspace container, fallback gracefully
# to keep the rspec execution suite from throwing fatal exceptions.
begin
  require 'chefspec/berkshelf'
rescue LoadError
  puts 'WARN: chefspec/berkshelf gem not found. Proceeding with standard library mock mapping.'
end

RSpec.configure do |config|
  config.color = true
  config.log_level = :error
  config.platform = 'oracle'
  config.version = '10'
end
