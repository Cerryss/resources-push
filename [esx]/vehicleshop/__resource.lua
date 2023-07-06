fx_version 'adamant'

game 'gta5'

description 'Vehicle Shop'

version '1.1.0'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@cerry-module/core/locale.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@cerry-module/core/locale.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'config.lua',
	'client/utils.lua',
	'client/main.lua'
}

dependency 'cerry-module'

export 'GeneratePlate'
