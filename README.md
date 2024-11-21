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

The `postgres` role on the server should exist and have the password set before the `default` recipe runs, but the `opennms` role should not yet exist.

The easiest way to satisfy this dependency is to use the `postgres` recipe in this cookbook.
It can be added to the run list prior to the `default` recipe.
Installation, configuration, and initialization of PostgreSQL 15 will occur via the PGDG repositories and the `postgres` password contained in the vault item described above will be applied to the `postgres` role.

## Useful Features

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
OpenNMS won't start with these files present, and the rest of the converge will make the changes we want anyway, so we just remove the old file by replacing it with the new file.
 
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

### Other Recipes

The recipes you may wish to include in your node list directly are:

* `opennms::default` Installs and configures OpenNMS Horizon with the standard configuration modified with any node attribute values changed from their defaults. 
  * Set `node['opennms']['plugin']['addl']` to an array of strings representing the names of the packages of the plugins you'd like installed.
* `opennms::rrdtool` Installs rrdtool and configures OpenNMS to use it instead of JRobin for performance metric storage.
* `opennms::postgres` Installs postgresql in a somewhat tuned manner (from PGDG). See `postres_install` recipe to figure out how the version is selected and override with node attributes if desired.

A few other recipes exist that aren't listed here. They are included by others when needed and are unlikely to be interesting for individual use.

# Custom Resources

## SNMP Config

* [opennms\_snmp\_config](documentation/snmp_config.md)
* [opennms\_snmp\_config\_definition](documentation/snmp_config_definition.md)
* [opennms\_snmp\_config\_profile](documentation/snmp_config_profile.md)

## Events, Alarms, and Notifications

* [opennms\_eventconf](documentation/eventconf.md)
* [opennms\_event](documentation/event.md)

## Service Assurance

* [Service assurance resource documentation](documentation/service_assurance.md)

## Performance Management and Thresholding

* [Data collection resource documentation](documentation/datacollection.md)

## Syslog configuration

# [opennms\_syslog\_file](documentation/syslog.md)

## User and Group Management

## Provisioning and Discovery

## Presentation

## Administration

* [opennms\_secret](documentation/secret.md)

TODO: update and move the rest of these to individual files

#### Users, Groups and Roles

* `opennms_user`: add a user. Uses the REST API. Supports changes, but requires all parameters to be included, not just identity + things you want to change.
* `opennms_group`: add a group and populate it with users. You can even set the default SVG map and duty schedules.
* `opennms_role`: add a role.
* `opennms_role_schedule`: Add schedules to a role.

#### Discovery

* `opennms_disco_specific`: add a specific IP to be discovered.
* `opennms_disco_range`: add a include or exclude range of IPs for discovery.
* `opennms_disco_url`: add a include-url to discovery and if it's a file deploy it where specified.

#### Provisioning Requisitions

These custom resources use the OpenNMS REST interface. As such, OpenNMS has to be running for the resources to converge. (I used the term 'import' rather than the correct term 'requisition'. I can type 'import' a lot faster than 'requisition').

* `opennms_foreign_source`: create a new foreign source optionally defining a scan interval (defaults to '1d').
* `opennms_service_detector`: add a service detector to a foreign source. Supports updating and deleting.
* `opennms_policy`: add a policy to a foreign source.
* `opennms_import`: Defines a requisition for a foreign source. This and all import\* custom resources include an option to synchronize the requisition - sync\_import.
* `opennms_import_node`: Add a node to a requisition including categories (array of strings) and assets (key/value hash pairs).
* `opennms_import_node_interface`: Add an interface to a node in a requisition.
* `opennms_import_node_interface_service`: Add a service to an interface on a node in a requisition.

#### Notifications

* `opennms_notification_command`: Create a new command in notificationCommands.xml.
* `opennms_destination_path`: creates a destination path element in destinationPaths.xml. Requires at a minimum a single target which can be defined with the following custom resource.
* `opennms_target`: Add a target or escalate target to a destination path (defined either in the default config or with the above custom resource).
* `opennms_notification`: Create notification elements in notifications.xml.  Supports updating and deleting (action :delete).

#### Statistics Reports

See `opennms::example_statsd` for example usage of these custom resources. 

* `opennms_statsd_package`: create a new package optionally with a filter in statsd-configuration.xml.
* `opennms_statsd_report`: add a report to a package in statsd-configuration.xml.

