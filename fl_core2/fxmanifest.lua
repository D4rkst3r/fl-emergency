fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'fl_emergency'
version '2.0.0'
description 'Modern Emergency Services System - Core'
author 'FL Development Team'

-- Dependencies (Required)
dependencies {
    'qb-core',
    'ox_lib',
    'ox_target',
    'oxmysql'
}

-- Shared Scripts (Config & Utils)
shared_scripts {
    '@ox_lib/init.lua',
    'config/main.lua',
    'config/services.lua',
    'config/stations.lua',
    'config/vehicles.lua'
}

-- Server Scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/database.lua',
    'server/duty.lua',
    'server/calls.lua'
}

-- Client Scripts
client_scripts {
    'client/main.lua',
    'client/ui.lua',
    'client/markers.lua',
    'client/vehicles.lua'
}

-- UI Files
ui_page 'web/index.html'
files {
    'web/index.html',
    'web/app.js',
    'web/style.css',
    'web/assets/**/*'
}

-- Exports (für andere Resources)
exports {
    'GetPlayerService',
    'IsPlayerOnDuty',
    'CreateEmergencyCall',
    'GetActiveCall'
}

server_exports {
    'GetEmergencyData',
    'UpdateCallStatus',
    'AssignPlayerToCall'
}
