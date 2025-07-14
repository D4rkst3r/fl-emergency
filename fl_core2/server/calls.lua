-- ================================
-- 🚨 FL EMERGENCY - CALL SYSTEM SERVER
-- ================================

FL.Calls = {}

-- ================================
-- 📞 CALL MANAGEMENT
-- ================================

-- Erstelle neuen Einsatz
function FL.Calls.CreateCall(data)
    -- Generiere eindeutige Call-ID
    local callId = FL.Calls.GenerateCallId(data.service)

    -- Erstelle Call-Objekt
    local call = {
        id = callId,
        service = data.service,
        type = data.type or 'general',
        priority = data.priority or 2,
        status = 'pending',
        coords = data.coords,
        description = data.description or 'Einsatz ' .. callId,
        reporter = data.reporter or 'System',
        assigned = {},
        created = os.time(),
        updated = os.time(),
        responseTime = nil,
        completedTime = nil,
        notes = {}
    }

    -- Zusätzliche Daten hinzufügen
    if data.blip then
        call.blip = data.blip
    end

    if data.requiredUnits then
        call.requiredUnits = data.requiredUnits
    else
        -- Automatische Einheit-Anforderung basierend auf Call-Type
        local callTypeData = Config.Services[data.service].callTypes[data.type]
        if callTypeData then
            call.requiredUnits = callTypeData.requiredUnits or 1
            call.requiredEquipment = callTypeData.equipment or {}
        else
            call.requiredUnits = 1
        end
    end

    -- Speichere Call
    FL.State.activeCalls[callId] = call
    FL.Database.SaveCall(call)

    -- Auto-Assignment (falls konfiguriert)
    if Config.ServiceSettings.autoAssignCalls then
        FL.Calls.AutoAssignCall(callId)
    end

    -- Broadcast an alle Spieler des Services
    FL.Broadcast('callCreated', call, data.service)

    -- Statistiken
    FL.Stats.totalCalls = FL.Stats.totalCalls + 1

    FL.Log('info', 'Call created', {
        id = callId,
        service = data.service,
        type = data.type,
        priority = data.priority,
        coords = data.coords
    })

    return callId, call
end

-- Auto-Assignment Logic
function FL.Calls.AutoAssignCall(callId)
    local call = FL.State.activeCalls[callId]
    if not call then return end

    -- Finde verfügbare Spieler des Services
    local availablePlayers = FL.Calls.GetAvailablePlayers(call.service, call.coords)

    if #availablePlayers == 0 then
        FL.Log('warn', 'No available players for auto-assignment', { callId = callId })
        return
    end

    -- Sortiere nach Nähe und Rang
    table.sort(availablePlayers, function(a, b)
        if a.distance == b.distance then
            return a.rank > b.rank
        end
        return a.distance < b.distance
    end)

    -- Weise zu (maximal requiredUnits)
    local assigned = 0
    for _, playerData in pairs(availablePlayers) do
        if assigned >= call.requiredUnits then break end

        FL.Calls.AssignPlayer(playerData.source, callId, true)
        assigned = assigned + 1
    end
end

