fx_version "cerulean"

description "Drug Selling Script | Fully Compatible with OP-GANGS 2.0!"
author "OTHERPLANET"
version '1.0.2'
lua54 'yes'
game 'gta5'

ui_page 'web/build/index.html'

shared_scripts {
	'@ox_lib/init.lua',
	'framework/shared.lua',
	'config/MainConfig.lua',
	'locales/*.lua',
}

client_scripts {
	'config/MainConfig.lua',
	'framework/client/c_framework.lua',
	'integrations/client/**',
	'client/**',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config/ServerConfig.lua',
	'framework/server/s_framework.lua',
	'server/**',
}

files {
	'web/build/**/*',
}

escrow_ignore {
	'client/**',
	'config/**',
	'locales/**',
	'framework/**',
	'server/**',
	'integrations/**'
}