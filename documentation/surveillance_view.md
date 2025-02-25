# opennms\_surveillance\_view

Manage the views of data on the main page when use of the surveillance view is enabled

## Actions

* `:create` - Default. Creates a new view or updates it if it already exists.
* `:create_if_missing` - Creates a new view if one with the same name does not already exist.
* `:update` - Update an existing view. Will not create a new view.
* `:delete` - Remove an existing view if it exists. If the view being removed is the current default, there will no longer be an explicit default view specified.

## Properties

| Name | Name? | Type | Validation |
| ---- | ----- | ---- | ---------- |
| `name` | x | String | |
| `rows` |   | Hash | should be a hash with at least one member having String keys that have Array of String values |
| `columns` |  | Hash | should be a hash with at least one member having String keys that have Array of String values |
| `default_view` |  | [true, false] | |
| `refresh_seconds` |  | [Integer, String] | |

## Examples

* [surveillance\_view.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/surveillance_view.rb)
* [surveillance\_view\_mod.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/surveillance_view_mod.rb)
