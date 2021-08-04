# frozen_string_literal: true

apt_update
include_recipe 'java::default'
# make sure we have java installed
openjdk_pkg_install node['java']['jdk_version']
