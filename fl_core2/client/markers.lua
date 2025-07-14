-- ================================
-- 🎯 FL EMERGENCY - MARKER SYSTEM CLIENT
-- ================================

FL.Markers = {
    active = {},
    blips = {},
    threads = {},
    lastCheck = 0
}

-- ================================
-- 🎯 MARKER MANAGEMENT
-- ================================

-- Erstelle Marker für Stationen
function FL.Markers.CreateStationMarkers()
    for service, stations in pairs(Config.Stations) do
        for stationId, stationData in pairs(stations) do
            FL.Markers.CreateStationBlip(service, stationId, stationData)
        end
    end
end

-- Erstelle Blip für Station
function FL.Markers.CreateStationBlip(service, stationId, stationData)
    local blip = AddBlipForCoord(stationData.coords.x, stationData.coords.y, stationData.coords.z)
    
    -- Blip-Einstellungen basierend auf Service
    local blipData = {
        fire = { sprite = 436, color = 1, name = 'Feuerwache' },
        police = { sprite = 60, color = 29, name = 'Polizeiwache' },
        ems = { sprite = 61, color = 2, name = 'Krankenhaus' }
    }
    
    local serviceBlip = blipData[service]
    if serviceBlip then
        SetBlipSprite(blip, serviceBlip.sprite)
        SetBlipColour(blip, serviceBlip.color)
        SetBlipAsShortRange(blip, true)
        SetBlipCategory(blip, 3)
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(serviceBlip.name .. ' - ' .. stationData.label)
        EndTextCommandSetBlipName(blip)
    end
    
    FL.Markers.blips[stationId] = blip
end

-- ================================
-- 🚨 CALL MARKERS
-- ================================

-- Erstelle Marker für Einsatz
function FL.Markers.CreateCallMarker(call)
    if FL.Markers.active[call.id] then
        FL.Markers.RemoveCallMarker(call.id)
    end
    
    local coords = vector3(call.coords.x, call.coords.y, call.coords.z)
    
    -- Blip erstellen
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    
    -- Blip-Einstellungen basierend auf Service und Priorität
    local blipSettings = FL.Markers.GetCallBlipSettings(call.service, call.priority)
    
    SetBlipSprite(blip, blipSettings.sprite)
    SetBlipColour(blip, blipSettings.color)
    SetBlipScale(blip, blipSettings.scale)
    SetBlipAsShortRange(blip, false)
    SetBlipCategory(blip, 1)
    
    -- Blip-Name
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(call.id .. ' - ' .. call.type)
    EndTextCommandSetBlipName(blip)
    
    -- Blip-Route (falls zugewiesen)
    if FL.Markers.IsPlayerAssignedToCall(call) then
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, blipSettings.color)
    end
    
    -- Marker-Daten speichern
    FL.Markers.active[call.id] = {
        blip = blip,
        coords = coords,
        call = call,
        created = GetGameTimer()
    }
    
    -- Erstelle 3D-Marker-Thread
    FL.Markers.Create3DMarker(call.id, coords, call)
end

-- Hole Blip-Einstellungen für Call
function FL.Markers.GetCallBlipSettings(service, priority)
    local baseSettings = {
        fire = { sprite = 436, color = 1 },
        police = { sprite = 60, color = 29 },
        ems = { sprite = 61, color = 2 }
    }
    
    local settings = baseSettings[service] or { sprite = 1, color = 0 }
    
    -- Prioritäts-Anpassungen
    if priority == 1 then
        settings.color = 1 -- Rot
        settings.scale = 1.2
    elseif priority == 2 then
        settings.color = 17 -- Orange
        settings.scale = 1.0
    else
        settings.color = 3 -- Blau
        settings.scale = 0.8
    end
    
    return settings
end

-- Prüfe ob Spieler einem Call zugewiesen ist
function FL.Markers.IsPlayerAssignedToCall(call)
    local playerId = GetPlayerServerId(PlayerId())
    
    for _, assignedPlayer in pairs(call.assigned) do
        if assignedPlayer == playerId then
            return true
        end
    end
    
    return false
end

-- ================================
-- 🎨 3D MARKERS
-- ================================

