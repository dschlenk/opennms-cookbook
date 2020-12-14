control 'collection_package_update_sbifalias' do
  describe collection_package 'foo' do
    its('filter') { should eq "IPADDR != '1.1.1.1' & categoryName == 'update_foo'" }
    its('store_by_if_alias') { should eq true }
  end
end
