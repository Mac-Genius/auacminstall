service "mysql" do
  action [ :enable, :start ]
  not_if { node['packages']['mysql-server'] != nil }
end

bash 'add acm user' do
  code <<-EOH
mysql -u root -e "CREATE USER 'acm'@'localhost' IDENTIFIED BY '';"
mysql -u root -e "GRANT ALL ON *.* TO 'acm'@'localhost';"
  EOH
  not_if { node['packages']['mysql-server'] != nil }
end

bash 'initialize database' do
  cwd "/home/#{node['auacm']['username']}/projects/auacm/setup"
  code <<-EOH
echo "Setting up mysql database..."
sudo mysql -uroot < acm.sql
echo "Setting up test database..."
if [ ! -e acm_test.sql ]
then
  echo "Please back up the database first using backup_database.sh."
  echo "That will create the necessary acm_test.sql file"
  exit
fi
echo "DROP DATABASE IF EXISTS acm_test;" | mysql -uroot -p
echo "CREATE DATABASE acm_test;" | mysql -uroot -p
# echo "DROP DATABASE IF EXISTS acm_test; CREATE DATABASE acm_test; \n" | mysql -uroot acm_test < acm_test.sql
mysql -uroot acm_test < acm_test.sql

# Ask to purge the data directory if it exists
if [ -e ../auacm/app/data ]
then
  echo "Do you want to reset the data directory? (y/n)"
  purge=#{node['auacm']['mysql']['purge_data_directory'] ? "y" : "n"}
fi
if [ "$purge" = "y" ]
then
  echo "Purging and resetting data directory..."
  rm -rf ../auacm/app/data
fi

# Create the data directory if it doesn't exist
if [ ! -e ../auacm/app/data ]
then
  echo "Setting up submissions and problems data."
  mkdir ../auacm/app/data
  cp data.zip ../auacm/app/data.zip
  cd ../auacm/app
  unzip data.zip > /dev/null
  rm data.zip
fi

# Remove the __MACOSX directory if created from the unzip
if [ -e __MACOSX ]
then
  rm -rf __MACOSX
fi
echo "Done!"
  EOH
  not_if { node['packages']['mysql-server'] != nil }
end
