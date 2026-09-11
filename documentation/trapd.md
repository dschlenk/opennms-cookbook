# opennms_trapd_config

Manages the OpenNMS Trapd configuration.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Create or update the Trapd configuration. |

Default action:

```ruby
:create
```

## Properties

| Property | Type | Description |
| --- | --- | --- |
| `batch_interval` | Integer | Trap processing batch interval. |
| `batch_size` | Integer | Maximum number of traps processed per batch. |
| `include_raw_message` | Boolean | Include the raw trap message. |
| `new_suspect_on_trap` | Boolean | Create new suspects from received traps. |
| `queue_size` | Integer | Trap queue size. |
| `snmp_trap_address` | String | Trap listener bind address. |
| `snmp_trap_port` | Integer | Trap listener port. |
| `threads` | Integer | Number of Trapd worker threads. |
| `use_address_from_varbind` | Boolean | Derive node identity from trap varbinds when possible. |

## Examples

### Basic Configuration

```ruby
opennms_trapd_config 'default' do
  batch_interval 200
  batch_size 500
  include_raw_message true
  queue_size 5000
  threads 8
end
```

### Configure Listener Address and Port

```ruby
opennms_trapd_config 'default' do
  snmp_trap_address '0.0.0.0'
  snmp_trap_port 1162
end
```

### Enable Address Resolution From Varbinds

```ruby
opennms_trapd_config 'default' do
  use_address_from_varbind true
end
```

---

# opennms_trapd_snmpv3_user

Manages Trapd SNMPv3 users.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Create or update an SNMPv3 user. |
| `:delete` | Delete an SNMPv3 user. |

Default action:

```ruby
:create
```

## Security Levels

| Value | Description |
| --- | --- |
| `NOAUTH_NOPRIV` | No authentication, no privacy. |
| `AUTH_NOPRIV` | Authentication without privacy. |
| `AUTH_PRIV` | Authentication with privacy. |

## Properties

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `security_name` | String | Yes | SNMPv3 security name. |
| `engine_id` | String | No | SNMP engine ID. |
| `security_level` | String | Yes | Security level. Must be one of `NOAUTH_NOPRIV`, `AUTH_NOPRIV`, or `AUTH_PRIV`. |
| `auth_protocol` | String | Conditional | Required for `AUTH_NOPRIV` and `AUTH_PRIV`. |
| `privacy_protocol` | String | Conditional | Required for `AUTH_PRIV`. |
| `auth_passphrase` | String | Conditional | Required for `AUTH_NOPRIV` and `AUTH_PRIV`. |
| `privacy_passphrase` | String | Conditional | Required for `AUTH_PRIV`. |

### Property Rules

For `NOAUTH_NOPRIV`:

- `auth_protocol` must not be specified
- `auth_passphrase` must not be specified
- `privacy_protocol` must not be specified
- `privacy_passphrase` must not be specified

For `AUTH_NOPRIV`:

- `auth_protocol` is required
- `auth_passphrase` is required
- `privacy_protocol` must not be specified
- `privacy_passphrase` must not be specified

For `AUTH_PRIV`:

- `auth_protocol` is required
- `auth_passphrase` is required
- `privacy_protocol` is required
- `privacy_passphrase` is required

## Examples

### NOAUTH_NOPRIV User

```ruby
opennms_trapd_snmpv3_user 'readonly' do
  security_name 'readonly'
  security_level 'NOAUTH_NOPRIV'
end
```

### AUTH_NOPRIV User

```ruby
opennms_trapd_snmpv3_user 'monitor' do
  security_name 'monitor'
  security_level 'AUTH_NOPRIV'
  auth_protocol 'SHA'
  auth_passphrase 'authsecret'
end
```

### AUTH_PRIV User

```ruby
opennms_trapd_snmpv3_user 'trapuser' do
  security_name 'trapuser'
  security_level 'AUTH_PRIV'
  auth_protocol 'SHA'
  auth_passphrase 'authsecret'
  privacy_protocol 'AES'
  privacy_passphrase 'privsecret'
end
```

### AUTH_PRIV User With Engine ID

```ruby
opennms_trapd_snmpv3_user 'remote-engine-user' do
  security_name 'trapuser'
  engine_id '8000000001020304'
  security_level 'AUTH_PRIV'
  auth_protocol 'SHA'
  auth_passphrase 'authsecret'
  privacy_protocol 'AES'
  privacy_passphrase 'privsecret'
end
```

### Delete a User

```ruby
opennms_trapd_snmpv3_user 'trapuser' do
  security_name 'trapuser'
  security_level 'AUTH_PRIV'
  auth_protocol 'SHA'
  privacy_protocol 'AES'

  action :delete
end
```