-- Weise Spieler einem Einsatz zu
function FL.Calls.AssignPlayer(source, callId, autoAssigned)
    local call = FL.State.activeCalls[callId]
    if not call then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Einsatz nicht gefunden'
        })
        return false
    end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    local playerService = FL.GetPlayerService(source)
    if playerService ~= call.service then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Einsatz nicht für deinen Service'
        })
        return false
    end

    if not FL.IsPlayerOnDuty(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Du musst im Dienst sein'
        })
        return false
    end

    -- Prüfe ob bereits zugewiesen
    for _, assignedSource in pairs(call.assigned) do
        if assignedSource == source then
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                description = 'Du bist bereits diesem Einsatz zugewiesen'
            })
            return false
        end
    end

    -- Füge Spieler hinzu
    table.insert(call.assigned, source)
    call.status = 'assigned'
    call.updated = os.time()

    -- Response Time (erster zugewiesener Spieler)
    if #call.assigned == 1 then
        call.responseTime = os.time() - call.created
    end

    -- Update Player Duty Data
    local dutyData = FL.State.activePlayers[source]
    if dutyData then
        dutyData.currentCall = callId
    end

    -- Notifications
    local assignmentType = autoAssigned and 'automatisch' or 'manuell'
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        title = 'Einsatz zugewiesen',
        description = call.id .. ' - ' .. call.type .. ' (' .. assignmentType .. ')'
    })

    -- Setze GPS-Marker
    TriggerClientEvent('fl:call:setWaypoint', source, call.coords)

    -- Broadcast Update
    FL.Broadcast('callUpdated', call, call.service)
    FL.Database.UpdateCall(callId, call)

    FL.Log('info', 'Player assigned to call', {
        source = source,
        callId = callId,
        autoAssigned = autoAssigned
    })

    return true
end

-- Entferne Spieler von Einsatz
function FL.Calls.UnassignPlayer(source, callId)
    local call = FL.State.activeCalls[callId]
    if not call then return false end

    -- Entferne aus assigned list
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
    call.updated = os.time()

    -- Update Player Duty Data
    local dutyData = FL.State.activePlayers[source]
    if dutyData then
        dutyData.currentCall = nil
    end

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'info',
        description = 'Von Einsatz ' .. call.id .. ' entfernt'
    })

    -- Clear GPS-Marker
    TriggerClientEvent('fl:call:clearWaypoint', source)

    -- Broadcast Update
    FL.Broadcast('callUpdated', call, call.service)
    FL.Database.UpdateCall(callId, call)

    return true
end

-- ================================
-- ✅ CALL COMPLETION
-- ================================

-- Markiere Einsatz als abgeschlossen
function FL.Calls.CompleteCall(callId, source, notes)
    local call = FL.State.activeCalls[callId]
    if not call then return false end

    -- Prüfe ob Spieler zugewiesen ist
    local isAssigned = false
    for _, assignedSource in pairs(call.assigned) do
        if assignedSource == source then
            isAssigned = true
            break
        end
    end

    if not isAssigned then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Du bist diesem Einsatz nicht zugewiesen'
        })
        return false
    end

    -- Update Call
    call.status = 'completed'
    call.completedTime = os.time()
    call.updated = os.time()

    if notes then
        table.insert(call.notes, {
            author = source,
            text = notes,
            timestamp = os.time()
        })
    end

    -- Entferne alle zugewiesenen Spieler
    for _, assignedSource in pairs(call.assigned) do
        local dutyData = FL.State.activePlayers[assignedSource]
        if dutyData then
            dutyData.currentCall = nil
        end

        TriggerClientEvent('fl:call:clearWaypoint', assignedSource)
        TriggerClientEvent('ox_lib:notify', assignedSource, {
            type = 'success',
            title = 'Einsatz abgeschlossen',
            description = call.id .. ' - ' .. call.type
        })
    end

    -- Berechne Gesamtzeit
    local totalTime = call.completedTime - call.created

    -- Broadcast
    FL.Broadcast('callCompleted', {
        id = callId,
        totalTime = totalTime,
        responseTime = call.responseTime
    }, call.service)

    -- Database Update
    FL.Database.UpdateCall(callId, call)

    -- Entferne nach Delay
    SetTimeout(30000, function() -- 30 Sekunden
        FL.State.activeCalls[callId] = nil
        FL.Database.DeleteExpiredCall(callId)
    end)

    FL.Log('info', 'Call completed', {
        callId = callId,
        completedBy = source,
        totalTime = totalTime,
        responseTime = call.responseTime
    })

    return true
end

