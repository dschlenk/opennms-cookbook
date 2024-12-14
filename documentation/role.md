# opennms\_role

Manage roles in `$OPENNMS_HOME/etc/groups.xml`

## Actions

* `:create` - Default. Add a role. Will update if role exists.
* `:create_if_missing` - Creates a role if one does not exist. Will not update if role already exists.
* `:update` - Update an existing role. Will raise an error if role does not exist.
* `:delete` - Delete an existing role if it exists.

## Properties

| Name | Type | Notes |
| ---- | ---- | ----- |
| `role_name` | String | Name property. |
| `membership_group` | String | Required for new roles. Group must exist. |
| `supervisor` | String | Required for new roles. User must exist. |
| `description` | String | |

## Examples

* [role](../test/fixtures/cookbooks/opennms_resource_tests/recipes/role.rb)
