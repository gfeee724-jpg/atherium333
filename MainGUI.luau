local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local AtheriumGUI = {}
AtheriumGUI.__index = AtheriumGUI

-- ============ BLUR EFFECT ============
local blurEffect = Lighting:FindFirstChild("AtheriumGlassBlur")
if not blurEffect then
	blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "AtheriumGlassBlur"
	blurEffect.Size = 12
	blurEffect.Enabled = true
	blurEffect.Parent = Lighting
end

-- ============ ICONS ============
local Icons = nil
pcall(function()
	Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	if Icons and Icons.SetIconsType then
		Icons.SetIconsType("lucide")
	end
end)

-- ============ THEME ============
local THEME = {
	GlassBackground   = Color3.fromRGB(25, 25, 30),
	GlassTransparency = 0.35,
	Header            = Color3.fromRGB(35, 35, 42),
	Card              = Color3.fromRGB(40, 40, 50),
	CardTransparency  = 0.4,
	Button            = Color3.fromRGB(50, 50, 62),
	ButtonHover       = Color3.fromRGB(65, 65, 80),
	
	Accent     = Color3.fromRGB(10, 132, 255),
	Success    = Color3.fromRGB(52, 199, 89),
	Warning    = Color3.fromRGB(255, 159, 10),
	Danger     = Color3.fromRGB(255, 69, 58),
	Purple     = Color3.fromRGB(175, 82, 222),
	
	Text       = Color3.fromRGB(255, 255, 255),
	SubText    = Color3.fromRGB(160, 160, 175),
	GlassBorder= Color3.fromRGB(255, 255, 255),
}

-- ============ HELPERS ============
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
	stroke.Transparency = transparency or 0.82
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function createIcon(parent, iconName, size, color)
	if not iconName or type(iconName) ~= "string" or not Icons then return 0 end
	size = size or 18

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
		iconLabel.Size = UDim2.new(0, size, 0, size)
		iconLabel.Position = UDim2.new(0, 12, 0.5, -size/2)
		iconLabel.BackgroundTransparency = 1
		
		if typeof(iconImage) == "table" then
			iconLabel.Image = iconImage.Image or iconImage.Texture or ""
			iconLabel.ImageRectOffset = iconImage.ImageRectOffset or Vector2.new(0, 0)
			iconLabel.ImageRectSize = iconImage.ImageRectSize or Vector2.new(0, 0)
		elseif typeof(iconImage) == "string" then
			iconLabel.Image = iconImage
		end

		iconLabel.ImageColor3 = color or THEME.Text
		iconLabel.ImageTransparency = 0.1
		iconLabel.ZIndex = 3
		iconLabel.Parent = parent
		return size + 10
	end
	return 0
end

