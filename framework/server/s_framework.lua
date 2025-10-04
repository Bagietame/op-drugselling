Framework = nil
Fr = {}
ESX = GetResourceState('es_extended') == 'started' and true or false
QBCore = GetResourceState('qb-core') == 'started' and true or false
QBox = GetResourceState('qbx_core') == 'started' and true or false

Citizen.CreateThread(function()
    if ESX then
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
    elseif QBCore or QBox then
        Framework = exports['qb-core']:GetCoreObject()

        Fr.usersTable = "players"
        Fr.identificatorTable = "citizenid"
        Fr.PlayerLoaded = 'QBCore:Client:OnPlayerLoaded'

        Fr.IsPlayerDead = function(source)
            local Player = Fr.getPlayerFromId(source)
            return Player.PlayerData.metadata["isdead"]
        end
        Fr.RegisterServerCallback = function(...)
            return Framework.Functions.CreateCallback(...)
        end
        Fr.getPlayerFromId = function(...)
            return Framework.Functions.GetPlayer(...)
        end
        Fr.ManageDirtyMoney = function(Player, action, amount)
            if action == "add" then
                return Player.Functions.AddItem(Config.DirtyMoney.itemName, amount)
            else
                return Player.Functions.RemoveItem(Config.DirtyMoney.itemName, amount)
            end
        end
        Fr.GetIndentifier = function(source)
            local xPlayer = Fr.getPlayerFromId(source)
            return xPlayer.PlayerData.citizenid
        end
        Fr.addItem = function(xPlayer, itemname, quantity)
            return xPlayer.Functions.AddItem(itemname, quantity)
        end
        Fr.removeItem = function(xPlayer, itemname, quantity)
            return xPlayer.Functions.RemoveItem(itemname, quantity)
        end
        Fr.getItem = function(xPlayer, itemname)
            local item = xPlayer.Functions.GetItemByName(itemname)
            local table
            if item then
                table = {amount = item.amount, name = itemname, weight = item.weight, label = item.label}
            else 
                table = {amount = 0, name = itemname, weight = 0, label = ""}
            end
            return table
        end
        Fr.getInventory = function(xPlayer)
            return xPlayer.PlayerData.items
        end
    end
end)