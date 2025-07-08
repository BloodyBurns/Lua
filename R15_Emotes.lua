--> Rewrite
local track = nil
local keybind = Enum.KeyCode.LeftAlt
local animation = Instance.new('Animation')
local plr = game:GetService('Players').LocalPlayer
local UI_ROOT = game:GetObjects('rbxassetid://10772412958')
local humanoid = plr.Character and plr.Character:FindFirstChild('Humanoid')

local play = function(id)
    if track and track.IsPlaying then track:Stop() end
    if not humanoid then return end
    animation.AnimationId = id
    track = humanoid:LoadAnimation(animation)
    track:Play()
end

plr.CharacterAdded:Connect(function(character) humanoid = character:WaitForChild('Humanoid') end)
UI_ROOT.Parent = CoreGui
Instance.new('UIDragDetector').Parent = UI_ROOT.Frame
UI_ROOT.Frame.Close.MouseButton1Click:Connect(function() UI_ROOT.Frame.Visible = false end)
UI_ROOT.Frame.List.Stop.Button.MouseButton1Click:Connect(function() if track then track:Stop() end end)
UI_ROOT.Frame.Search:GetPropertyChangedSignal('Text'):Connect(function()
    local query = UI_ROOT.Frame.Search.Text:lower()
    for x, v in UI_ROOT.Frame.List:GetChildren() do
        if v:IsA('Frame') then
            local match = v.Label.Text:lower():find(query)
            v.Visible = (#query == 0) or match ~= nil
        end
    end
end)

UI_ROOT.Frame.Key.Button.MouseButton1Click:Connect(function()
    UI_ROOT.Frame.Key.Button.Text = 'Keybind: Waiting'
    task.wait(0.2)

    local selected, temp = false
    temp = InputService.InputBegan:Connect(function(input, gpe)
        if not gpe then
            selected = true
            keybind = input.KeyCode
            UI_ROOT.Frame.Key.Button.Text = `Keybind: {input.KeyCode.Name}`
            temp:Disconnect()
        end
    end)

    task.wait(3)
    if not selected then
        temp:Disconnect()
        UI_ROOT.Frame.Key.Button.Text = 'No Key Selected!' task.wait(1)
        UI_ROOT.Frame.Key.Button.Text = `Keybind: {keybind.Name}`
    end
end)
    
UI_ROOT.Frame.Search.MouseEnter:Connect(function()
    UI_ROOT.Frame.Search.Bar:TweenSizeAndPosition(
        UDim2.new(1, 0, 0.031, 0),
        UDim2.new(0, 0, 1, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Sine,
        0.5, true
    )
end)

UI_ROOT.Frame.Search.MouseLeave:Connect(function()
    if not UI_ROOT.Frame.Search:IsFocused() then
        UI_ROOT.Frame.Search.Bar:TweenSizeAndPosition(
            UDim2.new(0, 0, 0.031, 0),
            UDim2.new(0.5, 0, 1, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Sine,
            0.5, true
        )
    end
end)

InputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == keybind then
        UI_ROOT.Frame.Visible = not UI_ROOT.Frame.Visible
    end
end)

--> Attempt cache load - fallback to remote fetch
local file = 'emotes.json'
local emotes = isfile(file) and readfile(file)
if not emotes then
    IvLog.warn('Cache miss: emote dataset not found')
    IvLog.info('Initiating remote fetch for emotes.json')
    local result, elapsed = benchmark(HttpGet, 'https://raw.githubusercontent.com/BloodyBurns/Lua/refs/heads/main/emotes.json')
    if not result then return IvLog.error('Fetch failed: Unable to retrieve emote data (network error or invalid response)') end
    emotes = result
    writefile('emotes.json', result)
    IvLog.success('Emotes cached', timeFmt(elapsed))
end

emotes = JSON('unpack', emotes)
for x, v in emotes do
    local button = UI_ROOT.Objs.Animation:Clone()
    button.Label.Text = v.name:split('-')[1]
    button.Emote.Image = `rbxthumb://type=Asset&id={v.id}&w=420&h=420`
    button.Parent = UI_ROOT.Frame.List
    button.Emote.MouseButton1Click:Connect(function() play(v.AnimationId) end)
end