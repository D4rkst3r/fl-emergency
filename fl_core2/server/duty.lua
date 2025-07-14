-- ================================
-- 🚨 FL EMERGENCY - DUTY SYSTEM SERVER
-- ================================

FL.Duty = {}

-- ================================
-- 🎯 DUTY MANAGEMENT
-- ================================

-- Validiere Duty-Berechtigung
function FL.Duty.ValidatePermission(source, service, action)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false, 'Spieler nicht gefunden' end

    -- Prüfe Job-Berechtigung
    local playerService = FL.GetPlayerService(source)
    if playerService ~= service then
        return false, 'Keine Berechtigung für diesen Service'
    end

    -- Prüfe Whitelist (falls aktiviert)
    if Config.Permissions.requireWhitelist then
        local isWhitelisted = FL.Duty.CheckWhitelist(Player.PlayerData.citizenid, service)
        if not isWhitelisted then
            return false, 'Nicht auf der Whitelist'
        end
    end

    -- Prüfe Station-Nähe (falls erforderlich)
    if Config.Duty.requirePhysicalStation and action == 'start' then
        local nearStation = FL.Duty.IsNearStation(source, service)
        if not nearStation then
            return false, 'Du musst an einer Wache sein'
        end
    end

    return true, 'Berechtigung erfolgreich'
end

-- Prüfe Station-Nähe
function FL.Duty.IsNearStation(source, service)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local stations = Config.Stations[service]

    if not stations then return false end

    for stationId, stationData in pairs(stations) do
        local distance = #(playerCoords - stationData.coords)
        if distance < 100.0 then -- 100m Radius
            return true, stationId
        end
    end

    return false
end

-- Prüfe Whitelist
function FL.Duty.CheckWhitelist(citizenid, service)
    -- Implementierung für Whitelist-Check
    -- Kann erweitert werden für externe Whitelist-Systeme
    return true -- Vorläufig immer erlaubt
end

-- ================================
-- 🚀 DUTY START LOGIC
-- ================================

function FL.Duty.StartDuty(source, service, stationId)
    local Player = QBCore.Functions.GetPlayer(source)
    local citizenid = Player.PlayerData.citizenid

    -- Validierung
    local valid, message = FL.Duty.ValidatePermission(source, service, 'start')
    if not valid then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = message
        })
        return false
    end

    -- Prüfe ob bereits im Dienst
    if FL.IsPlayerOnDuty(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Du bist bereits im Dienst'
        })
        return false
    end

    -- Prüfe Maximum aktive Spieler
    local activeCount = FL.Duty.GetActivePlayerCount(service)
    if activeCount >= Config.ServiceSettings.maxActivePerService then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Maximale Anzahl aktiver Spieler erreicht'
        })
        return false
    end

    -- Setze Spieler auf Dienst
    Player.Functions.SetJobDuty(true)

    -- Erstelle Duty-Record
    local dutyData = {
        citizenid = citizenid,
        service = service,
        station = stationId,
        startTime = os.time(),
        currentCall = nil,
        equipment = {},
        vehicles = {}
    }

    FL.State.activePlayers[source] = dutyData

    -- Speichere in Database
    FL.Database.SaveDutyRecord(citizenid, service, 'start', {
        station = stationId,
        duration = nil,
        equipment = Config.Services[service].equipment
    })

    -- Equipment geben
    if Config.Duty.equipmentAutoGive then
        FL.Duty.GiveEquipment(source, service)
        dutyData.equipment = Config.Services[service].equipment
    end

    -- Benachrichtigungen
    TriggerClientEvent('fl:duty:started', source, {
        service = service,
        station = stationId,
        equipment = Config.Services[service].equipment,
        uniform = Config.Services[service].uniforms
    })

    FL.Broadcast('playerDutyChanged', {
        source = source,
        citizenid = citizenid,
        service = service,
        action = 'start',
        station = stationId
    }, service)

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        title = 'Dienst begonnen',
        description = 'Willkommen bei ' .. Config.Services[service].label
    })

    FL.Log('info', 'Duty started', {
        source = source,
        citizenid = citizenid,
        service = service,
        station = stationId
    })

    return true
end

-- ================================
-- 🛑 DUTY END LOGIC
-- ================================

