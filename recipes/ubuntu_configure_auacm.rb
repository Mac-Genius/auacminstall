config_exists = File.exists?("/home/#{node['auacm']['username']}/projects/auacm/auacm/app/config.py")

# Allows the user to execute the sudo command without a password
# Add option to remove?
ruby_block 'sudo nopass' do
  block do
    fe = Chef::Util::FileEdit.new('/etc/sudoers')
    fe.insert_line_if_no_match(/#{node['auacm']['username']} ALL=(ALL) NOPASSWD:ALL/,
                               "#{node['auacm']['username']} ALL=(ALL) NOPASSWD:ALL")
    fe.write_file
  end
  not_if { config_exists }
end

directory "/var/lib/sudo/#{node['auacm']['username']}" do
  mode '0700'
  not_if { File.exists?("/var/lib/sudo/#{node['auacm']['username']}") }
end

bash 'configure auacm' do
  cwd "/home/#{node['auacm']['username']}/projects/auacm/auacm"
  code <<-EOH
echo "Configuring AUACM..."
su -c "sudo pip install virtualenv" #{node['auacm']['username']}
su -c "virtualenv -p $(which python3) flask" #{node['auacm']['username']}
su -c "CFLAGS="-std=c99" ./flask/bin/pip install -r requirements.txt" #{node['auacm']['username']}
su -c "sudo npm install -g bower" #{node['auacm']['username']}
su -c "bower install" #{node['auacm']['username']}
  EOH
  not_if { config_exists }
end

template "/home/#{node['auacm']['username']}/projects/auacm/auacm/app/config.py" do
  source 'config.py.erb'
  user node['auacm']['username']
  group node['auacm']['username']
  not_if { config_exists }
end

template '/etc/init.d/auacm' do
  source 'auacm.erb'
  mode '0755'
  variables({
      :user => node['auacm']['username']
  })
  not_if { config_exists }
end

service 'auacm' do
  action [:enable, :start]
end