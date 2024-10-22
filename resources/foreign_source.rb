# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :scan_interval, kind_of: String, default: '1d'

attr_accessor :exists
