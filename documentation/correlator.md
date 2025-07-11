# opennms\_correlator

Manages drools correlation engine configs in `$OPENNMS_HOME/etc/drools-engine.d`. Will restart the Correlator service automatically when needed. Creates sub-resources to accomplish its work and as such does not accumulate changes, potentially causing short periods of inconsistency during client execution when more than one resource operate on the same correlation configuration.

## Actions

* `:create` - Default. Adds or updates a correlation configuration in a directory named for the resource in `$OPENNMS_HOME/etc/drools-engine.d/`.
* `:create_if_missing` - Creates a correlation configuration if a directory named for the resource does not yet exist in `$OPENNMS_HOME/etc/drools-engine.d`.
* `:delete` - Removes the correlation configuration in the directory named for the resources in `$OPENNMS_HOME/etc/drools-engine.d` if it exists.

## Properties

| Name        | Name? | Type/Allowed Values | Identity? | Required? | Default | Notes |
| ----------- | ----- | ------------------- | --------- |---------- | ------- | ----- |
| `rule_name` | ✓ | String | ✓ | | | |
| `engine_source` | | String | | for :create | | Source of the `drools-engine.xml` file for this correlation configuration |
| `engine_source_type` | | `['template', 'remote_file', 'cookbook_file']` | | | `template` | Type of sub resource to create for `engine_source` |
| `engine_source_variables` | | Hash | | | | Passed to `template` resource when `engine_source_type` is `template` |
| `engine_source_properties` | | Hash | | | | Additional properties to set on the engine source sub resource |
| `drl_source` | | [String, Array] | | | | Source file or files of actual correlator rules and any supporting resources |
| `drl_source_type` | | `['template', 'remote_file', 'cookbook_file']` | | | `cookbook_file` | Type of sub resource to create for all `drl_source`s |
| `drl_source_variables` | | Hash | | | | Passed to the `template` sub resource of each sub resource derived from `drl_source` when `drl_source_type` is `template` |
| `drl_source_properties` | | Hash | | | | Additional properties to set on each `drl_source` sub resource |
| `notify` | | [true, false] | | | true | Whether or not to notify the correlator engine(s) in this config to restart |
| `notify_type` | | `['soft', 'hard']`] | | | soft | Restart engines via daemonReload event (soft) or by removal of the entire config, reloading the entire correlator service, adding it back, and finally reloading the entire correlator service again (hard). |

## Examples

See the following test recipes:

* [correlator.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/correlator.rb)
* [correlator\_edit.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/correlator_edit.rb)

## Additional Notes

If you need to source your DRL and/or support files from several source types, you can do so like this:

```ruby
opennms_correlation 'hybrid-sourced-drl' do
  engine_source 'hybrid-sourced-drools-engine.xml.erb'
  drl_source 'cookbook.drl'
  notify false
end

opennms_correlation 'add remote_file to hybrid-sourced-drl' do
  rule_name 'hybrid-sourced-drl'
  engine_source 'hybrid-sourced-drools-engine.xml.erb'
  drl_source 'template.drl'
  drl_source_type 'template'
  drl_source_variables foo: 'bar'
end
```

which would result in directory `$OPENNMS_HOME/etc/drools-engine.d/hybrid-sourced-drl` containing `drools-engine.xml` being derived from a template named `hybrid-sourced-drools-engine.xml.erb` and two DRL files: `cookbook.drl` from a cookbook_file sub resource and `template.drl` derived from a `template` sub resource.
