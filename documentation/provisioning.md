# Custom Resoruces for managing OpenNMS Provisioning

A number of custom resources are available to assist with provisioning nodes into requisitions. Note that the term `import` is used throughout instead of the more correct term `requisition` as I find it easier to type without frequent misspellings. Also, they all use the OpenNMS REST interface, and as such, OpenNMS has to be running for the resources to converge. It is assumed that the API is available via localhost on the configured jetty port (default 8980) with the managed admin account.

## opennms\_foreign\_source

Create a new foreign source optionally defining a scan interval (defaults to '1d').

## opennms\_service\_detector

Add a service detector to a foreign source. Supports updating and deleting.

## opennms\_policy

Add a policy to a foreign source.

## opennms\_import

Defines a requisition for a foreign source. This and all import\* custom resources include an option to synchronize the requisition - sync\_import.

## opennms\_import\_node

Add a node to a requisition including categories (array of strings) and assets (key/value hash pairs).

## opennms\_import\_node\_interface

Add an interface to a node in a requisition.

## opennms\_import\_node\_interface\_service

Add a service to an interface on a node in a requisition.
