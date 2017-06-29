# frozen_string_literal: true
#
# Cookbook Name:: opennms
# Library:: grafana
#
# Copyright (c) 2016 ConvergeOne Holding Corp.
#
# License: Apache 2.0

module Opennms
  module Grafana
    def self.create_api_key(node)
      require 'rest-client'
      Chef::Log.debug "creating api key with password #{node['grafana']['users']['admin']['password']}."
      response = RestClient::Request.new(
        method: :post,
        url: "http://#{node['grafana']['ini']['server']['domain']}:#{node['grafana']['ini']['server']['http_port']}/api/auth/keys",
        user: 'admin',
        password: node['grafana']['users']['admin']['password'],
        headers: { accept: :json,
                   content_type: :json },
        payload: '{"role":"Viewer","name":"OpenNMS"}'
      ).execute
      results = JSON.parse(response.to_str)
      node.override['opennms']['properties']['grafana']['api_key'] = results['key']
    end

    def self.api_key?(node)
      require 'rest-client'
      Chef::Log.debug "checking api key with password #{node['grafana']['users']['admin']['password']}."
      response = RestClient::Request.new(
        method: :get,
        url: "http://#{node['grafana']['ini']['server']['domain']}:#{node['grafana']['ini']['server']['http_port']}/api/auth/keys",
        user: 'admin',
        password: node['grafana']['users']['admin']['password'],
        headers: { accept: :json }
      ).execute
      keys = JSON.parse(response.to_str)
      keys.select { |k| k['name'] == 'OpenNMS' }.size == 1
    end
  end
end
