require 'json'
require 'rexml/document'

# Note that any of the methods that do work do not do any error handling as 
# they assume you've used the test methods first to establish that you can 
# do what you're going to do. 
#
# TODO: use dynamically generated password (which is a TODO in itself). 
module Provision
  def foreign_source_exists?(name, node)
    return true if name == 'default'
    unless foreign_sources(node).nil?
      foreign_sources(node).each do |source|
        return true if !source.nil? && source.has_key?('name') && source['name'] == name
      end
    end
    false
  end
  def add_foreign_source(name, scan_interval, node)
    require 'rest_client'
    fs = REXML::Document.new
    fs << REXML::XMLDecl.new
    fsel = fs.add_element 'foreign-source', {'name' => name}
    siel = fsel.add_element 'scan-interval'
    siel.add_text(scan_interval)
    # clear current list from cache
    node.run_state[:foreign_sources] = nil
    RestClient.post "#{baseurl(node)}/foreignSources", fs.to_s, {:content_type => :xml}
  end
  def service_detector_exists?(name, foreign_source_name, node)
    if foreign_source_name == 'default' 
      source = default_foreign_source(node)
      source['detectors'].each do |detector|
        return true if detector['name'] == name
      end
    elsif foreign_source_exists?(foreign_source_name, node)
      foreign_sources(node).each do |source|
        if source['name'] == foreign_source_name
          source['detectors'].each do |detector|
            return true if detector['name'] == name
          end
        end
      end
    end
    false
  end
  def service_detector_changed?(current_resource, node)
    detector = nil
    if current_resource.foreign_source_name == 'default'
      default_foreign_source(node)['detectors'].each do |d|
        if d['name'] == current_resource.service_name
          detector = d
          break
        end
      end
    else
      foreign_sources(node).each do |source|
        if source['name'] == current_resource.foreign_source_name
          source['detectors'].each do |d|
            if d['name'] == current_resource.service_name
              detector = d
              break
            end
          end
        end
      end
    end
    Chef::Log.debug detector
    curr_retries = nil
    curr_timeout = nil
    curr_port = nil
    curr_params = {}
    curr_class = detector['class']
    detector['parameter'].each do |p|
      case(p['key'])
      when 'retries'
        curr_retries = p['value']
      when 'timeout'
        curr_timeout = p['value']
      when 'port'
        curr_port = p['value']
      else
        curr_params[p['key']] = p['value']
      end
    end

    return true if thing_changed?(current_resource.retry_count, curr_retries)
    return true if thing_changed?(current_resource.timeout, curr_timeout)
    return true if thing_changed?(current_resource.port, curr_port)
    return true if thing_changed?(current_resource.class_name, curr_class)
    return true if things_equal?(current_resource.params, curr_params)
    false
  end

  def service_detector(service_name, foreign_source_name, node)
    detector = nil
    if foreign_source_name == 'default'
      default_foreign_source(node)['detectors'].each do |d|
        if d['name'] == current_resource.service_name
          detector = d
          break
        end
      end
    else
      foreign_sources(node).each do |source|
        if source['name'] == current_resource.foreign_source_name
          source['detectors'].each do |d|
            if d['name'] == current_resource.service_name
              detector = d
              break
            end
          end
        end
      end
    end
    detector
  end

  def thing_changed?(resource, current)
    unless resource.nil?
      Chef::Log.debug "#{resource} == #{current}?"
      return true unless "#{resource}" == "#{current}"
    end
    false
  end
  def things_equal?(resource, current)
    unless resource.nil?
      Chef::Log.debug "#{resource} == #{current}?"
      return true unless resource == current
    end
    false
  end

  # {"name"=>"Router", 
  #  "class"=>"org.opennms.netmgt.provision.detector.snmp.SnmpDetector", 
  #  "parameter"=>[
  #    {"key"=>"port", "value"=>"161"}, 
  #    {"key"=>"retries", "value"=>"3"}, 
  #    {"key"=>"timeout", "value"=>"5000"}, 
  #    {"key"=>"vbname", "value"=>".1.3.6.1.2.1.4.1.0"}, 
  #    {"key"=>"vbvalue", "value"=>"1"}]
  # }
  # new_resource only needs to define elements it wants to change.
  def update_service_detector(new_resource, node)
    require 'rest-client'
    detector = service_detector(new_resource.service_name, new_resource.foreign_source_name, node)
    unless new_resource.class_name.nil?
      detector['class'] = new_resource.class_name
    end
    update_parameter(detector['parameter'], 'port', new_resource.port)
    update_parameter(detector['parameter'], 'retries', new_resource.retry_count)
    update_parameter(detector['parameter'], 'timeout', new_resource.timeout)
    # don't change anything if no parameters specified in update resource
    unless new_resource.params.nil? || new_resource.params.size == 0
      # if you specify params, they replace all the current params. No merging of old and new occur.
      detector['parameter'].delete_if do |p|
        !['port', 'retries', 'timeout'].include? p['key']
      end
    end
    new_resource.params.each do |k,v|
      detector['parameter'].push({ 'key' => k, 'value' => v })
    end
    # seems easier to just delete the current then add the modified rather than grab the entire 
    # foreign source and PUT that with the change.
    RestClient.delete "#{baseurl(node)}/foreignSources/#{new_resource.foreign_source_name}/detectors/#{new_resource.service_name}"
    RestClient.post "#{baseurl(node)}/foreignSources/#{new_resource.foreign_source_name}/detectors", JSON.dump(detector), { :content_type => :json }
  end

  def update_parameter(curr_parameters, name, new_value)
    updated = false
    unless new_value.nil?
      curr_parameters.each do |p|
        if p['key'] == name
          p['value'] = new_value
          updated = true
          break
        end
      end
      # handle adding a previously undefined common param
      unless updated
        curr_parameters.push({ 'key' => name, 'value' => new_value })
      end
    end
    curr_parameters
  end

  def add_service_detector(name, class_name, port, retry_count, timeout, params, foreign_source_name, node)
    require 'rest_client'
    sd = REXML::Document.new
    sd << REXML::XMLDecl.new
    sdel = sd.add_element 'detector', {'name' => name, 'class' => class_name}
    if !port.nil?
      sdel.add_element 'parameter', {'key' => 'port', 'value' => port }
    end
    if !retry_count.nil?
      sdel.add_element 'parameter', {'key' => 'retries', 'value' => retry_count }
    end
    if !timeout.nil?
      sdel.add_element 'parameter', {'key' => 'timeout', 'value' => timeout }
    end
    if !params.nil?
      params.each do |key, value|
        sdel.add_element 'parameter', {'key' => key, 'value' => value }
      end
    end
    # clear current list from cache
    node.run_state[:foreign_sources] = nil
    RestClient.post "#{baseurl(node)}/foreignSources/#{foreign_source_name}/detectors", sd.to_s, {:content_type => :xml}
  end
  def policy_exists?(policy_name, foreign_source_name, node)
    if foreign_source_exists?(foreign_source_name, node)
      foreign_sources(node).each do |source|
        if source['name'] == foreign_source_name
          policies = source['policies']
          unless policies.nil?
            policies.each do |policy|
              Chef::Log.debug "policy: #{policy}; name: #{foreign_source_name}"
              return true if policy['name'] == policy_name
            end
          end
        end
      end
    end
    false
  end
  def add_policy(policy_name, class_name, params, foreign_source_name, node)
    require 'rest_client'
    pd = REXML::Document.new
    pd << REXML::XMLDecl.new
    pel = pd.add_element 'policy', {'name' => policy_name, 'class' => class_name}
    if !params.nil?
      params.each do |key, value|
        pel.add_element 'parameter', {'key' => key, 'value' => value }
      end
    end
    # clear current list from cache
    node.run_state[:foreign_sources] = nil
    RestClient.post "#{baseurl(node)}/foreignSources/#{foreign_source_name}/policies", pd.to_s, {:content_type => :xml}
  end
  def import_exists?(foreign_source_name, node)
    unless imports(node).nil?
      imports(node)['model-import'].each do |import|
        return true if import['foreign-source'] == foreign_source_name
      end
    end
    false
  end
  def add_import(foreign_source_name, node)
    require 'rest_client'
    id = REXML::Document.new
    id << REXML::XMLDecl.new
    mi_el = id.add_element 'model-import', {'foreign-source' => foreign_source_name}
    # clear current list from cache
    node.run_state[:imports] = nil
    resp = RestClient.post "#{baseurl(node)}/requisitions", id.to_s, {:content_type => :xml}
    Chef::Log.debug "add_import response is: #{resp}"
    resp
  end
  def import_node_exists?(foreign_source_name, foreign_id, node)
    if import_exists?(foreign_source_name, node)
      imports_mi = imports(node)['model-import']
      Chef::Log.debug "imports on this server: #{imports_mi}"
      unless imports_mi.nil?
        imports_mi.each do |import|
          Chef::Log.debug "#{import['foreign-source']} == #{foreign_source_name}"
          if import['foreign-source'] == foreign_source_name
            nodes = import['node']
            Chef::Log.debug "nodes: #{nodes}"
            unless nodes.nil?
              import['node'].each do |node|
                Chef::Log.debug "#{node['foreign-id']} == #{foreign_id}"
                return true if node['foreign-id'] == foreign_id
              end
            end
          end
        end
      end
    end
    false
  end
  def add_import_node(node_label, foreign_id, parent_foreign_source, parent_foreign_id, parent_node_label, city, building, categories, assets, foreign_source_name, node)
    require 'rest_client'
    nd = REXML::Document.new
    nd << REXML::XMLDecl.new
    node_el = nd.add_element 'node', {'node-label' => node_label, 'foreign-id' => foreign_id }
    if !parent_foreign_source.nil?
      node_el.attributes['parent-foreign-source'] = parent_foreign_source
    end
    if !parent_foreign_id.nil?
      node_el.attributes['parent-foreign-id'] = parent_foreign_id
    end
    if !parent_node_label.nil?
      node_el.attributes['parent-node-label'] = parent_node_label
    end
    if !city.nil?
      node_el.attributes['city'] = city
    end
    if !building.nil?
      node_el.attributes['building'] = building
    end
    if !categories.nil? && categories.length > 0
      categories.each do |category|
        node_el.add_element 'category', {'name' => category}
      end
    end
    if !assets.nil? 
      assets.each do |name, value|
        node_el.add_element 'asset', {'name' => name, 'value' => value}
      end
    end
    # clear current list from cache
    node.run_state[:imports] = nil
    RestClient.post "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes", nd.to_s, {:content_type => :xml}
  end
  def import_node_interface_exists?(foreign_source_name, foreign_id, ip_addr, node)
    if import_node_exists?(foreign_source_name, foreign_id, node)
      imports(node)['model-import'].each do |import|
        if import['foreign-source'] == foreign_source_name
          nodes = import['node']
          unless nodes.nil?
            nodes.each do |node|
              if node['foreign-id'] == foreign_id
                node['interface'].each do |iface|
                  return true if iface['ip-addr'] == ip_addr
                end
              end
            end
          end
        end
      end
    end
    false
  end
  def add_import_node_interface(ip_addr, foreign_source_name, foreign_id, status, managed, snmp_primary, node)
    require 'rest_client'
    id = REXML::Document.new
    id << REXML::XMLDecl.new
    i_el = id.add_element 'interface', {'ip-addr' => ip_addr}
    i_el.attributes['status'] = status if !status.nil?
    i_el.attributes['managed'] = managed if !managed.nil?
    i_el.attributes['snmp-primary'] = snmp_primary if !snmp_primary.nil?
    # clear current list from cache
    node.run_state[:imports] = nil
    RestClient.post "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/interfaces", id.to_s, {:content_type => :xml}
  end
  def import_node_interface_service_exists?(service_name, foreign_source_name, foreign_id, ip_addr, node)
    if import_node_exists?(foreign_source_name, foreign_id, node)
      imports(node)['model-import'].each do |import|
        if import['foreign-source'] == foreign_source_name
          import['node'].each do |node|
            if node['foreign-id'] == foreign_id
              node['interface'].each do |iface|
                if iface['ip-addr'] == ip_addr
                  iface['monitored-service'].each do |svc|
                    return true if svc['service-name'] == service_name
                  end
                end
              end
            end
          end
        end
      end
    end
    false
  end
  def add_import_node_interface_service(service_name, foreign_source_name, foreign_id, ip_addr, node)
    require 'rest_client'
    sd = REXML::Document.new
    sd << REXML::XMLDecl.new
    s_el = sd.add_element 'monitored-service', {'service-name' => service_name}
    # clear current list from cache
    node.run_state[:imports] = nil
    RestClient.post "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/interfaces/#{ip_addr}/services", sd.to_s, {:content_type => :xml}
  end

  def wait_for_sync(foreign_source_name, node, wait_periods, wait_length)
    now = Time.now.strftime "%Y-%m-%d %H:%M:%S"
    period = 0
    until sync_complete?(new_resource.foreign_source_name, now, node) || period == wait_periods
      Chef::Log.debug "Waiting period ##{period}/#{wait_periods} for #{wait_length} seconds for requisition #{new_resource.foreign_source_name} import to finish."
      sleep(wait_length);
      period += 1
    end
    Chef::Log.warn "Waited #{(wait_periods * wait_length).to_s} seconds for #{new_resource.foreign_source_name} to import, giving up. If a service restart occurs before it finishes, this and any pending requisitions may need to be synchronized manually." if period == wait_periods
  end

  # after must be in SQL query format: '2015-12-17 21:00:00'
  def sync_complete?(foreign_source_name, after, node)
    complete = false
    require 'rest-client'
    require 'addressable/uri'
    url = "#{baseurl(node)}/events?eventUei=uei.opennms.org/internal/importer/importSuccessful&eventParms=%25#{foreign_source_name}%25&comparator=like&query=eventcreatetime >= '#{after}'"
    parsed_url = Addressable::URI.parse(url).normalize.to_str
    Chef::Log.debug("sync_complete? URL: #{parsed_url}")
    events = JSON.parse(RestClient.get(parsed_url, { :accept => :json}).to_str)
    complete = true if !events.nil? && events.has_key?('totalCount') && events['totalCount'].to_i > 0
    complete
  end

  def sync_import(foreign_source_name, rescan, node)
    require 'rest_client'
    url = "#{baseurl(node)}/requisitions/#{foreign_source_name}/import"
    if !rescan.nil? && rescan == false
      url = url + "?rescanExisting=false" 
    end
    begin
      tries ||= 3
      Chef::Log.debug("Attempting import sync for #{foreign_source_name} with URL #{url}")
      RestClient.put url, nil
    rescue => e
      if (tries -= 1) > 0
        Chef::Log.debug("Retrying import sync for #{foreign_source_name} #{tries}")
        retry
      else
        raise
      end
    end
  end
  def foreign_id_gen
    t = Time.new()
    "#{t.to_i}#{t.usec}"
  end
  def baseurl(node)
    "http://admin:admin@localhost:#{node['opennms']['properties']['jetty']['port']}/opennms/rest"
  end
  def default_foreign_source(node)
    require 'rest_client'
    begin
      node.run_state[:default_foreign_source] ||=
        JSON.parse(RestClient.get("#{baseurl(node)}/foreignSources/default",
                                  { :accept => :json }).to_str)
      node.run_state[:default_foreign_source]
    rescue
      Chef::Log.warn "Cannot retrieve default foreign source via OpenNMS ReST API."
    end
  end
  def foreign_sources(node)
    require 'rest_client'
    begin
      node.run_state[:foreign_sources] ||=
        JSON.parse(RestClient.get("#{baseurl(node)}/foreignSources",
                                  { :accept => :json }).to_str)
      node.run_state[:foreign_sources]
    rescue
      Chef::Log.warn "Cannot retrieve foreign sources via OpenNMS ReST API."
      return nil
    end
  end
  def imports(node)
    require 'rest_client'
     begin
       node.run_state[:imports] ||=
         JSON.parse(RestClient.get("#{baseurl(node)}/requisitions",
                                       {:accept => :json}).to_str)
     rescue
       Chef::Log.error "Cannot retrieve requisitions via OpenNMS ReST API."
       return false
     end
  end
end
