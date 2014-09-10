# Encoding: utf-8
require 'kitchen'

namespace :integration do
  desc 'Run Test Kitchen with Vagrant'
  task :vagrant do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      instance.test(:always)
    end
  end

  desc 'Run Test Kitchen in the cloud'
  task :cloud do
    run_kitchen = true
    if ENV['TRAVIS'] == 'true' && ENV['TRAVIS_PULL_REQUEST'] != 'false'
      run_kitchen = false
    end

    if run_kitchen
      Kitchen.logger = Kitchen.default_file_logger
      @loader = Kitchen::Loader::YAML.new(
        project_config: './.kitchen.cloud.yml',
        local_config: './.kitchen.local.yml'
      )
      config = Kitchen::Config.new(loader: @loader)
      config.instances.each do |instance|
        instance.test(:passing)
      end
    end
  end
end

task local: ['integration:vagrant']

task default: ['integration:cloud']
