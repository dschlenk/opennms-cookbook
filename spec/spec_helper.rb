# frozen_string_literal: true

require 'json'

unless JSON.respond_to?(:create_id=)
  module JSON
    def self.create_id=(*)
      nil
    end
  end
end

require 'chefspec'

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
