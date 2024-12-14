# opennms\_group

Manage a group in `$OPENNMS_HOME/etc/groups.xml`.

## Actions

* `:create` - Default. Adds a group or updates an existing group.
* `:create_if_missing` - Adds a group if it does not exist. Does not update if group exists.
* `:update` - Update an existing group. Raises an error if the group does not exist.
* `:delete` - Delete group if it exists.

## Properties

| Name | Type | Notes |
| ---- | ---- | ----- |
| `group_name` | String | Name property. |
| `comments` | String | |
| `users` | Array of Strings | A list of members. Users must exist. |
| `duty_schedules` | Array of Strings | |

## Examples

* [group](../test/fixtures/cookbooks/opennms_resource_tests/recipes/group.rb)
