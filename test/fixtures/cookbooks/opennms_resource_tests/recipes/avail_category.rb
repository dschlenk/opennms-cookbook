opennms_avail_category 'Cats' do
  comment 'Cats that are pingable and run web server somehow.'
  services %w(ICMP HTTP)
  rule "categoryName == 'Cats'"
end

opennms_avail_category 'Dogs' do
  comment 'Dogs that have evolved to respond to DNS queries'
  normal 50.0
  warning 49.0
  services ['DNS']
  rule "(isDNS) & (categoryName == 'Dogs')"
end

# remove POP3 from the default config
opennms_avail_category 'Email Servers' do
  services %w(SMTP IMAP)
  rule 'isSMTP | isIMAP'
  action :update
end

# change `normal` on this default category
opennms_avail_category 'Database Servers' do
  normal 99.0
  action :update
end

# change `comment` on this default category
opennms_avail_category 'Web Servers' do
  comment 'This category includes all managed interfaces which are running an HTTP server on port 80 or other common ports.'
  action :update
end

# change `warning` on this default category without explicitly using action `:update`
opennms_avail_category 'Other Servers' do
  warning 98.6
end

# remove this category entirely
opennms_avail_category 'JMX Servers' do
  action :delete
end

# functional :create_if_missing
opennms_avail_category 'create_if_missing' do
  services %w(ICMP)
  action :create_if_missing
end

# create_if_missing that doesn't do anything
opennms_avail_category 'noop create_if_missing' do
  label 'Email Servers'
  services %w(LDAP HTTP)
  rule "IPADDR != '0.0.0.0'"
  action :create_if_missing
end
