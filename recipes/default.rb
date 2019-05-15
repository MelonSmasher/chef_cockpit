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

  if node['cockpit_install']['machines']
    template '/etc/cockpit/machines.d/50-chef.json' do
      source '50-chef.json.erb'
      mode '0644'
      owner 'root'
      group 'root'
      variables(machines: node['cockpit_install']['machines'])
    end
  end

  if node['cockpit_install']['auto_discover']
    unless node['cockpit_install']['auto_discover'].nil?
      discovered = []
      search(:node,
             node['cockpit_install']['auto_discover_filter'],
             :filter_result => {'name' => ['name'],
                                'ip' => ['ipaddress'],
                                'platform' => ['platform']
             }
      ).each do |result|
        case result['platform']
        when 'ubuntu', 'redhat', 'centos'
          discovered[result['name']]['address'] = result['ip']
          discovered[result['name']]['visible'] = true
        end
      end
    end

    template '/etc/cockpit/machines.d/50-chef-discovered.json' do
      source '50-chef-discovered.json.erb'
      mode '0644'
      owner 'root'
      group 'root'
      variables(discovered: discovered)
    end
  end

else
  log 'cockpit_install' do
    message "The platform : #{node['platform']} is not supported at this time."
    level :warn
  end
end