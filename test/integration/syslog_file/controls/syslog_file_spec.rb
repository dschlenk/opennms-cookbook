control 'syslog_file' do
  describe syslog_file('syslog-file1.xml') do
    it { should exist }
    c = <<-EOL
<?xml version="1.0"?>
<syslogd-configuration-group>
    <ueiList>
        <ueiMatch>
            <process-match expression="^file1$" />
            <match type="regex" expression="file1:.*?:\\s+authentication failure; logname=(.*?) uid=(\\d+) euid=(\\d+) tty=(.*?) ruser=.*? rhost=.*? user=(.*?)$" />
            <uei>uei.opennms.org/vendor/posix/syslog/su/authenFailure</uei>
        </ueiMatch>
    </ueiList>
</syslogd-configuration-group>
EOL
    its('content') { should eq c }
    its('position') { should eq 8 }
  end

  describe syslog_file('syslog-file2.xml') do
    it { should exist }
    its('content') do
      should eq <<-EOL
<?xml version="1.0"?>
<syslogd-configuration-group>
    <ueiList>
        <ueiMatch>
            <process-match expression="^file2$" />
            <match type="regex" expression="file2:.*?:\\s+authentication failure; logname=(.*?) uid=(\\d+) euid=(\\d+) tty=(.*?) ruser=.*? rhost=.*? user=(.*?)$" />
            <uei>uei.opennms.org/vendor/posix/syslog/su/authenFailure</uei>
        </ueiMatch>
    </ueiList>
</syslogd-configuration-group>
EOL
    end
    its('position') { should eq 24 }
  end

  describe syslog_file('NetgearProsafeSmartSwitch.syslog.xml') do
    it { should_not exist }
  end

  describe syslog_file('create-if-missing-syslog-file.xml') do
    it { should exist }
  end
end
