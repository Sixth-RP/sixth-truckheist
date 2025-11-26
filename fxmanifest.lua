fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Truck Heist Script with ps-ui Lockpick'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@ps-ui/shared/locale.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

dependencies {
    'ps-ui'
}
