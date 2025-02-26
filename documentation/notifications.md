# Custom Resources for Notifications

The following custom resources are available to manage notification configuration:

* `opennms_notification_command`: Manage commands in `$OPENNMS_HOME/etc/notificationCommands.xml`.
* `opennms_destination_path`: Manage a destination path element in `$OPENNMS_HOME/etc/destinationPaths.xml`. Each must have at a minimum a single target which can be defined with the `opennms_target` custom resource.
* `opennms_target`: Manage a target or escalate target in a destination path (defined either in the default config or with the above custom resource).
* `opennms_notification`: Manage notification elements in `$OPENNMS_HOME/etc/notifications.xml`.
* `opennms_notifd_autoack`: Manage `auto-acknowledge` elements in `$OPENNMS_HOME/etc/notifd-configuration.xml`.

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

* `:create` - Default. Adds a new notification or updates an existing notification to match the properties of the resource.
* `:create_if_missing` - Add a new notification if one with the same name does not exist. Does not update an existing notification with the same name.
* `:update` - Update an existing notification with the same name to match the properties of the resource. Raises an error if the notification does not exist.
* `:delete` - Removes the notification with the same name if it exists.

## Properties for opennms\_notification

| Name | Type | Notes |
| ---- | ---- | ----- |
| `notification_name` | String | Name property. |
| `status` | String | One of `on` or `off`. Required for new. |
| `writeable` | String | One of `yes` or `no`. |
| `uei` | String | Required for new. |
| `description` | String | |
| `rule` | String | Defaults to `IPADDR != '0.0.0.0'` when new. |
| `strict_rule` | [true, false] | |
| `destination_path` | String | Required for new |
| `text_message` | String | Required for new. |
| `subject` | String | |
| `numeric_message` | String | |
| `event_severity` | String | |
| `parameters` | Hash | Must be a Hash with string keys and values. |
| `vbname` | String | |
| `vbvalue` | String | |

## Examples for opennms\_notification

See test recipe [notification.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/notification.rb).

## Actions for opennms\_notifd\_autoack

* `:create` - Default. Adds a new `auto-acknowledge` element or updates an existing `auto-acknowledge` element to match the properties of the resource.
* `:create_if_missing` - Add a new `auto-acknowledge` element if one with the same identity does not exist. Does not update an existing `auto-acknowledge` element with the same identity.
* `:update` - Update an existing `auto-acknowledge` element with the same identity to match the properties of the resource. Raises an error if the `auto-acknowledge` element does not exist.
* `:delete` - Removes the `auto-acknowledge` element with the same identity if it exists.

## Properties for opennms\_notifd\_autoack

| Name | Type | Notes |
| ---- | ---- | ----- |
| `uei` | String | Name property. |
| `acknowledge` | String | Part of identity. Required. |
| `notify` | [true, false] | |
| `resolution_prefix` | String | Defaults to `'RESOLVED: '` for new. |
| `matches` | Array of Strings | Must contain at least one item on new and can't be empty on update. Defaults to `nodeid` when not specified. Other common items are `interfaceid` and `serviceid`. |

## Examples for opennms\_notifd\_autoack

See test recipe [notifd\_autoack.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/notifd_autoack.rb).
