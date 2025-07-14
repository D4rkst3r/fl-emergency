-- ================================
-- 🚨 FL EMERGENCY SERVICES - SERVER MAIN
-- ================================

local QBCore = exports['qb-core']:GetCoreObject()

-- ================================
-- 📊 GLOBALE STATE MANAGEMENT
-- ================================

FL = {
    -- System-Status
    System = {
        version = Config.Version.current,
        startTime = os.time(),
        debug = Config.Debug
    },

    -- Aktive Daten
    State = {
        activePlayers = {},  -- Spieler im Dienst
        activeCalls = {},    -- Aktive Einsätze
        activeVehicles = {}, -- Gespawnte Fahrzeuge
        stationStatus = {}   -- Status der Wachen
    },

    -- Cache für Performance
    Cache = {
        playerData = {},
        callHistory = {},
        lastUpdate = 0
    },

    -- Event Handler
    Events = {},

    -- Statistiken
    Stats = {
        totalCalls = 0,
        totalPlayersServed = 0,
        uptime = 0
    }
}

-- ================================
-- 🔧 SYSTEM INITIALIZATION
-- ================================

CreateThread(function()
    print('^2[FL Emergency]^7 Starting FL Emergency Services v' .. FL.System.version)

    -- Warte auf QBCore
    while not QBCore do
        Wait(100)
    end

    -- Database Setup
    FL.InitializeDatabase()

    -- Lade gespeicherte Daten
    FL.LoadStoredData()

    -- Starte System-Threads
    FL.StartSystemThreads()

    -- Registriere Commands
    FL.RegisterCommands()

    print('^2[FL Emergency]^7 Successfully started! Ready for emergency services.')
end)

-- ================================
-- 🗃️ DATABASE FUNCTIONS
-- ================================

function FL.InitializeDatabase()
    if Config.Debug then print('^3[FL Debug]^7 Initializing database...') end

    -- Haupt-Tabelle erstellen
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS fl_emergency_data (
            id INT PRIMARY KEY AUTO_INCREMENT,
            citizenid VARCHAR(50),
            type ENUM('duty', 'call', 'vehicle', 'equipment', 'stats'),
            service ENUM('fire', 'police', 'ems', 'system'),
            data JSON,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            expires_at TIMESTAMP NULL,
            INDEX idx_citizen_type (citizenid, type),
            INDEX idx_service_type (service, type),
            INDEX idx_active (expires_at),
            INDEX idx_created (created_at)
        )
    ]], {})

    if Config.Debug then print('^2[FL Debug]^7 Database initialized successfully') end
end

function FL.LoadStoredData()
    if Config.Debug then print('^3[FL Debug]^7 Loading stored data...') end

    -- Lade aktive Einsätze
    MySQL.query('SELECT * FROM fl_emergency_data WHERE type = ? AND (expires_at IS NULL OR expires_at > NOW())', {
        'call'
    }, function(result)
        if result then
            for _, row in pairs(result) do
                local callData = json.decode(row.data)
                FL.State.activeCalls[callData.id] = callData
            end
        end
    end)

    -- Lade System-Statistiken
    MySQL.query('SELECT * FROM fl_emergency_data WHERE type = ? ORDER BY created_at DESC LIMIT 1', {
        'stats'
    }, function(result)
        if result and result[1] then
            FL.Stats = json.decode(result[1].data)
        end
    end)

    if Config.Debug then print('^2[FL Debug]^7 Stored data loaded successfully') end
end

-- ================================
-- 🎯 UTILITY FUNCTIONS
-- ================================

