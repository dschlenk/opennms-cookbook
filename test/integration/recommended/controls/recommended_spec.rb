%w(opennms-core opennms-webapp-jetty).each do |p|
  describe package(p) do
    it { should be_installed }
    its('version') { should eq '33.1.7-1' }
  end
end
%w(rrdtool jrrd2).each do
  describe package('rrdtool') do
    it { should be_installed }
  end
end

describe file('/opt/opennms/etc/opennms.properties.d/store_by_group.properties') do
  it { should exist }
  its('owner') { should eq 'opennms' }
  its('group') { should eq 'opennms' }
  its('mode') { should cmp '0600' }
  its('content') { should match(/^org\.opennms\.rrd\.storeByGroup=true$/) }
end

describe file('/opt/opennms/etc/rrd-configuration.properties') do
  it { should exist }
  its('owner') { should eq 'opennms' }
  its('group') { should eq 'opennms' }
  its('mode') { should cmp '0664' }
  its('content') { should match(/^org\.opennms\.rrd\.strategyClass=org\.opennms\.netmgt\.rrd\.rrdtool\.MultithreadedJniRrdStrategy$/) }
  its('content') { should match(%r{^org\.opennms\.rrd\.interfaceJar=/usr/share/java/jrrd2.jar$}) }
  its('content') { should match(%r{^opennms\.library\.jrrd2=/usr/lib64/libjrrd2\.so$}) }
end

describe command('/opt/opennms/bin/scvcli list') do
  its('exit_status') { should_not eq 0 }
end

describe command('/opt/opennms/bin/scvcli --password=ulfulfulfulf list') do
  its('exit_status') { should eq 0 }
end

describe http('http://localhost:8980/opennms/rest/users/admin', 'auth': { 'user': 'admin', 'pass': 'admin' }) do
  its('status') { should eq 401 }
end

describe http('http://localhost:8980/opennms/rest/users/admin', 'auth': { 'user': 'admin', 'pass': 'foobar' }) do
  its('status') { should eq 200 }
end

describe service('opennms') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end
