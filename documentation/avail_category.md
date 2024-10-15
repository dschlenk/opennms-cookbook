# opennms\_avail\_category

Manage categories in an existing category group in `$OPENNMS_HOME/etc/categories.xml`. They are displayed in the Availability box on the main page and the summary dashlet in the ops board.

## Actions

* `:create` - Default.
* `:update` - TODO: test this
* `:delete` - TODO: test this

## Properties

| Name                 | Name? | Type          | Required | Identity | Default              |
| -------------------- | ----- | ------------- | -------- | -------- | -------------------- |
| `label`              |   x   | String        |          |    x     |                      |
| `category_group`     |       | String        |    x     |    x     | `WebConsole`         |
| `comment`            |       | String        |          |          |                      |
| `normal`             |       | Float         |          |          | 99.99                |
| `warning`            |       | Float         |          |          | 97.0                 |
| `rule`               |       | String        |          |          |`IPADDR != '0.0.0.0'` |
| `services`           |       | Array         |          |          | `[]`                 |

## Examples

See [avail_category.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/avail_category.rb)
