require 'rexml/document'
actions :create
default_action :create

attribute :resolution_prefix, :kind_of => String, :name_attribute => true, :default => 'RESOLVED: '
# Array of strings. 
attribute :uei, :kind_of => Array, :default => []
attribute :notify, :kind_of => [TrueClass, FalseClass], :default => true

attr_accessor :exists
