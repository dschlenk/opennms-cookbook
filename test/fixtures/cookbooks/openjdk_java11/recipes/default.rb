# frozen_string_literal: true
include_recipe 'java'

apt_update

# make sure we have java installed
openjdk_pkg_install node['java']['jdk_version']
