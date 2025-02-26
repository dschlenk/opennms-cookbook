module Opennms
  module Cookbook
    module ConfigHelpers
      module SnmpConfigTemplate
        def xml_resource_init
          xml_resource_create unless xml_resource_exist?
        end

        def xml_resource
          return unless xml_resource_exist?
          find_resource!(:template, "#{node['opennms']['conf']['home']}/etc/snmp-config.xml")
        end

        private

        def xml_resource_exist?
          !find_resource(:template, "#{node['opennms']['conf']['home']}/etc/snmp-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def xml_resource_create
          snmp_config = Opennms::Cookbook::ConfigHelpers::SnmpConfig::SnmpConfigFile.new
          snmp_config.read!("#{node['opennms']['conf']['home']}/etc/snmp-config.xml") if ::File.exist?("#{node['opennms']['conf']['home']}/etc/snmp-config.xml")
          with_run_context :root do
            declare_resource(:template, "#{node['opennms']['conf']['home']}/etc/snmp-config.xml") do
              source 'snmp-config.xml.erb'
              cookbook 'opennms'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0600'
              variables(snmp_config: snmp_config)
              action :nothing
              delayed_action :create
            end
          end
        end
      end

      module SnmpConfig
        module Helper
          def self.attributes_from_properties(r1, r2)
            v1v2 = true
            v1v2 = false if r2.version == 'v3'
            r1.port = r2.port
            r1.timeout = r2.timeout
            r1.retry_count = r2.retry_count
            r1.max_vars_per_pdu = r2.max_vars_per_pdu
            r1.max_repetitions = r2.max_repetitions
            r1.max_request_size = r2.max_request_size
            r1.ttl = r2.ttl
            r1.security_level = r2.security_level unless v1v2
            r1.version = r2.version
            r1.read_community = r2.read_community if v1v2
            r1.write_community = r2.write_community if v1v2
            r1.proxy_host = r2.proxy_host
            r1.security_name = r2.security_name unless v1v2
            r1.auth_passphrase = r2.auth_passphrase unless v1v2
            r1.auth_protocol = r2.auth_protocol unless v1v2
            r1.engine_id = r2.engine_id unless v1v2
            r1.context_engine_id = r2.context_engine_id unless v1v2
            r1.context_name = r2.context_name unless v1v2
            r1.privacy_passphrase = r2.privacy_passphrase unless v1v2
            r1.privacy_protocol = r2.privacy_protocol unless v1v2
            r1.enterprise_id = r2.enterprise_id unless v1v2
            r1.encrypted = r2.encrypted
          end

          def attrs_from_attributes(obj, el)
            v1v2 = true
            v1v2 = false if av_to_s(el, 'version') == 'v3'
            # Integers
            obj.port = av_to_i(el, 'port')
            obj.timeout = av_to_i(el, 'timeout')
            obj.retry_count = av_to_i(el, 'retry')
            obj.max_vars_per_pdu = av_to_i(el, 'max-vars-per-pdu')
            obj.max_repetitions = av_to_i(el, 'max-repetitions')
            obj.max_request_size = av_to_i(el, 'max-request-size')
            obj.ttl = av_to_i(el, 'ttl')
            obj.security_level = av_to_i(el, 'security-level') unless v1v2
            # Strings
            obj.version = av_to_s(el, 'version')
            obj.read_community = av_to_s(el, 'read-community') if v1v2
            obj.write_community = av_to_s(el, 'write-community') if v1v2
            obj.proxy_host = av_to_s(el, 'proxy-host')
            obj.security_name = av_to_s(el, 'security-name') unless v1v2
            obj.auth_passphrase = av_to_s(el, 'auth-passphrase') unless v1v2
            obj.auth_protocol = av_to_s(el, 'auth-protocol') unless v1v2
            obj.engine_id = av_to_s(el, 'engine-id') unless v1v2
            obj.context_engine_id = av_to_s(el, 'context-engine-id') unless v1v2
            obj.context_name = av_to_s(el, 'context-name') unless v1v2
            obj.privacy_passphrase = av_to_s(el, 'privacy-passphrase') unless v1v2
            obj.privacy_protocol = av_to_s(el, 'privacy-protocol') unless v1v2
            obj.enterprise_id = av_to_s(el, 'enterprise-id') unless v1v2
            # Booleans
            obj.encrypted = av_to_b(el, 'encrypted')
          end

          def av_to_i(el, at)
            return el.attribute(at).value.to_i unless el.attribute(at).nil?
            nil
          end

          def av_to_s(el, at)
            return el.attribute(at).value unless el.attribute(at).nil?
            nil
          end

          def av_to_b(el, at)
            return el.attribute(at).value.downcase == true unless el.attribute(at).nil?
            nil
          end
        end

        class SnmpConfig
          attr_accessor :version, :port, :read_community, :write_community, :timeout, :retry_count, :proxy_host, :max_vars_per_pdu, :max_repetitions, :max_request_size, :ttl, :encrypted, :security_name, :security_level, :auth_passphrase, :auth_protocol, :engine_id, :context_engine_id, :context_name, :privacy_passphrase, :privacy_protocol, :enterprise_id
          def to_s
            "version='#{@version}', port='#{@port}', read_community='#{@read_community}', write_community='#{@write_community}', timeout='#{@timeout}', retry_count='#{@retry_count}', proxy_host='#{@proxy_host}', max_vars_per_pdu='#{@max_vars_per_pdu}', max_repetitions='#{@max_repetitions}', max_request_size='#{@max_request_size}', ttl='#{@ttl}', encrypted='#{@encrypted}', security_name='#{@security_name}', security_level'#{@security_level}', auth_passphrase='#{@auth_passphrase}', auth_protocol='#{@auth_protocol}', engine_id='#{@engine_id}', context_engine_id='#{@context_engine_id}', context_name='#{@context_name}', privacy_passphrase='#{@privacy_passphrase}', privacy_protocol='#{@privacy_protocol}', enterprise_id='#{@enterprise_id}'"
          end
        end

        class SnmpConfigFile < SnmpConfig
          include Opennms::Cookbook::ConfigHelpers::SnmpConfig::Helper
          attr_accessor :definitions, :profiles

          def initialize
            @definitions = []
            @profiles = []
          end

          def to_s
            super + ", definitions count='#{@definitions.length}', profiles count='#{@profiles.length}'"
          end

          def read!(file = 'snmp-config.xml', _sort = false)
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

            f = ::File.new(file, 'r')
            doc = REXML::Document.new f
            f.close
            sc = doc.elements['/snmp-config']
            unless sc.nil?
              if sc.has_attributes?
                attrs_from_attributes(self, sc)
              end
              sc.each_element('definition') do |d|
                definition = SnmpConfigFileDefinition.new
                if d.has_attributes?
                  attrs_from_attributes(definition, d)
                  definition.location = av_to_s(d, 'location')
                  definition.profile_label = av_to_s(d, 'profile-label')
                end
                d.each_element('range') do |r|
                  if r.has_attributes? && !r.attribute('begin').nil? && !r.attribute('end').nil?
                    definition.ranges.push(r.attribute('begin').value => r.attribute('end').value)
                  end
                end
                d.each_element('specific') do |s|
                  definition.specifics.push(s.texts.join('').strip)
                end
                d.each_element('ip-match') do |i|
                  definition.ip_matches.push(i.texts.join('').strip)
                end
                @definitions.push(definition)
              end
              sc.each_element('profiles/profile') do |p|
                profile = SnmpConfigFileProfile.new
                if p.has_attributes?
                  attrs_from_attributes(profile, p)
                end
                profile.label = p.elements['label'].texts.join('').strip unless p.elements['label'].nil?
                profile.filter = p.elements['filter'].texts.join('').strip unless p.elements['filter'].nil?
                @profiles.push(profile)
              end
            end
            self
          end

          def add_definition(definition)
            raise SnmpConfigInvalidDefinition unless definition.is_a?(SnmpConfigFileDefinition)
            d = definition(definition.port, definition.retry_count, definition.timeout, definition.read_community, definition.write_community, definition.proxy_host, definition.version, definition.max_vars_per_pdu, definition.max_repetitions, definition.max_request_size, definition.ttl, definition.encrypted, definition.security_name, definition.security_level, definition.auth_passphrase, definition.auth_protocol, definition.engine_id, definition.context_engine_id, definition.context_name, definition.privacy_passphrase, definition.privacy_protocol, definition.enterprise_id, definition.location, definition.profile_label)
            if !d
              @definitions.push(definition)
            else
              if d.ranges.nil?
                d.ranges = definition.ranges
              else
                d.ranges.push(*definition.ranges)
                d.ranges.uniq!
              end
              if d.specifics.nil?
                d.specifics = definition.specifics
              else
                d.specifics.push(*definition.specifics)
                d.specifics.uniq!
              end
              if d.ip_matches.nil?
                d.ip_matches = definition.ip_matches
              else
                d.ip_matches.push(*definition.ip_matches)
                d.ip_matches.uniq!
              end
            end
          end

          def add_profile(profile)
            raise SnmpConfigInvalidProfile unless profile.is_a?(SnmpConfigFileProfile)
            p = profile(profile.label)
            if !p
              @profiles.push(profile)
            else
              # update existing profile `p` with `profile`'s attributes
              Opennms::Cookbook::ConfigHelpers::SnmpConfig::Helper.attributes_from_properties(p, profile)
              p.filter = profile.filter
            end
          end

          def remove_definition(definition)
            raise SnmpConfigInvalidDefinition unless definition.is_a?(SnmpConfigFileDefinition)
            d = definition(definition.port, definition.retry_count, definition.timeout, definition.read_community, definition.write_community, definition.proxy_host, definition.version, definition.max_vars_per_pdu, definition.max_repetitions, definition.max_request_size, definition.ttl, definition.encrypted, definition.security_name, definition.security_level, definition.auth_passphrase, definition.auth_protocol, definition.engine_id, definition.context_engine_id, definition.context_name, definition.privacy_passphrase, definition.privacy_protocol, definition.enterprise_id, definition.location, definition.profile_label)
            @definitions.reject! { |dd| dd.match?(d.port, d.retry_count, d.timeout, d.read_community, d.write_community, d.proxy_host, d.version, d.max_vars_per_pdu, d.max_repetitions, d.max_request_size, d.ttl, d.encrypted, d.security_name, d.security_level, d.auth_passphrase, d.auth_protocol, d.engine_id, d.context_engine_id, d.context_name, d.privacy_passphrase, d.privacy_protocol, d.enterprise_id, d.location, d.profile_label) }
          end

          def remove_profile(profile)
            raise SnmpConfigInvalidProfile unless profile.is_a?(SnmpConfigFileProfile)
            p = profile(profile.label)
            @profiles.reject! { |pp| pp.match?(p.label) }
          end

          def definition(port = nil, retry_count = nil, timeout = nil, read_community = nil, write_community = nil, proxy_host = nil, version = nil, max_vars_per_pdu = nil, max_repetitions = nil, max_request_size = nil, ttl = nil, encrypted = nil, security_name = nil, security_level = nil, auth_passphrase = nil, auth_protocol = nil, engine_id = nil, context_engine_id = nil, context_name = nil, privacy_passphrase = nil, privacy_protocol = nil, enterprise_id = nil, location = nil, profile_label = nil)
            # get a list of definitions that match d's identity
            # if not found return nil
            # raise an error if more than one found
            # return the single item left in the list via pop
            definition = @definitions.select { |dd| dd.match?(port, retry_count, timeout, read_community, write_community, proxy_host, version, max_vars_per_pdu, max_repetitions, max_request_size, ttl, encrypted, security_name, security_level, auth_passphrase, auth_protocol, engine_id, context_engine_id, context_name, privacy_passphrase, privacy_protocol, enterprise_id, location, profile_label) }

            return if definition.empty?

            raise SnmpConfigDefinitionDuplicateEntry, "Duplicate SNMP Config Definition found matching #{definition}" unless definition.one?

            definition.pop
          end

          def profile(label)
            profile = @profiles.select { |p| p.match?(label) }
            return if profile.empty?

            raise SnmpConfigProfileDuplicateEntry, "Duplicate SNMP Config Profile found with label #{label}" unless profile.one?
            profile.pop
          end

          def self.read(file = 'snmp-config.xml', sort: false)
            snmp_config = new
            snmp_config.read!(file, sort: sort)
            snmp_config
          end
        end

        class SnmpConfigFileDefinition < SnmpConfig
          attr_accessor :location, :profile_label, :ranges, :specifics, :ip_matches
          def initialize
            super
            @ranges = []
            @specifics = []
            @ip_matches = []
          end

          def to_s
            super + ", location='#{@location}', profile_label='#{@profile_label}', ranges='#{@ranges.nil? ? 'nil' : @ranges.length}', specifics='#{@specifics.nil? ? 'nil' : @specifics.length}', ip_matches='#{@ip_matches.nil? ? 'nil' : @ip_matches.length}'"
          end

          def match?(port = nil, retry_count = nil, timeout = nil, read_community = nil, write_community = nil, proxy_host = nil, version = nil, max_vars_per_pdu = nil, max_repetitions = nil, max_request_size = nil, ttl = nil, encrypted = nil, security_name = nil, security_level = nil, auth_passphrase = nil, auth_protocol = nil, engine_id = nil, context_engine_id = nil, context_name = nil, privacy_passphrase = nil, privacy_protocol = nil, enterprise_id = nil, location = nil, profile_label = nil)
            return true if port.eql?(@port) && retry_count.eql?(@retry_count) && timeout.eql?(@timeout) && read_community.eql?(@read_community) && write_community.eql?(@write_community) && proxy_host.eql?(@proxy_host) && version.eql?(@version) && max_vars_per_pdu.eql?(@max_vars_per_pdu) && max_repetitions.eql?(@max_repetitions) && max_request_size.eql?(@max_request_size) && ttl.eql?(@ttl) && encrypted.eql?(@encrypted) && security_name.eql?(@security_name) && security_level.eql?(@security_level) && auth_passphrase.eql?(@auth_passphrase) && auth_protocol.eql?(@auth_protocol) && engine_id.eql?(@engine_id) && context_engine_id.eql?(@context_engine_id) && context_name.eql?(@context_name) && privacy_passphrase.eql?(@privacy_passphrase) && privacy_protocol.eql?(@privacy_protocol) && enterprise_id.eql?(@enterprise_id) && location.eql?(@location) && profile_label.eql?(@profile_label)
            false
          end

          def eql?(d)
            return false unless self.class.eql?(d.class)
            return true if d.port.eql?(@port) && d.retry_count.eql?(@retry_count) && d.timeout.eql?(@timeout) && d.read_community.eql?(@read_community) && d.write_community.eql?(@write_community) && d.proxy_host.eql?(@proxy_host) && d.version.eql?(@version) && d.max_vars_per_pdu.eql?(@max_vars_per_pdu) && d.max_repetitions.eql?(@max_repetitions) && d.max_request_size.eql?(@max_request_size) && d.ttl.eql?(@ttl) && d.encrypted.eql?(@encrypted) && d.security_name.eql?(@security_name) && d.security_level.eql?(@security_level) && d.auth_passphrase.eql?(@auth_passphrase) && d.auth_protocol.eql?(@auth_protocol) && d.engine_id.eql?(@engine_id) && d.context_engine_id.eql?(@context_engine_id) && d.context_name.eql?(@context_name) && d.privacy_passphrase.eql?(@privacy_passphrase) && d.privacy_protocol.eql?(@privacy_protocol) && d.enterprise_id.eql?(@enterprise_id) && d.location.eql?(@location) && d.profile_label.eql?(@profile_label) && d.ranges.eql?(@ranges) && d.specifics.eql?(@specifics) && d.ip_matches.eql?(@ip_matches)
            false
          end
        end

        class SnmpConfigFileProfile < SnmpConfig
          attr_accessor :label, :filter

          def to_s
            super + ", label='#{@label}', filter='#{@filter}'"
          end

          def match?(label)
            return true if label.eql?(@label)
            false
          end

          def eql?(p)
            return false unless self.class.eql?(p.class)
            return true if p.port.eql?(@port) && p.retry_count.eql?(@retry_count) && p.timeout.eql?(@timeout) && p.read_community.eql?(@read_community) && p.write_community.eql?(@write_community) && p.proxy_host.eql?(@proxy_host) && p.version.eql?(@version) && p.max_vars_per_pdu.eql?(@max_vars_per_pdu) && p.max_repetitions.eql?(@max_repetitions) && p.max_request_size.eql?(@max_request_size) && p.ttl.eql?(@ttl) && p.encrypted.eql?(@encrypted) && p.security_name.eql?(@security_name) && p.security_level.eql?(@security_level) && p.auth_passphrase.eql?(@auth_passphrase) && p.auth_protocol.eql?(@auth_protocol) && p.engine_id.eql?(@engine_id) && p.context_engine_id.eql?(@context_engine_id) && p.context_name.eql?(@context_name) && p.privacy_passphrase.eql?(@privacy_passphrase) && p.privacy_protocol.eql?(@privacy_protocol) && p.enterprise_id.eql?(@enterprise_id) && p.label.eql?(@label) && p.filter.eql?(@filter)
          end
        end

        class SnmpConfigInvalidDefinition < StandardError; end
        class SnmpConfigInvalidProfile < StandardError; end
        class SnmpConfigDefinitionDuplicateEntry < StandardError; end
        class SnmpConfigProfileDuplicateEntry < StandardError; end
      end
    end
  end
end
