# frozen_string_literal: true
name 'openjdk_java11'
license 'Apache 2.0'
version '0.1.0'

depends 'java'
chef_version      '>= 15.3'

source_url  'https://github.com/sous-chefs/java'
issues_url  'https://github.com/sous-chefs/java/issues'
chef_version '>= 12.7' if respond_to?(:chef_version)

