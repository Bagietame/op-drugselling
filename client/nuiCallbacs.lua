RegisterNuiCallback('hideFrame', function(_, cb)
    endCam()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "setDrugSellingVisible",
        data = false
    })

    if dealingPed then 
        TaskClearLookAt(dealingPed)
        ClearPedTasks(dealingPed)
        SetBlockingOfNonTemporaryEvents(dealingPed, false)
        TaskWanderStandard(dealingPed, 10.0, 10)
    end
    ClearPedTasks(PlayerPedId())

    if isDrugDealing then
        Citizen.CreateThread(function()
            Wait(Config.CornerDealing.SellTimeout * 1000)
            getNextDealing()
        end)
    end

    cb(true)
end)

RegisterNUICallback('languageConfirmation', function(_, cb)
    cb(true)
    isUiLanguageLoaded = true
end)

RegisterNUICallback('drugSell', function(data, cb)
    cb(true)
    sellDrugForPedFinalize(data.name, data.price)
end)