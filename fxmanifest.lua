fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'GrossBean'
description 'Allows players to grow weed plants outdoors, harvest them, and progress through growth stages'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua'
}

client_scripts {
    'client/main.lua',
    'client/weedtables.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}

dependencies {
    'qb-target',
    'qb-core',
    'qb-menu'
}
