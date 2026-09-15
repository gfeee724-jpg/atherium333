local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = game:GetService("Players").LocalPlayer

local AtheriumGUI = {}
AtheriumGUI.__index = AtheriumGUI

-- Blur / Glass Effect
local blurEffect = Lighting:FindFirstChild("AtheriumGlassBlur")
if not blurEffect then
	blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "AtheriumGlassBlur"
	blurEffect.Size = 14
	blurEffect.Enabled = true
	blurEffect.Parent = Lighting
end

-- Dynamic Icons Loader
local Icons = nil
pcall(function()
	Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	if Icons and Icons.SetIconsType then
		Icons.SetIconsType("lucide")
	end
end)

-- Theme (macOS Sequoia / iOS 18 Glassmorphism)
local THEME = {
	GlassBackground = Color3.fromRGB(20, 20, 26),
	GlassTransparency = 0.25,
	Header = Color3.fromRGB(30, 30, 38),
	Card = Color3.fromRGB(35, 35, 45),
	CardHover = Color3.fromRGB(48, 48, 62),
	CardTransparency = 0.35,
	
	-- Colors
	Accent = Color3.fromRGB(10, 132, 255),      -- Blue
	Success = Color3.fromRGB(52, 199, 89),     -- Green
	Warning = Color3.fromRGB(255, 159, 10),    -- Orange
	Error = Color3.fromRGB(255, 69, 58),       -- Red
	
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(160, 160, 175),
	GlassBorder = Color3.fromRGB(255, 255, 255),
}

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 14)
	corner.Parent = parent
	return corner
end

local function addGlassStroke(parent, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.GlassBorder
	stroke.Thickness = 1
	stroke.Transparency = transparency or 0.85
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
		iconLabel.Size = customSize or UDim2.new(0, 18, 0, 18)
		iconLabel.Position = customPos or UDim2.new(0, 12, 0.5, -9)
		iconLabel.BackgroundTransparency = 1
		
		if typeof(iconImage) == "table" then
			iconLabel.Image = iconImage.Image or iconImage.Texture or ""
			iconLabel.ImageRectOffset = iconImage.ImageRectOffset or Vector2.new(0, 0)
			iconLabel.ImageRectSize = iconImage.ImageRectSize or Vector2.new(0, 0)
		elseif typeof(iconImage) == "string" then
			iconLabel.Image = iconImage
		end

		iconLabel.ImageColor3 = THEME.Text
		iconLabel.ImageTransparency = 0.1
		iconLabel.ZIndex = 3
		iconLabel.Parent = parent
		return 28
	end

	return 0
end

function AtheriumGUI.CreateWindow(titleText)
	local self = setmetatable({}, AtheriumGUI)
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Atherium_MacOS"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- Notification Container (Top Right)
	local notifHolder = Instance.new("Frame")
	notifHolder.Name = "NotifHolder"
	notifHolder.Size = UDim2.new(0, 300, 1, -30)
	notifHolder.Position = UDim2.new(1, -310, 0, 15)
	notifHolder.BackgroundTransparency = 1
	notifHolder.Parent = screenGui

	local notifLayout = Instance.new("UIListLayout")
	notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notifLayout.Padding = UDim.new(0, 10)
	notifLayout.Parent = notifHolder

	-- Main Window Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 500, 0, 380)
	mainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
	mainFrame.BackgroundColor3 = THEME.GlassBackground
	mainFrame.BackgroundTransparency = THEME.GlassTransparency
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	addCorner(mainFrame, 20)
	addGlassStroke(mainFrame, 0.75)

	-- Window Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 46)
	header.BackgroundColor3 = THEME.Header
	header.BackgroundTransparency = 0.4
	header.BorderSizePixel = 0
	header.Parent = mainFrame
	addCorner(header, 20)

	-- macOS Traffic Lights Buttons
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 12, 0, 12)
	closeBtn.Position = UDim2.new(0, 16, 0.5, -6)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
	closeBtn.Text = ""
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = header
	addCorner(closeBtn, 6)

	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	local minBtn = Instance.new("Frame")
	minBtn.Size = UDim2.new(0, 12, 0, 12)
	minBtn.Position = UDim2.new(0, 34, 0.5, -6)
	minBtn.BackgroundColor3 = Color3.fromRGB(254, 188, 46)
	minBtn.Parent = header
	addCorner(minBtn, 6)

	local maxBtn = Instance.new("Frame")
	maxBtn.Size = UDim2.new(0, 12, 0, 12)
	maxBtn.Position = UDim2.new(0, 52, 0.5, -6)
	maxBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 64)
	maxBtn.Parent = header
	addCorner(maxBtn, 6)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -80, 1, 0)
	title.Position = UDim2.new(0, 74, 0, 0)
	title.Text = titleText or "Atherium macOS"
	title.TextColor3 = THEME.Text
	title.TextSize = 14
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.BackgroundTransparency = 1
	title.Parent = header

	local container = Instance.new("ScrollingFrame")
	container.Name = "Container"
	container.Size = UDim2.new(1, -24, 1, -58)
	container.Position = UDim2.new(0, 12, 0, 52)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ScrollBarThickness = 2
	container.ScrollBarImageColor3 = THEME.SubText
	container.Parent = mainFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = container

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 4)
	padding.Parent = container

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
	end)

	-- Dragging Logic
	local dragging, dragStart, startPos
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)

	header.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Toggle Menu Visibility Key
	local visible = true
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
			visible = not visible
			mainFrame.Visible = visible
		end
	end)

	self.ScreenGui = screenGui
	self.Container = container
	self.NotifHolder = notifHolder
	return self
