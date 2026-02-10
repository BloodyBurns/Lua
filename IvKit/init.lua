if not game:IsLoaded() then
    game.Loaded:Wait()
end

if getgenv().IvKit then return IvKit.IvLog.warn('IvKit already loaded') end
local init = os.clock()
local _getgenv = getgenv()
getgenv().IvKit = {
    HttpGet = function(url) return game:HttpGet(url) end,
    plrs = game:GetService('Players'),
    CoreGui = game:GetService('CoreGui'),
    Lighting = game:GetService('Lighting'),
    RunService = game:GetService('RunService'),
    HttpService = game:GetService('HttpService'),
    TweenService = game:GetService('TweenService'),
    SoundService = game:GetService('SoundService'),
    UserInputService = game:GetService('UserInputService'),
    TeleportService = game:GetService('TeleportService'),
    TextChatService = game:GetService('TextChatService'),
    CollectionService = game:GetService('CollectionService'),
    ReplicatedStorage = game:GetService('ReplicatedStorage'),
    MarketplaceService = game:GetService('MarketplaceService'),
    AvatarEditorService = game:GetService('AvatarEditorService'),
    VirtualInputManager = game:GetService('VirtualInputManager'),
	ContextActionService = game:GetService('ContextActionService')
}

IvKit.plr = IvKit.plrs.LocalPlayer

local players = {} --> Cache for Big-O
local _type, _typeof = type, typeof --> Default Functionality
local _pack = function(...) return {n = select('#', ...), ...} end
local _unpack = function(tbl) return table.unpack(tbl, 1, tbl.n) end
local isMatch = function(ref, ...) for x, v in {...} do if ref == v then return true end end return false end
local type = function(v, t, orT)
    local vt = _type(v)
    if not t then return vt end
    return vt == t or (orT and vt == orT) or false
end

local typeof = function(v, t, orT)
    local vt = _typeof(v)
    if not t then return vt end
    return vt == t or (orT and vt == orT) or false
end

local isArray = function(tbl)
	if not type(tbl, 'table') then return false end
	local keys, n = 0, #tbl
	for x in tbl do
		keys += 1
		if not type(x, 'number') or x < 1 or x > n or x % 1 ~= 0 then
			return false
		end
	end
	return true
end

