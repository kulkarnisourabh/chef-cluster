# postgresql-cluster cookbook
This Chef repository aims at beaing easist way to setup postgres master and slave nodes quickly. Supports current version of postgresql 7.1.0 of chef market. You can always pull latest version of posgresql chef cookbook from https://github.com/sous-chefs/postgresql. Chef postgresql removed all recepies from 7.0 and later versions. Chef postgres also removed installation of server and client using `pg_gem` and started using cli. For more information about postgres upgrades please see https://github.com/sous-chefs/postgresql/blob/master/UPGRADING.md         

# Database
- postgresql 9.5

# Linux Distros
- Ubuntu 14.04 LTS
- Ubuntu 16.04 LTS

# 1. Getting Started
The following paragraphs will guide you to set up your own Postgresql master and slave nodes

Clone the repository onto your own workstation. For example in your `~/Code` directory:

`$ cd ~/Code`
`$ git clone git@github.com:kulkarnisourabh/chef-postgres-cluster.git`

Run Bundle:

`$ bundle install`

Run Librarian install:

`$ librarian-chef install`

# 2. Install your server

Use the following command to install Chef on your server and prepare it to be installed by these cookbooks:

`$ bundle exec knife solo prepare <your user>@<your host/ip>`

This will create a file

`nodes/<your host/ip>.json`

Now copy the the contents from the nodes/sample_host.json from this repository into this new file. Replace the sample values between < > with the values for your server and applications.

When this is done. Run the following command to start the full installation of your server:

`$ bundle exec knife solo cook <your user>@<your host/ip>`

# 3. Sample node
```{
  "run_list":["role[postgresql]"],
  "automatic": {
    "ipaddress": "<Public IP>"
  },
  "postgresql": {
  	"user" : "postgres",
  	"database" : "testdb",
  	"version" : "9.5",
  	 "contrib": {
      "packages": ["postgresql-contrib-9.5"]
    },
  	 "pg_hba": [
      { "type": "host",  "db": "all", "user": "all",      		"addr": "127.0.0.1/32",   	"method": "md5" },
      { "type": "host",  "db": "all", "user": "all",      		"addr": "::1/128",        	"method": "md5" },
      { "type": "host",  "db": "all", "user": "replication",    "addr": "<IP>/32", "method": "md5" }
    ],
  	"config" : {
  		"listen_addresses" : "*,<IP>",
  		"wal_level" : "hot_standby",
  		"synchronous_commit" : "local",
  		"max_wal_senders" : "2",
  		"wal_keep_segments" : "10",
  		"synchronous_standby_names" : "test-pgslave001",
  		"hot_standby" : "on"
  	}
  }
}```
