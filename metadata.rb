# frozen_string_literal: true
name             'opennms'
maintainer       'David Schlenk'
maintainer_email 'david.schlenk@spanlink.com'
license          'Apache-2.0'
description      'Installs and Configures opennms and provides many useful LWRPs.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
issues_url       'https://github.com/dschlenk/opennms-cookbook/issues'
source_url       'https://github.com/dschlenk/opennms-cookbook'
supports         'centos', '>= 6.0'
supports         'redhat', '>= 6.0'
version          '22.2.3'
depends          'hostsfile'
depends          'build-essential'
depends          'postgresql'
depends          'openssl'
chef_version '>= 12.5' if respond_to?(:chef_version)
