class ResourceType < Inspec.resource(1)
  name 'resource_type'

  desc '
    OpenNMS resource_type
  '

  example '
    describe resource_type(\'wibbleWobble\', \'metasyntactic\', \'resource-type.xml\') do,
      it { should exist }
      its(\'label\') { should eq \'Wibble Wobble\' }
      its(\'resource_label\') { should eq \'${wibble} - ${wobble}\' }
      its(\'persistence_selector_strategy\') { should eq \'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy\' }
      its(\'persistence_selector_strategy_params\') { should eq [{ \'theKey\' => \'theValue\' }] }
      its(\'storage_strategy\') { should eq \'org.opennms.netmgt.collection.support.IndexStorageStrategy\' }
      its(\'storage_strategy_params\') { should eq [{ \'theKey\' => \'theValue\' }] }
    end
  '

  def initialize(name, group_name, file_name = nil)
    # fn = find_group_file('/opt/opennms', group_name)
    return if group_name.nil? && file_name.nil?
    if group_name.nil?
      fn = "/opt/opennms/etc/resource-types.d/#{file_name}"
      xpath = "resource-types/resourceType[@name = '#{name}']"
    else
      fn = "/opt/opennms/etc/datacollection/#{group_name}.xml"
      xpath = "/datacollection-group/resourceType[@name = '#{name}']"
    end
    doc = REXML::Document.new(inspec.file(fn).content)
    r_el = doc.elements[xpath]
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
end
