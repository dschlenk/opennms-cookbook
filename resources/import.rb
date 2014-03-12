require 'rexml/document'

actions :create
default_action :create

# name is actually meaningless but needs to be unique in a client run. 
# foreign_source must reference an existing foreign_source's name.
attribute :name, :kind_of => String, :name_attribute => true
attribute :foreign_source, :kind_of => String, :default => 'imported:'
attribute :sync_import, :kind_of => [TrueClass, FalseClass], :default => false

attr_accessor :exists, :foreign_source_exists
