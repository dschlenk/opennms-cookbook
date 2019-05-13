# frozen_string_literal: true
default['java']['oracle']['accept_oracle_download_terms'] = true
default['java']['install_flavor']                         = 'oracle'
#default['java']['jdk']['8']['x86_64']['checksum']         = '53c29507e2405a7ffdbba627e6d64856089b094867479edc5ede4105c1da0d65'
#default['java']['jdk']['8']['x86_64']['url']              = 'http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz'
#default['java']['jdk']['8']['x86_64']['url']              = 'http://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz'
#default['java']['jdk_version']                            = 8
#default['java']['alternatives_priority'] = 18001210

default['java']['jdk']['8']['x86_64']['checksum']         = 'c0b7e45330c3f79750c89de6ee0d949ed4af946849592154874d22abc9c4668d'
default['java']['jdk']['8']['x86_64']['url']              = 'https://download.oracle.com/otn/java/jdk/8u211-b12/478a62b7d4e34b78b671c754eaaf38ab/jdk-8u211-linux-x64.tar.gz'
default['java']['jdk_version']                            = 8
default['java']['alternatives_priority'] = 18001210
