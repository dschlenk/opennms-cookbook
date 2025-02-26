module Opennms::VaultHelper
  def opennms_scv_password
    scv_pw = nil
    begin
      scv_pw = chef_vault_item(node['opennms']['scv']['vault'], node['opennms']['scv']['item'])['password']
    rescue => e
      Chef::Log.warn("No custom password found in vault #{node['opennms']['scv']['vault']} item #{node['opennms']['scv']['item']} because of #{e.message}. Using default. This is not recommended.")
    end
    scv_pw
  end
end

::Chef::DSL::Recipe.send(:include, Opennms::VaultHelper)
::Chef::Resource::RubyBlock.send(:include, Opennms::VaultHelper)
