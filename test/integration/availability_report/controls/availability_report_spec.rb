control 'availability_reports' do
  describe availability_report('foo') do
    it { should exist }
    it { expect(subject.type).to eq 'calendar' }
    it { expect(subject.parameters['category']['name']).to eq 'category' }
    it { expect(subject.parameters['category']['display-name']).to eq 'Category' }
    it { expect(subject.parameters['category']['input-type']).to eq 'reportCategorySelector' }
    it { expect(subject.parameters['category']['default']).to eq 'Network' }
    it { expect(subject.parameters['endDate']['name']).to eq 'endDate' }
    it { expect(subject.parameters['endDate']['display-name']).to eq 'End Date' }
    it { expect(subject.parameters['endDate']['use-absolute-date']).to eq 'false' }
    it { expect(subject.parameters['endDate']['default-interval']).to eq 'month' }
    it { expect(subject.parameters['endDate']['default-count']).to eq '1' }
    it { expect(subject.parameters['endDate']['default-time']['hour']).to eq '0' }
    it { expect(subject.parameters['endDate']['default-time']['minute']).to eq '0' }
    it { expect(subject.parameters['retryCount']['name']).to eq 'retryCount' }
    it { expect(subject.parameters['retryCount']['display-name']).to eq 'Retry Count' }
    it { expect(subject.parameters['retryCount']['input-type']).to eq 'freeText' }
    it { expect(subject.parameters['retryCount']['default']).to eq '3' }
  end

  describe availability_report('bar') do
    it { should exist }
    it { expect(subject.type).to eq 'classic' }
    it { expect(subject.parameters['category']['name']).to eq 'category' }
    it { expect(subject.parameters['category']['display-name']).to eq 'Category' }
    it { expect(subject.parameters['category']['input-type']).to eq 'freeText' }
    it { expect(subject.parameters['category']['default']).to eq 'Core' }
    it { expect(subject.parameters['endDate']['name']).to eq 'endDate' }
    it { expect(subject.parameters['endDate']['display-name']).to eq 'End Date' }
    it { expect(subject.parameters['endDate']['use-absolute-date']).to eq 'true' }
    it { expect(subject.parameters['endDate']['default-interval']).to eq 'day' }
    it { expect(subject.parameters['endDate']['default-count']).to eq '7' }
    it { expect(subject.parameters['endDate']['default-time']['hour']).to eq '6' }
    it { expect(subject.parameters['endDate']['default-time']['minute']).to eq '30' }
    it { expect(subject.parameters['retryCount']['name']).to eq 'retryCount' }
    it { expect(subject.parameters['retryCount']['display-name']).to eq 'Retry Count' }
    it { expect(subject.parameters['retryCount']['input-type']).to eq 'freeText' }
    it { expect(subject.parameters['retryCount']['default']).to eq '5' }
  end

  describe availability_report('baz') do
    it { should exist }
    it { expect(subject.type).to eq 'calendar' }
    it { expect(subject.parameters['category']['name']).to eq 'category' }
    it { expect(subject.parameters['category']['display-name']).to eq 'Category' }
    it { expect(subject.parameters['category']['input-type']).to eq 'reportCategorySelector' }
    it { expect(subject.parameters['category']['default']).to eq 'WAN' }
    it { expect(subject.parameters['endDate']['name']).to eq 'endDate' }
    it { expect(subject.parameters['endDate']['display-name']).to eq 'End Date' }
    it { expect(subject.parameters['endDate']['use-absolute-date']).to eq 'false' }
    it { expect(subject.parameters['endDate']['default-interval']).to eq 'year' }
    it { expect(subject.parameters['endDate']['default-count']).to eq '2' }
    it { expect(subject.parameters['endDate']['default-time']['hour']).to eq '12' }
    it { expect(subject.parameters['endDate']['default-time']['minute']).to eq '15' }
    it { expect(subject.parameters['retryCount']['name']).to eq 'retryCount' }
    it { expect(subject.parameters['retryCount']['display-name']).to eq 'Retry Count' }
    it { expect(subject.parameters['retryCount']['input-type']).to eq 'freeText' }
    it { expect(subject.parameters['retryCount']['default']).to eq '10' }
  end

  describe availability_report('delete') do
    it { should_not exist }
  end

  describe availability_report('nope') do
    it { should_not exist }
  end
end
