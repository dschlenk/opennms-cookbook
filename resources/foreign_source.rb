include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac
property :scan_interval, String, default: '1d'

load_current_value do |new_resource|
  foreign_source = REXML::Document.new(fs_resource(new_resource.name).message) unless fs_resource(new_resource.name).nil?
  foreign_source = REXML::Document.new(Opennms::Cookbook::Provision::ForeignSource.new(new_resource.name, "#{baseurl}/foreignSources/#{new_resource.name}").message) if foreign_source.nil?
  current_value_does_not_exist! if foreign_source.nil?
  scan_interval xml_element_text(foreign_source.elements['/scan-interval'])
end

action_class do
  include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
  include Opennms::XmlHelper
  include Opennms::Rbac
end

action :create do
  converge_if_changed do
    fs_resource_init(new_resource.name)
    foreign_source = REXML::Document.new(fs_resource(new_resource.name).message).root
    if foreign_source.elements['/foreign-source/scan-interval'].nil?
      foreign_source.unshift(REXML::Element.new('scan-interval')).text = new_resource.scan_interval
    else
      foreign_source.elements['/foreign-source/scan-interval'].text = new_resource.scan_interval
    end
    fs_resource(new_resource.name).message foreign_source.to_s
  end
end
