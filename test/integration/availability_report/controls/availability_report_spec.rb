control 'availability_reports' do
  describe availability_report('foo') do
    it { should exist }
    its('type') { should eq 'calendar' }
    its('parameters["category"]["name"]') { should eq 'category' }
    its('parameters"]') { should eq 'Category' }
    its('parameters["category"]["input-type"]') { should eq 'freeText' }
    its('parameters["category"]["default"]') { should eq 'Core' }
    its('parameters["category"]["display-name"]') { should eq 'Category' }
    its('parameters["category"]["input-type"]') { should eq 'reportCategorySelector' }
    its('parameters["category"]["default"]') { should eq 'Network' }
    its('parameters["endDate"]["name"]') { should eq 'endDate' }
    its('parameters["endDate"]["display-name"]') { should eq 'End Date' }
    its('parameters["endDate"]["use-absolute-date"]') { should eq 'false' }
    its('parameters["endDate"]["default-interval"]') { should eq 'month' }
    its('parameters["endDate"]["default-count"]') { should eq '1' }
    its('parameters["endDate"]["default-time.hour"]') { should eq '0' }
    its('parameters["endDate"]["default-time.minute"]') { should eq '0' }
    its('parameters["retryCount"]["name"]') { should eq 'retryCount' }
    its('parameters["retryCount"]["display-name"]') { should eq 'Retry Count' }
    its('parameters["retryCount"]["input-type"]') { should eq 'freeText' }
    its('parameters["retryCount"]["default"]') { should eq '3' }
  end

  describe availability_report('bar') do
    it { should exist }
    its('type') { should eq 'classic' }
    its('parameters["category"]["name"]') { should eq 'category' }
    its('parameters["category"]["display-name    # Date parameter: endDate
    its('parameters["endDate"]["name"]') { should eq 'endDate' }
    its('parameters["endDate"]["display-name"]') { should eq 'End Date' }
    its('parameters["endDate"]["use-absolute-date"]') { should eq 'true' }
    its('parameters["endDate"]["default-interval"]') { should eq 'day' }
    its('parameters["endDate"]["default-count"]') { should eq '7' }
    its('parameters["endDate"]["default-time.hour"]') { should eq '6' }
    its('parameters["endDate"]["default-time.minute"]') { should eq '30' }
    its('parameters["retryCount"]["name"]') { should eq 'retryCount' }
    its('parameters["retryCount"]["display-name"]') { should eq 'Retry Count' }
    its('parameters["retryCount"]["input-type"]') { should eq 'freeText' }
    its('parameters["retryCount"]["default"]') { should eq '5' }
  end

  describe availability_report('baz') do
    it { should exist }
    its('type') { should eq 'calendar' }
    its('parameters["category"]["name"]') { should eq 'category' }
    its('parameters["category"]["display-name"]') { should eq 'Category' }
    its('parameters["category"]["input-type"]') { should eq 'reportCategorySelector' }
    its('parameters["category"]["default"]') { should eq 'WAN' }
    its('parameters["endDate"]["name"]') { should eq 'endDate' }
    its('parameters["endDate"]["display-name"]') { should eq 'End Date' }
    its('parameters["endDate"]["use-absolute-date"]') { should eq 'false' }
    its('parameters["endDate"]["default-interval"]') { should eq 'year' }
    its('parameters["endDate"]["default-count"]') { should eq '2' }
    its('parameters["endDate"]["default-time.hour"]') { should eq '12' }
    its('parameters["endDate"]["default-time.minute"]') { should eq '15' }
    its('parameters["retryCount"]["name"]') { should eq 'retryCount' }
    its('parameters["retryCount"]["display-name"]') { should eq 'Retry Count' }
    its('parameters["retryCount"]["input-type"]') { should eq 'freeText' }
    its('parameters["retryCount"]["default"]') { should eq '10' }
  end

  describe availability_report('delete') do
    it { should_not exist }
  end

  describe availability_report('nope') do
    it { should_not exist }
  end
end