-- Abbruch eines Einsatzes
function FL.Calls.CancelCall(callId, reason, source)
    local call = FL.State.activeCalls[callId]
    if not call then return false end

    -- Update Call
    call.status = 'cancelled'
    call.updated = os.time()
    call.cancelReason = reason
    call.cancelledBy = source

    -- Benachrichtige alle zugewiesenen Spieler
    for _, assignedSource in pairs(call.assigned) do
        local dutyData = FL.State.activePlayers[assignedSource]
        if dutyData then
            dutyData.currentCall = nil
        end

        TriggerClientEvent('fl:call:clearWaypoint', assignedSource)
        TriggerClientEvent('ox_lib:notify', assignedSource, {
            type = 'error',
            title = 'Einsatz abgebrochen',
            description = call.id .. ' - Grund: ' .. reason
        })
    end

    -- Broadcast
    FL.Broadcast('callCancelled', {
        id = callId,
        reason = reason
    }, call.service)

    -- Database Update
    FL.Database.UpdateCall(callId, call)

    -- Entferne sofort
    FL.State.activeCalls[callId] = nil

    FL.Log('info', 'Call cancelled', {
        callId = callId,
        reason = reason,
        cancelledBy = source
    })

    return true
end

-- ================================
-- 🔍 CALL QUERIES
-- ================================

-- Finde verfügbare Spieler
function FL.Calls.GetAvailablePlayers(service, coords)
    local availablePlayers = {}

    for source, dutyData in pairs(FL.State.activePlayers) do
        if dutyData.service == service and not dutyData.currentCall then
            local Player = QBCore.Functions.GetPlayer(source)
            if Player then
                local playerCoords = GetEntityCoords(GetPlayerPed(source))
                local distance = coords and #(playerCoords - vector3(coords.x, coords.y, coords.z)) or 0

                table.insert(availablePlayers, {
                    source = source,
                    citizenid = dutyData.citizenid,
                    rank = Player.PlayerData.job.grade.level,
                    distance = distance,
                    coords = playerCoords
                })
            end
        end
    end

    return availablePlayers
end

-- Hole aktive Einsätze für Service
function FL.Calls.GetActiveCalls(service)
    local calls = {}

    for callId, call in pairs(FL.State.activeCalls) do
        if not service or call.service == service then
            calls[callId] = call
        end
    end

    return calls
end

-- ================================
-- 🎲 UTILITY FUNCTIONS
-- ================================

-- Generiere Call-ID
function FL.Calls.GenerateCallId(service)
    local prefixes = {
        fire = 'FW',
        police = 'POL',
        ems = 'RD'
    }

    local prefix = prefixes[service] or 'FL'
    local number = math.random(1000, 9999)
    local timestamp = os.date('%H%M')

    return prefix .. '-' .. timestamp .. '-' .. number
end

-- Berechne Prioritäts-Farbe
function FL.Calls.GetPriorityColor(priority)
    return Config.Calls.priorityColors[priority] or '#95a5a6'
end

-- Formatiere Call-Zeit
function FL.Calls.FormatCallTime(timestamp)
    return os.date('%H:%M:%S', timestamp)
end

-- ================================
-- ⏰ AUTOMATIC CALL TIMEOUT
-- ================================

CreateThread(function()
    while true do
        Wait(60000) -- Check every minute

        for callId, call in pairs(FL.State.activeCalls) do
            local age = os.time() - call.created

            if age > Config.Calls.callTimeout then
                FL.Log('info', 'Call timeout', { callId = callId, age = age })
                FL.Calls.CancelCall(callId, 'Timeout', nil)
            end
        end
    end
end)

-- ================================
-- 🎯 RANDOM CALL GENERATION
-- ================================