function FL.GetPlayerService(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end

    local job = Player.PlayerData.job.name
    for service, data in pairs(Config.Services) do
        if data.job == job then
            return service, data
        end
    end
    return nil
end

function FL.IsPlayerOnDuty(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    return Player.PlayerData.job.onduty or false
end

function FL.GetPlayerRank(source, service)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return 0 end

    if Player.PlayerData.job.name == Config.Services[service].job then
        return Player.PlayerData.job.grade.level or 0
    end
    return 0
end

function FL.Broadcast(event, data, service)
    if service then
        -- Nur an Spieler des jeweiligen Service
        for source, playerData in pairs(FL.State.activePlayers) do
            if playerData.service == service then
                TriggerClientEvent('fl:' .. event, source, data)
            end
        end
    else
        -- An alle Emergency Services Spieler
        for source, _ in pairs(FL.State.activePlayers) do
            TriggerClientEvent('fl:' .. event, source, data)
        end
    end
end

function FL.Log(level, message, data)
    if not Config.Logging.enabled then return end

    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local logMessage = string.format('[%s] [%s] %s', timestamp, level:upper(), message)

    if data then
        logMessage = logMessage .. ' | Data: ' .. json.encode(data)
    end

    print(logMessage)

    -- Speichere in Database (optional)
    if level == 'error' or Config.Logging.level == 'debug' then
        MySQL.insert('INSERT INTO fl_emergency_data (citizenid, type, service, data) VALUES (?, ?, ?, ?)', {
            'system', 'log', 'system', json.encode({
            level = level,
            message = message,
            data = data,
            timestamp = timestamp
        })
        })
    end
end

function FL.UpdateStats()
    FL.Stats.uptime = os.time() - FL.System.startTime

    -- Speichere Statistiken
    MySQL.insert('INSERT INTO fl_emergency_data (citizenid, type, service, data) VALUES (?, ?, ?, ?)', {
        'system', 'stats', 'system', json.encode(FL.Stats)
    })
end

-- ================================
-- 🚨 DUTY SYSTEM
-- ================================

RegisterNetEvent('fl:duty:toggle', function(stationId)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        FL.Log('error', 'Player not found for duty toggle', { source = source })
        return
    end

    local service, serviceData = FL.GetPlayerService(source)
    if not service then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'You are not an emergency service member'
        })
        return
    end

    local isOnDuty = FL.IsPlayerOnDuty(source)
    local citizenid = Player.PlayerData.citizenid

    if isOnDuty then
        -- Ende des Dienstes
        FL.EndDuty(source, service, stationId)
    else
        -- Beginn des Dienstes
        FL.StartDuty(source, service, stationId)
    end

    FL.Log('info', 'Duty toggled', {
        source = source,
        citizenid = citizenid,
        service = service,
        onDuty = not isOnDuty,
        station = stationId
    })
end)

function FL.StartDuty(source, service, stationId)
    local Player = QBCore.Functions.GetPlayer(source)
    local citizenid = Player.PlayerData.citizenid

    -- Setze Spieler auf Dienst
    Player.Functions.SetJobDuty(true)

    -- Füge zu aktiven Spielern hinzu
    FL.State.activePlayers[source] = {
        citizenid = citizenid,
        service = service,
        station = stationId,
        startTime = os.time(),
        currentCall = nil
    }

    -- Gib Equipment
    if Config.Duty.equipmentAutoGive then
        FL.GiveEquipment(source, service)
    end

    -- Speichere in Database
    MySQL.insert('INSERT INTO fl_emergency_data (citizenid, type, service, data) VALUES (?, ?, ?, ?)', {
        citizenid, 'duty', service, json.encode({
        action = 'start',
        station = stationId,
        timestamp = os.time()
    })
    })

    -- Benachrichtige Client
    TriggerClientEvent('fl:duty:started', source, {
        service = service,
        station = stationId,
        equipment = Config.Services[service].equipment
    })

    -- Broadcast an alle
    FL.Broadcast('playerDutyChanged', {
        source = source,
        service = service,
        onDuty = true
    })

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        title = 'Dienst begonnen',
        description = 'Du bist jetzt als ' .. Config.Services[service].label .. ' im Dienst'
    })
end

