if Config.dispatchScript == "lb-tablet" then
    function sendDispatchAlert(title, message, blipData)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        local streetHash, crossingHash = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        local streetName = GetStreetNameFromHashKey(streetHash)
        local crossingName = crossingHash and crossingHash ~= 0 and GetStreetNameFromHashKey(crossingHash) or nil

        local label = streetName or "Unknown location"
        if crossingName and crossingName ~= "" then
            label = ("%s / %s"):format(label, crossingName)
        end

        blipData = blipData or {}
        local sprite = blipData.sprite or 161
        local color  = blipData.color  or 1

        local dispatchData = {
            priority = "medium",
            code = "DrugSelling",
            title = title,
            description = message,
            location = {
                label = label,
                coords = vector3(pos.x, pos.y, pos.z) 
            },
            time = 300,
            job = "police",
            blip = {
                sprite = sprite,
                label = title,
                color = color
            }
        }

        local ok, err = pcall(function()
            exports["lb-tablet"]:AddDispatch(dispatchData)
        end)

        if not ok then
            print(("[op-drugselling] lb-tablet AddDispatch error: %s"):format(tostring(err)))
        end
    end
end
