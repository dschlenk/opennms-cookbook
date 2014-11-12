require 'rexml/document'

actions :create
default_action :create

attribute :ipaddr, :kind_of => String, :required => true, :name_attribute => true
attribute :retry_count, :kind_of => Fixnum
attribute :timeout, :kind_of => Fixnum
attribute :foreign_source, :kind_of => String

attr_accessor :exists, :foreign_source_exists
