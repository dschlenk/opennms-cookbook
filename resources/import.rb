include Opennms::Cookbook::Provision::ModelImportHttpRequest
include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac

property :name, String, identity: true
property :foreign_source_name, String, default: 'imported:'
property :sync_import, [TrueClass, FalseClass], default: false
property :sync_wait_periods, Integer, default: 30
property :sync_wait_secs, Integer, default: 10

load_current_value do |new_resource|
  fs_resource_init(new_resource.foreign_source_name)
  model_import = REXML::Document.new(model_import(new_resource.name).message) unless model_import(new_resource.name).nil?
  model_import = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new(new_resource.foreign_source_name, "#{baseurl}/requisitions/#{new_resource.name}").message) if model_import.nil?
  current_value_does_not_exist! if model_import.nil?
  Chef::Log.debug "add_import response is: #{model_import}"
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Rbac
end

action :create do
  converge_if_changed do
    fs_resource_init(new_resource.foreign_source_name)
    model_import_init(new_resource.name, new_resource.foreign_source_name)
    model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root
    model_import(new_resource.foreign_source_name).message model_import.to_s
    if !new_resource.sync_import.nil? && new_resource.sync_import
      model_import_sync(new_resource.name, new_resource.foreign_source_name, true)
    end
  end
end

action :sync do
  converge_if_changed do
    fs_resource_init(new_resource.foreign_source_name)
    model_import_init(new_resource.name, new_resource.foreign_source_name)
    model_import_sync(new_resource.name, new_resource.foreign_source_name, true)
  end
end