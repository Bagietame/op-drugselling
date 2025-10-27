if Config.dispatchScript == "ps-dispatch" then

    function sendDispatchAlert(title, message, blipData)
        local currentPos = GetEntityCoords(PlayerPedId())
        local streetHash = GetStreetNameAtCoord(currentPos)
        local locationInfo = GetStreetNameFromHashKey(streetHash)
        local gender = GetPedGender()
        TriggerServerEvent("dispatch:server:notify",{
            dispatchcodename = "bankrobbery", -- has to match the codes in sv_dispatchcodes.lua so that it generates the right blip
            dispatchCode = "10-90",
            firstStreet = locationInfo,
            gender = gender,
            camId = camId,
            model = nil,
            plate = nil,
            priority = 2, -- priority
            firstColor = nil,
            automaticGunfire = false,
            origin = {
                x = currentPos.x,
                y = currentPos.y,
                z = currentPos.z
            },
            dispatchMessage = message, -- message
            job = {"police"} -- jobs that will get the alerts
        })
    end
end