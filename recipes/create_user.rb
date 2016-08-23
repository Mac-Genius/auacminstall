# Creates the default user
user 'auacm user' do
  comment 'The default user for the account'
  home '/home/' + node['auacm']['username']
  username node['auacm']['username']
  password node['auacm']['password']
  action node['etc']['passwd'][node['auacm']['username']] != nil ? :nothing : :create
end

directory "/home/#{node['auacm']['username']}" do
  owner node['auacm']['username']
  group node['auacm']['username']
  action node['etc']['passwd'][node['auacm']['username']] != nil ? :nothing : :create
end

execute 'set sudoer' do
  if node["platform"].eql? "centos"
    command "usermod -aG wheel #{node['auacm']['username']}"
  elsif node["platform"].eql? "ubuntu"
    command "usermod -aG sudo #{node['auacm']['username']}"
  end
  action node['etc']['passwd'][node['auacm']['username']] != nil ? :nothing : :run
end

directory '.ssh' do
  owner node['auacm']['username']
  group node['auacm']['username']
  mode '0700'
  action node['etc']['passwd'][node['auacm']['username']] != nil ? :nothing : :create
  path '/home/' + node['auacm']['username'] + '/.ssh'
end

if node['auacm']['private_rsa_key'] == nil
  template "/home/#{node["auacm"]["username"]}/.ssh/key.pem" do
    owner node['auacm']['username']
    group node['auacm']['username']
    source 'private.pem.erb'
    action node['etc']['passwd'][node['auacm']['username']] != nil ? :nothing : :create
  end

  file 'authorized_keys' do
    content = ''
    owner node['auacm']['username']
    group node['auacm']['username']
    mode '0600'
    path '/home/' + node['auacm']['username'] + '/.ssh/authorized_keys'
    action node['etc']['passwd'][node['auacm']['username']] != nil ? :nothing : :create
  end

  execute 'create_public_key' do
    command 'ssh-keygen -y -f /home/' + node['auacm']['username'] + '/.ssh/key.pem > /home/' + node['auacm']['username'] + '/.ssh/key.pub'
    action node['etc']['passwd'][node['auacm']['username']] != nil ? :nothing : :run
  end

  execute 'add_public_key' do
    command 'cat /home/' + node['auacm']['username'] + '/.ssh/key.pub >> /home/' + node['auacm']['username'] + '/.ssh/authorized_keys'
    action node['etc']['passwd'][node['auacm']['username']] != nil ? :nothing : :run
  end

  file 'remove_public_key' do
    path '/home/' + node['auacm']['username'] + '/.ssh/key.pub'
    action node['etc']['passwd'][node['auacm']['username']] != nil ? :nothing : :delete
  end

  file 'remove_private_key' do
    path '/home/' + node['auacm']['username'] + '/.ssh/key.pem'
    action node['etc']['passwd'][node['auacm']['username']] != nil ? :nothing : :delete
  end
end