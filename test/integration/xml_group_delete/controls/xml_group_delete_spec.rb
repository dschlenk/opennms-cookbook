# frozen_string_literal: true
control 'xml_group_delete' do
  describe xml_group('minimal', 'http://{ipaddr}/get-minimal', 'foo') do
    it { should_not exist }
  end
  describe xml_group('fxa-sc', 'http://{ipaddr}/group-example', 'foo') do
    it { should_not exist }
  end
end
