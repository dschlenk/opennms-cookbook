kafka_broker 'default' do
  automatic_start true
  format_storage true
  cluster_id 'MkU3OEVBNTcwNTJENDM2Qk'
  broker_config(
    'process.roles' => 'broker,controller',
    'node.id' => 1,
    'controller.quorum.voters' => '1@localhost:9093',
    'listeners' => 'PLAINTEXT://:9092,CONTROLLER://:9093',
    'advertised.listeners' => 'PLAINTEXT://localhost:9092',
    'controller.listener.names' => 'CONTROLLER',
    'listener.security.protocol.map' => 'CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT',
    'inter.broker.listener.name' => 'PLAINTEXT',
    'log.dirs' => '/var/lib/kafka/data'
  )
end
