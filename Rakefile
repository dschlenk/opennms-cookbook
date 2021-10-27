# Encoding: utf-8
# frozen_string_literal: true
require 'kitchen'
require 'cookstyle'
require 'rubocop/rake_task'
require 'optparse'

# # Style tests. cookstyle (rubocop) and Foodcritic
namespace :style do
  desc 'Run Chef and ruby style checks'
  RuboCop::RakeTask.new(:cookstyle)
  RuboCop::RakeTask.new(:correct) do |task|
    task.options = ['-a']
  end
  RuboCop::RakeTask.new(:config) do |task|
    task.options = ['--auto-gen-config']
  end
  RuboCop::RakeTask.new(:correctconfig) do |task|
    task.options = ['--auto-gen-config', '-a']
  end
end

desc 'Run all style checks'
task style: ['style:cookstyle']

namespace :integration do
  desc 'Run Test Kitchen with Vagrant'
  task :vagrant do
    options = {
      versions: %w(16 17 18 19 20 21 22 23 24 25 26 27 28),
      platforms: %w(centos-7),
    }
    opts = OptionParser.new
    opts.banner = 'Usage: rake integration:vagrant [options]'
    opts.on('-r', '--resume ARG', String) { |resume| options[:resume] = resume }
    opts.on('-v', '--versions ARG', Array) { |versions| options[:versions] = versions }
    opts.on('-p', '--platforms ARG', Array) { |platforms| options[:platforms] = platforms }
    opts.on('-s', '--suites ARG', Array) { |suites| options[:suites] = suites }
    opts.on('-h', '--help') { puts opts }
    args = opts.order!(ARGV) {}
    opts.parse!(args)
    Kitchen.logger = Kitchen.default_file_logger
    skipping = false
    skipping = true unless options[:resume].nil?
    puts "Skipping some suites? #{skipping}"
    resuming = false
    options[:platforms].each do |plat|
      if skipping
        next unless options[:resume].end_with?(plat)
      end
      options[:versions].each do |ver|
        puts "Testing version #{ver} on #{plat}"
        old_instance = nil
        first_instance = nil
        Kitchen::Config.new.instances.each do |instance|
          unless options[:suites].nil?
            md = /^(\w+((?:-\w+)?)*)-(\d+)-(\w+-\d+)$/.match(instance.name)
            next unless options[:suites].include?(md[1])
          end
          next unless instance.name =~ /-#{ver}-#{plat}/
          if skipping
            if instance.name == options[:resume]
              puts 'Resuming'
              resuming = true
              skipping = false
            else
              puts "Going to skip #{instance.name}"
              if old_instance.nil?
                puts "Setting #{instance.name} to first_instance."
                first_instance = instance
              end
              puts "Setting #{instance.name} to old_instance."
              old_instance = instance
              next
            end
          end
          if old_instance.nil?
            puts "Setting #{instance.name} to first_instance."
            first_instance = instance
          else
            if !resuming
              puts "Not resuming. Moving #{old_instance.name}.yml to #{instance.name}.yml."
              File.rename(".kitchen/#{old_instance.name}.yml", ".kitchen/#{instance.name}.yml")
            else
              puts 'Resuming, not moving yml file.'
              resuming = false
            end
            instance.converge
          end
          instance.verify
          old_instance = instance
        end
        # to improve the odds it actually destroys properly, rename it back to original
        if !old_instance.nil? && File.exist?(".kitchen/#{old_instance.name}.yml")
          puts "Done with #{ver} on #{plat}. Moving #{old_instance.name}.yml to #{first_instance.name}.yml before destroying."
          File.rename(".kitchen/#{old_instance.name}.yml", ".kitchen/#{first_instance.name}.yml")
          first_instance.destroy
        end
        # try to prevent OOM
        GC.start
      end
    end
    puts "Done testing #{options[:versions]} on #{options[:platforms]}!"
    exit 0
  end
end

task default: ['style']
task kitchen: ['integration:vagrant']
