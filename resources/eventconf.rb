unified_mode true

property :event_file, String, name_property: true, identity: true
property :source_name, String, alias: true
property :vendor, String
property :description, String
property :position, String, equal_to: %w(override top bottom), default: 'bottom', desired_state: false

action_class do
  include Opennms::Cookbook::EventConf::HttpRequest
  include Opennms::Rbac

  def source_name_from_event_file
    name = new_resource.event_file.to_s
    name = name.sub(%r{^events/}, '')
    name = name.sub(/\.xml$/, '')
    name
  end

  def vendor_from_name(name)
    return new_resource.vendor if new_resource.vendor
    if name.include?('-')
      name.split('-').first
    elsif name.include?('.')
      name.split('.').first
    else
      name
    end
  end
end

load_current_value do |new_resource|
  src_name = source_name_from_event_file
  eventconf_source_resource_init(src_name)
  res = eventconf_source(src_name)
  current_value_does_not_exist! if res.nil?
  # Position is not stored in REST, keep as is
end

action :create do
  src_name = source_name_from_event_file
  eventconf_source_resource_init(src_name)
  res = eventconf_source(src_name)
  converge_if_changed do
    payload = {
      name: src_name,
      description: new_resource.description,
      vendor: vendor_from_name(src_name)
    }.compact
    res.message payload.to_json
  end
end

action :create_if_missing do
  # existence check via load_current_value
  run_action(:create)
end

action :delete do
  src_name = source_name_from_event_file
  # Delete source via REST
  require 'net/http'
  require 'json'
  uri = URI("http://localhost:8980/opennms/api/v2/eventconf/sources/names-and-ids")
  req = Net::HTTP::Get.new(uri)
  res_http = Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
  if res_http.is_a?(Net::HTTPSuccess)
    data = JSON.parse(res_http.body)
    entry = data.find { |s| s['name'] == src_name }
    if entry
      uri_del = URI("http://localhost:8980/opennms/api/v2/eventconf/sources")
      http = Net::HTTP.new(uri_del.host, uri_del.port)
      req_del = Net::HTTP::Delete.new(uri_del.path, 'Content-Type' => 'application/json')
      req_del.body = { sourceIds: [entry['id']] }.to_json
      http.request(req_del)
    end
  end
end
