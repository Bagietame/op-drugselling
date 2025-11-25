-- op-drugselling/integrations/client/dispatch/kartik-mdt.lua
-- Direct Kartik-MDT integration for drug selling alerts

if Config.dispatchScript ~= "kartik-mdt" then return end

local function getStreetAndZone(coords)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = GetStreetNameFromHashKey(streetHash)
    local crossing = crossingHash ~= 0 and GetStreetNameFromHashKey(crossingHash) or nil

    local zone = GetNameOfZone(coords.x, coords.y, coords.z)
    local zoneLabel = GetLabelText(zone)

    local location
    if crossing then
        location = ("%s & %s (%s)"):format(street, crossing, zoneLabel)
    else
        location = ("%s (%s)"):format(street, zoneLabel)
    end

    return location
end

local function normalizeCoords(arg)
    if not arg then
        return GetEntityCoords(PlayerPedId())
    end

    -- If it’s already a vector3 / vector4
    if type(arg) == "vector3" or type(arg) == "vector4" then
        return vector3(arg.x, arg.y, arg.z)
    end

    -- If they passed a table with x, y, z
    if type(arg) == "table" and arg.x and arg.y and arg.z then
        return vector3(arg.x, arg.y, arg.z)
    end

    -- Fallback
    return GetEntityCoords(PlayerPedId())
end

-- This is what op-drugselling calls
-- title, message, coords/blipData (varies by integration)
function sendDispatchAlert(title, message, coordsData)
    if GetResourceState("kartik-mdt") ~= "started" then
        print("^3[op-drugselling] Kartik-MDT not started, skipping dispatch^0")
        return
    end

    local coords = normalizeCoords(coordsData)
    local location = getStreetAndZone(coords)

    title = title or "Drug Dealing In Progress"
    message = message or "Possible drug dealing reported in the area"

    local alertData = {
        title       = title,
        description = message,
        location    = location,

        -- where the call is
        x = coords.x,
        y = coords.y,
        z = coords.z,

        -- who gets it
        jobs = {
            police = true,
            sheriff = true,
            sasp = true,
        },

        type = "Alert",

        -- 🔴 SEARCH RADIUS BLIP (not exact pin)
        blip = {
            radius = 75.0,    -- how big the circle is
            sprite = 161,     -- circle sprite
            color  = 1,       -- red
            scale  = 1.0,
            length = 5,       -- how long the blip stays (minutes, per Kartik docs)
        },

        sound = "dispatch",  -- uses Kartik’s dispatch sound
    }

    -- Send to Kartik-MDT
    exports["kartik-mdt"]:CustomAlert(alertData)
    print(("[op-drugselling] Kartik-MDT alert sent: %s @ %s"):format(title, location))
end
