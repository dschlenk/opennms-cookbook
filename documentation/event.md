# opennms\_event

Manages an event in a file in `$OPENNMS_HOME/etc/events/`, including its presence in `$OPENNMS_HOME/etc/eventconf.xml`. Utilizes the initialized accumulator pattern, so adding new events to an existing file does not require that all events in the file are managed with this resource. It does, however, require that there is only one event in the file with the same identity, which is defined as the composite of the `uei`, `mask`, and `file` properties. Properties using `Array` or `Hash` types must adhere to format specified. Validations are employed to enforce required elements within.

## Actions

* `:create` - Default. Adds or updates an `event` element to `file` in `$OPENNMS_HOME/etc/events` in accordance with the properties of the resource, and adds a reference to the file to `$OPENNMS_HOME/etc/eventconf.xml` if one does not yet exist.
* `:update` - Modify an existing event. Identity properties are required. Properties that are `nil` are not updated. Some properties support the use of `false` to indicate that they should be removed if present in the existing event definition.
* `:delete` - Removes the event matching `uei` and `mask` from the `file`. Also removes the file if no events remain in it, along with the reference to it in the main `eventconf.xml` file.

## Properties

| Name                 | Name? | Type          | Identity? | Required | Allowed Values                                                                     | Notes                          |
| -------------------- | ----- | ------------- | --------- |--------- | ---------------------------------------------------------------------------------- | ------------------------------ |
| `uei`                |       | String        |     ✓     |          |                                                                                    | `name` is used if `nil`        |
| `file`               |       | String        |     ✓     |    ✓     |                                                                                    |                                |
| `mask`               |       | Array, String |     ✓     |          | `*` or `!` when String                                                             | default `*`                    |
| `priority`           |       | Integer       |           |          | non-negative Integer                                                               |                                |
| `event_label`        |       | String        |           |          |                                                                                    | must be present for new events |
| `descr`              |       | String        |           |          |                                                                                    | must be present for new events |
| `logmsg`             |       | String        |           |          |                                                                                    | must be present for new events |
| `logmsg_dest`        |       | String        |           |          | `logndisplay`, `displayonly`, `logonly`, `supress`, `donotpersist`, `discardtraps` | must be present for new events |
| `logmsg_notify`      |       | true, false   |           |          |                                                                                    |                                |
| `collection_group`   |       | Array, false  |           |          |                                                                                    |                                |
| `severity`           |       | String        |           |          |                                                                                    | must be present for new events |
| `operinstruct`       |       | String        |           |          |                                                                                    |                                |
| `autoaction`         |       | Array, false  |           |          |                                                                                    |                                |
| `varbindsdecode`     |       | Array, false  |           |          |                                                                                    |                                |
| `parameters`         |       | Array, false  |           |          |                                                                                    |                                |
| `operaction`         |       | Array, false  |           |          |                                                                                    |                                |
| `autoacknowledge`    |       | Hash, false   |           |          |                                                                                    |                                |
| `loggroup`           |       | String        |           |          |                                                                                    |                                |
| `tticket`            |       | Hash, false   |           |          |                                                                                    |                                |
| `forward`            |       | Array, false  |           |          |                                                                                    |                                |
| `script`             |       | Array, false  |           |          |                                                                                    |                                |
| `mouseovertext`      |       | String        |           |          |                                                                                    |                                |
| `alarm_data`         |       | Hash, false   |           |          |                                                                                    |                                |
| `filters`            |       | Array, false  |           |          |                                                                                    |                                |
| `position`           |       | String        |           |          | `top` or `bottom` default `bottom`                                                 | relevant only for `:create`    |
| `eventconf_position` |       | String        |           |          | `override`, `top`, or `bottom`                                                     | relevant only for `:create`    |

The `uei` property is populated with the `name` property if not defined. It represents the text value of the `uei` element in the `event` element in `file`.

The `file` property is the name of the file relative to `$OPENNMS_HOME/etc` that the managed event resides in.

