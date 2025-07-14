fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'fl_emergency'
version '2.0.0'
description 'Modern Emergency Services System - Core'
author 'FL Development Team'

-- Dependencies (Required) - REIHENFOLGE WICHTIG!
dependencies {
    'qb-core',
    'oxmysql',
    'ox_lib',
    'ox_target'
}

-- Shared Scripts (Config & Utils) - ZUERST LADEN
shared_scripts {
    '@ox_lib/init.lua',
    'config/main.lua',
    'config/services.lua',
    'config/stations.lua',
    'config/vehicles.lua',
    'shared/utils.lua' -- Falls vorhanden
}

-- Server Scripts - REIHENFOLGE WICHTIG!
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',     -- ZUERST - initialisiert FL global
    'server/database.lua', -- ZWEITES - braucht FL
    'server/duty.lua',     -- DRITTES - braucht FL + Database
    'server/calls.lua'     -- LETZTES - braucht alles andere
}

-- Client Scripts - REIHENFOLGE WICHTIG!
client_scripts {
    'client/main.lua',          -- ZUERST - initialisiert FL global
    'client/compatibility.lua', -- ZWEITES - Target-System detection
    'client/ui.lua',            -- DRITTES - UI Functions
    'client/markers.lua',       -- VIERTES - Marker System
    'client/vehicles.lua'       -- LETZTES - Vehicle System
}

-- UI Files
ui_page 'web/index.html'
files {
    'web/index.html',
    'web/debug.html',
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
    'AssignPlayerToCall',
    'CreateCall',
    'GetActiveCalls'
}

-- QBCore Integration
server_scripts {
    '@qb-core/import.lua' -- Optional, falls verfügbar
}

client_scripts {
    '@qb-core/import.lua' -- Optional, falls verfügbar
}
