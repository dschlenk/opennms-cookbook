# Description

A Chef cookbook to manage the installation and configuration of OpenNMS Horizon.
Current version supports Horizon release 33 on EL (redhat, rocky, oracle, etc) 9.

# Versions

Starting with OpenNMS Horizon 16, the MSB of the version of the cookbook matches the latest MSB of the version of OpenNMS Horizon it supports.
Starting with cookbook version 33.0.0 and OpenNMS Horizon 33.x.x, each cookbook version only officially supports the major Horizon release for which it is named.
The version of OpenNMS Horizon is selected via node attribute, defaulting to the latest release at the time the cookbook was released.
The balance of the version follows semantic versioning - minor version bumps for backwards-compatible new features, third level bumps for bugfix only releases.

# Requirements

* Chef or Cinc version 18.5.0 or later
* EL 9
* the public `postgresql` cookbook maintained by `sous-chefs`
* a compatible java runtime
* A Chef vault item that contains `postgres` credentials for the PostgreSQL server that will be used by OpenNMS Horizon

# Usage

Running the `default` recipe will install OpenNMS Horizon from the official repo with a mostly default configuration.
It will also execute `'$ONMS_HOME/bin/runjava -s` if `$ONMS_HOME/etc/java.conf` is not present and `$ONMS_HOME/bin/install -dis` if `$ONMS_HOME/etc/configured` is not present.

There are also a plethora of custom resources that you can use to do more in depth configuration management.

## Required Dependencies

The following dependencies must be satisfied for the `default` recipe to successfully converge.

### Java

You'll need to install a compatible Java runtime. Take a look at the fixture cookbook `openjdk17` in `test/fixtures/cookbooks` for an example.
Set `node['opennms']['jre_path']` to the home directory of a specific runtime if you cannot rely on the algorithm used by the `run_java -s` command to find the correct runtime.

### Postgres

An OpenNMS Horizon instance needs a PostgreSQL server to function. 
You must provide the node with a Chef vault named `node['opennms']['postgresql']['user_vault']` (defaults to `Chef::Config['node_name']`) that contains an item named `node['opennms']['postgresql']['user_vault_item']` (defaults to `postgres_users`) with objects named `postgres` and `opennms`, each with string values named `password`, like this:

```
{
  "id": "postgres_users",
  "postgres": {
    "password": "foo12345"
  },
  "opennms": {
    "password": "bar67890"
  }
}
```

The `postgres` role on the PostgreSQL server should exist and have the password set before the `default` recipe runs, but the `opennms` role should not yet exist.

The easiest way to satisfy this dependency is to use the `postgres` recipe in this cookbook.
It can be added to the run list prior to the `default` recipe.
When used, installation, configuration, and initialization of PostgreSQL 15 will occur via the PGDG repositories and the `postgres` password contained in the vault item described above will be applied to the `postgres` role.

## Recommended Features

Many of the following features are essential to the long term success of using this cookbook to manage your OpenNMS instance.

### Admin Password

You should absolutely not use the default admin password.
Store an item named `node['opennms']['users']['admin']['vault_item']` (default `opennms_admin_password`) in a vault named `node['opennms']['users']['admin']['vault']` (default `Chef::Config['node_name']`) with a value named `password`, and the cookbook will change it for you.

Once changed, you can also change it again later by adding a new value to that vault item named `new_password`.
Once the password is changed, the vault item is automatically updated to reflect the new state.

### Secure Credential Vault Password

Another thing you should not do is use the default secure credential vault password.
To set a custom one, simply populate a vault item named 'scv' with a value named `password` in a vault named `node['opennms']['scv']['vault']` (default `Chef::Config['node_name']`).
You can use a different item name by changing `node['opennms']['scv']['item']`.

Just like when doing this manually, there's no way to change the password after credentials are stored.
This means that you need to have this configured before you perform the initial installation, or delete the `scv.jce` file from `$OPENNMS_HOME/etc` to start fresh with a new SCV.

Note: If everything needed in the SCV is added via the custom resource `opennms_secret` provided by this cookbook, you could delete file `/opt/opennms/etc/scv.jce` and re-run Chef after changing the password in the appropriate vault item, although some temporary issues may occur during the time between when the SCV gets recreated and the secrets get added back to the SCV. The safest approach would be to:

