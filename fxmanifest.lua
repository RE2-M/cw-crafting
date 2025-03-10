
fx_version 'adamant'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

author 'Coffeelot and Wuggie'
description 'CW crafting system'
version '3.6'

ui_page {
    "html/dist/index.html"
}

files {
    "html/dist/index.html",
    "html/dist/*.png",
    "html/dist/assets/*.*",
    "images/*.*"
}

client_scripts{
    'config.lua',
    'bridge/client/*.lua',
    'client/functions.lua',
    'client/client.lua',
}

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'bridge/server/*.lua',
    'server/functions.lua',
    'server/server.lua',
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
    -- '@qbx_core/modules/playerdata.lua' -- Needed for QBOX!
}

dependency 'oxmysql'
