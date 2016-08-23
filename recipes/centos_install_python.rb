# This will not install Python with the same major and minor version!
# If 3.5.2 exists, then it will not install 3.5.X

node['auacm']['python']['versions'].each do |version|
  bash "install Python v#{version}" do
    code <<-EOH
echo "Downloading Python v#{version}..."
wget http://www.python.org/ftp/python/#{version}/Python-#{version}.tar.xz
echo "Unpacking Python v#{version}..."
tar -xJf Python-#{version}.tar.xz
cd Python-#{version}
echo "Configuring and installing Python v#{version}..."
./configure --with-ensurepip=install
make && make altinstall
cd ..
rm -rf Python-#{version}
rm Python-#{version}.tar.xz
echo "Python v#{version} installed successfully"
    EOH
    not_if { File.exists?("/usr/local/bin/python#{node['auacm']['python']['main'].slice(0, 3)}") }
  end
end