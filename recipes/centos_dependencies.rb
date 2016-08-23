# Installs the Auburn ACM website on Centos 7
yum_package "python-devel" do
  :install
end

yum_package "libffi-devel" do
  :install
end

yum_package "openssl-devel" do
  :install
end

execute "install_nodejs" do
  command "sudo curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -"
  action :run
  not_if { node['packages']['nodejs'] != nil }
end

yum_package "nodejs" do
  action :install
  not_if { node['packages']['nodejs'] != nil }
end

remote_file '/mysql57-community-release-el7-8.noarch.rpm' do
  source 'http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm'
  action :create
  not_if { node['packages']['nodejs'] != nil }
end

rpm_package "mysql-server" do
  source '/mysql57-community-release-el7-8.noarch.rpm'
  action :upgrade
  not_if { node['packages']['nodejs'] != nil }
end

file '/mysql57-community-release-el7-8.noarch.rpm' do
  action :delete
  not_if { node['packages']['nodejs'] != nil }
end

yum_package "mysql-server" do
  action :install
  not_if { node['packages']['nodejs'] != nil }
end

execute 'install Development Tools' do
  command 'sudo yum groupinstall -y "Development Tools"'
end

yum_package "wget" do
  :install
end