#### Graphs

* `opennms_collection_graph_file`: Add a cookbook file containing graph definitions (perhaps generated by the mib compiler) to $ONMS_HOME/etc/snmp-graph.properties.d/. Use the `source` parameter to load the file from a URL, otherwise assumes cookbook file.
* `opennms_collection_graph`: Add a new graph definition to the main (bad idea), new or an existing graph file.
* `opennms_response_graph`: Add a response graph to $ONMS_HOME/etc/response-graph.properties. Since there's a pretty well defined pattern to these, you can define these with just the name of the data source and it'll create a graph with min, max and average response times.

#### Web UI

There are a couple custom resources for managing the Web UI. All of these support updating.

* `opennms_avail_category`: Define categories for use in the Availability box on the main page (and the Summary dashlet in Ops Board).
* `opennms_avail_view`: Define the list of categories in each view sections displayed in the Availability box on the main page (and the Summary dashlet in Ops Board).
* `opennms_wallboard`: Create a wallboard.
* `opennms_dashlet`: Add a dashlet to a wallboard.
* `opennms_surveillance_view`: Manage surveillance views used in the legacy dashboard, Ops Board, and optionally on the front page. Note: does not verify that the categories you reference exist, because there's no ReST interface (yet).

### Template Overview

Most configuration files are templated and can be overridden with environment, role, or node attributes.  See the default attributes file for a list of configuration items that can be changed in this manner, or keep reading for a brief overview of each template available. Default attribute values set to `nil` mean that the file's default value is commented out in the original file and will remain so unless set to a non-nil value.

Each template can also be overridden in a wrapper cookbook by manipulating the appropriate node attribute. For example, if you've got a pretty heavily customized collectd-configuration.xml file and you don't want to move to the custom resource/library cookbook workflow, turn your custom version into a template (append `.erb` to the filename and optionally add some templating logic to it) and add it to `templates/default` in your wrapper cookbook. Then set `default[:opennms][:collectd][:cookbook]` to the name of your wrapper cookbook. You could also copy all of the templates from this cookbook to your wrapper, edit them all as desired and set `default[:opennms][:default_template_cookbook]` to your wrapper cookbook's name.

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

#### etc/availability-reports.xml

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

#### etc/categories.xml

Default categories can be modified by doing things like

```
   {
     "opennms": {
       "categories": {
         "web": {
           "services": [
             "HTTP",
             "HTTPS",
             "HTTP-8080",
             "HTTP-8000",
             "HTTP-8980"
           ]
         }
       }
     }
   }
```

That'll leave the defaults for everything except overwrite the list of services in the `web` category.
The names of the categories are: 'overall', 'interfaces', 'email', 'web', 'jmx', 'dns', 'db', 'other', 'inet'.
The defaults are nil, which leaves the defaults as is. Override with false to disable.

#### etc/chart-configuration.xml

Disable one of the three default charts by setting `severity_enabled`, `outages_enable` or `inventory_enable` to false in `node['opennms']['chart']`.

#### etc/collectd-configuration.xml

Use the `node['opennms']['collectd']['threads']` attribute to change the number of threads (duh). There are also attributes for each default package. As of 1.12.5 those are: vmware3, vmware4, vmware5, example1. To modify one of those, for example, to change the IPv4 include range in the example1 package, you would do:
```
   {
     "opennms": {
       "collectd": {
           "example1": {
             "ipv4_range": {
                 "begin": "10.0.1.0",
                 "end": "10.0.1.255"
             }
           }
       }
     }
   }
```

That leaves most of the example1 package as default. Set a package's `enabled` attribute to false if you want to completely remove that package. You can also do that for specific services in that package. See the template for more options.

#### etc/datacollection-config.xml

You can override some settings like:

```
   {
     "opennms": {
       "datacollection": {
         "default": {
           "snmpStorageFlag": "all"
         }
       }
   }
```

Or maybe you don't have any Dell gear:

```
   {
     "opennms": {
       "datacollection": {
         "default": {
           "dell": false
         }
       }
     }
   }
```

You can also remove one of the default snmp-collections, or change the step and RRA definitions.

#### etc/discovery-configuration.xml

Attributes are available in `node['opennms']['discovery']` to change global settings:

