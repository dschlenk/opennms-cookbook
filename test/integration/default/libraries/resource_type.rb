# frozen_string_literal: true
class ResourceType < Inspec.resource(1)
  name 'resource_type'

  desc '
    OpenNMS resource_type
  '

  example '
    describe resource_type(\'wibbleWobble\', \'metasyntactic\') do,
      it { should exist }
      its(\'label\') { should eq \'Wibble Wobble\' }
      its(\'resource_label\') { should eq \'${wibble} - ${wobble}\' }
      its(\'persistence_selector_strategy\') { should eq \'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy\' }
      its(\'persistence_selector_strategy_params\') { should eq [{ \'theKey\' => \'theValue\' }] }
      its(\'storage_strategy\') { should eq \'org.opennms.netmgt.collection.support.IndexStorageStrategy\' }
      its(\'storage_strategy_params\') { should eq [{ \'theKey\' => \'theValue\' }] }
    end
  '

  def initialize(name, group_name)
    fn = find_group_file('/opt/opennms', group_name)
    doc = REXML::Document.new(inspec.file(fn).content)
    r_el = doc.elements["/datacollection-group[@name='#{group_name}']/resourceType[@name = '#{name}']"]
    @exists = !r_el.nil?
    if @exists
      @params = {}
      @params[:label] = r_el.attributes['label'].to_s
      @params[:resource_label] = r_el.attributes['resourceLabel'].to_s
      @params[:persistence_selector_strategy] = r_el.elements['persistenceSelectorStrategy'].attributes['class'].to_s
      @params[:persistence_selector_strategy_params] = []
      unless r_el.elements['persistenceSelectorStrategy/parameter'].nil?
        r_el.each_element('persistenceSelectorStrategy/parameter') do |p|
          @params[:persistence_selector_strategy_params].push(p.attributes['key'].to_s => p.attributes['value'].to_s)
        end
      end
      @params[:storage_strategy] = r_el.elements['storageStrategy'].attributes['class'].to_s
      @params[:storage_strategy_params] = []
      unless r_el.elements['storageStrategy/parameter'].nil?
        r_el.each_element('storageStrategy/parameter') do |p|
          @params[:storage_strategy_params].push(p.attributes['key'].to_s => p.attributes['value'].to_s)
        end
      end
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end

  private

  def find_group_file(onms_home, group)
    file_name = nil
    files = inspec.command("ls -1 #{onms_home}/etc/datacollection").stdout
    files.each_line do |g|
      g.chomp!
      next if g !~ /.*\.xml$/
      file = inspec.file("#{onms_home}/etc/datacollection/#{g}").content
      doc = REXML::Document.new file
      exists = !doc.elements["/datacollection-group[@name='#{group}']"].nil?
      next unless exists
      file_name = "#{onms_home}/etc/datacollection/#{g}"
      break
    end
    file_name
  end
end
