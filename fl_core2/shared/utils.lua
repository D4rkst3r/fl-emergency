-- ================================
-- 🔧 FL EMERGENCY - UTILITY FUNCTIONS
-- ================================

FL.Utils = {}

-- ================================
-- 📝 LOGGING SYSTEM
-- ================================

FL.Utils.Log = {}

-- Log-Level Definitionen
FL.Utils.Log.Levels = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5
}

-- Log-Level Namen
FL.Utils.Log.LevelNames = {
    [1] = 'DEBUG',
    [2] = 'INFO',
    [3] = 'WARN',
    [4] = 'ERROR',
    [5] = 'FATAL'
}

-- Log-Level Farben
FL.Utils.Log.LevelColors = {
    [1] = '^5', -- Magenta
    [2] = '^2', -- Grün
    [3] = '^3', -- Gelb
    [4] = '^1', -- Rot
    [5] = '^9'  -- Dunkelrot
}

-- Haupt-Log-Funktion
function FL.Utils.Log.Write(level, message, data, source)
    if not Config.Logging.enabled then return end

    local configLevel = FL.Utils.Log.Levels[string.upper(Config.Logging.level)] or FL.Utils.Log.Levels.INFO
    if level < configLevel then return end

    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local levelName = FL.Utils.Log.LevelNames[level] or 'UNKNOWN'
    local levelColor = FL.Utils.Log.LevelColors[level] or '^7'

    -- Console Output
    local consoleMessage = string.format(
        '%s[FL Emergency]^7 [%s%s^7] %s',
        levelColor,
        levelColor,
        levelName,
        message
    )

    if data then
        consoleMessage = consoleMessage .. ' | Data: ' .. json.encode(data)
    end

    print(consoleMessage)

    -- Database Logging (Server-side only)
    if IsDuplicityVersion() then
        if level >= FL.Utils.Log.Levels.WARN or Config.Logging.level == 'debug' then
            MySQL.insert('INSERT INTO fl_emergency_data (citizenid, type, service, data) VALUES (?, ?, ?, ?)', {
                source or 'system',
                'log',
                'system',
                json.encode({
                    level = levelName,
                    message = message,
                    data = data,
                    timestamp = timestamp,
                    source = source
                })
            })
        end
    end

    -- Discord Webhook (Server-side only)
    if IsDuplicityVersion() and Config.Logging.discordWebhook and Config.Logging.webhookURL then
        if level >= FL.Utils.Log.Levels.ERROR then
            FL.Utils.Log.SendDiscordLog(levelName, message, data, timestamp)
        end
    end
end

-- Convenience Functions
function FL.Utils.Log.Debug(message, data, source)
    FL.Utils.Log.Write(FL.Utils.Log.Levels.DEBUG, message, data, source)
end

function FL.Utils.Log.Info(message, data, source)
    FL.Utils.Log.Write(FL.Utils.Log.Levels.INFO, message, data, source)
end

function FL.Utils.Log.Warn(message, data, source)
    FL.Utils.Log.Write(FL.Utils.Log.Levels.WARN, message, data, source)
end

function FL.Utils.Log.Error(message, data, source)
    FL.Utils.Log.Write(FL.Utils.Log.Levels.ERROR, message, data, source)
end

function FL.Utils.Log.Fatal(message, data, source)
    FL.Utils.Log.Write(FL.Utils.Log.Levels.FATAL, message, data, source)
end