local getKeysSorted = function(tbl)
	local sorted = {}
	for x in tbl do sorted[#sorted + 1] = x end
	table.sort(sorted, function(a, b)
        local ta, tb = typeof(a), typeof(b)
        if ta ~= tb then return ta < tb end
        return tostring(a) < tostring(b)
    end)
	return sorted
end

for x, v in IvKit.plrs:GetPlayers() do players[v.Name] = v end
IvKit.type, IvKit.typeof, IvKit.isMatch, IvKit._pack, IvKit._unpack = type, typeof, isMatch, _pack, _unpack
IvKit.plrs.PlayerAdded:Connect(function(player) players[player.Name] = player end)
IvKit.plrs.PlayerRemoving:Connect(function(player)
    if players[player.Name] then
        players[player.Name] = nil
    end
end)

IvKit.IvLog = IvKit.IvLog or {}
IvKit.IvLog.emojis = IvKit.IvLog.emojis ~= false
IvKit.IvLog.live = IvKit.IvLog.live ~= false
IvKit.IvLog.prettyTables = IvKit.IvLog.prettyTables ~= false
IvKit.IvLog.maxInline = IvKit.IvLog.maxInline or 3
IvKit.IvLog.sortKeys = IvKit.IvLog.sortKeys ~= false

local serialize; serialize = function(t, indent, stack, maxInline)
	indent = indent or 0
	stack = stack or {}
	maxInline = maxInline or IvKit.IvLog.maxInline

	if stack[t] then return '<self>' end
	stack[t] = true

	local keys, hasNested = 0, false
	for x, v in t do
		keys += 1
		if not hasNested and type(v, 'table') then
			hasNested = true
		end
	end

	local array = isArray(t)
	if keys == 0 then
		stack[t] = nil
		return '{}'
	end

	local output = function(output) stack[t] = nil return output end
	local valStr = function(v) return type(v, 'table') and serialize(v, indent + 1, stack, maxInline) or tostring(v) end

	if keys <= maxInline and not hasNested then
		local parts = {}
		if array then
			for i = 1, #t do parts[#parts + 1] = tostring(t[i]) end
			return output('{' .. table.concat(parts, ', ') .. '}')
		end

		if IvKit.IvLog.sortKeys then
			for x, v in ipairs(getKeysSorted(t)) do
				parts[#parts + 1] = tostring(v) .. ' = ' .. tostring(t[v])
			end
		else
			for x, v in t do
				parts[#parts + 1] = tostring(x) .. ' = ' .. tostring(v)
			end
		end

		return output('{' .. table.concat(parts, ', ') .. '}')
	end

	local spacing = string.rep('  ', indent)
	local result = { '{' }

	if array then
		for i = 1, #t do
			result[#result + 1] = spacing .. '  ' .. valStr(t[i]) .. ','
		end
	else
		if IvKit.IvLog.sortKeys then
			for x, v in ipairs(getKeysSorted(t)) do
				result[#result + 1] = spacing .. '  ' .. tostring(v) .. ' = ' .. valStr(t[v]) .. ','
			end
		else
			for x, v in t do
				result[#result + 1] = spacing .. '  ' .. tostring(x) .. ' = ' .. valStr(v) .. ','
			end
		end
	end

	result[#result + 1] = spacing .. '}'
	return output(table.concat(result, '\n'))
end

local log = function(prefix, emoji, ...)
	if not IvKit.IvLog.live then return end
	local args = { ... }
	for i = 1, #args do
		if IvKit.IvLog.prettyTables and type(args[i], 'table') then
			args[i] = serialize(args[i])
		end
	end

    print(`{IvKit.IvLog.emojis and (emoji .. ' ') or ''}[IvLog] →`, table.unpack(args))
end

IvKit.IvLog.success = function(...) log('success', '✅', ...) end
IvKit.IvLog.error = function(...) log('error', '❌', ...) end
IvKit.IvLog.warn = function(...) log('warn', '⚠️', ...) end
IvKit.IvLog.info = function(...) log('info', 'ℹ️', ...) end
IvKit.IvLog.unknown = function(...) log('unknown', '❔', ...) end
IvKit.IvLog.throw = function(err, context)
    local _src, lvl = IvKit._src, 2
    repeat
        local src = debug.info(lvl, 's')
        if not src or (src ~= '[C]' and src ~= _src) then break end
        lvl += 1
    until false

    error(context and `{IvKit.IvLog.emojis and ('💀 ') or ''}[IvLog] {context}\n→ {err}` or err, lvl)
end

--> lazy map over an Instance (children/descendants) or a table
local map = {}
map.__index = map

local reqInst = function(self, method)
    if self.mode == 'list' then
        error(`{method}() not valid for table sources`, 2)
    end
end

local push = function(self, fn)
    self.filters[#self.filters + 1] = fn
    return self
end

local getList = function(self)
    if self.mode == 'list' then return self.root end
    if self.mode == 'descendants' then return self.root:GetDescendants() end
    return self.root:GetChildren()
end

map.new = function(src)
    return setmetatable({
        root = src,
        mode = typeof(src, 'Instance') and 'children' or 'list',
        filters = {},
    }, map)
end

map.Children = function(self)
    reqInst(self, 'Children')
    self.mode = 'children'
    return self
end

map.Descendants = function(self)
    reqInst(self, 'Descendants')
    self.mode = 'descendants'
    return self
end

map._iter = function(self)
    local list = getList(self)
    local filters = self.filters
    local i = 0

    if (self.mode == 'list' and not isArray(list)) then
        local x, v
        return function()
            while true do
                x, v = next(list, x)
                if x == nil then return nil end

                local ok = true
                for z = 1, #filters do
                    if not filters[z](v, x) then
                        ok = false
                        break
                    end
                end

                if ok then
                    return v, x
                end
            end
        end
    end

    local n = #list
    return function()
        while true do
            i += 1
            if i > n then return nil end
            local v = list[i]

            for z = 1, #filters do
                if not filters[z](v) then
                    v = nil
                    break
                end
            end

            if v ~= nil then
                return v
            end
        end
    end
end

map.Where = function(self, fn)
    return push(self, fn)
end

map.IsA = function(self, className)
    reqInst(self, 'IsA')
    return push(self, function(instance) return instance:IsA(className) end)
end

map.Name = function(self, name)
    reqInst(self, 'Name')
    return push(self, function(instance) return instance.Name == name end)
end

map.Take = function(self, n)
    local left = n
    return push(self, function()
        if left <= 0 then return false end
        left -= 1
        return true
    end)
end

map.Skip = function(self, n)
    local left = n
    return push(self, function()
        if left > 0 then left -= 1 return false end
        return true
    end)
end

map.Invoke = function(self, fn)
    for x, v in self:_iter() do fn(x, v) end
end

map.ToTable = function(self)
    local result, n = {}, 0
    for x in self:_iter() do n += 1; result[n] = x end
    return result
end

map.Count = function(self)
    local n = 0
    for x in self:_iter() do n += 1 end
    return n
end

map.Set = function(self, key, valOrFn)
    reqInst(self, 'Set')
    local isFn = type(valOrFn, 'function')
    for instance in self:_iter() do
        instance[key] = isFn and valOrFn(instance) or valOrFn
    end
end

map.SetAttr = function(self, attr, valOrFn)
    reqInst(self, 'SetAttr')
    local isFn = type(valOrFn, 'function')
    for instance in self:_iter() do
        instance:SetAttribute(attr, isFn and valOrFn(instance) or valOrFn)
    end
end

map.Exclude = function(self, items)
    reqInst(self, 'Exclude')
    local set = {}

    if type(items, 'table') then
        for x, v in ipairs(items) do
            set[v] = true
        end
    else
        set[items] = true
    end

    return self:Where(function(x)
        return not set[x]
    end)
end

map.ExcludeBy = function(self, property, value)
    reqInst(self, 'ExcludeBy')
    if not type(property, 'string') then error('ExcludeBy(property, value): property must be string', 2) end

    local isList = type(value, 'table')
    local filter = {}

    if isList then
        for x, v in ipairs(value) do
            filter[v] = true
        end
    end

    return self:Where(function(instance)
        local ok, v = pcall(function() return instance[property] end)
        if not ok then return true end
        if isList then return not filter[v] end
        return v ~= value
    end)
end

map.Destroy = function(self)
    reqInst(self, 'Destroy')
    for instance in self:_iter() do instance:Destroy() end
end

setreadonly(table, false)
table.map = function(src)
    return map.new(src)
end

table.size = function(t)
    if not type(t, 'table') then return 0 end
    local n = 0
    for x in next, t do n += 1 end
    return n
end

table.purge = function(t)
    if not type(t, 'table') then return false end
    table.clear(t)
    return true
end

table.sample = function(t, n, noRep)
    if not type(t, 'table') then return nil end
    local arr = (#t > 0) and t or (function()
        local a = {}
        for x, v in next, t do a[#a+1] = v end
        return a
    end)()

    local len = #arr
    if len == 0 then return nil end
    if not n then return arr[math.random(len)] end
    n = math.min(math.floor(n), len)
    local result = {}

    if noRep then
        local used = {}
        while #result < n do
            local i = math.random(len)
            if not used[i] then
                used[i] = true
                result[#result+1] = arr[i]
            end
        end
    else
        for i = 1, n do
            result[i] = arr[math.random(len)]
        end
    end

    return result
end

table.flat = function(t, deep)
    if not type(t, 'table') then return nil end
    local result = {}

    local flatten; flatten = function(v)
        if deep and type(v, 'table') then
            for x, x in next, v do flatten(x) end
            return
        end
        result[#result + 1] = v
    end

    for x, v in next, t do flatten(v) end
    return result
end

table.invoke = function(t, fn, self, ...)
    if not type(t, 'table') or not type(fn, 'function') then return false end
    local callback = (self ~= nil) and function(v, k, ...) return fn(self, v, k, ...) end or function(v, k, ...) return fn(v, k, ...) end
    for x, v in next, t do callback(v, x, ...) end
    return true
end
setreadonly(table, true)

IvKit.GetObjects = function(asset) return game:GetObjects(`rbxassetid://{asset}`)[1] end
IvKit.GetPlayers = function(...)
	local result = {}
	local args = {...}
	local toExclude

	if #args > 0 then
		toExclude = {}
        for x, v in ipairs(args) do
			if typeof(v, 'Instance') and v:IsA('Player') then
				toExclude[v.Name] = true
			elseif type(v, 'string') then
				toExclude[v] = true
			end
		end
	end

	for x, v in players do
		if not toExclude or not toExclude[x] then
			result[#result + 1] = v
		end
	end

	return result
end

IvKit.GetPlayer = function(query, caller)
    if not type(query, 'string') then return nil end

    local me = caller or IvKit.plr
	local entry = query:lower()

	if entry == 'me' then return me end
	if entry == 'random' then return table.sample(players) end
	if entry == 'others' then
		local new = {}
		for x, v in next, players do
			if v ~= me then
				new[#new + 1] = v
			end
		end
		return new
	end

    local O1 = players[query] or players[entry]
    if O1 then return O1 end

    for x, v in next, players do
        local name, display = x:lower(), v.DisplayName:lower()
        if name:sub(1, #entry) == entry or display:sub(1, #entry) == entry then
            return v
        end
    end
    return nil
end
 
IvKit.randomString = function(minLen, maxLen)
    minLen = tonumber(minLen) or 5
    maxLen = math.clamp(tonumber(maxLen) or minLen, minLen, 300)

    local length = math.random(minLen, maxLen)
    local randomized = ''

    while #randomized < length do
        local byte = math.random(48, 122)
        if (byte >= 48 and byte <= 57) or (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) then
            randomized = randomized .. string.char(byte)
        end
    end

    return randomized
end

local sharedSignals = {}
IvKit.SignalRegistry = function(token)
	if token ~= nil then
		local cached = sharedSignals[token]
		if cached ~= nil then
			return cached
		end
	end

	local connections, registry = {}, {}
    registry.getConnection = function(entry)
        if type(entry, 'string', 'number') then --> id lookup
            return connections[entry]
        end

        if typeof(entry, 'RBXScriptConnection') then --> fallback :: RBXScriptConnection lookup
            for x, v in connections do
                if v and v.listener == entry then
                    return v
                end
            end
        end

        return nil
    end

    registry.clear = function()
        for x, v in connections do
            local listener = v and v.listener
            if listener then listener:Disconnect() end
            if v then
                v.listener = nil
                v.event = nil
                v.callback = nil
                v.fire = nil
                v.suspended = true
            end
            connections[x] = nil
        end
    end
    
    registry.suspend = function(id)
        local entry = registry.getConnection(id)
        if entry then entry.suspended = true end
    end

    registry.resume = function(id)
        local entry = registry.getConnection(id)
        if entry then entry.suspended = false end
    end

    registry.count = function()
        local n = 0
        for x in connections do
            n += 1
        end
        return n
    end

    registry.connect = function(id, signal, callback, ...)
        if not (id and typeof(signal, 'RBXScriptSignal') and type(callback, 'function')) then return end
        local entry = registry.getConnection(id)
        if entry then return entry end

        local extra = _pack(...)
		
        entry = {
			key = id,
			suspended = false,
			event = signal,
			callback = callback,
		}

        entry.listener = signal:Connect(function(...)
			if entry.suspended then return end
			callback(..., _unpack(extra))
		end)

        entry.Fire = function(self, ...)
			if self.suspended then return end
			return self.callback(..., _unpack(extra))
		end

        connections[id] = entry
        return entry
    end

    registry.disconnect = function(id)
        local entry = registry.getConnection(id)
        if not entry then return end
        local listener = entry.listener
        if listener then listener:Disconnect() end

        entry.listener = nil
        entry.event = nil
        entry.callback = nil
        entry.fire = nil
        entry.suspended = true
        connections[id] = nil
    end

    registry.untilThen = function(signal, callback, condition, onTimeout, ...)
        if not (typeof(signal, 'RBXScriptSignal') and type(callback, 'function')) then return end

		local alive = true
		local extra = _pack(...)
		local mainConn, killConn

        local cleanup = function()
			if not alive then return end
			alive = false

			if mainConn then mainConn:Disconnect() mainConn = nil end
			if killConn then killConn:Disconnect() killConn = nil end
        end

		mainConn = signal:Connect(function(...)
			if not alive then return end
			local stop = callback(..., _unpack(extra))
            if stop then
                return cleanup()
            end

			if type(condition, 'function') and condition() then
				cleanup()
			end
		end)

        if type(condition, 'number') then
			task.delay(condition, function()
				if not alive then return end
				cleanup()
				if type(onTimeout, 'function') then
					onTimeout(_unpack(extra))
				end
			end)
        elseif typeof(condition, 'RBXScriptSignal') then
			killConn = condition:Connect(cleanup)
		end

		return cleanup, mainConn
    end

	local api = setmetatable(connections, {__index = registry})
	if token ~= nil then sharedSignals[token] = api end
	return api
end

IvKit.fs = {}
IvKit.fs.normalizePath = function(path)
    if not type(path, 'string') then return '' end
    path = path:gsub('\\', '/'):gsub('/+', '/')
    if #path > 1 then path = path:gsub('/$', '') end
    return path
end

IvKit.fs.joinPath = function(...)
    local result = {}
    for i = 1, select('#', ...) do
        local part = select(i, ...)
        if type(part, 'string') and part ~= '' then
            result[#result + 1] = IvKit.fs.normalizePath(part)
        end
    end
    return IvKit.fs.normalizePath(table.concat(result, '/'))
end

IvKit.fs.dirName = function(path)
    path = IvKit.fs.normalizePath(path)
    local dir = path:match('^(.*)/[^/]+$')
    return dir or ''
end

IvKit.fs.exists = function(path)
    path = IvKit.fs.normalizePath(path)
    if path == '' then return false end
    if isfile and isfile(path) then return true end
    if isfolder and isfolder(path) then return true end
    return false
end

IvKit.fs.readFile = function(path)
    if not readfile then return nil end
    path = IvKit.fs.normalizePath(path)
    if path == '' then return nil end
    if isfile and not isfile(path) then return nil end
    local ok, res = pcall(readfile, path)
    return ok and res or nil
end

IvKit.fs.writeFile = function(path, data)
    if not writefile or not type(data, 'string') then return false end
    path = IvKit.fs.normalizePath(path)
    if path == '' then return false end
    local ok = pcall(writefile, path, data)
    return ok
end

IvKit.fs.appendFile = function(path, data)
    if not appendfile or not type(data, 'string') then return false end
    path = IvKit.fs.normalizePath(path)
    if path == '' then return false end
    local ok = pcall(appendfile, path, data)
    return ok
end

IvKit.fs.listFiles = function(path)
    if not listfiles then return nil end
    path = IvKit.fs.normalizePath(path)
    if path == '' then return nil end
    local ok, res = pcall(listfiles, path)
    return ok and type(res, 'table') and res or nil
end

IvKit.fs.makeDir = function(path)
	if not makefolder then return end
    path = IvKit.fs.normalizePath(path)
    if path == '' then return false end
    local current = ''
    for seg in path:gmatch('[^/]+') do
        current = current == '' and seg or (current .. '/' .. seg)
        if not isfolder(current) then
            makefolder(current)
        end
    end
    return true
end

IvKit.fs.deleteFile = function(path)
    if not delfile then return false end
    path = IvKit.fs.normalizePath(path)
    if path == '' then return false end
    if isfile and not isfile(path) then return false end
    local ok = pcall(delfile, path)
    return ok
end

IvKit.fs.deleteFolder = function(path)
    if not delfolder then return false end
    path = IvKit.fs.normalizePath(path)
    if path == '' then return false end
    if isfolder and not isfolder(path) then return false end
    local ok = pcall(delfolder, path)
    return ok
end

IvKit.fs.loadFile = function(path, chunkname)
    if not loadfile then return end
    path = IvKit.fs.normalizePath(path)
    if path == '' then return nil end
    local ok, fn, err = pcall(loadfile, path, chunkname)
    if not ok or not type(fn, 'function') then return nil, err end
    return fn
end

IvKit.fs.doFile = function(path)
    if not dofile then return false end
    path = IvKit.fs.normalizePath(path)
    if path == '' then return false end
    local ok = pcall(dofile, path)
    return ok
end

IvKit.fs.loadAsset = function(folder, url, deleteOld, key)
    if not (type(folder, 'string') and type(url, 'string')) then return 0, false  end
    if not (crypt and crypt.hash and readfile and writefile and isfile and delfile and getcustomasset) then  return 0, false end

    key = type(key, 'string') and key or 'image'
    folder = IvKit.fs.normalizePath(folder)
    IvKit.fs.makeDir(folder)

    local hash = crypt.hash(url, 'sha256'):gsub('[^%w]', '')
	local fileName = `{key}_{hash}.png`
    local filePath = IvKit.fs.joinPath(folder, fileName)
    local metaPath = IvKit.fs.joinPath(folder, `{key}.meta`)

    if not isfile(filePath) then
        local ok, bytes = pcall(IvKit.HttpGet, url)
        if not (ok and type(bytes, 'string')) then return 0, false end
        if not IvKit.fs.writeFile(filePath, bytes) then  return 0, false end
    end

    if deleteOld and isfile(metaPath) then
        local ok, old = pcall(readfile, metaPath)
        if ok and type(old, 'string') and old ~= fileName then
            pcall(delfile, IvKit.fs.joinPath(folder, old:gsub('%s+$', '')))
        end
    end

    pcall(writefile, metaPath, fileName)
    return getcustomasset(filePath), true, filePath
end

IvKit.benchmark = function(fn, ...)
    local t0 = os.clock()
    local results = _pack(pcall(fn, ...))
    results[results.n+1] = os.clock() - t0
    results.n += 1
    return _unpack(results)
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

IvKit.IvLog.info('IvKit load time:', IvKit.timeFmt(os.clock() - init))


