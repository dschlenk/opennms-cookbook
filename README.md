Description
===========

A Chef cookbook to manage the installation and configuration of OpenNMS.
Current version of templates are based on OpenNMS release 1.12.5.

Requirements
============

* Chef 11.x
* CentOS 6.x. Debian/Ubuntu support planned.
* Some experience using OpenNMS without the benefit of configuration management.
* The need to manage many instances of OpenNMS.
* The desire to share configurations with other users without `$OPENNMS_HOME/etc` tarballs or git patches.
* Patience as unimplemented templates and LWRPs are completed.
* Either use Berkshelf to satisfy dependencies or manually acquire the following cookbooks: 
  * yum
  * hostsfile
* Unless you like really old JVMs and a poorly tuned PostgreSQL or just really want to install java and postgresql yourself you will also want these cookbooks:
  * java
  * postgresql

See Usage for more details.

Usage
=====

Running the default recipe will install OpenNMS 1.12.5 on CentOS 6.x from the official repo with the default configuration. It will also execute `'$ONMS_HOME/bin/runjava -s` if `$ONMS_HOME/etc/java.conf` is not present and `$ONMS_HOME/bin/install -dis` if `$ONMS_HOME/etc/configured` is not present.

Also, most configuration files are templated and can be overridden with environment, role, or node attributes.  See the default attributes file for a list of configuration items that can be changed in this manner, or keep reading for a brief overview of each template available. Some general notes:

* Default attribute values set to `nil` mean that the file's default value is commented out in the original file and will remain so unless set to a non-nil value.
* For XML configuration files, you can disable or modify elements that exist in the default configuration, but in general if you want to add something new or drastically change something you will want to disable the default config and use the appropriate LWRP (coming soon!) in your own cookbook/recipe.
* Some items that exist in the default configuration but are commented out can be turned on with attributes.

