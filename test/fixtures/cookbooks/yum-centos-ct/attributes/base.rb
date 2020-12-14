default['yum']['base']['repositoryid'] = 'base'
default['yum']['base']['mirrorlist'] = "http://mirrorlist.centos.org/?release=#{node['platform_version'].to_i}&arch=$basearch&repo=os"
default['yum']['base']['description'] = "CentOS-#{node['platform_version'].to_i} - Base"
default['yum']['base']['enabled'] = true
default['yum']['base']['make_cache'] = true
default['yum']['base']['managed'] = true
default['yum']['base']['gpgcheck'] = true
default['yum']['base']['gpgkey'] = "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-#{node['platform_version'].to_i}"
