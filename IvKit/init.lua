if getgenv().IvKit then return print('IvKit') end
local init = os.clock()
local _getgenv = getgenv()
getgenv().IvKit = {
    HttpGet = function(url) return game:HttpGet(url) end,
    plr = game:GetService('Players').LocalPlayer,

    plrs = game:GetService('Players'),
    CoreGui = game:GetService('CoreGui'),
    Lighting = game:GetService('Lighting'),
    RunService = game:GetService('RunService'),
    HttpService = game:GetService('HttpService'),
    TweenService = game:GetService('TweenService'),
    SoundService = game:GetService('SoundService'),
    InputService = game:GetService('UserInputService'),
    TeleportService = game:GetService('TeleportService'),
    TextChatService = game:GetService('TextChatService'),
    CollectionService = game:GetService('CollectionService'),
    ReplicatedStorage = game:GetService('ReplicatedStorage'),
    MarketplaceService = game:GetService('MarketplaceService'),
    AvatarEditorService = game:GetService('AvatarEditorService'),
    VirtualInputManager = game:GetService('VirtualInputManager')
}

local players = {} --> Cache for Big-O
local _type, _typeof = type, typeof --> Default Functionality
local type = function(ref, typeValue, orValue) return not typeValue and _type(ref) or _type(ref) == typeValue or orValue and _type(ref) == orValue end
local typeof = function(ref, typeValue, orValue) return not typeValue and _typeof(ref) or _typeof(ref) == typeValue or orValue and _typeof(ref) == orValue end
local isMatch = function(ref, v1, v2, v3) return ref == v1 or ref == v2 or ref == v3 end

for x, v in IvKit.plrs:GetPlayers() do players[v.Name] = v end
IvKit.plrs.PlayerAdded:Connect(function(player) players[player.Name] = player end)
IvKit.plrs.PlayerRemoving:Connect(function(player)
    if players[player.Name] then
        players[player.Name] = nil
    end
end)

IvKit.IvLog = {emojis = true, live = true}
IvKit.IvLog.success = function(...) if not IvKit.IvLog.live then return end print(IvKit.IvLog.emojis and '✅' or '', '[IvLog] →', ...) end
IvKit.IvLog.error = function(...) if not IvKit.IvLog.live then return end print(IvKit.IvLog.emojis and '❌' or '', '[IvLog] →', ...) end
IvKit.IvLog.warn = function(...) if not IvKit.IvLog.live then return end print(IvKit.IvLog.emojis and '⚠️' or '', '[IvLog] →', ...) end
IvKit.IvLog.info = function(...) if not IvKit.IvLog.live then return end print(IvKit.IvLog.emojis and 'ℹ️' or '', '[IvLog] →', ...) end
IvKit.IvLog.unknown = function(...) if not IvKit.IvLog.live then return end print(IvKit.IvLog.emojis and '❔' or '', '[IvLog] →', ...) end

setreadonly(table, false)
table.size = function(tbl)
    if not type(tbl, 'table') then return end
    if #tbl > 0 then return #tbl end
    local n = 0
    for x in next, tbl do n += 1 end
    return n
end

table.purge = function(tbl)
    if not type(tbl, 'table') then return end
    local isHash = #tbl == 0

    if isHash then
        for x0 in tbl do
            tbl[x0] = nil
        end
    else
        table.clear(tbl)
    end
end

