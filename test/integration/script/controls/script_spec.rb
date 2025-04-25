control 'script' do
  describe engine('beanshell') do
    it { should exist }
    its('className') { should eq 'bsh.util.BeanShellBSFEngine' }
    its('extensions') { should eq 'bsh' }
  end

  describe engine('jython') do
    it { should exist }
    its('className') { should eq 'org.apache.bsf.engines.JythonEngine' }
    its('extensions') { should eq 'py' }
  end

  describe start_script('beanshell') do
    it { should exist }
    its('script') {
      should include("log = bsf.lookupBean(\"log\");")
      should include("log.debug(\"start-script\");")
      should include("log.debug(\"start-script too\");")
    }
  end

  describe stop_script('beanshell') do
    it { should exist }
    its('script') {
      should include("log = bsf.lookupBean(\"log\");")
      should include("log.debug(\"stop-script\");")
      should include("log.debug(\"stop-script also\");")
      should include("log.debug(\"another line but it is indented\");")
    }
  end

  describe stop_script('jython') do
    it { should exist }
    its('script') { should eq("1 + 1") }
  end

  describe reload_script('beanshell') do
    it { should exist }
    its('script') {
      should include("log = bsf.lookupBean(\"log\");")
      should include("log.debug(\"reload-script also\");")
      should include("log.debug(\"another reload line but it is indented and there is a blank line between this one and the last one\");")
    }
  end

  describe event_script('beanshell') do
    it { should exist }
    its('uei') {
      should eq 'uei.opennms.org/vendor/compaqhp/traps/cpqHoMibHealthStatusArrayChangeTrap'
    }
    its('script') {
      should include(
        "log = bsf.lookupBean(\"log\");\n" \
        "log.debug(\"cpqHoTrapFlags: {}\", cpqHoTrapFlags);\n\n" \
        "if (\"CRITICAL\".equalsIgnoreCase(trapType)) {\n" \
        "    log.warn(\"HP device sent a CRITICAL trap!\");\n" \
        "} else {\n" \
        "    log.warn(\"Received HP trap that should have had varbind cpqHoTrapFlags in it but it did not.\");\n" \
        "}\n" \
        "log.debug(\"cpqHoMibHealthStatusArray: {}\", cpqHoMibHealthStatusArray);\n" \
        "if (cpqHoMibHealthStatusArray == null || cpqHoMibHealthStatusArray.length() < 38) {\n" \
        "    log.warn(\"Received HP trap that should have had varbind cpqHoMibHealthStatusArray in it but it did not.\");\n" \
        "}\n" \
        "log.debug(\"Sending new event: \\n{}\", org.opennms.core.xml.JaxbUtils.marshal(bldr.getEvent()));"
      )
    }
  end

  describe event_script('beanshell') do
    it { should exist }
    its('uei') { should eq 'uei.opennms.org/nodes/nodeLostService' }
    its('script') {
      should include(
        "log = bsf.lookupBean(\"log\");\n" \
        "log.debug(\"nodeLostService event found for TLS-Cert-Expire, is '{}'\", event.service);\n" \
        "log.debug(\"making socket\");\n" \
        "log.debug(\"connected\");\n" \
        "if (!isAvailable && cert != null) {\n" \
        "    log.debug(\"Found the failing cert. It's subject is \" + cert.getSubjectDN().getName() + \", is issued by \" + cert.getIssuerDN().getName() + \", is valid between \" + cert.getNotBefore().toString() + \" and \" + cert.getNotAfter().toString() + \", thumbprint is \" + thumbprint);\n" \
        "    log.debug(\"builder initialized; pre-params: {}\", bldr.getEvent());\n" \
        "    log.debug(\"sending event {}.\", bldr.getEvent());\n" \
        "    log.debug(\"sent\");\n" \
        "} else {\n" \
        "    log.debug(\"nodeLostService event but is not for TLS-Cert-Expire, is '{}'\", event.service);\n" \
        "}"
      )
    }
  end

  describe event_script('beanshell') do
    it { should exist }
    its('uei') { should eq 'uei.opennms.org/vendor/Telco/traps/prvtLmmTemperatureThresholdCrossed' }
    its('script') {
      should include(
        "log = bsf.lookupBean(\"log\");\n" \
        "log.debug(\"prvtLmmInterfaceTempValue: {}\", tempValue);\n\n" \
        "log.debug(\"prvtLmmInterfaceTempThresholdLo: {}\", tempThresholdLo);\n" \
        "log.debug(\"prvtLmmInterfaceTempThresholdHi: {}\", tempThresholdHi);\n" \
        "if ((tempValue < tempThresholdLo) || (tempValue > tempThresholdHi)) {\n" \
        "    log.debug(\"Sending new event: {}\", org.opennms.core.xml.JaxbUtils.marshal(bldr.getEvent()));\n" \
        "    EventIpcManagerFactory.getIpcManager().sendNow(bldr.getEvent());\n" \
        "} else {\n" \
        "    log.debug(\"value is inside the threshold: do nothing\");\n" \
        "}"
      )
    }
  end

  describe event_script('beanshell') do
    it { should exist }
    its('uei') { should eq 'uei.opennms.org/vendor/Telco/traps/prvtLmmTxPowerThresholdCrossed' }
    its('script') {
      should include(
        "log = bsf.lookupBean(\"log\");\n" \
        "log.debug(\"prvtLmmInterfaceTxPowerValue: {}\", txPowerValue);\n\n" \
        "log.debug(\"prvtLmmInterfaceTxPowerThresholdTxLo: {}\", txPowerThresholdLo);\n" \
        "log.debug(\"prvtLmmInterfaceTxPowerThresholdTxHi: {}\", txPowerThresholdHi);\n" \
        "if ((txPowerValue < txPowerThresholdLo) || (txPowerValue > txPowerThresholdHi)) {\n" \
        "    log.debug(\"Sending new event: {}\", org.opennms.core.xml.JaxbUtils.marshal(bldr.getEvent()));\n" \
        "    EventIpcManagerFactory.getIpcManager().sendNow(bldr.getEvent());\n" \
        "} else {\n" \
        "    log.debug(\"value is inside the threshold: do nothing\");\n" \
        "}"
      )
    }
  end

  describe event_script('beanshell') do
    it { should exist }
    its('uei') { should eq 'uei.opennms.org/vendor/Telco/traps/prvtLmmRxPowerThresholdCrossed' }
    its('script') {
      should include(
        "log = bsf.lookupBean(\"log\");\n" \
        "log.debug(\"prvtLmmInterfaceRxPowerValue: {}\", rxPowerValue);\n\n" \
        "log.debug(\"prvtLmmInterfaceRxPowerThresholdTxLo: {}\", rxPowerThresholdLo);\n" \
        "log.debug(\"prvtLmmInterfaceRxPowerThresholdTxHi: {}\", rxPowerThresholdHi);\n" \
        "if ((rxPowerValue < rxPowerThresholdLo) || (rxPowerValue > rxPowerThresholdHi)) {\n" \
        "    log.debug(\"Sending new event: {}\", org.opennms.core.xml.JaxbUtils.marshal(bldr.getEvent()));\n" \
        "    EventIpcManagerFactory.getIpcManager().sendNow(bldr.getEvent());\n" \
        "} else {\n" \
        "    log.debug(\"value is inside the threshold: do nothing\");\n" \
        "}"
      )
    }
  end
end