* threads (`threads`)
* packets-per-second (`pps`)
* initial-sleep-time (`init_sleep_ms`)
* restart-sleep-time (`restart_sleep_ms`)
* retries (`retries`)
* timeout (`timeout`)

#### etc/eventd-configuration.xml

Attributes are available in `node['opennms']['eventd']` to change global settings:

* TCPAddress (`tcp_address`)
* TCPPort (`tcp_port`)
* UDPAddress (`udp_address`)
* UDPPort (`udp_port`)
* receivers (`receivers`)
* socketSoTimeoutRequired (`sock_so_timeout_req` to true or false)
* socketSoTimeoutPeriod (`socket_so_timeout_period`)

#### etc/events-archiver-configuration.xml

Attributes are available in `node['opennms']['events_archiver']` to change global settings:

* archiveAge (`age`)
* separator (`separator`)

#### etc/javamail-configuration.properties

This file controls how OpenNMS sends email. This is not where you configure the mail monitor.
Attributes available in `node['opennms']['javamail_props']`. They follow the config file but with ruby style because the kids hate camel case I guess.

* org.opennms.core.utils.fromAddress (`from_address`) 
* org.opennms.core.utils.mailHost (`mail_host`)
* ...and so on.

#### etc/javamail-configuration.xml

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

#### jcifs.properties

This is useful for something I'm sure, but I don't know what. See the template or default attributes file for hints.

#### etc/jdbc-datacollection-config.xml 

Similar to other datacollection-config.xml files, you can change the RRD repository, step, RRA definitions and disable default collections and their queries.

#### etc/jms-northbounder-configuration.xml

Configures the JMS Northbounder introduced in version 17.0.0. See the default attributes under the `jms_nbi` key for configuration options. You may also need to set some JMS related attributes under the `properties` key.

#### etc/jmx-datacollection-config.xml

Similar to other datacollection-config.xml files, you can change the RRD repository, step, RRA definitions and disable default collections and their mbeans. In the JBoss collection you can specify a JMS queue and/or topic to collect stats on. See the template and default attributes for details. 

#### etc/linkd-configuration.xml & etc/enlinkd-configuration.xml

Attributes available in `node['opennms']['linkd']` that allow you change global settings like:

* threads
* initial_sleep_time
* snmp_poll_interval
* discovery_link_interval

You can also turn off various kinds of detection, like for `iproutes`, set any of these to false to remove them from the file:

* netscreen
* cisco
* darwin

Finally there's the package element at the end of the file that you can configure with these attributes:

```
default['opennms']['linkd']['package']                      = "example1"
default['opennms']['linkd']['filter']                       = "IPADDR != '0.0.0.0'"
default['opennms']['linkd']['range_begin']                  = "1.1.1.1"
default['opennms']['linkd']['range_end']                    = "254.254.254.254"
```

#### etc/log4j2.xml

This one is a little different. If you want to turn up logging for collectd, for instance, you'd set these override attributes:

```
default['opennms']['log4j2']['collectd'] = 'DEBUG'
```

#### magic-users.properties

The rtc username and password are populated from the values set in `node['opennms']['properties']['rtc']['username']` and `node['opennms']['properties']['rtc']['password']`. TODO: Generate passwords during install! Other attributes available for configuration are:

```
default['opennms']['magic_users']['admin_users']     = "admin"
default['opennms']['magic_users']['ro_users']        = ""
default['opennms']['magic_users']['dashboard_users'] = ""
default['opennms']['magic_users']['provision_users'] = ""
default['opennms']['magic_users']['remoting_users']  = ""
default['opennms']['magic_users']['rest_users']      = "iphone"
```

Note that this file isn't a thing in versions >= 19.

#### etc/map.properties

Do you love the old SVG maps but are a contrarian when it comes to color schemes? Have we got the template for you! I guess also useful for translating labels?  Check out the default attributes for details on what you can change.

#### etc/notifd-configuration.xml

Is ignorance about your broken network in fact bliss?  Shut off notifd by setting `node['notifd']['status']` to "off" and find out. Don't know what `match-all` even means? Find out by setting `node['opennms']['notifd']['match_all']` to false. (It controls whether only the first matching notification is used or not). You can also disable any of the default auto-acknowledge elements with `node['notifd']['auto_ack']['service_unresponsive|service_lost|interface_down|widespread_outage']`.

