-- ================================
-- 🔧 FL EMERGENCY - TARGET COMPATIBILITY (FIXED)
-- ================================

-- Initialize FL.Target safely
if not FL then FL = {} end
FL.Target = FL.Target or {}

FL.Target.System = nil
FL.Target.Available = false

-- ================================
-- 🎯 TARGET SYSTEM DETECTION
-- ================================

function FL.Target.DetectSystem()
    -- Prüfe ox_target
    if GetResourceState('ox_target') == 'started' then
        FL.Target.System = 'ox_target'
        FL.Target.Available = true
        if Config.Debug then print('^2[FL Target]^7 Using ox_target') end
        return true
    end

    -- Prüfe qb-target
    if GetResourceState('qb-target') == 'started' then
        FL.Target.System = 'qb_target'
        FL.Target.Available = true
        if Config.Debug then print('^2[FL Target]^7 Using qb-target') end
        return true
    end

    -- Prüfe qtarget
    if GetResourceState('qtarget') == 'started' then
        FL.Target.System = 'qtarget'
        FL.Target.Available = true
        if Config.Debug then print('^2[FL Target]^7 Using qtarget') end
        return true
    end

    FL.Target.Available = false
    print('^1[FL Error]^7 No compatible target system found!')
    return false
end

-- ================================
-- 🎯 UNIFIED TARGET FUNCTIONS
-- ================================

-- Add Box Zone
function FL.Target.AddBoxZone(data)
    if not FL.Target.Available then
        if Config.Debug then print('^3[FL Target]^7 No target system available, skipping zone creation') end
        return
    end

    if FL.Target.System == 'ox_target' then
        exports.ox_target:addBoxZone(data)
    elseif FL.Target.System == 'qb_target' then
        -- Konvertiere ox_target format zu qb-target format
        local options = {}
        for _, option in pairs(data.options) do
            table.insert(options, {
                type = "client",
                event = "fl:target:option",
                icon = option.icon,
                label = option.label,
                job = option.groups and option.groups or nil,
                action = option.onSelect
            })
        end

        exports['qb-target']:AddBoxZone("fl_" .. GetGameTimer(), data.coords, data.size.x, data.size.y, {
            name = "fl_" .. GetGameTimer(),
            heading = data.rotation or 0,
            debugPoly = Config.Debug,
            minZ = data.coords.z - (data.size.z / 2),
            maxZ = data.coords.z + (data.size.z / 2),
        }, {
            options = options,
            distance = 2.0
        })
    end
end

-- Add Sphere Zone
function FL.Target.AddSphereZone(data)
    if not FL.Target.Available then return end

    if FL.Target.System == 'ox_target' then
        exports.ox_target:addSphereZone(data)
    elseif FL.Target.System == 'qb_target' then
        local options = {}
        for _, option in pairs(data.options) do
            table.insert(options, {
                type = "client",
                event = "fl:target:option",
                icon = option.icon,
                label = option.label,
                job = option.groups and option.groups or nil,
                action = option.onSelect
            })
        end

        exports['qb-target']:AddCircleZone("fl_sphere_" .. GetGameTimer(), data.coords, data.radius, {
            name = "fl_sphere_" .. GetGameTimer(),
            debugPoly = Config.Debug,
        }, {
            options = options,
            distance = 2.0
        })
    end
end

-- Remove Zone
function FL.Target.RemoveZone(zoneName)
    if not FL.Target.Available then return end

    if FL.Target.System == 'ox_target' then
        exports.ox_target:removeZone(zoneName)
    elseif FL.Target.System == 'qb_target' then
        exports['qb-target']:RemoveZone(zoneName)
    end
end

-- ================================
-- 🔄 INITIALIZATION
-- ================================

function FL.Target.Initialize()
    return FL.Target.DetectSystem()
end

-- Create Thread to initialize target system
CreateThread(function()
    -- Wait for FL to be initialized
    while not FL do
        Wait(100)
    end

    -- Initialize target system
    FL.Target.Initialize()

    -- Set up global functions
    FL.AddBoxZone = FL.Target.AddBoxZone
    FL.AddSphereZone = FL.Target.AddSphereZone
    FL.RemoveZone = FL.Target.RemoveZone

    if Config.Debug then
        print('^2[FL Compatibility]^7 Target compatibility system loaded')
    end
end)

-- ================================
-- 📡 TARGET EVENT HANDLER
-- ================================

RegisterNetEvent('fl:target:option', function(data)
    if data and data.action then
        data.action(data)
    end
end)
