# frozen_string_literal: true
control 'jmx_delete' do
  describe jmx_collection_service('jmx_url_ignore_path', 'jmxcollection', 'jmx1') do
    it { should_not exist }
  end
end
