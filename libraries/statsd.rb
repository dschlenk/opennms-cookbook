# frozen_string_literal: true
require 'rexml/document'

module Statsd
  def package_exists?(name, node)
    Chef::Log.debug "Checking to see if this statsd package exists: '#{name}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/statsd-configuration.xml", 'r')
    doc = REXML::Document.new file
    !doc.elements["/statistics-daemon-configuration/package[@name='#{name}']"].nil?
  end

  def report_exists?(name, report_name, package, node)
    name = report_name unless report_name.nil?
    Chef::Log.debug "Checking to see if this statsd package exists: '#{name}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/statsd-configuration.xml", 'r')
    doc = REXML::Document.new file
    !doc.elements["/statistics-daemon-configuration/package[@name='#{package}']/packageReport[@name='#{name}']"].nil?
  end
end