end

-- Premium iOS 18 Notifications
function AtheriumGUI:Notify(titleText, descText, duration, notifType)
	duration = duration or 3.5
	notifType = notifType or "info" -- info, success, warning, error

	local typeColors = {
		info = THEME.Accent,
		success = THEME.Success,
		warning = THEME.Warning,
		error = THEME.Error
	}
	
	local typeIcons = {
		info = "info",
		success = "check-circle",
		warning = "alert-triangle",
		error = "x-circle"
	}

	local accentColor = typeColors[notifType] or THEME.Accent
	local iconName = typeIcons[notifType] or "bell"

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 62)
	notif.BackgroundColor3 = THEME.GlassBackground
	notif.BackgroundTransparency = 0.15
	notif.ClipsDescendants = true
	notif.Parent = self.NotifHolder
	addCorner(notif, 14)
	addGlassStroke(notif, 0.7)

	-- Indicator Line
	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, 4, 1, -16)
	line.Position = UDim2.new(0, 6, 0, 8)
	line.BackgroundColor3 = accentColor
	line.BorderSizePixel = 0
	line.Parent = notif
	addCorner(line, 2)

	-- Notification Icon
	createIcon(notif, iconName, UDim2.new(0, 20, 0, 20), UDim2.new(0, 18, 0, 12))

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -50, 0, 18)
	titleLabel.Position = UDim2.new(0, 46, 0, 10)
	titleLabel.Text = titleText
	titleLabel.TextColor3 = THEME.Text
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = notif

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -50, 0, 24)
	descLabel.Position = UDim2.new(0, 46, 0, 28)
	descLabel.Text = descText
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 11
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextWrapped = true
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.BackgroundTransparency = 1
	descLabel.Parent = notif

	-- Duration Progress Bar
	local progressBar = Instance.new("Frame")
	progressBar.Size = UDim2.new(1, 0, 0, 2)
	progressBar.Position = UDim2.new(0, 0, 1, -2)
	progressBar.BackgroundColor3 = accentColor
	progressBar.BorderSizePixel = 0
	progressBar.Parent = notif

	-- Animation: Slide In
	notif.Position = UDim2.new(1, 100, 0, 0)
	TweenService:Create(notif, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
	TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()

	task.delay(duration, function()
		local dismiss = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 100, 0, 0), BackgroundTransparency = 1})
		dismiss:Play()
		dismiss.Completed:Connect(function()
			notif:Destroy()
		end)
	end)
end

-- Section Divider Header
function AtheriumGUI:AddSection(text)
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Size = UDim2.new(1, 0, 0, 24)
	sectionFrame.BackgroundTransparency = 1
	sectionFrame.Parent = self.Container

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Position = UDim2.new(0, 4, 0, 2)
	label.Text = string.upper(text)
	label.TextColor3 = THEME.SubText
	label.TextSize = 10
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = sectionFrame
end

-- macOS Button
function AtheriumGUI:AddButton(text, iconName, callback)
	if type(iconName) == "function" then
		callback = iconName
		iconName = nil
	end

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 38)
	button.BackgroundColor3 = THEME.Card
	button.BackgroundTransparency = THEME.CardTransparency
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = self.Container
	addCorner(button, 12)
	addGlassStroke(button, 0.85)

	local iconOffset = createIcon(button, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -(14 + iconOffset), 1, 0)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = button

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.CardHover, BackgroundTransparency = 0.2}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Card, BackgroundTransparency = THEME.CardTransparency}):Play()
	end)
	button.MouseButton1Down:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.98, 0, 0, 36)}):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 38)}):Play()
		if callback then callback() end
	end)
