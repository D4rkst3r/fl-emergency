-- ================================
-- 🗃️ FL EMERGENCY - DATABASE MANAGEMENT
-- ================================

FL.Database = {}

-- ================================
-- 📊 DATABASE OPERATIONS
-- ================================

-- Speichere Spieler-Duty-Status
function FL.Database.SaveDutyRecord(citizenid, service, action, data)
    MySQL.insert([[
        INSERT INTO fl_emergency_data (citizenid, type, service, data, expires_at)
        VALUES (?, ?, ?, ?, ?)
    ]], {
        citizenid,
        'duty',
        service,
        json.encode({
            action = action,
            timestamp = os.time(),
            station = data.station,
            duration = data.duration,
            equipment = data.equipment
        }),
        action == 'start' and nil or (os.date('%Y-%m-%d %H:%M:%S', os.time() + 86400)) -- 24h für end records
    })
end

-- Speichere Einsatz-Daten
function FL.Database.SaveCall(callData)
    MySQL.insert([[
        INSERT INTO fl_emergency_data (citizenid, type, service, data, expires_at)
        VALUES (?, ?, ?, ?, ?)
    ]], {
        'system',
        'call',
        callData.service,
        json.encode(callData),
        os.date('%Y-%m-%d %H:%M:%S', os.time() + Config.Calls.callTimeout)
    }, function(insertId)
        if insertId then
            callData.dbId = insertId
        end
    end)
end

-- Update Einsatz-Status
function FL.Database.UpdateCall(callId, newData)
    MySQL.update([[
        UPDATE fl_emergency_data
        SET data = ?, updated_at = CURRENT_TIMESTAMP
        WHERE type = 'call' AND JSON_EXTRACT(data, '$.id') = ?
    ]], {
        json.encode(newData),
        callId
    })
end

-- Lösche abgelaufene Einsätze
function FL.Database.DeleteExpiredCall(callId)
    MySQL.execute([[
        DELETE FROM fl_emergency_data
        WHERE type = 'call' AND JSON_EXTRACT(data, '$.id') = ?
    ]], { callId })
end

-- Speichere Fahrzeug-Daten
function FL.Database.SaveVehicle(citizenid, service, vehicleData)
    MySQL.insert([[
        INSERT INTO fl_emergency_data (citizenid, type, service, data, expires_at)
        VALUES (?, ?, ?, ?, ?)
    ]], {
        citizenid,
        'vehicle',
        service,
        json.encode({
            model = vehicleData.model,
            plate = vehicleData.plate,
            coords = vehicleData.coords,
            spawned = vehicleData.spawned,
            timestamp = os.time()
        }),
        os.date('%Y-%m-%d %H:%M:%S', os.time() + 7200) -- 2 Stunden
    })
end

-- Entferne Fahrzeug aus Database
function FL.Database.RemoveVehicle(plate)
    MySQL.execute([[
        DELETE FROM fl_emergency_data
        WHERE type = 'vehicle' AND JSON_EXTRACT(data, '$.plate') = ?
    ]], { plate })
end

-- ================================
-- 📈 STATISTIKEN & ANALYTICS
-- ================================

-- Speichere Service-Statistiken
function FL.Database.SaveStats(service, statsData)
    MySQL.insert([[
        INSERT INTO fl_emergency_data (citizenid, type, service, data)
        VALUES (?, ?, ?, ?)
    ]], {
        'system',
        'stats',
        service,
        json.encode({
            date = os.date('%Y-%m-%d'),
            stats = statsData,
            timestamp = os.time()
        })
    })
end

-- Lade Duty-Statistiken für Spieler
function FL.Database.GetPlayerDutyStats(citizenid, callback)
    MySQL.query([[
        SELECT
            service,
            COUNT(*) as total_shifts,
            SUM(CASE WHEN JSON_EXTRACT(data, '$.action') = 'end' THEN JSON_EXTRACT(data, '$.duration') ELSE 0 END) as total_duration,
            AVG(CASE WHEN JSON_EXTRACT(data, '$.action') = 'end' THEN JSON_EXTRACT(data, '$.duration') ELSE NULL END) as avg_duration
        FROM fl_emergency_data
        WHERE citizenid = ? AND type = 'duty' AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        GROUP BY service
    ]], { citizenid }, function(result)
        callback(result or {})
    end)
end

