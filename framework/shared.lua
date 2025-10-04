Locales = {}

Citizen.CreateThread(function()

    function trim(s)
        if s then
         return (s:gsub("^%s*(.-)%s*$", "%1"))
        else
            return nil
        end
    end

    TranslateIt = function(...)
        return Translate(...)
    end

    function Translate(str, ...) -- Translate string
        if not str then
            print(("[^1ERROR^7] Resource ^5%s^7 You did not specify a parameter for the Translate function or the value is nil!"):format(GetInvokingResource() or GetCurrentResourceName()))
            return "Given translate function parameter is nil!"
        end
        local loc = string.lower(Config.Locale)
        if Locales[loc] then
            if Locales[loc][str] then
                return string.format(Locales[loc][str], ...)
            elseif loc ~= "en" and Locales["en"] and Locales["en"][str] then
                return string.format(Locales["en"][str], ...)
            else
                return "Translation [" .. loc .. "][" .. str .. "] does not exist"
            end
        elseif loc ~= "en" and Locales["en"] and Locales["en"][str] then
            return string.format(Locales["en"][str], ...)
        else
            return "Locale [" .. loc .. "] does not exist"
        end
    end

    function levelFromExp(exp)
        return 1 + math.floor((exp or 0) / Config.Leveling.LevelEXP)
    end

    function debugPrint(...)
        if not Config.Debug then return end
        local args <const> = { ... }

        local appendStr = ''
        for _, v in ipairs(args) do
            appendStr = appendStr .. ' ' .. tostring(v)
        end
        local msgTemplate = '^3[debuglog]^0%s'
        local finalMsg = msgTemplate:format(appendStr)
        print(finalMsg)
    end

    function GetLevelBoost(level)
        if not level or level < 1 then return 0 end
        if Config.Leveling.LevelsList[level] then
            return Config.Leveling.LevelsList[level]
        end
        local max = 0
        for _, boost in pairs(Config.Leveling.LevelsList) do
            if boost > max then
                max = boost
            end
        end
        return max
    end

end)