You probably also want to check out the community java (https://github.com/socrata-cookbooks/java) and postgresql (https://github.com/hw-cookbooks/postgresql) cookbooks. Here's my default overrides for each:

### Java

```
{
  "java":
  {
    "oracle":
    {
      "accept_oracle_download_terms": true
    },
    "install_flavor":"oracle",
    "jdk":
    {
      "7":
      {
        "x86_64":
        {
          "checksum":"77367c3ef36e0930bf3089fb41824f4b8cf55dcc8f43cce0868f7687a474f55c",
          "url":"http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.tar.gz"
        }
      }
    },
    "jdk_version":7
  }
}
```

### Postgresql

Include the server, config_initdb, config_pgtune and contrib recipes in your run list. Then use these override attributes for a fairly well tuned config:

```
{
  "postgresql":
  {
    "pg_hba":
    [
      {
        "addr":"",
        "user":"all",
        "type":"local",
        "method":"trust",
        "db":"all"
      },
      {
        "addr":"127.0.0.1/32",
        "user":"all",
        "type":"host",
        "method":"trust",
        "db":"all"
      },
      {
        "addr":"::1/128",
        "user":"all",
        "type":"host",
        "method":"trust",
        "db":"all"
      }
    ],
    "config":
    {
      "checkpoint_timeout":"15min",
      "autovacuum":"on",
      "track_activities":"on",
      "track_counts":"on",
      "shared_preload_libraries":"pg_stat_statements",
      "vacuum_cost_delay":50
    },
    "server":
    {
      "packages":
      [
        "postgresql-server",
        "postgresql-contrib"
      ]
    },
    "contrib":
    {
      "extensions":
      [
        "pageinspect",
        "pg_buffercache",
        "pg_freespacemap",
        "pgrowlocks",
        "pg_stat_statements",
        "pgstattuple"
      ]
    }
  }
}
```

There are also a couple OpenNMS attributes you'll probably want to override at a minimum: 

### opennms.conf

```
   {
     "opennms": {
       "conf":{
         "start_timeout": 20,
         "heap_size": 1024
       }
     }
   }
```

### Template Overview

#### Access Point Monitor (etc/access-point-monitor-configuration.xml)

You can change `threads` and `pscan_interval` or disable either of the default types by setting `aruba_enable` or `moto_enable` to false in `node['opennms']['apm']`.

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

#### etc/capsd-configuration.xml

Note: the existance of this template does not imply that you should still be using capsd! To enable capsd you need to change the handler for newSuspect events in opennms.conf by setting `node['opennms']['properties']['provisioning']['enable_discovery']` to `false`.

Example: change the timeout and retries for the ICMP scanner, do:

```
   {
     "opennms": {
       "capsd": {
         "icmp": {
           "timeout": "5000",
           "retry": "3"
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

TODO: Finish this template!!!
Similar to other datacollection-config.xml files, you can change the RRD repository, step, RRA definitions and disable default collections.

#### etc/jmx-datacollection-config.xml 

TODO: Finish this template!!!
Similar to other datacollection-config.xml files, you can change the RRD repository, step, RRA definitions and disable default collections.

#### etc/linkd-configuration.xml

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

#### etc/log4j.properties

This one is a little different. If you want to turn up logging for collectd, for instance, you'd set these override attributes:
```
{
  "opennms":
  {
    "log4j":
    {
      "collectd":
      {
        "level": "DEBUG"
      }
    }
  }
}
```
But you could also change the appender class, the max file size, the max number of files (assuming the use of RollingFileAppender), the layout class and the layout conversion pattern (assuming the use of PatternLayout) using `appender`, `max_file_size`, `max_backup_index`, `layout`, and `conversion_pattern`.

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

Do you love maps but are a contrarian when it comes to color schemes? Have we got the template for you! I guess also useful for translating labels?  Check out the default attributes for details on what you can change.

#### etec/microblog-configuration.xml

Join twitter and tell the public about your broken network! Set `node['opennms']['microblog']['default_profile']['name']` to `twitter` or `identica` and then set `['opennms']['microblog']['default_profile']['authen_username']` and `['opennms']['microblog']['default_profile']['authen_password']` to use those services, or use a different service by setting `node['opennms']['microblog']['default_profile']['service_url']` as well (assuming OpenNMS supports it). This only sets up the profile. You'll still need to define a destination path and set events and alarms to use it the normal way as described at http://www.opennms.org/wiki/Microblog_Notifications until the notification and destination path LWRPs are written.

#### etc/model-importer.properties

I couldn't figure out if this file is still used and/or necessary, but anyway the same attributes are used here and in provisiond-configuration.xml, so go check that one out.

#### etc/modemConfig.properties

You can set `node['opennms']['modem']` to one of the predefined modems (mac2412, mac2414, macFA22, macFA24, macFA42, macFA44, acm0, acm1, acm2, acm3, acm4, acm5) or set `node['opennms']['custom_modem']` to something like :
```
{
  "opennms":
  {
    "custom_modem":
    {
      "name": "foobar",
      "port": "/dev/ttyFoobar",
      "model": "foobar37",
      "manufacturer": "Foo Bar"
      "baudrate": 57600
    }
  }
}
```

#### etc/notifd-configuration.xml

Is ignorance about your broken network in fact bliss?  Shut off notifd by setting `node['notifd']['status']` to "off" and find out. Don't know what `match-all` even means? Find out by setting `node['opennms']['notifd']['match_all']` to false. (It controls whether only the first matching notification is used or not). You can also disable any of the default auto-acknowledge elements with `node'notifd']['auto_ack']['service_unresponsive|service_lost|interface_down|widespread_outage']`.

#### etc/notificationCommands.xml

Turn off one of the default notification commands by setting one of the attributes in `node['opennms']['notification_commands']` to false:
* java_pager_email
* xmpp_message
* xmpp_group_message
* irc_cat
* call_work_phone
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

#### etc/nsclient-datacollection-config.xml

TODO: finish this template
Similar to other datacollection-config.xml files, you can change the RRD repository, step, RRA definitions and disable default collections.
#### etc/poller-configuration.xml

Disable packages, change IPv4 and IPv6 include ranges and RRD settings, remove or disable services or change their polling interval, retry, timeout or another service parameter. Like collectd and capsd, the possibilities here are pretty extensive so check out the default attributes and template for more info.
#### etc/provisiond-configuration.xml

Same as model-importer.properties.
```
default['opennms']['importer']['import_url']         = "file:/path/to/dump.xml"
default['opennms']['importer']['schedule']           = "0 0 0 1 1 ? 2023"
default['opennms']['importer']['threads']            = 8
default['opennms']['importer']['scan_threads']       = 10
default['opennms']['importer']['rescan_threads']     = 10
default['opennms']['importer']['write_threads']      = 8
default['opennms']['importer']['requisition_dir']    = "#{default['opennms']['conf']['home']}/etc/imports"
default['opennms']['importer']['foreign_source_dir'] = "#{default['opennms']['conf']['home']}/etc/foreign-sources"
```

#### etc/remedy.properties

Do you use the Remedy integration but aren't the Italian that checked their Remedy config into git? Change all of these attributes then:

```
default['opennms']['remedy']['username']
default['opennms']['remedy']['password']
default['opennms']['remedy']['authentication']
default['opennms']['remedy']['locale']
default['opennms']['remedy']['timezone']
default['opennms']['remedy']['endpoint']
default['opennms']['remedy']['portname']
default['opennms']['remedy']['createendpoint']
default['opennms']['remedy']['createportname']
default['opennms']['remedy']['targetgroups']
default['opennms']['remedy']['assignedgroups']
default['opennms']['remedy']['assignedsupportcompanies']
default['opennms']['remedy']['assignedsupportorganizations']
default['opennms']['remedy']['assignedgroup']
default['opennms']['remedy']['firstname']
default['opennms']['remedy']['lastname']
default['opennms']['remedy']['serviceCI']
default['opennms']['remedy']['serviceCIReconID']
default['opennms']['remedy']['assignedsupportcompany']
default['opennms']['remedy']['assignedsupportorganization']
default['opennms']['remedy']['categorizationtier1']
default['opennms']['remedy']['categorizationtier2']
default['opennms']['remedy']['categorizationtier3']
default['opennms']['remedy']['service_type']
default['opennms']['remedy']['reported_source']
default['opennms']['remedy']['impact']
default['opennms']['remedy']['urgency']
default['opennms']['remedy']['reason_reopen']
default['opennms']['remedy']['resolution']
default['opennms']['remedy']['reason_resolved']
default['opennms']['remedy']['reason_cancelled']
```

#### etc/reportd-configuration.xml

Two attributes are available for your availability report running pleasure:

* storage_location
* persist_reports

But they aren't very helpful until you add some reports. A LWRP for that is planned.

#### etc/response-graph.properties
Change the image format from the default `png` to `gif` or `jpg` (if using jrobin or you like broken images) with `node['response_graph']['image_format']`. Font sizes can also be changed with `node['response_graph']['default_font_size']` and `node['response_graph']['title_font_size']` (defaults are 7 and 10 respectively). Setting these attributes to false remotes them from the file:

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

If you changed the count of pings in the strafer polling package to a value higher than 20, you'll also need to define additional colors for the strafeping graph, like `default['opennms']['response_graph']['strafeping_colors'][21] = ["#f5f5f5"]`. If you want to add a STACK to the graph for another ping number (defaults to 1-4,10,19) add a second color to that attribute's value array, like `default['opennms']['response_graph']['strafeping_colors'][21] = ["#f5f5f5","#050505"]`. TODO: Fix the STACK ranges. 

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

#### etc/rtc-configuration.xml

Like other factory configuration files, you can change some settings with attributes:

```
default['opennms']['rtc']['updaters']                      = 10
default['opennms']['rtc']['senders']                       = 5
default['opennms']['rtc']['rolling_window']                = "24h"
default['opennms']['rtc']['max_events_before_resend']      = 100
default['opennms']['rtc']['low_threshold_interval']        = "20s"
default['opennms']['rtc']['high_threshold_interval']       = "45s"
default['opennms']['rtc']['user_refresh_interval']         = "2m"
default['opennms']['rtc']['errors_before_url_unsubscribe'] = 5
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

