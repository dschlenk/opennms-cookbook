module Opennms
  module Cookbook
    module Statsd
      module StatsdTemplate
        def statsd_resource_init
          statsd_resource_create unless statsd_resource_exist?
        end

        def statsd_resource
          return unless statsd_resource_exist?
          find_resource!(:template, "#{onms_etc}/statsd-configuration.xml")
        end

        private

        def statsd_resource_exist?
          !find_resource(:template, "#{onms_etc}/statsd-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def statsd_resource_create
          file = Opennms::Cookbook::Statsd::StatsdConfiguration.new
          file.read!("#{onms_etc}/statsd-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/statsd-configuration.xml") do
              cookbook 'opennms'
              source 'statsd-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :create
              notifies :run, 'opennms_send_event[restart_Statsd]'
            end
          end
        end
      end

      class StatsdConfiguration
        include Opennms::XmlHelper
        attr_reader :packages
        def initialize
          @packages = []
        end

        def read!(file = 'statsd-configuration.xml')
          doc = xmldoc_from_file(file)
          doc.each_element('/statistics-daemon-configuration/package') do |package|
            name = package.attributes['name']
            filter = xml_element_text(package, 'filter')
            package_reports = [] unless package.elements['packageReport'].nil?
            package.each_element('packageReport') do |pr|
              report_name = pr.attributes['name']
              description = pr.attributes['description']
              schedule = pr.attributes['schedule']
              retain_interval = pr.attributes['retainInterval'].to_i
              status = pr.attributes['status']
              params = {} unless pr.elements['parameter'].nil?
              pr.each_element('parameter') do |parameter|
                params[parameter.attributes['key']] = parameter.attributes['value']
              end
              class_name = doc.elements["/statistics-daemon-configuration/report[@name = '#{report_name}']"].attributes['class-name']
              package_reports.push(StatsdReport.new(name: report_name, description: description, schedule: schedule, retain_interval: retain_interval, status: status, parameters: params, class_name: class_name))
            end
            @packages.push(StatsdPackage.new(name: name, filter: filter, reports: package_reports))
          end
        end

        def package(name:)
          package = @packages.select { |p| p.name.eql?(name) }
          return if package.empty?
          raise DuplicateStatsdPackage, "More than one package named #{name} found in statsd-configuration.xml" unless package.one?
          package.pop
        end

        def add_package(name:, filter: nil)
          @packages.push(StatsdPackage.new(name: name, filter: filter))
        end

        def delete_package(name:)
          @packages.delete_if { |p| p.name.eql?(name) }
        end

        def self.read(file = 'statsd-configuration.xml')
          sc = StatsdConfiguration.new
          sc.read!(file)
          sc
        end
      end

      class StatsdPackage
        attr_reader :name, :filter, :reports

        def initialize(name:, filter: nil, reports: nil)
          @name = name
          @filter = filter
          @reports = reports || []
        end

        def report(name:)
          report = @reports.select { |r| r.name.eql?(name) }
          return if report.empty?
          raise DuplicatePackageReport, "More than one report named #{name} found in package #{@name}." unless report.one?
          report.pop
        end

        def add_report(**properties)
          @reports.push(StatsdReport.new(**properties))
        end

        def delete_report(name:)
          @reports.delete_if { |r| r.name.eql?(name) }
        end

        def update(filter:)
          @filter = filter unless filter.nil?
        end
      end

      class StatsdReport
        attr_reader :name, :description, :schedule, :retain_interval, :status, :parameters, :class_name
        def initialize(name:, description:, schedule:, retain_interval:, status:, parameters:, class_name:)
          @name = name
          @description = description
          @schedule = schedule
          @retain_interval = retain_interval
          @status = status
          @parameters = parameters
          @class_name = class_name
        end

        def update(description: nil, schedule: nil, retain_interval: nil, status: nil, parameters: nil, class_name: nil)
          @description = description unless description.nil?
          @schedule = schedule unless schedule.nil?
          @retain_interval = retain_interval unless retain_interval.nil?
          @status = status unless status.nil?
          @parameters = parameters unless parameters.nil?
          @class_name = class_name unless class_name.nil?
        end
      end
    end
  end
end
