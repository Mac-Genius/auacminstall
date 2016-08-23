#
# Cookbook Name:: auacminstall
# Recipe:: default
#

if node["platform"].eql? "centos"
  include_recipe 'auacminstall::centos_dependencies'
elsif node["platform"].eql? "ubuntu"
  include_recipe 'auacminstall::ubuntu_dependencies'
end

include_recipe 'auacminstall::create_user'
include_recipe 'auacminstall::install_auacm'

if node["platform"].eql? "centos"
  include_recipe 'auacminstall::centos_setup_database'
  include_recipe 'auacminstall::centos_install_python'
  include_recipe 'auacminstall::centos_configure_auacm'
elsif node["platform"].eql? "ubuntu"
  include_recipe 'auacminstall::ubuntu_setup_database'
  include_recipe 'auacminstall::ubuntu_configure_auacm'
end

# Prints the address of the node at the end of the run
ruby_block 'print address' do
  block do
    hostname = `hostname -I`.split(' ')
    Chef::Log.info 'AUACM should now at one of the following addresses:'
    hostname.each do |ip|
      Chef::Log.info "http://#{ip}:5000"
    end
  end
end