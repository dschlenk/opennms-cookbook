# Syslogd Configuration

The following node attributes can be used to override values present in the file by default:

```
node['opennms']['syslogd']['port']
node['opennms']['syslogd']['new_suspect']
node['opennms']['syslogd']['parser']
node['opennms']['syslogd']['forwarding_regexp']
node['opennms']['syslogd']['matching_group_host']
node['opennms']['syslogd']['matching_group_message']
node['opennms']['syslogd']['discard_uei']
node['opennms']['syslogd']['timezone']
```

# opennms\_syslog\_file resource

Manages a syslog config file in `$OPENNMS_HOME/etc/syslog/` including its presence in `$OPENNMS_HOME/etc/syslog-configuration.xml`. The latter is managed as a template using the initialized accumulator pattern, so to remove an `include-file` from the default config, a resource with action `:delete` must be used.

## Actions

* `:create` - Default. Adds a file to `$OPENNMS_HOME/etc/syslog/` in accordance with the properties of the resource along with a reference to the file in the main `syslogd-configuration.xml` file.
* `:delete` - Removes the named file and the reference to it in the config file.

## Properties

| Name                 | Name? | Type          | Allowed Values                               |
| -------------------- | ----- | ------------- | -------------------------------------------- |
| `filename`           |   ✓   | String        |                                              |
| `position`           |       | Hash          | `top`, `bottom` (default)        |

The `filename` property should match the name of the file in the containing cookbook and will be what the name of the file in `$OPENNMS_HOME/etc/syslog` will be.

The file containing syslog config will be managed by a derived resource of type `cookbook_file`.

The `position` property dictates where in the main file the `include-file` element is placed relative to files currently present.
When `position` is the default, `bottom`, the file is included after all the other `include-file` elements.
When `position` is `top`, the file is included before all other `include-file` elements currently in the file.

## Examples

See [syslog_file.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/syslog_file.rb)