function FL.Duty.EndDuty(source, service, stationId, forced)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    local citizenid = Player.PlayerData.citizenid
    local dutyData = FL.State.activePlayers[source]

    if not dutyData then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Du bist nicht im Dienst'
        })
        return false
    end

    -- Validierung (außer bei forced)
    if not forced then
        local valid, message = FL.Duty.ValidatePermission(source, service, 'end')
        if not valid and Config.Duty.requirePhysicalStation then
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                description = message
            })
            return false
        end
    end

    -- Berechne Dienstzeit
    local dutyDuration = os.time() - dutyData.startTime

    -- Prüfe Mindest-Dienstzeit
    if dutyDuration < (Config.ServiceSettings.minDutyTime * 60) and not forced then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Mindest-Dienstzeit von ' .. Config.ServiceSettings.minDutyTime .. ' Minuten nicht erreicht'
        })
        return false
    end

    -- Entferne Equipment
    if Config.Duty.equipmentAutoGive then
        FL.Duty.RemoveEquipment(source, service)
    end

    -- Despawne Fahrzeuge
    FL.Duty.DespawnPlayerVehicles(source)

    -- Entferne von aktivem Call
    if dutyData.currentCall then
        FL.Duty.RemoveFromCall(source, dutyData.currentCall)
    end

    -- Setze Player off-duty
    Player.Functions.SetJobDuty(false)

    -- Entferne von aktiven Spielern
    FL.State.activePlayers[source] = nil

    -- Speichere End-Record
    FL.Database.SaveDutyRecord(citizenid, service, 'end', {
        station = stationId or dutyData.station,
        duration = dutyDuration,
        equipment = dutyData.equipment
    })

    -- Benachrichtigungen
    TriggerClientEvent('fl:duty:ended', source, {
        service = service,
        station = stationId or dutyData.station,
        duration = dutyDuration
    })

    FL.Broadcast('playerDutyChanged', {
        source = source,
        citizenid = citizenid,
        service = service,
        action = 'end',
        duration = dutyDuration
    }, service)

    local durationText = FL.Duty.FormatDuration(dutyDuration)
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        title = 'Dienst beendet',
        description = 'Dienstzeit: ' .. durationText
    })

    FL.Log('info', 'Duty ended', {
        source = source,
        citizenid = citizenid,
        service = service,
        duration = dutyDuration
    })

    return true
end

-- ================================
-- 🎒 EQUIPMENT MANAGEMENT
-- ================================

function FL.Duty.GiveEquipment(source, service)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local serviceData = Config.Services[service]
    if not serviceData.equipment then return end

    local givenItems = {}

    -- Items geben
    if serviceData.equipment.items then
        for _, item in pairs(serviceData.equipment.items) do
            local success = Player.Functions.AddItem(item, 1)
            if success then
                table.insert(givenItems, item)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add')
            end
        end
    end

    -- Waffen geben
    if serviceData.equipment.weapons then
        for _, weapon in pairs(serviceData.equipment.weapons) do
            local success = Player.Functions.AddItem(weapon, 1)
            if success then
                table.insert(givenItems, weapon)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[weapon], 'add')
            end
        end
    end

    if #givenItems > 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'success',
            description = 'Ausrüstung erhalten: ' .. table.concat(givenItems, ', ')
        })
    end

    FL.Log('info', 'Equipment given', {
        source = source,
        service = service,
        items = givenItems
    })
end

function FL.Duty.RemoveEquipment(source, service)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local serviceData = Config.Services[service]
    if not serviceData.equipment then return end

    local removedItems = {}

    -- Items entfernen
    if serviceData.equipment.items then
        for _, item in pairs(serviceData.equipment.items) do
            local itemData = Player.Functions.GetItemByName(item)
            if itemData then
                local removed = Player.Functions.RemoveItem(item, itemData.amount)
                if removed then
                    table.insert(removedItems, item)
                    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'remove')
                end
            end
        end
    end

    -- Waffen entfernen
    if serviceData.equipment.weapons then
        for _, weapon in pairs(serviceData.equipment.weapons) do
            local itemData = Player.Functions.GetItemByName(weapon)
            if itemData then
                local removed = Player.Functions.RemoveItem(weapon, itemData.amount)
                if removed then
                    table.insert(removedItems, weapon)
                    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[weapon], 'remove')
                end
            end
        end
    end

    if #removedItems > 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'info',
            description = 'Ausrüstung abgegeben: ' .. table.concat(removedItems, ', ')
        })
    end
end

-- ================================
-- 🚗 VEHICLE MANAGEMENT
-- ================================

function FL.Duty.DespawnPlayerVehicles(source)
    local dutyData = FL.State.activePlayers[source]
    if not dutyData or not dutyData.vehicles then return end

    for plate, vehicleData in pairs(dutyData.vehicles) do
        -- Benachrichtige Client zum Despawn
        TriggerClientEvent('fl:vehicle:despawn', source, plate)

        -- Entferne aus Database
        FL.Database.RemoveVehicle(plate)

        -- Entferne aus State
        FL.State.activeVehicles[plate] = nil
    end

    dutyData.vehicles = {}
