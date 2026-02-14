if Config.dispatchScript == "ps-dispatch" then

    function sendDispatchAlert(title, message, blipData)
        exports['ps-dispatch']:DrugSale()
    end
end