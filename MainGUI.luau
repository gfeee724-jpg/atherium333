local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = game:GetService("Players").LocalPlayer

local AtheriumGUI = {}
AtheriumGUI.__index = AtheriumGUI

-- Включение размытия заднего плана (Blur/Glass Effect)
local blurEffect = Lighting:FindFirstChild("AtheriumGlassBlur")
if not blurEffect then
	blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "AtheriumGlassBlur"
	blurEffect.Size = 12
	blurEffect.Enabled = true
	blurEffect.Parent = Lighting
end

-- Динамическая подгрузка иконок
local Icons = nil
pcall(function()
	Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	if Icons and Icons.SetIconsType then
		Icons.SetIconsType("lucide")
	end
end)

-- Палитра iOS / macOS Dynamic Dark Mode
local THEME = {
	GlassBackground = Color3.fromRGB(25, 25, 30),
	GlassTransparency = 0.35,
	Header = Color3.fromRGB(35, 35, 42),
	Card = Color3.fromRGB(40, 40, 50),
	CardTransparency = 0.4,
	Button = Color3.fromRGB(50, 50, 62),
	ButtonHover = Color3.fromRGB(65, 65, 80),
	
	-- iOS System Colors
	Accent = Color3.fromRGB(10, 132, 255),       -- iOS System Blue
	Success = Color3.fromRGB(52, 199, 89),       -- iOS System Green
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

-- Эффект тонкой стеклянной каемки macOS
local function addGlassStroke(parent, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.GlassBorder
	stroke.Thickness = 1
	stroke.Transparency = transparency or 0.82
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function createIcon(parent, iconName)
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
		iconLabel.Size = UDim2.new(0, 18, 0, 18)
		iconLabel.Position = UDim2.new(0, 12, 0.5, -9)
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

	-- Уведомления iOS Style
	local notifHolder = Instance.new("Frame")
	notifHolder.Name = "NotifHolder"
	notifHolder.Size = UDim2.new(0, 280, 1, -20)
	notifHolder.Position = UDim2.new(1, -290, 0, 15)
	notifHolder.BackgroundTransparency = 1
	notifHolder.Parent = screenGui

	local notifLayout = Instance.new("UIListLayout")
	notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notifLayout.Padding = UDim.new(0, 10)
	notifLayout.Parent = notifHolder

	-- Главный фрейм (macOS Window)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 480, 0, 360)
	mainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
	mainFrame.BackgroundColor3 = THEME.GlassBackground
	mainFrame.BackgroundTransparency = THEME.GlassTransparency
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	addCorner(mainFrame, 20)
	addGlassStroke(mainFrame, 0.75)

	-- Верхний бар macOS с фирменными кнопками (Traffic Lights)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 46)
	header.BackgroundColor3 = THEME.Header
	header.BackgroundTransparency = 0.5
	header.BorderSizePixel = 0
	header.Parent = mainFrame
	addCorner(header, 20)

	-- macOS Window Controls (Красная, желтая, зеленая точки)
	local dots = {
		{ Color3.fromRGB(255, 95, 87), 16 },  -- Close
		{ Color3.fromRGB(254, 188, 46), 32 }, -- Minimize
		{ Color3.fromRGB(40, 200, 64), 48 }   -- Expand
	}
	for _, dot in ipairs(dots) do
		local circle = Instance.new("Frame")
		circle.Size = UDim2.new(0, 10, 0, 10)
		circle.Position = UDim2.new(0, dot[2], 0.5, -5)
		circle.BackgroundColor3 = dot[1]
		circle.BorderSizePixel = 0
		circle.Parent = header
		addCorner(circle, 5)
	end

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -80, 1, 0)
	title.Position = UDim2.new(0, 68, 0, 0)
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
	container.ScrollBarThickness = 0 -- Минимализм Apple
	container.Parent = mainFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = container

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.Parent = container

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
	end)

	-- Drag Logic
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

	self.Container = container
	self.NotifHolder = notifHolder
	return self
end