end

-- Toggle Switch
function AtheriumGUI:AddToggle(text, iconName, defaultState, callback)
	if type(iconName) == "boolean" then
		callback = defaultState
		defaultState = iconName
		iconName = nil
	end

	local state = defaultState or false
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(1, 0, 0, 40)
	toggleFrame.BackgroundColor3 = THEME.Card
	toggleFrame.BackgroundTransparency = THEME.CardTransparency
	toggleFrame.Parent = self.Container
	addCorner(toggleFrame, 12)
	addGlassStroke(toggleFrame, 0.85)

	local iconOffset = createIcon(toggleFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -(65 + iconOffset), 1, 0)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = toggleFrame

	local switchBG = Instance.new("Frame")
	switchBG.Size = UDim2.new(0, 42, 0, 22)
	switchBG.Position = UDim2.new(1, -52, 0.5, -11)
	switchBG.BackgroundColor3 = state and THEME.Success or Color3.fromRGB(60, 60, 72)
	switchBG.Parent = toggleFrame
	addCorner(switchBG, 11)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 18, 0, 18)
	circle.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.Parent = switchBG
	addCorner(circle, 9)

	local clickBtn = Instance.new("TextButton")
	clickBtn.Size = UDim2.new(1, 0, 1, 0)
	clickBtn.BackgroundTransparency = 1
	clickBtn.Text = ""
	clickBtn.Parent = toggleFrame

	clickBtn.MouseButton1Click:Connect(function()
		state = not state
		local springInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		TweenService:Create(switchBG, springInfo, {BackgroundColor3 = state and THEME.Success or Color3.fromRGB(60, 60, 72)}):Play()
		TweenService:Create(circle, springInfo, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
		if callback then callback(state) end
	end)
end

-- Slider
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
	sliderFrame.Size = UDim2.new(1, 0, 0, 50)
	sliderFrame.BackgroundColor3 = THEME.Card
	sliderFrame.BackgroundTransparency = THEME.CardTransparency
	sliderFrame.Parent = self.Container
	addCorner(sliderFrame, 12)
	addGlassStroke(sliderFrame, 0.85)

	local iconOffset = createIcon(sliderFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -(70 + iconOffset), 0, 22)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 5)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = sliderFrame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0, 22)
	valueLabel.Position = UDim2.new(1, -62, 0, 5)
	valueLabel.Text = tostring(defaultVal)
	valueLabel.TextColor3 = THEME.SubText
	valueLabel.TextSize = 12
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.BackgroundTransparency = 1
	valueLabel.Parent = sliderFrame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -24, 0, 5)
	track.Position = UDim2.new(0, 12, 1, -14)
	track.BackgroundColor3 = Color3.fromRGB(60, 60, 72)
	track.Parent = sliderFrame
	addCorner(track, 3)

	local initialPercent = (defaultVal - minVal) / (maxVal - minVal)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(initialPercent, 0, 1, 0)
	fill.BackgroundColor3 = THEME.Accent
	fill.Parent = track
	addCorner(fill, 3)

	local handle = Instance.new("Frame")
	handle.Size = UDim2.new(0, 13, 0, 13)
	handle.Position = UDim2.new(1, -6, 0.5, -6)
	handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	handle.Parent = fill
	addCorner(handle, 7)

	local isSliding = false

	local function updateSlider(input)
		local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = math.floor(minVal + (maxVal - minVal) * percent)
		
		TweenService:Create(fill, TweenInfo.new(0.05), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
		valueLabel.Text = tostring(value)
		if callback then callback(value) end
	end

	sliderFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isSliding = true
			updateSlider(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isSliding = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)
end

-- TextBox Field
function AtheriumGUI:AddTextBox(text, iconName, placeholder, callback)
	if type(iconName) == "string" and not callback and placeholder == nil then
		placeholder = iconName
		iconName = nil
	end

	local textBoxFrame = Instance.new("Frame")
	textBoxFrame.Size = UDim2.new(1, 0, 0, 42)
	textBoxFrame.BackgroundColor3 = THEME.Card
	textBoxFrame.BackgroundTransparency = THEME.CardTransparency
	textBoxFrame.Parent = self.Container
	addCorner(textBoxFrame, 12)
	addGlassStroke(textBoxFrame, 0.85)

	local iconOffset = createIcon(textBoxFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, -iconOffset, 1, 0)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = textBoxFrame

	local boxBG = Instance.new("Frame")
	boxBG.Size = UDim2.new(0.5, 0, 0, 26)
	boxBG.Position = UDim2.new(0.5, -12, 0.5, -13)
	boxBG.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	boxBG.Parent = textBoxFrame
	addCorner(boxBG, 8)
	addGlassStroke(boxBG, 0.9)

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1, -12, 1, 0)
	textBox.Position = UDim2.new(0, 6, 0, 0)
	textBox.PlaceholderText = placeholder or "Enter text..."
	textBox.PlaceholderColor3 = THEME.SubText
	textBox.Text = ""
	textBox.TextColor3 = THEME.Text
	textBox.TextSize = 12
	textBox.Font = Enum.Font.Gotham
	textBox.BackgroundTransparency = 1
	textBox.ClearTextOnFocus = false
	textBox.Parent = boxBG

	textBox.FocusLost:Connect(function(enterPressed)
		if callback then callback(textBox.Text, enterPressed) end
	end)
