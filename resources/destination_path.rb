# frozen_string_literal: true
require 'rexml/document'
actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :initial_delay, kind_of: String, default: '0s'

attr_accessor :exists
