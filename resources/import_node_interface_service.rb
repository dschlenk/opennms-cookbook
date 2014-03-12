actions :create
default_action :create

attribute :service_name, :kind_of => String, :name_attribute => true
attribute :foreign_source_name, :kind_of => String, :required => true
attribute :foreign_id, :kind_of => String, :required => true
attribute :ip_addr, :kind_of => String, :required => true
attribute :sync_import, :kind_of => [TrueClass, FalseClass], :default => false

attr_accessor :exists, :interface_exists, :node_exists, :import_exists