-- Erstelle 3D-Marker
function FL.Markers.Create3DMarker(callId, coords, call)
    FL.Markers.threads[callId] = CreateThread(function()
        while FL.Markers.active[callId] do
            Wait(0)
            
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - coords)
            
            -- Nur in Reichweite rendern
            if distance < Config.Interaction.markerDistance then
                -- Marker-Farbe basierend auf Priorität
                local r, g, b = FL.Markers.GetMarkerColor(call.priority)
                
                -- 3D-Marker
                DrawMarker(
                    1, -- Typ: Zylinder
                    coords.x, coords.y, coords.z - 1.0,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    3.0, 3.0, 1.0,
                    r, g, b, 100,
                    false, true, 2, false, nil, nil, false
                )
                
                -- Pulsierender Effekt
                local pulseScale = 1.0 + math.sin(GetGameTimer() * 0.005) * 0.2
                DrawMarker(
                    1,
                    coords.x, coords.y, coords.z - 0.5,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    2.0 * pulseScale, 2.0 * pulseScale, 0.5,
                    r, g, b, 50,
                    false, true, 2, false, nil, nil, false
                )
                
                -- Text-Label
                if distance < 10.0 then
                    FL.Markers.Draw3DText(
                        coords.x, coords.y, coords.z + 1.0,
                        call.id .. '\n' .. call.type .. '\nPriorität: ' .. call.priority
                    )
                end
                
                -- Interaktion
                if distance < Config.Interaction.interactionDistance then
                    FL.Markers.ShowCallInteraction(call)
                end
            end
        end
    end)
end

-- Hole Marker-Farbe
function FL.Markers.GetMarkerColor(priority)
    local colors = {
        [1] = { 231, 76, 60 },   -- Rot
        [2] = { 243, 156, 18 },  -- Orange
        [3] = { 52, 152, 219 }   -- Blau
    }
    
    local color = colors[priority] or { 149, 165, 166 }
    return color[1], color[2], color[3]
end

-- Zeichne 3D-Text
function FL.Markers.Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

-- Zeige Call-Interaktion
function FL.Markers.ShowCallInteraction(call)
    if not FL.Player.onDuty or FL.Player.service ~= call.service then
        return
    end
    
    -- Hilfe-Text
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName("Drücke ~INPUT_CONTEXT~ um Einsatz-Aktionen zu öffnen")
    EndTextCommandDisplayHelp(0, false, true, -1)
    
    -- Interaktion
    if IsControlJustPressed(0, 38) then -- E
        FL.UI.OpenCallActions(call.id, call)
    end
end

-- ================================
-- 🗑️ MARKER CLEANUP
-- ================================

-- Entferne Call-Marker
function FL.Markers.RemoveCallMarker(callId)
    local marker = FL.Markers.active[callId]
    if not marker then return end
    
    -- Blip entfernen
    if DoesBlipExist(marker.blip) then
        RemoveBlip(marker.blip)
    end
    
    -- Thread beenden
    if FL.Markers.threads[callId] then
        FL.Markers.threads[callId] = nil
    end
    
    -- Marker entfernen
    FL.Markers.active[callId] = nil
end

-- Aktualisiere Call-Marker
function FL.Markers.UpdateCallMarker(call)
    local marker = FL.Markers.active[call.id]
    if not marker then
        FL.Markers.CreateCallMarker(call)
        return
    end
    
    -- Update Blip-Route
    local isAssigned = FL.Markers.IsPlayerAssignedToCall(call)
    if isAssigned then
        SetBlipRoute(marker.blip, true)
        SetBlipRouteColour(marker.blip, FL.Markers.GetCallBlipSettings(call.service, call.priority).color)
    else
        SetBlipRoute(marker.blip, false)
    end
    
    -- Update Call-Daten
    marker.call = call
end

-- ================================
-- 🌐 WAYPOINT SYSTEM
-- ================================

-- Setze Waypoint für Call
function FL.Markers.SetCallWaypoint(coords)
    SetNewWaypoint(coords.x, coords.y)
    
    lib.notify({
        type = 'success',
        description = 'GPS-Route gesetzt'
    })
end

-- Entferne Waypoint
function FL.Markers.ClearWaypoint()
    SetWaypointOff()
    
    lib.notify({
        type = 'info',
        description = 'GPS-Route entfernt'
    })
end

-- ================================
-- 🎮 BLIP MANAGEMENT
-- ================================

-- Erstelle Service-Blips für Spieler
function FL.Markers.CreatePlayerBlips()
    CreateThread(function()
        while true do
            Wait(5000) -- Update alle 5 Sekunden
            
            if FL.Player.onDuty then
                FL.Markers.UpdatePlayerBlips()
            end
        end
    end)
end

-- Update Spieler-Blips
function FL.Markers.UpdatePlayerBlips()
    -- Nur für Emergency Services
    if not FL.Player.service then return end
    
    -- Hole andere Spieler des gleichen Services
    local players = GetActivePlayers()
    
    for _, player in pairs(players) do
        if player ~= PlayerId() then
            local playerPed = GetPlayerPed(player)
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Prüfe ob Spieler Emergency Service ist
            -- (Implementierung hängt von verfügbaren Funktionen ab)
            
            -- Erstelle/Update Blip
            FL.Markers.UpdatePlayerBlip(player, playerCoords)
        end
    end