-- ============ ANIMATION HELPERS ============
local function spring(target, props, duration)
	duration = duration or 0.35
	local tween = TweenService:Create(target, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
	tween:Play()
	return tween
end

local function smooth(target, props, duration)
	duration = duration or 0.2
	local tween = TweenService:Create(target, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
	tween:Play()
	return tween
end

-- ============ WINDOW ============
function AtheriumGUI.CreateWindow(titleText)
	local self = setmetatable({}, AtheriumGUI)
	
	self.WindowSize = UDim2.new(0, 500, 0, 400)
	self.Minimized = false
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Atherium_MacOS"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- ============ NOTIFICATION HOLDER ============
	local notifHolder = Instance.new("Frame")
	notifHolder.Name = "NotifHolder"
	notifHolder.Size = UDim2.new(0, 320, 1, -30)
	notifHolder.Position = UDim2.new(1, -340, 0, 15)
	notifHolder.BackgroundTransparency = 1
	notifHolder.ZIndex = 100
	notifHolder.Parent = screenGui

	local notifLayout = Instance.new("UIListLayout")
	notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	notifLayout.Padding = UDim.new(0, 10)
	notifLayout.Parent = notifHolder

	-- ============ MAIN WINDOW ============
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = self.WindowSize
	mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
	mainFrame.BackgroundColor3 = THEME.GlassBackground
	mainFrame.BackgroundTransparency = THEME.GlassTransparency
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	addCorner(mainFrame, 20)
	addGlassStroke(mainFrame, 0.75)

	-- Появление окна
	mainFrame.Size = UDim2.new(0, 500, 0, 0)
	mainFrame.BackgroundTransparency = 1
	spring(mainFrame, {Size = self.WindowSize, BackgroundTransparency = THEME.GlassTransparency}, 0.5)

	-- ============ HEADER ============
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 46)
	header.BackgroundColor3 = THEME.Header
	header.BackgroundTransparency = 0.5
	header.BorderSizePixel = 0
	header.Parent = mainFrame
	addCorner(header, 20)

	-- Точки macOS (кликабельные!)
	local closeBtn, minBtn, maxBtn
	
	local dots = {
		{ Color3.fromRGB(255, 95, 87), 16, "close" },
		{ Color3.fromRGB(254, 188, 46), 32, "min" },
		{ Color3.fromRGB(40, 200, 64), 48, "max" }
	}
	
	for _, dot in ipairs(dots) do
		local circle = Instance.new("TextButton")
		circle.Size = UDim2.new(0, 12, 0, 12)
		circle.Position = UDim2.new(0, dot[2] - 2, 0.5, -6)
		circle.BackgroundColor3 = dot[1]
		circle.BorderSizePixel = 0
		circle.Text = ""
		circle.AutoButtonColor = false
		circle.Parent = header
		addCorner(circle, 6)
		
		-- Символы внутри точек при ховере
		local symbol = Instance.new("TextLabel")
		symbol.Size = UDim2.new(1, 0, 1, 0)
		symbol.Text = ""
		symbol.TextColor3 = Color3.fromRGB(80, 0, 0)
		symbol.Font = Enum.Font.GothamBold
		symbol.TextSize = 9
		symbol.BackgroundTransparency = 1
		symbol.TextTransparency = 1
		symbol.Parent = circle
		
		circle.MouseEnter:Connect(function()
			smooth(symbol, {TextTransparency = 0})
			smooth(circle, {BackgroundColor3 = dot[1]:Lerp(Color3.new(1,1,1), 0.15)})
		end)
		circle.MouseLeave:Connect(function()
			smooth(symbol, {TextTransparency = 1})
			smooth(circle, {BackgroundColor3 = dot[1]})
		end)
		
		if dot[3] == "close" then
			closeBtn = circle
			symbol.Text = "✕"
			circle.MouseButton1Click:Connect(function()
				local fade = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
					Size = UDim2.new(0, 500, 0, 0),
					BackgroundTransparency = 1
				})
				fade:Play()
				fade.Completed:Connect(function()
					screenGui:Destroy()
					if blurEffect then blurEffect:Destroy() end
				end)
			end)
		elseif dot[3] == "min" then
			minBtn = circle
			symbol.Text = "−"
			circle.MouseButton1Click:Connect(function()
				self.Minimized = not self.Minimized
				if self.Minimized then
					smooth(mainFrame, {Size = UDim2.new(0, 500, 0, 46)}, 0.35)
				else
					smooth(mainFrame, {Size = self.WindowSize}, 0.35)
				end
			end)
		elseif dot[3] == "max" then
			maxBtn = circle
			symbol.Text = "+"
			circle.MouseButton1Click:Connect(function()
				if mainFrame.Size.Y.Offset < 500 then
					smooth(mainFrame, {Size = UDim2.new(0, 700, 0, 550)}, 0.35)
				else
					smooth(mainFrame, {Size = self.WindowSize}, 0.35)
				end
			end)
		end
	end

	-- Заголовок
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -160, 1, 0)
	title.Position = UDim2.new(0, 80, 0, 0)
	title.Text = titleText or "Atherium macOS"
	title.TextColor3 = THEME.Text
	title.TextSize = 14
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.BackgroundTransparency = 1
	title.Parent = header
	
	-- Время в правом углу
	local clock = Instance.new("TextLabel")
	clock.Size = UDim2.new(0, 60, 1, 0)
	clock.Position = UDim2.new(1, -70, 0, 0)
	clock.TextColor3 = THEME.SubText
	clock.TextSize = 12
	clock.Font = Enum.Font.GothamMedium
	clock.TextXAlignment = Enum.TextXAlignment.Right
	clock.BackgroundTransparency = 1
	clock.Parent = header
	
	task.spawn(function()
		while clock.Parent do
			clock.Text = os.date("%H:%M")
			task.wait(30)
		end
	end)

	-- ============ CONTAINER ============
	local container = Instance.new("ScrollingFrame")
	container.Name = "Container"
	container.Size = UDim2.new(1, -24, 1, -70)
	container.Position = UDim2.new(0, 12, 0, 58)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ScrollBarThickness = 2
	container.ScrollBarImageColor3 = THEME.SubText
	container.ScrollBarImageTransparency = 0.6
	container.CanvasSize = UDim2.new(0, 0, 0, 0)
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

	-- ============ DRAG LOGIC ============
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
	self.MainFrame = mainFrame
	self.ScreenGui = screenGui
	return self