1. Stop `opennms`
2. Change the password in the vault item
3. Run chef with a temporary run list that includes `opennms::base_templates` and your `opennms_secret` resources
4. Start `opennms`

### Upgrades

Starting with version 2.0.0 there is support for handling upgrades automatically.
It is disabled by default. To enable, set `node['opennms']['upgrade']` to `true`.
If this sounds like something you want to do, review the `upgrade` helper library.
It roughly translates to:

1. New RPMs are installed.
2. Are there any files named `*.rpmnew` in `$ONMS_HOME`? If so, overwrite the existing files with them.
3. Are there any files named `*.rpmsave` in `$ONMS_HOME`? If so, remove them.

`rpmnew` files are created when a newer version of a file exists, but it doesn't contain breaking changes.
OpenNMS won't start with these files present, and the rest of the converge should re-make the changes we want anyway, so we just remove the old file by replacing it with the new file.
 
`rpmsave` files happen when there's a config file that you have changed that was replaced with the new version, because not replacing it would prevent OpenNMS from working properly.
But since we're using Chef, we don't care about the old version as any changes we made to it previously will be redone with the appropriate custom resources and templates later in the converge.
Since OpenNMS won't start with these files in place we just remove them.

### Environment Variables and System Properties

You can add environment variables in `opennms.conf` by populating `node['opennms']['conf']['env']`. By default, we do so to set `START_TIMEOUT` to 20, like so:

```
default['opennms']['conf']['env'] = {
  'START_TIMEOUT' => 20,
}
```

Similarly, you can override Java system properties by populating `node['opennms']['properties']['files']`.
For instance, if you provide the vault item required to change the SCV password, the following object is added to this attribute:

```
'scv' => {
  'org.opennms.features.scv.jceks.key' => '<the password>'
}
```

This results in file `$OPENNMS_HOME/etc/opennms.properties.d/scv.properties` created with the contents `org.opennms.features.scv.jceks.key=the password`.

### RRDTool

To enable installation and configuration of RRDTool in place of the default time series engine JRobin, set `node['opennms']['rrdtool']['enabled']` to `true` or include the `rrdtool` recipe after the `default` recipe in your node's run list.

## Other Recipes

The recipes you may wish to include in your node list directly are:

* `opennms::default` Installs and configures OpenNMS Horizon with the standard configuration modified with any node attribute values changed from their defaults. 
  * Set `node['opennms']['plugin']['addl']` to an array of strings representing the names of the packages of the plugins you'd like installed.
* `opennms::rrdtool` Installs rrdtool and configures OpenNMS to use it instead of JRobin for performance metric storage.
* `opennms::postgres` Installs postgresql in a somewhat tuned manner (from PGDG). See `postres_install` recipe to figure out how the version is selected and override with node attributes if desired.

A few other recipes exist that aren't listed here. They are included by others when needed and are unlikely to be interesting for individual use.

## Custom Resources

A number of [custom resources are documented separately](documentation/README.md) 

### Provisioning Requisitions

These custom resources use the OpenNMS REST interface. As such, OpenNMS has to be running for the resources to converge. (I used the term 'import' rather than the correct term 'requisition'. I can type 'import' a lot faster than 'requisition').

* `opennms_foreign_source`: create a new foreign source optionally defining a scan interval (defaults to '1d').
* `opennms_service_detector`: add a service detector to a foreign source. Supports updating and deleting.
* `opennms_policy`: add a policy to a foreign source.
* `opennms_import`: Defines a requisition for a foreign source. This and all import\* custom resources include an option to synchronize the requisition - sync\_import.
* `opennms_import_node`: Add a node to a requisition including categories (array of strings) and assets (key/value hash pairs).
* `opennms_import_node_interface`: Add an interface to a node in a requisition.
* `opennms_import_node_interface_service`: Add a service to an interface on a node in a requisition.

### Custom Resources Wishlist

The following custom resources don't exist yet, but they should!

