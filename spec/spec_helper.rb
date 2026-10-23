# frozen_string_literal: true

# Force the gem activation sequence to prioritize the legacy json version required by train-core
begin
  gem 'json', '< 3.0'
rescue Gem::LoadError
  # Fallback gracefully if the specific version pinning isn't locally cached yet
end

require 'json'

# Hotpatch the missing legacy method on the JSON engine module
unless JSON.respond_to?(:create_id=)
  module JSON
    def self.create_id=(*)
      nil
    end
  end
end

require 'chefspec'

# Only attempt to require and initialize the Berkshelf solver extension
# if a valid Berksfile physically exists at the cookbook root directory.
if File.exist?(File.expand_path('../Berksfile', __dir__))
  begin
    require 'chefspec/berkshelf'
  rescue LoadError
    puts 'WARN: chefspec/berkshelf gem not found. Proceeding with standard library mock mapping.'
  end
else
  puts 'INFO: No Berksfile found at root directory. Skipping Berkshelf resolution hooks.'
end

RSpec.configure do |config|
  config.color = true
  config.log_level = :error
  config.platform = 'oracle'
  config.version = '10'
end