-- Lade Service-Statistiken
function FL.Database.GetServiceStats(service, days, callback)
    MySQL.query([[
        SELECT
            DATE(created_at) as date,
            COUNT(DISTINCT CASE WHEN JSON_EXTRACT(data, '$.action') = 'start' THEN citizenid END) as active_players,
            COUNT(CASE WHEN type = 'call' THEN 1 END) as total_calls,
            COUNT(CASE WHEN type = 'call' AND JSON_EXTRACT(data, '$.status') = 'completed' THEN 1 END) as completed_calls
        FROM fl_emergency_data
        WHERE service = ? AND created_at >= DATE_SUB(NOW(), INTERVAL ? DAY)
        GROUP BY DATE(created_at)
        ORDER BY date DESC
    ]], { service, days }, function(result)
        callback(result or {})
    end)
end

-- ================================
-- 🔍 QUERY FUNCTIONS
-- ================================

-- Lade aktive Einsätze
function FL.Database.GetActiveCalls(service, callback)
    local query = service and [[
        SELECT * FROM fl_emergency_data
        WHERE type = 'call' AND service = ? AND (expires_at IS NULL OR expires_at > NOW())
        ORDER BY JSON_EXTRACT(data, '$.priority') ASC, created_at ASC
    ]] or [[
        SELECT * FROM fl_emergency_data
        WHERE type = 'call' AND (expires_at IS NULL OR expires_at > NOW())
        ORDER BY JSON_EXTRACT(data, '$.priority') ASC, created_at ASC
    ]]

    MySQL.query(query, service and { service } or {}, function(result)
        local calls = {}
        if result then
            for _, row in pairs(result) do
                local callData = json.decode(row.data)
                callData.dbId = row.id
                calls[callData.id] = callData
            end
        end
        callback(calls)
    end)
end

-- Lade aktive Spieler im Dienst
function FL.Database.GetActivePlayers(service, callback)
    -- Finde Spieler die Dienst begonnen haben aber noch nicht beendet
    MySQL.query([[
        SELECT DISTINCT d1.citizenid, d1.service, d1.data, d1.created_at
        FROM fl_emergency_data d1
        WHERE d1.type = 'duty'
            AND JSON_EXTRACT(d1.data, '$.action') = 'start'
            AND (? IS NULL OR d1.service = ?)
            AND NOT EXISTS (
                SELECT 1 FROM fl_emergency_data d2
                WHERE d2.citizenid = d1.citizenid
                    AND d2.service = d1.service
                    AND d2.type = 'duty'
                    AND JSON_EXTRACT(d2.data, '$.action') = 'end'
                    AND d2.created_at > d1.created_at
            )
            AND d1.created_at >= DATE_SUB(NOW(), INTERVAL 12 HOUR)
        ORDER BY d1.created_at DESC
    ]], { service, service }, function(result)
        local players = {}
        if result then
            for _, row in pairs(result) do
                local dutyData = json.decode(row.data)
                players[row.citizenid] = {
                    citizenid = row.citizenid,
                    service = row.service,
                    station = dutyData.station,
                    startTime = dutyData.timestamp,
                    duration = os.time() - dutyData.timestamp
                }
            end
        end
        callback(players)
    end)
end

-- Lade Fahrzeug-Historie
function FL.Database.GetVehicleHistory(citizenid, callback)
    MySQL.query([[
        SELECT * FROM fl_emergency_data
        WHERE citizenid = ? AND type = 'vehicle'
        ORDER BY created_at DESC
        LIMIT 10
    ]], { citizenid }, function(result)
        local vehicles = {}
        if result then
            for _, row in pairs(result) do
                table.insert(vehicles, {
                    id = row.id,
                    data = json.decode(row.data),
                    created = row.created_at
                })
            end
        end
        callback(vehicles)
    end)
end

-- ================================
-- 🧹 CLEANUP FUNCTIONS
-- ================================

-- Bereinige abgelaufene Daten
function FL.Database.CleanupExpiredData()
    -- Lösche abgelaufene Einträge
    MySQL.execute([[
        DELETE FROM fl_emergency_data
        WHERE expires_at IS NOT NULL AND expires_at < NOW()
    ]], {}, function(affectedRows)
        if affectedRows > 0 and Config.Debug then
            print('^3[FL Database]^7 Cleaned up ' .. affectedRows .. ' expired records')
        end
    end)

    -- Lösche alte Log-Einträge (älter als konfigurierte Tage)
    MySQL.execute([[
        DELETE FROM fl_emergency_data
        WHERE type = 'log' AND created_at < DATE_SUB(NOW(), INTERVAL ? DAY)
    ]], { Config.Database.maxLogDays }, function(affectedRows)
        if affectedRows > 0 and Config.Debug then
            print('^3[FL Database]^7 Cleaned up ' .. affectedRows .. ' old log records')
        end
    end)
