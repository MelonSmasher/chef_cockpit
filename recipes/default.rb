#
# Cookbook:: cockpit_install
# Recipe:: default
#

# Run only on supported platforms
case node['platform']
when 'ubuntu', 'centos', 'redhat'

# Enable RHEL repos
  case node['platform']
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
      notifies :restart, 'service[cockpit],service[cockpit.socket]', :delayed
    end
  else
    # Install a specific version
    package 'cockpit' do
      action :install
      version node['cockpit_install']['action'].to_s
      notifies :restart, 'service[cockpit],service[cockpit.socket]', :delayed
    end
  end

# Enable and start the service
  service 'cockpit.socket' do
    action [:enable, :start]
  end
  service 'cockpit' do
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

  machines = Chef::JSONCompat.to_json_pretty(node['cockpit_install']['machines'].to_hash)
  file '/etc/cockpit/machines.d/50-chef.json' do
    content machines.to_s
    mode '0644'
    owner 'root'
    group 'root'
    notifies :restart, 'service[cockpit],service[cockpit.socket]', :delayed
  end

else
  log 'cockpit_install' do
    message "The platform : #{node['platform']} is not supported at this time."
    level :warn
  end
end