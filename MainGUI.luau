local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local AtheriumGUI = {}
AtheriumGUI.__index = AtheriumGUI

-- Динамическая подгрузка библиотеки иконок с GitHub
local Icons = nil
local success, err = pcall(function()
	Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	if Icons and Icons.SetIconsType then
		Icons.SetIconsType("lucide")
	end
end)

if not success then
	warn("Не удалось подгрузить Footagesus/Icons с GitHub:", err)
end

local THEME = {
	Background = Color3.fromRGB(24, 24, 28),
	Header = Color3.fromRGB(30, 30, 36),
	Card = Color3.fromRGB(34, 34, 40),
	Button = Color3.fromRGB(45, 45, 54),
	ButtonHover = Color3.fromRGB(58, 58, 70),
	Accent = Color3.fromRGB(114, 137, 218),
	Text = Color3.fromRGB(240, 240, 245),
}

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

-- Создание иконки через Footagesus Icons API
local function createIcon(parent, iconName)
	if not iconName or type(iconName) ~= "string" or not Icons then return 0 end

	local iconImage = nil
	local getSuccess = pcall(function()
		if typeof(Icons.GetIcon) == "function" then
			iconImage = Icons.GetIcon(iconName)
		elseif typeof(Icons.CreateIcon) == "function" then
			iconImage = Icons.CreateIcon(iconName)
		end
	end)

	if getSuccess and iconImage then
		local iconLabel = Instance.new("ImageLabel")
		iconLabel.Name = "Icon"
		iconLabel.Size = UDim2.new(0, 18, 0, 18)
		iconLabel.Position = UDim2.new(0, 10, 0.5, -9)
		iconLabel.BackgroundTransparency = 1
		
		if typeof(iconImage) == "table" then
			iconLabel.Image = iconImage.Image or iconImage.Texture or ""
			iconLabel.ImageRectOffset = iconImage.ImageRectOffset or Vector2.new(0, 0)
			iconLabel.ImageRectSize = iconImage.ImageRectSize or Vector2.new(0, 0)
		elseif typeof(iconImage) == "string" then
			iconLabel.Image = iconImage
		end

		iconLabel.ImageColor3 = THEME.Text
		iconLabel.ZIndex = 3
		iconLabel.Parent = parent
		return 26
	end

	return 0
end

function AtheriumGUI.CreateWindow(titleText)
	local self = setmetatable({}, AtheriumGUI)
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Atherium_Container"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 480, 0, 340)
	mainFrame.Position = UDim2.new(0.5, -240, 0.5, -170)
	mainFrame.BackgroundColor3 = THEME.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	addCorner(mainFrame, 12)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(50, 50, 60)
	stroke.Thickness = 1.5
	stroke.Parent = mainFrame

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 42)
	header.BackgroundColor3 = THEME.Header
	header.BorderSizePixel = 0
	header.Parent = mainFrame
	addCorner(header, 12)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.Text = titleText or "Atherium Hub"
	title.TextColor3 = THEME.Text
	title.TextSize = 16
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.BackgroundTransparency = 1
	title.Parent = header

	local container = Instance.new("ScrollingFrame")
	container.Name = "Container"
	container.Size = UDim2.new(1, -20, 1, -52)
	container.Position = UDim2.new(0, 10, 0, 47)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ScrollBarThickness = 3
	container.ScrollBarImageColor3 = THEME.Accent
	container.Parent = mainFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = container

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.Parent = container

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
	end)

	-- Логика перетаскивания (Drag)
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
	return self
end

-- Кнопка
function AtheriumGUI:AddButton(text, iconName, callback)
	if type(iconName) == "function" then
		callback = iconName
		iconName = nil
	end

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 38)
	button.BackgroundColor3 = THEME.Button
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = self.Container
	addCorner(button, 8)

	local iconOffset = createIcon(button, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -(10 + iconOffset), 1, 0)
	label.Position = UDim2.new(0, 10 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 14
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = button

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.ButtonHover}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Button}):Play()
	end)
	button.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)
end

-- Тогл (Переключатель)
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
	toggleFrame.Parent = self.Container
	addCorner(toggleFrame, 8)

	local iconOffset = createIcon(toggleFrame, iconName)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -(60 + iconOffset), 1, 0)
	label.Position = UDim2.new(0, 10 + iconOffset, 0, 0)
	label.Text = text
	label.TextColor3 = THEME.Text
	label.TextSize = 14
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = toggleFrame

	local switchBG = Instance.new("Frame")
	switchBG.Size = UDim2.new(0, 42, 0, 22)
	switchBG.Position = UDim2.new(1, -52, 0.5, -11)
	switchBG.BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(50, 50, 60)
	switchBG.Parent = toggleFrame
	addCorner(switchBG, 12)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 16, 0, 16)
	circle.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
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
		TweenService:Create(switchBG, TweenInfo.new(0.2), {BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(50, 50, 60)}):Play()
		TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
		if callback then callback(state) end
	end)
end

return AtheriumGUI
