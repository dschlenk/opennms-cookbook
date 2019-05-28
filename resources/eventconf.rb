# frozen_string_literal: true
require 'rexml/document'
actions :create, :delete
default_action :create

attribute :filename, name_attribute: true, kind_of: String, required: true
# default is a file in your cookbook, use a URL here to do something different
attribute :source, kind_of: String, default: 'cookbook_file'
# 'bottom' places it near the bottom before these files:
# ncs-component.events.xml
# asset-management.events.xml
# Standard.events.xml
# default.events.xml
#
# 'top' places it just after
# Translator.events.xml
#
# TODO: 'alphabetical' places it in alphabetical order with the other vendor MIBs.
attribute :position, kind_of: String, default: 'bottom', equal_to: %w(bottom top), required: true
attr_accessor :exists
