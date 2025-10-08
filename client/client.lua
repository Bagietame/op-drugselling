isDrugDealing = false
dealingPed = nil
isPedAtPoint = false
cam = nil
pedCamCoords = nil
isInCam = nil
isUiLanguageLoaded = false
pedType = "normal"
stolenTarget = nil

local playerLVL = nil

local isOnCooldown = false
local movementDisabled = false
local soldPedsList = {}
local maleNames = {
    "Michael", "James", "John", "Robert", "David",
    "William", "Joseph", "Thomas", "Charles", "Daniel",
    "Matthew", "Anthony", "Mark", "Paul", "Steven"
}
local femaleNames = {
    "Mary", "Patricia", "Jennifer", "Linda", "Elizabeth",
    "Barbara", "Susan", "Jessica", "Sarah", "Karen",
    "Nancy", "Lisa", "Margaret", "Sandra", "Ashley"
}

Citizen.CreateThread(function()
    while not isUiLanguageLoaded do
        Wait(0)
        local loc = string.lower(Config.Locale)
        SendNUIMessage({
            action = "setLanguage",
            data = {locale = Locales[loc]}
        })
        SendNUIMessage({
            action = "setCurrency",
            data = {
                currency = Config.CurrencySettings.currency,
                style = Config.CurrencySettings.style,
                format = Config.CurrencySettings.format,
            }
        })
    end
end)

