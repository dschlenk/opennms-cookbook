if node['platform_version'].to_i == 9
  openjdk_pkg_install 21
else
  temurin_package_install 21 do
    repository_uri 'https://packages.adoptium.net/artifactory/rpm/centos/\$releasever/\$basearch'
  end
end
