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
# Copyright 2014-2020, ConvergeOne
#

class Chef
  class Recipe
    def old_data_dir
      # Something to play with - just discover the first initialized data dir
      # that isn't the new data dir.
      # Assumption: we will not support installing multiple versions of this package
      # on top of each other without expecting at least one reconfigure in between...
      #
      # Cheat and use gem's version parsing and comparison operators.
      # Note we're doing a reverse sort to put the highest version at 0,
      # and we're not checking '==' because we can't have two paths of the same name. # filter those with no PG_VERSION
      ::Dir.glob(::File.join(::File.expand_path('../..', new_data_dir), '*/data'))
           .reject { |dir| dir == new_data_dir } # ignore the new one
           .map { |dir| [dir, version_from_data_dir(dir)] }
           .reject { |_dir, vsn| !vsn }.sort { |a, b| Gem::Version.new(a[1]) > Gem::Version.new(b[1]) ? -1 : 1 }
           .map(&:first).first # drop the versions again
    end

    def new_data_dir
      "/var/lib/pgsql/#{node['postgresql']['version']}/data"
    end

    # Find the location of the binaries that interact with a Postgres
    # cluster of the given `version`
    #
    # @note The path used in this method are taken from how we currently
    #   use Postgres software definitions.
    #
    # @param version [String] indicates the major release of Postgres,
    #   e.g. "9.1", "9.2".  Note that this does NOT include patch-levels,
    #   like "9.1.9" or "9.2.4"
    # @return [String] the absolute path to the binaries.
    def binary_path_for(version)
      "/usr/pgsql-#{version}/bin"
    end

    # @return [Boolean] Whether or not an upgrade is needed, and the
    # why-run message to describe what we're doing (or why we're not doing
    # anything)
    def upgrade_required?
      if old_data_dir.nil?
        # This will only happen if we've never successfully completed a
        # Private Chef installation on this machine before.  In that case,
        # there is (by definition) nothing to upgrade
        Chef::Log.info 'No prior database cluster detected; nothing to upgrade'
        false
      elsif old_data_dir == new_data_dir
        # If the directories are the same, then we're not changing anything
        # (since we keep data directories in version-scoped
        # directories); i.e., this is just another garden-variety chef run
        Chef::Log.info 'Database cluster is unchanged; nothing to upgrade'
        false
      elsif Dir.exist?(new_data_dir) && cluster_initialized?(new_data_dir) && ::File.exist?(sentinel_file)
        # If the directories are different, we may need to do an upgrade,
        # but only if all the steps along the way haven't been completed
        # yet.  We'll look for a sentinel file (which we'll write out
        # following a successful upgrade) as final confirmation.
        #
        # If we then make it all the way through the chef run, then the next
        # time through, the old_data_dir will be the same as our
        # new_data_dir
        Chef::Log.info 'Database cluster already upgraded from previous installation; nothing to do'
        false
      else
        # Hmm, looks like we need to upgrade after all
        true
      end
    end

    # If this file exists, assume that the upgrade has succeeded
    def sentinel_file
      ::File.join(new_data_dir, 'upgraded.sentinel')
    end

    # Postgres stores version information inside a cluster's data
    # directory; given the directory, then, we can figure out what version
    # of Postgres is managing it.
    #
    # @param data_dir [String] the absolute path of a Postgres cluster's
    #   data directory
    #
    # @return [String, nil] the major version of the Postgres cluster in
    #   `data_dir`, or `nil` if the directory does not exist, or if a
    #   cluster has not yet been initialized in it
    def version_from_data_dir(data_dir)
      if Dir.exist?(data_dir)
        cluster_initialized_ = cluster_initialized?(data_dir)
        if cluster_initialized_
          # Might not be initialized yet if a prior Chef run failed between
          # creating the directory and initializing a cluster in it

          # the version file contains is a single line with the version
          # (e.g. "9.2\n")
          IO.read(version_file_for(data_dir)).strip
        else
          Chef::Log.fatal "File don't exist #{cluster_initialized_}"
        end
      else
        Chef::Log.fatal "Dir don't exist #{data_dir}"
      end
    end

    # Use the existence of a PG_VERSION file in a cluster's data directory
    # as an indicator of it having been already set up.
    def cluster_initialized?(data_dir)
      ::File.exist?(version_file_for(data_dir))
    end

    def version_file_for(data_dir)
      ::File.join(data_dir, 'PG_VERSION')
    end

    def get_psql_short(version)
      version.sub('.', '')
    end

    #
    # Since we don't use the --link flag, we need to ensure the disk has
    # enough space for another copy of the postgresql data.
    #
    def check_required_disk_space
      old_data_dir_size = Du.du(old_data_dir)
      # new_data_dir might not exist at the point of making this check.
      # In that case check the first existing directory above it.
      new_dir = dir_or_existing_parent(new_data_dir)
      free_disk_space = Statfs.new(new_dir).free_space

      if old_data_dir_size < (free_disk_space * 0.90)
        Chef::Log.info("!!!!!!!!!!!!! Old data dir size: #{old_data_dir_size}")
        Chef::Log.info("Free disk space: #{free_disk_space}")
        Chef::Log.info('Free space is sufficient to start upgrade')
        true
      else
        Chef::Log.fatal('Insufficient free space on disk to complete upgrade.')
        Chef::Log.fatal("The current postgresql data directory contains #{old_data_dir_size} KB of data but only #{free_disk_space} KB is available on disk.")
        Chef::Log.fatal("The upgrade process requires at least #{old_data_dir_size / 0.90} KB.")
        raise 'Insufficient Disk Space to Upgrade'
      end
    end

    def dir_or_existing_parent(dir)
      return dir if ::File.exist?(dir)
      return dir if ::File.expand_path(dir) == '/'

      dir_or_existing_parent(::File.expand_path("#{dir}/.."))
    end
  end
end
