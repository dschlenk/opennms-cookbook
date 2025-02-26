# opennms\_user

Manage users in `$OPENNMS_HOME/etc/users.xml`

## Actions

* `:create` - Default. Add a user. Uses the REST API. Will update non-password fields if user exists.
* `:create_if_missing` - Creates a user if one does not exist. Will not update if user already exists.
* `:update` - Update non-password fields of an existing user. Will raise an error if user does not exist.
* `:set_password` - Change the password for the specified user. Does not update other fields. Raises an error if the user does not exist.
* `:delete` - Delete an existing user if it exists.

## Properties

| Name | Type | Notes |
| ---- | ---- | ----- |
| `user_id` | String | Name property. |
| `full_name` | String | |
| `user_comments` | String | |
| `password` | String | Only utilized for new users and the `:set_password` action. |
| `password_salt` | [true, false] | Whether or not to salt the password. Only applicable for new users and the `:set_password` action. Default `true`. |
| `email` | String | |
| `duty_schedules` | Array of Strings | |
| `roles` | Array of Strings | Defaults to `['ROLE_USER']` when a new user is created. |

## Examples

* [user](../test/fixtures/cookbooks/opennms_resource_tests/recipes/user.rb)
* [user\_mod](../test/fixtures/cookbooks/opennms_resource_tests/recipes/user_mod.rb)