* `opennms_availability_report`: Manage availability reports in `$OPENNMS_HOME/etc/availability-reports.xml`.
* `opennms_chart`: Manage chart configs in `$OPENNMS_HOME/etc/chart-configuration.xml`.
* `opennms_sendmail`: Manage `sendmail-config` elements in `$OPENNMS_HOME/etc/javamail-configuration.xml`.
* `opennms_readmail`: Manage `readmail-config` elements in `$OPENNMS_HOME/etc/javamail-configuration.xml`.
* `opennms_end2endmail`: Manage `end2end-mail-config` elements in `$OPENNMS_HOME/etc/javamail-configuration.xml`.
* `opennms_jms_nb_destination`: Manage `destination` elements in `$OPENNMS_HOME/etc/jms-northbounder-configuration.xml`.
* `opennms_site_status_view`: Manage `view` elements in `$OPENNMS_HOME/etc/site-status-views.xml`.
* `opennms_translation_specs`: Manage `event-translation-spec` elements in `$OPENNMS_HOME/etc/translator-configuration.xml`.
* `opennms_correlation`: Manage a set of correlator rules
* `opennms_scriptd_engine`: Manage scriptd engines
* `opennms_scriptd_script`: Manage scriptd scripts

## Template Overview

Most configuration files that aren't managed with custom resources are templated and can be overridden with environment, role, or node attributes.  See the default attributes file for a list of configuration items that can be changed in this manner, or keep reading for a brief overview of each template available. Default attribute values set to `nil` mean that the file's default value is commented out in the original file and will remain so unless set to a non-nil value.

Each template can also be overridden in a wrapper cookbook by manipulating the appropriate node attribute. For example, if you've got a pretty heavily customized availability-reports.xml file, turn your custom version into a template (append `.erb` to the filename and optionally add some templating logic to it) and add it to `templates/default` in your wrapper cookbook. Then set `default['opennms']['db_reports']['avail']['cookbook']` to the name of your wrapper cookbook. You could also copy all of the templates from this cookbook to your wrapper, edit them all as desired and set `default['opennms']['default_template_cookbook']` to your wrapper cookbook's name.

If you want to skip some of the templates you can use `edit_resource` to set the action to :nothing. Example:

```
edit_resource(:template, '/opt/opennms/etc/service-configuration.xml') do {
  action :nothing
end
```

A similar technique can be done to selectively enable a specific template, even when you are running with non-base templates disabled:

```
edit_resource(:template, '/opt/opennms/etc/service-configuration.xml') do {
  action :create
end
```

### etc/availability-reports.xml

If you want to change the logo or default interval, count, hour or minute you can do so for either the calandar or classic report like so:
```
   {
     "opennms": {
       "db_reports": {
         "avail": {
           "cal": {
             "logo": "/path/to/an/other_logo.png"
           },
           "classic": {
             "count": 7
           }
         }
       }
     }
   }
```

### etc/chart-configuration.xml

Disable one of the three default charts by setting `severity_enabled`, `outages_enable` or `inventory_enable` to false in `node['opennms']['chart']`.

### etc/eventd-configuration.xml

Attributes are available in `node['opennms']['eventd']` to change global settings:

* TCPAddress (`tcp_address`)
* TCPPort (`tcp_port`)
* UDPAddress (`udp_address`)
* UDPPort (`udp_port`)
* receivers (`receivers`)
* socketSoTimeoutRequired (`sock_so_timeout_req` to true or false)
* socketSoTimeoutPeriod (`socket_so_timeout_period`)

### etc/javamail-configuration.properties

This file controls how OpenNMS sends email. This is not where you configure the mail monitor.
Attributes available in `node['opennms']['javamail_props']`. They follow the config file but with ruby style because the kids hate camel case I guess.

* org.opennms.core.utils.fromAddress (`from_address`) 
* org.opennms.core.utils.mailHost (`mail_host`)
* ...and so on.

### etc/javamail-configuration.xml

This is where you configure the mail monitor.
Attributes available in `node['opennms']['javamail_config'`. Unlike most of the templates, you can change every attribute and element in the default sendmail and receivemail elements since the defaults are useful to no one. Here's a list of the defaults which you definitely need to override if you want a mail monitor to work: 