end

-- ================================
-- 📊 UTILITY FUNCTIONS
-- ================================

function FL.Duty.GetActivePlayerCount(service)
    local count = 0
    for source, data in pairs(FL.State.activePlayers) do
        if data.service == service then
            count = count + 1
        end
    end
    return count
end

function FL.Duty.GetActivePlayersInService(service)
    local players = {}
    for source, data in pairs(FL.State.activePlayers) do
        if data.service == service then
            local Player = QBCore.Functions.GetPlayer(source)
            if Player then
                table.insert(players, {
                    source = source,
                    citizenid = data.citizenid,
                    name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                    rank = Player.PlayerData.job.grade.name,
                    station = data.station,
                    startTime = data.startTime,
                    currentCall = data.currentCall
                })
            end
        end
    end
    return players
end

function FL.Duty.FormatDuration(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)

    if hours > 0 then
        return string.format('%dh %dm', hours, minutes)
    else
        return string.format('%dm', minutes)
    end
end

function FL.Duty.RemoveFromCall(source, callId)
    local call = FL.State.activeCalls[callId]
    if not call then return end

    -- Entferne Spieler aus Call
    for i, assignedSource in pairs(call.assigned) do
        if assignedSource == source then
            table.remove(call.assigned, i)
            break
        end
    end

    -- Update Call Status
    if #call.assigned == 0 then
        call.status = 'pending'
    end

    -- Broadcast Update
    FL.Broadcast('callUpdated', call, call.service)

    -- Update Database
    FL.Database.UpdateCall(callId, call)
end

-- ================================
-- 🔄 AUTO DUTY END SYSTEM
-- ================================

-- Automatisches Dienst-Ende bei Disconnect
RegisterNetEvent('playerDropped', function(reason)
    local source = source
    local dutyData = FL.State.activePlayers[source]

    if dutyData then
        FL.Log('info', 'Auto duty end on disconnect', {
            source = source,
            citizenid = dutyData.citizenid,
            service = dutyData.service,
            reason = reason
        })

        FL.Duty.EndDuty(source, dutyData.service, 'disconnect', true)
    end
end)

-- Duty Timeout Check
CreateThread(function()
    while true do
        Wait(300000) -- Check every 5 minutes

        for source, dutyData in pairs(FL.State.activePlayers) do
            local dutyDuration = os.time() - dutyData.startTime

            -- Max Duty Time Check
            if Config.Duty.maxDutyTime and dutyDuration > Config.Duty.maxDutyTime then
                FL.Log('warn', 'Force duty end - max time exceeded', {
                    source = source,
                    citizenid = dutyData.citizenid,
                    service = dutyData.service,
                    duration = dutyDuration
                })

                TriggerClientEvent('ox_lib:notify', source, {
                    type = 'error',
                    title = 'Dienst beendet',
                    description = 'Maximale Dienstzeit erreicht'
                })

                FL.Duty.EndDuty(source, dutyData.service, 'timeout', true)
            end
        end
    end
end)

-- ================================
-- 📡 EVENT HANDLERS
-- ================================

-- Duty Toggle Event
RegisterNetEvent('fl:duty:toggle', function(stationId)
    local source = source
    local service = FL.GetPlayerService(source)

    if not service then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Du bist kein Emergency Service Mitglied'
        })
        return
    end

    if FL.IsPlayerOnDuty(source) then
        FL.Duty.EndDuty(source, service, stationId)
    else
        FL.Duty.StartDuty(source, service, stationId)
    end
end)

-- Equipment Request Event
RegisterNetEvent('fl:equipment:request', function(item)
    local source = source
    local service = FL.GetPlayerService(source)

    if not service or not FL.IsPlayerOnDuty(source) then
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)
    local success = Player.Functions.AddItem(item, 1)

    if success then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'success',
            description = item .. ' erhalten'
        })
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add')
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Inventar voll oder Item nicht verfügbar'
        })
    end
end)

-- ================================
-- 📤 EXPORTS
-- ================================

exports('StartDuty', function(source, service, stationId)
    return FL.Duty.StartDuty(source, service, stationId)
end)

exports('EndDuty', function(source, service, stationId, forced)
    return FL.Duty.EndDuty(source, service, stationId, forced)
end)

exports('GetActivePlayersInService', function(service)
    return FL.Duty.GetActivePlayersInService(service)
end)

exports('IsPlayerOnDuty', function(source)
    return FL.State.activePlayers[source] ~= nil
end)
