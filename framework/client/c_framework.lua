Framework = nil
Fr = {}
ScriptFunctions = {}

Citizen.CreateThread(function()
    ESX = GetResourceState('es_extended') == 'started' and true or false
    QBCore = GetResourceState('qb-core') == 'started' and true or false
    QBox = GetResourceState('qbx_core') == 'started' and true or false

    if ESX then
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
    elseif QBCore or QBox then
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
    end

    local drugsCache = { data = nil, expiresAt = 0 }
    local cacheTime = 10000

    ScriptFunctions.GetInventoryDrugs = function()
        local playerData = Fr.GetPlayerData()
        local drugsList = {}

        local now = GetGameTimer() or 0
        if drugsCache.data and now < drugsCache.expiresAt then
            return drugsCache.data
        end
        
        if ESX then
            local items = playerData.inventory
            if not items then 
                return {} 
            end
            
            for k, v in pairs(items) do
                if v and Config.DrugSelling.availableDrugs[v.name] and v.count > 0 then
                    local drugInfo = Config.DrugSelling.availableDrugs[v.name]
                    table.insert(drugsList, {
                        icon = drugInfo.icon,
                        spawn_name = v.name,
                        label = drugInfo.label,
                        amount = v.count,
                        normalPrice = drugInfo.optimalPrice,
                        priceRangeMin = drugInfo.minimumPrice,
                        priceRangeMax = drugInfo.maximumPrice,
                    })
                end
            end
        elseif QBCore or QBox then
            local items = playerData.items
            if not items then 
                return {} 
            end
            
            for k, v in pairs(items) do
                if v and Config.DrugSelling.availableDrugs[v.name] and v.amount > 0 then
                    local drugInfo = Config.DrugSelling.availableDrugs[v.name]
                    table.insert(drugsList, {
                        icon = drugInfo.icon,
                        spawn_name = v.name,
                        label = drugInfo.label,
                        amount = v.amount,
                        normalPrice = drugInfo.optimalPrice,
                        priceRangeMin = drugInfo.minimumPrice,
                        priceRangeMax = drugInfo.maximumPrice,
                    })
                end
            end
        end

        drugsCache.data = drugsList
        drugsCache.expiresAt = now + cacheTime
        
        debugPrint("drugsList", json.encode(drugsList))
        return drugsList
    end
end)
