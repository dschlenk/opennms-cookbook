opennms_scriptd_engine 'groovy' do
  class_name 'org.gradle.tasks.build.CompileTaskHandler'
  extensions 'groovy'
end

opennms_scriptd_engine 'java' do
  class_name 'com.game.core.physics.CollisionManagerr'
  extensions 'java'
end
