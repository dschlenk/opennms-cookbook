# opennms\_collection\_graph\_file

Manage a graph definition file to `$OPENNMS_HOME/etc/snmp-graph.properties.d/`

## Actions

* `:create` - Default. Adds the graph file or updates it if it exists.
* `:create_if_missing` - Adds the graph file if it does not exist but does not update it.
* `:delete` - Deletes the graph file if it exists.

## Properties

| Name | Type | Notes |
| ---- | ---- | ----- |
| `file` | String | Name property. The name of the file to deploy to `$OPENNMS_HOME/etc/snmp-graph.properties.d/`. |
| `source` | String | When `cookbook_file` (the default), a `cookbook_file` resource is declared that assumes a file named `file` is present in the cookbook defining the resource. Otherwise, a `remote_file` resource is declared with the value of this property serving as the `source` of that resource. |

## Examples

* [collection\_graph\_file](../test/fixtures/cookbooks/opennms_resource_tests/recipes/collection_graph_file.rb) demonstrates use.
