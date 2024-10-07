# opennms\_eventconf

Manages an eventconf file in `$OPENNMS_HOME/etc/events/`, including its presence in `$OPENNMS_HOME/etc/eventconf.xml`. The latter is managed as a template using the initialized accumulator pattern, so to remove an `event-file` from `eventconf.xml` a resource with action `:delete` must be used.

## Actions

* `:create` - Default. Adds a file to `$OPENNMS_HOME/etc/events` in accordance with the properties of the resource along with a reference to the file in the main `eventconf.xml` file.
* `:delete` - Removes the reference to the file indicated by the resource properties from the main `eventconf.xml` file and deletes the file.

## Properties

| Name                 | Name? | Type          | Required | Allowed Values                               |
| -------------------- | ----- | ------------- | -------- | -------------------------------------------- |
| `event_file`         |   ✓   | String        |     ✓    |                                              |
| `source_type`        |       | String        |     x    | 'cookbook\_file', 'template', 'remote\_file' |
| `source`             |       | String        |          |                                              |
| `source_properties`  |       | Hash          |          |                                              |
| `position`           |       | Hash          |          | `override`, `top`, `bottom` (default)        |
| `variables`          |       | Hash          |          |                                              |

The `event_file` property controls what the name of the file containing events in `$OPENNMS_HOME/etc/events` will be.

The file containing events will be managed by a derived resource of type `source_type`.

The `source` property is passed to the derived resource of type `source_type`. The value of `event_file` is used when this property is nil (for `source_type` `template`, `.erb` is appended).

The property `source_properties`, if used, must be a Hash keyed with `Symbol`s that are valid properties of the selected `source_type`.
Use to set or override properties on the derived resource that manages the actual file that contains event definitions.

The `position` property dictates where in the main `eventconf.xml` file the `event-file` element is placed relative to files that ship with OpenNMS out of the box.
When `position` is the default, `bottom`, the file is included after all the other `event-file` elements except for `opennms.catch-all.events.xml`.
When `position` is `top`, the file is included after the internal OpenNMS event files, but before the vendor files included out of the box.
When `position` is `override`, the file is included before the internal OpenNMS event files.

The `variables` property is passed to the derived `template` resource when `source_type` is `template`.

## Examples

