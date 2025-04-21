# OpenNMS Cookbook Changes

## 33.3.0

* update to 33.1.5-1
* replace REXML with Nokogiri in opennms\_service\_detector for performance reasons (likely more to follow)
* allow use of array of hashes for resource type selector parameters to allow for multiple instances of parameters with the same key
* bugfix: new foreign source documents had the wrong root element
* bugfix: wrong RRD directory in datacollection-config.xml

## 33.2.1

* bugfix: checking threshold idempotence didn't take resource filters into account
* bugfix: incorrect exception class name used when when validating that the desired threshold group existed

## 33.2.0

* default to installing OpenNMS Horizon 33.1.4-1
* stop checking to see if the rtc and admin users exist and have roles during upgrades
* significantly improve the performance of subsequent converges of run lists that use custom resources by caching config variables in derived resources with action `:nothing` in the resource collection to read from instead of having to read from the file system or make a REST call when loading the current value of every resource instance
* bug: JMS NBI attribute `default['opennms']['jms_nbi']['first_occurrence_only']` was spelled incorrectly
* bug: admin passwords with special characters were not URL encoded when used to make REST requests
* bug: `wsman_system_definition` idempotence check was broken

## 33.1.0

* support disabling more daemons
* make postgres access more flexible
* add `opennms_send_event` resource for restarting SnmpPoller
* make `logndisplay` the default for `logmsg_dest` in new events created with `opennms_event`
* breaking: `opennms_poller_service` and `opennms_service_detector` no longer proxy common parameters
* breaking: `triggered_uei` and `rearmed_uei` properties of `opennms_threshold` and `opennms_expression` are now part of identity
* bug: fix `opennms_service_detector` and `opennms_policy` idempotence
* bug: `opennms_service_detector` and `opennms_policy`: `:delete` action didn't work
* bug: `opennms_xml_source` `include_groups` files not creating
* bug: events in files included OOTB falsely marked as updated every converge
* bug: default wallboard not correctly identified
* bug: mark `opennms.conf` sensitive since scv password often present in it
* bug: users marked for update when not needed
* bug: thresholds and expressions without descriptions broke the derived template execution
* bug: `opennms_xml_source` with `request` properties broke the derived template execution in some circumstances
* bug/breaking: `opennms_threshd_package` validation of `services` property and `opennms_threshd_service` identity incorrect: parameters need to be an array of hashes to support multiple threshold groups for a single service
* bug/breaking: `opennms_xml_group` and the `groups` property of `opennms_xml_source` now support only one syntax: Array of hashes

## 33.0.0

* drop support for older releases. Upgrading from 32 is supported.
* refactor custom resources to mostly adapt initialized accumulator pattern
* remove templates for config files that can be managed with custom resources
* lots of other minor changes. See README.

## 28.1.0

* add support for updating and deleteing threshd packages

## 26.3.3

* actually don't manage postres repos when told not to

## 26.3.2

* fix bug introduced as side effect of making postgresl repo mgmt optional

## 26.3.1

* Fix location of postgres stats directory
* Make management of postgres repos optional

## 26.3.0

* support changes and manage roles in user LWRP

## 26.2.0

* Properly handle upgrades of users.xml when jumping from very old to current

## 26.1.0

* Allow installation of plugin packages via node attributes

## 26.0.0

### New Features

* Use OpenNMS Horizon 26.2.2-1 as the default version.
* Support OpenNMS Horizon 23, 24, 25, 26

## 22.3.3

### Bug Fixes

* remove unnecessary check for datacollection group before removing a system def

## 22.3.2

### Bug Fixes

* join multiline strings together properly in events

## 22.3.1

### Bug Fixes

* fix bug introduced in poller param modification

## 22.3.0

### New Features

* add ability to remove params from poller services

## 22.2.3

### Bug Fixes

* quit restarting unnecessarily when logging config changes

## 22.2.2

### Bug Fixes

* more attempts to deal with bogus gzip handling in rest calls

## 22.2.1

### Bug Fixes

* correctly use mask existence in identity of events 
* attempt to deal with bogus gzip handling in rest calls
* fix bug in editing of poller services
* misc test improvements

## 22.2.0

### New Features

* Support for OpenNMS Horizon 22.0.4-1 (replacing 22.0.2-1). Default version.

## 22.1.1

### Bug Fixes

* re-order repo list to fix an issue with CentOS 7

## 22.1.0

### New Features

* Add :delete action to opennms_poller_service

### Bug Fixes

* Fixed some minor issues in the testing scripts

## 22.0.0

### New Features

* Support for OpenNMS Horizon 20 - 22 (defaults to 22.0.2-1)
* CentOS 7 support
* New resource: opennms_poll_outages
* Telemetryd: templates `elastic-credentials.xml`, `telemetryd-configuration.xml` in new recipe `opennms::telemetryd`. Set `node['opennms']['telemetryd']['managed']` to true and use version >= 22 to use. See `flows` test kitchen suite for example usage.
* `opennms_collection_package` has two new properties: `remote`, `outage_calendars`
* `opennms_dashlet` can now specify a title separately from the resource name
* `opennms_jmx_collection_service` now supports `:delete` action, has new properties: `factory`, `username`, `password`, `url`, `rmi_server_port`, `remote_jmx`. See resource definition and tests for details.
* `opennms_poller_service` can now specify a service name separately from the resource name.
* Management of yum repos is now optional with node attribute `node['opennms']['manage_repos']`.
* Loads more testing. InSpec resources exist now to test custom resources.

### Bug Fixes

* Fix handling of static parameters in eventconf
* Minor internal syntax changes to support Chef 13+
* `opennms_disco_specific` had a bug detecting existing entries and therefore duplicated on each Chef run. A bug in element ordering during create was also fixed.
* Various service resources had element order insertion bugs that were fixed, including:
** `opennms_jdbc_collection_service`
** `opennms_jmx_collection_service`
** `opennms_jmx_collection_service`
** `opennms_poller_service`
** `opennms_snmp_collection_service`
** `opennms_wmi_collection_service`
** `opennms_xml_collection_service`
* `opennms_wmi_config_definition` had an element ordering bug resolved as well.
* `opennms_xml_source` no longer removes files referenced in `import_groups` during `:delete` actions in case another resource is using that same file.
* Removed unnecessary opennms service restarts from various template resources.

### Breaking Changes

* Remove old grafana stuff (use opennms_helm cookbook for replacement)
* `opennms_poller_package` properties `include_ranges` and `exclude_ranges` now needs to be an Array of Hashes each containing `begin` and `end` keys.
* Several custom resources had properties that were previously named `params` which has a naming collision with Chef in 13+. They were all renamed `parameters`. Any use of these custom resources will need to be changed to use the new property names. The list of resources impacted is:
** `opennms_collection_service`
** `opennms_notification`
** `opennms_policy`
** `opennms_poller_service`
** `opennms_service_detector`
