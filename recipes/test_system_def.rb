opennms_system_def "Cisco Routers" do
  groups ["mib2-tcp", "mib2-powerethernet"]
  action :add
end
opennms_system_def "Cisco ASA5510sy" do
  groups ["cisco-pix", "cisco-memory"]
  action :remove
end
