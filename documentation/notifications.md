# Custom Resources for Notifications

The following custom resources are available to manage notification configuration:

* `opennms_notification_command`: Manage commands in `$OPENNMS_HOME/etc/notificationCommands.xml`.
* `opennms_destination_path`: Manage a destination path element in `$OPENNMS_HOME/etc/destinationPaths.xml`. Each must have at a minimum a single target which can be defined with the `opennms_target` custom resource.
* `opennms_target`: Manage a target or escalate target in a destination path (defined either in the default config or with the above custom resource).
* `opennms_notification`: Manage notification elements in `$OPENNMS_HOME/etc/notifications.xml`.

## Actions for opennms\_notification\_command

* `:create` - Default. Adds a new command or updates an existing command to match the properties of the resource.
* `:create_if_missing` - Create a new command if it does not exist. Does not update an existing command with the same identity.
* `:update` - Update an existing command to match the properties of the resource. Raises an error if the command does not exist.
* `:delete` - Removes the command with matching identity if it exists.

## Properties for opennms\_notification\_command

| Name | Type | Notes |
| ---- | ---- | ----- |
| `command_name` | String | Name property. |
| `execute` | String | Required for new commands. |
| `comment` | String | |
| `contact_type` | String | |
| `binary` | [true, false] | Defaults to `true` for new commands |
| `arguments` | Array of Hash | Each Hash must contain a key named `streamed` with a value of `true` or `false` and can have keys `substitution` and `switch` which must be Strings. |
| `service_registry` | [true, false] | |

## Examples for opennms\_notification\_command

See test recipe [notification\_command.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/notification_command.rb).

## Actions for opennms\_destination\_path

* `:create` - Default. Adds a new path or updates an existing path to match the properties of the resource.
* `:create_if_missing` - Create a new path if it does not exist. Does not update an existing path with the same identity.
* `:update` - Update an existing path to match the properties of the resource. Raises an error if the path does not exist.
* `:delete` - Removes the path with matching identity if it exists.

## Properties for opennms\_destination\_path

| Name | Type | Notes |
| ---- | ---- | ----- |
| `path_name` | String | Name property. |
| `initial_delay` | String | Defaults to `0s` for new paths. |

## Examples for opennms\_destination\_path

See test recipe [destination\_path.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/destination_path.rb).

## Actions for opennms\_target

* `:create` - Default. Adds a new target or escalate target to the path identified by `destination_path_name` or updates an existing target or escalate target to match the properties of the resource.
* `:create_if_missing` - Add a new target or escalate target to the path identified by `destination_path_name` if it does not exist. Does not update an existing target or escalate target with the same identity.
* `:update` - Update an existing target or escalate target of the path identified by `destination_path_name` to match the properties of the resource. Raises an error if the target or escalate target does not exist.
* `:delete` - Removes the target or escalate target from the path identified by `destination_path_name` if it exists.

## Properties for opennms\_target

| Name | Type | Notes |
| ---- | ---- | ----- |
| `target_name` | String | Name property. The user or group to notify in OpenNMS. |
| `destination_path_name` | String | Required. Part of identity. |
| `commands` | Array of Strings | The names of the commands to execute in `$OPENNMS_HOME/etc/notificationCommands.xml`. Must not be empty for new instances. |
| `auto_notify` | String | Determines if off duty targets get notifications for automatically acknowledged notifications. Must be `off`, `on`, or `auto`. |
| `interval` | String | When `target_name` is a group, this controls the amount of time to wait between notifying members of the group. |
| `type` | String | Defaults to `target`. Can also be `escalate`. |
| `escalate_delay` | String | The length of the delay before processing escalate targets. |

## Examples for opennms\_target

See test recipe [destination\_path.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/destination_path.rb).

## Actions for opennms\_notification

## Properties for opennms\_notification

| Name | Type | Notes |
| ---- | ---- | ----- |

## Examples for opennms\_notification
