# frozen_string_literal: true
require 'rexml/document'

module Threshold
  def group_exists?(name, node)
    Chef::Log.debug "Checking to see if this threshold group exists: '#{name}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml", 'r')
    doc = REXML::Document.new file
    !doc.elements["/thresholding-config/group[@name='#{name}']"].nil?
  end

  def threshold_exists?(threshold, node)
    Chef::Log.debug "Checking to see if this threshold exists: '#{threshold.name}' in group '#{threshold.group}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml", 'r')
    doc = REXML::Document.new file
    !doc.elements[identity_xpath(threshold)].nil?
  end

  def expression_exists?(expression, node)
    Chef::Log.debug "Checking to see if this threshold expression exists: '#{expression.expression}' in group '#{expression.group}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml", 'r')
    doc = REXML::Document.new file
    !doc.elements[expression_identity_xpath(expression)].nil?
  end

  def threshold_changed?(threshold, node)
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml", 'r')
    doc = REXML::Document.new file
    tel = doc.elements[identity_xpath(threshold)]
    unless threshold.description.nil?
      description = tel.attributes['description']
      Chef::Log.debug "description changed? curr: #{description}; new: #{threshold.description}"
      return true unless description == threshold.description
    end
    unless threshold.value.nil?
      value = tel.attributes['value']
      Chef::Log.debug "value changed? curr: #{value}; new: #{threshold.value}"
      return true unless value == threshold.value.to_s
    end
    unless threshold.rearm.nil?
      rearm = tel.attributes['rearm']
      Chef::Log.debug "rearm changed? curr: #{rearm}; new: #{threshold.rearm}"
      return true unless rearm == threshold.rearm.to_s
    end
    unless threshold.trigger.nil?
      trigger = tel.attributes['trigger']
      Chef::Log.debug "trigger changed? curr: #{trigger}; new: #{threshold.trigger}"
      return true unless trigger == threshold.trigger.to_s
    end
    unless threshold.ds_label.nil?
      ds_label = tel.attributes['ds-label']
      Chef::Log.debug "ds_label changed? curr: #{ds_label}; new: #{threshold.ds_label}"
      return true unless ds_label == threshold.ds_label.to_s
    end
    unless threshold.triggered_uei.nil?
      triggered_uei = tel.attributes['triggeredUEI']
      Chef::Log.debug "triggered_uei changed? curr: #{triggered_uei}; new: #{threshold.triggered_uei}"
      return true unless triggered_uei == threshold.triggered_uei
    end
    unless threshold.rearmed_uei.nil?
      rearmed_uei = tel.attributes['rearmedUEI']
      Chef::Log.debug "rearmed_uei changed? curr: #{rearmed_uei}; new: #{threshold.rearmed_uei}"
      return true unless rearmed_uei == threshold.rearmed_uei
    end
    Chef::Log.debug 'No changes found in this threshold.'
    false
  end

  def expression_changed?(expression, node)
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml", 'r')
    doc = REXML::Document.new file
    tel = doc.elements[expression_identity_xpath(expression)]
    unless expression.description.nil?
      description = tel.attributes['description']
      Chef::Log.debug "description changed? curr: #{description}; new: #{expression.description}"
      return true unless description == expression.description
    end
    unless expression.relaxed.nil?
      relaxed = tel.attributes['relaxed']
      Chef::Log.debug "relaxed changed? curr: #{relaxed}; new: #{expression.relaxed}"
      return true unless relaxed == expression.relaxed.to_s
    end
    unless expression.value.nil?
      value = tel.attributes['value']
      Chef::Log.debug "value changed? curr: #{value}; new: #{expression.value}"
      return true unless value == expression.value.to_s
    end
    unless expression.rearm.nil?
      rearm = tel.attributes['rearm']
      Chef::Log.debug "rearm changed? curr: #{rearm}; new: #{expression.rearm}"
      return true unless rearm == expression.rearm.to_s
    end
    unless expression.trigger.nil?
      trigger = tel.attributes['trigger']
      Chef::Log.debug "trigger changed? curr: #{trigger}; new: #{expression.trigger}"
      return true unless trigger == expression.trigger.to_s
    end
    unless expression.ds_label.nil?
      ds_label = tel.attributes['ds-label']
      Chef::Log.debug "ds_label changed? curr: #{ds_label}; new: #{expression.ds_label}"
      return true unless ds_label == expression.ds_label.to_s
    end
    unless expression.triggered_uei.nil?
      triggered_uei = tel.attributes['triggeredUEI']
      Chef::Log.debug "triggered_uei changed? curr: #{triggered_uei}; new: #{expression.triggered_uei}"
      return true unless triggered_uei == expression.triggered_uei
    end
    unless expression.rearmed_uei.nil?
      rearmed_uei = tel.attributes['rearmedUEI']
      Chef::Log.debug "rearmed_uei changed? curr: #{rearmed_uei}; new: #{expression.rearmed_uei}"
      return true unless rearmed_uei == expression.rearmed_uei
    end
    Chef::Log.debug 'No changes found in this expression.'
    false
  end

  def identity_xpath(threshold)
    ds_name = threshold.ds_name || threshold.name
    attrs = "/thresholding-config/group[@name = '#{threshold.group}']/threshold[@ds-name = '#{ds_name}' and @ds-type = '#{threshold.ds_type}' and @type = '#{threshold.type}'"
    attrs = "#{attrs} and @filterOperator = '#{threshold.filter_operator}'" unless threshold.filter_operator.nil? || threshold.filter_operator == 'or'
    if threshold.resource_filters.nil? || threshold.resource_filters == []
      attrs = "#{attrs} and not(resource-filter)"
    else
      threshold.resource_filters.each do |rf|
        attrs = "#{attrs} and resource-filter/@field = '#{rf['field']}' and resource-filter/text() = '#{rf['filter']}'"
      end
    end
    attrs = "#{attrs}]"
    Chef::Log.debug "threshold xpath: #{attrs}"
    attrs
  end

  def expression_identity_xpath(expression)
    exp = expression.expression || expression.name
    attrs = "/thresholding-config/group[@name = '#{expression.group}']/expression[@expression = '#{exp}' and @ds-type = '#{expression.ds_type}' and @type = '#{expression.type}'"
    attrs = "#{attrs} and @filterOperator = '#{expression.filter_operator}'" unless expression.filter_operator.nil? || expression.filter_operator == 'or'
    if expression.resource_filters.nil? || expression.resource_filters == []
      attrs = "#{attrs} and not(resource-filter)"
    else
      expression.resource_filters.each do |rf|
        attrs = "#{attrs} and resource-filter/@field = '#{rf['field']}' and resource-filter/text() = '#{rf['filter']}'"
      end
    end
    attrs = "#{attrs}]"
    Chef::Log.debug "expression xpath: #{attrs}"
    attrs
  end
end
