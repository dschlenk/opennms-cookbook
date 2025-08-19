include_recipe 'opennms_resource_tests::jms_nb_destination'

opennms_jms_nb_destination 'baz' do
  action :delete
end
