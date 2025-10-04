if Config.dispatchScript == "rcore_dispatch" then

    function sendDispatchAlert(title, message, blipData)
        local playerData = exports['rcore_dispatch']:GetPlayerData()

        local alertData = {
            code = '10-64',                    -- Alert code
            default_priority = 'medium',       -- 'low', 'medium', or 'high'
            coords = playerData.coords,        -- Alert location
            job = 'police',                    -- Job(s) to receive alert (string or table)
            text = message,     -- Alert description
            type = 'alerts',                   -- Alert type for statistics
            blip_time = 5,                     -- Optional: Blip fade time (seconds)
            image = 'url_to_image.jpg',        -- Optional: Image URL
            custom_sound = 'url_to_sound.mp3', -- Optional: Custom sound URL
            blip = {                           -- Optional: Custom blip settings
                sprite = blipData.sprite,
                colour = blipData.color,
                scale = 0.7,
                text = title,
                flashes = false,
                radius = 0,
            }
        }

        TriggerServerEvent('rcore_dispatch:server:sendAlert', alertData)
    end
end