# OpenNMS Cookbook Changes

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
