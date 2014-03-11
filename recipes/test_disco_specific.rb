# all options
opennms_disco_specific "10.10.1.1" do
  retry_count 13
  timeout 4000
end

# minimal, and probably more typical
opennms_disco_specific "10.10.1.2"
