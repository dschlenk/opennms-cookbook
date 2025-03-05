include Opennms::XmlHelper
include Opennms::Cookbook::Threshold::ThresholdsTemplate
unified_mode true

property :group, String, required: true, identity: true
property :relaxed, [true, false]
# required for new
property :type, String, equal_to: %w(high low relativeChange absoluteChange rearmingAbsoluteChange), identity: true
property :description, String
# required for new
property :ds_type, String, identity: true
# required for new
property :value, [Float, String], callbacks: {
  'should be a Float or a String representing the same or a metadata expression' => lambda { |p|
    p.is_a?(Float) || (p.is_a?(String) && p.match(/[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?|\$\{(.+:.+)\}/))
  },
}
# required for new
property :rearm, [Float, String], callbacks: {
  'should be a Float or a String representing the same or a metadata expression' => lambda { |p|
    p.is_a?(Float) || (p.is_a?(String) && p.match(/[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?|\$\{(.+:.+)\}/))
  },
}
# will default to 1 for creates
property :trigger, [Integer, String], callbacks: {
  'should be an Integer or a String representing the same or a metadata expression' => lambda { |p|
    p.is_a?(Integer) || (p.is_a?(String) && p.match(/[0-9]*[1-9][0-9]*|\$\{(.+:.+)\}/))
  },
}

property :ds_label, String
property :triggered_uei, String, identity: true
property :rearmed_uei, String, identity: true
# only relevent if resource filters present
property :filter_operator, String, identity: true, callbacks: {
  'should be a String matching regular expression `([Oo][Rr])|([Aa][Nn][Dd])`' => lambda { |p|
    p.is_a?(String) && p.match(/([Oo][Rr])|([Aa][Nn][Dd])/)
  },
}
# Array of hashes with two keys each: 'field', 'filter'. Like:
# [{'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$'}, ... ]
property :resource_filters, Array, identity: true, callbacks: {
  'should be an array of hashes which each contain keys `field` and `filter`, both strings.' => ->(p) { !p.any? { |h| !h.is_a?(Hash) || !h.key?('field') || !h['field'].is_a?(String) || !h.key?('filter') || !h['filter'].is_a?(String) } } }

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Threshold::ThresholdsTemplate
end

load_current_value do |new_resource|
  group = if thresholds_resource.nil?
            Opennms::Cookbook::Threshold::ThresholdsFile.read("#{onms_etc}/thresholds.xml").groups[new_resource.group]
          else
            thresholds_resource.variables[:config].groups[new_resource.group]
          end
  current_value_does_not_exist! if group.nil?
  ip = %i(type ds_type filter_operator resource_filters).map { |p| [p, new_resource.send(p)] }.to_h.compact
  if new_resource.respond_to?(:ds_name)
    ip[:ds_name] = new_resource.ds_name
  else
    ip[:expression] = new_resource.expression
  end
  t = group.find_rule(**ip)
  current_value_does_not_exist! if t.nil?
  %i(relaxed description ds_label value rearm trigger).each do |p|
    send(p, t.send(p))
  end
end

action :create do
  converge_if_changed do
    thresholds_resource_init
    group = thresholds_resource.variables[:config].groups[new_resource.group]
    raise Chef::Exceptions::Validation, "Cannot add a rule to #{new_resource.group} because it does not exist" if group.nil?
    ip = %i(type ds_type filter_operator resource_filters triggered_uei rearmed_uei).map { |p| [p, new_resource.send(p)] }.to_h.compact
    if new_resource.respond_to?(:ds_name)
      ip[:ds_name] = new_resource.ds_name
    else
      ip[:expression] = new_resource.expression
    end
    t = group.find_rule(**ip)
    if t.nil?
      rp = %i(type ds_type filter_operator resource_filters relaxed description ds_label value rearm trigger).map { |p| [p, new_resource.send(p)] }.to_h.compact
      if new_resource.respond_to?(:ds_name)
        rp[:ds_name] = new_resource.ds_name
      else
        rp[:expression] = new_resource.expression
      end
      group.add_rule(**rp)
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  thresholds_resource_init
  group = thresholds_resource.variables[:config].groups[new_resource.group]
  raise Chef::Exceptions::Validation, "Cannot add a rule to #{new_resource.group} because it does not exist" if group.nil?
  ip = %i(type ds_type filter_operator resource_filters triggered_uei rearmed_uei).map { |p| [p, new_resource.send(p)] }.to_h.compact
  if new_resource.respond_to?(:ds_name)
    ip[:ds_name] = new_resource.ds_name
  else
    ip[:expression] = new_resource.expression
  end
  t = group.find_rule(**ip)
  run_action(:create) if t.nil?
end

action :update do
  converge_if_changed do
    thresholds_resource_init
    group = thresholds_resource.variables[:config].groups[new_resource.group]
    raise Chef::Exceptions::Validation, "Cannot add a rule to #{new_resource.group} because it does not exist" if group.nil?
    ip = %i(type ds_type filter_operator resource_filters triggered_uei rearmed_uei).map { |p| [p, new_resource.send(p)] }.to_h.compact
    if new_resource.respond_to?(:ds_name)
      ip[:ds_name] = new_resource.ds_name
    else
      ip[:expression] = new_resource.expression
    end
    t = group.find_rule(**ip)
    raise Chef::Exceptions::ResourceNotFound, 'No existing rule found to update. Use `:create` action to create new rules.' if t.nil?
    rp = %i(relaxed description ds_label value rearm trigger).map { |p| [p, new_resource.send(p)] }.to_h.compact
    t.update(**rp)
  end
end

action :delete do
  thresholds_resource_init
  group = thresholds_resource.variables[:config].groups[new_resource.group]
  unless group.nil?
    ip = %i(type ds_type filter_operator resource_filters triggered_uei rearmed_uei).map { |p| [p, new_resource.send(p)] }.to_h.compact
    if new_resource.respond_to?(:ds_name)
      ip[:ds_name] = new_resource.ds_name
    else
      ip[:expression] = new_resource.expression
    end
    t = group.find_rule(**ip)
    unless t.nil?
      converge_by "Removing #{new_resource.name}" do
        group.delete_rule(**ip)
      end
    end
  end
end
