local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = game:GetService("Players").LocalPlayer

local AtheriumGUI = {}
AtheriumGUI.__index = AtheriumGUI

-- Dynamic Icons Loader
local Icons = nil
pcall(function()
	Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	if Icons and Icons.SetIconsType then
		Icons.SetIconsType("lucide")
	end
end)

-- Fluent / WindUI Premium Dark Theme
local THEME = {
	Background = Color3.fromRGB(15, 15, 20),
	Header = Color3.fromRGB(22, 22, 30),
	Card = Color3.fromRGB(25, 25, 35),
	CardHover = Color3.fromRGB(35, 35, 48),
	
	-- Modern WindUI Palette
	Accent = Color3.fromRGB(0, 162, 255),       -- Vibrant Fluent Blue
	Success = Color3.fromRGB(46, 204, 113),     -- Mint Green
	Warning = Color3.fromRGB(241, 196, 15),     -- Amber
	Error = Color3.fromRGB(231, 76, 60),        -- Coral Red
	
	Text = Color3.fromRGB(240, 240, 245),
	SubText = Color3.fromRGB(140, 140, 160),
	Border = Color3.fromRGB(45, 45, 60),
	BorderFocus = Color3.fromRGB(0, 162, 255),
}

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

local function addStroke(parent, color, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or THEME.Border
	stroke.Thickness = 1
	stroke.Transparency = transparency or 0.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function createIcon(parent, iconName, customSize, customPos)
	if not iconName or type(iconName) ~= "string" or not Icons then return 0 end

	local iconImage = nil
	pcall(function()
		if typeof(Icons.GetIcon) == "function" then
			iconImage = Icons.GetIcon(iconName)
		elseif typeof(Icons.CreateIcon) == "function" then
			iconImage = Icons.CreateIcon(iconName)
		end
	end)

	if iconImage then
		local iconLabel = Instance.new("ImageLabel")
		iconLabel.Name = "Icon"
		iconLabel.Size = customSize or UDim2.new(0, 16, 0, 16)
		iconLabel.Position = customPos or UDim2.new(0, 12, 0.5, -8)
		iconLabel.BackgroundTransparency = 1
		
		if typeof(iconImage) == "table" then
			iconLabel.Image = iconImage.Image or iconImage.Texture or ""
			iconLabel.ImageRectOffset = iconImage.ImageRectOffset or Vector2.new(0, 0)
			iconLabel.ImageRectSize = iconImage.ImageRectSize or Vector2.new(0, 0)
		elseif typeof(iconImage) == "string" then
			iconLabel.Image = iconImage
		end

		iconLabel.ImageColor3 = THEME.Text
		iconLabel.ImageTransparency = 0.15
		iconLabel.ZIndex = 3
		iconLabel.Parent = parent
		return 26
	end

	return 0
end

function AtheriumGUI.CreateWindow(titleText)
	local self = setmetatable({}, AtheriumGUI)
	self.GlobalTransparency = 0.15
	self.ElementsToTransparency = {}

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Atherium_WindUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- Notification Container
	local notifHolder = Instance.new("Frame")
	notifHolder.Name = "NotifHolder"
	notifHolder.Size = UDim2.new(0, 280, 1, -30)
	notifHolder.Position = UDim2.new(1, -290, 0, 15)
	notifHolder.BackgroundTransparency = 1
	notifHolder.Parent = screenGui

	local notifLayout = Instance.new("UIListLayout")
	notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notifLayout.Padding = UDim.new(0, 8)
	notifLayout.Parent = notifHolder

	-- Main Window Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 520, 0, 400)
	mainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
	mainFrame.BackgroundColor3 = THEME.Background
	mainFrame.BackgroundTransparency = self.GlobalTransparency
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	addCorner(mainFrame, 10)
	local mainStroke = addStroke(mainFrame, THEME.Border, 0.2)

	table.insert(self.ElementsToTransparency, {Instance = mainFrame, BaseTransparency = 0.15})

	-- Window Header (Fluent Style)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 42)
	header.BackgroundColor3 = THEME.Header
	header.BackgroundTransparency = self.GlobalTransparency
	header.BorderSizePixel = 0
	header.Parent = mainFrame
	addCorner(header, 10)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -120, 1, 0)
	title.Position = UDim2.new(0, 16, 0, 0)
	title.Text = titleText or "Atherium WindUI"
	title.TextColor3 = THEME.Text
	title.TextSize = 14
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.BackgroundTransparency = 1
	title.Parent = header

	-- Quick Settings Button (Transparency Control)
	local settingsBtn = Instance.new("ImageButton")
	settingsBtn.Size = UDim2.new(0, 18, 0, 18)
	settingsBtn.Position = UDim2.new(1, -64, 0.5, -9)
	settingsBtn.BackgroundTransparency = 1
	settingsBtn.Image = "rbxassetid://6031280882" -- Settings Gear Icon
	settingsBtn.ImageColor3 = THEME.SubText
	settingsBtn.Parent = header

	-- Settings Dropdown Frame (Opacity Slider)
	local opacityFrame = Instance.new("Frame")
	opacityFrame.Size = UDim2.new(0, 200, 0, 45)
	opacityFrame.Position = UDim2.new(1, -210, 1, 5)
	opacityFrame.BackgroundColor3 = THEME.Card
	opacityFrame.Visible = false
	opacityFrame.ZIndex = 10
	opacityFrame.Parent = header
	addCorner(opacityFrame, 8)
	addStroke(opacityFrame, THEME.Accent, 0.4)

	local opLabel = Instance.new("TextLabel")
	opLabel.Size = UDim2.new(1, -12, 0, 18)
	opLabel.Position = UDim2.new(0, 8, 0, 4)
	opLabel.Text = "Прозрачность UI"
	opLabel.TextColor3 = THEME.Text
	opLabel.TextSize = 11
	opLabel.Font = Enum.Font.GothamMedium
	opLabel.TextXAlignment = Enum.TextXAlignment.Left
	opLabel.BackgroundTransparency = 1
	opLabel.ZIndex = 11
	opLabel.Parent = opacityFrame

	local opTrack = Instance.new("Frame")
	opTrack.Size = UDim2.new(1, -16, 0, 4)
	opTrack.Position = UDim2.new(0, 8, 1, -12)
	opTrack.BackgroundColor3 = THEME.Header
	opTrack.ZIndex = 11
	opTrack.Parent = opacityFrame
	addCorner(opTrack, 2)

	local opFill = Instance.new("Frame")
	opFill.Size = UDim2.new(1 - self.GlobalTransparency, 0, 1, 0)
	opFill.BackgroundColor3 = THEME.Accent
	opFill.ZIndex = 11
	opFill.Parent = opTrack
	addCorner(opFill, 2)

	local isSlidingOp = false
	local function updateOpacity(input)
		local percent = math.clamp((input.Position.X - opTrack.AbsolutePosition.X) / opTrack.AbsoluteSize.X, 0.05, 0.95)
		opFill.Size = UDim2.new(percent, 0, 1, 0)
		self.GlobalTransparency = 1 - percent

		for _, item in ipairs(self.ElementsToTransparency) do
			if item.Instance and item.Instance.Parent then
				item.Instance.BackgroundTransparency = math.clamp(self.GlobalTransparency, item.BaseTransparency or 0, 0.95)
			end
		end
	end

	settingsBtn.MouseButton1Click:Connect(function()
		opacityFrame.Visible = not opacityFrame.Visible
	end)

	opTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isSlidingOp = true
			updateOpacity(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then isSlidingOp = false end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isSlidingOp and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateOpacity(input)
		end
	end)

	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = THEME.SubText
	closeBtn.TextSize = 13
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = header

	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	local container = Instance.new("ScrollingFrame")
	container.Name = "Container"
	container.Size = UDim2.new(1, -20, 1, -52)
	container.Position = UDim2.new(0, 10, 0, 48)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ScrollBarThickness = 2
	container.ScrollBarImageColor3 = THEME.Accent
	container.Parent = mainFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 6)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = container

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingRight = UDim.new(0, 4)
	padding.Parent = container

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
	end)

	-- Window Dragging Logic
	local dragging, dragStart, startPos
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)

	header.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Toggle Keybind (RightControl)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
			mainFrame.Visible = not mainFrame.Visible
		end
	end)

	self.ScreenGui = screenGui
	self.Container = container
	self.NotifHolder = notifHolder
	return self
