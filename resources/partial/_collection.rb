include Opennms::XmlHelper
unified_mode true
property :collection, String, name_property: true
# default: 300 on create
property :rrd_step, kind_of: Integer
# default: ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] on create
property :rras, kind_of: Array, callbacks: {
  'should be an array of strings that match regular expression `RRA:(AVERAGE|MIN|MAX|LAST):.*`' => lambda { |p|
    !p.any? { |s| !s.match(/RRA:(AVERAGE|MIN|MAX|LAST):.*/) }
  },
}

action_class do
  include Opennms::XmlHelper
end
