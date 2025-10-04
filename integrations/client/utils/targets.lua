------------------------------------------------------------------
-- TARGETS FUNCTIONS, YOU CAN CONNECT YOUR OWN SYSTEM TO THIS ----
------------------------------------------------------------------

function addGlobalPeds(name, size, icon, label, onselect, canInteract)
    if Config.Misc.AccessMethod == "ox-target" then
        exports.ox_target:addGlobalPed({{
            name = name,
            icon = icon,
            label = label,
            onSelect = function(data)
                onselect(data.entity)
            end,
            canInteract = function(ent)
                return canInteract(ent)
            end,
            distance = size,
        }})
    elseif Config.Misc.AccessMethod == "qb-target" then
        exports['qb-target']:AddGlobalPed({
            distance = size,
            options = {{
                num = 1,
                type = "client", 
                icon = icon,
                label = label,
                action = function(ent)
                    onselect(ent)
                end,
                canInteract = function(ent)
                    return canInteract(ent)
                end,
            }},
        })
    end
end

function removeTargetEntity(data)
    if Config.Misc.AccessMethod == "ox-target" then
        exports.ox_target:removeEntity(data.id)
    elseif Config.Misc.AccessMethod == "qb-target" then
        exports['qb-target']:RemoveTargetEntity(data.id, data.name)
    end
end

function addTargetTypedEntity(name, size, icon, label, onselect, entity)
    if Config.Misc.AccessMethod == "ox-target" then
        local networkId = NetworkGetNetworkIdFromEntity(entity)
        exports.ox_target:addEntity(networkId, {
            icon = icon,
            label = label,
            onSelect = function() onselect({name = name, id = networkId}) end
        })
        return {name = name, id = networkId}
    elseif Config.Misc.AccessMethod == "qb-target" then
        exports['qb-target']:AddTargetEntity(entity, {
            options = {
                {icon = icon, label = label, action = function()
                    onselect({name = label, id = entity})
                end}
            },
            distance = size
        })
        return {name = label, id = entity}
    end
end