#### etc/smsPhonebook.properties

Populate `node['opennms']['sms_phonebook']['entries']` with `{ "hostname": "+PHONE_NUMBER" }` keypairs to define an IP address' phone number for the mobile sequence monitor (http://www.opennms.org/wiki/Mobile_Sequence_Monitor). A pending LWRP will provide the ability to add the required mobile-sequence elements to make this useful.

#### etc/snmp-adhoc-graph.properties

Similar to other *-graph.properties files, you can change the image format used in adhoc graphs by setting the attribute `node['opennms']['snmp_adhoc_graph']['image_format']` to `gif` or `jpg` rather than the default `png`. Note that the intersection of formats supported by both jrobin and rrdtool is `png`, though.

#### etc/snmp-graph.properties & snmp-graph.properties.d/*

snmp-graph.properties & snmp-graph.properties.d/*
-------------------------------------------------

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

License
=======
Apache 2.0

Author
======
David Schlenk (<david.schlenk@spanlink.com>)

Development
===========

Please feel free to fork and send me pull requests!  The focus of my work will initially be on templates for configuration files that modify the default configuration and LWRPs to add new elements to configuration files. 

I use test kitchen with the openstack vagrant plugin, so if you use the default VirtualBox driver you'll need to change that.  Otherwise I think it's a pretty normal Chef workflow but I'm new at writing cookbooks so criticism is welcome. 