end

-- WindUI Style Banner Notifications
function AtheriumGUI:Notify(titleText, descText, duration, notifType)
	duration = duration or 3.5
	notifType = notifType or "info"

	local typeColors = {
		info = THEME.Accent,
		success = THEME.Success,
		warning = THEME.Warning,
		error = THEME.Error
	}

	local accentColor = typeColors[notifType] or THEME.Accent

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 58)
	notif.BackgroundColor3 = THEME.Card
	notif.BackgroundTransparency = self.GlobalTransparency
	notif.ClipsDescendants = true
	notif.Parent = self.NotifHolder
	addCorner(notif, 8)
	addStroke(notif, accentColor, 0.4)

	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, 3, 1, -12)
	line.Position = UDim2.new(0, 6, 0, 6)
	line.BackgroundColor3 = accentColor
	line.BorderSizePixel = 0
	line.Parent = notif
	addCorner(line, 2)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -24, 0, 18)
	titleLabel.Position = UDim2.new(0, 16, 0, 8)
	titleLabel.Text = titleText
	titleLabel.TextColor3 = THEME.Text
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = notif

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -24, 0, 22)
	descLabel.Position = UDim2.new(0, 16, 0, 26)
	descLabel.Text = descText
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextWrapped = true
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.BackgroundTransparency = 1
	descLabel.Parent = notif

	notif.Position = UDim2.new(1, 80, 0, 0)
	TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

	task.delay(duration, function()
		local dismiss = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 80, 0, 0), BackgroundTransparency = 1})
		dismiss:Play()
		dismiss.Completed:Connect(function() notif:Destroy() end)
	end)
