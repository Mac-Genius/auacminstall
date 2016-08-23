# These are the default settings for this cookbook
# This will create a new user that is dedicated to running the website
# The password for the user should be a shadow hash. You can obtain one
# by running the following command: openssl passwd -1 "yourPasswordHere"

userbag = Chef::DataBagItem.load('users', 'default')

if userbag == nil
  default['auacm']['username'] = 'auacm'
  default['auacm']['password'] = '$1$Nj4cIWTE$75M9Y53hIsyoC0Po4O41k.'
  default['auacm']['private_rsa_key'] = nil
else
  default['auacm']['username'] = userbag['username']
  default['auacm']['password'] = userbag['password']
  default['auacm']['private_rsa_key'] = userbag['rsa_private_key']
end

# Python settings. Please ensure that the versions contain the main python version
default['auacm']['python']['versions'] = ['2.7.12', '3.5.2']
default['auacm']['python']['main'] = '3.5.2'

# Initialize database
default['auacm']['mysql']['purge_data_directory'] = false
default['auacm']['mysql']['disabled_plugins'] = ['validate_password']
