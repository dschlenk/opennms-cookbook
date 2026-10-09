# Custom Resources for managing OpenNMS Provisioning

A number of custom resources are available to assist with provisioning nodes into requisitions. Note that the term `import` is used throughout instead of the more correct term `requisition` as I find it easier to type without frequent misspellings. Also, they all use the OpenNMS REST interface, and as such, OpenNMS has to be running for the resources to converge. It is assumed that the API is available via localhost on the configured jetty port (default 8980) with the managed admin account.

## opennms\_foreign\_source

Create a new foreign source optionally defining a scan interval (defaults to '1d').

### Actions for opennms\_foreign\_source

* `:create` - Default. Creates the foreign source if it does not exist, and updates its `scan-interval` to match the `scan_interval` property.

### Properties for opennms\_foreign\_source

| Name | Identity? | Type | Required? | Notes |
|:-----|:----------|:-----|:----------|:------|
| `name` | x | String | x | Name property. |
| `scan_interval` | | String | | Defaults to `1d`. |

### Examples for opennms\_foreign\_source

Recipe [foreign\_source.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/foreign_source.rb) demonstrates use.

## opennms\_service\_detector

Add a service detector to a foreign source. Supports updating and deleting.

### Actions for opennms\_service\_detector

* `:create` - Default. Creates the service detector in the foreign source if it does not exist, and updates the `class_name` and `parameters` of an existing detector.
* `:create_if_missing` - Creates the service detector if it does not exist. Existing detectors are left unchanged.
* `:delete` - Deletes the service detector if it exists.

### Properties for opennms\_service\_detector

| Name | Identity? | Type | Required? | Notes |
|:-----|:----------|:-----|:----------|:------|
| `service_name` | x | String | x | Name property. |
| `class_name` | | String | | Fully qualified class name of the detector. |
| `foreign_source_name` | x | String | | Name of the foreign source the detector is added to/removed from. |
| `parameters` | | Hash | | Hash of string keys and values passed to the detector. |

### Examples for opennms\_service\_detector

Recipe [service\_detector.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/service_detector.rb) demonstrates use.

## opennms\_policy

Add a policy to a foreign source.

### Actions for opennms\_policy

* `:create` - Default. Creates the policy in the foreign source if it does not exist, and updates the `class_name` and `parameters` of an existing policy.
* `:create_if_missing` - Creates the policy if it does not exist. Existing policies are left unchanged.
* `:delete` - Deletes the policy if it exists.

### Properties for opennms\_policy

| Name | Identity? | Type | Required? | Notes |
|:-----|:----------|:-----|:----------|:------|
| `policy_name` | | String | x | Name property. |
| `class_name` | | String | x | Fully qualified class name of the policy. |
| `foreign_source_name` | x | String | | Name of the foreign source the policy is added to/removed from. |
| `parameters` | | Hash | | Hash of string keys and values passed to the policy. |

### Examples for opennms\_policy

Recipe [policy.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/policy.rb) demonstrates use.

## opennms\_import

Defines a requisition for a foreign source. This and all import\* custom resources include an option to synchronize the requisition - sync\_import.

### Actions for opennms\_import

* `:create` - Default. Creates the requisition if it does not exist. Synchronizes the requisition if `sync_import` is `true`.
* `:sync` - Synchronizes the requisition.

### Properties for opennms\_import

| Name | Identity? | Type | Required? | Notes |
|:-----|:----------|:-----|:----------|:------|
| `import_name` | x | String | x | Name property. |
| `foreign_source_name` | | String | | Name of the foreign source the requisition belongs to. Defaults to `imported:`. |
| `sync_import` | | Boolean | | Synchronize the requisition on converge. Defaults to `false`. |
| `sync_wait_periods` | | Integer | | Number of wait periods when synchronizing. Defaults to `30`. |
| `sync_wait_secs` | | Integer | | Seconds between wait periods when synchronizing. Defaults to `10`. |

### Examples for opennms\_import

Recipe [import.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/import.rb) demonstrates use.

## opennms\_import\_node

Add a node to a requisition including categories (array of strings) and assets (key/value hash pairs).

### Actions for opennms\_import\_node

* `:create` - Default. Creates a node with the given `foreign_id` in the requisition if it does not exist, and updates the node label, attributes, categories, assets, and metadata if it does.
* `:create_if_missing` - Creates the node if it does not exist. Existing nodes are left unchanged.
* `:delete` - Deletes the node from the requisition if it exists.

### Properties for opennms\_import\_node

