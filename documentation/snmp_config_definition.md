# opennms\_snmp\_config\_definition

Manage SNMP config definitions. This resource uses the initialized accumulator pattern. The content of the current config is loaded into `run_state` when the required `opennms_snmp_config` resource is executed. Instances of this resource modify that state. As a result, a definition entry that was added outside of Chef can be removed with a resource matching its identity with the `:delete` action.

## Changes in OpenNMS 36

On OpenNMS 36 and later definitions are stored in the database and managed through the v2 REST API instead of the `snmp-config.xml` file. The config is downloaded once per run and, only if anything changed in the run, uploaded once at the end of the run (see [opennms\_snmp\_config](snmp_config.md)). The download is accumulated in memory and the same file-based semantics as on earlier versions apply to it:

* `:add` (`:create`) matches the stored definition by its full identity — every attribute from the properties table plus `location` and `profile_label`; the selectors are not part of the identity. If a stored definition matches, the declared interface selectors (`ranges`, `specifics`, `ip_matches`) are union-merged into it; otherwise the definition is added as declared. Nothing is purged from other definitions, overlapping definitions can coexist, and a single definition may carry all three kinds of selectors.
* If the stored definition the resource matches carries more selectors than the declaration (because they were added by another resource or outside of Chef), the resource converges and reports changes on every run; the merge itself is a no-op and does not by itself trigger the end-of-run upload.
* Definitions without any SNMP attributes are valid and stored as-is (e.g. selectors plus `profile_label` only).
* `:delete` matches the stored definition by the same full identity and removes the whole definition, including all of its selectors — not just the declared ones. To remove a definition that was added outside of Chef, declare the attributes of the stored definition: every attribute that is not declared must be absent from it. If several stored definitions match the declared identity, the resource raises an error, as on earlier versions.
* `encrypted` is not stored in the database and is rejected on OpenNMS 36.

## Uses

* [partial/\_snmp\_config](../partial/_snmp_config.rb)

## Requires

* An instance of [opennms\_snmp\_config](snmp_config.md).

## Actions

* `:add` - Default. Creates or updates the definition.
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
