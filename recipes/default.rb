#
# Cookbook:: cockpit_install
# Recipe:: default
#

# Run only on supported platforms
case node['platform']
when 'debian', 'ubuntu', 'centos', 'redhat'

# Enable repos on Debian and RHEL
  case node['platform']
  when 'debian'
    case node['lsb']['codename']
    when 'jessie'
      file '/etc/apt/sources.list.d/backports-sloppy.list' do
        content 'deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports-sloppy main'
        mode '0644'
        owner 'root'
        group 'root'
      end
      apt_update 'backports-sloppy' do
        subscribes :update, 'file[/etc/apt/sources.list.d/backports-sloppy.list]', :immediately
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

# Enable and start the service
  service 'cockpit.socket' do
    action [:enable, :start]
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

else
  log 'cockpit_install' do
    message "The platform : #{node['platform']} is not supported at this time."
    level :warn
  end
end