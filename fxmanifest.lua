fx_version 'cerulean'
game 'gta5'

name "mp_vehiclecam"
description "mp_vehiclecam"
author "Michael Pollenski"
version "2"

shared_scripts {
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/*.lua'
}

dependencies {
	'ox_core',
	'ox_lib',
	'oxmysql',
}