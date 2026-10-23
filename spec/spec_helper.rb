# frozen_string_literal: true

require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.color = true
  config.log_level = :error
  config.platform = 'oracle'
  config.version = '10'
end
