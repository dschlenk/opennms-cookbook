module Opennms
  module Cookbook
    module ConfigHelpers
      module Event
        module EventFiles
          def self.opennms_event_files
            [
              'opennms.snmp.trap.translator.events.xml',
              'opennms.ackd.events.xml',
              'opennms.alarm.events.xml',
              'opennms.bmp.events.xml',
              'opennms.bsm.events.xml',
              'opennms.capsd.events.xml',
              'opennms.collectd.events.xml',
              'opennms.config.events.xml',
              'opennms.correlation.events.xml',
              'opennms.default.threshold.events.xml',
              'opennms.discovery.events.xml',
              'opennms.hyperic.events.xml',
              'opennms.internal.events.xml',
              'opennms.linkd.events.xml',
              'opennms.mib.events.xml',
              'opennms.pollerd.events.xml',
              'opennms.provisioning.events.xml',
              'opennms.minion.events.xml',
              'opennms.perspective.poller.events.xml',
              'opennms.reportd.events.xml',
              'opennms.syslogd.events.xml',
              'opennms.ticketd.events.xml',
              'opennms.tl1d.events.xml',
            ]
          end

          def self.vendor_event_files
            [
              'GraphMLAssetPluginEvents.xml',
              '3Com.events.xml',
              'AdaptecRaid.events.xml',
              'ADIC-v2.events.xml',
              'Adtran.events.xml',
              'Adtran.Atlas.events.xml',
              'Aedilis.events.xml',
              'AirDefense.events.xml',
              'AIX.events.xml',
              'AKCP.events.xml',
              'AlcatelLucent.OmniSwitch.events.xml',
              'AlcatelLucent.SMSBrick.events.xml',
              'Allot.events.xml',
              'Allot.NetXplorer.events.xml',
              'Allot.SM.events.xml',
              'Alteon.events.xml',
              'Altiga.events.xml',
              'APC.events.xml',
              'APC.Best.events.xml',
              'APC.Exide.events.xml',
              'ApacheHTTPD.syslog.events.xml',
              'Aruba.AP.events.xml',
              'Aruba.Switch.events.xml',
              'Aruba.events.xml',
              'Ascend.events.xml',
              'ASYNCOS-MAIL-MIB.events.xml',
              'Avocent.ACS.events.xml',
              'Avocent.ACS5000.events.xml',
              'Avocent.AMX5000.events.xml',
              'Avocent.AMX5010.events.xml',
              'Avocent.AMX5020.events.xml',
              'Avocent.AMX5030.events.xml',
              'Avocent.CCM.events.xml',
              'Avocent.DSR.events.xml',
              'Avocent.DSR1021.events.xml',
              'Avocent.DSR2010.events.xml',
              'Avocent-DSView.events.xml',
              'Avocent.Mergepoint.events.xml',
              'Avocent.PMTrap.events.xml',
              'Audiocodes.events.xml',
              'A10.AX.events.xml',
              'ATMForum.events.xml',
              'BackupExec.events.xml',
              'BEA.events.xml',
              'BGP4.events.xml',
              'BladeNetwork.events.xml',
              'Bluecat.events.xml',
              'BlueCoat.events.xml',
              'Brocade.events.xml',
              'Broadcom-BASPTrap.events.xml',
              'CA.ArcServe.events.xml',
              'Ceragon-FA1500.events.xml',
              'Cisco.airespace.xml',
              'Cisco.CIDS.events.xml',
              'Cisco.5300dchan.events.xml',
              'Cisco.mcast.events.xml',
              'Cisco.SCE.events.xml',
              'Cisco2.events.xml',
              'Cisco.events.xml',
              'CitrixNetScaler.events.xml',
              'Colubris.events.xml',
              'ComtechEFData.events.xml',
              'Concord.events.xml',
              'Covergence.events.xml',
              'CPQHPIM.events.xml',
              'Clarent.events.xml',
              'Clarinet.events.xml',
              'Clavister.events.xml',
              'Compuware.events.xml',
              'Cricket.events.xml',
              'CRITAPP.events.xml',
              'Crossbeam.events.xml',
              'Dell-Asf.events.xml',
              'DellArrayManager.events.xml',
              'DellEquallogic.events.xml',
              'Dell-DRAC2.events.xml',
              'Dell-ITassist.events.xml',
              'Dell-F10-bgb4-v2.events.xml',
              'Dell-F10-chassis.events.xml',
              'Dell-F10-copy-config.events.xml',
              'Dell-F10-mstp.events.xml',
              'Dell-F10-system-component.events.xml',
              'DellOpenManage.events.xml',
              'DellRacHost.events.xml',
              'DellStorageManagement.events.xml',
              'DISMAN.events.xml',
              'DISMAN-PING.events.xml',
              'Dlink.events.xml',
              'DMTF.events.xml',
              'DPS.events.xml',
              'DS1.events.xml',
              'EMC.events.xml',
              'EMC-Celerra.events.xml',
              'EMC-Clariion.events.xml',
              'Evertz.7780ASI-IP2.events.xml',
              'Evertz.7880IP-ASI-IP.events.xml',
              'Evertz.7880IP-ASI-IP-FR.events.xml',
              'Evertz.7881DEC-MP2-HD.events.xml',
              'Extreme.events.xml',
              'F5.events.xml',
              'fcmgmt.events.xml',
              'Fore.events.xml',
              'Fortinet-FortiCore-v52.events.xml',
              'Fortinet-FortiGate-v52.events.xml',
              'Fortinet-FortiMail.events.xml',
              'Fortinet-FortiManager-Analyzer.events.xml',
              'Fortinet-FortiRecorder.events.xml',
              'Fortinet-FortiVoice.events.xml',
              'Fortinet-FortiCore-v4.events.xml',
              'Fortinet-FortiGate-v4.events.xml',
              'FoundryNetworks.events.xml',
              'FoundryNetworks2.events.xml',
              'FujitsuSiemens.events.xml',
              'GGSN.events.xml',
              'Groupwise.events.xml',
              'HP.events.xml',
              'HWg.Poseidon.events.xml',
              'Hyperic.events.xml',
              'IBM.events.xml',
              'IBM-UMS.events.xml',
              'IBMRSA2.events.xml',
              'IBM.EIF.events.xml',
              'IEEE802dot11.events.xml',
              'ietf.dlsw.events.xml',
              'ietf.docsis.events.xml',
              'ietf.events.xml',
              'ietf.ptopo.events.xml',
              'ietf.sna-dlc.events.xml',
              'ietf.tn3270e.events.xml',
              'ietf.vrrp.events.xml',
              'Infoblox.events.xml',
              'Intel.events.xml',
              'INTEL-LAN-ADAPTERS-MIB.events.xml',
              'InteractiveIntelligence.events.xml',
              'IronPort.events.xml',
              'ISS.events.xml',
              'IPUnity-SES-MIB.events.xml',
              'IPV6.events.xml',
              'Juniper.mcast.events.xml',
              'Juniper.events.xml',
              'Juniper.ive.events.xml',
              'Juniper.screen.events.xml',
              'Junos.events.xml',
              'JunosV1.events.xml',
              'K5Systems.events.xml',
              'Konica.events.xml',
              'LLDP.events.xml',
              'Liebert.events.xml',
              'Liebert.600SM.events.xml',
              'Linksys.events.xml',
              'LinuxKernel.syslog.events.xml',
              'Lucent.events.xml',
              'MadgeNetworks.events.xml',
              'McAfee.events.xml',
              'MGE-UPS.events.xml',
              'Microsoft.events.xml',
              'MikrotikRouterOS.events.xml',
              'Multicast.standard.events.xml',
              'MPLS.events.xml',
              'MRV.events.xml',
              'MSDP.events.xml',
              'Mylex.events.xml',
              'NetApp.events.xml',
              'Netbotz.events.xml',
              'Netgear.events.xml',
              'NetgearProsafeSmartSwitch.events.xml',
              'NetgearProsafeSmartSwitch.syslog.events.xml',
              'Netscreen.events.xml',
              'NetSNMP.events.xml',
              'Nokia.events.xml',
              'NORTEL.Contivity.events.xml',
              'Novell.events.xml',
              'OpenSSH.syslog.events.xml',
              'OpenWrt.syslog.events.xml',
              'Oracle.events.xml',
              'OSPF.events.xml',
              'Overland.events.xml',
              'Overture.events.xml',
              'Procmail.syslog.events.xml',
              'POSIX.syslog.events.xml',
              'Postfix.syslog.events.xml',
              'Packeteer.events.xml',
              'Patrol.events.xml',
              'PCube.events.xml',
              'Pingtel.events.xml',
              'Pixelmetrix.events.xml',
              'Polycom.events.xml',
              'Powerware.events.xml',
              'Primecluster.events.xml',
              'Quintum.events.xml',
              'Raytheon.events.xml',
              'RADLAN-MIB.events.xml',
              'RAPID-CITY.events.xml',
              'Redline.events.xml',
              'RFC1382.events.xml',
              'RFC1628.events.xml',
              'Rightfax.events.xml',
              'RiverbedSteelhead.events.xml',
              'RMON.events.xml',
              'Sensaphone.events.xml',
              'Sentry.events.xml',
              'Siemens-HiPath3000.events.xml',
              'Siemens-HiPath3000-HG1500.events.xml',
              'Siemens-HiPath4000.events.xml',
              'Siemens-HiPath8000-OpenScapeVoice.events.xml',
              'SNA-NAU.events.xml',
              'SNMP-REPEATER.events.xml',
              'Snort.events.xml',
              'SonicWall.events.xml',
              'Sonus.events.xml',
              'Sudo.syslog.events.xml',
              'SunILOM.events.xml',
              'Symbol.events.xml',
              'Syslogd.events.xml',
              'SystemEdge.events.xml',
              'SwissQual.events.xml',
              'TransPath.events.xml',
              'Trendmicro.events.xml',
              'TrippLite.events.xml',
              'TUT.events.xml',
              'UPS-MIB.events.xml',
              'Uptime.events.xml',
              'Veeam_Backup-Replication.events.xml',
              'Veraz.events.xml',
              'VMWare.env.events.xml',
              'VMWare.vc.events.xml',
              'VMWare.vminfo.events.xml',
              'VMWare.obsolete.events.xml',
              'VMWare.events.xml',
              'Waverider.3000.events.xml',
              'Websense.events.xml',
              'Xerox-V2.events.xml',
              'Xerox.events.xml',
            ]
          end

          def self.catch_all_event_file
            'opennms.catch-all.events.xml'
          end

          def self.secure_fields
            [
              'logmsg',
              'operaction',
              'autoaction',
              'tticket',
              'script'
            ]
          end
        end

        module EventConfTemplate
          def eventconf_resource_init
            eventconf_resource_create unless eventconf_resource_exist?
          end

          def eventconf_resource
            return unless eventconf_resource_exist?
            find_resource!(:template, "#{node['opennms']['conf']['home']}/etc/eventconf.xml")
          end

          private

          def eventconf_resource_exist?
            !find_resource(:template, "#{node['opennms']['conf']['home']}/etc/eventconf.xml").nil?
          rescue Chef::Exceptions::ResourceNotFound
            false
          end

          def eventconf_resource_create
            eventconf = Opennms::Cookbook::ConfigHelpers::Event::EventConf.new
            eventconf.read!("#{node['opennms']['conf']['home']}/etc/eventconf.xml") if ::File.exist?("#{node['opennms']['conf']['home']}/etc/eventconf.xml")
            with_run_context :root do
              declare_resource(:template, "#{node['opennms']['conf']['home']}/etc/eventconf.xml") do
                source 'eventconf.xml.erb'
                cookbook 'opennms'
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode 0664
                variables(eventconf: eventconf, 
                          opennms_event_files: Opennms::Cookbook::ConfigHelpers::Event::EventFiles.opennms_event_files,
                          vendor_event_files: Opennms::Cookbook::ConfigHelpers::Event::EventFiles.vendor_event_files,
                          catch_all_event_file: Opennms::Cookbook::ConfigHelpers::Event::EventFiles.catch_all_event_file,
                          secure_fields: Opennms::Cookbook::ConfigHelpers::Event::EventFiles.secure_fields,
                         )
                action :nothing
                delayed_action :create
                notifies :run, 'opennms_send_event[restart_Eventd]'
              end
            end
          end
        end

        class EventConf
          attr_reader :event_files

          def initialize
            @event_files = {}
          end

          def read!(file = 'eventconf.xml')
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
            f = ::File.new(file, 'r')
            doc = REXML::Document.new f
            f.close
            position = 'override'
            ec = doc.each_element('/events/event-file') do |ef|
              event_file = ef.texts.join('').strip[7..-1] if !ef.nil? && ef.respond_to?(:texts) && ef.texts.join('').strip.length > 7
              if Opennms::Cookbook::ConfigHelpers::Event::EventFiles.opennms_event_files.include?(event_file)
                position = 'top' if position != 'top'
                next
              end
              if Opennms::Cookbook::ConfigHelpers::Event::EventFiles.vendor_event_files.include?(event_file)
                position = 'bottom' if position != 'bottom'
                next
              end
              break if event_file == Opennms::Cookbook::ConfigHelpers::Event::EventFiles.catch_all_event_file
              # @event_files = {} if @event_files.nil?
              @event_files[event_file] = { :position => position }
            end
          end

          def self.read(file = 'eventconf.xml')
            eventconf = new
            eventconf.read!(file)
            eventconf
          end
        end
      end
    end
  end
end

