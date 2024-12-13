# Custom Resources for managing OpenNMS Discovery configuration

Custom resources `opennms_disco_range`, `opennms_disco_specific`, and `opennms_disco_url` allow you to manage the discovery configuration file `$OPENNMS_HOME/etc/discovery-configuration.xml` as code.

## opennms\_disco\_range

Creates an `include-range` or `exclude-range` element in the file (type is determined by the `range_type` property).

### Actions for opennms\_disco\_range

* `:create` - Default. Creates a new `include-range` or `exclude-range` element if it does not exist. Will update if already exists.
* `:create_if_missing` - Creates a new `include-range` or `exclude-range` element if it does not exist. Will not update an existing element with the same identity, which is composed of the `range_begin`, `range_end`, `range_type`, and `location` properties.
* `:update` - Updates an existing `include-range` or `exclude-range` element with matching identity. Will raise an error if no such element exists.
* `:delete` - Deletes an existing `include-range` or `exclude-range` element with matching identity if it exists.

### Properties for opennms\_disco\_range

| Name | Identity? | Type | Required? | Notes |
| ---- | --------- | ---- | --------- | ----- |
| `name` | | String | x | Not used for anything |
| `range_begin` | x | String | x | should be an IP address although no validation is performed |
| `range_end` | x | String | x | should be an IP address although no validation is performed |
| `range_type` | x | String | | Defaults to `include`. Can be `include` or `exclude`. |
| `location` | x | String | | |
| `retry_count` | | Integer | | Ignored when `range_type` is `exclude`. |
| `timeout` | | Integer | | Ignored when `range_type` is `exclude`. |
| `foreign_source` | | String | | Ignored when `range_type` is `exclude`. |

### Examples for opennms\_disco\_range

Recipe [disco\_range.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/disco_range.rb) demonstrates use.

## opennms\_disco\_specific

Creates a `specific` element in the file.

### Actions for opennms\_disco\_specific

* `:create` - Default. Creates a new `specific` element if it does not exist. Will update if an element with the same identity already exists. Identity is composed of the `ipaddr` and `location` properties.
* `:create_if_missing` - Creates a new `specific` element if it does not exist. Will not update an existing element with the same identity.
* `:update` - Updates an existing `specific` element with matching identity. Will raise an error if no such element exists.
* `:delete` - Deletes an existing `specific` element with matching identity if it exists.

### Properties for opennms\_disco\_specific

| Name | Identity? | Type | Required? | Notes |
| ---- | --------- | ---- | --------- | ----- |
| `ipaddr` | x | String | x | Name property. Should be an IP address, although no validation is performed. |
| `location` | x | String | | |
| `retry_count` | | Integer | | |
| `timeout` | | Integer | | |
| `foreign_source` | | String | | |

### Examples for opennms\_disco\_specific

Recipe [disco\_specific.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/disco_specific.rb) demonstrates use.

## opennms\_disco\_url

Creates an `include-url` or `exclude-url` element in the file (type is determined by the `url_type` property).

### Actions for opennms\_disco\_url

* `:create` - Default. Creates a new `include-url` or `exclude-url` element if it does not exist. Will update if an element with matching identity already exists. Identity is composed of the `url`, `url_type`, and `location` properties.
* `:create_if_missing` - Creates a new `include-url` or `exclude-url` element if it does not exist. Will not update an existing element with the same identity.
* `:update` - Updates an existing `include-url` or `exclude-url` element with matching identity. Will raise an error if no such element exists.
* `:delete` - Deletes an existing `include-url` or `exclude-url` element with matching identity if it exists.

### Properties for opennms\_disco\_url

| Name | Identity? | Type | Required? | Notes |
| ---- | --------- | ---- | --------- | ----- |
| `url` | x | String | x | Name proeprty. Should be a URL in a format compatible with OpenNMS, although no validation is performed. |
| `url_type` | x | String | | Defaults to `include`. Can be `include` or `exclude`. |
| `location` | x | String | | |
| `retry_count` | | Integer | | Ignored when `url_type` is `exclude`. |
| `timeout` | | Integer | | Ignored when `url_type` is `exclude`. |
| `foreign_source` | | String | | Ignored when `url_type` is `exclude`. |

### Examples for opennms\_disco\_url

Recipe [disco\_url.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/disco_url.rb) demonstrates use.
