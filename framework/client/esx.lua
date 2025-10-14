ESX = GetResourceState('es_extended') == 'started' and true or false

if not ESX then return end

Framework = exports["es_extended"]:getSharedObject()
Fr.PlayerLoaded = 'esx:playerLoaded'
Fr.identificatorTable = "identifier"

Fr.TriggerServerCallback = function(...)
    return Framework.TriggerServerCallback(...)
end
Fr.GetVehicleProperties = function(vehicle) 
    return Framework.Game.GetVehicleProperties(vehicle)
end
Fr.DeleteVehicle = function(vehicle)
    return Framework.Game.DeleteVehicle(vehicle)
end
Fr.SetVehicleProperties = function(...) 
    return Framework.Game.SetVehicleProperties(...)
end
Fr.GetPlayerData = function()
    return Framework.GetPlayerData()
end
Fr.isDead = function()
    local playerData = Fr.GetPlayerData()
    return playerData.dead
end