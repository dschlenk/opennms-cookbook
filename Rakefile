# Encoding: utf-8
# frozen_string_literal: true
require 'kitchen'
require 'cookstyle'
require 'rubocop/rake_task'
require 'foodcritic'
require 'optparse'

# # Style tests. cookstyle (rubocop) and Foodcritic
namespace :style do
  desc 'Run Ruby style checks'
  RuboCop::RakeTask.new(:ruby)
  RuboCop::RakeTask.new(:rubycorrect) do |task|
    task.options = ['-a']
  end
  RuboCop::RakeTask.new(:rubyconfig) do |task|
    task.options = ['--auto-gen-config']
  end
  RuboCop::RakeTask.new(:rubycorrectconfig) do |task|
    task.options = ['--auto-gen-config', '-a']
  end
  desc 'Run Chef style checks'
  FoodCritic::Rake::LintTask.new(:chef) do |t|
    t.options = {
      fail_tags: ['any'],
      progress: true,
    }
  end
end

desc 'Run all style checks'
task style: ['style:chef', 'style:ruby']

namespace :integration do
  desc 'Run Test Kitchen with Vagrant'
  task :vagrant do
    options = {
      versions: %w(16 17 18 19),
    }
    opts = OptionParser.new
    opts.banner = 'Usage: rake integration:vagrant [options]'
    opts.on('-r', '--resume ARG', String) { |resume| options[:resume] = resume }
    opts.on('-v', '--versions ARG', Array) { |versions| options[:versions] = versions }
    opts.on('-h', '--help') { puts opts }
    args = opts.order!(ARGV) {}
    opts.parse!(args)
    Kitchen.logger = Kitchen.default_file_logger
    skipping = false
    skipping = true unless options[:resume].nil?
    resuming = false
    options[:versions].each do |ver|
      puts "Testing version #{ver}"
      old_instance = nil
      first_instance = nil
      Kitchen::Config.new.instances.each do |instance|
        next unless instance.name =~ /-#{ver}-centos-68/
        if skipping
          if instance.name == options[:resume]
            puts 'Resuming'
            resuming = true
            skipping = false
          else
            first_instance = instance if old_instance.nil?
            old_instance = instance
            next
          end
        end
        if old_instance.nil?
          first_instance = instance
        else
          if !resuming
            File.rename(".kitchen/#{old_instance.name}.yml", ".kitchen/#{instance.name}.yml")
          else
            resuming = false
          end
          instance.converge
        end
        instance.verify
        old_instance = instance
      end
      # to improve the odds it actually destroys properly, rename it back to original
      File.rename(".kitchen/#{old_instance.name}.yml", ".kitchen/#{first_instance.name}.yml")
      first_instance.destroy
    end
  end
end

task default: ['style']
task kitchen: ['integration:vagrant']
