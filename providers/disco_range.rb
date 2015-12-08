include Provision
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  elsif !@current_resource.foreign_source.nil? && !@current_resource.foreign_source_exists
    Chef::Application.fatal!("Missing foreign source #{@current_resource.foreign_source}.")
  else
    converge_by("Create #{ @new_resource }") do
      create_range
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsDiscoRange.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.range_begin(@new_resource.range_begin)
  @current_resource.range_end(@new_resource.range_end)
  @current_resource.range_type(@new_resource.range_type)
  @current_resource.foreign_source(@new_resource.foreign_source) unless @new_resource.foreign_source.nil?

  if @current_resource.foreign_source.nil?
    if range_exists?(@current_resource.name, @current_resource.range_begin, @current_resource.range_end, @current_resource.range_type, nil)
      @current_resource.exists = true
    end
  else
    if range_exists?(@current_resource.name, @current_resource.range_begin, @current_resource.range_end, @current_resource.range_type, @current_resource.foreign_source)
      @current_resource.exists = true
    elsif foreign_source_exists?(@current_resource.foreign_source, node)
      @current_resource.foreign_source_exists = true
    end
  end
end


private

def range_exists?(name, range_begin, range_end, range_type, foreign_source)
  Chef::Log.debug "Checking to see if this discovery #{range_type} range exists: '#{range_begin} to #{range_end}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml", "r")
  doc = REXML::Document.new file
  if foreign_source.nil?
    !doc.elements["/discovery-configuration/#{range_type}-range/begin[text() ='#{range_begin}']"].nil? && !doc.elements["/discovery-configuration/#{range_type}-range/end[text() = '#{range_end}']"].nil?
  else
    !doc.elements["/discovery-configuration/#{range_type}-range[@foreign-source = '#{foreign_source}']/begin[text() ='#{range_begin}']"].nil? && !doc.elements["/discovery-configuration/#{range_type}-range[@foreign-source = '#{foreign_source}']/end[text() = '#{range_end}']"].nil?
  end
end

def create_range
  Chef::Log.debug "Adding #{new_resource.range_type}-range to discovery: '#{ new_resource.range_begin} - #{new_resource.range_end}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  file.close
  new_el = REXML::Element.new("#{new_resource.range_type}-range")
  new_el.attributes['foreign-source'] = new_resource.foreign_source unless new_resource.foreign_source.nil?
  begin_el = new_el.add_element 'begin'
  begin_el.add_text(new_resource.range_begin)
  end_el = new_el.add_element 'end'
  end_el.add_text(new_resource.range_end)
  if !new_resource.retry_count.nil?
    new_el.attributes['retries'] = new_resource.retry_count
  end
  if !new_resource.timeout.nil?
    new_el.attributes['timeout'] = new_resource.timeout
  end
  last_el = doc.root.elements["/discovery-configuration/#{new_resource.range_type}-range[last()]"]
  if !last_el.nil?
    doc.root.insert_after(last_el, new_el)
  else
    # see if there are any other discovery elements.
    after_el = nil 
    before_el = nil
    if new_resource.range_type == "include"
      after_el = doc.root.elements["/discovery-configuration/specific[last()]"]
      if after_el.nil?
        before_el = doc.root.elements["/discovery-configuration/exclude-range[1]"]
        if before_el.nil?
          before_el = doc.root.elements["/discovery-configuration/include-url[1]"]
        end
      end
      if !after_el.nil?
        doc.root.insert_after(after_el, new_el)
      elsif !before_el.nil?
        doc.root.insert_before(before_el, new_el)
      else
        doc.root.elements["/discovery-configuration"].add_element new_el
      end
    else
      before_el = doc.root.elements["/discovery-configuration/include-url[1]"]
      if before_el.nil?
        after_el = doc.root.elements["/discovery-configuration/include-range[last()]"]
        if after_el.nil? 
          after_el = doc.root.elements["/discovery-configuration/specific[last()]"]
        end
      end
      if !before_el.nil?
        doc.root.insert_before(before_el, new_el)
      elsif !after_el.nil?
        doc.root.insert_after(after_el, new_el)
      else
        doc.root.elements["/discovery-configuration"].add_element new_el
      end
    end
  end
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml", "w"){ |file| file.puts(out) }
end
