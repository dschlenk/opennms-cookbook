name 'opennms-elasticsearch'
maintainer 'ConvergeOne'
maintainer_email 'dschlenk@convergeone.com'
license 'Apache-2.0'
description 'Installs/Configures opennms-elasticsearch'
long_description 'Installs/Configures opennms-elasticsearch'
version '0.1.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

depends 'elasticsearch'
