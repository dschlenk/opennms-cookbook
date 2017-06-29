# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :section, kind_of: String, name_attribute: true
# containing view-name, default is the default OpenNMS ships with
attribute :view_name, kind_of: String, default: 'WebConsoleView'
attribute :category_group, kind_of: String, default: 'WebConsole'
attribute :categories, kind_of: Array, default: []
# controls where to position new view sections.
# Only affects new resources; doesn't move existing view sections.
# It's an error to define all three of these attributes. If more than one
# are defined, the precendence is:
# before
# after
# position
attribute :before, kind_of: String # name of a view section to place the new section before
attribute :after, kind_of: String # name of a view section to place the new section after
# append or prepend this view section to the current sections list
attribute :position, kind_of: String, equal_to: %w(top bottom), default: 'top'

attr_accessor :exists, :categories_exist, :view_name_exists, :changed, :position_valid
