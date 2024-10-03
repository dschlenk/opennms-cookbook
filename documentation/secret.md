# opennms\_secret

Manage secrets in the OpenNMS secure credentials vault.

## Actions

* `:create` - Default. Adds credentials defined in the resource to the secreat alias named `secret_alias` to the secure crendentials vault.

## Properties

| Name                 | Name? | Type          | Required |
| -------------------- | ----- | ------------- | -------- |
| `username`           |       | String        |     x    |
| `password`           |       | String        |     x    |
| `extra_properties`   |       | Hash          |          |

## Examples

To store the passwords (retrieved from a Chef Vault) for the accounts needed for the postgres database using the alias and username used by the default config of `$OPENNMS_HOME/etc/opennms-datasources.xml`:

```
opennms_secret 'opennms postgresql user' do
  secret_alias 'postgres'
  username node['opennms']['username']
  password chef_vault_item(node['opennms']['postgresql']['user_vault'], node['opennms']['postgresql']['user_vault_item'])['opennms']['password']
end

opennms_secret 'postgres postgresql user' do
  secret_alias 'postgres-admin'
  username 'postgres'
  password chef_vault_item(node['opennms']['postgresql']['user_vault'], node['opennms']['postgresql']['user_vault_item'])['postgres']['password']
end
```

with the vault item:

```
{
  "id": "postgres_users",
  "postgres": {
    "password": "one2three4"
  },
  "opennms": {
    "password": "five6seven8"
  }
}
```

will result in the following items in the SCV:

```
# /opt/opennms/bin/scvcli list
[main] INFO org.opennms.features.scv.jceks.JCEKSSecureCredentialsVault - Loading existing keystore from: scv.jce
postgres-admin
postgres
# /opt/opennms/bin/scvcli get postgres-admin
[main] INFO org.opennms.features.scv.jceks.JCEKSSecureCredentialsVault - Loading existing keystore from: scv.jce
Credentials for postgres-admin:
        Username: postgres
        Password: *********
# /opt/opennms/bin/scvcli get postgres
[main] INFO org.opennms.features.scv.jceks.JCEKSSecureCredentialsVault - Loading existing keystore from: scv.jce
Credentials for postgres:
        Username: opennms
        Password: *********
```
