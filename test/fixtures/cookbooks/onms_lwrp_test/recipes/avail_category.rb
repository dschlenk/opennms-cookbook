opennms_avail_category 'Cats' do
  comment "Cats that are pingable and run web server somehow."
  services ["ICMP", "HTTP"]
  rule "categoryName == 'Cats'"
end

opennms_avail_category 'Dogs' do
  comment "Dogs that have evolved to respond to DNS queries"
  normal 50.0
  warning 49.0
  services ['DNS']
  rule "(isDNS) & (categoryName == 'Dogs')"
end