#### etc/notificationCommands.xml

Turn off one of the default notification commands by setting one of the attributes in `node['opennms']['notification_commands']` to false:

* java_pager_email
* java_email
* xmpp_message
* xmpp_group_message
* irc_cat
* call_work_phone
* call_mobile_phone
* call_home_phone
* microblog_update
* microblog_reply
* microblog_dm

#### etc/notifications.xml

These attributes:

* enabled
* status
* rule
* destination_path
* description
* text_message
* subject
* numeric_message

can be overridden to alter any of these default notifications:

* interface_down
* node_down
* node_lost_service
* node_added
* interface_deleted
* high_threshold
* low_threshold

in `node['opennms']['notifications']`.

#### etc/response-graph.properties

Change the image format from the default `png` to `gif` or `jpg` (if using jrobin or you like broken images) with `node['response_graph']['image_format']`. Font sizes can also be changed with `node['response_graph']['default_font_size']` and `node['response_graph']['title_font_size']` (defaults are 7 and 10 respectively). Setting these attributes to false removes them from the file:

* icmp
* avail
* dhcp
* dns
* http
* http_8080
* http_8000
* mail
* pop3
* radius
* smtp
* ssh
* jboss
* snmp
* ldap
* strafeping
* memcached_bytes
* memcached_bytesrw
* memcached_uptime
* memcached_rusage
* memcached_items
* memcached_conns
* memcached_tconns (off by default)
* memcached_cmds
* memcached_gets
* memcached_evictions
* memcached_threads
* memcached_struct
* ciscoping_time

If you changed the count of pings in the strafer polling package to a value higher than 20, you'll also need to define additional colors for the strafeping graph, like `default['opennms']['response_graph']['strafeping_colors'][21] = ["#f5f5f5"]`. If you want to add a STACK to the graph for another ping number (defaults to 1-4,10,19) add a second color to that attribute's value array, like `default['opennms']['response_graph']['strafeping_colors'][21] = ["#f5f5f5","#050505"]`. 

#### etc/rrd-configuration.properties

Tobi enthusiasts will want to set some attributes in `node['opennms']['rrd']` to switch from jrobin to rrdtool:

```
{
  "opennms":
  {
    "rrd":
    {
      "strategy_class": "org.opennms.netmgt.rrd.rrdtool.JniRrdStrategy",
      "interface_jar":  "/usr/share/java/jrrd.jar",
      "jrrd":           "/usr/lib/libjrrd.so"
    }
  }
}
```

There's now a recipe that does this for you, named rrdtool. Probably just use that. 

If you're a unique snowflake you can change a multitude of queue settings or change the jrobin backend factory, but unless you know what you're doing that's probably a mistake. Look at the template for details if you're curious.

Finally, to turn on the Google protobuf export thing described at http://www.opennms.org/wiki/Performance_Data_TCP_Export, set these attributes accordingly:

```
default['opennms']['rrd']['usetcp']      = true
default['opennms']['rrd']['tcp']['host'] = 10.0.0.1
default['opennms']['rrd']['tcp']['port'] = 9100     # Hope that's a JetDirect compatible network interface!
```

#### etc/site-status-views.xml

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

#### etc/snmp-adhoc-graph.properties

Similar to other *-graph.properties files, you can change the image format used in adhoc graphs by setting the attribute `node['opennms']['snmp_adhoc_graph']['image_format']` to `gif` or `jpg` rather than the default `png`. Note that the intersection of formats supported by both jrobin and rrdtool is `png`, though.

#### etc/snmp-graph.properties & snmp-graph.properties.d/*

Similar to other *-graph.properties files, you can change the image format used in predefined graphs by setting the attribute `node['opennms']['snmp_adhoc_graph']['image_format']` to `gif` or `jpg` rather than the default `png`. Note that the intersection of formats supported by both jrobin and rrdtool is `png`, though.
You can also set the default and title font sizes like you can in the response graphs. Since these graphs are now split up by manufacturer, you can disable graphs for a manufacturer like you can in snmp-datacollection-config.xml. This example disables Dell graphs:

```
{
  "opennms":
  {
    "snmp_graph":
    {
      "dell_openmanage": false,
      "dell_rac": false
    }
  }
}
```

