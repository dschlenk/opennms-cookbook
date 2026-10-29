# opennms\_snmp\_config\_profile

Manage SNMP config profile configurations. This resource uses the initialized accumulator pattern. The content of the current SNMP config is loaded into `run_state` when the required `opennms_snmp_config` resource is executed. Instances of this resource modify that state, which is then updated at the end of the Chef run. As a result, to remove a profile entry from the file that was added outside of Chef, a resource matching that entry must be called with the `:delete` action.

## OpenNMS 36

On OpenNMS 36 and later profiles are stored in the database and managed through the v2 REST API instead of the `snmp-config.xml` file. The config is downloaded once per run and, only if anything changed in the run, uploaded once at the end of the run (see [opennms\_snmp\_config](snmp_config.md)). The download is accumulated in memory and the same file-based semantics as on earlier versions apply to it:

* `:add` (`:create`) **replaces the entire profile row** with the same label: attributes that are not set on the resource are cleared. If the same label is declared by more than one resource in a run list, the last declaration wins, and on every run the earlier declarations revert the row and the later ones re-apply it, so all of them report changes on every run (the resulting state is stable).
* `:delete` removes the profile with the label; if the profile does not exist the resource does nothing. Nothing checks for definitions that reference the label: deleting a profile leaves definitions with the same `profile_label` in place.
* `encrypted` is not stored in the database and is rejected on OpenNMS 36.

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