-- iOS Banner Notifications
function AtheriumGUI:Notify(titleText, descText, duration)
	duration = duration or 3
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 56)
	notif.BackgroundColor3 = THEME.GlassBackground
	notif.BackgroundTransparency = 0.2
	notif.Parent = self.NotifHolder
	addCorner(notif, 16)
	addGlassStroke(notif, 0.7)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -24, 0, 20)
	titleLabel.Position = UDim2.new(0, 12, 0, 8)
	titleLabel.Text = titleText
	titleLabel.TextColor3 = THEME.Text
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = notif

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -24, 0, 18)
	descLabel.Position = UDim2.new(0, 12, 0, 28)
	descLabel.Text = descText
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 12
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.BackgroundTransparency = 1
	descLabel.Parent = notif

	-- Появление с iOS Spring эффектом
	notif.Position = UDim2.new(1, 50, 0, 0)
	TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

	task.delay(duration, function()
		local dismiss = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
		dismiss:Play()
		dismiss.Completed:Connect(function()
			notif:Destroy()
		end)
	end)
end

-- macOS Button
function AtheriumGUI:AddButton(text, iconName, callback)
	if type(iconName) == "function" then
		callback = iconName
		iconName = nil
	end

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 40)
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
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.ButtonHover, BackgroundTransparency = 0.2}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Card, BackgroundTransparency = THEME.CardTransparency}):Play()
	end)
	button.MouseButton1Down:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.98, 0, 0, 38)}):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 40)}):Play()
		if callback then callback() end
	end)
end

-- iOS Style Toggle Switch
function AtheriumGUI:AddToggle(text, iconName, defaultState, callback)
	if type(iconName) == "boolean" then
		callback = defaultState
		defaultState = iconName
		iconName = nil
	end

	local state = defaultState or false
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(1, 0, 0, 42)
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

	-- Фирменный переключатель iOS (Зеленый тумблер)
	local switchBG = Instance.new("Frame")
	switchBG.Size = UDim2.new(0, 44, 0, 24)
	switchBG.Position = UDim2.new(1, -54, 0.5, -12)
	switchBG.BackgroundColor3 = state and THEME.Success or Color3.fromRGB(60, 60, 72)
	switchBG.Parent = toggleFrame
	addCorner(switchBG, 12)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 20, 0, 20)
	circle.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.Parent = switchBG
	addCorner(circle, 10)

	local clickBtn = Instance.new("TextButton")
	clickBtn.Size = UDim2.new(1, 0, 1, 0)
	clickBtn.BackgroundTransparency = 1
	clickBtn.Text = ""
	clickBtn.Parent = toggleFrame

	clickBtn.MouseButton1Click:Connect(function()
		state = not state
		local springInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		TweenService:Create(switchBG, springInfo, {BackgroundColor3 = state and THEME.Success or Color3.fromRGB(60, 60, 72)}):Play()
		TweenService:Create(circle, springInfo, {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
		if callback then callback(state) end
	end)
end

-- iOS Control Center Slider с круглым бегунком
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
	sliderFrame.Size = UDim2.new(1, 0, 0, 52)
	sliderFrame.BackgroundColor3 = THEME.Card
	sliderFrame.BackgroundTransparency = THEME.CardTransparency
	sliderFrame.Parent = self.Container
	addCorner(sliderFrame, 12)
	addGlassStroke(sliderFrame, 0.85)

	local iconOffset = createIcon(sliderFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -(70 + iconOffset), 0, 22)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 6)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = sliderFrame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0, 22)
	valueLabel.Position = UDim2.new(1, -62, 0, 6)
	valueLabel.Text = tostring(defaultVal)
	valueLabel.TextColor3 = THEME.SubText
	valueLabel.TextSize = 12
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.BackgroundTransparency = 1
	valueLabel.Parent = sliderFrame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -24, 0, 6)
	track.Position = UDim2.new(0, 12, 1, -16)
	track.BackgroundColor3 = Color3.fromRGB(60, 60, 72)
	track.Parent = sliderFrame
	addCorner(track, 3)

	local initialPercent = (defaultVal - minVal) / (maxVal - minVal)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(initialPercent, 0, 1, 0)
	fill.BackgroundColor3 = THEME.Accent
	fill.Parent = track
	addCorner(fill, 3)

	-- Круглый Handle (как в iOS)
	local handle = Instance.new("Frame")
	handle.Size = UDim2.new(0, 14, 0, 14)
	handle.Position = UDim2.new(1, -7, 0.5, -7)
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

return AtheriumGUI