end

-- Section Divider
function AtheriumGUI:AddSection(text)
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Size = UDim2.new(1, 0, 0, 22)
	sectionFrame.BackgroundTransparency = 1
	sectionFrame.Parent = self.Container

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Position = UDim2.new(0, 4, 0, 2)
	label.Text = string.upper(text)
	label.TextColor3 = THEME.Accent
	label.TextSize = 10
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = sectionFrame
end

-- Fluent Button
function AtheriumGUI:AddButton(text, iconName, callback)
	if type(iconName) == "function" then
		callback = iconName
		iconName = nil
	end

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 36)
	button.BackgroundColor3 = THEME.Card
	button.BackgroundTransparency = self.GlobalTransparency
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = self.Container
	addCorner(button, 8)
	local stroke = addStroke(button, THEME.Border, 0.6)

	table.insert(self.ElementsToTransparency, {Instance = button, BaseTransparency = 0})

	local iconOffset = createIcon(button, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -(14 + iconOffset), 1, 0)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 12
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = button

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.CardHover}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.2), {Color = THEME.Accent}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Card}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.2), {Color = THEME.Border}):Play()
	end)
	button.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)
end

-- Fluent Toggle Switch
function AtheriumGUI:AddToggle(text, iconName, defaultState, callback)
	if type(iconName) == "boolean" then
		callback = defaultState
		defaultState = iconName
		iconName = nil
	end

	local state = defaultState or false
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(1, 0, 0, 38)
	toggleFrame.BackgroundColor3 = THEME.Card
	toggleFrame.BackgroundTransparency = self.GlobalTransparency
	toggleFrame.Parent = self.Container
	addCorner(toggleFrame, 8)
	addStroke(toggleFrame, THEME.Border, 0.6)

	table.insert(self.ElementsToTransparency, {Instance = toggleFrame, BaseTransparency = 0})

	local iconOffset = createIcon(toggleFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -(60 + iconOffset), 1, 0)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 12
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = toggleFrame

	local switchBG = Instance.new("Frame")
	switchBG.Size = UDim2.new(0, 38, 0, 20)
	switchBG.Position = UDim2.new(1, -48, 0.5, -10)
	switchBG.BackgroundColor3 = state and THEME.Accent or THEME.Header
	switchBG.Parent = toggleFrame
	addCorner(switchBG, 10)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 14, 0, 14)
	circle.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.Parent = switchBG
	addCorner(circle, 7)

	local clickBtn = Instance.new("TextButton")
	clickBtn.Size = UDim2.new(1, 0, 1, 0)
	clickBtn.BackgroundTransparency = 1
	clickBtn.Text = ""
	clickBtn.Parent = toggleFrame

	clickBtn.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(switchBG, TweenInfo.new(0.2), {BackgroundColor3 = state and THEME.Accent or THEME.Header}):Play()
		TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
		if callback then callback(state) end
	end)