-- Discord Webhook Function (Server-side only)
function FL.Utils.Log.SendDiscordLog(level, message, data, timestamp)
    if not IsDuplicityVersion() then return end

    local embed = {
        {
            title = 'FL Emergency - ' .. level,
            description = message,
            color = level == 'ERROR' and 15158332 or 16776960, -- Red or Yellow
            fields = {
                {
                    name = 'Timestamp',
                    value = timestamp,
                    inline = true
                },
                {
                    name = 'Resource',
                    value = GetCurrentResourceName(),
                    inline = true
                }
            },
            footer = {
                text = 'FL Emergency Services',
                icon_url = 'https://cdn.discordapp.com/icons/your-icon.png'
            }
        }
    }

    if data then
        table.insert(embed[1].fields, {
            name = 'Data',
            value = '```json\n' .. json.encode(data, { indent = true }) .. '\n```',
            inline = false
        })
    end

    PerformHttpRequest(Config.Logging.webhookURL, function(err, text, headers) end, 'POST', json.encode({
        username = 'FL Emergency',
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- ================================
-- 🔧 STRING UTILITIES
-- ================================

FL.Utils.String = {}

-- Trim whitespace
function FL.Utils.String.Trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Split string by delimiter
function FL.Utils.String.Split(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- Check if string starts with prefix
function FL.Utils.String.StartsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

-- Check if string ends with suffix
function FL.Utils.String.EndsWith(str, suffix)
    return str:sub(- #suffix) == suffix
end

-- Escape special characters for pattern matching
function FL.Utils.String.EscapePattern(str)
    return str:gsub("([^%w])", "%%%1")
end

-- Generate random string
function FL.Utils.String.Random(length, chars)
    chars = chars or 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    local result = ''
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

-- Format string with placeholders
function FL.Utils.String.Format(str, ...)
    local args = { ... }
    return str:gsub('%%s', function()
        return table.remove(args, 1)
    end)
end

-- Convert to title case
function FL.Utils.String.ToTitleCase(str)
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

-- ================================
-- 🔢 MATH UTILITIES
-- ================================

FL.Utils.Math = {}

-- Round number to specified decimal places
function FL.Utils.Math.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Clamp number between min and max
function FL.Utils.Math.Clamp(num, min, max)
    return math.min(math.max(num, min), max)
end

-- Linear interpolation
function FL.Utils.Math.Lerp(a, b, t)
    return a + (b - a) * t
end

-- Distance between two points
function FL.Utils.Math.Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

-- Distance between two vectors
function FL.Utils.Math.VectorDistance(v1, v2)
    return #(v1 - v2)
end

-- Generate random float between min and max
function FL.Utils.Math.RandomFloat(min, max)
    return min + (max - min) * math.random()
end

-- Check if number is within range
function FL.Utils.Math.InRange(num, min, max)
    return num >= min and num <= max
end

-- ================================
-- 📅 TIME UTILITIES
-- ================================

FL.Utils.Time = {}

-- Get current timestamp
function FL.Utils.Time.Now()
    return os.time()
end

-- Format timestamp to readable string
function FL.Utils.Time.Format(timestamp, format)
    format = format or '%Y-%m-%d %H:%M:%S'
    return os.date(format, timestamp)
end

-- Get time difference in seconds
function FL.Utils.Time.Diff(start, finish)
    finish = finish or os.time()
    return finish - start
end

-- Format duration in human readable format
function FL.Utils.Time.FormatDuration(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format('%d:%02d:%02d', hours, minutes, secs)
    else
        return string.format('%02d:%02d', minutes, secs)
    end
end

-- Get time ago string
function FL.Utils.Time.TimeAgo(timestamp)
    local diff = os.time() - timestamp

    if diff < 60 then
        return 'Gerade eben'
    elseif diff < 3600 then
        return string.format('vor %d Minuten', math.floor(diff / 60))
    elseif diff < 86400 then
        return string.format('vor %d Stunden', math.floor(diff / 3600))
    else
        return string.format('vor %d Tagen', math.floor(diff / 86400))
    end
end

-- Check if time is within range
function FL.Utils.Time.IsWithinRange(timestamp, rangeStart, rangeEnd)
    return timestamp >= rangeStart and timestamp <= rangeEnd
end

-- Get start of day timestamp
function FL.Utils.Time.StartOfDay(timestamp)
    timestamp = timestamp or os.time()
    local date = os.date('*t', timestamp)
    date.hour = 0
    date.min = 0
    date.sec = 0
    return os.time(date)
end

-- ================================
-- 🔍 TABLE UTILITIES
-- ================================

FL.Utils.Table = {}

-- Deep copy table
function FL.Utils.Table.DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == 'table' then
            copy[k] = FL.Utils.Table.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Check if table is empty
function FL.Utils.Table.IsEmpty(tbl)
    return next(tbl) == nil
end

-- Get table size
function FL.Utils.Table.Size(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Merge two tables
function FL.Utils.Table.Merge(t1, t2)
    local result = FL.Utils.Table.DeepCopy(t1)
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

-- Check if table contains value
function FL.Utils.Table.Contains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Get table keys
function FL.Utils.Table.Keys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

-- Get table values
function FL.Utils.Table.Values(tbl)
    local values = {}
    for _, v in pairs(tbl) do
        table.insert(values, v)
    end
    return values
end

-- Filter table by predicate
function FL.Utils.Table.Filter(tbl, predicate)
    local result = {}
    for k, v in pairs(tbl) do
        if predicate(v, k) then
            result[k] = v
        end
    end
    return result
end

-- Map table values
function FL.Utils.Table.Map(tbl, mapper)
    local result = {}
    for k, v in pairs(tbl) do
        result[k] = mapper(v, k)
    end
    return result
end

-- ================================
-- 🎯 VALIDATION UTILITIES
-- ================================

FL.Utils.Validate = {}

-- Check if value is valid coordinates
function FL.Utils.Validate.Coords(coords)
    if type(coords) ~= 'table' then return false end
    if not coords.x or not coords.y or not coords.z then return false end
    if type(coords.x) ~= 'number' or type(coords.y) ~= 'number' or type(coords.z) ~= 'number' then return false end
    return true
end

-- Check if value is valid citizenid
function FL.Utils.Validate.CitizenId(citizenid)
    if type(citizenid) ~= 'string' then return false end
    if #citizenid < 8 or #citizenid > 50 then return false end
    return true
end

-- Check if value is valid service
function FL.Utils.Validate.Service(service)
    return Config.Services[service] ~= nil
end

-- Check if value is valid call type
function FL.Utils.Validate.CallType(service, callType)
    if not FL.Utils.Validate.Service(service) then return false end
    return Config.Services[service].callTypes[callType] ~= nil
end

-- Check if value is valid priority
function FL.Utils.Validate.Priority(priority)
    return type(priority) == 'number' and priority >= 1 and priority <= 3
end

-- Check if value is valid vehicle model
function FL.Utils.Validate.VehicleModel(model)
    if type(model) ~= 'string' then return false end
    return IsModelInCdimage(GetHashKey(model))
end

-- ================================
-- 🔐 PERMISSION UTILITIES
-- ================================

FL.Utils.Permission = {}

-- Check if player has permission for service
function FL.Utils.Permission.HasService(source, service)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    local serviceData = Config.Services[service]
    if not serviceData then return false end

    return Player.PlayerData.job.name == serviceData.job
end

-- Check if player has minimum rank
function FL.Utils.Permission.HasRank(source, service, minRank)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    if not FL.Utils.Permission.HasService(source, service) then return false end

    return Player.PlayerData.job.grade.level >= minRank
end

-- Check if player is on duty
function FL.Utils.Permission.IsOnDuty(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    return Player.PlayerData.job.onduty
end

-- Check if player is admin
function FL.Utils.Permission.IsAdmin(source)
    if not source then return false end
    return QBCore.Functions.HasPermission(source, 'admin')
end

-- Check if player is in whitelist
function FL.Utils.Permission.IsWhitelisted(source, service)
    if not Config.Permissions.requireWhitelist then return true end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    -- Check database for whitelist entry
    local result = MySQL.Sync.fetchAll(
    'SELECT * FROM fl_emergency_whitelist WHERE citizenid = ? AND service = ? AND active = 1', {
        Player.PlayerData.citizenid,
        service
    })

    return #result > 0
end

-- ================================
-- 🌐 NETWORK UTILITIES
-- ================================

FL.Utils.Network = {}

-- Trigger event for all players in service
function FL.Utils.Network.TriggerService(service, event, data)
    if not IsDuplicityVersion() then return end

    local players = QBCore.Functions.GetPlayers()
    for _, playerId in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            local serviceData = Config.Services[service]
            if serviceData and Player.PlayerData.job.name == serviceData.job then
                TriggerClientEvent(event, playerId, data)
            end
        end
    end
end

-- Get player by citizenid
function FL.Utils.Network.GetPlayerByCitizenId(citizenid)
    if not IsDuplicityVersion() then return nil end

    local players = QBCore.Functions.GetPlayers()
    for _, playerId in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player and Player.PlayerData.citizenid == citizenid then
            return Player
        end
    end
    return nil
end

-- Get online players by service
function FL.Utils.Network.GetPlayersByService(service)
    if not IsDuplicityVersion() then return {} end

    local servicePlayers = {}
    local players = QBCore.Functions.GetPlayers()

    for _, playerId in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            local serviceData = Config.Services[service]
            if serviceData and Player.PlayerData.job.name == serviceData.job then
                table.insert(servicePlayers, {
                    source = playerId,
                    citizenid = Player.PlayerData.citizenid,
                    name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                    rank = Player.PlayerData.job.grade.level,
                    onDuty = Player.PlayerData.job.onduty
                })
            end
        end
    end

    return servicePlayers
end

-- ================================
-- 🎨 COLOR UTILITIES
-- ================================

FL.Utils.Color = {}

-- Convert hex to RGB
function FL.Utils.Color.HexToRgb(hex)
    hex = hex:gsub('#', '')
    return {
        r = tonumber(hex:sub(1, 2), 16),
        g = tonumber(hex:sub(3, 4), 16),
        b = tonumber(hex:sub(5, 6), 16)
    }
end

-- Convert RGB to hex
function FL.Utils.Color.RgbToHex(r, g, b)
    return string.format('#%02X%02X%02X', r, g, b)
end

-- Get service color
function FL.Utils.Color.GetServiceColor(service)
    return Config.Services[service] and Config.Services[service].color or '#3498db'
end

-- Get priority color
function FL.Utils.Color.GetPriorityColor(priority)
    return Config.Calls.priorityColors[priority] or '#95a5a6'
end

-- ================================
-- 🔄 INITIALIZATION
-- ================================

-- Initialize Utils (if needed)
function FL.Utils.Init()
    FL.Utils.Log.Info('FL Utils initialized', {
        version = Config.Version.current,
        timestamp = os.time()
    })
end

-- Export Utils for other resources
if IsDuplicityVersion() then
    exports('Utils', FL.Utils)
end

-- Initialize if Config is available
if Config then
    FL.Utils.Init()
end
