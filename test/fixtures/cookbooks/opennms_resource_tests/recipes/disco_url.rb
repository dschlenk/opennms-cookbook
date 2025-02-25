# all options
opennms_disco_url 'file:/opt/opennms/etc/include' do
  location 'Detroit'
  file_name 'include'
  foreign_source 'disco-url-source'
  retry_count 13
  timeout 4000
end

# minimal
opennms_disco_url 'http://example.com/include'

# minimal with location
opennms_disco_url 'http://other.net/things' do
  location 'Detroit'
end

opennms_disco_url 'https://example.com/exclude' do
  location 'Jupiter'
  url_type 'include'
end

opennms_disco_url 'update' do
  url 'https://example.com/exclude'
  url_type 'include'
  location 'Jupiter'
  retry_count 14
  action :update
end

opennms_disco_url 'implicit update' do
  url 'https://example.com/exclude'
  url_type 'include'
  location 'Jupiter'
  timeout 400
end

opennms_disco_url 'noop' do
  url 'https://example.com/exclude'
  url_type 'include'
  location 'Jupiter'
  retry_count 15
  action :create_if_missing
end

opennms_disco_url 'functional :create_if_missing' do
  url 'https://example.com/excludes'
  url_type 'exclude'
  action :create_if_missing
end

opennms_disco_url 'url to delete' do
  url 'http://zombo.com'
  url_type 'include'
  action :create
end

opennms_disco_url 'delete url' do
  url 'http://zombo.com'
  action :delete
end

opennms_disco_url 'delete nonexistant url similar to existant url' do
  url 'http://example.com/include'
  location 'Uranus'
  action :delete
end