end

-- WindUI Slider
function AtheriumGUI:AddSlider(text, iconName, minVal, maxVal, defaultVal, callback)
	if type(iconName) == "number" then
		callback = defaultVal
		defaultVal = maxVal
		maxVal = minVal
		minVal = iconName
		iconName = nil
	end

	minVal = minVal or 0
	maxVal = maxVal or 100
	defaultVal = math.clamp(defaultVal or minVal, minVal, maxVal)

	local sliderFrame = Instance.new("Frame")
	sliderFrame.Size = UDim2.new(1, 0, 0, 46)
	sliderFrame.BackgroundColor3 = THEME.Card
	sliderFrame.BackgroundTransparency = self.GlobalTransparency
	sliderFrame.Parent = self.Container
	addCorner(sliderFrame, 8)
	addStroke(sliderFrame, THEME.Border, 0.6)

	table.insert(self.ElementsToTransparency, {Instance = sliderFrame, BaseTransparency = 0})

	local iconOffset = createIcon(sliderFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -(70 + iconOffset), 0, 20)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 4)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 12
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = sliderFrame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0, 20)
	valueLabel.Position = UDim2.new(1, -60, 0, 4)
	valueLabel.Text = tostring(defaultVal)
	valueLabel.TextColor3 = THEME.SubText
	valueLabel.TextSize = 11
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.BackgroundTransparency = 1
	valueLabel.Parent = sliderFrame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -24, 0, 4)
	track.Position = UDim2.new(0, 12, 1, -12)
	track.BackgroundColor3 = THEME.Header
	track.Parent = sliderFrame
	addCorner(track, 2)

	local initialPercent = (defaultVal - minVal) / (maxVal - minVal)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(initialPercent, 0, 1, 0)
	fill.BackgroundColor3 = THEME.Accent
	fill.Parent = track
	addCorner(fill, 2)

	local isSliding = false
	local function updateSlider(input)
		local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = math.floor(minVal + (maxVal - minVal) * percent)
		
		fill.Size = UDim2.new(percent, 0, 1, 0)
		valueLabel.Text = tostring(value)
		if callback then callback(value) end
	end

	sliderFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isSliding = true
			updateSlider(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input)
		end
	end)
end

