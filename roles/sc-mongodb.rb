name        "MongoDB"
description "MongoDB Server Support"

run_list(
	"recipe[apt]",
	"recipe[ssh-private-keys]",
	"recipe[sc-mongodb::configserver]",
	"recipe[sc-mongodb::default]",
	"recipe[sc-mongodb::install]",
	"recipe[sc-mongodb::replicaset]",
	"recipe[sc-mongodb::user_management]"
	)    