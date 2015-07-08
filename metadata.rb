name             'opennms'
maintainer       'David Schlenk'
maintainer_email 'david.schlenk@spanlink.com'
license          'Apache 2.0'
description      'Installs and Configures opennms 15 and provides many useful LWRPs.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports         'centos', ">= 6.0"
supports         'rhel', ">= 6.0"
version          '3.0.0'
depends          'yum'
depends          'hostsfile'
depends          'java'
depends          'build-essential'
