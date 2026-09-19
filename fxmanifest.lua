fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Codex'
description 'Admin item overlay with search and give actions'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'data/shop_overrides.json'
}

dependencies {
    'qb-core'
}