function FL.EndDuty(source, service, stationId)
    local Player = QBCore.Functions.GetPlayer(source)
    local citizenid = Player.PlayerData.citizenid

    -- Entferne Equipment
    if Config.Duty.equipmentAutoGive then
        FL.RemoveEquipment(source, service)
    end

    -- Entferne gespawnte Fahrzeuge
    FL.DespawnPlayerVehicles(source)

    -- Setze Spieler off-duty
    Player.Functions.SetJobDuty(false)

    -- Entferne von aktiven Spielern
    local dutyData = FL.State.activePlayers[source]
    FL.State.activePlayers[source] = nil

    -- Speichere Duty-Zeit
    if dutyData then
        local dutyTime = os.time() - dutyData.startTime
        MySQL.insert('INSERT INTO fl_emergency_data (citizenid, type, service, data) VALUES (?, ?, ?, ?)', {
            citizenid, 'duty', service, json.encode({
            action = 'end',
            station = stationId,
            duration = dutyTime,
            timestamp = os.time()
        })
        })
    end

    -- Benachrichtige Client
    TriggerClientEvent('fl:duty:ended', source, {
        service = service,
        station = stationId
    })

    -- Broadcast
    FL.Broadcast('playerDutyChanged', {
        source = source,
        service = service,
        onDuty = false
    })

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        title = 'Dienst beendet',
        description = 'Du bist nicht mehr im Dienst'
    })
end

-- ================================
-- 🎒 EQUIPMENT SYSTEM
-- ================================

function FL.GiveEquipment(source, service)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local serviceData = Config.Services[service]
    if not serviceData or not serviceData.equipment then return end

    -- Gib Items
    if serviceData.equipment.items then
        for _, item in pairs(serviceData.equipment.items) do
            Player.Functions.AddItem(item, 1)
        end
    end

    -- Gib Waffen
    if serviceData.equipment.weapons then
        for _, weapon in pairs(serviceData.equipment.weapons) do
            Player.Functions.AddItem(weapon, 1)
        end
    end

    FL.Log('info', 'Equipment given', {
        source = source,
        service = service,
        items = serviceData.equipment.items,
        weapons = serviceData.equipment.weapons
    })
end

function FL.RemoveEquipment(source, service)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local serviceData = Config.Services[service]
    if not serviceData or not serviceData.equipment then return end

    -- Entferne Items
    if serviceData.equipment.items then
        for _, item in pairs(serviceData.equipment.items) do
            Player.Functions.RemoveItem(item, Player.Functions.GetItemByName(item)?.amount or 0)
        end
    end

    -- Entferne Waffen
    if serviceData.equipment.weapons then
        for _, weapon in pairs(serviceData.equipment.weapons) do
            Player.Functions.RemoveItem(weapon, 1)
        end
    end

    FL.Log('info', 'Equipment removed', {
        source = source,
        service = service
    })
end

-- ================================
-- 🚗 VEHICLE MANAGEMENT
-- ================================

function FL.DespawnPlayerVehicles(source)
    local playerVehicles = {}

    for vehicleId, vehicleData in pairs(FL.State.activeVehicles) do
        if vehicleData.owner == source then
            table.insert(playerVehicles, vehicleId)
        end
    end

    for _, vehicleId in pairs(playerVehicles) do
        TriggerClientEvent('fl:vehicle:despawn', source, vehicleId)
        FL.State.activeVehicles[vehicleId] = nil
    end
end

-- ================================
-- 🔄 SYSTEM THREADS
-- ================================

function FL.StartSystemThreads()
    -- Cleanup Thread
    CreateThread(function()
        while true do
            Wait(Config.Threads.cleanup)

            -- Bereinige abgelaufene Daten
            MySQL.query('DELETE FROM fl_emergency_data WHERE expires_at IS NOT NULL AND expires_at < NOW()')

            -- Update Statistiken
            FL.UpdateStats()

            -- Bereinige inaktive Spieler
            for source, data in pairs(FL.State.activePlayers) do
                if not GetPlayerName(source) then
                    FL.State.activePlayers[source] = nil
                end
            end
        end
    end)

    -- Call Update Thread
    CreateThread(function()
        while true do
            Wait(Config.Threads.callUpdate)

            -- Update Call Status
            for callId, callData in pairs(FL.State.activeCalls) do
                if callData.status == 'timeout' or (callData.created + Config.Calls.callTimeout) < os.time() then
                    FL.State.activeCalls[callId] = nil
                    FL.Broadcast('callClosed', { id = callId, reason = 'timeout' })
                end
            end
        end
    end)
