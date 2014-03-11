require 'rexml/document'

actions :create
default_action :create

attribute :name,        :kind_of => String, :name_attribute => true, :required => true
attribute :range_begin, :kind_of => String, :required => true
attribute :range_end,   :kind_of => String, :required => true
attribute :range_type,  :kind_of => String, :default => "include", :equal_to => ["include", "exclude"], :required => true
attribute :retry_count, :kind_of => Fixnum
attribute :timeout,     :kind_of => Fixnum
attr_accessor :exists
