require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run 'bundle install' to install missing gems."
  exit e.status_code
end
require 'rake'
require 'rake/testtask'
require 'jeweler'
require './lib/java_properties/version.rb'

Jeweler::Tasks.new do |gem|
  gem.version = JavaProperties::VERSION::STRING
  gem.name = "java_properties"
  gem.homepage = "https://github.com/flergl/java-properties-for-ruby"
  gem.license = "MIT"
  gem.summary = "Simple gem for reading/writing Java properties files from Ruby."
  gem.description = "A class that can read and write to Java properties files that behaves otherwise as a standard ruby Enumerable. The keys to this object can
  be provided as Strings or Symbols, but internally they are Symbols."
  gem.email = "flergl@flergl.net"
  gem.authors = ["Dwayne Kristjanson","Colin Dean"]
  gem.executables = ["properties2yaml"]
  gem.rdoc_options = ["--main", "README.txt"]
  gem.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
end

Jeweler::RubygemsDotOrgTasks.new

Rake::TestTask.new(:test) do |t|
  t.libs.push 'lib'
  t.test_files = FileList['test/test_java_properties.rb','test/test_utf8.rb']
  t.verbose = true
end

task :default => :test
