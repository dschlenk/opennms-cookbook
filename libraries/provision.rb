# frozen_string_literal: true
require 'json'
require 'rexml/document'
require 'uri'

# Note that any of the methods that do work do not do any error handling as
# they assume you've used the test methods first to establish that you can
# do what you're going to do.
#
# TODO: use dynamically generated password (which is a TODO in itself).
module Provision
  def foreign_source_exists?(name, node)
    return true if name == 'default'
    unless foreign_sources(node).nil?
      fs = foreign_sources(node)
      Chef::Log.debug(fs)
      fs.each do |source|
        Chef::Log.debug source
        return true if !source.nil? && source.key?('name') && source['name'] == name
      end
    end
    false
  end

  def add_foreign_source(name, scan_interval, node)
    require 'rest_client'
    fs = REXML::Document.new
    fs << REXML::XMLDecl.new
    fsel = fs.add_element 'foreign-source', 'name' => name
    siel = fsel.add_element 'scan-interval'
    siel.add_text(scan_interval)
    # clear current list from cache
    node.run_state['foreign_sources'] = nil
    RestClient.post "#{baseurl(node)}/foreignSources", fs.to_s, content_type: :xml
  end

  def service_detector_exists?(name, foreign_source_name, node)
    if foreign_source_name == 'default'
      source = default_foreign_source(node)
      source['detectors'].each do |detector|
        return true if detector['name'] == name
      end
    elsif foreign_source_exists?(foreign_source_name, node)
      foreign_sources(node).each do |src|
        next unless src['name'] == foreign_source_name
        src['detectors'].each do |detector|
          return true if detector['name'] == name
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
        next unless source['name'] == current_resource.foreign_source_name
        source['detectors'].each do |d|
          if d['name'] == current_resource.service_name
            detector = d
            break
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
      case (p['key'])
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
    return true if things_changed?(current_resource.parameters, curr_params)
    false
  end

  def service_detector(_service_name, foreign_source_name, node)
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
        next unless source['name'] == current_resource.foreign_source_name
        source['detectors'].each do |d|
          if d['name'] == current_resource.service_name
            detector = d
            break
          end
        end
      end
    end
    detector
  end

  def thing_changed?(resource, current)
    unless resource.nil?
      Chef::Log.debug "thing_changed? #{resource} == #{current}?"
      return true unless resource.to_s == current.to_s
    end
    false
  end

  def things_changed?(resource, current)
    unless resource.nil?
      Chef::Log.debug "things_changed? #{resource} == #{current}?"
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
    service_name = new_resource.service_name || new_resource.name
    detector = service_detector(service_name, new_resource.foreign_source_name, node)
    service_name = URI.escape(service_name)
    foreign_source_name = URI.escape(new_resource.foreign_source_name)
    unless new_resource.class_name.nil?
      detector['class'] = new_resource.class_name
    end
    update_parameter(detector['parameter'], 'port', new_resource.port)
    update_parameter(detector['parameter'], 'retries', new_resource.retry_count)
    update_parameter(detector['parameter'], 'timeout', new_resource.timeout)
    # don't change anything if no parameters specified in update resource
    unless new_resource.parameters.nil? || new_resource.parameters.empty?
      # if you specify params, they replace all the current params. No merging of old and new occur.
      detector['parameter'].delete_if do |p|
        !%w(port retries timeout).include? p['key']
      end
    end
    unless new_resource.parameters.nil?
      new_resource.parameters.each do |k, v|
        detector['parameter'].push('key' => k, 'value' => v)
      end
    end
    # seems easier to just delete the current then add the modified rather than grab the entire
    # foreign source and PUT that with the change.
    RestClient.delete "#{baseurl(node)}/foreignSources/#{foreign_source_name}/detectors/#{service_name}"
    RestClient.post "#{baseurl(node)}/foreignSources/#{foreign_source_name}/detectors", JSON.dump(detector), content_type: :json
  end

  def update_parameter(curr_parameters, name, new_value)
    updated = false
    unless new_value.nil?
      curr_parameters.each do |p|
        next unless p['key'] == name
        p['value'] = new_value
        updated = true
        break
      end
      # handle adding a previously undefined common param
      curr_parameters.push('key' => name, 'value' => new_value) unless updated
    end
    curr_parameters
  end

  def add_service_detector(new_resource, node)
    require 'rest_client'
    service_name = new_resource.service_name || new_resource.name
    foreign_source_name = URI.escape(new_resource.foreign_source_name)
    sd = REXML::Document.new
    sd << REXML::XMLDecl.new
    sdel = sd.add_element 'detector', 'name' => service_name, 'class' => new_resource.class_name
    unless new_resource.port.nil?
      sdel.add_element 'parameter', 'key' => 'port', 'value' => new_resource.port
    end
    unless new_resource.retry_count.nil?
      sdel.add_element 'parameter', 'key' => 'retries', 'value' => new_resource.retry_count
    end
    unless new_resource.timeout.nil?
      sdel.add_element 'parameter', 'key' => 'timeout', 'value' => new_resource.timeout
    end
    unless new_resource.parameters.nil?
      new_resource.parameters.each do |key, value|
        sdel.add_element 'parameter', 'key' => key, 'value' => value
      end
    end
    # clear current list from cache
    node.run_state['foreign_sources'] = nil
    RestClient.post "#{baseurl(node)}/foreignSources/#{foreign_source_name}/detectors", sd.to_s, content_type: :xml
  end

  def remove_service_detector(new_resource, node)
    require 'rest_client'
    service_name = new_resource.service_name || new_resource.name
    service_name = URI.escape(service_name)
    foreign_source_name = URI.escape(new_resource.foreign_source_name)
    node.run_state['foreign_sources'] = nil
    RestClient.delete "#{baseurl(node)}/foreignSources/#{foreign_source_name}/detectors/#{service_name}"
  end

  def policy_exists?(policy_name, foreign_source_name, node)
    if foreign_source_exists?(foreign_source_name, node)
      foreign_sources(node).each do |source|
        next unless source['name'] == foreign_source_name
        policies = source['policies']
        next if policies.nil?
        policies.each do |policy|
          Chef::Log.debug "policy: #{policy}; name: #{foreign_source_name}"
          return true if policy['name'] == policy_name
        end
      end
    end
    false
  end

  def add_policy(policy_name, class_name, params, foreign_source_name, node)
    require 'rest_client'
    foreign_source_name = URI.escape(foreign_source_name)
    pd = REXML::Document.new
    pd << REXML::XMLDecl.new
    pel = pd.add_element 'policy', 'name' => policy_name, 'class' => class_name
    unless params.nil?
      params.each do |key, value|
        pel.add_element 'parameter', 'key' => key, 'value' => value
      end
    end
    # clear current list from cache
    node.run_state['foreign_sources'] = nil
    RestClient.post "#{baseurl(node)}/foreignSources/#{foreign_source_name}/policies", pd.to_s, content_type: :xml
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
    id.add_element 'model-import', 'foreign-source' => foreign_source_name
    # clear current list from cache
    node.run_state['imports'] = nil
    resp = RestClient.post "#{baseurl(node)}/requisitions", id.to_s, content_type: :xml
    Chef::Log.debug "add_import response is: #{resp}"
    resp
  end

  def import_node_exists?(foreign_source_name, foreign_id, node)
    if import_exists?(foreign_source_name, node)
      imports_mi = imports(node)['model-import']
      Chef::Log.debug "imports on this server: #{imports_mi}"
      unless imports_mi.nil?
        imports_mi.each do |import|
          next unless import['foreign-source'] == foreign_source_name
          nodes = import['node']
          next if nodes.nil?
          import['node'].each do |n|
            return true if n['foreign-id'] == foreign_id
          end
        end
      end
    end
    false
  end

  def import_node_changed?(current_resource, node)
    require 'rest_client'
    foreign_source_name = URI.escape(current_resource.foreign_source_name)
    foreign_id = URI.escape(current_resource.foreign_id)
    (1..3).each do |r|
      begin
        Chef::Log.debug("url for existing, try #{r}: '#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}'") #, { accept: :json, 'Accept-Encoding' => 'identity' }).to_s)
        n = JSON.parse(RestClient.get("#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}", { accept: :json, 'Accept-Encoding' => 'identity' }).to_s)
        Chef::Log.debug("checking for changes in #{new_resource.foreign_id}.")
        Chef::Log.debug("n is #{n}")
        return true if thing_changed?(current_resource.node_label, n['node-label'])
        return true if thing_changed?(current_resource.parent_foreign_source, n['parent-foreign-source'])
        return true if thing_changed?(current_resource.parent_foreign_id, n['parent-foreign-id'])
        return true if thing_changed?(current_resource.parent_node_label, n['parent-node-label'])
        return true if thing_changed?(current_resource.city, n['city'])
        return true if thing_changed?(current_resource.building, n['building'])
        # TODO: support categories/assets return true if things_changed?(current_resource.categories, n[
        curr_cats = []
        n['category'].each do |cat|
          Chef::Log.debug "current category membership includes #{cat['name']}"
          curr_cats.push cat['name']
        end
        return true if things_changed?(current_resource.categories, curr_cats)
        curr_assets = {}
        n['asset'].each do |asset|
          curr_assets[asset['name']] = asset['value']
        end
        return true if things_changed?(current_resource.assets, curr_assets)
      rescue StandardError => err
        Chef::Log.debug("failed to get node from requisition because '#{err}', will wait a bit for provisiond to catch up")
        sleep(15)
      end
    end
    false
  end

  def delete_imported_node(fsid, fsname, node)
    require 'rest_client'
    RestClient.delete "#{baseurl(node)}/requisitions/#{fsname}/nodes/#{fsid}"
  end

  def update_imported_node(new_resource, node)
    require 'rest_client'
    foreign_source_name = URI.escape(new_resource.foreign_source_name)
    foreign_id = URI.escape(new_resource.foreign_id)

    n = REXML::Document.new(RestClient.get("#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}", { 'Accept-Encoding' => 'identity' }).to_s)
    # you can't update a node label using the implied node label from the name of the resource
    node_el = n.elements['node']
    if !new_resource.node_label.nil? && new_resource.node_label != node_el.attributes['node-label']
      node_el.attributes['node-label'] = new_resource.node_label
    end
    unless new_resource.parent_foreign_source.nil?
      node_el.attributes['parent-foreign-source'] = new_resource.parent_foreign_source
    end
    unless new_resource.parent_foreign_id.nil?
      node_el.attributes['parent-foreign-id'] = new_resource.parent_foreign_id
    end
    unless new_resource.parent_node_label.nil?
      node_el.attributes['parent-node-label'] = new_resource.parent_node_label
    end
    node_el.attributes['city'] = new_resource.city unless new_resource.city.nil?
    unless new_resource.building.nil?
      node_el.attributes['building'] = new_resource.building
    end
    # TODO: categories
    unless new_resource.categories.nil?
      node_el.elements.delete_all 'category'
      new_resource.categories.each do |c|
        node_el.add_element('category', 'name' => c)
      end
    end
    # TODO: assets
    unless new_resource.assets.nil?
      node_el.elements.delete_all 'asset'
      new_resource.assets.each do |k, v|
        node_el.add_element 'asset', 'name' => k, 'value' => v
      end
    end
    Chef::Log.debug "Updating node with #{n} to #{baseurl(node)}/requisitions/#{foreign_source_name}/nodes with content type xml"
    RestClient.post "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes", n.to_s, content_type: :xml
  end

  def add_import_node(new_resource, node)
    require 'rest_client'
    name = new_resource.node_label || new_resource.name
    nd = REXML::Document.new
    nd << REXML::XMLDecl.new
    node_el = nd.add_element 'node', 'node-label' => name, 'foreign-id' => new_resource.foreign_id
    unless new_resource.parent_foreign_source.nil?
      node_el.attributes['parent-foreign-source'] = new_resource.parent_foreign_source
    end
    unless new_resource.parent_foreign_id.nil?
      node_el.attributes['parent-foreign-id'] = new_resource.parent_foreign_id
    end
    unless new_resource.parent_node_label.nil?
      node_el.attributes['parent-node-label'] = new_resource.parent_node_label
    end
    node_el.attributes['city'] = new_resource.city unless new_resource.city.nil?
    node_el.attributes['building'] = new_resource.building unless new_resource.building.nil?
    if !new_resource.categories.nil? && !new_resource.categories.empty?
      new_resource.categories.each do |category|
        node_el.add_element 'category', 'name' => category
      end
    end
    unless new_resource.assets.nil?
      new_resource.assets.each do |key, value|
        node_el.add_element 'asset', 'name' => key, 'value' => value
      end
    end
    # clear current list from cache
    node.run_state['imports'] = nil
    foreign_source_name = URI.escape(new_resource.foreign_source_name)
    RestClient.post "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes", nd.to_s, content_type: :xml
  end

  def import_node_interface_exists?(foreign_source_name, foreign_id, ip_addr, node)
    if import_node_exists?(foreign_source_name, foreign_id, node)
      imports(node)['model-import'].each do |import|
        next unless import['foreign-source'] == foreign_source_name
        nodes = import['node']
        next if nodes.nil?
        nodes.each do |n|
          next unless n['foreign-id'] == foreign_id
          n['interface'].each do |iface|
            return true if iface['ip-addr'] == ip_addr
          end
        end
      end
    end
    false
  end

  def add_import_node_interface(new_resource, node)
    require 'rest_client'
    id = REXML::Document.new
    id << REXML::XMLDecl.new
    i_el = id.add_element 'interface', 'ip-addr' => new_resource.ip_addr
    i_el.attributes['status'] = new_resource.status unless new_resource.status.nil?
    i_el.attributes['managed'] = new_resource.managed unless new_resource.managed.nil?
    i_el.attributes['snmp-primary'] = new_resource.snmp_primary unless new_resource.snmp_primary.nil?
    # clear current list from cache
    node.run_state['imports'] = nil
    foreign_source_name = URI.escape(new_resource.foreign_source_name)
    foreign_id = URI.escape(new_resource.foreign_id)
    RestClient.post "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/interfaces", id.to_s, content_type: :xml
  end

  def import_node_interface_service_exists?(service_name, foreign_source_name, foreign_id, ip_addr, node)
    if import_node_exists?(foreign_source_name, foreign_id, node)
      imports(node)['model-import'].each do |import|
        next unless import['foreign-source'] == foreign_source_name
        import['node'].each do |n|
          next unless n['foreign-id'] == foreign_id
          n['interface'].each do |iface|
            next unless iface['ip-addr'] == ip_addr
            iface['monitored-service'].each do |svc|
              return true if svc['service-name'] == service_name
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
    sd.add_element 'monitored-service', 'service-name' => service_name
    # clear current list from cache
    node.run_state['imports'] = nil
    foreign_source_name = URI.escape(foreign_source_name)
    foreign_id = URI.escape(foreign_id)
    ip_addr = URI.escape(ip_addr)
    RestClient.post "#{baseurl(node)}/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/interfaces/#{ip_addr}/services", sd.to_s, content_type: :xml
  end

  def wait_for_sync(_foreign_source_name, node, wait_periods, wait_length)
    now = Time.now
    # sometimes syncs happen real quick
    now -= 60
    now = now.strftime '%Y-%m-%d %H:%M:%S'
    period = 0
    until sync_complete?(new_resource.foreign_source_name, now, node) || period == wait_periods
      Chef::Log.debug "Waiting period ##{period}/#{wait_periods} for #{wait_length} seconds for requisition #{new_resource.foreign_source_name} import to finish."
      sleep(wait_length)
      period += 1
    end
    Chef::Log.warn "Waited #{(wait_periods * wait_length)} seconds for #{new_resource.foreign_source_name} to import, giving up. If a service restart occurs before it finishes, this and any pending requisitions may need to be synchronized manually." if period == wait_periods
  end

  # after must be in SQL query format: '2015-12-17 21:00:00'
  def sync_complete?(foreign_source_name, after, node)
    require 'rest-client'
    require 'addressable/uri'
    api = 'v1'
    m = node['opennms']['version'].match(/^(\d+)\.(\d+)\.(\d+)-(\d+)$/)
    unless m.nil?
      if m[1].to_i > 20
        api = 'v2'
      elsif m[1].to_i == 20 && m[2].to_i == 0 && m[3].to_i >= '2'
        api = 'v2'
      elsif m[1].to_i == 20 && m[2].to_i > 0
        api = 'v2'
      end
    end
    case api
    when 'v1'
      url = "#{baseurl(node)}/events?eventUei=uei.opennms.org/internal/importer/importSuccessful&eventParms=%25#{foreign_source_name}%25&comparator=like&query=eventcreatetime >= '#{after}'"
    when 'v2'
      url = "#{baseurlv2(node)}/events?_s=eventCreateTime=ge=#{Time.parse(after + ' ' + Time.now.zone).utc.strftime('%FT%T.%LZ')};eventUei==uei.opennms.org/internal/importer/importSuccessful"
    end
    parsed_url = Addressable::URI.parse(url).normalize.to_str
    Chef::Log.debug("sync_complete? URL: '#{parsed_url}'")
    response = RestClient.get(parsed_url, { accept: :json, 'Accept-Encoding' => 'identity' })
    # apiv2 returns empty response (204) when nothing found
    # and might return things in gzip format which annoyingly rest-client doesn't decode for you
    return false if response.code == 204
    if response.headers[:content_encoding] == 'gzip'
      Chef::Log.debug('dealing with gzip content')
      begin
        sio = StringIO.new(response.body)
        gz = Zlib::GzipReader.new(sio)
        response = gz.read()
      rescue StandardError => err
        Chef::Log.warn("response body indicated gzip but extraction failed due to #{err}")
        Chef::Log.debug("response body that failed to extract is #{response.body}. Will attempt to read as JSON string.")
        response = response.body
      end
    else
      Chef::Log.debug("not dealing with gzip content, headers are #{response.headers} and content encoding is #{response.headers[:content_encoding]}")
      response = response.to_s
    end
    begin
      events = JSON.parse(response) unless response.nil? || response.empty?
    rescue
      Chef::Log.warn('unparseable response from events API, assuming not found')
      return false
    end
    complete = true
    complete = false if !events.nil? && events.key?('totalCount') && events['totalCount'].to_i == 0
    if events.nil? || (api == 'v2' && !apiv2synced?(events, foreign_source_name))
      complete = false
    end
    complete
  end

  def apiv2synced?(events, foreign_source_name)
    events = events['event'].select do |e|
      mp = e['parameters'].select do |p|
        p['value'].include?(foreign_source_name)
      end
      !(mp.nil? || mp.empty?)
    end
    !events.empty?
  end

  def sync_import(foreign_source_name, rescan, node)
    require 'rest_client'
    foreign_source_name = URI.escape(foreign_source_name)
    url = "#{baseurl(node)}/requisitions/#{foreign_source_name}/import"
    url += '?rescanExisting=false' if !rescan.nil? && rescan == false
    begin
      tries ||= 3
      Chef::Log.debug("Attempting import sync for #{foreign_source_name} with URL #{url}")
      RestClient.put url, nil
    rescue => e
      Chef::Log.debug("Retrying import sync for #{foreign_source_name} #{tries}")
      retry if (tries -= 1) > 0
      raise e
    end
  end

  def foreign_id_gen
    t = Time.new
    "#{t.to_i}#{t.usec}"
  end

  def baseurl(node)
    "http://admin:#{node['opennms']['users']['admin']['password']}@localhost:#{node['opennms']['properties']['jetty']['port']}/opennms/rest"
  end

  def baseurlv2(node)
    "http://admin:#{node['opennms']['users']['admin']['password']}@localhost:#{node['opennms']['properties']['jetty']['port']}/opennms/api/v2"
  end

  def default_foreign_source(node)
    require 'rest_client'
    begin
      node.run_state['default_foreign_source'] ||=
        JSON.parse(RestClient.get("#{baseurl(node)}/foreignSources/default",
                                  { accept: :json, 'Accept-Encoding' => 'identity' }).to_str)
      node.run_state['default_foreign_source']
    rescue
      Chef::Log.warn 'Cannot retrieve default foreign source via OpenNMS ReST API.'
    end
  end

  def foreign_sources(node)
    require 'rest_client'
    begin
      node.run_state['foreign_sources'] ||=
        if Opennms::Helpers.major(node['opennms']['version']).to_i > 16
          JSON.parse(RestClient.get("#{baseurl(node)}/foreignSources",
                                  { accept: :json, 'Accept-Encoding' => 'identity' }).to_str)['foreignSources']
        else
          JSON.parse(RestClient.get("#{baseurl(node)}/foreignSources",
                                  { accept: :json, 'Accept-Encoding' => 'identity' }).to_str)
        end
      node.run_state['foreign_sources']
    rescue
      Chef::Log.warn 'Cannot retrieve foreign sources via OpenNMS ReST API.'
      return nil
    end
  end

  def imports(node)
    require 'rest_client'
    last_err = nil
    ret = nil
    (1..3).each do |r|
      begin
        node.run_state['imports'] ||=
          JSON.parse(RestClient.get("#{baseurl(node)}/requisitions",
                                        { accept: :json, 'Accept-Encoding' => 'identity' }).to_str)
        Chef::Log.debug("imports is #{node.run_state['imports']}.")
        ret = node.run_state['imports']
        if ret.nil?
          Chef::Log.debug('imports was nil somehow, sleeping and trying again')
          sleep(15)
          next
        else
          return ret
        end
      rescue StandardError => err
        Chef::Log.debug "Cannot retrieve requisitions via OpenNMS ReST API due to #{err}."
        last_err = err
        sleep(15)
      end
    end
    Chef::Log.error 'Could not retrieve requisitions via OpenNMS ReST API.'
    return false
  end
end
