categories = {
  'Dogs' => { 'comment' => 'Dogs that have evolved to respond to DNS queries',
              'normal' => '50.0',
              'warning' => '49.0',
              'service' => ['DNS'],
              'rule' => "(isDNS) & (categoryName == 'Dogs')",
  },
  'Cats' => { 'comment' => 'Cats that are pingable and run web server somehow.',
              'normal' => '99.99',
              'warning' => '97.0',
              'service' => %w(ICMP HTTP),
              'rule' => "categoryName == 'Cats'",
  },
}
categories.each do |name, properties|
  describe avail_category(name) do
    its('comment') { should eq properties['comment'] }
    its('normal') { should eq properties['normal'] }
    its('warning') { should eq properties['warning'] }
    its('service') { should eq properties['service'] }
    its('rule') { should eq properties['rule'] }
  end
end

describe avail_category('Email Servers') do
  its('comment') { should eq 'This category includes all managed interfaces which are running an Email service, including SMTP, POP3, or IMAP.  This will include MS Exchange servers running these protocols.' }
  its('normal') { should eq '99.99' }
  its('warning') { should eq '97' }
  its('service') { should eq %w(SMTP IMAP) }
  its('rule') { should eq 'isSMTP | isIMAP' }
end

describe avail_category('Web Servers') do
  its('comment') { should eq 'This category includes all managed interfaces which are running an HTTP server on port 80 or other common ports.' }
  its('normal') { should eq '99.99' }
  its('warning') { should eq '97' }
  its('service') { should eq %w(HTTP HTTPS HTTP-8000 HTTP-8080) }
  its('rule') { should eq 'isHTTP | isHTTPS | isHTTP-8000 | isHTTP-8080' }
end

describe avail_category('JMX Servers') do
  it { should_not exist }
end

describe avail_category('Database Servers') do
  its('normal') { should eq '99.0' }
  its('warning') { should eq '97' }
  its('service') { should eq %w(MySQL Oracle Postgres SQLServer) }
  its('comment') { should eq 'This category includes all managed interfaces which are currently running PostgreSQL, MySQL, SQLServer, or Oracle database servers.' }
  its('rule') { should eq 'isMySQL | isOracle | isPostgres | isSQLServer' }
end

describe avail_category('Other Servers') do
  its('comment') { should eq 'This category includes all managed interfaces which are running FTP (file transfer protocol) servers or SSH (secure shell) servers.' }
  its('normal') { should eq '99.99' }
  its('warning') { should eq '98.6' }
  its('service') { should eq %w(FTP SSH) }
  its('rule') { should eq 'isFTP | isSSH' }
end