end

-- ================================
-- 📝 ADMIN COMMANDS
-- ================================

function FL.RegisterCommands()
    -- Debug Command
    lib.addCommand('fldebug', {
        help = 'FL Emergency Debug Information',
        restricted = 'group.admin'
    }, function(source, args)
        local info = {
            system = FL.System,
            activePlayers = #FL.State.activePlayers,
            activeCalls = #FL.State.activeCalls,
            activeVehicles = #FL.State.activeVehicles,
            stats = FL.Stats
        }

        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 255, 0 },
            multiline = true,
            args = { 'FL Debug', json.encode(info, { indent = true }) }
        })
    end)

    -- Force Duty End
    lib.addCommand('fldutyend', {
        help = 'Force end duty for a player',
        params = {
            { name = 'id', type = 'playerId', help = 'Player ID' }
        },
        restricted = 'group.admin'
    }, function(source, args)
        local targetSource = args.id
        local service = FL.GetPlayerService(targetSource)

        if service and FL.State.activePlayers[targetSource] then
            FL.EndDuty(targetSource, service, 'admin_forced')
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'success',
                description = 'Duty ended for player ' .. targetSource
            })
        else
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                description = 'Player not on duty'
            })
        end
    end)

    -- Test Call Command
    lib.addCommand('testcall', {
        help = 'Create a test emergency call',
        params = {
            { name = 'service', type = 'string', help = 'Service (fire/police/ems)' },
            { name = 'type',    type = 'string', help = 'Call type',                optional = true }
        },
        restricted = 'group.admin'
    }, function(source, args)
        local coords = GetEntityCoords(GetPlayerPed(source))

        local callType = args.type or 'test_emergency'
        local service = args.service

        if not Config.Services[service] then
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                description = 'Invalid service'
            })
            return
        end

        TriggerEvent('fl:call:create', {
            service = service,
            type = callType,
            coords = { x = coords.x, y = coords.y, z = coords.z },
            priority = 1,
            description = 'Test call created by admin'
        })

        TriggerClientEvent('ox_lib:notify', source, {
            type = 'success',
            description = 'Test call created for ' .. service
        })
    end)
end

-- ================================
-- 📤 EXPORTS
-- ================================

-- Get Player Service
exports('GetPlayerService', function(source)
    return FL.GetPlayerService(source)
end)

-- Check if Player is on Duty
exports('IsPlayerOnDuty', function(source)
    return FL.IsPlayerOnDuty(source)
end)

-- Get Emergency Data
exports('GetEmergencyData', function()
    return FL.State
end)

-- Create Emergency Call (für andere Resources)
exports('CreateEmergencyCall', function(data)
    TriggerEvent('fl:call:create', data)
end)

-- Get Active Call for Player
exports('GetActiveCall', function(source)
    local playerData = FL.State.activePlayers[source]
    if playerData and playerData.currentCall then
        return FL.State.activeCalls[playerData.currentCall]
    end
    return nil
end)

-- ================================
-- 🔚 RESOURCE STOP HANDLER
-- ================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        FL.Log('info', 'FL Emergency Services shutting down...')

        -- Speichere finale Statistiken
        FL.UpdateStats()

        -- Bereinige aktive Daten
        for source, _ in pairs(FL.State.activePlayers) do
            TriggerClientEvent('fl:system:shutdown', source)
        end

        print('^3[FL Emergency]^7 Successfully shut down')
    end
end)
