%w(opennms postgresql-15).each do |s|
  service s do
    action :stop
  end
end
