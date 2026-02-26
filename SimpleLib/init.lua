if not getgenv().IvKit then loadstring(game:HttpGet('https://raw.githubusercontent.com/BloodyBurns/Lua/refs/heads/main/IvKit/init.lua'))() end;setfenv(1, IvKit)
local UI_ROOT = GetObjects(76298660204746)
local objecst = UI_ROOT.objects
local cards = objecst.cards
local group = objecst.group
local groupFrame = objecst.groupFrame
local window = UI_ROOT.canvas.window
local s2 = Color3.fromRGB(26, 26, 26)
local accent = Color3.fromRGB(162, 109, 243)
local darkenAccent = Color3.fromRGB(81, 52, 124)
local signals = SignalRegistry()

UI_ROOT.Parent = CoreGui
UI_ROOT.DisplayOrder = 7

signals.connect(randomString(), UserInputService.InputBegan, function(input, f)
	if f then return end
	if input.KeyCode == Enum.KeyCode.LeftAlt then
		UI_ROOT.Enabled = not UI_ROOT.Enabled
	end
end)

local library = {}
library.groupCount = 0
library.Destroy = function() signals.clear() UI_ROOT:Destroy() end
library.SetTitle = function(self, title) window.header.title.Text = title end
library.CreateGroup = function(self, groupName)
	if library.groupCount > 5 then return error('Max Group Count') end
	
	library.groupCount += 1
	
	local groupFrame = groupFrame:Clone()
	local group = group:Clone()
	local isOpen = true
	local methods = {}
	
	groupFrame.Parent = window.body
	groupFrame.open.Text = groupName
	groupFrame.open.MouseButton1Click:Connect(function() group.Visible = true end)
	groupFrame.close.MouseButton1Click:Connect(function() group.Visible = false end)
	
	window.body.Visible = true
	window.padding.PaddingBottom = UDim.new(0, 10)

	group.Parent = UI_ROOT.canvas
	group.header.title.Text = groupName
	group.Position = UDim2.new(0.005 + 0.155 * library.groupCount, 0, 0.005, 0)
	group.header.collapse.d_close.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		group.body.Visible = isOpen
		group.padding.PaddingBottom = UDim.new(0, isOpen and 10 or 0)
		group.header.collapse.d_close.Image = isOpen and 'rbxassetid://10709791523' or 'rbxassetid://10709790948'
	end)
	
	methods.CreateButton = function(self, label, callback, ...)
        local extra = _pack(...)
		local btnFrame = cards.button:Clone()
		local db = false
		
		btnFrame.Parent = group.body
		btnFrame.frame.label.Text = label
		btnFrame.click.MouseButton1Click:Connect(function()
			if db then return end
			db = true
			callback(_unpack(extra))
			local effect = btnFrame:FindFirstChild('effect')
			if not effect then db = false return end
			effect.Visible = true
			effect.BackgroundTransparency = 1
			effect.Size = UDim2.new(1, 0, 1, 0)
			effect.Position = UDim2.new(0.5, 0, 0.5, 0)
			effect.AnchorPoint = Vector2.new(0.5, 0.5)

			local fadeIn = TweenService:Create(effect, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.25 })
			local fadeOut = TweenService:Create(effect, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })

			fadeIn:Play()
			fadeIn.Completed:Once(function() fadeOut:Play() end)
			fadeOut.Completed:Once(function()
				if effect.Parent then effect.Visible = false end
				db = false
			end)
		end)
	end
	
	methods.CreateText = function(self, label)
		local textFrame = cards.label:Clone()
		textFrame.Parent = group.body
		textFrame.label.Text = label
		 return textFrame.label
	end
	
	methods.CreateInput = function(self, label, callback)
		local inputFrame = cards.field:Clone()
		inputFrame.Parent = group.body
		inputFrame.label.Text = label
		inputFrame.field.input.FocusLost:Connect(function()
			local input = inputFrame.field.input
			callback(input.Text, input)
		end)
	end
	
	methods.CreateToggle = function(self, label, state, callback)
		local toggleFrame = cards.toggle:Clone()
		local db = false
		
		toggleFrame.Parent = group.body
		toggleFrame.label.Text = label
		toggleFrame.click.btn.MouseButton1Click:Connect(function()
			if db then return end
			db = true
			state = not state
			callback(state)

			local fade = TweenService:Create(toggleFrame.click, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = state and accent or s2})
			
			fade:Play()
			fade.Completed:Once(function() db = false end)
		end)
		
		toggleFrame.click.MouseEnter:Connect(function() if state then return end toggleFrame.click.BackgroundColor3 = darkenAccent end)
		toggleFrame.click.MouseLeave:Connect(function() if state then return end toggleFrame.click.BackgroundColor3 = s2 end)
		toggleFrame.click.BackgroundColor3 = state and accent or s2
		callback(state)
	end
	
	methods.CreateSlider = function(self, label, cfg, callback)
		local sliderFrame = cards.slider:Clone()
		local slider = sliderFrame.slide
		local dragging = false

		sliderFrame.Parent = group.body
		sliderFrame.frame.label.Text = label
		sliderFrame.frame.value.Text = cfg.value
		
		local calculateInput = function(input)
			local mousePos = Vector2.new(input.Position.X, input.Position.Y)
			local localPos = mousePos - sliderFrame.AbsolutePosition
			
			if localPos.X < -10 or localPos.X - 10 > sliderFrame.AbsoluteSize.X then return end
			local t = math.clamp(localPos.X / sliderFrame.AbsoluteSize.X, 0, 1)
			local value = cfg.min + (cfg.max - cfg.min) * t
			
			cfg.value = value
			sliderFrame.slide.Size = UDim2.new(t, 0, 1, 0)
			sliderFrame.frame.value.Text = cfg.p and string.format(`%.{math.clamp(cfg.p, 0, 4)}f`, value) or math.floor(value)
			callback(value)
		end
		
		sliderFrame.slide.Size = UDim2.new((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
		signals.connect(randomString(), sliderFrame.InputBegan, function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			dragging = true
			group.db.Enabled = false
			calculateInput(input)
		end)

		signals.connect(randomString(), UserInputService.InputChanged, function(input)
			if not dragging then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			calculateInput(input)
		end)

		signals.connect(randomString(), UserInputService.InputEnded, function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			dragging = false
			group.db.Enabled = true
		end)
	end
	
	return methods
end


return library
