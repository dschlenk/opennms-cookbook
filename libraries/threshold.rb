require 'rexml/document'

module Threshold
  def group_exists?(name, node)
    Chef::Log.debug "Checking to see if this threshold group exists: '#{ name }'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml", "r")
    doc = REXML::Document.new file
    !doc.elements["/thresholding-config/group[@name='#{name}']"].nil?
  end

  def threshold_exists?(name, group, node)
    Chef::Log.debug "Checking to see if this threshold exists: '#{ name }' in group '#{group}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml", "r")
    doc = REXML::Document.new file
    !doc.elements["/thresholding-config/group[@name='#{group}']/threshold[@ds-name = '#{name}']"].nil?
  end

  def expression_exists?(name, group, node)
    Chef::Log.debug "Checking to see if this threshold expression exists: '#{ name }' in group '#{group}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml", "r")
    doc = REXML::Document.new file
    !doc.elements["/thresholding-config/group[@name='#{group}']/expression[@expression = '#{name}']"].nil?
  end
end
