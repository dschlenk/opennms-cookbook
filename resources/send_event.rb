# frozen_string_literal: true
actions :run
default_action :run

# not used for anything but identifying the resource
attribute :name, kind_of: String, name_attribute: true
# UEI of the event to send
attribute :uei, kind_of: String, default: 'uei.opennms.org/internal/reloadDaemonConfig'
# array of strings that are passed as command line arguments to
# the send-event.pl script. Assumes you've done the proper string
# escaping required
attribute :parameters, kind_of: Array
