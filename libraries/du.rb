#
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Based on pg_upgrade resource from the private-chef cookbook included in chef-server: https://github.com/chef/chef-server
# Copyright 2008-2019, Chef Software, Inc, https://www.chef.io/chef/
#
require 'mixlib/shellout'

module Du
  # Calculate the disk space used by the given path. Requires that
  # `du` is in our PATH.
  #
  # @param path [String] Path to a directory on disk
  # @return [Integer] KB used by directory on disk
  #
  def self.du(path)
    # TODO(ssd) 2017-08-18: Do we need to worry about sparse files
    # here? If so, can we expect the --apparent-size flag to exist on
    # all of our platforms.
    command = Mixlib::ShellOut.new("du -sk #{path}")
    command.run_command
    if command.status.success?
      command.stdout.split("\t").first.to_i
    else
      Chef::Log.error("du -sk #{path} failed with exit status: #{command.exitstatus}")
      Chef::Log.error("du stderr: #{command.stderr}")
      raise 'du failed'
    end
  rescue Errno::ENOENT
    raise 'The du utility is not available. Unable to check disk usage'
  end
end