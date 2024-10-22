module PostgreSQL
  module Cookbook
    module SqlHelpers
      module Connection
        private

        # until https://github.com/sous-chefs/postgresql/pull/775
        def install_pg_gem
          return if gem_installed?('pg')

          libpq_package_name = case installed_postgresql_package_source
                               when :os
                                 'libpq'
                               when :repo
                                 'libpq5'
                               end

          case node['platform_family']
          when 'fedora'
            declare_resource(:package, libpq_package_name) { compile_time(true) }
          when 'rhel'
            case node['platform_version'].to_i
            when 7
              declare_resource(:package, 'epel-release') { compile_time(true) }
              declare_resource(:package, 'centos-release-scl') { compile_time(true) }
            when 8
              declare_resource(:package, libpq_package_name) { compile_time(true) }
              declare_resource(:package, 'perl-IPC-Run') do
                compile_time(true)
                options('--enablerepo=powertools')
              end
            when 9
              declare_resource(:package, "#{libpq_package_name}-15*") { compile_time(true) }
              declare_resource(:package, 'perl-IPC-Run') do
                compile_time(true)
                if platform?('oracle')
                  options ['--enablerepo=ol9_codeready_builder']
                else
                  options('--enablerepo=crb')
                end
              end
            end
          end

          declare_resource(:build_essential, 'Build Essential') { compile_time(true) }
          declare_resource(:package, postgresql_devel_pkg_name) { compile_time(true) }

          build_options = pg_gem_build_options
          declare_resource(:chef_gem, 'pg') do
            options build_options
            version '~> 1.4'
            compile_time true
          end
        end
      end
    end
  end
end
