opennms_wallboard "fooboard" do
  set_default true
end

# this being later in the run list should make fooboard non-default
opennms_wallboard "schlazorboard" do
  set_default true
end

# this won't do a thing to the default
opennms_wallboard "barboard"
