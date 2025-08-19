# opennms\_jms\_nb\_destination

Manages destinations in `$OPENNMS_HOME/etc/jms-northbounder-configuration.xml`. Will restart the OpenNMS service automatically when needed.

## Actions

* `:create` - Default. Adds or updates a JMS destination configuration in `$OPENNMS_HOME/etc/jms-northbounder-configuration.xml`.
* `:create_if_missing` - Adds a destination it does not exist. Does not update.
* `:delete` - Removes a destination if it exists.

## Properties

| Name        | Name? | Type/Allowed Values | Identity? | Required? | Default | Notes |
| ----------- | ----- | ------------------- | --------- |---------- | ------- | ----- |
| `destination` | ✓ | String | ✓ | | | |
| `first_occurrence_only` | | `[true, false]` | | | |  |
| `send_as_object_message` | | `['true, false']` | | |  | |
| `destination_type` | | `['QUEUE', 'TOPIC']` | | | | |
| `message_format` | | String | | | | |

## Examples

See the following test recipes:

* [jms_nb_destination.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jms_nb_destination.rb)