| Name | Identity? | Type | Required? | Notes |
|:-----|:----------|:-----|:----------|:------|
| `node_label` | | String | x | Name property. Used as the label of the node. |
| `foreign_id` | x | String | x | |
| `foreign_source_name` | x | String | x | Name of the requisition the node is added to. |
| `parent_foreign_source` | | String | | Foreign source of the parent node. |
| `parent_foreign_id` | | String | | Foreign ID of the parent node. |
| `parent_node_label` | | String | | Label of the parent node. |
| `city` | | String | | |
| `building` | | String | | |
| `assets` | | Hash | | Hash of string keys and values. |
| `categories` | | Array | | Array of strings. |
| `meta_data` | | Array or Hash | | Array of hashes with string `context`, `key`, and `value` entries, or hash of metadata keys with `type` and `context` hashes. Defaults to an empty array. |
| `sync_import` | | Boolean | | Synchronize the requisition on converge. Defaults to `false`. |
| `sync_wait_periods` | | Integer | | Number of wait periods when synchronizing. Defaults to `30`. |
| `sync_wait_secs` | | Integer | | Seconds between wait periods when synchronizing. Defaults to `10`. |

### Examples for opennms\_import\_node

Recipe [import\_node.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/import_node.rb) demonstrates use.

## opennms\_import\_node\_interface

Add an interface to a node in a requisition.

### Actions for opennms\_import\_node\_interface

* `:create` - Default. Creates an interface for the node with the given `foreign_id` in the requisition if it does not exist, and updates the `status`, `managed`, `snmp_primary`, `categories`, and `meta_data` of an existing interface. Synchronizes the requisition if `sync_import` is `true`, or if `sync_existing` is `true` and no changes were made.

### Properties for opennms\_import\_node\_interface

| Name | Identity? | Type | Required? | Notes |
|:-----|:----------|:-----|:----------|:------|
| `ip_addr` | x | String | x | Name property and identity. IP address of the interface. Must be a valid IPv4 or IPv6 address. |
| `foreign_id` | x | String | x | Foreign ID of the node the interface is added to. |
| `foreign_source_name` | x | String | x | Name of the requisition the node is in. |
| `status` | | Integer | | |
| `managed` | | Boolean | | Whether the interface is managed. Defaults to `false`. |
| `snmp_primary` | | String | | Whether the interface is the primary SNMP interface. Must be `P`, `S`, or `N`. |
| `sync_existing` | | Boolean | | Synchronize the requisition even if the interface is unchanged. Defaults to `false`. |
| `categories` | | Array | | Array of strings. |
| `meta_data` | | Array or Hash | | Array of hashes with string `context`, `key`, and `value` entries, or hash of metadata keys with `type` and `context` hashes. Defaults to an empty array. |
| `sync_import` | | Boolean | | Synchronize the requisition on converge. Defaults to `false`. |
| `sync_wait_periods` | | Integer | | Number of wait periods when synchronizing. Defaults to `30`. |
| `sync_wait_secs` | | Integer | | Seconds between wait periods when synchronizing. Defaults to `10`. |

### Examples for opennms\_import\_node\_interface

Recipe [import\_node\_interface.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/import_node_interface.rb) demonstrates use.

## opennms\_import\_node\_interface\_service

Add a service to an interface on a node in a requisition.

### Actions for opennms\_import\_node\_interface\_service

* `:create` - Default. Creates a monitored service on the interface for the node with the given `foreign_id` in the requisition if it does not exist, and updates the `categories` and `meta_data` of an existing service.

### Properties for opennms\_import\_node\_interface\_service

| Name | Identity? | Type | Required? | Notes |
|:-----|:----------|:-----|:----------|:------|
| `service_name` | | String | x | Name property. |
| `foreign_id` | x | String | x | Foreign ID of the node the service is added to. |
| `ip_addr` | x | String | x | IP address of the interface the service is monitored on. |
| `foreign_source_name` | x | String | x | Name of the requisition the node is in. |
| `categories` | | Array | | Array of strings. |
| `meta_data` | | Array or Hash | | Array of hashes with string `context`, `key`, and `value` entries, or hash of metadata keys with `type` and `context` hashes. Defaults to an empty array. |
| `sync_import` | | Boolean | | Synchronize the requisition on converge. Defaults to `false`. |
| `sync_wait_periods` | | Integer | | Number of wait periods when synchronizing. Defaults to `30`. |
| `sync_wait_secs` | | Integer | | Seconds between wait periods when synchronizing. Defaults to `10`. |

### Examples for opennms\_import\_node\_interface\_service

Recipe [import\_node\_interface\_service.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/import_node_interface_service.rb) demonstrates use.
