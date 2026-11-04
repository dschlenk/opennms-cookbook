# frozen_string_literal: true

require 'base64'
require 'rest-client'
require 'rexml/document'

module Opennms
  module Cookbook
    module ConfigHelpers
      module SnmpConfigTemplate
        def xml_resource_init
          xml_resource_create unless xml_resource_exist?
        end

        def xml_resource
          return unless xml_resource_exist?
          find_resource!(:template, xml_template_path)
        end

        def ro_xml_resource_init
          ro_xml_resource_create unless ro_xml_resource_exist?
        end

        def ro_xml_resource
          return unless ro_xml_resource_exist?
          find_resource!(:template, "RO #{node['opennms']['conf']['home']}/etc/snmp-config.xml")
        end

        # On OpenNMS 36 the snmp-config is stored in the database and managed via the
        # v2 REST API instead of $OPENNMS_HOME/etc/snmp-config.xml
        def snmp_config_v36?
          node['opennms']['version'].to_i >= 36
        end

        # The snmp-config template resource: on OpenNMS 36 a scratch copy in the
        # file cache that is rendered and uploaded to the v2 API; on earlier
        # versions the real $OPENNMS_HOME/etc/snmp-config.xml
        def xml_template_path
          if snmp_config_v36?
            "#{Chef::Config[:file_cache_path]}/snmp-config.xml"
          else
            "#{node['opennms']['conf']['home']}/etc/snmp-config.xml"
          end
        end

        # The accumulated snmp config for this run: the result of a single
        # download (GET /snmp-config/download?format=xml) parsed into a
        # SnmpConfigFile, cached in the run state and shared by all resources,
        # so mutations made by earlier resources are visible to later ones
        def snmp_config_file
          node.run_state['opennms_snmp_config_file'] ||=
            Opennms::Cookbook::ConfigHelpers::SnmpConfig::SnmpConfigFile.load(snmp_config_document_xml, materialized: true)
        end

        # The pristine download, kept for the dirty check in
        # snmp_config_update_file: a run whose mutations net out to no change
        # uploads nothing
        def snmp_config_file_original
          node.run_state['opennms_snmp_config_file_original'] ||=
            Opennms::Cookbook::ConfigHelpers::SnmpConfig::SnmpConfigFile.load(snmp_config_document_xml, materialized: true)
        end

        # Read-modify-write of the accumulated snmp config: yield it for
        # mutation, then, only if the accumulated document differs from the
        # pristine download, make sure the end-of-run upload resource (POST
        # /snmp-config/upload/xml) exists. The upload is declared on the first
        # net change only, so a fully idempotent run makes exactly one API
        # call (the download)
        def snmp_config_update_file
          file = snmp_config_file
          yield file
          snmp_config_upload_resource_ensure if snmp_config_file_original != file
          file
        end

        private

        def snmp_config_document_xml
          node.run_state['opennms_snmp_config_xml'] ||= begin
            response = RestClient.get("#{restv2url}/snmp-config/download?format=xml", snmp_config_api_headers)
            response.body
          end
        end

        def snmp_config_api_headers
          { 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" }
        end

        # The http_request resource that uploads the accumulated document at the
        # end of the run, declared on the first net change only. The message is
        # a lazy block that the http_request provider evaluates when the
        # delayed POST runs, so it reads the rendered file as written by the
        # delayed template create that runs just before it; a run without a net
        # change never declares the resource and never posts
        def snmp_config_upload_resource_ensure
          return unless find_resource(:http_request, 'snmp config upload').nil?

          upload_url = "#{restv2url}/snmp-config/upload/xml"
          with_run_context :root do
            declare_resource(:http_request, 'snmp config upload') do
              url upload_url
              headers 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}",
                      'Content-Type' => "multipart/form-data; boundary=#{Opennms::Cookbook::ConfigHelpers::SnmpConfig::UPLOAD_BOUNDARY}"
              message lazy { Opennms::Cookbook::ConfigHelpers::SnmpConfig.snmp_config_upload_body(::File.read(xml_template_path)) }
              sensitive true
              action :nothing
              delayed_action :post
            end
          end
        end

        def xml_resource_exist?
          !find_resource(:template, xml_template_path).nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def xml_resource_create
          if snmp_config_v36?
            with_run_context :root do
              declare_resource(:template, xml_template_path) do
                source 'snmp-config.xml.erb'
                cookbook 'opennms'
                mode '0600'
                variables(snmp_config: snmp_config_file)
                action :nothing
                delayed_action :create
              end
            end
          else
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

        def ro_xml_resource_exist?
          !find_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/snmp-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_xml_resource_create
          snmp_config = Opennms::Cookbook::ConfigHelpers::SnmpConfig::SnmpConfigFile.new
          snmp_config.read!("#{node['opennms']['conf']['home']}/etc/snmp-config.xml") if ::File.exist?("#{node['opennms']['conf']['home']}/etc/snmp-config.xml")
          with_run_context :root do
            declare_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/snmp-config.xml") do
              path "#{Chef::Config[:file_cache_path]}/snmp-config.xml"
              source 'snmp-config.xml.erb'
              cookbook 'opennms'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0600'
              variables(snmp_config: snmp_config)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      module SnmpConfig
        # the fixed boundary for the multipart body of POST /snmp-config/upload/xml
        UPLOAD_BOUNDARY = 'opennms-snmp-config-xml-upload'

        # The numeric attributes the OpenNMS 36 server stores materialized on
        # upload: a definition or profile attribute that is unset in the
        # uploaded document is stored as the root element's value, or as the
        # schema default when the root element does not declare the attribute
        # (upstream is still deciding what the correct behavior is). A stored
        # value that equals that effective default is indistinguishable from
        # an unset attribute, so identity matching treats it as unset on
        # documents served by the v2 API. Each entry maps the attribute name
        # to its position in the definition()/match? argument list and the
        # schema default
        MATERIALIZED_ATTRIBUTES = { max_vars_per_pdu: [7, 10], max_repetitions: [8, 2], max_request_size: [9, 65_535] }.freeze

        # The multipart body for POST /snmp-config/upload/xml: a single form
        # field 'upload' carrying the XML document as a file part
        def self.snmp_config_upload_body(xml)
          boundary = UPLOAD_BOUNDARY
          body = +''
          body << "--#{boundary}\r\n"
          body << "Content-Disposition: form-data; name=\"upload\"; filename=\"snmp-config.xml\"\r\n"
          body << "Content-Type: application/xml\r\n"
          body << "\r\n"
          body << "#{xml}\r\n"
          body << "--#{boundary}--\r\n"
          body
        end

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
            "version='#{@version}', port='#{@port}', read_community='#{@read_community}', write_community='#{@write_community}', timeout='#{@timeout}', retry_count='#{@retry_count}', proxy_host='#{@proxy_host}', max_vars_per_pdu='#{@max_vars_per_pdu}', max_repetitions='#{@max_repetitions}', max_request_size='#{@max_request_size}', ttl='#{@ttl}', encrypted='#{@encrypted}', security_name='#{@security_name}', security_level='#{@security_level}', auth_passphrase='#{@auth_passphrase}', auth_protocol='#{@auth_protocol}', engine_id='#{@engine_id}', context_engine_id='#{@context_engine_id}', context_name='#{@context_name}', privacy_passphrase='#{@privacy_passphrase}', privacy_protocol='#{@privacy_protocol}', enterprise_id='#{@enterprise_id}'"
          end
        end

        class SnmpConfigFile < SnmpConfig
          include Opennms::Cookbook::ConfigHelpers::SnmpConfig::Helper
          attr_accessor :definitions, :profiles
          # true when the document was served by the v2 API download endpoint,
          # whose server stores unset attributes materialized (see
          # MATERIALIZED_ATTRIBUTES); documents parsed from local files keep
          # the strict pre-36 identity
          attr_accessor :materialized

          def initialize
            @definitions = []
            @profiles = []
          end

          def to_s
            super + ", definitions count='#{@definitions.length}', profiles count='#{@profiles.length}'"
          end

          # Parse the given XML document into a new config; the shared core of
          # read!. materialized marks a document served by the v2 API (see
          # MATERIALIZED_ATTRIBUTES)
          def self.load(content, materialized: false)
            snmp_config = new
            snmp_config.materialized = materialized
            snmp_config.parse!(content)
          end

          def parse!(content)
            doc = REXML::Document.new(content)
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
                profile.filter = p.elements['filter'].texts.join('').strip unless p.elements['filter'].nil? || p.elements['filter'].texts.join('').empty?
                @profiles.push(profile)
              end
            end
            self
          end

          def read!(file = 'snmp-config.xml', _sort = false)
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

            parse!(::File.read(file))
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
            identity = [port, retry_count, timeout, read_community, write_community, proxy_host, version, max_vars_per_pdu, max_repetitions, max_request_size, ttl, encrypted, security_name, security_level, auth_passphrase, auth_protocol, engine_id, context_engine_id, context_name, privacy_passphrase, privacy_protocol, enterprise_id, location, profile_label]
            definition = @definitions.select { |dd| definition_matches_identity?(dd, identity) }

            return if definition.empty?

            raise SnmpConfigDefinitionDuplicateEntry, "Duplicate SNMP Config Definition found matching #{definition}" unless definition.one?

            definition.pop
          end

          # Identity matching of a stored definition against a declared
          # identity. On a document served by the v2 API (materialized), the
          # server stores the unset max-vars-per-pdu, max-repetitions and
          # max-request-size materialized as the root element's value or the
          # schema default, which is indistinguishable from an unset
          # attribute: an unset declared attribute therefore also matches the
          # materialized stored value, while every set declared attribute
          # always matches strictly. Documents parsed from files keep the
          # strict pre-36 semantics
          def definition_matches_identity?(dd, identity)
            return dd.match?(*identity) unless materialized

            effective = identity.dup
            MATERIALIZED_ATTRIBUTES.each do |attribute, (position, schema_default)|
              stored = dd.send(attribute)
              next unless identity[position].nil? && !stored.nil? && stored == (send(attribute) || schema_default)

              effective[position] = stored
            end
            dd.match?(*effective)
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

          # Structural equality of two parsed configs: the root attributes plus
          # the definitions and the profiles. The definition and profile
          # classes' own eql? implementations do the element-wise comparison.
          # Used to decide whether a run's mutations changed the accumulated
          # document
          def eql?(other)
            return false unless self.class.eql?(other.class)
            return true if version.eql?(other.version) && port.eql?(other.port) && read_community.eql?(other.read_community) && write_community.eql?(other.write_community) && timeout.eql?(other.timeout) && retry_count.eql?(other.retry_count) && proxy_host.eql?(other.proxy_host) && max_vars_per_pdu.eql?(other.max_vars_per_pdu) && max_repetitions.eql?(other.max_repetitions) && max_request_size.eql?(other.max_request_size) && ttl.eql?(other.ttl) && encrypted.eql?(other.encrypted) && security_name.eql?(other.security_name) && security_level.eql?(other.security_level) && auth_passphrase.eql?(other.auth_passphrase) && auth_protocol.eql?(other.auth_protocol) && engine_id.eql?(other.engine_id) && context_engine_id.eql?(other.context_engine_id) && context_name.eql?(other.context_name) && privacy_passphrase.eql?(other.privacy_passphrase) && privacy_protocol.eql?(other.privacy_protocol) && enterprise_id.eql?(other.enterprise_id) && definitions.eql?(other.definitions) && profiles.eql?(other.profiles)
            false
          end

          alias_method :==, :eql?
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
