# frozen_string_literal: true
ruby_block 'Perform OpenNMS Upgrade If Necessary' do
  block do
    Opennms::Upgrade.upgrade_opennms(node)
  end
end
