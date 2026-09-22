unified_mode true

property :event_file, String, name_property: true, identity: true
property :source_name, String, alias: true
property :vendor, String
property :description, String
property :source_type, String, equal_to: %w(cookbook_file template remote_file), default: 'cookbook_file', desired_state: false
property :source, String, desired_state: false
property :source_properties, Hash, desired_state: false
property :variables, Hash
property :position, String, equal_to: %w(override top bottom), default: 'bottom', desired_state: false

action_class do
  include Opennms::Cookbook::EventConf::HttpRequest
  include Opennms::Rbac

  @eventconf_upload_accumulator = {}

  def source_name_from_event_file
    name = new_resource.event_file.to_s
    name = name.sub(%r{^events/}, '')
    name.sub(/\.xml$/, '')
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

  def ensure_upload_resource
    with_run_context(:root) do
      declare_resource(:http_request, 'opennms_eventconf_upload') do
        url "#{resturl}/eventconf/upload"
        headers({ 'Content-Type' => 'multipart/form-data', 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" })
        action :nothing
        delayed_action :post
        message ''
        sensitive true
      end unless find_resource(:http_request, 'opennms_eventconf_upload')
    end
  end
end

load_current_value do |_new_resource|
  src_name = source_name_from_event_file
  # Existence check via API
  require 'net/http'
  uri = URI("#{resturl}/eventconf/sources/names-and-ids")
  res = Net::HTTP.get_response(uri)
  if res.is_a?(Net::HTTPSuccess)
    data = JSON.parse(res.body)
    current_value_does_not_exist! unless data.any? { |s| s['name'] == src_name }
  else
    current_value_does_not_exist!
  end
end

action :create do
  src_name = source_name_from_event_file
  ensure_upload_resource
  # Accumulate file content for bulk upload
  converge_if_changed do
    # Render file content
    content = case new_resource.source_type
              when 'cookbook_file'
                cookbook_file_path = "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.event_file}"
                begin
                  File.read(cookbook_file_path)
                rescue
                  ''
                end
              when 'template'
                # Simplified: assume rendered content is available via template resource
                ''
              when 'remote_file'
                ''
              end
    # Store in accumulator
    action_class.instance_variable_get(:@eventconf_upload_accumulator)[new_resource.event_file] = {
      source_name: src_name,
      vendor: vendor_from_name(src_name),
      description: new_resource.description,
      content: content,
    }
    # Update upload resource message with accumulated files
    upload_res = find_resource!(:http_request, 'opennms_eventconf_upload')
    # Build multipart body placeholder – actual building would happen in converge
    upload_res.message 'accumulated'
  end
end

action :create_if_missing do
  run_action(:create)
end

action :delete do
  src_name = source_name_from_event_file
  # Remove from accumulator
  acc = action_class.instance_variable_get(:@eventconf_upload_accumulator)
  acc.delete(new_resource.event_file)
end