```
default['opennms']['javamail_config']['default_read_config_name'] = "localhost"
default['opennms']['javamail_config']['default_send_config_name'] = "localhost"
default['opennms']['javamail_config']['default_read']['attempt_interval'] = 1000
default['opennms']['javamail_config']['default_read']['delete_all_mail']  = false
default['opennms']['javamail_config']['default_read']['mail_folder']      = "INBOX"
default['opennms']['javamail_config']['default_read']['debug']            = true
default['opennms']['javamail_config']['default_read']['properties']       = {'mail.pop3.apop.enable' => false, 'mail.pop3.rsetbeforequit' => false}
default['opennms']['javamail_config']['default_read']['host']             = "127.0.0.1"
default['opennms']['javamail_config']['default_read']['port']             = 110
default['opennms']['javamail_config']['default_read']['ssl_enable']       = false
default['opennms']['javamail_config']['default_read']['start_tls']        = false
default['opennms']['javamail_config']['default_read']['transport']        = "pop3"
default['opennms']['javamail_config']['default_read']['user']             = "opennms"
default['opennms']['javamail_config']['default_read']['password']         = "opennms"
default['opennms']['javamail_config']['default_send']['attempt_interval']   = 3000
default['opennms']['javamail_config']['default_send']['use_authentication'] = false
default['opennms']['javamail_config']['default_send']['use_jmta']           = true
default['opennms']['javamail_config']['default_send']['debug']              = true
default['opennms']['javamail_config']['default_send']['host']               = "127.0.0.1"
default['opennms']['javamail_config']['default_send']['port']               = 25
default['opennms']['javamail_config']['default_send']['char_set']           = "us-ascii"
default['opennms']['javamail_config']['default_send']['mailer']             = "smtpsend"
default['opennms']['javamail_config']['default_send']['content_type']       = "text/plain"
default['opennms']['javamail_config']['default_send']['encoding']           = "7-bit"
default['opennms']['javamail_config']['default_send']['quit_wait']          = true
default['opennms']['javamail_config']['default_send']['ssl_enable']         = false
default['opennms']['javamail_config']['default_send']['start_tls']          = false
default['opennms']['javamail_config']['default_send']['transport']          = "smtp"
default['opennms']['javamail_config']['default_send']['to']                 = "root@localhost"
default['opennms']['javamail_config']['default_send']['from']               = "root@[localhost]"
default['opennms']['javamail_config']['default_send']['subject']            = "OpenNMS Test Message"
default['opennms']['javamail_config']['default_send']['body']               = "This is an OpenNMS test message."
default['opennms']['javamail_config']['default_send']['user']               = "opennms"
default['opennms']['javamail_config']['default_send']['password']           = "opennms"
```

### jcifs.properties

This is useful for something I'm sure, but I don't know what. See the template or default attributes file for hints.

### etc/jms-northbounder-configuration.xml

Configures the JMS Northbounder introduced in version 17.0.0. See the default attributes under the `jms_nbi` key for configuration options. You may also need to set some JMS related attributes under the `properties` key.

### etc/enlinkd-configuration.xml

Attributes available in `node['opennms']['enlinkd']` that allow you change global settings like:

* threads
* initial\_sleep\_time
* snmp\_poll\_interval
* discovery\_link\_interval

### etc/log4j2.xml

This one is a little different. If you want to turn up logging for collectd, for instance, you'd set these override attributes:

```
default['opennms']['log4j2']['collectd'] = 'DEBUG'
```

### etc/site-status-views.xml

Do you actually populate the building column in assets or site field in provisioning reqs? Change the default site status view name and/or it's definition with these attributes: `node['opennms']['site_status_views']['default_view']['name']` and `node['opennms']['site_status_views']['default_view']['rows']` where `rows` is an array of single element hashes (to maintain order) like:

```
[
  {
    "Routers": "Routers"
  },
  {
    "Switches": "Switches"
  },
  {
    "Servers": "Servers"
  }
]
```

### etc/snmp-adhoc-graph.properties

Similar to other \*-graph.properties files, you can change the image format used in adhoc graphs by setting the attribute `node['opennms']['snmp_adhoc_graph']['image_format']` to `gif` or `jpg` rather than the default `png`. Note that the intersection of formats supported by both jrobin and rrdtool is `png`, though.

### etc/translator-configuration.xml

