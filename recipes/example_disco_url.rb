# all options
opennms_disco_url "file:/opt/opennms/etc/include" do
  file_name "include"
  retry_count 13
  timeout 4000
end

# minimal
opennms_disco_url "http://example.com/include"
