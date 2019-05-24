# frozen_string_literal: true
default['java']['oracle']['accept_oracle_download_terms'] = true
default['java']['install_flavor']                         = 'oracle'
default['java']['jdk']['8']['x86_64']['checksum']         = 'cb700cc0ac3ddc728a567c350881ce7e25118eaf7ca97ca9705d4580c506e370'
# requires account because oracle so you'll need to download yourself, mirror and point this to your mirror
default['java']['jdk']['8']['x86_64']['url']              = 'https://download.oracle.com/otn/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz'
default['java']['jdk_version']                            = 8
default['java']['alternatives_priority'] = 18002010
