fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author "Asgaard Developments | s4t4n667"
description 'Cinematic bars overlay'
version '1.1.0'


shared_scripts {
	'@ox_lib/init.lua'
}

client_scripts {
	'resource/client.lua',
}

server_scripts {
	'resource/server.lua',
}

files {
	'config.lua',
	'locales/*.json',
}