end

-- ============ NOTIFICATIONS (iOS Style) ============
function AtheriumGUI:Notify(titleText, descText, duration, notifType)
	duration = duration or 3
	notifType = notifType or "info" -- info, success, warning, error
	
	local colors = {
		info = THEME.Accent,
		success = THEME.Success,
		warning = THEME.Warning,
		error = THEME.Danger,
	}
	local icons = {
		info = "info",
		success = "check-circle",
		warning = "alert-triangle",
		error = "x-circle",
	}
	local accentColor = colors[notifType] or THEME.Accent

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 70)
	notif.BackgroundColor3 = THEME.GlassBackground
	notif.BackgroundTransparency = 0.15
	notif.Parent = self.NotifHolder
	addCorner(notif, 16)
	addGlassStroke(notif, 0.7)
	
	-- Цветная полоска слева
	local accentBar = Instance.new("Frame")
	accentBar.Size = UDim2.new(0, 4, 0, 40)
	accentBar.Position = UDim2.new(0, 8, 0.5, -20)
	accentBar.BackgroundColor3 = accentColor
	accentBar.BorderSizePixel = 0
	accentBar.Parent = notif
	addCorner(accentBar, 2)
	
	-- Иконка
	local iconBox = Instance.new("Frame")
	iconBox.Size = UDim2.new(0, 36, 0, 36)
	iconBox.Position = UDim2.new(0, 18, 0.5, -18)
	iconBox.BackgroundColor3 = accentColor
	iconBox.BackgroundTransparency = 0.85
	iconBox.BorderSizePixel = 0
	iconBox.Parent = notif
	addCorner(iconBox, 10)
	
	createIcon(iconBox, icons[notifType], 20, accentColor)
	
	-- Смещение для иконки (по центру)
	local iconLbl = iconBox:FindFirstChild("Icon")
	if iconLbl then
		iconLbl.Position = UDim2.new(0, 8, 0, 8)
	end

	-- Заголовок
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -80, 0, 20)
	titleLabel.Position = UDim2.new(0, 64, 0, 14)
	titleLabel.Text = titleText
	titleLabel.TextColor3 = THEME.Text
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.Parent = notif

	-- Описание
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -80, 0, 18)
	descLabel.Position = UDim2.new(0, 64, 0, 34)
	descLabel.Text = descText
	descLabel.TextColor3 = THEME.SubText
	descLabel.TextSize = 12
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.BackgroundTransparency = 1
	descLabel.TextTruncate = Enum.TextTruncate.AtEnd
	descLabel.Parent = notif

	-- Прогресс-бар (таймер)
	local progressTrack = Instance.new("Frame")
	progressTrack.Size = UDim2.new(1, -20, 0, 3)
	progressTrack.Position = UDim2.new(0, 10, 1, -7)
	progressTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 72)
	progressTrack.BorderSizePixel = 0
	progressTrack.Parent = notif
	addCorner(progressTrack, 2)
	
	local progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.new(1, 0, 1, 0)
	progressFill.BackgroundColor3 = accentColor
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressTrack
	addCorner(progressFill, 2)
	
	TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 1, 0)
	}):Play()

	-- Появление (iOS spring)
	notif.Position = UDim2.new(1, 50, 0, 0)
	notif.BackgroundTransparency = 1
	local enterTween = TweenService:Create(notif, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 0.15
	})
	enterTween:Play()

	task.delay(duration, function()
		local dismiss = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 50, 0, 0),
			BackgroundTransparency = 1
		})
		dismiss:Play()
		dismiss.Completed:Connect(function()
			notif:Destroy()
		end)
	end)
end

-- ============ SECTION / LABEL ============
function AtheriumGUI:AddSection(text)
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Size = UDim2.new(1, 0, 0, 30)
	sectionFrame.BackgroundTransparency = 1
	sectionFrame.Parent = self.Container
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Position = UDim2.new(0, 6, 0, 0)
	label.Text = text:upper()
	label.TextColor3 = THEME.SubText
	label.TextSize = 11
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = sectionFrame
end

function AtheriumGUI:AddLabel(text, descText)
	local labelFrame = Instance.new("Frame")
	labelFrame.Size = UDim2.new(1, 0, 0, descText and 52 or 36)
	labelFrame.BackgroundColor3 = THEME.Card
	labelFrame.BackgroundTransparency = THEME.CardTransparency
	labelFrame.Parent = self.Container
	addCorner(labelFrame, 12)
	addGlassStroke(labelFrame, 0.9)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -24, 0, 20)
	label.Position = UDim2.new(0, 12, 0, descText and 8 or 8)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = labelFrame
	
	if descText then
		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(1, -24, 0, 18)
		desc.Position = UDim2.new(0, 12, 0, 28)
		desc.Text = descText
		desc.TextColor3 = THEME.SubText
		desc.TextSize = 11
		desc.Font = Enum.Font.Gotham
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.BackgroundTransparency = 1
		desc.Parent = labelFrame
	end
