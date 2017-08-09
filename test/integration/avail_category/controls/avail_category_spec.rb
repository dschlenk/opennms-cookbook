#def category_path(name) 
#  "/catinfo/categorygroup/categories/category[contains(.,'#{name}')]"
#end
#
#def element_path(name, value)
#  "#{name}[contains(.,'#{value}')]"
#end
#
#category_file = '/opt/opennms/etc/categories.xml'
categories = { 
  'Dogs' => { 'comment' => 'Dogs that have evolved to respond to DNS queries',
    'normal' => '50.0',
    'warning' => '49.0',
    'service' => ['DNS'],
    'rule' => "(isDNS) & (categoryName == 'Dogs')"
  },
  'Cats' => { 'comment' => 'Cats that are pingable and run web server somehow.',
    'normal' => '99.99',
    'warning' => '97.0',
    'service' => ['ICMP', 'HTTP'],
    'rule' => "categoryName == 'Cats'"
  }
}
categories.each do |name, properties|
  describe avail_category(name) do
   its('comment') { should eq properties['comment'] }
   its('normal') { should eq properties['normal'] }
   its('warning') { should eq properties['warning'] }
   its('service') { should eq properties['service'] }
   its('rule') { should eq properties['rule'] }
  end
end
#cf = file(category_file)
#doc = REXML::Document.new(cf.content)
#
#categories.each do |name, properties|
#  cat_el = doc.elements[category_path(name)]
#  describe cat_el do
#    it { should_not eq nil }
#  end
#  properties.each do |k,v|
#    vs = v
#    vs = [v] unless v.is_a? Array
#    vs.each do |vv|
#      p_el = cat_el.elements[element_path(k,vv)]
#      describe p_el do
#        it { should_not eq nil }
#      end
#    end
#  end
#end
