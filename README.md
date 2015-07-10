Description
===========

A Chef cookbook to manage the installation and configuration of OpenNMS.
Current version of templates are based on OpenNMS release 16.0.2

Versions
========

Starting with OpenNMS 16, the MSB of the version of the cookbook matches the MSB of the version of OpenNMS it is meant to support. 


Requirements
============

* Chef 11.x+
* CentOS 6.x. Debian/Ubuntu support shouldn't be too hard to do - if anyone wants to head that up let me know. 
* Either use Berkshelf to satisfy dependencies or manually acquire the following cookbooks: 
  * yum
  * hostsfile
  * build-essential
* In OpenNMS 17+ you will need a newer PostgreSQL than CentOS 6.x provides. Also, using Chef to install PostgreSQL makes tuning a lot easier. While there's no explicit dependency, you most likely will want some combination of recipes from the `postgresql` cookbook.  See Usage for details.

Usage
=====

Running the default recipe will install OpenNMS 16.0.2 (or a custom version using the attribute `node[:opennms][:version]`) on CentOS 6.x from the official repo with the default configuration. It will also execute `'$ONMS_HOME/bin/runjava -s` if `$ONMS_HOME/etc/java.conf` is not present and `$ONMS_HOME/bin/install -dis` if `$ONMS_HOME/etc/configured` is not present.

There are two primary ways to use this cookbook: as an application cookbook or library cookbook. If you simply want to tweak a few settings to the default OpenNMS configuration, you can use the `default` recipe of this cookbook directly and modify node attributes to suit your needs. There are also a plethora of LWRPs that you can use to do more in depth customizations. If you go that route I recommend starting with the `notemplates` recipe and then using those LWRPs (and maybe a few of the templates in this cookbook) to define your run list. If your node's run list contains both the template and a resource that manages the same file you'll end up with a lot of churn during the chef client run, which is a waste of time and will probably cause unnecessary restarts of OpenNMS. 

Template resources for daemons that support configuration changes without a restart will automatically send the proper event to activate changes. Add `notifies` to your resource for similar funcationality when using the LWRPs from this cookbook. See the example recipe for each LWRP for details.

### Java (Optional)

