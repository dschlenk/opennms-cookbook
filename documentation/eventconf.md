# opennms\_eventconf

Manages an eventconf file in `$OPENNMS_HOME/etc/events/`, including its presence in `$OPENNMS_HOME/etc/eventconf.xml`. The latter is managed as a template using the initialized accumulator pattern, so to remove an `event-file` from `eventconf.xml` a resource with action `:delete` must be used.

## Actions

* `:create` - Default. Adds a new eventconf source in accordance with the properties of the resource along with the event definitions contained in the source.
* `:create_if_missing` - Same as `:create` but only operates if the source does not exist.
* `:delete` - Removes the eventconf source.

## Properties

| Name                 | Name? | Type          | Required | Allowed Values                               | Deprecated Alias |
| -------------------- | ----- | ------------- | -------- | -------------------------------------------- | ---------------- |
| `source_name`        |   ✓   | String        |     ✓    |                                              | `event_file`     |
| `source_type`        |       | String        |     x    | 'cookbook\_file', 'template', 'remote\_file' | |
| `source`             |       | String        |          |                                              | |
| `source_properties`  |       | Hash          |          |                                              | |
| `position`           |       | String        |          | `override`, `top`, `bottom` (default)        | |
| `variables`          |       | Hash          |          |                                              | |

The `source_name` property controls what the name of the eventconf source will be.

The file containing events will be managed by a derived resource of type `source_type` to facilitate uploading the events contained within to the source.

The `source` property is passed to the derived resource of type `source_type`. The value of `source_name` is used when this property is nil (for `source_type` `template`, `.erb` is appended).

The property `source_properties`, if used, must be a Hash keyed with `Symbol`s that are valid properties of the selected `source_type`.
Use to set or override properties on the derived resource that manages the actual file that contains event definitions.

The `position` property dictates file order of the eventconf source.
When `position` is the default, `bottom`, the source has the lowest priority except for `opennms.catch-all.events.xml`.
When `position` is `top` or `override`, the source has the highest priority.

The `variables` property is passed to the derived `template` resource when `source_type` is `template`.

## Examples

See [eventconf.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/eventconf.rb)
