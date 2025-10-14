QBCore = GetResourceState('qb-core') == 'started' and true or false

if not QBCore then return end

Framework = exports['qb-core']:GetCoreObject()
Fr.PlayerLoaded = 'QBCore:Client:OnPlayerLoaded'
Fr.identificatorTable = "citizenid"

Fr.TriggerServerCallback = function(...)
    return Framework.Functions.TriggerCallback(...)
end
Fr.GetVehicleProperties = function(vehicle) 
    return Framework.Functions.GetVehicleProperties(vehicle)
end
Fr.DeleteVehicle = function(vehicle)
    return Framework.Functions.DeleteVehicle(vehicle)
end
Fr.SetVehicleProperties = function(...) 
    return Framework.Functions.SetVehicleProperties(...)
end
Fr.GetPlayerData = function()
    return Framework.Functions.GetPlayerData()
end
Fr.isDead = function()
    local playerData = Fr.GetPlayerData()
    return playerData.metadata['isdead']
end