The `mask` property can be the string `*` or `!` or an array of hashes where each hash has either keys `mename` and `mevalue` or `vbnumber` and `vbvalue`. The string value `*` means "any" mask. If any event exists with matching `uei` in `file` of a resource with action `:create` and mask `*`, and `:update` of that event will occur. If more than one matching event exists in `file`, the first event in the file is updated. Use `!` with the `:update` action to remove the mask from the first instance of an event in `file` with the matching `uei`.
To define a mask in `:create` or `:update`, use an array of hashes that contain key `mename` or `vbnumber` with a string value and `mevalue` or `vbvalue` with an array of string values. 'mename' indicates 'maskelement' while 'vbnumber' indicates 'varbind'.

The `priority` property corresponds to the child element of the same name and must be a non-negative integer.

Property `event_label` is required when creating a new event. It is assumed to be a single line of text.

Property `descr` is required when creating a new event. It can be a multi-line string.

Property `logmsg` is required when creating a new event. It can be a multi-line string.

Property `logmsg_dest` is required when creating a new event. `logndisplay` is the most common value used.

Property `logmsg_notify` can be `true` or `false`. `true` is implicit when not present.

Property `collection_group` can be `false` or an array of hashes that create a configuration for persisting measurements via SNMP trap. `false` removes an existing configuration from the event matching this resource's identity if it exists. When the value is an array, each item in the array must be a hash and it must contain key `rrd` with hash value consisting of key `rra` that is an array of strings that match pattern `RRA:(AVERAGE|MIN|MAX|LAST):.*`, `step` that is an integer; `name` with a string value; and `collections` which is an array of at least one hash containing key `name` with a string value. An example array that includes one of every possible option follows:

```ruby
[
  {
    'name' => 'nodeGroup',
    'resource_type' => 'nodeSnmp',
    'instance' => 'instanceParmName',
    'collections' => [{ 'name' => 'TIME', 'type' => 'counter', 'param_values' => { 'primary' => 1, 'secondary' => 2 } }],
    'rrd' => {
               'rra' => [ 'RRA:AVERAGE:0.5:1:8928' ],
               'step' => 60, 'heartbeat' => 120
             }
  }
]
```

Property `severity` is a string and is required when creating a new event. Typical values include `Critical`, `Major`, `Minor`, `Warning`, `Normal`, or `Indeterminate` although no restrictions exist in the underlying XML schema.

Property `operinstruct` is a string that is displayed to the user when instances of the event occur.

Property `autoaction` is a list of actions to be executed when an instance of the event occurs. The array must contain hashes each of which contain a key named `action` and optionally a key named `state` with value of either `on` or `off`. The value of `action` is what is executed. Use `false` to remove all `autoaction` configs from an event with matching identity.

Property `varbindsdecode` allows substitution of integer values in parameter values of event instances with text defined in a `TEXTUAL-CONVENTION`. Use an array of hashes each with a `parmid` key and a `decode` key with an array value of at least one hash that contains keys `varbindvalue` and `varbinddecodedstring`, or `false` to removing existing from an event with matching identity.

Property `parameters` allows inclusion of additional statically defined parameter key/value pairs with instances of the event. To define, use an array of hashes each with a `name` key and a `value` key and optionally an `expand` key with a boolean value, or `false` to remove all from an event with matching identity.

Property `operaction` creates config for a feature that does not currently exist but used to allow users to click a button to execute a command. Use `false` to remove from an existing event or be prepared for disappointment and define an array of hashes each containing key `action`, key `menutext` and optionally key `state` with value of either `on` or `off` to add to an event.

When `autoacknowledge` contains a hash with key `info` and either no `state` or `state` with value `on`, the event will be acknowledged when persisted. Use `false` or set `state` to `off` to disable this functionality on an existing event.

Property `loggroup` adds an element of the same name to an event. It is queryable, but is not displayed anywhere.

Property `tticket` is similar to `autoaction` but is a scalar instead of a list. Ostensibly meant to be used to execute a command that creates a trouble ticket in an external system. Use false to remove or a hash with key `info` key and optionally `state` key with value `on` or `off`. The value of `info` is what will be executed.

Property `forward` configures OpenNMS to send a copy of event instances to external systems. Use `false` to remove or an array of hashes each of which contains keys `info` (string) and may contain keys `state` and `mechanism`. I think value of `info` should be the IP address or hostname of the target system. It is unlikely that you would want to do this.

Property `script` once allowed one to run 0..\* scripts when an instance of an event occurs. No longer functional as it was replaced with `autoaction` although the element is still in the schema. Use `false` to remove from an existing event or add it with an array of hashes that each contain a `name` and `language` key.

