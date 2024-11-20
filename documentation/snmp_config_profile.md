# opennms\_snmp\_config\_profile

Manage `profile` elements and children in `$OPENNMS_HOME/etc/snmp-config.xml`. This resource uses the initialized accumulator pattern. The content of the current file is loaded into the template variables when the required `opennms_snmp_config` resource is executed. Instances of this resource modify those variables. As a result, to remove a profile entry from the file that was added outside of Chef, a resource matching that entry must be called with the `:delete` action.

## Uses

* [partial/\_snmp\_config](../partial/_snmp_config.rb)

## Requires

* An instance of [opennms\_snmp\_config](snmp_config.md).

## Actions

* `:add` - Default. Creates template resource, initializes variables used in the template with existing values, and manages the top level element attributes that all definitions and profiles inherit from.
* `:create` - Alias of `:add`.
* `:delete` - Removes a profile matching this resource if found in the current config file.

## Properties

| Name                 | Identity? | Name? | Type          | Default | Allowed Values                                       | v3? | v1/v2c? |
| -------------------- | --------- | ----- | ------------- | ------- | ---------------------------------------------------- | --- | ------- |
| `port`               |           |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `read_community`     |           |       | String        | `nil`   |                                                      |     |    ✓    |
| `write_community`    |           |       | String        | `nil`   |                                                      |     |    ✓    |
| `retry_count`        |           |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `timeout`            |           |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `proxy_host`         |           |       | String        | `nil`   |                                                      |  ✓  |    ✓    |
| `version`            |           |       | String        | `nil`   | `v1`, `v2c`,`v3`                                     |  ✓  |    ✓    |
| `max_vars_per_pdu`   |           |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `max_repetitions`    |           |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `max_request_size`   |           |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `ttl`                |           |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `encrypted`          |           |       | [true, false] | `nil`   |                                                      |  ✓  |    ✓    |
| `security_name`      |           |       | String        | `nil`   |                                                      |  ✓  |         |
| `security_level`     |           |       | Integer       | `nil`   | `1` (noAuthNoPriv), `2` (authNoPriv), `3` (authPriv) |  ✓  |         |
| `auth_passphrase`    |           |       | String        | `nil`   |                                                      |  ✓  |         |
| `auth_protocol`      |           |       | String        | `nil`   | `MD5`, `SHA`, `SHA-224`, `SHA-256`, `SHA-512`        |  ✓  |         |
| `engine_id`          |           |       | String        | `nil`   |                                                      |  ✓  |         |
| `context_engine_id`  |           |       | String        | `nil`   |                                                      |  ✓  |         |
| `context_name`       |           |       | String        | `nil`   |                                                      |  ✓  |         |
| `privacy_passphrase` |           |       | String        | `nil`   |                                                      |  ✓  |         |
| `privacy_protocol`   |           |       | String        | `nil`   | `DES`, `AES`, `AES192`, `AES256`                     |  ✓  |         |
| `enterprise_id`      |           |       | String        | `nil`   |                                                      |  ✓  |         |
| `label`              |   :id:    |   ✓   | String        |         |                                                      |  ✓  |    ✓    |
| `filter`             |           |       | String        | `nil`   |                                                      |  ✓  |    ✓    |

## Libraries

* `Opennms::Cookbook::ConfigHelpers::SnmpConfigTemplate`

## Examples

Recipe: [snmp\_config\_profile](../test/fixtures/cookbooks/opennms_resource_tests/recipes/snmp_config_profile.rb)
Test: [snmp\_config\_profile\_spec.rb](../test/integration/snmp_config_profile/controls/snmp_config_profile_spec.rb)

Recipe: [snmp\_config\_profile\_update](../test/fixtures/cookbooks/opennms_resource_tests/recipes/snmp_config_profile_update.rb)
Test: [snmp\_config\_profile\_update\_spec.rb](../test/integration/snmp_config_profile_update/controls/snmp_config_profile_spec.rb)

Recipe: [snmp\_config\_profile\_delete](../test/fixtures/cookbooks/opennms_resource_tests/recipes/snmp_config_profile_delete.rb)
Test: [snmp\_config\_profile\_delete\_spec.rb](../test/integration/snmp_config_profile_delete/controls/snmp_config_profile_spec.rb)
