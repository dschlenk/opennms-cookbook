# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :title, kind_of: String, name_attribute: true
attribute :set_default, kind_of: [TrueClass, FalseClass], default: false

attr_accessor :exists, :changed