-- WindUI Interactive ColorPicker
function AtheriumGUI:AddColorPicker(text, iconName, defaultColor, callback)
	if typeof(iconName) == "Color3" then
		callback = defaultColor
		defaultColor = iconName
		iconName = nil
	end

	defaultColor = defaultColor or Color3.fromRGB(0, 162, 255)
	local currentColor = defaultColor
	local expanded = false

	local colorFrame = Instance.new("Frame")
	colorFrame.Size = UDim2.new(1, 0, 0, 38)
	colorFrame.BackgroundColor3 = THEME.Card
	colorFrame.BackgroundTransparency = self.GlobalTransparency
	colorFrame.ClipsDescendants = true
	colorFrame.Parent = self.Container
	addCorner(colorFrame, 8)
	addStroke(colorFrame, THEME.Border, 0.6)

	table.insert(self.ElementsToTransparency, {Instance = colorFrame, BaseTransparency = 0})

	local iconOffset = createIcon(colorFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, -iconOffset, 0, 38)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 12
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = colorFrame

	-- Color Preview Indicator
	local preview = Instance.new("Frame")
	preview.Size = UDim2.new(0, 26, 0, 18)
	preview.Position = UDim2.new(1, -38, 0, 10)
	preview.BackgroundColor3 = currentColor
	preview.Parent = colorFrame
	addCorner(preview, 4)
	addStroke(preview, THEME.Border, 0.4)

	-- Color Palette Container
	local paletteContainer = Instance.new("Frame")
	paletteContainer.Size = UDim2.new(1, -24, 0, 100)
	paletteContainer.Position = UDim2.new(0, 12, 0, 42)
	paletteContainer.BackgroundTransparency = 1
	paletteContainer.Parent = colorFrame

	-- Hue Slider
	local hueTrack = Instance.new("ImageLabel")
	hueTrack.Size = UDim2.new(1, 0, 0, 14)
	hueTrack.Position = UDim2.new(0, 0, 0, 75)
	hueTrack.Image = "rbxassetid://2849427770" -- Rainbow Gradient Spectrum
	hueTrack.Parent = paletteContainer
	addCorner(hueTrack, 4)

	local isSlidingHue = false
	local function updateHue(input)
		local percent = math.clamp((input.Position.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
		currentColor = Color3.fromHSV(percent, 1, 1)
		preview.BackgroundColor3 = currentColor
		if callback then callback(currentColor) end
	end

	hueTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isSlidingHue = true
			updateHue(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then isSlidingHue = false end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isSlidingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateHue(input)
		end
	end)

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(1, 0, 0, 38)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.Text = ""
	toggleBtn.Parent = colorFrame

	toggleBtn.MouseButton1Click:Connect(function()
		expanded = not expanded
		TweenService:Create(colorFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, expanded and 140 or 38)}):Play()
	end)
end

-- TextBox Field
function AtheriumGUI:AddTextBox(text, iconName, placeholder, callback)
	if type(iconName) == "string" and not callback and placeholder == nil then
		placeholder = iconName
		iconName = nil
	end

	local textBoxFrame = Instance.new("Frame")
	textBoxFrame.Size = UDim2.new(1, 0, 0, 38)
	textBoxFrame.BackgroundColor3 = THEME.Card
	textBoxFrame.BackgroundTransparency = self.GlobalTransparency
	textBoxFrame.Parent = self.Container
	addCorner(textBoxFrame, 8)
	addStroke(textBoxFrame, THEME.Border, 0.6)

	table.insert(self.ElementsToTransparency, {Instance = textBoxFrame, BaseTransparency = 0})

	local iconOffset = createIcon(textBoxFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, -iconOffset, 1, 0)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 12
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = textBoxFrame

	local boxBG = Instance.new("Frame")
	boxBG.Size = UDim2.new(0.5, 0, 0, 24)
	boxBG.Position = UDim2.new(0.5, -12, 0.5, -12)
	boxBG.BackgroundColor3 = THEME.Header
	boxBG.Parent = textBoxFrame
	addCorner(boxBG, 6)

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1, -12, 1, 0)
	textBox.Position = UDim2.new(0, 6, 0, 0)
	textBox.PlaceholderText = placeholder or "Enter..."
	textBox.PlaceholderColor3 = THEME.SubText
	textBox.Text = ""
	textBox.TextColor3 = THEME.Text
	textBox.TextSize = 11
	textBox.Font = Enum.Font.Gotham
	textBox.BackgroundTransparency = 1
	textBox.ClearTextOnFocus = false
	textBox.Parent = boxBG

	textBox.FocusLost:Connect(function(enterPressed)
		if callback then callback(textBox.Text, enterPressed) end
	end)
end