end

-- Bereinige Spieler-Daten nach Disconnect
function FL.Database.CleanupPlayerData(citizenid)
    -- Markiere aktive Fahrzeuge als despawned
    MySQL.update([[
        UPDATE fl_emergency_data
        SET data = JSON_SET(data, '$.spawned', false), expires_at = DATE_ADD(NOW(), INTERVAL 1 HOUR)
        WHERE citizenid = ? AND type = 'vehicle' AND JSON_EXTRACT(data, '$.spawned') = true
    ]], { citizenid })

    -- Beende offene Duty-Sessions
    FL.Database.SaveDutyRecord(citizenid, 'unknown', 'end', {
        station = 'auto_disconnect',
        duration = 0,
        equipment = {}
    })
end

-- ================================
-- 📊 REPORTING FUNCTIONS
-- ================================

-- Generiere Duty-Report
function FL.Database.GenerateDutyReport(service, startDate, endDate, callback)
    MySQL.query([[
        SELECT
            citizenid,
            COUNT(CASE WHEN JSON_EXTRACT(data, '$.action') = 'start' THEN 1 END) as shifts,
            SUM(CASE WHEN JSON_EXTRACT(data, '$.action') = 'end' THEN JSON_EXTRACT(data, '$.duration') ELSE 0 END) as total_time,
            MIN(created_at) as first_duty,
            MAX(created_at) as last_duty
        FROM fl_emergency_data
        WHERE type = 'duty'
            AND service = ?
            AND created_at BETWEEN ? AND ?
        GROUP BY citizenid
        ORDER BY total_time DESC
    ]], { service, startDate, endDate }, function(result)
        callback(result or {})
    end)
end

-- Generiere Call-Report
function FL.Database.GenerateCallReport(service, startDate, endDate, callback)
    MySQL.query([[
        SELECT
            JSON_EXTRACT(data, '$.type') as call_type,
            JSON_EXTRACT(data, '$.priority') as priority,
            COUNT(*) as total_calls,
            AVG(JSON_EXTRACT(data, '$.response_time')) as avg_response_time,
            COUNT(CASE WHEN JSON_EXTRACT(data, '$.status') = 'completed' THEN 1 END) as completed_calls
        FROM fl_emergency_data
        WHERE type = 'call'
            AND service = ?
            AND created_at BETWEEN ? AND ?
        GROUP BY JSON_EXTRACT(data, '$.type'), JSON_EXTRACT(data, '$.priority')
        ORDER BY total_calls DESC
    ]], { service, startDate, endDate }, function(result)
        callback(result or {})
    end)
end

-- ================================
-- 🔄 BACKGROUND TASKS
-- ================================

-- Starte Cleanup-Task
CreateThread(function()
    while true do
        Wait(Config.Database.cleanupInterval * 1000)
        FL.Database.CleanupExpiredData()
    end
end)

-- Backup wichtiger Daten (täglich)
CreateThread(function()
    while true do
        Wait(86400000) -- 24 Stunden

        -- Erstelle tägliches Statistik-Backup
        for service, _ in pairs(Config.Services) do
            FL.Database.GetServiceStats(service, 1, function(stats)
                if #stats > 0 then
                    FL.Database.SaveStats(service, stats[1])
                end
            end)
        end

        if Config.Debug then
            print('^2[FL Database]^7 Daily backup completed')
        end
    end
end)

-- ================================
-- 📤 EXPORT FUNCTIONS
-- ================================

-- Exportiere Database Functions für andere Resources
exports('GetPlayerDutyStats', function(citizenid, callback)
    FL.Database.GetPlayerDutyStats(citizenid, callback)
end)

exports('GetServiceStats', function(service, days, callback)
    FL.Database.GetServiceStats(service, days or 7, callback)
end)

exports('GetActiveCalls', function(service, callback)
    FL.Database.GetActiveCalls(service, callback)
end)

exports('SaveCustomData', function(citizenid, type, service, data)
    MySQL.insert([[
        INSERT INTO fl_emergency_data (citizenid, type, service, data)
        VALUES (?, ?, ?, ?)
    ]], { citizenid, type, service, json.encode(data) })
end)
