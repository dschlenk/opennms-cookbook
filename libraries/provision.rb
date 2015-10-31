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
  def sync_import(foreign_source_name, rescan, node)
    require 'rest_client'
    url = "#{baseurl(node)}/requisitions/#{foreign_source_name}/import"
    if !rescan.nil? && rescan == false
      url = url + "?rescanExisting=false" 
    end
    begin
      tries ||= 3
      RestClient.put url, nil
    rescue => e
      if (tries -= 1) > 0
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
