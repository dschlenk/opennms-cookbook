# opennms\_role\_schedule

Manage role schedules in `$OPENNMS_HOME/etc/groups.xml`

## Actions

* `:create` - Default. Add a schedule to a role.
* `:delete` - Delete an existing schedule from a role if it exists.

## Properties

All properties are part of identity and are required.

| Name | Type | Notes |
| ---- | ---- | ----- |
| `role_name` | String | The name of the role to add the schedule to. |
| `username` | String | The user the schedule is for. The user must exist and be in the role. |
| `type` | String | One of `specific`, `daily`, `weekly`, or `monthly`. |
| `times` | Array of Hashes | See notes below. |

Each Hash in `times` must have keys `begins` and `ends` in the format `dd-MMM-yyyy HH:mm:ss` or `HH:mm:ss`.
Can have key `day` matching `/(monday|tuesday|wednesday|thursday|friday|saturday|sunday|[1-3][0-9]|[1-9])/`.

## Examples

* [role](../test/fixtures/cookbooks/opennms_resource_tests/recipes/role.rb)
