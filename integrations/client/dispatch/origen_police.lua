if Config.dispatchScript == "origen_police" then
    function sendDispatchAlert(title, message, blipData)
        local currentPos = GetEntityCoords(PlayerPedId())
        TriggerServerEvent("SendAlert:police", {
            coords = currentPos,
            title = title,
            type = 'GENERAL',
            message = message,
            job = 'police'
        })
    end
end