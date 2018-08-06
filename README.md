# postgresql-cluster cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/postgresql.svg)](https://supermarket.chef.io/cookbooks/postgresql)

This Chef repository aims at being easist way to setup postgres master and slave nodes quickly. Supports current version of postgresql 7.1.0 of chef market. You can always pull latest version of posgresql chef cookbook from https://github.com/sous-chefs/postgresql. Chef postgresql removed all recepies from 7.0 and later versions. Chef postgres also removed installation of server and client using `pg_gem` and started using cli. For more information about postgres upgrades please see https://github.com/sous-chefs/postgresql/blob/master/UPGRADING.md         

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
```
{
  "run_list":["role[postgresql_<master/slave>]"],
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
      { "type": "host",  "db": "all", "user": "replication",    "addr": "<IP>/32", "method": "trust" }
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
}
```

# Working with replication nodes and slaves

If you want to deploy postgres slave node when you have pgpool setup running ahead you can do following changes and deploy code,

- Create a new slave server machine and get IP (use private IP's for any kind of cluster setups)

# On Master Node Server

- In master node server change the ufw rules and add rule to allow <new_slave_node> server IP to postgres running port
`sudo ufw allow from <new_slave_ip> to any port 5432`

- change pg_hba.conf and add access rule for your replication user,
```
TYPE      DB             USER               SLAVE IP              METHOD      
host    replication     replication     <new_slave_ip>/32         trust
```

# Deployment Steps (your workstation)

- On your workstation just prepare the recepie as follows
` $ bundle exec knife solo prepare <user>@<new_slave_ip>`

- Go to your node and copy the node contents from above sample node containts and chnge the relevent configs to new slave node. If you dont know how postgres master slave replication then follow this tutorial link: https://www.howtoforge.com/tutorial/how-to-set-up-master-slave-replication-for-postgresql-96-on-ubuntu-1604/

- Change the `recovery.conf.erb` as follows,

`./site-cookbook/postgresql/templets/recovery.conf.erb`
```
standby_mode = 'on'
primary_conninfo = 'host=<master_node_ip> port=5432 user=<replication_user> password=<user_password> application_name=<slave_application_name>'
restore_command = 'cp /var/lib/postgresql/9.5/main/archive/%f %p'
trigger_file = '/tmp/postgresql.trigger.5432'
```

- Run the installation command `$ bundle exec knife solo cook <your user>@<your host/ip>`

# On new Slave Node Server

- Once installation is completed successfully ssh to your new slave node server.

- Add the master server entry in `pg_hba.conf`

```
TYPE      DB             USER               SLAVE IP              METHOD      
host    replication     replication     <master_ip>/32         trust
```
- stop the postgres server,

`$ sudo systemctl stop postgresql`

- Dont forget alwys use trust method for any kind of pgpool configuration in `pg_hba.conf`.

- swith to `/var/lib/postgresql.9.5/main` and run the following command to copy the main directory from the Master Node Server to the Slave Node Server with pg_basebackup command, we will use replication user to perform this data copy.
```
$ pg_basebackup -h <Master_node_ip> -U <replication_user> -D /var/lib/postgresql/9.5/main -P --xlog
```
- After finish copy, move the `recovery.conf` as, 

`$ mv /var/lib/postgresql/9.5/recovery.conf /var/lib/postgresql/9.5/main/recovery.conf`

- Change the directory permissions to user and group as a postgres

`$ sudo chown -R postgres:postgres /var/lib/postgresql/9.5/main`

- Start the postgresql server,

`$ sudo systemctl start postgresql`

- Test the replication and check all master data is replicated to new slave.


# PGPOOL config

If your replication is running behind `pgpool` you have to take care of few things as follows,

- Check the pgpool backend node status

`$ psql -U <user> --dbname=postgres --host <pgpool_host_ip> -p <pgpool_port> -c "show pool_nodes" `

or you can use pcp commands,

`$ pcp_node_info -h <pgpool_socket_dir> -U user -n <node_id>`

- Go to the `/etc/pgpool2/pgpool.conf` and add config for newly attached new backend slave node,

```
backend_hostname2 = '<new_slave_ip>'
backend_port2 = 5432
backend_weight2 = 1
backend_data_directory2 = '/data1'
backend_flag2 = 'ALLOW_TO_FAILOVER'
```
under CONNECTIONS in `pgpool.conf`, also you can add and change no of backends, for more information about pgpool and its behaviour visit following link: http://www.pgpool.net/docs/pgpool-II-3.7.5/en/html/

- Restart the pgpool service,

stop

`$ pgpool -m fast stop`

start

`$ pgpool`

- Check the backend node status and attach new node in cluster as follows,

`$ pcp_attach_node -h <pcp_socket_file_path> -U <pcp_user> -p <pcp_port> -n <node_id>`

### And you are Done.....
