# frozen_string_literal: true
require 'rexml/document'
class AvailCategory < Inspec.resource(1)
  name 'avail_category'

  desc '
    OpenNMS Availability Category
  '

  example '
    describe avail_category(\'Web Servers\') do
      its(\'comment\') { should eq \'the comment\' }
      its(\'normal\') { should eq \'99.0\' }
      its(\'warning\') { should eq \'95.0\' }
      its(\'service\') { should eq [\'HTTP\'] }
    end
  '

  def initialize(cat_name)
    @cat_name = cat_name
    category_file = '/opt/opennms/etc/categories.xml'
    cf = inspec.file(category_file)
    doc = REXML::Document.new(cf.content)
    cat_el = doc.elements[category_path(@cat_name)]
    @exists = !cat_el.nil?
    return unless @exists
    @comment = cat_el.elements['comment'].text.to_s unless cat_el.elements['comment'].nil?
    @normal = cat_el.elements['normal'].text.to_s
    @warning = cat_el.elements['warning'].text.to_s
    @service = []
    cat_el.each_element('service') do |s|
      @service.push s.text.to_s
    end
    @rule = cat_el.elements['rule'].text.to_s
  end

  attr_reader :comment

  attr_reader :normal

  attr_reader :warning

  attr_reader :service

  attr_reader :rule

  def exist?
    @exists
  end

  private

  def category_path(name)
    "/catinfo/categorygroup/categories/category[contains(.,'#{name}')]"
  end
end
