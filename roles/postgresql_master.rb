name        "postgresql_master"
description "PostgreSQL Server Support"

run_list(
	"recipe[apt]",
	"recipe[ssh-private-keys]",
	"recipe[postgresql::repository]", 
	"recipe[postgresql::access]", 
	"recipe[postgresql::client_install]", 
	"recipe[postgresql::server_install]",
	"recipe[apt::unattended-upgrades]"
	)    