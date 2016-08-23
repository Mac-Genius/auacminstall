# auacminstall cookbook

This cookbook will install and configure AUACM's website and run it as a linux server.

## Requirements

* Chef 12.5.x or higher
* Ubuntu 14 or CentOS 7

## Usage

* Clone this repository
* Create a data bag with the following structure:
* (Command: `knife data bag create settings development`)
```
{
    "id": "development",
    "username": "auacmuser",
    "password": "shadowHashOfPassword",
    "rsa_private_key": "-----BEGIN RSA PRIVATE KEY..."
}
```

You can create a shadow hash of a password with the following command:
`openssl passwd -1 "yourPasswordHere"`

Make sure your put new line characters to separate lines in the rsa key.

* Change any settings of the cookbook in the default attributes file
* Upload to your Chef server or run locally with chef-client

## Attributes

This will load the data bag "users" with the item "default":

`userbag = Chef::DataBagItem.load('users', 'default')`

The next settings are used to create a user. It should be filled in by your data bag.
```
if userbag == nil
  default['auacm']['username'] = 'auacm'
  default['auacm']['password'] = '$1$Nj4cIWTE$75M9Y53hIsyoC0Po4O41k.'
  default['auacm']['private_rsa_key'] = nil
else
  default['auacm']['username'] = userbag['username']
  default['auacm']['password'] = userbag['password']
  default['auacm']['private_rsa_key'] = userbag['rsa_private_key']
end
```

The next settings are the versions of python to install, and the version you want to run AUACM with.

```
default['auacm']['python']['versions'] = ['2.7.12', '3.5.2']
default['auacm']['python']['main'] = '3.5.2'
```

The last settings are used to initialize the database. You shouldn't need to change anything here.

```
default['auacm']['mysql']['purge_data_directory'] = false
default['auacm']['mysql']['disabled_plugins'] = ['validate_password']
```