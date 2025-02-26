# opennms\_snmp\_config\_definition

Manage `definition` elements and children in `$OPENNMS_HOME/etc/snmp-config.xml`. This resource uses the initialized accumulator pattern. The content of the current file is loaded into the template variables when the required `opennms_snmp_config` resource is executed. Instances of this resource modify those variables. As a result, to remove a definition entry from the file that was added outside of Chef, a resource matching that entry must be called with the `:delete` action.

## Uses

* [partial/\_snmp\_config](../partial/_snmp_config.rb)

## Requires

* An instance of [opennms\_snmp\_config](snmp_config.md).

## Actions

* `:add` - Default. Creates template resource, initializes variables used in the template with existing values, and manages the top level element attributes that all definitions and profiles inherit from.
* `:create` - Alias of `:add`.
* `:delete` - Removes a definition matching this resource if found in the current config file.

## Properties

| Name                 | Identity? | Name? | Type          | Default | Allowed Values                                       | v3? | v1/v2c? |
| -------------------- | --------- | ----- | ------------- | ------- | ---------------------------------------------------- | --- | ------- |
| `port`               |   :id:    |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `read_community`     |   :id:    |       | String        | `nil`   |                                                      |     |    ✓    |
| `write_community`    |   :id:    |       | String        | `nil`   |                                                      |     |    ✓    |
| `retry_count`        |   :id:    |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `timeout`            |   :id:    |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `proxy_host`         |   :id:    |       | String        | `nil`   |                                                      |  ✓  |    ✓    |
| `version`            |   :id:    |       | String        | `nil`   | `v1`, `v2c`,`v3`                                     |  ✓  |    ✓    |
| `max_vars_per_pdu`   |   :id:    |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `max_repetitions`    |   :id:    |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `max_request_size`   |   :id:    |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `ttl`                |   :id:    |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `encrypted`          |   :id:    |       | [true, false] | `nil`   |                                                      |  ✓  |    ✓    |
| `security_name`      |   :id:    |       | String        | `nil`   |                                                      |  ✓  |         |
| `security_level`     |   :id:    |       | Integer       | `nil`   | `1` (noAuthNoPriv), `2` (authNoPriv), `3` (authPriv) |  ✓  |         |
| `auth_passphrase`    |   :id:    |       | String        | `nil`   |                                                      |  ✓  |         |
| `auth_protocol`      |   :id:    |       | String        | `nil`   | `MD5`, `SHA`, `SHA-224`, `SHA-256`, `SHA-512`        |  ✓  |         |
| `engine_id`          |   :id:    |       | String        | `nil`   |                                                      |  ✓  |         |
| `context_engine_id`  |   :id:    |       | String        | `nil`   |                                                      |  ✓  |         |
| `context_name`       |   :id:    |       | String        | `nil`   |                                                      |  ✓  |         |
| `privacy_passphrase` |   :id:    |       | String        | `nil`   |                                                      |  ✓  |         |
| `privacy_protocol`   |   :id:    |       | String        | `nil`   | `DES`, `AES`, `AES192`, `AES256`                     |  ✓  |         |
| `enterprise_id`      |   :id:    |       | String        | `nil`   |                                                      |  ✓  |         |
| `location`           |   :id:    |       | String        | `nil`   |                                                      |  ✓  |    ✓    |
| `profile_label`      |   :id:    |       | String        | `nil`   |                                                      |  ✓  |    ✓    |
| `ranges`             |           |       | Array         | `nil`   | Each item must be a hash.                            |  ✓  |    ✓    |
| `specifics`          |           |       | Array         | `nil`   |                                                      |  ✓  |    ✓    |
| `ip_matches`         |           |       | Array         | `nil`   |                                                      |  ✓  |    ✓    |

## Libraries

* `Opennms::Cookbook::ConfigHelpers::SnmpConfigTemplate`

## Examples

Recipe: [snmp\_config\_definition](../test/fixtures/cookbooks/opennms_resource_tests/recipes/snmp_config_definition.rb)
Test: [snmp\_config\_definition_spec.rb](../test/integration/snmp_config_definition/controls/snmp_config_definition_spec.rb)

Recipe: [snmp\_config\_definition\_update](../test/fixtures/cookbooks/opennms_resource_tests/recipes/snmp_config_definition_update.rb)
Test: [snmp\_config\_definition\_update\_spec.rb](../test/integration/snmp_config_definition_update/controls/snmp_config_definition_update_spec.rb)

Recipe: [snmp\_config\_definition\_delete](../test/fixtures/cookbooks/opennms_resource_tests/recipes/snmp_config_definition_delete.rb)
Test: [snmp\_config\_definition\_delete\_spec.rb](../test/integration/snmp_config_definition_delete/controls/snmp_config_definition_delete_spec.rb)
