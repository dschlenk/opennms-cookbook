control 'translation_specs' do
  describe translation_spec('uei.opennms.org/internal/telemetry/clockSkewDetected', [
    {
      assignments: [
        {
          name: 'uei',
          type: 'field',
          value: {
            type: 'constant',
            result: 'uei.opennms.org/translator/telemetry/clockSkewDetected',
          },
        },
        {
          name: 'nodeid',
          type: 'field',
          value: {
            type: 'sql',
            result: 'SELECT n.nodeid FROM node n, ipinterface i WHERE n.nodeid = i.nodeid AND i.ipaddr = ? AND n.location = ?',
            values: [
              { type: 'field', name: 'interface', matches: '.*', result: '${0}' },
              { type: 'parameter', name: 'monitoringSystemLocation', matches: '.*', result: '${0}' },
            ],
          },
        },
      ],
    },
  ]) do
    it { should exist }
  end

  describe translation_spec('uei.opennms.org/generic/traps/SNMP_Link_Down', [
    {
      assignments: [
        {
          name: 'uei',
          type: 'field',
          value: {
            type: 'constant',
            result: 'uei.opennms.org/translator/traps/SNMP_Link_Down',
          },
        },
        {
          name: 'ifDescr',
          type: 'parameter',
          default: 'Unknown',
          value: {
            type: 'sql',
            result: 'SELECT snmp.snmpIfDescr FROM snmpInterface snmp WHERE snmp.nodeid = ?::integer AND snmp.snmpifindex = ?::integer',
            values: [
              { type: 'field', name: 'nodeid', matches: '.*', result: '${0}' },
              { type: 'parameter', name: '~^\\.1\\.3\\.6\\.1\\.2\\.1\\.2\\.2\\.1\\.1\\.([0-9]*)$', matches: '.*', result: '${0}' },
            ],
          },
        },
        {
          name: 'ifName',
          type: 'parameter',
          default: 'Unknown',
          value: {
            type: 'sql',
            result: 'SELECT snmp.snmpIfName FROM snmpInterface snmp WHERE snmp.nodeid = ?::integer AND snmp.snmpifindex = ?::integer',
            values: [
              { type: 'field', name: 'nodeid', matches: '.*', result: '${0}' },
              { type: 'parameter', name: '~^\\.1\\.3\\.6\\.1\\.2\\.1\\.2\\.2\\.1\\.1\\.([0-9]*)$', matches: '.*', result: '${0}' },
            ],
          },
        },
        {
          name: 'ifAlias',
          type: 'parameter',
          default: 'Unknown',
          value: {
            type: 'sql',
            result: 'SELECT snmp.snmpIfAlias FROM snmpInterface snmp WHERE snmp.nodeid = ?::integer AND snmp.snmpifindex = ?::integer',
            values: [
              { type: 'field', name: 'nodeid', matches: '.*', result: '${0}' },
              { type: 'parameter', name: '~^\\.1\\.3\\.6\\.1\\.2\\.1\\.2\\.2\\.1\\.1\\.([0-9]*)$', matches: '.*', result: '${0}' },
            ],
          },
        },
      ],
    },
    {
      assignments: [
        {
          name: 'uei',
          type: 'field',
          value: {
            type: 'constant',
            result: 'uei.opennms.org/internal/topology/linkDown',
          },
        },
      ],
    },
  ]) do
    it { should exist }
  end

  describe translation_spec('uei.opennms.org/generic/traps/SNMP_Link_Up', [
    {
      assignments: [
        {
          name: 'uei',
          type: 'field',
          value: {
            type: 'constant',
            result: 'uei.opennms.org/translator/traps/SNMP_Link_Up',
          },
        },
        {
          name: 'ifDescr',
          type: 'parameter',
          default: 'Unknown',
          value: {
            type: 'sql',
            result: 'SELECT snmp.snmpIfDescr FROM snmpInterface snmp WHERE snmp.nodeid = ?::integer AND snmp.snmpifindex = ?::integer',
            values: [
              { type: 'field', name: 'nodeid', matches: '.*', result: '${0}' },
              { type: 'parameter', name: '~^\\.1\\.3\\.6\\.1\\.2\\.1\\.2\\.2\\.1\\.1\\.([0-9]*)$', matches: '.*', result: '${0}' },
            ],
          },
        },
        {
          name: 'ifName',
          type: 'parameter',
          default: 'Unknown',
          value: {
            type: 'sql',
            result: 'SELECT snmp.snmpIfName FROM snmpInterface snmp WHERE snmp.nodeid = ?::integer AND snmp.snmpifindex = ?::integer',
            values: [
              { type: 'field', name: 'nodeid', matches: '.*', result: '${0}' },
              { type: 'parameter', name: '~^\\.1\\.3\\.6\\.1\\.2\\.1\\.2\\.2\\.1\\.1\\.([0-9]*)$', matches: '.*', result: '${0}' },
            ],
          },
        },
        {
          name: 'ifAlias',
          type: 'parameter',
          default: 'Unknown',
          value: {
            type: 'sql',
            result: 'SELECT snmp.snmpIfAlias FROM snmpInterface snmp WHERE snmp.nodeid = ?::integer AND snmp.snmpifindex = ?::integer',
            values: [
              { type: 'field', name: 'nodeid', matches: '.*', result: '${0}' },
              { type: 'parameter', name: '~^\\.1\\.3\\.6\\.1\\.2\\.1\\.2\\.2\\.1\\.1\\.([0-9]*)$', matches: '.*', result: '${0}' },
            ],
          },
        },
      ],
    },
    {
      assignments: [
        {
          name: 'uei',
          type: 'field',
          value: {
            type: 'constant',
            result: 'uei.opennms.org/internal/topology/linkUp',
          },
        },
      ],
    },
  ]) do
    it { should exist }
  end

  describe translation_spec('uei.opennms.org/external/hyperic/alert', [
    {
      assignments: [
        {
          name: 'uei',
          type: 'field',
          value: {
            type: 'constant',
            result: 'uei.opennms.org/internal/translator/hypericAlert',
          },
        },
        {
          name: 'nodeid',
          type: 'field',
          value: {
            type: 'sql',
            result: 'SELECT n.nodeid FROM node n WHERE n.foreignid = ? AND n.foreignsource = ?',
            values: [
              { type: 'parameter', name: 'platform.id', matches: '.*', result: '${0}' },
              { type: 'parameter', name: 'alert.source', matches: '.*', result: '${0}' },
            ],
          },
        },
      ],
    },
  ]) do
    it { should_not exist }
  end

  describe translation_spec('uei.opennms.org/vendor/Cisco/traps/ciscoConfigManEvent', [
    {
      assignments: [
        {
          name: 'uei',
          type: 'field',
          value: {
            type: 'constant',
            result: 'uei.opennms.org/internal/translator/entityConfigChanged',
          },
        },
        {
          name: 'configSource',
          type: 'parameter',
          value: {
            type: 'parameter',
            name: '~^\.1\.3\.6\.1\.4\.1\.9\.9\.43\.1\.1\.6\.1\.3\..*',
            matches: '.*',
            result: '${0}',
          },
        },
        {
          name: 'configUser',
          type: 'parameter',
          value: {
            type: 'constant',
            result: 'Unknown',
          },
        },
      ],
    },
  ]) do
    it { should exist }
  end

  describe translation_spec('uei.opennms.org/vendor/Juniper/traps/jnxCmCfgChange', [
    {
      assignments: [
        {
          name: 'uei',
          type: 'field',
          value: {
            type: 'constant',
            result: 'uei.opennms.org/internal/translator/entityConfigChanged',
          },
        },
        {
          name: 'configSource',
          type: 'parameter',
          value: {
            type: 'parameter',
            name: '~^\.1\.3\.6\.1\.4\.1\.2636\.3\.18\.1\.7\.1\.4\..*',
            matches: '.*',
            result: '${0}',
          },
        },
        {
          name: 'configUser',
          type: 'parameter',
          value: {
            type: 'parameter',
            name: '~^\.1\.3\.6\.1\.4\.1\.2636\.3\.18\.1\.7\.1\.5\..*',
            matches: '.*',
            result: '${0}',
          },
        },
      ],
    },
  ]) do
    it { should exist }
  end

  describe translation_spec('uei.opennms.org/fakeUei', [
    {
      assignments: [
        {
          name: 'uei',
          type: 'field',
          value: {
            type: 'constant',
            result: 'uei.opennms.org/translatedUei',
          },
        },
      ],
    },
  ]) do
    it { should exist }
  end
end
