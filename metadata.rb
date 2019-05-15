name 'cockpit_install'
maintainer 'Alex Markessinis'
maintainer_email 'markea125@gmail.com'
license 'MIT'
description 'Installs Cockpit'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.4.1'
chef_version ">= 12.11" if respond_to?(:chef_version)
issues_url 'https://github.com/melonsmasher/chef_cockpit_install/issues' if respond_to?(:issues_url)
source_url 'https://github.com/melonsmasher/chef_cockpit_install' if respond_to?(:source_url)

depends 'redhat_subscription_manager'
depends 'firewalld'

supports 'ubuntu', '>= 16.04'
supports 'centos', '>= 7.0'
supports 'redhat', '>= 7.0'

