require 'rexml/document'

actions :create
default_action :create

attribute :node_label, :kind_of => String, :name_attribute => true
attribute :foreign_source_name, :kind_of => String, :required => true
attribute :foreign_id, :kind_of => String, :required => true
attribute :parent_foreign_source, :kind_of => String
attribute :parent_foreign_id, :kind_of => String
attribute :parent_node_label, :kind_of => String
attribute :city, :kind_of => String
attribute :building, :kind_of => String
attribute :categories, :kind_of => Array
# key/value pairs - keys must be valid asset fields!
attribute :assets, :kind_of => Hash
attribute :sync_import, :kind_of => [TrueClass, FalseClass], :default => false

attr_accessor :exists, :import_exists