end

-- Animated Dropdown
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
	dropdownFrame.Size = UDim2.new(1, 0, 0, 42)
	dropdownFrame.BackgroundColor3 = THEME.Card
	dropdownFrame.BackgroundTransparency = THEME.CardTransparency
	dropdownFrame.ClipsDescendants = true
	dropdownFrame.Parent = self.Container
	addCorner(dropdownFrame, 12)
	addGlassStroke(dropdownFrame, 0.85)

	local iconOffset = createIcon(dropdownFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, -iconOffset, 0, 42)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = dropdownFrame

	local selectedLabel = Instance.new("TextLabel")
	selectedLabel.Size = UDim2.new(0.4, -20, 0, 42)
	selectedLabel.Position = UDim2.new(0.6, -20, 0, 0)
	selectedLabel.Text = selected
	selectedLabel.TextColor3 = THEME.SubText
	selectedLabel.TextSize = 12
	selectedLabel.Font = Enum.Font.Gotham
	selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
	selectedLabel.BackgroundTransparency = 1
	selectedLabel.Parent = dropdownFrame

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 20, 0, 42)
	arrow.Position = UDim2.new(1, -28, 0, 0)
	arrow.Text = "v"
	arrow.TextColor3 = THEME.SubText
	arrow.TextSize = 12
	arrow.Font = Enum.Font.GothamBold
	arrow.BackgroundTransparency = 1
	arrow.Parent = dropdownFrame

	local optContainer = Instance.new("Frame")
	optContainer.Size = UDim2.new(1, -24, 0, #options * 28)
	optContainer.Position = UDim2.new(0, 12, 0, 42)
	optContainer.BackgroundTransparency = 1
	optContainer.Parent = dropdownFrame

	local optLayout = Instance.new("UIListLayout")
	optLayout.Padding = UDim.new(0, 2)
	optLayout.Parent = optContainer

	for _, opt in ipairs(options) do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 26)
		optBtn.BackgroundColor3 = THEME.Header
		optBtn.BackgroundTransparency = 0.5
		optBtn.Text = opt
		optBtn.TextColor3 = THEME.Text
		optBtn.TextSize = 12
		optBtn.Font = Enum.Font.Gotham
		optBtn.Parent = optContainer
		addCorner(optBtn, 6)

		optBtn.MouseButton1Click:Connect(function()
			selected = opt
			selectedLabel.Text = selected
			expanded = false
			TweenService:Create(dropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 42)}):Play()
			TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
			if callback then callback(selected) end
		end)
	end

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(1, 0, 0, 42)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.Text = ""
	toggleBtn.Parent = dropdownFrame

	toggleBtn.MouseButton1Click:Connect(function()
		expanded = not expanded
		local targetHeight = expanded and (46 + #options * 28) or 42
		TweenService:Create(dropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
		TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = expanded and 180 or 0}):Play()
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
	bindFrame.Size = UDim2.new(1, 0, 0, 40)
	bindFrame.BackgroundColor3 = THEME.Card
	bindFrame.BackgroundTransparency = THEME.CardTransparency
	bindFrame.Parent = self.Container
	addCorner(bindFrame, 12)
	addGlassStroke(bindFrame, 0.85)

	local iconOffset = createIcon(bindFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, -iconOffset, 1, 0)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = bindFrame

	local keyBtn = Instance.new("TextButton")
	keyBtn.Size = UDim2.new(0, 70, 0, 24)
	keyBtn.Position = UDim2.new(1, -82, 0.5, -12)
	keyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	keyBtn.Text = currentKey.Name
	keyBtn.TextColor3 = THEME.Accent
	keyBtn.TextSize = 11
	keyBtn.Font = Enum.Font.GothamBold
	keyBtn.Parent = bindFrame
	addCorner(keyBtn, 6)
	addGlassStroke(keyBtn, 0.9)

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
