$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]

require 'rest_client'
require 'json'
require 'rexml/document'

# Note that any of the methods that do work do not do any error handling as 
# they assume you've used the test methods first to establish that you can 
# do what you're going to do. 
#
# TODO: use dynamically generated password (which is a TODO in itself). 
module Provision
  def foreign_source_exists?(name, node)
    begin
      response = RestClient.get "#{baseurl(node)}/foreignSources", {:accept => :json}
      fsources = JSON.parse(response.to_str)
      if fsources['@count'].to_i == 1
        return true if fsources['foreign-source']['@name'] == name
      elsif fsources['@count'].to_i > 1
        fsources['foreign-source'].each do |fs|
          return true if fs['@name'] == name
        end
      end
    rescue
      return false
    end
    false
  end
  def add_foreign_source(name, scan_interval, node)
    fs = REXML::Document.new
    fs << REXML::XMLDecl.new
    fsel = fs.add_element 'foreign-source', {'name' => name}
    siel = fsel.add_element 'scan-interval'
    siel.add_text(scan_interval)
    RestClient.post "#{baseurl(node)}/foreignSources", fs.to_s, {:content_type => :xml}
  end
  def service_detector_exists?(name, foreign_source_name, node)
    if foreign_source_exists?(foreign_source_name, node)
     begin
      response = RestClient.get "#{baseurl(node)}/foreignSources/#{foreign_source_name}/detectors/#{name}"
      return true if response.code == 200
     rescue
      return false
     end
    end
    false
  end
  def add_service_detector(name, class_name, port, retry_count, timeout, params, foreign_source_name, node)
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
   RestClient.post "#{baseurl(node)}/foreignSources/#{foreign_source_name}/detectors", sd.to_s, {:content_type => :xml}
  end
  def policy_exists?(policy_name, foreign_source_name, node)
    if foreign_source_exists?(foreign_source_name, node)
      begin
        response = RestClient.get "#{baseurl(node)}/foreignSources/#{foreign_source_name}/policies/#{policy_name}"
        return true if response.code == 200
      rescue
        return false
      end
    end
    false
  end
  def add_policy(policy_name, class_name, params, foreign_source_name, node)
   pd = REXML::Document.new
   pd << REXML::XMLDecl.new
   pel = pd.add_element 'policy', {'name' => policy_name, 'class' => class_name}
   if !params.nil?
     params.each do |key, value|
       pel.add_element 'parameter', {'key' => key, 'value' => value }
     end
   end
   RestClient.post "#{baseurl(node)}/foreignSources/#{foreign_source_name}/policies", pd.to_s, {:content_type => :xml}
  end
  def import_exists?(foreign_source_name, node)
    if foreign_source_exists?(foreign_source_name, node)
     begin
      response = RestClient.get "#{baseurl(node)}/requisitions", {:accept => :json}
      reqs = JSON.parse(response.to_str)
      if reqs['@count'].to_i == 1
        return true if reqs['model-import']['@foreign-source'] == foreign_source_name
      elsif reqs['@count'].to_i > 1
        reqs['model-import'].each do |import|
          return true if import['@foreign-source'] == foreign_source_name
        end
      end
     rescue
      return false
     end
    end
    false
  end
  def add_import(foreign_source_name, node)
    id = REXML::Document.new
    id << REXML::XMLDecl.new
    mi_el = id.add_element 'model-import', {'foreign-source' => foreign_source_name}
    RestClient.post "#{baseurl(node)}/requisitions", id.to_s, {:content_type => :xml}
  end
  def import_node_exists?(foreign_source_name, foreign_id, node)
    if import_exists?(foreign_source_name, node)
     begin
      response = RestClient.get "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}"
      Chef::Log.info "INE: import_node_exists response is #{response.to_s}"
      return true if response.code == 200
     rescue
      Chef::Log.info "INE: import_node_exists doesn't exist: #{foreign_source_name} - #{foreign_id}"
      return false
     end
    end
    false
  end
  def add_import_node(node_label, foreign_id, parent_foreign_source, parent_foreign_id, parent_node_label, city, building, categories, assets, foreign_source_name, node)
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
    RestClient.post "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes", nd.to_s, {:content_type => :xml}
  end
  def import_node_interface_exists?(foreign_source_name, foreign_id, ip_addr, node)
    if import_node_exists?(foreign_source_name, foreign_id, node)
     begin
      response = RestClient.get "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/#{ip_addr}"
      return true if response.code == 200
     rescue
      return false
     end
    end
    false
  end
  def add_import_node_interface(ip_addr, foreign_source_name, foreign_id, status, managed, snmp_primary, node)
    id = REXML::Document.new
    id << REXML::XMLDecl.new
    i_el = id.add_element 'interface', {'ip-addr' => ip_addr}
    i_el.attributes['status'] = status if !status.nil?
    i_el.attributes['managed'] = managed if !managed.nil?
    i_el.attributes['snmp-primary'] = snmp_primary if !snmp_primary.nil?
    RestClient.post "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/interfaces", id.to_s, {:content_type => :xml}
  end
  def import_node_interface_service_exists?(service_name, foreign_source_name, foreign_id, ip_addr, node)
    if import_node_interface_exists?(foreign_source_name, foreign_id, ip_addr, node)
     begin
      response = RestClient.get "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/#{ip_addr}/services/#{service_name}"
      return true if response.code == 200
     rescue
      return false
     end
    end
    false
  end
  def add_import_node_interface_service(service_name, foreign_source_name, foreign_id, ip_addr, node)
    sd = REXML::Document.new
    sd << REXML::XMLDecl.new
    s_el = sd.add_element 'monitored-service', {'name' => service_name}
    RestClient.post "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/interfaces/#{ip_addr}/services", sd.to_s, {:content_type => :xml}
  end
  def sync_import(foreign_source_name, rescan, node)
    url = "#{baseurl(node)}/requisitions/#{foreign_source_name}/import"
    if !rescan.nil? && rescan == false
      url = url + "?rescanExisting=false" 
    end

    RestClient.put url, nil
  end
  def foreign_id_gen
    t = Time.new()
    "#{t.to_i}#{t.usec}"
  end
  def baseurl(node)
    "http://admin:admin@localhost:#{node['opennms']['properties']['jetty']['port']}/opennms/rest"
  end
end
