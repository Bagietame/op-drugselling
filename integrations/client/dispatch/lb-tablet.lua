if Config.dispatchScript == "lb-tablet" then
    function sendDispatchAlert(title, message, blipData)
        local currentPos = GetEntityCoords(PlayerPedId())
        local streetHash = GetStreetNameAtCoord(currentPos)
        local locationInfo = GetStreetNameFromHashKey(streetHash)

        local dispatchData = {
            priority = "medium",
            code = "DrugSelling",
            title = title,
            description = message,
            location = {
                label = locationInfo,
                coords = vector2(currentPos.x, currentPos.y)
            },
            time = 300,
            job = "police",
            blip = {
                sprite = blipData.sprite,
                label = title,
                color = blipData.color
            }
        }
        local dispatchId = exports["lb-tablet"]:AddDispatch(dispatchData)
    end
end