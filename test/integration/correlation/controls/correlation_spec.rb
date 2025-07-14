control 'correlation' do
  describe file('/opt/opennms/etc/drools-engine.d/basic-rule/drools-engine.xml') do
    it { should exist }
    its('content') do
      should cmp %q(<?xml version="1.0" encoding="UTF-8"?>
<engine-configuration 
        xmlns="http://xmlns.opennms.org/xsd/drools-engine"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <rule-set name="basic-rule">
    <rule-file>sample.drl</rule-file>
    <event>uei.opennms.org/nodes/nodeLostService</event>
    <app-context>sampleContext.xml</app-context>
    <global name="LOG" ref="slf4jLogger"/>
  </rule-set>
</engine-configuration>
)
    end
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/basic-rule/sample.drl') do
    it { should exist }
    its('content') do
      should cmp %q(package com.example.rules

import org.opennms.netmgt.xml.event.Event;
import org.opennms.netmgt.model.events.EventUtils;

global org.slf4j.Logger LOG;
global org.opennms.netmgt.correlation.drools.DroolsCorrelationEngine engine;

rule "Event received"
    when
        $e : Event( $uei : uei, $nodeid : nodeid, $ipAddr : interface, $svcName : service, $ifname : getParm("ifName"), $snmpifname : getParm("snmpifname") )
    then
        LOG.info( "UEI: " + $uei + "; Node ID: " + $nodeid + "; IP Address: " + $ipAddr + "; Interface Name: " + $snmpifname + "/" + $ifname + "; Service: " + $svcName);
        retract( $e );
end
)
    end
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/basic-rule/sampleContext.xml') do
    it { should exist }
    its('content') do
      should cmp %q(<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 		xmlns:tx="http://www.springframework.org/schema/tx"
		xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans-4.2.xsd
        http://www.springframework.org/schema/tx
        http://www.springframework.org/schema/tx/spring-tx-4.2.xsd">
    <bean name="slf4jLogger" class="org.slf4j.LoggerFactory" factory-method="getLogger">
        <constructor-arg value="Drools.Engine" />
    </bean>
</beans>
)
    end
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/template-rule/drools-engine.xml') do
    it { should exist }
    its('content') do
      should cmp %q(<?xml version="1.0" encoding="UTF-8"?>
<engine-configuration 
        xmlns="http://xmlns.opennms.org/xsd/drools-engine"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <rule-set name="TemplateRule">
    <rule-file>template-rule.drl</rule-file>
    <event>uei.opennms.org/nodes/nodeLostService</event>
  </rule-set>
</engine-configuration>
)
    end
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/template-rule/template-rule.drl') do
    it { should exist }
    its('content') do
      should cmp %q(package com.example.rules

import org.opennms.netmgt.xml.event.Event;

global org.opennms.netmgt.correlation.drools.DroolsCorrelationEngine engine;

rule "Template Rule - VIP Customer"
    when
        $e : Event( $uei : uei, $nodeid : nodeid, $ipAddr : interface, $svcName : service )
    then
        System.out.println("Event: " + $e.toString());
end
)
    end
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/cookbook-drl-rule/drools-engine.xml') do
    it { should exist }
    its('content') do
      should cmp %q(<?xml version="1.0" encoding="UTF-8"?>
<engine-configuration 
        xmlns="http://xmlns.opennms.org/xsd/drools-engine"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <rule-set name="CookbookRule">
    <rule-file>sample.drl</rule-file>
    <event>uei.opennms.org/nodes/nodeLostService</event>
    <app-context>sampleContext.xml</app-context>
    <global name="LOG" ref="slf4jLogger"/>
  </rule-set>
</engine-configuration>
)
    end
    its('mode') { should cmp '0755' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/cookbook-drl-rule/sample.drl') do
    it { should exist }
    its('content') do
      should cmp %q(package com.example.rules

import org.opennms.netmgt.xml.event.Event;
import org.opennms.netmgt.model.events.EventUtils;

global org.slf4j.Logger LOG;
global org.opennms.netmgt.correlation.drools.DroolsCorrelationEngine engine;

rule "Event received"
    when
        $e : Event( $uei : uei, $nodeid : nodeid, $ipAddr : interface, $svcName : service, $ifname : getParm("ifName"), $snmpifname : getParm("snmpifname") )
    then
        LOG.info( "UEI: " + $uei + "; Node ID: " + $nodeid + "; IP Address: " + $ipAddr + "; Interface Name: " + $snmpifname + "/" + $ifname + "; Service: " + $svcName);
        retract( $e );
end
)
    end
    its('mode') { should cmp '0755' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/cookbook-drl-rule/sampleContext.xml') do
    it { should exist }
    its('content') do
      should cmp %q(<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 		xmlns:tx="http://www.springframework.org/schema/tx"
		xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans-4.2.xsd
        http://www.springframework.org/schema/tx
        http://www.springframework.org/schema/tx/spring-tx-4.2.xsd">
    <bean name="slf4jLogger" class="org.slf4j.LoggerFactory" factory-method="getLogger">
        <constructor-arg value="Drools.Engine" />
    </bean>
</beans>
)
    end
    its('mode') { should cmp '0755' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/remote-engine-rule/drools-engine.xml') do
    it { should exist }
    its('content') do
      should cmp %q(<?xml version="1.0" encoding="UTF-8"?>
<engine-configuration 
	xmlns="http://xmlns.opennms.org/xsd/drools-engine" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:schemaLocation="http://xmlns.opennms.org/xsd/drools-engine /opt/opennms/share/xsds/drools-engine.xsd ">
  <rule-set name="connectionRateRules">
    <rule-file>ConnectionRateRules.drl</rule-file>
    <event>uei.opennms.org/vendor/Juniper/MFC/traps/connectionRateHigh</event>
    <global name="CONN_RATE_HIGH_TRIGGER_COUNT" type="java.lang.Integer" value="10"/>
    <global name="CONN_RATE_HIGH_TIME_WINDOW" type="java.lang.Integer" value="3600000"/>
  </rule-set>
  <rule-set name="transactionRateRules">
    <rule-file>TransactionRateRules.drl</rule-file>
    <event>uei.opennms.org/vendor/Juniper/MFC/traps/transactionRateHigh</event>
    <global name="XACT_RATE_HIGH_TRIGGER_COUNT" type="java.lang.Integer" value="10"/>
    <global name="XACT_RATE_HIGH_TIME_WINDOW" type="java.lang.Integer" value="3600000"/>
  </rule-set>
  <rule-set name="avgCacheBwUsageRules">
    <rule-file>AvgCacheBwUsageRules.drl</rule-file>
    <event>uei.opennms.org/vendor/Juniper/MFC/traps/avgcacheBWusageHigh</event>
    <global name="CACHE_BW_HIGH_TRIGGER_COUNT" type="java.lang.Integer" value="10"/>
    <global name="CACHE_BW_HIGH_TIME_WINDOW" type="java.lang.Integer" value="3600000"/>
  </rule-set>
  <rule-set name="avgOriginBwUsageRules">
    <rule-file>AvgOriginBwUsageRules.drl</rule-file>
    <event>uei.opennms.org/vendor/Juniper/MFC/traps/avgoriginBWusageHigh</event>
    <global name="ORIGIN_BW_HIGH_TRIGGER_COUNT" type="java.lang.Integer" value="10"/>
    <global name="ORIGIN_BW_HIGH_TIME_WINDOW" type="java.lang.Integer" value="3600000"/>
  </rule-set>
  <rule-set name="memUtilizationRules">
    <rule-file>MemUtilizationRules.drl</rule-file>
    <event>uei.opennms.org/vendor/TallMaple/TMS/traps/memUtilizationHigh</event>
    <global name="MEM_UTIL_HIGH_TRIGGER_COUNT" type="java.lang.Integer" value="10"/>
    <global name="MEM_UTIL_HIGH_TIME_WINDOW" type="java.lang.Integer" value="3600000"/>
  </rule-set>
  <rule-set name="netUtilizationRules">
    <rule-file>NetUtilizationRules.drl</rule-file>
    <event>uei.opennms.org/vendor/TallMaple/TMS/traps/netUtilizationHigh</event>
    <global name="NET_UTIL_HIGH_TRIGGER_COUNT" type="java.lang.Integer" value="10"/>
    <global name="NET_UTIL_HIGH_TIME_WINDOW" type="java.lang.Integer" value="3600000"/>
  </rule-set>
  <rule-set name="pagingActivityRules">
    <rule-file>PagingActivityRules.drl</rule-file>
    <event>uei.opennms.org/vendor/TallMaple/TMS/traps/pagingActivityHigh</event>
    <global name="PAGING_HIGH_TRIGGER_COUNT" type="java.lang.Integer" value="10"/>
    <global name="PAGING_HIGH_TIME_WINDOW" type="java.lang.Integer" value="3600000"/>
  </rule-set>
  <rule-set name="nodeDownHolddownRules">
    <rule-file>NodeDownRules.drl</rule-file>
    <event>uei.opennms.org/nodes/nodeDown</event>
    <event>uei.opennms.org/nodes/nodeUp</event>
    <global name="NODE_DOWN_HOLDDOWN_TIME" type="java.lang.Integer" value="30000"/>
  </rule-set>
  <rule-set name="interfaceDownHolddownRules">
    <rule-file>InterfaceDownRules.drl</rule-file>
    <event>uei.opennms.org/nodes/interfaceDown</event>
    <event>uei.opennms.org/nodes/interfaceUp</event>
    <global name="IFACE_DOWN_HOLDDOWN_TIME" type="java.lang.Integer" value="30000"/>
  </rule-set>
  <rule-set name="syslogWriteMemRateRules">
    <rule-file>WriteMemRules.drl</rule-file>
    <event>uei.opennms.org/syslogd/local7/Notice</event>
    <global name="WRITE_MEM_TRIGGER_COUNT" type="java.lang.Integer" value="5"/>
    <global name="WRITE_MEM_TIME_WINDOW" type="java.lang.Integer" value="30000"/>
  </rule-set>
  <rule-set name="deviceStateTrackingRaceConditionRules" event-processing-mode="stream">
    <rule-file>CorrelationRaceConditionRules.drl</rule-file>
    <event>DeviceOffline</event>
    <event>DeviceAdopted</event>
  </rule-set>
  <!-- Disabled as it's not used, but useful as a reference
  <rule-set name="resourcePoolUtilRules">
    <rule-file>file:src/test/opennms-home/etc/ResourcePoolUtilRules.drl</rule-file>
    <event>uei.opennms.org/vendor/Juniper/MFC/traps/resourcePoolUsageHigh</event>
    <event>uei.opennms.org/vendor/Juniper/MFC/traps/resourcePoolUsageLow</event>
    <global name="PAGING_HIGH_TRIGGER_COUNT" type="java.lang.Integer" value="10"/>
    <global name="PAGING_HIGH_TIME_WINDOW" type="java.lang.Integer" value="3600000"/>
  </rule-set>
  -->
</engine-configuration>
)
    end
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end
  %w(AvgCacheBwUsageRules AvgOriginBwUsageRules ConnectionRateRules CorrelationRaceConditionRules InterfaceDownRules MemUtilizationRules NetUtilizationRules NodeDownRules PagingActivityRules ResourcePoolUtilRules TransactionRateRules WriteMemRules).each do |drl|
    describe file("/opt/opennms/etc/drools-engine.d/remote-engine-rule/#{drl}.drl") do
      it { should exist }
      its('size') { should be > 0 }
      its('mode') { should cmp '0644' }
      its('owner') { should eq 'opennms' }
      its('group') { should eq 'opennms' }
    end
  end

  describe file('/opt/opennms/etc/drools-engine.d/remote-everything/drools-engine.xml') do
    it { should exist }
    its('content') do
      should cmp %q(<?xml version="1.0" encoding="UTF-8"?>
<engine-configuration xmlns="http://xmlns.opennms.org/xsd/drools-engine">
  <rule-set name="persistStateStreamingTest" persist-state="true" event-processing-mode="stream">
    <rule-file>PersistStateStreaming.drl</rule-file>
    <event>uei.opennms.org/nodes/nodeLostService</event>
  </rule-set>  
</engine-configuration>)
    end
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/remote-everything/PersistStateStreaming.drl') do
    it { should exist }
    its('content') do
      should cmp %q(package org.opennms.netmgt.correlation.drools;

import org.opennms.netmgt.correlation.drools.DroolsCorrelationEngine;
import org.opennms.netmgt.xml.event.Event;
import org.opennms.netmgt.model.events.EventBuilder;

global DroolsCorrelationEngine engine;

declare Thing
	name: String
end

rule "test-got-something"
	salience 300
when
	$e : Event(uei matches "uei.opennms.org/nodes/nodeLostService")
then
    System.err.println("got one: " + $e);
    EventBuilder eventBuilder = new EventBuilder("uei.opennms.org/nodes/nodeUp", "Component Correlator");
    eventBuilder.setNodeid($e.getNodeid());
    insert(eventBuilder.getEvent());
    insert(new Thing());
end)
    end
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/cookbook-everything/drools-engine.xml') do
    it { should exist }
    its('content') do
      should cmp %q(<?xml version="1.0" encoding="UTF-8"?>
<engine-configuration
        xmlns="http://xmlns.opennms.org/xsd/drools-engine"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <rule-set name="basic-rool">
    <rule-file>sample.drl</rule-file>
    <event>uei.opennms.org/nodes/nodeLostService</event>
    <app-context>sampleContext.xml</app-context>
    <global name="LOG" ref="slf4jLogger"/>
  </rule-set>
</engine-configuration>
)
    end
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/cookbook-everything/sample.drl') do
    it { should exist }
    its('content') do
      should cmp %q(package com.example.rules

import org.opennms.netmgt.xml.event.Event;
import org.opennms.netmgt.model.events.EventUtils;

global org.slf4j.Logger LOG;
global org.opennms.netmgt.correlation.drools.DroolsCorrelationEngine engine;

rule "Event received"
    when
        $e : Event( $uei : uei, $nodeid : nodeid, $ipAddr : interface, $svcName : service, $ifname : getParm("ifName"), $snmpifname : getParm("snmpifname") )
    then
        LOG.info( "UEI: " + $uei + "; Node ID: " + $nodeid + "; IP Address: " + $ipAddr + "; Interface Name: " + $snmpifname + "/" + $ifname + "; Service: " + $svcName);
        retract( $e );
end
)
    end
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/cookbook-everything/sampleContext.xml') do
    it { should exist }
    its('content') do
      should cmp %q(<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 		xmlns:tx="http://www.springframework.org/schema/tx"
		xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans-4.2.xsd
        http://www.springframework.org/schema/tx
        http://www.springframework.org/schema/tx/spring-tx-4.2.xsd">
    <bean name="slf4jLogger" class="org.slf4j.LoggerFactory" factory-method="getLogger">
        <constructor-arg value="Drools.Engine" />
    </bean>
</beans>
)
    end
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/nonexistent-rule') do
    it { should_not exist }
  end
end