table.sample = function(tbl, n, noRep)
    if not (type(tbl, 'table')) then return end
    n = (type(n, 'number') and n > 1) and math.floor(n) or nil

    local isHash = #tbl == 0
    local temp = tbl

    if isHash then
        temp = {}
        for x0, v0 in tbl do
            table.insert(temp, v0)
        end
    end

    if #temp == 0 then return nil end

    if not n then
        return temp[math.random(1, #temp)]
    else
        local samples = {}
        n = math.min(n, #temp)
        while #samples < n do
            local val = temp[math.random(1, #temp)]
            if noRep then
                if not table.find(samples, val) then
                    table.insert(samples, val)
                end
            else
                table.insert(samples, val)
            end
        end
        return samples
    end
end

table.flat = function(tbl, deep)
    if not type(tbl, 'table') then return end
    local result = {}
    local function flatten(t)
        for _, v in pairs(t) do
            if deep and type(v, 'table') then
                flatten(v)
            else
                table.insert(result, v)
            end
        end
    end

    flatten(tbl)
    return result
end

table.invoke = function(tbl, callback)
    if #tbl == 0 then return end
    for x, v in tbl do
        callback(v)
    end
end

setreadonly(table, true)

IvKit.type, IvKit.typeof, IvKit.isMatch = type, typeof, isMatch
IvKit.GetObjects = function(asset) return game:GetObjects(`rbxassetid://{asset}`)[1] end
IvKit.JSON = function(method, data) return isMatch(method, 'enc', 'encode', 'Encode') and IvKit.HttpService:JSONEncode(data) or IvKit.HttpService:JSONDecode(data) end
IvKit.GetPlayers = function(exclude)
    if not exclude then return players end
    local result = {}
    local isList = typeof(exclude, 'table')

    for x, v in next, players do
        local a = not exclude
        local b = isList and table.find(exclude, x)
        local c = not isList and x ~= exclude

        if a or b or c then
            result[#result + 1] = v
        end
    end

    return result
end

IvKit.GetPlayer = function(query, caller)
    if not type(query, 'string') then return nil end
    local O1 = players[query]
    if O1 then return O1 end

    if query:lower() == 'me' then return caller or IvKit.plr end
    if query:lower() == 'random' then return table.sample(players) end
    if query:lower() == 'others' then
        local new = {}
        for x, v in next, players do
            if v ~= (caller or IvKit.plr) then
                table.insert(new, v)
            end
        end
        return new
    end

    query = query:lower()
    for x, v in next, players do
        local name, display = x:lower(), v.DisplayName:lower()

        if name:sub(1, #query) == query or display:sub(1, #query) == query then
            return v
        end
    end
    return nil
end

IvKit.randomString = function(length)
    length = tonumber(length) or 5

    local randomized = ''
    for i = 1, length do
        local byte = math.random(48, 122)
        if (byte >= 48 and byte <= 57) or (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) then
            randomized ..= string.char(byte)
        end
    end
    return randomized
end

local sharedSignals = {}
IvKit.SignalRegistry = function(token)
    if token and sharedSignals[token] then return sharedSignals[token] end
    local connections, actions = {}, {}
    actions.getConnection = function(entry)
        if not (type(entry, 'string', 'number') or typeof(entry, 'RBXScriptConnection')) then return nil end
        if connections[entry] then return connections[entry] end

        --> fallback
        if typeof(entry, 'RBXScriptConnection') then
            for x, v in connections do
                if v.listener == entry then
                    return v
                end
            end
        end

        return nil
    end

    actions.clear = function()
        for x, v in connections do
            v.listener:Disconnect()
            connections[x] = nil
        end
    end

    actions.suspend = function(id)
        local connection = actions.getConnection(id)
        if not connection then return end
        connections[connection.key].suspended = true
    end

    actions.resume = function(id)
        local connection = actions.getConnection(id)
        if not connection then return end
        connections[connection.key].suspended = false
    end

    actions.count = function()
        local n = 0
        for x in connections do
            n += 1
        end
        return n
    end

    actions.connect = function(id, signal, callback, ...)
        if not (id and signal and callback) or actions.getConnection(id) then return end
        local tI_arP = ...
        connections[id] = {
            key = id,
            suspended = false,
            event = signal,
            callback = callback,
            listener = signal:Connect(function(...)
                if connections[id].suspended then return end
                callback(..., tI_arP)
            end)
        }
    end

    actions.disconnect = function(id)
        local connection = actions.getConnection(id)
        if not connection then return end
        connection.listener:Disconnect()
        connections[connection.key] = nil
    end

    actions.untilThen = function(signal, callback, condition, onTimeout, ...)
        local conditionType = typeof(condition)
        local extraArgs = { ... }
        local listener

        listener = signal:Connect(function(...)
            if conditionType == 'function' then
                local ran, valid = pcall(condition, ...)
                if ran and valid then
                    listener:Disconnect()
                    listener = nil
                    return
                end
            end

            if callback and callback(...) then
                listener:Disconnect()
                listener = nil
            end

            if not condition then
                listener:Disconnect()
                listener = nil
            end
        end)

        if conditionType == 'RBXScriptSignal' then
            local temp
            temp = condition:Connect(function()
                if listener then
                    listener:Disconnect()
                    listener = nil
                end
                temp:Disconnect()
            end)

        elseif conditionType == 'number' then
            task.delay(condition, function()
                if listener then
                    listener:Disconnect()
                    listener = nil
                end
                if onTimeout then
                    pcall(onTimeout, table.unpack(extraArgs))
                end
            end)
        end
    end

    if token and not sharedSignals[token] then sharedSignals[token] = connections end
    return setmetatable(connections, {__index = actions})
end

IvKit.fileSys = {}
IvKit.fileSys.save = function(path, name, data)
    if not writefile then return warn(`Failed to Save Data [{name}] : Executor not Supported`) end
    writefile(`{path}/{name}`, data)
end

IvKit.fileSys.read = function(path, name)
    if not (isfile and readfile) then warn(`Failed to Read Data [{name}] : Executor not Supported`) end
    return isfile(`{path}/{name}`) and readfile(`{path}/{name}`)
end

IvKit.fileSys.exist = function(path, method)
    if not (path and type(method, 'function')) then return false end
    return method(path)
end

IvKit.fileSys.loadAsset = function(path, url, delete, name)
    if not (path and (isfile(path) or url) and writefile and isfolder and makefolder and isfile and delfile and getcustomasset) then
        return 0, false
    end

    local fileName = type(name, "string") and name or IvKit.randomString(5, 10) .. ".png"
    local fullPath = isfile(path) and path or `{path}\\{fileName}`

    local CACHE_FILE
    if isfile(fullPath) then
        CACHE_FILE = getcustomasset(fullPath)
    else
        local success, response = pcall(Iv.HttpGet, url)
        if not (success and response) then
            return 0, false
        end

        writefile(fullPath, response)
        CACHE_FILE = getcustomasset(fullPath)

        task.delay(5, function()
            if delete then
                delfile(fullPath)
            end
        end)
    end

    return CACHE_FILE, true, fullPath
end

IvKit.benchmark = function(fn, ...)
    local start = os.clock()
    local results = {pcall(fn, ...)}
    local elapsed = os.clock() - start
    local success = table.remove(results, 1)
    return success and table.unpack(results), elapsed
end

IvKit.timeFmt = function(elapse)
    return (elapse < 0.001 and string.format('%.2fµs', elapse * 1e6))
        or (elapse < 1 and string.format('%.2fms', elapse * 1e3))
        or string.format('%.2fs', elapse)
end

setmetatable(getgenv().IvKit, {
    __index = function(_, key)
        return _getgenv[key]
    end
})

print('IvKit load time:', IvKit.timeFmt(os.clock() - init))