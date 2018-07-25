# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class OpennmsUser < Inspec.resource(1)
  name 'opennms_user'

  desc '
    OpenNMS user
  '

  example '
    describe opennms_user(\'jimmy\') do
      it { should exist }
      its(\'full_name\') { should eq \'Jimmy John\' }
      its(\'user_comments\') { should eq \'Sandwiches\' }
      its(\'password\') { should eq \'6D639656F5EAC2E799D32870DD86046D\' }
      its(\'password_salt\') { should eq false }
    end
  '

  def initialize(name)
    parsed_url = Addressable::URI.parse("http://admin:admin@localhost:8980/opennms/rest/users/#{name}").normalize.to_str
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
    @params[:full_name] = u_el.elements['full-name'].texts.join('') unless u_el.elements['full-name'].nil?
    @params[:user_comments] = u_el.elements['user-comments'].texts.join('') unless u_el.elements['user-comments'].nil?
    @params[:password] = u_el.elements['password'].texts.join('') unless u_el.elements['password'].nil?
    @params[:password_salt] = false
    @params[:password_salt] = true unless u_el.elements['passwordSalt'].nil? || !(u_el.elements['passwordSalt'].texts.join('') == 'true')
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end
