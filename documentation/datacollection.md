# Data Collection Resources

## XML

The following resources are available to express XML data collection configuration as code.
All resources use the initialized delayed accumulator pattern, so template variables are created in accordance with current state when the first resource is executed, and the execution of all subsequent resource instances that affect that file simply modify those template variables.
The templates are then rendered as delayed `:create` actions.
Appropriate service restarts are performed automatically.

### xml\_collection

Manages an `xml-collection` element in `$OPENNMS_HOME/etc/xml-datacollection-config.xml`.

#### Actions

* `:create` - Default. Adds or updates the `xml-collection` element in the file with the name matching the `collection` property.
* `:update` - Modify an existing `xml-collection` element. Raises an error if the collection does not exist.
* `:delete` - Remove an existing `xml-collection` element and its children if it exists.

#### Properties

| Name         | Name? | Type    | Allowed Values                                                                    |
| ------------ | ----- | ------- | --------------------------------------------------------------------------------- |
| `collection` |   ✓   | String  |                                                                                   |
| `rrd_step`   |       | Integer |                                                                                   |
| `rras`       |       | Array   | an array of strings that match regular expression `RRA:(AVERAGE|MIN|MAX|LAST):.*` |

`rrd_step` will default to 300 on `:create` when not specified.

`rras` will default to `['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']` on `:create` when not specified.

#### Examples

The following resource:

```
opennms_xml_collection 'foo' do
  rrd_step 600
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732']
  notifies :restart, 'service[opennms]', :delayed
end
```

results in the addition of the following element:

```
<xml-collection name="foo">
        <rrd step="600">
            <rra>RRA:AVERAGE:0.5:2:4032</rra>
            <rra>RRA:AVERAGE:0.5:24:2976</rra>
            <rra>RRA:AVERAGE:0.5:576:732</rra>
            <rra>RRA:MAX:0.5:576:732</rra>
            <rra>RRA:MIN:0.5:576:732</rra>
        </rrd>
</xml-collection>
```

See [xml\_collection.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/xml_collection.rb) for additional examples.

### xml\_source

Manages the `xml-source` child of the `xml-collection` element with name `collection_name` in `$OPENNMS_HOME/etc/xml-datacollection-config.xml`.

#### Actions

* `:create` - Default. Adds the element with attributes and children according to the defined properties of the resource.
* `:update` - Update an existing `xml-source` element and its children. Raises an error if the `xml-source` does not exist.
* `:delete` - Deletes the referenced `xml-source` element and its children if it exists.

#### Properties

| Name                   | Name? | Type             | Identity? | Desired State? | Validation? |
| ---------------------- | ----- | ---------------- | --------- | -------------- | ----------- |
| `url`                  |   ✓   | String           |     ✓     |       ✓        |             |
| `collection_name`      |       | String           |     ✓     |       ✓        |             |
| `request_method`       |       | String           |           |       ✓        |             |
| `request_params`       |       | Hash             |           |       ✓        |             |
| `request_headers`      |       | Hash             |           |       ✓        |             |
| `request_content`      |       | String           |           |       ✓        |             |
| `request_content_type` |       | String           |           |       ✓        |             |
| `import_groups`        |       | `Array`, `false` |           |       ✓        |      ✓      |
| `import_groups_source` |       | String           |           |                |             |
| `groups`               |       | `Array`, `false` |           |       ✓        |      ✓      |

The `collection_name` must reference an existing collection (see the `xml_collection` resource above)
The `xml-datacollection-config.xml` file can be modularized by storing `xml-group` elements in separate files in `$OPENNMS_HOME/etc/xml-datacollection/` and referencing them in a source by filename with `import-group` elements. 
Alternatively, the `xml-group` elements can be included directly in the `xml-source`. 
This cookbook supports either method.
To reference groups in a file, use the `import_groups` property of this resource (array of file names relative to `$OPENNMS_HOME/etc/xml-datacollection`). 
To add groups directly to an `xml-source` in the main file, use the `groups` property of this resource or use the `opennms_xml_group` resource (without using the `file` property).

Property `request_content_type` will default to `application/x-www-form-urlencoded` if `request_content` is specified but the former is not. 

`import_groups_source` defaults to `cookbook_file`, meaning that a `cookbook_file` resource will be declared for each item in `import_group`. The path will be `$OPENNMS_HOME/etc/xml-datacollection/<import group item>` and source of `<import group item>`. If you are managing this file yourself, set this property to `external`. To source the files with `remote_file` resources instead, set this to the root directory of a URI that `remote_file` supports and that contains all files referenced by `import_groups`.

The validation performed on `import_groups` is to assert that each item in the array is a String, or `false`. When `false`, any existing `import-group` elements are removed.

The validation performed on `groups` is to assert that it is an array of hashes where each hash must contain keys `name`, `resource_type`, and `resource_xpath` (all strings); can contain `key_xpath`, `timestamp_xpath`, and `timestamp_format` (all strings), a key named `resource_keys` that if present its value must be an array of strings, and `objects` which if present must be an array of hashes with keys `name`, `type`, and `xpath` with string values. See examples for further illustration on how to use this property.

#### Examples

See [xml\_source.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/xml_source.rb) and [xml\_source\_delete.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/xml_source_delete.rb).

### xml\_group

Manage an `xml-group` element and its children in either an `xml-source` element of `$OPENNMS_HOME/etc/xml-datacollection-config.xml` or a tribuary file in `$OPENNMS_HOME/etc/xml-datacollection/`.

#### Actions

* `:create` - Default. Adds the element with attributes and children according to the defined properties of the resource.
* `:update` - Update an existing `xml-group` element and its children. Raises an error if the `xml-group` does not exist.
* `:delete` - Deletes the referenced `xml-group` element and its children if it exists.

#### Properties

| Name               | Name? | Type            | Identity? | Required? | Desired State? | Validation? | Default |
| ------------------ | ----- | --------------- | --------- | --------- | -------------- | ----------- | ------- |
| `group_name`       |   ✓   | String          |     ✓     |           |       ✓        |             |         |
| `source_url`       |       | String          |     ✓     |           |       ✓        |             |         |
| `collection_name`  |       | String          |     ✓     |           |       ✓        |             |         |
| `file`             |       | String          |     ✓     |           |       ✓        |             |         |
| `resource_type`    |       | String          |           |           |       ✓        |             | `node`  |
| `resource_xpath`   |       | String          |           |     ✓     |       ✓        |             |         |
| `key_xpath`        |       | String          |           |           |       ✓        |             |         |
| `timestamp_xpath`  |       | String          |           |           |       ✓        |             |         |
| `timestamp_format` |       | String          |           |           |       ✓        |             |         |
| `resource_keys`    |       | Array           |           |           |       ✓        |      ✓      |         |
| `objects`          |       | `Array`, `Hash` |           |           |       ✓        |      ✓      |         |

When the `file` property is set, the group is added to a file in `$OPENNMS_HOME/etc/xml-datacollection/<file>` and the `source_url` and `collection_name` properties are ignored.

The validation on `resource_keys` verifies that each item in the array is a `String`.

The validation on `objects` ensures that when the property value is an `Array`, each item is a `Hash` that contains keys `name`, `type`, and `xpath` each with `String` values. When the property value is a `Hash`, each key has a `Hash` value that contains keys `type` and `xpath` with `String` values.

#### Examples

See [xml\_group.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/xml_group.rb) and [xml\_group\_delete.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/xml_group_delete.rb).
