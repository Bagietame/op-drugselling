function ensureColumnExists(tableName, columnName, columnDefinition)
    local result = MySQL.query.await([[
        SELECT COUNT(*) AS columnExists
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @tableName AND COLUMN_NAME = @columnName
    ]], {['@tableName'] = tableName, ['@columnName'] = columnName})

    if result[1].columnExists == 0 then
        local success, errorMsg = pcall(function()
            MySQL.execute("ALTER TABLE " .. tableName .. " ADD COLUMN " .. columnName .. " " .. columnDefinition)
        end)
        
        if not success then
            print("^1[Auto-SQL] Error during adding column: ^0" .. errorMsg)
        else 
            print("^2[Auto-SQL] Successfully created missing column: " .. columnName)
        end
        
    end
end

MySQL.ready(function()
    local scriptName = GetCurrentResourceName()
    if scriptName ~= "op-drugselling" then return print('[OTHERPLANET.DEV] Required resource name: op-drugselling (needed for proper functionality)') end
    
    local attempts = 100
    while Framework == nil do 
        Wait(1000) 
        attempts = attempts - 1
        if attempts == 50 then
            print("[FRAMEWORK] Still waiting... attempts left: " .. attempts)
        end

        if attempts <= 0 then
            return print('[FRAMEWORK ISSUE] Unable to load framework properly, please check framework files.')
        end
    end

    local columnsCheck = {
        {table = Fr.usersTable, name = "expdrugs", def = "int(250) NOT NULL DEFAULT '0'"}
    }
    for _, column in ipairs(columnsCheck) do
        ensureColumnExists(column.table, column.name, column.def)
    end
end)

function formatWebHook(...)
    local args <const> = { ... }

    local appendStr = ''
    for _, v in ipairs(args) do
        appendStr = appendStr .. ' ' .. tostring(v)
    end
    return appendStr
end

function SendWebHook(title, color, message)
    local embedMsg = {}
    timestamp = os.date("%c")
    embedMsg = {
        {
            ["color"] = color,
            ["title"] = title,
            ["description"] =  message,
            ["footer"] ={
                ["text"] = timestamp.." (Server Time).",
            },
        }
    }
    PerformHttpRequest(ServerConfig.LogsWebhook,
    function(err, text, headers)end, 'POST', json.encode({username = "OP DRUGSELLING", embeds = embedMsg}), { ['Content-Type']= 'application/json' })
end