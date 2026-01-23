setfenv(1, IvKit)

getgenv()._R15Emotes = getgenv()._R15Emotes or {
    UI_ROOT = CoreGui:FindFirstChild('R15Emotes') or GetObjects(10772412958),
    animation = Instance.new('Animation'),
    keybind = Enum.KeyCode.LeftAlt,
    isSelecting = false,
    track = nil
}

local settings = _R15Emotes
local UI_ROOT = settings.UI_ROOT
local signals = SignalRegistry('emote_ui'); signals.clear()

local animation = settings.animation
local mainDir = fs.joinPath('IvKernel', 'R15 Emotes')
local emotes = fs.joinPath(mainDir, 'emotes.json')

local frame = UI_ROOT.Frame
local search = frame.Search
local list = frame.List

local readEmotes = function()
    fs.makeDir(mainDir)

    local raw, data = fs.readFile(emotes), nil
    if type(raw, 'string') and raw ~= '' then
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok and type(decoded, 'table') then
            IvLog.success('Emotes cache loaded')
            data = decoded
        end
    end

    if not data then
        IvLog.warn('Cache miss → fetching remote file')
        IvLog.info('Initiating remote fetch for emotes.json')

        local ok, body = pcall(HttpGet, 'https://raw.githubusercontent.com/BloodyBurns/Lua/refs/heads/main/R15%20Emotes/emotes.json')
        if not (ok and type(body, 'string') and body ~= '') then
            return IvLog.error('Fetch failed → invalid response')
        end

        raw = body
        local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok2 or type(decoded, 'table') ~= true then
            return IvLog.error('Decode failed → invalid JSON')
        end

        data = decoded

        if fs.writeFile(emotes, raw) then
            IvLog.success(`Emotes cache written → {emotes}`)
        else
            IvLog.error(`Emotes cache write failed → {emotes}`)
        end
    end

    IvLog.success(`Emotes loaded → {table.size(data)} entries`)
    return data
end

local stop = function()
	if settings.track then
		settings.track:Stop()
		settings.track = nil
	end
end

local collapse = function()
    if search:IsFocused() then return end
    search.Bar:TweenSizeAndPosition(
        UDim2.new(0, 0, 0.031, 0),
        UDim2.new(0.5, 0, 1, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quint,
        0.5,
        true
    )
end

if not frame:FindFirstChild('UIDragDetector') then
    Instance.new('UIDragDetector').Parent = frame
end

UI_ROOT.Parent = CoreGui
signals.connect(randomString(), plr.CharacterAdded, stop)
signals.connect(randomString(), search.FocusLost, collapse)
signals.connect(randomString(), search.MouseLeave, collapse)
signals.connect(randomString(), list.Stop.Button.MouseButton1Click, stop)
signals.connect(randomString(), frame.Close.MouseButton1Click, function() frame.Visible = false end)
signals.connect(randomString(), search:GetPropertyChangedSignal('Text'), function()
	local query = search.Text:lower()
	for x, v in list:GetChildren() do
		if v:IsA('Frame') then
			local label = v:FindFirstChild('Label')
			local text = label and label.Text or ''
			local match = string.find(string.lower(text), query, 1, true)
			v.Visible = (query == '') or (match ~= nil)
		end
	end
end)

signals.connect('keybind_click', frame.Key.Button.MouseButton1Click, function()
    if settings.isSelecting then return end
    settings.isSelecting = true

    local btn = frame.Key.Button
    btn.Text = 'Keybind: Waiting'
    
    signals.untilThen(UserInputService.InputBegan, function(input, f)
        if f or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        task.defer(function() --> apply after current input event finishes (prevents same key toggle)
            settings.keybind = input.KeyCode
            btn.Text = `Keybind: {settings.keybind.Name}`
            settings.isSelecting = false
        end)
        return true
    end, 3, function()
        btn.Text = 'No Key Selected!'; task.wait(1)
        btn.Text = `Keybind: {settings.keybind.Name}`
        settings.isSelecting = false
    end)
end)

signals.connect(randomString(), search.MouseEnter, function()
	search.Bar:TweenSizeAndPosition(
		UDim2.new(1, 0, 0.031, 0),
		UDim2.new(0, 0, 1, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quint,
		0.5,
		true
	)
end)

signals.connect('toggle_ui', UserInputService.InputBegan, function(input, f)
    if f then return end
    if UserInputService:GetFocusedTextBox() then return end
    if settings.isSelecting then return end
    if input.KeyCode ~= settings.keybind then return end
    frame.Visible = not frame.Visible
end)

frame.Visible = true
for x, v in list:GetChildren() do
    if v:IsA('GuiObject') and v.Name ~= 'Stop' then
        v:Destroy()
    end
end

list.Stop.BackgroundTransparency = 0.7
for x, v in readEmotes() do
	local button = UI_ROOT.Objs.Animation:Clone()
    button.Parent = list
    button.BackgroundTransparency = 0.7
	button.Label.Text = v.name:split('-')[1]
	button.Emote.Image = `rbxthumb://type=Asset&id={v.id}&w=420&h=420`
    button.Emote.MouseButton1Click:Connect(function()
    	local humanoid = plr.Character:FindFirstChild('Humanoid')
        if not humanoid then return end

        stop()

        animation.AnimationId = v.AnimationId
        settings.track = humanoid:LoadAnimation(animation)
        settings.track.Priority = Enum.AnimationPriority.Idle
        settings.track:Play()
    end)

end
