# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "java_properties"
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dwayne Kristjanson", "Colin Dean"]
  s.date = "2014-01-14"
  s.description = "A class that can read and write to Java properties files that behaves otherwise as a standard ruby Enumerable. The keys to this object can\n  be provided as Strings or Symbols, but internally they are Symbols."
  s.email = "flergl@flergl.net"
  s.executables = ["properties2yaml"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["bin/properties2yaml", "History.txt", "Manifest.txt", "README.txt"]
  s.homepage = "https://github.com/flergl/java-properties-for-ruby"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Simple gem for reading/writing Java properties files from Ruby."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
    else
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
  end
end
