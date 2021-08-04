# frozen_string_literal: true
name 'openjdk_java11'
license 'Apache 2.0'
version '0.1.0'
chef_version '>= 12.7' if respond_to?(:chef_version)

depends 'java', '= 8.4.0'
depends 'seven_zip', '= 3.2.0'