-- Dropdown Menu
function AtheriumGUI:AddDropdown(text, iconName, options, defaultOption, callback)
	if type(iconName) == "table" then
		callback = defaultOption
		defaultOption = options
		options = iconName
		iconName = nil
	end

	options = options or {}
	local selected = defaultOption or options[1] or "Select..."
	local expanded = false

	local dropdownFrame = Instance.new("Frame")
	dropdownFrame.Size = UDim2.new(1, 0, 0, 38)
	dropdownFrame.BackgroundColor3 = THEME.Card
	dropdownFrame.BackgroundTransparency = self.GlobalTransparency
	dropdownFrame.ClipsDescendants = true
	dropdownFrame.Parent = self.Container
	addCorner(dropdownFrame, 8)
	addStroke(dropdownFrame, THEME.Border, 0.6)

	table.insert(self.ElementsToTransparency, {Instance = dropdownFrame, BaseTransparency = 0})

	local iconOffset = createIcon(dropdownFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, -iconOffset, 0, 38)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 12
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = dropdownFrame

	local selectedLabel = Instance.new("TextLabel")
	selectedLabel.Size = UDim2.new(0.4, -20, 0, 38)
	selectedLabel.Position = UDim2.new(0.6, -20, 0, 0)
	selectedLabel.Text = selected
	selectedLabel.TextColor3 = THEME.Accent
	selectedLabel.TextSize = 11
	selectedLabel.Font = Enum.Font.GothamBold
	selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
	selectedLabel.BackgroundTransparency = 1
	selectedLabel.Parent = dropdownFrame

	local optContainer = Instance.new("Frame")
	optContainer.Size = UDim2.new(1, -24, 0, #options * 26)
	optContainer.Position = UDim2.new(0, 12, 0, 38)
	optContainer.BackgroundTransparency = 1
	optContainer.Parent = dropdownFrame

	local optLayout = Instance.new("UIListLayout")
	optLayout.Padding = UDim.new(0, 2)
	optLayout.Parent = optContainer

	for _, opt in ipairs(options) do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 24)
		optBtn.BackgroundColor3 = THEME.Header
		optBtn.Text = opt
		optBtn.TextColor3 = THEME.Text
		optBtn.TextSize = 11
		optBtn.Font = Enum.Font.Gotham
		optBtn.Parent = optContainer
		addCorner(optBtn, 4)

		optBtn.MouseButton1Click:Connect(function()
			selected = opt
			selectedLabel.Text = selected
			expanded = false
			TweenService:Create(dropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 38)}):Play()
			if callback then callback(selected) end
		end)
	end

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(1, 0, 0, 38)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.Text = ""
	toggleBtn.Parent = dropdownFrame

	toggleBtn.MouseButton1Click:Connect(function()
		expanded = not expanded
		TweenService:Create(dropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, expanded and (42 + #options * 26) or 38)}):Play()
	end)
end

-- Keybind Picker
function AtheriumGUI:AddKeybind(text, iconName, defaultKey, callback)
	if typeof(defaultKey) == "function" then
		callback = defaultKey
		defaultKey = Enum.KeyCode.E
	end
	
	local currentKey = defaultKey or Enum.KeyCode.E
	local listening = false

	local bindFrame = Instance.new("Frame")
	bindFrame.Size = UDim2.new(1, 0, 0, 38)
	bindFrame.BackgroundColor3 = THEME.Card
	bindFrame.BackgroundTransparency = self.GlobalTransparency
	bindFrame.Parent = self.Container
	addCorner(bindFrame, 8)
	addStroke(bindFrame, THEME.Border, 0.6)

	table.insert(self.ElementsToTransparency, {Instance = bindFrame, BaseTransparency = 0})

	local iconOffset = createIcon(bindFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, -iconOffset, 1, 0)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 12
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = bindFrame

	local keyBtn = Instance.new("TextButton")
	keyBtn.Size = UDim2.new(0, 65, 0, 22)
	keyBtn.Position = UDim2.new(1, -77, 0.5, -11)
	keyBtn.BackgroundColor3 = THEME.Header
	keyBtn.Text = currentKey.Name
	keyBtn.TextColor3 = THEME.Accent
	keyBtn.TextSize = 10
	keyBtn.Font = Enum.Font.GothamBold
	keyBtn.Parent = bindFrame
	addCorner(keyBtn, 4)

	keyBtn.MouseButton1Click:Connect(function()
		listening = true
		keyBtn.Text = "..."
		keyBtn.TextColor3 = THEME.Warning
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if listening and not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			currentKey = input.KeyCode
			keyBtn.Text = currentKey.Name
			keyBtn.TextColor3 = THEME.Accent
			if callback then callback(currentKey) end
		end
	end)
end

return AtheriumGUI
