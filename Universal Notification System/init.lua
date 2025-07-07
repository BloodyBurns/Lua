local UI_ROOT = game:GetService('CoreGui'):FindFirstChild('IvNotificationCenter') or game:GetObjects('rbxassetid://119242040448475')[1]
local uiObjects, notifCenter = UI_ROOT.Objects, UI_ROOT.Frame
local icons = uiObjects.Icons:GetAttributes()
local iconColors = uiObjects.Icons.Colors:GetAttributes()
local rectOffsets = uiObjects.Icons.Offsets:GetAttributes()
local create = function(title, message, notifType, duration)
	if not notifType or not icons[notifType] then
		warn(`Missing notification type. Received: {notifType}`)
		return
	end

	duration = tonumber(duration) or 5

	local notification, connection = uiObjects.Notification:Clone()
	notification.Body.TopBar.Icon.ImageRectOffset = rectOffsets[notifType]
	notification.Body.TopBar.Icon.ImageColor3 = iconColors[notifType]
	notification.Body.TopBar.Icon.Image = icons[notifType]
	notification.Body.TopBar.Title.Text = title
	notification.Body.Message.Text = message

	connection = notification.Body.TopBar.Close.MouseButton1Click:Connect(function()
		notification.Body:TweenPosition(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.6)
		task.wait(0.2)
		if connection then
			notification:Destroy()
			connection = nil
		end
	end)

	notification.Parent = notifCenter
	notification.Body:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.5, false, function()
		task.delay(duration, function()
			notification.Body:TweenPosition(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.8)
			task.wait(0.4)
			if connection then
				notification:Destroy()
				connection = nil
			end
		end)
	end)
end

getgenv().IvNotify = {
	error = function(t, m, d) create(t, m, 'error', d) end,
	info = function(t, m, d) create(t, m, 'info', d) end,
	warning = function(t, m, d) create(t, m, 'warning', d) end,
	success = function(t, m, d) create(t, m, 'success', d) end
}

UI_ROOT.Name = 'IvNotificationCenter'
UI_ROOT.Parent = game:GetService('CoreGui')
IvNotify.success('Universal Notification System', 'Notification System Loaded!')