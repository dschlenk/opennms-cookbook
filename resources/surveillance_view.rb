# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

# rows and columns should be of the form
# { 'Category Label' => ['categoryName', ...], ... }
attribute :rows, kind_of: Hash, default: {}
attribute :columns, kind_of: Hash, default: {}
attribute :default_view, kind_of: [TrueClass, FalseClass], default: false

attr_accessor :exists, :changed