Remove one of the default event translations (http://www.opennms.org/wiki/Event_Translator) by setting an attribute in `node['opennms']['translator']` to false. They are:

* snmp\_link\_down
* snmp\_link\_up
* hyperic
* cisco\_config\_man
* juniper\_cfg\_change

You can also add additional `event-translation-spec` elements by populating `node['opennms']['translator']['addl_specs']` with an array of hashes where each has a key `uei` that has a string value and a key `'mappings'` (array of hashes each with key `'assignments'` (array of hashes that each contain keys `'name'` (string), `'type'` (string), `'default'` (string, optional), `'value'` (a hash that contains keys `'type'` (string), `'matches'` (string, optional), `'result'` (string), `'values'` (array of hashes that each contain keys `'type'` (string), `'matches'` (string, optional), `'result'` (string))))).

An example:

```
default['opennms']['translator']['addl_specs'] = [
  { 
    'uei ' => 'uei.opennms.org/internal/telemetry/clockSkewDetected',
    'mappings' => [
      {
        'assignments' => [
          {
            'name' => 'uei',
            'type' => 'field',
            'value' => {
              'type' => 'constant',
              'result' => 'uei.opennms.org/translator/telemetry/clockSkewDetected'
            }
          },
          {
            'name' => 'nodeid',
            'type' => 'field',
            'value' => {
              'type' => 'sql',
              'result' => 'SELECT n.nodeid FROM node n, ipinterface i WHERE n.nodeid = i.nodeid AND i.ipaddr = ? AND n.location = ?',
              'values' => [
                {
                  'type' => 'field',
                  'name' => 'interface',
                  'matches' => '.*',
                  'result' => '${0}'
                },
                {
                  'type' => 'parameter',
                  'name' => 'monitoringSystemLocation',
                  'matches' => '.*',
                  'result' => '${0}'
                }
              ]
            }
          },
        ]
      },
    ]
  },
]
```

would be how to express the following `event-translation-spec`:

```
    <event-translation-spec uei="uei.opennms.org/internal/telemetry/clockSkewDetected" >
      <mappings>
        <mapping>
          <assignment name="uei" type="field" >
            <value type="constant" result="uei.opennms.org/translator/telemetry/clockSkewDetected" />
          </assignment>
          <assignment name="nodeid" type="field" >
            <value type="sql" result="SELECT n.nodeid FROM node n, ipinterface i WHERE n.nodeid = i.nodeid AND i.ipaddr = ? AND n.location = ?" >
              <value type="field" name="interface"  matches=".*" result="${0}" />
              <value type="parameter" name="monitoringSystemLocation" matches=".*" result="${0}" />
            </value>
          </assignment>
        </mapping>
      </mappings>
    </event-translation-spec>
```

### etc/trapd-configuration.xml

Two attributes available: `port` and `new_suspect` in `node['opennms']['trapd']` that allow you to configure the port to listen for traps on (default 10162) and whether or not to create newSuspect events when a trap is received from an unmanaged host (default false).

### etc/xmpp-configuration.xml

Configure notifications to be sent via XMPP (aka Jabber, GTalk) with these attributes in `node['opennms']['xmpp']`:

* server
* service\_name
* port
* tls
* sasl
* self\_signed\_certs
* truststore\_password
* debug
* user
* pass

### Others

See the template and default attributes source for more details on using these templates:

* etc/microblog-configuration.xml.erb
* etc/modemConfig.properties.erb
* etc/nsclient-datacollection-config.xml.erb
* etc/reportd-configuration.xml.erb
* etc/rtc-configuration.xml.erb
* etc/snmp-interface-poller-configuration.xml.erb
* etc/syslog-northbounder-configuration.xml.erb
* etc/vacuumd-configuration.xml.erb
* etc/vmware-cim-datacollection-config.xml.erb
* etc/vmware-datacollection-config.xml.erb

# Copyright and License

Copyright 2014-2025 ConvergeOne Holding Corp.

Released under Apache 2.0 license. See LICENSE for details.

OpenNMS and OpenNMS Horizon are &#8482; and &copy; The OpenNMS Group, Inc.

# Author

David Schlenk (<dschlenk@onec1.com>)

# Development

Tests consist of:

* Style Checks using cookstyle
* InSpec tests for all the custom resources.

CircleCI executes cookstyle and the default kitchen suite.

Pull requests welcome!
