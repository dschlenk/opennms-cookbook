# Ops Board Resources

The configuration of the Ops Board feature of OpenNMS can be managed using the `opennms_wallboard` and `opennms_dashlet` resources.

## opennms\_wallboard

Creates a `wallboard` element in the configuration file. These are called Operator Boards in the user interface. Each board can contain dashlets, which are managed with the `opennms_dashlet` resource documented below.

### Actions for opennms\_wallboard

* `:create` - Default. Creates a new `wallboard` element if it does not exist and will make it the default board if the `:set_default` property is set to true. Will update if already exists.
* `:create_if_missing` - Creates a new `wallboard` element if it does not exist and will make it the default board if the `:set_default` property is set to true. Will not update an existing wallboard with the same `title`.
* `:update` - Updates an existing `wallboard` if the `:set_default` property does not match the current value. Raises an error if the `wallboard` does not exist.
* `:delete` - Deletes an existing `wallboard` if it exists.

### Properties for opennms\_wallboard

| Name | Name? | Type | Required? |
| ---- | ----- | ---- | ---------------------- |
| `title` | x | String | x |
| `set_default` | | [true, false] | |

### Examples for opennms\_wallboard

Recipe [wallboard.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/wallboard.rb) demonstrates use.

## opennms\_dashlet`

Add a dashlet to a wallboard. The wallboard must exist.

### Actions for opennms\_dashlet

* `:create` - Default. Creates a new `dashlet` child element of the `wallboard` element with a title matching the `wallboard` property of this resource if it does not exist. Will update if already exists. Raises an error if the `wallboard` element does not exist.
* `:create_if_missing` - Creates a new `dashlet` child element of the `wallboard` element with a title matching the `wallboard` property of this resource if it does not exist. Will not update an existing dashlet with the same `title`.
* `:update` - Updates an existing `dashlet` child element of the `wallboard` element with a title matching the `wallboard` property of this resource. Raises an error if the `wallboard` does not exist.
* `:delete` - Deletes an existing `dashlet` if it exists.

### Properties for opennms\_dashlet

| Name | Name? | Type | Required? | Notes |
| ---- | ----- | ---- | --------- | ----- |
| `title` | x | String | x | |
| `wallboard` | | String | x | Part of identity |
| `boost_duration` | | Integer | | Defaults to `0` when new |
| `boost_priority` | | Integer | | Defaults to `0` when new |
| `duration` | | Integer | | Defaults to `15` when new |
| `priority` | | Integer | | Defaults to `5` when new |
| `dashlet_name` | | String | when new | Must be one of 'Surveillance', 'RTC', 'Summary', 'Alarm Details', 'Alarms', 'Charts', 'Image', 'KSC', 'Map', 'RRD', 'Topology', 'URL' |
| `parameters` | | Hash | | Must be a Hash with String keys and String values |

### Examples for opennms\_dashlet

Recipe [dashlet.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/dashlet.rb) demonstrates use.
