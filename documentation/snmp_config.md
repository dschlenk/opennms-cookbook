# opennms\_snmp\_config

An instance of this resource must be defined when using any of the other `opennms_snmp_config_*` resources. It controls the default attributes used by OpenNMS for interfaces that don't match a definition.

On OpenNMS 36 and later the snmp config is stored in the database and managed through the v2 REST API instead of `$OPENNMS_HOME/etc/snmp-config.xml`. The config is downloaded once per run as XML and, only if a resource changed it in the run, uploaded once at the end of the run: at most two API calls per run, one on a fully idempotent run. The download is accumulated in memory and the same file-based semantics as on earlier versions apply to it.

* `:create` rewrites the root attributes of the accumulated document: attributes set on the resource are written and attributes that are not set are cleared, exactly like the file on earlier versions. An instance without any properties set therefore never converges. A partial instance (e.g. only `timeout`) converges whenever a declared attribute differs from the stored value and rewrites the whole root, clearing every attribute it does not declare (e.g. the values that a fresh 36 installation seeds into the database from the stale `snmp-config.xml` shipped in the package); it is idempotent once the declared attributes match.
* On every converging run the accumulated document is rendered with the `snmp-config.xml.erb` template into a scratch file in the file cache that the upload reads, so the run output also shows that template as updated.
* `encrypted` is not stored in the database and is rejected on OpenNMS 36: passphrases are never stored encrypted.

## Uses

* [partial/\_snmp\_config](../partial/_snmp_config.rb)

## Actions

* `:create` - Default. Manages the default configuration values that definitions and profiles inherit from.

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

```ruby
opennms_snmp_config 'default' do
  version 'v2c'
  read_community 'public'
  timeout 1800
  retry_count 1
end
```

which results in the following config:

```xml
<snmp-config xmlns="http://xmlns.opennms.org/xsd/config/snmp" version="v2c" read-community="public" timeout="1800" retry="1"/>
```

An example with all relavant v1/v2c properties set:

```ruby
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

```xml
<snmp-config xmlns="http://xmlns.opennms.org/xsd/config/snmp" version="v2c" port="161" read-community="public" write-community="private" timeout="3000" retry="1" proxy-host="192.0.2.1" max-vars-per-pdu="50" max-repetitions="1" max-request-size="1337" ttl="4000" encrypted="false"/>
```

An example with all properties set that are relevent for v3:

```ruby
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

```xml
<snmp-config xmlns="http://xmlns.opennms.org/xsd/config/snmp" version="v3" port="161" timeout="3000" retry="1" proxy-host="192.0.2.1" max-vars-per-pdu="50" max-repetitions="1" max-request-size="1337" ttl="4000" encrypted="false" security-name="superSecure" security-level="3" auth-passphrase="0p3nNMSv3" auth-protocol="SHA-512" engine-id="3ng*n3" context-engine-id="c0nt3xt" context-name="cn@m3" privacy-passphrase="0p3nNMSv3" privacy-protocol="AES256" enterprise-id="8072"/>
```

Note that properties exclusive to `v1` and `v2c` will be ignored if `version` is `v3`. Likewise, `v3` exclusive properties will be ignored when `version` is not `v3`.
If `version` is not set, OpenNMS assumes `v1` and this resource matches that behavior.
