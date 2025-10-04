if Config.dispatchScript == "codem_dispatch" then

    function sendDispatchAlert(title, message, blipData)
        local Type = 'DrugDealing'

        local Data = {
            type = Type,
            header = title,
            text = message,
            code = Config.DispatchTypes[Type] and Config.DispatchTypes['DrugDealing'].code or "Unknown",
        }

        exports['codem-dispatch']:CustomDispatch(Data)
    end
end