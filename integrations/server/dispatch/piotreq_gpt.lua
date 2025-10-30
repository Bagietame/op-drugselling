local cooldowns = {}

RegisterNetEvent('op-drugselling:piotreqgptalert', function(title, blip)
    local src = source
    local currentTime = os.time()

    if cooldowns[src] and (currentTime - cooldowns[src]) < 20 then
        local remaining = 20 - (currentTime - cooldowns[src])
        print(("Player %s tried to trigger alert too soon (%ds left)"):format(src, remaining))
        return
    end

    cooldowns[src] = currentTime

    exports['piotreq_gpt']:SendAlert(src, {
        title = title,
        code = '10-70',
        icon = 'fa-solid fa-mask',
        info = {
            {icon = 'fa-solid fa-road', isStreet = true},
            {icon = 'fa-solid fa-triangle-exclamation', data = 'Very Danger'},
        },
        blip = {
            scale = 1.1,
            sprite = blip.sprite,
            category = 3,
            color = blip.color,
            hidden = false,
            priority = 5,
            short = true,
            alpha = 200,
            name = title
        },
        type = 'risk',
        canAnswer = true,
        maxOfficers = 6,
        time = 10,
        notifyTime = 8000,
    })
end)
