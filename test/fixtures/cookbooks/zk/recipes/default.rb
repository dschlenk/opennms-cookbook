zookeeper 'zookeeper' do
  version '3.8.4'
  use_java_cookbook false
end

zookeeper_config 'zookeeper'

zookeeper_service 'zookeeper'