-- Generiere zufällige Einsätze (für Testing/RP)
function FL.Calls.GenerateRandomCall(service)
    local callTypes = {}
    for callType, _ in pairs(Config.Services[service].callTypes) do
        table.insert(callTypes, callType)
    end

    if #callTypes == 0 then return nil end

    local randomType = callTypes[math.random(1, #callTypes)]
    local randomCoords = FL.Calls.GetRandomLocation()

    local callData = {
        service = service,
        type = randomType,
        priority = math.random(1, 3),
        coords = randomCoords,
        description = 'Automatisch generierter Einsatz',
        reporter = 'System'
    }

    return FL.Calls.CreateCall(callData)
end

function FL.Calls.GetRandomLocation()
    -- Zufällige Locations in Los Santos
    local locations = {
        { x = 213.5,   y = -810.0,  z = 31.0 }, -- Downtown
        { x = -1037.0, y = -2738.0, z = 20.0 }, -- Airport
        { x = 1855.0,  y = 3683.0,  z = 34.0 }, -- Sandy Shores
        { x = -1313.0, y = -834.0,  z = 17.0 }, -- Vespucci
        { x = 1207.0,  y = -1456.0, z = 35.0 }, -- Fire Station
        { x = 441.0,   y = -982.0,  z = 30.0 }, -- Mission Row PD
        { x = 298.0,   y = -584.0,  z = 43.0 }  -- Pillbox Medical
    }

    return locations[math.random(1, #locations)]
end

-- ================================
-- 📡 EVENT HANDLERS
-- ================================

-- Call Creation Event
RegisterNetEvent('fl:call:create', function(data)
    FL.Calls.CreateCall(data)
end)

-- Call Assignment Event
RegisterNetEvent('fl:call:assign', function(callId)
    local source = source
    FL.Calls.AssignPlayer(source, callId, false)
end)

-- Call Unassignment Event
RegisterNetEvent('fl:call:unassign', function(callId)
    local source = source
    FL.Calls.UnassignPlayer(source, callId)
end)

-- Call Completion Event
RegisterNetEvent('fl:call:complete', function(callId, notes)
    local source = source
    FL.Calls.CompleteCall(callId, source, notes)
end)

-- Call Cancel Event
RegisterNetEvent('fl:call:cancel', function(callId, reason)
    local source = source

    -- Prüfe Admin-Berechtigung für Cancel
    if not QBCore.Functions.HasPermission(source, 'admin') then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Keine Berechtigung'
        })
        return
    end

    FL.Calls.CancelCall(callId, reason, source)
end)

-- Call Status Update Event
RegisterNetEvent('fl:call:updateStatus', function(callId, newStatus)
    local source = source
    local call = FL.State.activeCalls[callId]

    if not call then return end

    -- Prüfe ob Spieler zugewiesen ist
    local isAssigned = false
    for _, assignedSource in pairs(call.assigned) do
        if assignedSource == source then
            isAssigned = true
            break
        end
    end

    if not isAssigned then return end

    call.status = newStatus
    call.updated = os.time()

    FL.Broadcast('callUpdated', call, call.service)
    FL.Database.UpdateCall(callId, call)
end)

-- ================================
-- 📝 ADMIN COMMANDS
-- ================================

-- Random Call Command
lib.addCommand('randomcall', {
    help = 'Generate a random emergency call',
    params = {
        { name = 'service', type = 'string', help = 'Service (fire/police/ems)' }
    },
    restricted = 'group.admin'
}, function(source, args)
    local service = args.service

    if not Config.Services[service] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid service'
        })
        return
    end

    local callId = FL.Calls.GenerateRandomCall(service)

    if callId then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'success',
            description = 'Random call created: ' .. callId
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Failed to create random call'
        })
    end
end)

-- ================================
-- 📤 EXPORTS
-- ================================

exports('CreateCall', function(data)
    return FL.Calls.CreateCall(data)
end)

exports('GetActiveCalls', function(service)
    return FL.Calls.GetActiveCalls(service)
end)

exports('AssignPlayerToCall', function(source, callId)
    return FL.Calls.AssignPlayer(source, callId, false)
end)

exports('CompleteCall', function(callId, source, notes)
    return FL.Calls.CompleteCall(callId, source, notes)
end)