You might also want to check out the community java (https://github.com/socrata-cookbooks/java) and almost definitely postgresql (https://github.com/hw-cookbooks/postgresql) cookbooks. Here's an example of each:

At this time the OpenNMS yum repo includes a modern Oracle JDK. Since Oracle likes to change license terms on a whim (and their RPM doesn't necessarily set up things (like alternatives priorities) to your liking), you might want to get ahead of the curve and manage installing the JDK yourself. Here's an example using [dschlenk's fork](https://github.com/dschlenk/java/) of the community java cookbook. 

First, you need to download the appropriate RPM(s) from Oracle and make a yum repo available to your nodes. For example, on a CentOS server with Apache httpd installed you could do:

```
# mkdir /var/www/html/oracle-java
# mv jdk*.rpm /var/www/html/oracle-java/
# createrepo /var/www/html/oracle-java
# chown -R apache:apache /var/www/html/oracle-java
```

Next, acquire the java cookbook in the link above by either cloning the repo and uploading to your Chef server or using Berkshelf or another cookbook management tool that can talk to git repos. 

Set the following attributes (in a role, environement, or in a wrapper cookbook - up to you):

```
node['java']['oracle']['accept_oracle_download_terms'] = true
node['java']['install_flavor'] = 'oracle_rpm'
node['java']['oracle_rpm']['type'] = 'jdk'
node['java']['oracle_rpm']['package_name'] = 'jdk1.8.0_40' # match the current JDK version you've downloaded and set up a yum repo for
node['java']['alternatives_priority'] = 180040
node['java']['jdk_version'] = 8
node['java']['set_etc_environment'] = true
node['java']['oracle']['jce']['enabled'] = true
```

Add a `yum_repository` resource to your node or role's run list, like so:

```
yum_repository 'oracle-java' do
  description 'mirror of oracle java RPM packages'
  baseurl 'URL_TO_YOUR_YUM_REPO'
  gpgcheck false
  action :create
end
```

Then add the 'java::default' recipe to your run list. 

### Postgresql

Include the client, server, contrib, config_initdb, config_pgtune recipes 
(in that order) in your run list. Then use these attributes for a fairly well
tuned config:

```
node[:postgresql][:enable_pgdg_yum] = true,
node[:postgresql][:version] = '9.3',
node[:postgresql][:dir] = '/var/lib/pgsql/9.3/data',
node[:postgresql][:pg_hba] = { :addr => '' :user => 'all', :type => 'local', :method => 'trust', :db => 'all' }
node[:postgresql][:pg_hba] = { :addr => '127.0.0.1/32', :user => 'all', :type => 'host', :method => 'trust', :db => 'all'}
node[:postgresql][:pg_hba] = { :addr => '::1/128', :user => 'all', :type => 'host', :method => 'trust', :db => 'all' }
node[:postgresql][:config][:checkpoint_timeout] = '15min'
node[:postgresql][:config][:data_directory] = '/var/lib/pgsql/9.3/data'
node[:postgresql][:config][:autovacuum] = 'on'
node[:postgresql][:config][:track_activities] = 'on'
node[:postgresql][:config][:track_counts]  = 'on'
node[:postgresql][:config][:shared_preload_libraries] = 'pg_stat_statements'
node[:postgresql][:config][:vacuum_cost_delay] = 50
node[:postgresql][:config_pgtune][:max_connections] = 160
node[:postgresql][:contrib][:extensions] = ['pageinspect', 'pg_buffercache', 'pg_freespacemap', 'pgrowlocks', 'pg_stat_statements', 'pgstattuple']
node[:postgresql][:client][:packages] = ["postgresql93", "postgresql93-contrib", "postgresql93-devel"]
node[:postgresql][:server][:packages] = ["postgresql93-server"]
node[:postgresql][:server][:service_name] = "postgresql-93
```

### Recommended Tweaks
There are also a couple OpenNMS attributes you'll probably want to override at a minimum: 

### opennms.conf

```
node[:opennms][:conf][:start_timeout] = 20
node[:opennms][:conf][:heap_size] = 1024
node[:opennms][:conf][:addl_mgr_opts] = '-XX:+UseConcMarkSweepGC -XX:MaxMetaspaceSize=512m'
```

### Upgrades

Starting with version 2.0.0 there is now experimental support for handling 
upgrades automatically. Use at your own risk. It is disabled by default. 
To enable, set `node['opennms']['upgrade']` to true. If this sounds like 
something you want to do, review the `upgrade` recipe. It roughly translates to:

* New RPM is installed. 
* Are there any files named `*.rpmnew` in `$ONMS_HOME/etc` or `$ONMS_HOME/jetty-webapp`? If so, overwrite the existing files with them. 
* Are there any files named `*.rpmsave` in `$ONMS_HOME/etc` or `$ONMS_HOME/jetty-webapp`? If so, remove them.

`rpmsave` files happen when there's a config file that you have changed that 
was replaced with the new version because not replacing it would prevent 
OpenNMS from working properly. But since we're using Chef, we don't care about
the old version as any changes we made to it previously will be redone with the
appropriate LWRP(s) or templates later in the converge. Since OpenNMS won't 
start with these files in place we just remove them. 

Similarly, `rpmnew` files are created when a newer version of a file exists, but 
it doesn't contain breaking changes. Just like `rpmsave` files, OpenNMS won't 
start with these files present, and the rest of the converge will make the changes
we want anyway, so we just overwrite the old file with the `rpmnew` version. 
 
### Recipes

* `opennms::default` Installs and configures OpenNMS with the standard configuration modified with any node attribute values changed from their defaults.
* `opennms::notemplates` Everything default does except minimal templates are used - etc/opennms.conf, etc/opennms.properties and etc/log4j2.xml. Use this recipe if you intend to use any of the LWRPs in this cookbook.

#### Deprecated
The following recipes are deprecated. The preferred method to install these packages is by setting `node[:opennms][:plugin][:nsclient]` and/or `node[:opennms][:plugin][:xml]` to true. All these recipes do now is set those attributes at the default level. 
* `opennms::nsclient` installs the optional nsclient data collection plugin and uses the template for etc/nsclient-datacollection-config.xml. 
* `opennms::xml` installs the optional xml data collection plugin and uses the template for etc/xml-datacollection-config.xml. 

### LWRPs

As a general rule these LWRPs support a single action: `create` and many of them behave more like `create_if_missing` does in other cookbooks. In other words, updating is generally not supported. Exceptions are noted, and this behavior may change in future releases. 

Also, there are example recipes in the cookbook for most every LWRP named `opennms::example_<LWRP_NAME>`. Eventually these will become tests. 

The list of implemented LWRPs is as follows: 

#### Users, Groups and Roles

* `opennms_user`: add a user. Uses the REST API. 
* `opennms_group`: add a group and populate it with users. You can even set the default SVG map and duty schedules.
* `opennms_role`: add a role.
* `opennms_role_schedule`: Add schedules to a role. See an example for this and the role LWRP in recipe `opennms::example_role`.

#### Discovery

* `opennms_disco_specific`: add a specific IP to be discovered. 
* `opennms_disco_range`: add a include or exclude range  discovery. 
* `opennms_disco_url`: add a include-url to discovery and if it's a file deploy it where specified. 

#### Provisioning Requisitions

These LWRPs use a cookbook library named Provision that I wrote to perform the work using the OpenNMS REST interface. As such, OpenNMS has to be running for the resources to converge. Also you'll notice that I used the term 'import' rather than the correct term 'requisition'. I can type 'import' a lot faster than 'requisition'. ;)

* `opennms_foreign_source`: create a new foreign source optionally defining a scan interval (defaults to '1d'). 
* `opennms_service_detector`: add a service detector to a foreign source.
* `opennms_policy`: add a policy to a foreign source. 
* `opennms_import`: Defines a requisition for a foreign source. This and all import* LWRPs include an option to synchronize the requisition - sync_import. 
* `opennms_import_node`: Add a node to a requisition including categories (array of strings) and assets (key/value hash pairs). 
* `opennms_import_node_interface`: Add an interface to a node in a requisition. 
* `opennms_import_node_interface_service`: Add a service to an interface on a node in a requisition. 

#### Events

* `opennms_eventconf`: adds an event-file element to events in etc/eventconf.xml. 
* `opennms_event`: adds an event element to events in target eventconf file `file`. Not all elements from the eventconf schema are implemented, but the ones that seem to actually exist in the wild are. See resource for details and recipes `example_event` and `example_threshold` for example usage.
* `opennms_send_event`: creates an actual instance of an event using the `send-event.pl` script in `$ONMS_HOME/bin`. Used by the `send_events` recipe, which is included by `default` and `notemplates` recipes to cause config file reloads to take place when template resources make changes or an LWRP sends a notification.

#### Notifications

* `opennms_notification_command`: Create a new command in notificationCommands.xml. 
* `opennms_destination_path`: creates a destination path element in destinationPaths.xml. Requires at a minimum a single target which can be defined with the following LWRP. 
* `opennms_target`: Add a target or escalate target to a destination path (defined either in the default config or with the above LWRP). 
* `opennms_notification`: Create notification elements in notifications.xml. 
* `opennms_notifd_autoack`: Create a auto acknowledge up/down pair in notifd-configuration.xml

#### Node Service Credential Configuration

These LWRPs allow you to define the credentials necessary to connect to services on monitored nodes. These are some of the few that currently implement updating and deleting. Action `:create` will update if changes are detected but `:create_if_missing` will do nothing. To determine if a resource needs to be updated or deleted, existance is determined by all definition element attributes being equal (so all resource attributes except `ranges`, `specifics`, `ip_matches` and `position`). 

If an update occurs, the values contained in the new resource will be used. Note that all `range`, `specific` and `ip-match` elements that exist currently in the definition will be removed before the new elements are added. 

Currently implemented are: 

* `opennms_snmp_config_definition`: add a definition element to snmp-config.xml. 
* `opennms_wmi_config_definition`: add a definition element to wmi-config.xml.

#### Polling

* `opennms_poller_package`: add a package to etc/poller-configuration.xml. Note that an instance of this resource without use of an accompanying `opennms_poller_service` resource will result in a failure to start opennms. 
* `opennms_poller_service`: add a service to poller package named `poller_name`.  See `opennms::example_poller` for example usage of this and the `opennms_poller_package` resource. 

#### Data Collection

* `opennms_resource_type`: adds a resourceType definition to a file in etc/datacollection and an include-collection element to the default snmp-collection. This LWRP supports a very limited form of updating - if the resource type already exists but isn't included in the default snmp-collection, an include-collection element will be added. The definition of the resource type won't be updated, however.  
* `opennms_system_def`: add or remove pre-existing groups (`/datacollection-group/group[@name]`) to or from pre-existing systemDefs (`/datacollection-group/systemDef/collect/includeGroup[text()]`) in $ONMS_HOME/etc/datacollection/*.xml.
* `opennms_snmp_collection`: adds an snmp-collection element to etc/datacollection-config.xml. 
* `opennms_xml_collection`: adds an xml-collection element to etc/xml-datacollection-config.xml. 
* `opennms_wmi_collection`: adds a wmi-collection element to etc/wmi-datacollection-config.xml. 
* `opennms_jdbc_collection`: adds a jdbc-collection element to etc/jdbc-datacollection-config.xml. 
* `opennms_collection_package`: adds a package element to etc/collectd-configuration.xml. 
* `opennms_snmp_collection_service`: adds a service element to a package in etc/collectd-configuration.xml. 
* `opennms_xml_collection_service`: adds a service element to a package in etc/collectd-configuration.xml. 
* `opennms_wmi_collection_service`: adds a service element to a package in etc/collectd-configuration.xml.
* `opennms_jdbc_collection_service`: adds a service element to a package in etc/collectd-configuration.xml.
* `opennms_snmp_collection_group`: adds an include-collection element to an snmp-collection in etc/datacollection-config.xml and drops off the specified cookbook file into etc/datacollection. 
* `opennms_jdbc_query`: adds a query element to a jdbc-collection in etc/jdbc-datacollection-config.xml. 
* `opennms_xml_source`: adds a xml-source element to a xml-collection in etc/xml-datacollection-config.xml. 
* `opennms_xml_group`: adds a xml-source element to a xml-source in etc/xml-datacollection-config.xml. 

#### Statistics Reports

See `opennms::example_statsd` for example usage of these LWRPs. 

* `opennms_statsd_package`: create a new package optionally with a filter in statsd-configuration.xml.
* `opennms_statsd_report`: add a report to a package in statsd-configuration.xml. 

#### Graphs

* `opennms_collection_graph_file`: Add a cookbook file containing graph definitions (perhaps generated by the mib compiler) to $ONMS_HOME/etc/snmp-graph.properties.d/. 
* `opennms_collection_graph`: Add a new graph definition to the main (bad idea), new or an existing graph file.
* `opennms_response_graph`: Add a response graph to $ONMS_HOME/etc/response-graph.properties. Since there's a pretty well defined pattern to these, you can define these with just the name of the data source and it'll create a graph with min, max and average response times. 

#### Thresholds

See examples for all of these LWRPs are in a single recipe, `example_threshold`. 

* `opennms_threshd_package`: Create a new package in threshd-configuration.xml. 
* `opennms_threshold_group`: Create a new threshold group in thresholds.xml. 
* `opennms_threshold`: Create a new threshold in the specified group in thresholds.xml. 
* `opennms_expression`: Create a new expression threshold in the specified group in thresholds.xml. 

#### Web UI

There are a couple LWRPs for managing the Web UI. All of these support updating.

* `opennms_avail_category`: Define categories for use in the Availability box on the main page (and the Summary dashlet in Ops Board).
* `opennms_avail_view`: Define the list of categories in each view sections displayed in the Availability box on the main page (and the Summary dashlet in Ops Board).
* `opennms_wallboard`: Create a wallboard. 
* `opennms_dashlet`: Add a dashlet to a wallboard.
* `opennms_surveillance_view`: Manage surveillance views used in the legacy dashboard, Ops Board, and optionally on the front page. Note: does not verify that the categories you reference exist, because there's no ReST interface (yet). 

### Template Overview

Most configuration files are templated and can be overridden with environment, role, or node attributes.  See the default attributes file for a list of configuration items that can be changed in this manner, or keep reading for a brief overview of each template available. Default attribute values set to `nil` mean that the file's default value is commented out in the original file and will remain so unless set to a non-nil value.

Each template can also be overridden in a wrapper cookbook by manipulating the appropriate node attribute. For example, if you've got a pretty heavily customized collectd-configuration.xml file and you don't want to move to the LWRP/library cookbook workflow, turn your custom version into a template (append `.erb` to the filename and optionally add some templating logic to it) and add it to `templates/default` in your wrapper cookbook. Then set `default[:opennms][:collectd][:cookbook]` to the name of your wrapper cookbook. You could also copy all of the templates from this cookbook to your wrapper, edit them all as desired and set `default[:opennms][:default_template_cookbook]` to your wrapper cookbook's name.  

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

in `node['opennms']['notifications']`. Stay tuned for a notification LWRP.

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
TODO: automatically install the appropriate JNI stuff for the target architecture/platform.

You can also change a multitude of queue settings or change the jrobin backend factory, but unless you know what you're doing that's probably a mistake. Look at the template for details if you're curious.

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

Similar to other *-graph.properties files, you can change the image format used in predefined graphs by setting the attribute `node['opennms']['snmp_adhoc_graph']['image_format']` t
o `gif` or `jpg` rather than the default `png`. Note that the intersection of formats supported by both jrobin and rrdtool is `png`, though.
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

Another web UI XML file, this one controls which categories are displayed in the availability box on the main landing page. Once a LWRP exists you'll be able to add sections, but until then you can disable any of the existing categories by setting one of these attributes in `node['opennms']['web_console_view']` to false:

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

* etc/microblog-configuration.xml
* etc/model-importer.properties
* etc/modemConfig.properties
* etc/nsclient-datacollection-config.xml
* etc/poller-configuration.xml
* etc/provisiond-configuration.xml
* etc/remedy.properties
* etc/reportd-configuration.xml
* etc/rtc-configuration.xml
* etc/smsPhonebook.properties
* etc/snmp-interface-poller-configuration.xml
* etc/support.properties
* etc/surveillance-views.xml
* etc/syslog-northbounder-configuration.xml
* etc/syslogd-configuration.xml
* etc/vacuumd-configuration.xml
* etc/vmware-cim-datacollection-config.xml
* etc/vmware-datacollection-config.xml
* etc/wmi-datacollection-config.xml
* etc/xml-datacollection-config.xml
* etc/xmlrpcd-configuration.xml

License
=======
Apache 2.0

Author
======
David Schlenk (<dschlenk@converge-one.com>)

Development
===========

Please feel free to fork and send me pull requests!  The focus of my work will initially be on templates for configuration files that modify the default configuration and LWRPs to add new elements to configuration files. 

There's some kitchen suites available that exercise the main recipes and LWRPs. More testing will be a thing someday!