Property `mouseovertext` is a string stored with the event and was once displayed on mouse over but is no longer.

Property `alarm_data` defines the alarm configuration for instances of this event. Use `false` to remove existing config, or define with a hash that contains keys `reduction_key` (string), `alarm_type` (integer). May contain keys `update_fields` (array of hashes that include mandatory key `field_name` (string) and optional keys `update_on_reduction` (boolean), `value_expression` (string)), `clear_key` (string), `auto_clean` (boolean), `x733_alarm_type` (string), `x733_probable_cause` (int). A full example follows:

```ruby
{
  'update_fields' => [{'field_name' => 'severity', 'update_on_reduction' => true}],
  'managed_object_type' => 'snmp-interface-link',
  'reduction_key' => '%uei%:%dpname%:%nodeid%:%parm[#1]%',
  'alarm_type' => 2,
  'clear_key' => 'uei.opennms.org/raiseEvent:%dpname%:%nodeid%:%parm[#1]%,
  'auto_clean' => false,
  'x733_alarm_type' => 'CommunicationsAlarm',
  'x733_probable_cause' => 12
}
```

Property `filters` controls the remnant of feature that allowed you to match a regular expression to the named event parameter's value and replace it with a different value. It has been disabled since 2013. Use `false` to remove existing config from an existing event definition, or add/update with an array of hashes each of which contains keys `eventparm` (string), `pattern` (string), `replacement` (string). Enabling it requires editing the eventDaemon application context, which not only requires a restart, but also editing a jar file, and it was disabled for performance reasons.

The `position` property dictates where in the event file a new event will be placed. It is ignored when an existing event is updated.

The `eventconf_position` property dictates where in the main `eventconf.xml` file the `event-file` element is placed relative to files that ship with OpenNMS out of the box and is only relevant for action `:create` when the `file` is not already present in `eventconf.xml`.
When `eventconf_position` is the default, `bottom`, the file is included after all the other `event-file` elements except for `opennms.catch-all.events.xml`.
When `eventconf_position` is `top`, the file is included after the internal OpenNMS event files, but before the vendor files included out of the box.
When `eventconf_position` is `override`, the file is included before the internal OpenNMS event files.

## Examples

See the following test recipes:

* [event.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event.rb)
* [event\_add\_parameters.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_add_parameters.rb)
* [event\_change\_parameters.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_change_parameters.rb)
* [event\_descr.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_descr.rb)
* [event\_edit\_alarm\_data.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_edit_alarm_data.rb)
* [event\_edit\_autoaction.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_edit_autoaction.rb)
* [event\_edit\_forward.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_edit_forward.rb)
* [event\_edit\_mouseovertext.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_edit_mouseovertext.rb)
* [event\_edit\_operinstruct.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_edit_operinstruct.rb)
* [event\_edit\_script.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_edit_script.rb)
* [event\_edit\_tticket.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_edit_tticket.rb)
* [event\_edit\_varbindsdecode.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_edit_varbindsdecode.rb)
* [event\_label.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_label.rb)
* [event\_logmsg\_dest.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_logmsg_dest.rb)
* [event\_logmsg\_notify.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_logmsg_notify.rb)
* [event\_logmsg.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_logmsg.rb)
* [event\_noop.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_noop.rb)
* [event\_remove\_add\_alarm\_data.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_add_alarm_data.rb)
* [event\_remove\_add\_autoaction.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_add_autoaction.rb)
* [event\_remove\_add\_forward.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_add_forward.rb)
* [event\_remove\_add\_script.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_add_script.rb)
* [event\_remove\_add\_tticket.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_add_tticket.rb)
* [event\_remove\_add\_varbindsdecode.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_add_varbindsdecode.rb)
* [event\_remove\_alarm\_data.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_alarm_data.rb)
* [event\_remove\_autoaction.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_autoaction.rb)
* [event\_remove\_forward.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_forward.rb)
* [event\_remove\_script.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_script.rb)
* [event\_remove\_tticket.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_tticket.rb)
* [event\_remove\_varbindsdecode.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_remove_varbindsdecode.rb)
* [event\_severity.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/event_severity.rb)
