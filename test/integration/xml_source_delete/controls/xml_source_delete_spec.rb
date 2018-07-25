# frozen_string_literal: true
control 'xml_source_delete' do
  describe xml_source('http://{ipaddr}/to-delete', 'foo') do
    it { should_not exist }
  end

  describe xml_source('http://{ipaddr}/get-example', 'foo') do
    it { should_not exist }
  end
end
