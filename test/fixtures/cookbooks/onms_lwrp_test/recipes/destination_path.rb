# all options
opennms_destination_path "foo" do
  initial_delay "5s"
end
# minimal
opennms_destination_path "bar"

# each destination path needs at least one target - these are minimal
opennms_target "Admin-foo" do
  target_name "Admin"
  destination_path_name "foo"
  commands ['javaEmail']
end

opennms_target "Admin-bar" do
  target_name "Admin"
  destination_path_name "bar"
  commands ['javaPagerEmail']
end
