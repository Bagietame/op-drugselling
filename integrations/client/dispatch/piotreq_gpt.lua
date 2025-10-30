if Config.dispatchScript == "piotreq_gpt" then
    function sendDispatchAlert(title, message, blipData)
        TriggerServerEvent('op-drugselling:piotreqgptalert', title, blipData)
    end
end