end

-- ============ DIVIDER ============
function AtheriumGUI:AddDivider()
	local div = Instance.new("Frame")
	div.Size = UDim2.new(1, -20, 0, 1)
	div.Position = UDim2.new(0, 10, 0, 0)
	div.BackgroundColor3 = THEME.SubText
	div.BackgroundTransparency = 0.7
	div.BorderSizePixel = 0
	div.Parent = self.Container
end

-- ============ BUTTON ============
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
	label.Size = UDim2.new(1, -(40 + iconOffset), 1, 0)
	label.Position = UDim2.new(0, 12 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = button
	
	-- Стрелка справа
	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.Position = UDim2.new(1, -26, 0, 0)
	arrow.Text = "›"
	arrow.TextColor3 = THEME.SubText
	arrow.TextSize = 20
	arrow.Font = Enum.Font.GothamBold
	arrow.BackgroundTransparency = 1
	arrow.Parent = button

	button.MouseEnter:Connect(function()
		smooth(button, {BackgroundColor3 = THEME.ButtonHover, BackgroundTransparency = 0.2})
		smooth(arrow, {TextColor3 = THEME.Text})
	end)
	button.MouseLeave:Connect(function()
		smooth(button, {BackgroundColor3 = THEME.Card, BackgroundTransparency = THEME.CardTransparency})
		smooth(arrow, {TextColor3 = THEME.SubText})
	end)
	button.MouseButton1Down:Connect(function()
		smooth(button, {Size = UDim2.new(0.98, 0, 0, 38)}, 0.1)
	end)
	button.MouseButton1Up:Connect(function()
		spring(button, {Size = UDim2.new(1, 0, 0, 40)}, 0.25)
		if callback then callback() end
	end)
end

-- ============ TOGGLE ============
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
		local springInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		TweenService:Create(switchBG, springInfo, {BackgroundColor3 = state and THEME.Success or Color3.fromRGB(60, 60, 72)}):Play()
		TweenService:Create(circle, springInfo, {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
		if callback then callback(state) end
	end)
end

-- ============ SLIDER ============
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
	sliderFrame.Size = UDim2.new(1, 0, 0, 54)
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

	local valueBox = Instance.new("Frame")
	valueBox.Size = UDim2.new(0, 50, 0, 20)
	valueBox.Position = UDim2.new(1, -62, 0, 7)
	valueBox.BackgroundColor3 = THEME.Accent
	valueBox.BackgroundTransparency = 0.85
	valueBox.Parent = sliderFrame
	addCorner(valueBox, 6)
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, 0, 1, 0)
	valueLabel.Text = tostring(defaultVal)
	valueLabel.TextColor3 = THEME.Accent
	valueLabel.TextSize = 12
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.BackgroundTransparency = 1
	valueLabel.Parent = valueBox

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -24, 0, 6)
	track.Position = UDim2.new(0, 12, 1, -18)
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
	handle.Size = UDim2.new(0, 14, 0, 14)
	handle.Position = UDim2.new(1, -7, 0.5, -7)
	handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	handle.Parent = fill
	addCorner(handle, 7)
	
	local handleShadow = Instance.new("UIStroke")
	handleShadow.Color = Color3.fromRGB(0, 0, 0)
	handleShadow.Thickness = 1
	handleShadow.Transparency = 0.7
	handleShadow.Parent = handle

	local isSliding = false
	local currentValue = defaultVal

	local function updateSlider(input)
		local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = math.floor(minVal + (maxVal - minVal) * percent + 0.5)
		
		if value ~= currentValue then
			currentValue = value
			TweenService:Create(fill, TweenInfo.new(0.05), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
			valueLabel.Text = tostring(value)
			if callback then callback(value) end
		end
	end

	sliderFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isSliding = true
			smooth(handle, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -9, 0.5, -9)}, 0.1)
			updateSlider(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if isSliding then
				isSliding = false
				smooth(handle, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7)}, 0.15)
			end
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)
end

-- ============ DROPDOWN ============
function AtheriumGUI:AddDropdown(text, iconName, options, callback)
	if type(iconName) == "table" then
		callback = options
		options = iconName
		iconName = nil
	end
	
	options = options or {}
	local selected = options[
