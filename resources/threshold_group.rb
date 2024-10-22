# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :rrd_repository, kind_of: String, required: true

attr_accessor :exists
