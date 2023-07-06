fx_version 'adamant'

game 'gta5'

description 'ESX Identity'

version '1.7.5'

shared_script '@cerry-module/core/imports.lua'

server_scripts {
	'@cerry-module/core/locale.lua',
	'@oxmysql/lib/MySQL.lua',
	'locales/*.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@cerry-module/core/locale.lua',
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/js/script.js',
	'html/css/style.css',
	'html/img/esx_identity.png'
}

dependency 'cerry-module'
