# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.changed
    Chef::Log.info "#{@new_resource} already exists but has changed - updating."
    converge_by("Update #{@new_resource}") do
      update_surveillance_view
    end
  elsif @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_surveillance_view
    end
  end
end

def load_current_resource
  @current_resource =
    Chef::Resource::OpennmsSurveillanceView.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.rows(@new_resource.rows)
  @current_resource.columns(@new_resource.columns)
  @current_resource.default_view(@new_resource.default_view)

  if view_exists?(@current_resource.name)
    @current_resource.exists = true
    if view_changed?(@current_resource.name, @current_resource.rows,
                     @current_resource.columns, @current_resource.default_view)
      @current_resource.changed = true
    end
  end
end

def view_exists?(name)
  doc = surveillance_doc
  !doc.elements["/surveillance-view-configuration/views/view[@name='#{name}']"].nil?
end

def view_changed?(name, rows, columns, default_view)
  doc = surveillance_doc
  view = doc.elements["/surveillance-view-configuration/views/view[@name='#{name}']"]
  curr_rows = get_cells(view, 'rows/row-def')
  curr_columns = get_cells(view, 'columns/column-def')
  Chef::Log.debug "rows: #{curr_rows} == #{rows}?"
  return true if curr_rows != rows
  Chef::Log.debug "columns: #{curr_columns} == #{columns}?"
  return true if curr_columns != columns
  curr_default = doc.elements['/surveillance-view-configuration'].attributes['default-view']
  Chef::Log.debug "current default is #{curr_default}"
  return true if default_view == true && curr_default != name
  false
end

def update_surveillance_view
  doc = surveillance_doc
  view = doc.elements["/surveillance-view-configuration/views/view[@name='#{new_resource.name}']"]
  converge_surveillance_view(doc, view, new_resource.rows, new_resource.columns,
                             new_resource.default_view)
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/surveillance-views.xml")
end

def create_surveillance_view
  doc = surveillance_doc
  views = doc.elements['/surveillance-view-configuration/views']
  view = views.add_element('view', 'name' => new_resource.name,
                                   'refresh-seconds' => '300')
  converge_surveillance_view(doc, view, new_resource.rows, new_resource.columns,
                             new_resource.default_view)
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/surveillance-views.xml")
end

def surveillance_doc
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/surveillance-views.xml", 'r')
  doc = REXML::Document.new file
  file.close
  doc
end

def get_cells(view, path)
  cells = {}
  view.elements.each path do |cell|
    cells[cell.attributes['label']] = []
    cell.elements.each 'category' do |category|
      cells[cell.attributes['label']].push category.attributes['name']
    end
  end
  cells
end

def add_cells(container, items, type)
  items.each do |k, v|
    cd = container.add_element(type, 'label' => k)
    v.each do |cat|
      cd.add_element('category', 'name' => cat)
    end
  end
end

def converge_surveillance_view(doc, view, rows, columns, default_view)
  if default_view
    doc.root.add_attribute('default-view', view.attributes['name'])
  end

  view.delete_element 'rows'
  rows_el = view.add_element 'rows'
  add_cells(rows_el, rows, 'row-def')

  view.delete_element 'columns'
  cols_el = view.add_element 'columns'
  add_cells(cols_el, columns, 'column-def')
end
