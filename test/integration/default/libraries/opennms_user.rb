require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class OpennmsUser < Inspec.resource(1)
  name 'opennms_user'

  desc '
    OpenNMS user
  '

  example '
    describe opennms_user(\'jimmy\', 1234) do
      it { should exist }
      its(\'full_name\') { should eq \'Jimmy John\' }
      its(\'user_comments\') { should eq \'Sandwiches\' }
      its(\'password\') { should eq \'6D639656F5EAC2E799D32870DD86046D\' }
      its(\'password_salt\') { should eq false }
    end
  '

  def initialize(name, port = 8980, auth = 'admin:admin')
    parsed_url = Addressable::URI.parse("http://#{auth}@localhost:#{port}/opennms/rest/users/#{name}").normalize.to_str
    begin
      req = RestClient.get(parsed_url)
    rescue StandardError
      @exists = false
      return
    end
    doc = REXML::Document.new(req)
    u_el = doc.elements['/user']
    @exists = !u_el.nil?
    return unless @exists
    @params = {}
    @params[:full_name] = u_el.elements['full-name'].texts.collect(&:value).join('') unless u_el.elements['full-name'].nil?
    @params[:email] = u_el.elements['email'].texts.collect(&:value).join('') unless u_el.elements['email'].nil?
    @params[:user_comments] = u_el.elements['user-comments'].texts.collect(&:value).join('') unless u_el.elements['user-comments'].nil?
    @params[:password] = u_el.elements['password'].texts.collect(&:value).join('') unless u_el.elements['password'].nil?
    @params[:password_salt] = false
    @params[:password_salt] = true unless u_el.elements['passwordSalt'].nil? || !(u_el.elements['passwordSalt'].texts.collect(&:value).join('') == 'true')
    roles = []
    u_el.elements.each('role') do |r_el|
      roles.push r_el.texts[0].value
    end
    @params[:roles] = roles
    ds = []
    u_el.elements.each('duty-schedule') do |ds_el|
      ds.push ds_el.texts[0].value
    end
    @params[:duty_schedules] = ds
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end
