directory "/home/#{node['auacm']['username']}/projects" do
  owner node['auacm']['username']
  group node['auacm']['username']
  mode '0755'
  not_if { File.exists?("/home/#{node['auacm']['username']}/projects") }
end

git "/home/#{node['auacm']['username']}/projects/auacm" do
  repository 'https://github.com/AuburnACM/auacm.git'
  revision 'master'
  user node['auacm']['username']
  group node['auacm']['username']
  not_if { File.exists?("/home/#{node['auacm']['username']}/projects/auacm") }
end