#
# Cookbook:: cockpit_install
# Recipe:: default
#

# Enable repos on Debian and RHEL
case node['platform']
when 'debian'
  case node['lsb']['codename']
  when 'jessie'
    apt_repository 'backports' do
      uri 'http://deb.debian.org/debian/'
      distribution 'jessie-backports-sloppy'
      components ['main']
    end
  when 'stretch'
    apt_repository 'backports' do
      uri 'http://deb.debian.org/debian/'
      distribution 'stretch-backports'
      components ['main']
    end
  end
when 'redhat'
  rhsm_repo 'rhel-7-server-extras-rpms' do
    action :enable
  end
end

# Install, upgrade or remove the package
case node['cockpit_install']['action']
when 'install', 'upgrade', 'remove'
  package 'cockpit' do
    action node['cockpit_install']['action'].to_s.to_sym
  end
else
  # Install a specific version
  package 'cockpit' do
    action :install
    version node['cockpit_install']['action'].to_s
  end
end

# Enable and start the services
%w(cockpit.socket cockpit-ws).each do |name|
  service name do
    action [:enable, :start]
  end
end

# Add firewall rules on CentOS and RHEL
case node['platform']
when 'redhat'
  firewalld_service 'cockpit' do
    action :add
  end
when 'centos'
  firewalld_service 'cockpit' do
    action :add
    zone 'public'
  end
end