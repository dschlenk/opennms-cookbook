# opennms\_collection\_graph

Add a graph to an existing or new data collection graph definition properties file.

## Actions

* `:create` - Default. Adds a graph if it doesn't exist. Does not update.
* `:create_if_missing` - Currently an alias to `:create` but if `:update` ever gets implemented this action will preserve the current immutability of the `:create` action.

## Properties

All properties are required.

| Name | Type | Notes |
| ---- | ---- | ----- |
| `short_name` | String | Name property. This is the identity of the report in the properties file included in the `reports=` line. |
| `file` | String | The name of the file relative to `$OPENNMS_HOME/etc/snmp-graph.properties.d/` that the graph definition should be added to |
| `long_name` | String | The name used in the user interface to describe the graph. Provides the value of the `report.<short_name>.name=` line. |
| `columns` | Array of Strings | The list of DS names used in the `command`. Provides the value of the `report.<short_name>.columns` line. |
| `type` | String | The resource type of the columns in use by the graph. Provides the value of the `report.<short_name>.type` line. |
| `command` | String | The `rrdgraph` command to execute to generate the graph. Provies the value of the `report.<short_name>.command` line. |

## Examples

* [collection\_graph](../test/fixtures/cookbooks/opennms_resource_tests/recipes/collection_graph.rb) demonstrates use.

## Notes

It is rather unlikely that this resource will ever be refactored to include additional actions like `:udpate` and `:delete`, as Ruby support for Java properties files is pretty limited, which means that modifying them while preserving whitespace and comments has to be done line by line, which is a chore and is pretty slow.
It should also be noted that some options like `propertiesValues` and `suppress` are missing from this resource.
Furthermore, most users of OpenNMS have moved to using more dynamic external tools like Grafana to view performance data.
However, should you still rely on the resource graphs feature in OpenNMS and find this custom resource lacking, you are encouraged to create full graph files through other means and deploy them using the `opennms_collection_graph_file` resource.