Citizen.CreateThread(function()
    while Framework == nil do Wait(5) end

    local scriptName = GetCurrentResourceName()
    if scriptName ~= "op-drugselling" then return print('[OTHERPLANET.DEV] Required resource name: op-drugselling (needed for proper functionality)') end

    if Config.LevelCommand then
        TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.LevelCommand), TranslateIt('level_command_helper'), {})
    end

    ----
    -- ADDING GLOBAL TARGETS:
    ----

    addGlobalPeds("global_peds_drugselling", 1.7, TranslateIt('target_selldrug_icon'), TranslateIt('target_selldrug'), function(entity)
        dealingPed = entity
        sellDrugMenu(entity)
    end, function(entity) 
        if isDrugDealing and dealingPed ~= entity then return false end
        local pedModel = GetEntityModel(entity)
        if Config.BlackListPeds[pedModel] then return end
        local inventoryItems = ScriptFunctions.GetInventoryDrugs()
        if #inventoryItems < 1 then return false end
        if soldPedsList[entity] then return false end
        return IsEntityAPed(entity) and not IsPedAPlayer(entity) and not IsPedInAnyVehicle(entity, false) and not IsPedDeadOrDying(entity, true) and not IsPedInCombat(entity, PlayerPedId())
    end)

    ----
    -- SELL DRUGS MENU:
    ----

    function getLVL(cb)
        if not playerLVL then 
            Fr.TriggerServerCallback('op-drugselling:getlvl', function(reslvl)
                playerLVL = resExp
                cb(reslvl)
            end)
        else 
            cb(playerLVL) 
        end
    end

    function sellDrugMenu(entity)
        soldPedsList[entity] = true
        local playerPed = PlayerPedId()
        local pedModel = GetEntityModel(entity)
        pedType = "normal"

        if Config.PedsList[pedModel] then
            pedType = Config.PedsList[pedModel]
        end
        local pedCfg = Config.PedTypes[pedType]

        if math.random(100) <= pedCfg.refuseChance then
            if not Config.dispatchScript == "none" and pedCfg.dispatchCall then
                sendDispatchAlert(TranslateIt('drugdeal_dispatch_title'), TranslateIt('drugdeal_dispatch_message'), Config.DrugSelling.blipData)
            end

            stopDealFunc()
            if isDrugDealing then
                Citizen.CreateThread(function()
                    Wait(Config.CornerDealing.SellTimeout * 1000)
                    getNextDealing()
                end)
            end

            return sendNotify(TranslateIt('notify_refuse_2'), "error", 5)
        end

        getLVL(function(lvl)
            local inventoryItems = ScriptFunctions.GetInventoryDrugs()
            
            if not pedCfg then return print('Config for Ped Type not found!', pedType) end

            local pedGenderObj = IsPedMale(entity) and maleNames or femaleNames
            local pedName = pedGenderObj[math.random(1, #pedGenderObj)]
            local nuiData = {
                pedType = pedCfg.label,
                pedBorder = pedCfg.colors.border,
                pedBg = pedCfg.colors.background,
                playerLevel = lvl,
                playerBoost = GetLevelBoost(lvl),
                playerDrugs = inventoryItems,
                pedName = pedName
            }

            local dict = "missfbi3_party_b"
            if not LoadAnimDict(dict) then
                return debugPrint("Unable to load anim dict:", dict)
            end

            ClearPedTasks(entity)
            SetBlockingOfNonTemporaryEvents(entity, true)
            hardStopPed(entity) 
            faceEachOtherHard(playerPed, entity)

            TaskStandStill(entity, -1)
            TaskPlayAnim(entity, dict, "talk_inside_loop_male1", 8.0, -8.0, -1, 49, 0.0, false, false, false)
            TaskPlayAnim(playerPed, dict, "talk_inside_loop_male1", 8.0, -8.0, -1, 49, 0.0, false, false, false)

            startcam(entity)
            SetNuiFocus(true, true)
            SendNUIMessage({ action = "setDrugDealingData", data = nuiData })
            SendNUIMessage({ action = "setDrugSellingVisible", data = true })
        end)
    end

    ----
    -- Function Triggered by NUI:
    ----

    function sellDrugForPedFinalize(drug_name, price)
        local isdead = Fr.isDead()
        if isdead then 
            isDrugDealing = false
            return stopDealFunc()
        end

        endCam()
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = "setDrugSellingVisible",
            data = false
        })
        local drugCfg = Config.DrugSelling.availableDrugs[drug_name]
        if not drugCfg then return print('[op-drugselling] Missing drug config:', drug_name) end

        Fr.TriggerServerCallback('op-drugselling:sellDrug', function(sold)
            if not sold then 
                return print('An server-side error occured. Check txAdmin Console.')
            end

            local pedCfg = Config.PedTypes[pedType]
            if math.random(100) <= Config.DrugSelling.dispatchCallChance and not Config.dispatchScript == "none" and pedCfg.dispatchCall then
                sendDispatchAlert(TranslateIt('drugdeal_dispatch_title'), TranslateIt('drugdeal_dispatch_message'), Config.DrugSelling.blipData)
            end

            if sold.sold then
                soldPedsList[dealingPed] = true
                movementDisabled = true
                CreateThread(function()
                    while movementDisabled do
                        DisableControlAction(0, 30, true) 
                        DisableControlAction(0, 31, true) 
                        DisableControlAction(0, 32, true) 
                        DisableControlAction(0, 33, true) 
                        DisableControlAction(0, 34, true)
                        DisableControlAction(0, 35, true) 
                        DisableControlAction(0, 21, true) 
                        DisableControlAction(0, 22, true) 
                        DisableControlAction(0, 36, true) 
                        Wait(0)
                    end
                end)

                playerLVL = sold.newLevel
                FaceEachOtherAndPlayGive(dealingPed, drugCfg.handPropName)
                if not sold.isRivalry then 
                    --sendNotify(TranslateIt('notify_success', sold.amount, sold.label, sold.price), "success", 5)
                else
                    --sendNotify(TranslateIt('notify_success_2', sold.amount, sold.label, sold.price), "success", 5)
                end

                if sold.zoneOwner then 
                    --sendNotify(TranslateIt('notify_zoneowner'), "info", 5)
                end
                
                movementDisabled = false

                local dumpPed = dealingPed
                Citizen.CreateThread(function()
                    Wait(25 * 1000)
                    DeletePed(dumpPed)
                end)
            elseif sold.steal then
                ClearPedTasks(PlayerPedId())

                addTargetTypedEntity("ped_drug_stolen", 2.0, TranslateIt('target_getdrugs_icon'), TranslateIt('target_getdrugs'), function(deleteData)
                    TriggerServerEvent('op-drugselling:getBackDrugs')
                    removeTargetEntity(deleteData)
                end, dealingPed)

                MakePedRunAway()
                sendNotify(TranslateIt('notify_steal'), "error", 5)
            elseif sold.refused then
                local dumpPed = dealingPed
                stopDealFunc()
                sendNotify(TranslateIt('notify_refuse'), "error", 5)
                Citizen.CreateThread(function()
                    Wait(25 * 1000)
                    DeletePed(dumpPed)
                end)
            end

            if isDrugDealing then
                Citizen.CreateThread(function()
                    Wait(Config.CornerDealing.SellTimeout * 1000)
                    getNextDealing()
                end)
            end
        end, drug_name, price, pedType, isDrugDealing)
    end

    ----
    -- Corner Selling Command:
    ----

    if Config.CornerDealing.Enable then
        debugPrint("Registering drug selling command:", Config.CornerDealing.Command)

        RegisterNetEvent('op-drugselling:startDealingCorner', function()
            if isOnCooldown then
                return sendNotify(TranslateIt('drugDealing_wait'), "error", 5)
            end

            if not isDrugDealing then
                isDrugDealing = true
                sendNotify(TranslateIt('drugdeal_started_notify'), "info", 5)
                getNextDealing()
            else
                isDrugDealing = false
                
                stopDealFunc()
                DeletePed(dealingPed)

                dealingPed = nil
                sendNotify(TranslateIt('ended_drugdealing'), "info", 5)
                isOnCooldown = true
                
                local timeouttime = Config.CornerDealing.SellTimeout * 1000
                SetTimeout(timeouttime + 2000, function()
                    isOnCooldown = false
                end)
            end
        end)

        TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.CornerDealing.Command), TranslateIt('drugsell_command_help'), {})

        RegisterCommand(Config.CornerDealing.Command, function()
            TriggerEvent('op-drugselling:startDealingCorner')
        end)

        function getNextDealing()
            if not isDrugDealing then return end
            isPedAtPoint = false
            dealingPed = SpawnRandomPedAndApproach(20.0, 30.0, 1.0, 1.45)
            sendNotify(TranslateIt('ped_heading_notify'), "success", 5)
        end
    end

    ----
    -- Run with Drugs Function:
    ----

    function MakePedRunAway()
        local playerPed = PlayerPedId()
        local ped = dealingPed
        if not DoesEntityExist(ped) or IsEntityDead(ped) then return end

        SetEntityAsMissionEntity(ped, true, false)       
        ClearPedTasksImmediately(ped)
        ClearPedSecondaryTask(ped)
        TaskSetBlockingOfNonTemporaryEvents(ped, false) 
        SetBlockingOfNonTemporaryEvents(ped, false)

        SetPedCombatAttributes(ped, 46, false)           
        SetPedFleeAttributes(ped, 0, false)             
        SetPedSeeingRange(ped, 80.0)
        SetPedHearingRange(ped, 80.0)
        SetPedAlertness(ped, 3)

        SetPedKeepTask(ped, true)
        SetPedMaxMoveBlendRatio(ped, 3.0)                
        SetPedDesiredMoveBlendRatio(ped, 3.0)

        local ply = GetPlayerPed(-1)
        local plyCoords = GetEntityCoords(playerPed)
        TaskReactAndFleePed(ped, playerPed)
        SetTimeout(500, function()
            if DoesEntityExist(ped) then
                TaskSmartFleePed(ped, playerPed, 120.0, -1, true, false)
            end
        end)
    end

    ----
    -- Stop Dealing Function:
    ----

    function stopDealFunc()
        if dealingPed then 
            FreezeEntityPosition(dealingPed, false)
            TaskClearLookAt(dealingPed)
            ClearPedTasksImmediately(dealingPed)
            SetBlockingOfNonTemporaryEvents(dealingPed, false)
            TaskWanderStandard(dealingPed, 10.0, 10)
        end
        ClearPedTasks(PlayerPedId())
    end

    ----
    -- Give Drugs Animation:
    ----

    function FaceEachOtherAndPlayGive(targetPed, propName)
        if not DoesEntityExist(targetPed) then
            return debugPrint("FaceEachOtherAndPlayGive: targetPed does not exist")
        end

        local playerDuration = 2000
        local npcDuration = 2000
        local playerPed = PlayerPedId()
        local dict = "mp_common"

        if not LoadAnimDict(dict) then
            return debugPrint("Unable to load anim dict:", dict)
        end
        TaskPlayAnim(targetPed, dict, "givetake2_a", 8.0, -8.0, npcDuration, 49, 0.0, false, false, false)
        TaskPlayAnim(playerPed, dict, "givetake1_b", 8.0, -8.0, playerDuration, 49, 0.0, false, false, false)

        local ok, propHash = LoadModel(propName)
        if not ok then
            return debugPrint("Couldn't load prop:", propName)
        end

        local prop = CreateObject(propHash, 0.0, 0.0, 0.0, true, true, false)
        SetEntityCollision(prop, false, true)
        attachPropToRightHand(playerPed, prop)

        local half = math.floor(math.min(playerDuration, npcDuration) / 2)
        CreateThread(function()
            Wait(half)
            if DoesEntityExist(prop) and DoesEntityExist(targetPed) then
                attachPropToRightHand(targetPed, prop)
            end
        end)
        SetModelAsNoLongerNeeded(propHash)
        
        Wait(2300)
        DeleteEntity(prop)
        PlayPedAmbientSpeechNative(targetPed, "GENERIC_THANKS", "SPEECH_PARAMS_FORCE")
        TaskClearLookAt(targetPed)
        ClearPedTasks(targetPed)
        SetBlockingOfNonTemporaryEvents(targetPed, false)
        TaskWanderStandard(targetPed, 10.0, 10)
    end

    ----
    -- Ped Spawning In Corner Mode:
    ----

    local function randFloat(min, max)
        return min + math.random() * (max - min)
    end

    local function findSafeSpawnNear(px, py, pz, minDist, maxDist, attempts)
        attempts = attempts or 12
        for i = 1, attempts do
            local angle = math.random() * math.pi * 2
            local dist = randFloat(minDist, maxDist)
            local tx = px + math.cos(angle) * dist
            local ty = py + math.sin(angle) * dist
            local tz = pz
            local found, safePos = GetSafeCoordForPed(tx, ty, tz, true, 16)
            if found and safePos then
                return safePos.x, safePos.y, safePos.z
            end
        end
        local angle = math.random() * math.pi * 2
        local dist  = randFloat(minDist, maxDist)
        return px + math.cos(angle) * dist, py + math.sin(angle) * dist, pz
    end

    function SpawnRandomPedAndApproach(minDist, maxDist, walkSpeed, stopRange)
        local models = {"a_f_m_fatwhite_01", "a_f_m_soucentmc_01", "a_m_m_afriamer_01", "a_m_m_bevhills_02", "a_m_m_eastsa_01", "a_m_m_polynesian_01", "a_m_m_trampbeac_01", "a_m_y_beachvesp_01", "a_m_y_clubcust_01", "a_m_y_epsilon_02", "a_m_y_vinewood_01", "a_m_y_vinewood_02", "cs_dom", "cs_manuel"}
        minDist = minDist or 3.0
        maxDist = maxDist or 7.0
        walkSpeed = walkSpeed or 1.0
        stopRange = stopRange or 0.7
        local playerPed = PlayerPedId()
        local px, py, pz = table.unpack(GetEntityCoords(playerPed))
        local sx, sy, sz = findSafeSpawnNear(px, py, pz, minDist, maxDist, 16)

        local modelName = models[math.random(1, #models)]
        local model = GetHashKey(modelName)

        if not IsModelInCdimage(model) then
            return debugPrint(("Model %s does not exist in cdimage"):format(modelName))
        end

        RequestModel(model)
        local t = GetGameTimer() + 7000
        while not HasModelLoaded(model) and GetGameTimer() < t do
            Wait(10)
        end
        if not HasModelLoaded(model) then
            return debugPrint("Error during model load", modelName)
        end

        local ped = CreatePed(4, model, sx, sy, sz, 0.0, true, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCanRagdoll(ped, false)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 46, true)
        SetPedSeeingRange(ped, 0.0)
        SetPedHearingRange(ped, 0.0)
        TaskFollowToOffsetOfEntity(ped, playerPed, 0.0, 0.0, 0.0, walkSpeed, -1, stopRange, true)
        TaskLookAtEntity(ped, playerPed, 10000, 2048, 3)

        CreateThread(function()
            local arrived = false
            local lastReissue = 0
            while DoesEntityExist(ped) and not arrived do
                local pcoords = GetEntityCoords(playerPed)
                local ecoords = GetEntityCoords(ped)
                local dist = #(pcoords - ecoords)

                if not arrived then
                    if dist > (stopRange + 0.5) then
                        if GetGameTimer() - lastReissue > 2000 then
                            TaskFollowToOffsetOfEntity(ped, playerPed, 0.0, 0.0, 0.0, walkSpeed, -1, stopRange, true)
                            lastReissue = GetGameTimer()
                        end
                    else
                        arrived = true
                        isPedAtPoint = true
                        ClearPedTasks(ped)
                        TaskStandStill(ped, -1)                           
                        TaskTurnPedToFaceEntity(ped, playerPed, 800)      
                        TaskLookAtEntity(ped, playerPed, -1, 2048, 3)
                    end
                end
                Wait(300)
            end
        end)
        SetModelAsNoLongerNeeded(model)
        return ped
    end
end)