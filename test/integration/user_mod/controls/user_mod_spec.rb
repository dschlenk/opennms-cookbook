control 'user_mod' do
  describe opennms_user('jimmy') do
    let(:node) { json('/tmp/kitchen/dna.json').params }
    # roles didn't exist until 19 but also that was a long time ago so just skip testing releases prior to 19
    before do
      puts "version is #{node['opennms']['version']}"
      skip if node['opennms']['version'].to_i < 19
    end

    it { should exist }
    its('full_name') { should eq 'Jimmy Jam' }
    its('user_comments') { should eq 'The Time' }
    its('password') { should eq 'gU2wmSW7k9v1xg4/MrAsaI+VyddBAhJJt4zPX5SGG0BK+qiASGnJsqM8JOug/aEL' }
    its('password_salt') { should eq true }
    its('roles') { should eq ['ROLE_USER'] }
  end

  # minimal
  describe opennms_user('johnny') do
    let(:node) { json('/tmp/kitchen/dna.json').params }
    # roles didn't exist until 19 but also that was a long time ago so just skip testing releases prior to 19
    before do
      skip if node['opennms']['version'].to_i < 19
    end

    it { should exist }
    its('roles') { should eq ['ROLE_ADMIN'] }
  end
end
