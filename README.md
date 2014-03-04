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

```{
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
