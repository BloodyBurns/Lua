if not getgenv().IvKit then loadstring(game:HttpGet('https://raw.githubusercontent.com/BloodyBurns/Lua/refs/heads/main/IvKit/init.lua'))() end; setfenv(1, IvKit)
local mainDir = fs.joinPath('IvKernel', 'R15 Emotes')
local emotesFile = fs.joinPath(mainDir, 'emotes.json')
local favoritesFile = fs.joinPath(mainDir, 'favorites.json')

getgenv()._R15Emotes = getgenv()._R15Emotes or {
	UI_ROOT = CoreGui:FindFirstChild('Iv-R15-UI') or GetObjects(114129191302596),
	animation = Instance.new('Animation'),
	keybind = Enum.KeyCode.LeftAlt,
	isSelecting = false,
    isViewing = false,
    loaded = false,
	track = nil,
    favorites = (function()
        fs.makeDir(mainDir)
        if not fs.exists(favoritesFile) then fs.writeFile(favoritesFile, '{}') end
        local raw = fs.readFile(favoritesFile)
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok and type(decoded, 'table') then return decoded end
        IvLog.error(ok, decoded, type(decoded)) 
        fs.writeFile(favoritesFile, '{}')
        return {}
    end)(),
}

local uisettings = _R15Emotes
local UI_ROOT = uisettings.UI_ROOT
local animation = uisettings.animation
local signals = SignalRegistry('IvR15.'); signals.clear()

local main = UI_ROOT.canvas.main
local header = main.header
local body = main.body
local overlay = main.overlay
local list = body.list
local toggler = UI_ROOT.canvas.emotes_toggle
local item = UI_ROOT.templates.item
local favorites = uisettings.favorites

local readEmotes = function()
    local raw, data = fs.readFile(emotesFile), nil
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

        if fs.writeFile(emotesFile, raw) then
            IvLog.success(`Emotes cache written → {emotesFile}`)
        else
            IvLog.error(`Emotes cache write failed → {emotesFile}`)
        end
    end

    IvLog.success(`Emotes loaded → {table.size(data)} entries`)
    return data
end

local stop = function()
	if uisettings.track then
		uisettings.track:Stop()
		uisettings.track = nil
	end
end

local favFilter = function()
    local query = overlay.search.Text:lower()
    table.map(list):Children():IsA('Frame'):Invoke(function(frame)
        local isSearched = (query == '') or (frame.Name:find(query, 1, true) ~= nil)
        frame.Visible = isSearched and (not uisettings.isViewing or favorites[frame.Name])
    end)
end

local saveFavorites = function(v)
    if v ~= plr then return end
    fs.writeFile(favoritesFile, HttpService:JSONEncode(favorites))
end

if not uisettings.loaded then
    local search = overlay.search
    local collapse = function()
        if search:IsFocused() then return end
        search.divider:TweenSize(
            UDim2.new(0, 0, 0.1, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quint,
            0.5,
            true
        )
    end

    plr.CharacterAdded:Connect(stop)
    overlay.cancel.MouseButton1Click:Connect(stop)
    toggler.btn.MouseButton1Click:Connect(function() main.Visible = true toggler.Visible = not main.Visible end)
    header.right.close.MouseButton1Click:Connect(function() main.Visible = false toggler.Visible = not main.Visible end)
    overlay.keybind.MouseButton1Click:Connect(function()
        if uisettings.isSelecting then return end
        uisettings.isSelecting = true
        overlay.keybind.Text = 'Listening..'
        signals.untilThen(UserInputService.InputBegan, function(input, f)
            if f or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            task.defer(function()
                uisettings.keybind = input.KeyCode
                overlay.keybind.Text = uisettings.keybind.Name
                uisettings.isSelecting = false
            end)
            return true
        end, 3, function()
            overlay.keybind.Text = 'No Selection'; task.wait(1)
            overlay.keybind.Text = uisettings.keybind.Name
            uisettings.isSelecting = false
        end)
    end)

    header.right.favorite.MouseButton1Click:Connect(function()
        uisettings.isViewing = not uisettings.isViewing
        header.right.favorite.click.ImageColor3 = uisettings.isViewing and Color3.fromRGB(255, 255, 127) or Color3.new(1, 1, 1)
        header.right.favorite.click.ImageTransparency = uisettings.isViewing and 0 or 0.5
        favFilter()
    end)

    UserInputService.InputBegan:Connect(function(input, f)
        if f then return end
        if UserInputService:GetFocusedTextBox() then return end
        if uisettings.isSelecting then return end
        if input.KeyCode ~= uisettings.keybind then return end
        main.Visible = not main.Visible
        toggler.Visible = not main.Visible
    end)

    search.FocusLost:Connect(collapse)
    search.MouseLeave:Connect(collapse)
    search.MouseEnter:Connect(function()
        search.divider:TweenSize(
            UDim2.new(1, 0, 0.1, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quint,
            0.5,
            true
        )
    end)

    search:GetPropertyChangedSignal('Text'):Connect(favFilter)
    Instance.new('UIDragDetector').Parent = toggler
end

table.map(list):Children():IsA('GuiObject'):Destroy()
header.right.favorite.click.ImageColor3 = uisettings.isViewing and Color3.fromRGB(255, 255, 127) or Color3.new(1, 1, 1)
header.right.favorite.click.ImageTransparency = uisettings.isViewing and 0 or 0.5
signals.connect('save_on_leave', plrs.PlayerRemoving, saveFavorites)

for x, v in readEmotes() do
	local frame = item:Clone()
    local text = v.name:split('-')[1]
    local favorite = favorites[text:lower()]

    frame.Parent = list
	frame.Name = text:lower()
    frame.play.Text = text
    frame.Visible = not uisettings.isViewing or favorite
	frame.icon.icon.Image = `rbxthumb://type=Asset&id={v.id}&w=420&h=420`
    frame.MouseEnter:Connect(function() frame.BackgroundTransparency = 0 end)
    frame.MouseLeave:Connect(function() frame.BackgroundTransparency = 1 end)
    frame.favorite.click.ImageColor3 = favorite and Color3.fromRGB(255, 255, 127) or Color3.new(1, 1, 1)
    frame.favorite.click.ImageTransparency = favorite and 0 or 0.5
    frame.play.MouseButton1Click:Connect(function()
    	local humanoid = plr.Character:FindFirstChild('Humanoid')
        if not humanoid then return end
        animation.AnimationId = v.AnimationId
        stop()
        uisettings.track = humanoid:LoadAnimation(animation)
        uisettings.track.Priority = Enum.AnimationPriority.Idle
        uisettings.track:Play()
    end)

    frame.favorite.click.MouseButton1Click:Connect(function()
        favorite = not favorite
        favorites[frame.Name] = favorite and true or nil
        frame.favorite.click.ImageColor3 = favorite and Color3.fromRGB(255, 255, 127) or Color3.new(1, 1, 1)
        frame.favorite.click.ImageTransparency = favorite and 0 or 0.5
        frame.Visible = not uisettings.isViewing or favorite
    end)
end

favFilter()
main.Visible = true
toggler.Visible = false
uisettings.loaded = true
UI_ROOT.Parent = CoreGui
