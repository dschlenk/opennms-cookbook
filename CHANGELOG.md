# OpenNMS Cookbook Changes

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
