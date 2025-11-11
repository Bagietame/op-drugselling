stolenDrugs = {}
playersEXP = {}

while Framework == nil do Wait(5) end

if Config.LevelCommand then
    RegisterCommand(Config.LevelCommand, function(source)
        if not playersEXP[tostring(source)] then
            loadPlayerBySrc(source)
        end

        local lvl = levelFromExp(playersEXP[tostring(source)].exp)
        local boost = GetLevelBoost(lvl)

        TriggerClientEvent('op-drugselling:sendNotify', source, TranslateIt('level_command', lvl, boost .. "%"), "info", 5)
    end)
end

RegisterServerEvent('op-drugselling:getBackDrugs', function()
    local drugsCf = stolenDrugs[tostring(source)]
    if drugsCf then
        local xPlayer = Fr.getPlayerFromId(source)
        Fr.addItem(xPlayer, drugsCf.drugName, drugsCf.amount)
        stolenDrugs[tostring(source)] = nil
    end
end)

-- Helper:
local function adjustSellChanceByPrice(baseChance, pricePerGram, cfgDrug)
    local minP = cfgDrug.minimumPrice or 0
    local optP = cfgDrug.optimalPrice or pricePerGram or 0
    local maxP = cfgDrug.maximumPrice or (optP > 0 and optP * 2 or 100)

    local influence = (cfgDrug.priceInfluence or 30) * 0.5  

    if optP <= minP then minP = math.max(0, optP - 1) end
    if maxP <= optP then maxP = optP + 1 end

    local factor = 0.0
    if pricePerGram and pricePerGram < optP then
        factor = math.min(1.0, (optP - pricePerGram) / (optP - minP))
    elseif pricePerGram and pricePerGram > optP then
        factor = -math.min(1.0, (pricePerGram - optP) / (maxP - optP))
    else
        factor = 0.0
    end

    local adjusted = baseChance + (factor * influence)
    return math.max(0, math.min(100, adjusted))
end

Fr.RegisterServerCallback('op-drugselling:getlvl', function(source, cb)
    if not playersEXP[tostring(source)] then
        loadPlayerBySrc(source)
    end

    local lvl = levelFromExp(playersEXP[tostring(source)].exp)
    return cb(lvl)
end)

