# opennms\_avail\_view\_section

Manage sections in an existing view in `$OPENNMS_HOME/etc/viewsdisplay.xml`. They are displayed in the Availability box on the main page and the summary dashlet in the Ops Board.

## Actions

* `:create` - Default. Creates a new section if it does not exist or updates an existing section. The view with `:view_name` must exist, although the default of `WebConsoleView` is almost certainly what you want, and as such no custom resource exists to create a new view.
* `:create_if_missing` - Same as `:create` but will not update the categories of an existing section with the values provided by the `:categories` property of the resource.
* `:update` - Updates the `:categories` of an existing section but will not create a new section. Raises an error if attempted when the section does not exist.
* `:delete` - Removes section from view if it exists.

## Properties

| Name                 | Name? | Type          | Required | Identity | Default              |
| -------------------- | ----- | ------------- | -------- | -------- | -------------------- |
| `section` | x | String | x | | |
| `view_name` | | String | | x | 'WebConsoleView' |
| `categories` | | Array of Strings | | | |
| `before` | | String | | | |
| `after` | | String | | | |
| `position` | | 'top' or 'bottom' | | | 'top' |

## Examples

See [avail_view_section.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/avail_view_section.rb)
and [avail_view_section_mod.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/avail_view_section_mod.rb).