Note that this doesn't delete that file, it merely comments out the `reports=...` line(s) in the file.

You can also change the default KSC graph by setting `node['snmp_graph']['default_ksc_graph']` to the name of a valid graph.

Also note that releases that use backshift instead of displaying generated images (17+) won't be affected by these changes.

#### etc/statsd-configuration.xml

You can remove either of the default packages or an individual report by setting attributes in `node['opennms']['statsd']['PACKAGE_NAME']['REPORT_NAME']` to false. Packages and their reports are:

* example1
  * top_n
* response_time_reports
  * top_10_weekly
  * top_10_this_month
  * top_10_last_month
  * top_10_this_year

#### etc/threshd-configuration.xml

Like everything else that has packages, filters, ranges and services, you can override attributes to tune the defaults. See the template and default attributes for details. You can also configure the number of threads with `node['opennms']['threshd']['threads']` (default is 5).

#### etc/thresholds.xml

Change the RRD repository location or disable threshold groups with the `enabled` and `rrd_repository` attributes in `node['opennms']['thresholds']['GROUP']` where group can be:

* mib2
* cisco
* hrstorage
* netsnmp
* netsnmp_memory_linux
* netsnmp_memory_nonlinux
* coffee

#### etc/translator-configuration.xml

Remove one of the default event translations (http://www.opennms.org/wiki/Event_Translator) by setting an attribute in `node['opennms']['translator']` to false. They are:

* snmp_link_down
* snmp_link_up
* hyperic
* cisco_config_man
* juniper_cfg_change

#### etc/trapd-configuration.xml

Two attributes available: `port` and `new_suspect` in `node['opennms']['trapd']` that allow you to configure the port to listen for traps on (default 162) and whether or not to create newSuspect events when a trap is received from an unmanaged host (default false).

#### etc/users.xml

Change your admin password by setting `node['opennms']['users']['admin']['password']` to whatever hashed value of your password OpenNMS uses. Uppercase MD5? In the future we'll generate one during install. You can also change the name and user_comments attributes, I guess.

#### etc/viewsdisplay.xml

Another web UI XML file, this one controls which categories are displayed in the availability box on the main landing page. Once a custom resource exists you'll be able to add sections, but until then you can disable any of the existing categories by setting one of these attributes in `node['opennms']['web_console_view']` to false:

* network_interfaces
* web_servers
* email_servers
* dns_dhcp_servers
* db_servers
* jmx_servers
* other_servers

#### etc/xmpp-configuration.xml

Configure notifications to be sent via XMPP (aka Jabber, GTalk) with these attributes in `node['opennms']['xmpp']`:

* server
* service_name
* port
* tls
* sasl
* self_signed_certs
* truststore_password
* debug
* user
* pass

#### Others

See the template and default attributes source for more details on using these templates:

* etc/microblog-configuration.xml.erb
* etc/model-importer.properties.erb
* etc/modemConfig.properties.erb
* etc/nsclient-datacollection-config.xml.erb
* etc/poller-configuration.xml.erb
* etc/provisiond-configuration.xml.erb
* etc/remedy.properties.erb
* etc/reportd-configuration.xml.erb
* etc/rtc-configuration.xml.erb
* etc/smsPhonebook.properties.erb
* etc/snmp-interface-poller-configuration.xml.erb
* etc/support.properties.erb
* etc/surveillance-views.xml.erb
* etc/syslog-northbounder-configuration.xml.erb
* etc/syslogd-configuration.xml.erb
* etc/vacuumd-configuration.xml.erb
* etc/vmware-cim-datacollection-config.xml.erb
* etc/vmware-datacollection-config.xml.erb
* etc/wmi-datacollection-config.xml.erb
* etc/xml-datacollection-config.xml.erb
* etc/xmlrpcd-configuration.xml.erb

Copyright and License
=======

Copyright 2014-2024 ConvergeOne Holding Corp.

Released under Apache 2.0 license. See LICENSE for details.

OpenNMS and OpenNMS Horizon are &#8482; and &copy; The OpenNMS Group, Inc.

Author
======
David Schlenk (<dschlenk@onec1.com>)

Development
===========

So far, tests consist of:

* Style Checks using foodcritic and rubocop. 
* InSpec tests for all the custom resources.

The default rake task will run the style checks. 

Pull requests welcome!
