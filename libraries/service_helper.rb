module Opennms::Service
  def opennms_running?
    shell_out('systemctl is-active --quiet opennms').exitstatus.zero?
  end
end

::Chef::DSL::Universal.send(:include, Opennms::Service)
