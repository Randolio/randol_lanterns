fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Lanterns'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'bridge/client/**.lua',
    'cl_lantern.lua',
}

server_scripts {
    'bridge/server/**.lua',
    'sv_config.lua',
    'sv_lantern.lua',
}

lua54 'yes'
