function LoadAnimDict(dict)
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
        Wait(10)
    end
    return HasAnimDictLoaded(dict)
end

function LoadModel(model)
    local hash = type(model) == "number" and model or GetHashKey(model)
    RequestModel(hash)
    local t = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(10) end
    return HasModelLoaded(hash), hash
end

function attachPropToRightHand(ped, obj)
    local bone = GetPedBoneIndex(ped, 57005)
    AttachEntityToEntity(
        obj, ped, bone,
        0.10, 0.02, -0.02,     
        0.0, 90.0, 10.0,      
        true,  true,  false, true, 1, true
    )
end

function ensureControl(entity, tries, waitMs)
    tries = tries or 15
    waitMs = waitMs or 50
    if not DoesEntityExist(entity) then return false end
    if not NetworkGetEntityIsNetworked(entity) then return true end
    local netId = NetworkGetNetworkIdFromEntity(entity)
    SetNetworkIdCanMigrate(netId, true)
    local i = 0
    while not NetworkHasControlOfEntity(entity) and i < tries do
        NetworkRequestControlOfEntity(entity)
        Wait(waitMs)
        i = i + 1
    end
    return NetworkHasControlOfEntity(entity)
end

function hardStopPed(ped)
    ClearPedTasksImmediately(ped)         
    ClearPedSecondaryTask(ped)
    SetPedKeepTask(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStandStill(ped, -1)              
end

function faceEntityHardLock(ped, target, timeout, tolDeg)
    timeout = timeout or 1800
    tolDeg = tolDeg or 8.0
    if not (DoesEntityExist(ped) and DoesEntityExist(target)) then return false end

    local pc = GetEntityCoords(ped)
    local tc = GetEntityCoords(target)
    local dx, dy = (tc.x - pc.x), (tc.y - pc.y)

    local desired = GetHeadingFromVector_2d(dx, dy)
    TaskAchieveHeading(ped, desired, timeout)
    local t = 0
    while t < timeout do
        local cur = GetEntityHeading(ped)
        local diff = math.abs(((cur - desired + 180.0) % 360.0) - 180.0) 
        if diff <= tolDeg then break end
        Wait(40)
        t = t + 40
    end
    SetEntityHeading(ped, desired)
    TaskStandStill(ped, 1000)

    return true
end

function faceEachOtherHard(playerPed, npc)
    ensureControl(npc, 20, 30)
    hardStopPed(npc)
    TaskTurnPedToFaceEntity(playerPed, npc, 1200)     
    faceEntityHardLock(npc, playerPed, 1600, 10.0)        
    TaskLookAtEntity(playerPed, npc, 10000, 2048, 3)
    TaskLookAtEntity(npc, playerPed, 10000, 2048, 3)
end

function startcam(entity)
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local forwardV = GetEntityForwardVector(entity)
    local pedCoords = GetEntityCoords(entity)
    pedCamCoords = vec3(pedCoords.x + (forwardV.x * 0.5), pedCoords.y + (forwardV.y * 0.5), pedCoords.z + 0.5)

    SetCamActive(cam, true)
    PointCamAtCoord(cam, pedCoords.x, pedCoords.y, pedCoords.z + 0.5)
    SetCamCoord(cam, pedCamCoords.x, pedCamCoords.y, pedCamCoords.z)
    SetCamFov(cam, 90.0)
    RenderScriptCams(true, true, 1000, true, true)
    isInCam = true
end

function endCam()
    SetCamActive(cam, false)
    RenderScriptCams(false, true, 1000, true, true)
    cam = nil
    pedCamCoords = nil
    isInCam = false
end