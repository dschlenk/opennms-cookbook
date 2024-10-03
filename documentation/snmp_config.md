# opennms\_snmp\_config

An instance of this resource should be defined when using any of the other `opennms_snmp_config_*` resources. It controls the top level attributes of the `snmp-config` element in `$OPENNMS_HOME/etc/snmp-config.xml` and initializes the template variables used by the other `opennms_snmp_config` custom resources.

## Uses

* [partial/\_snmp\_config](../partial/_snmp_config.rb)

## Actions

* `:create` - Default. Creates template resource, initializes variables used in the template with existing values, and manages the top level element attributes that all definitions and profiles inherit from.

## Properties

| Name                 | Name? | Type          | Default | Allowed Values                                       | v3? | v1/v2c? |
| -------------------- | ----- | ------------- | ------- | ---------------------------------------------------- | --- | ------- |
| `port`               |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `read_community`     |       | String        | `nil`   |                                                      |     |    ✓    |
| `write_community`    |       | String        | `nil`   |                                                      |     |    ✓    |
| `retry_count`        |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `timeout`            |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `proxy_host`         |       | String        | `nil`   |                                                      |  ✓  |    ✓    |
| `version`            |       | String        | `nil`   | `v1`, `v2c`,`v3`                                     |  ✓  |    ✓    |
| `max_vars_per_pdu`   |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `max_repetitions`    |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `max_request_size`   |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `ttl`                |       | Integer       | `nil`   |                                                      |  ✓  |    ✓    |
| `encrypted`          |       | [true, false] | `nil`   |                                                      |  ✓  |    ✓    |
| `security_name`      |       | String        | `nil`   |                                                      |  ✓  |         |
| `security_level`     |       | Integer       | `nil`   | `1` (noAuthNoPriv), `2` (authNoPriv), `3` (authPriv) |  ✓  |         |
| `auth_passphrase`    |       | String        | `nil`   |                                                      |  ✓  |         |
| `auth_protocol`      |       | String        | `nil`   | `MD5`, `SHA`, `SHA-224`, `SHA-256`, `SHA-512`        |  ✓  |         |
| `engine_id`          |       | String        | `nil`   |                                                      |  ✓  |         |
| `context_engine_id`  |       | String        | `nil`   |                                                      |  ✓  |         |
| `context_name`       |       | String        | `nil`   |                                                      |  ✓  |         |
| `privacy_passphrase` |       | String        | `nil`   |                                                      |  ✓  |         |
| `privacy_protocol`   |       | String        | `nil`   | `DES`, `AES`, `AES192`, `AES256`                     |  ✓  |         |
| `enterprise_id`      |       | String        | `nil`   |                                                      |  ✓  |         |

## Libraries

* `Opennms::Cookbook::ConfigHelpers::SnmpConfigTemplate`

## Examples

To match the out of the box config:

```
opennms_snmp_config 'default' do
  version 'v2c'
  read_community 'public'
  timeout 1800
  retry_count 1
end
```

resulting in the following config:

```
<snmp-config xmlns="http://xmlns.opennms.org/xsd/config/snmp" version="v2c" read-community="public" timeout="1800" retry="1"/>
```

An example with all relavant v1/v2c properties set:

```
opennms_snmp_config `v3' do
  port 161
  retry_count 1
  timeout 3000
  read_community 'public'
  write_community 'private'
  proxy_host '192.0.2.1'
  version 'v2c'
  max_vars_per_pdu 50
  max_repetitions 1
  max_request_size 1337
  ttl 4000
  encrypted false
end
```

resulting in the following config:

```
<snmp-config xmlns="http://xmlns.opennms.org/xsd/config/snmp" version="v2c" port="161" read-community="public" write-community="private" timeout="3000" retry="1" proxy-host="192.0.2.1" max-vars-per-pdu="50" max-repetitions="1" max-request-size="1337" ttl="4000" encrypted="false"/>
```

An example with all properties set that are relevent for v3:

```
opennms_snmp_config `v3' do
  port 161
  retry_count 1
  timeout 3000
  proxy_host '192.0.2.1'
  version 'v3'
  max_vars_per_pdu 50
  max_repetitions 1
  max_request_size 1337
  ttl 4000
  encrypted false
  security_name 'superSecure'
  security_level 3
  auth_passphrase '0p3nNMSv3'
  auth_protocol 'SHA-512'
  engine_id '3ng*n3'
  context_engine_id 'c0nt3xt'
  context_name 'cn@m3'
  privacy_passphrase '0p3nNMSv3'
  privacy_protocol 'AES256'
  enterprise_id '8072'
end
```

resulting in the following config:

```
<snmp-config xmlns="http://xmlns.opennms.org/xsd/config/snmp" version="v3" port="161" timeout="3000" retry="1" proxy-host="192.0.2.1" max-vars-per-pdu="50" max-repetitions="1" max-request-size="1337" ttl="4000" encrypted="false" security-name="superSecure" security-level="3" auth-passphrase="0p3nNMSv3" auth-protocol="SHA-512" engine-id="3ng*n3" context-engine-id="c0nt3xt" context-name="cn@m3" privacy-passphrase="0p3nNMSv3" privacy-protocol="AES256" enterprise-id="8072"/>
```

Note that properties exclusive to `v1` and `v2c` will be ignored if `version` is `v3`. Likewise, `v3` exclusive properties will be ignored when `version` is not `v3`.
If `version` is not set, OpenNMS assumes `v1` and this resource matches that behavior.
