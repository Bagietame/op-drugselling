ESX = GetResourceState('es_extended') == 'started' and true or false

if not ESX then return end

Fr = {}
Framework = exports["es_extended"]:getSharedObject()
Fr.usersTable = "users"
Fr.identificatorTable = "identifier"
Fr.PlayerLoaded = 'esx:playerLoaded'

Fr.IsPlayerDead = function(source)
    return Player(source).state.isDead
end
Fr.RegisterServerCallback = function(...)
    return Framework.RegisterServerCallback(...)
end
Fr.getPlayerFromId = function(...)
    return Framework.GetPlayerFromId(...)
end
Fr.ManageDirtyMoney = function(xPlayer, action, amount)
    if action == "add" then
        return xPlayer.addAccountMoney("black_money", amount)
    else
        return xPlayer.removeAccountMoney("black_money", amount)
    end
end
Fr.GetIndentifier = function(source)
    local xPlayer = Fr.getPlayerFromId(source)
    if not xPlayer then return nil end
    return xPlayer.identifier
end
Fr.addItem = function(xPlayer, itemname, quantity)
    return xPlayer.addInventoryItem(itemname, quantity)
end
Fr.removeItem = function(xPlayer, itemname, quantity)
    return xPlayer.removeInventoryItem(itemname, quantity)
end
Fr.getItem = function(xPlayer, itemname)
    local item = xPlayer.getInventoryItem(itemname)
    local table
    if item then
        table = {amount = item.count, name = itemname, weight = item.weight, label = item.label}
    else 
        table = {amount = 0, name = itemname, weight = 0, label = ""}
    end
    return table
end
Fr.getInventory = function(xPlayer)
    return xPlayer.getInventory()
end