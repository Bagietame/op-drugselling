if Config.dispatchScript == "cd_dispatch" then

    function sendDispatchAlert(title, message, blipData)
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = {'police', }, 
            coords = data.coords,
            title = title,
            message = message, 
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = blipData.sprite, 
                scale = 1.2, 
                colour = blipData.color,
                flashes = false, 
                text = title,
                time = 5,
                radius = 0,
            }
        })
    end
end