end

-- Update einzelnen Spieler-Blip
function FL.Markers.UpdatePlayerBlip(player, coords)
    local playerId = GetPlayerServerId(player)
    
    -- Erstelle Blip falls nicht vorhanden
    if not FL.Markers.blips['player_' .. playerId] then
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 2)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        SetBlipCategory(blip, 7)
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(GetPlayerName(player))
        EndTextCommandSetBlipName(blip)
        
        FL.Markers.blips['player_' .. playerId] = blip
    else
        -- Update Position
        SetBlipCoords(FL.Markers.blips['player_' .. playerId], coords.x, coords.y, coords.z)
    end
end

-- ================================
-- 🚨 EMERGENCY BLIP EFFECTS
-- ================================

-- Erstelle blinkenden Blip für High-Priority Calls
function FL.Markers.CreateFlashingBlip(call)
    if call.priority ~= 1 then return end
    
    local marker = FL.Markers.active[call.id]
    if not marker then return end
    
    CreateThread(function()
        while FL.Markers.active[call.id] do
            Wait(500)
            
            if DoesBlipExist(marker.blip) then
                -- Blinking Effect
                SetBlipFlashes(marker.blip, true)
                SetBlipFlashTimer(marker.blip, 1000)
            end
        end
    end)
end

-- ================================
-- 🔄 MARKER SYSTEM THREADS
-- ================================

-- Haupt-Marker-Thread
function FL.Markers.StartMarkerSystem()
    -- Station-Marker erstellen
    FL.Markers.CreateStationMarkers()
    
    -- Player-Blips starten
    FL.Markers.CreatePlayerBlips()
    
    -- Cleanup-Thread
    CreateThread(function()
        while true do
            Wait(60000) -- Cleanup alle 60 Sekunden
            
            -- Entferne verwaiste Marker
            for callId, marker in pairs(FL.Markers.active) do
                if not FL.State.activeCalls[callId] then
                    FL.Markers.RemoveCallMarker(callId)
                end
            end
            
            -- Entferne verwaiste Player-Blips
            for blipId, blip in pairs(FL.Markers.blips) do
                if string.find(blipId, 'player_') then
                    local playerId = tonumber(string.gsub(blipId, 'player_', ''))
                    if not playerId or not GetPlayerPed(GetPlayerFromServerId(playerId)) then
                        if DoesBlipExist(blip) then
                            RemoveBlip(blip)
                        end
                        FL.Markers.blips[blipId] = nil
                    end
                end
            end
        end
    end)
end

-- ================================
-- 📡 EVENT HANDLERS
-- ================================

-- Call Created
RegisterNetEvent('fl:callCreated', function(call)
    if FL.Player.service == call.service then
        FL.Markers.CreateCallMarker(call)
        FL.Markers.CreateFlashingBlip(call)
    end
end)

-- Call Updated
RegisterNetEvent('fl:callUpdated', function(call)
    if FL.Player.service == call.service then
        FL.Markers.UpdateCallMarker(call)
    end
end)

-- Call Completed/Cancelled
RegisterNetEvent('fl:callCompleted', function(data)
    FL.Markers.RemoveCallMarker(data.id)
end)

RegisterNetEvent('fl:callCancelled', function(data)
    FL.Markers.RemoveCallMarker(data.id)
end)

-- Waypoint Events
RegisterNetEvent('fl:call:setWaypoint', function(coords)
    FL.Markers.SetCallWaypoint(coords)
end)

RegisterNetEvent('fl:call:clearWaypoint', function()
    FL.Markers.ClearWaypoint()
end)

-- ================================
-- 🎯 INITIALIZATION
-- ================================

-- Starte Marker-System
CreateThread(function()
    -- Warte auf Spieler-Login
    while not LocalPlayer.state.isLoggedIn do
        Wait(1000)
    end
    
    -- Warte auf Player-Service
    while not FL.Player.service do
        Wait(1000)
    end
    
    -- Starte Marker-System
    FL.Markers.StartMarkerSystem()
    
    if Config.Debug then
        print('^2[FL Markers]^7 Marker system initialized')
    end
end)

-- ================================
-- 🧹 CLEANUP ON RESOURCE STOP
-- ================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Entferne alle Blips
        for _, blip in pairs(FL.Markers.blips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        
        -- Entferne alle Marker
        for callId, _ in pairs(FL.Markers.active) do
            FL.Markers.RemoveCallMarker(callId)
        end
        
        -- Beende alle Threads
        for callId, _ in pairs(FL.Markers.threads) do
            FL.Markers.threads[callId] = nil
        end
    end
end)