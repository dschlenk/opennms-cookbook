require 'rexml/document'

actions :create
default_action :create

attribute :service_name, :kind_of => String, :name_attribute => true
attribute :class_name,   :kind_of => String, :required => true
attribute :foreign_source_name, :kind_of => String
attribute :port,         :kind_of => Fixnum
attribute :retry_count,  :kind_of => Fixnum
attribute :timeout,      :kind_of => Fixnum
attribute :params,       :kind_of => Hash
attr_accessor :exists, :foreign_source_exists