Fr.RegisterServerCallback('op-drugselling:sellDrug', function(source, cb, drugName, pricePerGram, pedType, cornerSelling)
    local xPlayer = Fr.getPlayerFromId(source)
    if not xPlayer then return cb(false) end

    local hasItem = Fr.getItem(xPlayer, drugName)
    if not (hasItem and hasItem.amount and hasItem.amount > 0) then
        print('[op-drugselling] Player doenst have items inside inventory')
        print(json.encode(hasItem))
        print("drugName", drugName)
        return cb(false)
    end

    local cfgDrug = Config.DrugSelling.availableDrugs[drugName]
    if not cfgDrug then
        print('[op-drugselling] Missing drug config:', drugName)
        return cb(false)
    end

    local cfgPed = Config.PedTypes[pedType]
    if not cfgPed then
        print('[op-drugselling] Missing pedType config:', pedType)
        return cb(false)
    end

    local maxPerPed = cfgDrug.maxAmountPedTransaction or 1
    local maxCanSell = math.max(1, math.min(hasItem.amount, maxPerPed))
    local amountSell = math.random(1, maxCanSell)

    if not playersEXP[tostring(source)] then
        loadPlayerBySrc(source)
    end
    local playerLevel = levelFromExp(playersEXP[tostring(source)].exp)

    local multiplier = 1.0 + (GetLevelBoost(playerLevel) / 100.0)
    local finalPrice = math.floor((pricePerGram or 0) * amountSell * multiplier)

    local sellChance, stealChance, refuseChance

    if cornerSelling then
        sellChance  = 80
        stealChance = 20
        refuseChance = 0
    else
        local baseSell = math.max(0, math.min(100, cfgPed.buyChance or 0))
        sellChance  = adjustSellChanceByPrice(baseSell, pricePerGram or cfgDrug.optimalPrice, cfgDrug)
        stealChance = math.max(0, math.min(100, cfgPed.stealDrugChance or 0))
        refuseChance = math.max(0, 100 - (sellChance + stealChance))
    end

    local roll = math.random(1, 100)
    local stealBandEnd = stealChance
    local sellBandEnd  = stealBandEnd + sellChance

    if roll <= stealBandEnd then
        Fr.removeItem(xPlayer, drugName, amountSell)
        stolenDrugs[tostring(source)] = {
            amount = amountSell,
            drugName = drugName, 
        }
        return cb({ steal = true, amount = amountSell })
    elseif roll <= sellBandEnd then
        local label = (cfgDrug.label or drugName)

        local isRivalry = false
        local zoneOwner = false
        if Config.AdditionalScripts.op_Gangs then
            local turfId = exports['op-crime']:getPlayerTurfZone(source)
            if turfId then 
                isRivalry = exports['op-crime']:isTurfZoneInRivalry(turfId)
                zoneOwner = exports['op-crime']:isPlayerTurfOwner(source, turfId)
                TriggerEvent('op-crime:drugSold', source, turfId, finalPrice)

                if isRivalry then 
                    finalPrice = finalPrice / 2
                end

                if zoneOwner then 
                    finalPrice = finalPrice * 1.1
                end
            end
        end
        playersEXP[tostring(source)].exp = playersEXP[tostring(source)].exp + cfgPed.saleEXP 
        playersEXP[tostring(source)].changed = true
        local newLevel = levelFromExp(playersEXP[tostring(source)].exp)

        finalPrice = math.floor(finalPrice)

        Fr.removeItem(xPlayer, drugName, amountSell)
        Fr.ManageDirtyMoney(xPlayer, "add", finalPrice)

        local ident = Fr.GetIndentifier(source)
        local message = formatWebHook("**Drug Name:**", drugName or "None", "\n**Price per gram:**", pricePerGram, "\n**Player Identificator:**", ident, "\n**Price:**", finalPrice, "\n**Corner Selling:**", cornerSelling and "True" or "False")
        SendWebHook("DRUG SOLD", 706333, message)

        return cb({
            sold = true,
            label = label,
            amount = amountSell,
            price = finalPrice,
            newLevel = newLevel,
            isRivalry = isRivalry,
            zoneOwner = zoneOwner
        })
    else
        return cb({ refused = true })
    end
end)

function loadPlayerBySrc(source)
    local ident = Fr.GetIndentifier(source)
    local row = MySQL.single.await('SELECT expdrugs FROM `'.. Fr.usersTable ..'` WHERE `'.. Fr.identificatorTable ..'` = ?', {ident})
    
    if row then 
        playersEXP[tostring(source)] = {
            exp = row.expdrugs,
            changed = false
        }
        return playersEXP[tostring(source)]
    else
        playersEXP[tostring(source)] = {
            exp = 0,
            changed = false
        }
        return playersEXP[tostring(source)]
    end
end

function SavePlayerXP(src)
    local ident = Fr.GetIndentifier(tonumber(src))
    if not ident then return end

    local st = playersEXP[tostring(src)]
    if not st then return end

    MySQL.update.await([[
        UPDATE `]] .. Fr.usersTable .. [[`
        SET expdrugs = ?
        WHERE `]] .. Fr.identificatorTable .. [[` = ?
    ]], { st.exp, ident })

    playersEXP[tostring(src)].changed = false
end

CreateThread(function()
    while true do
        Wait(120000)
        for src, st in pairs(playersEXP) do
            if st.changed then 
                SavePlayerXP(src) 
                debugPrint('Saved Player:', src)
            else
                debugPrint('Skipping', src, json.encode(st))      
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = tostring(source)
    if playersEXP[src] and playersEXP[src].changed then 
        SavePlayerXP(source)
        playersEXP[src] = nil
        debugPrint('Saved Player:', src)
    end
end)