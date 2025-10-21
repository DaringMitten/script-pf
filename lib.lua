-- Clean UI Library (No Background Image)
-- Based on the original ALCATRAZ/PF UI system

local Library = {Toggle = true, FirstTab = nil, TabCount = 0, ColorTable = {}}

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Simple drag function
local function MakeDraggable(ClickObject, Object)
	local Dragging, DragInput, DragStart, StartPosition

	ClickObject.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			DragStart = Input.Position
			StartPosition = Object.Position

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	ClickObject.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			DragInput = Input
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - DragStart
			Object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		end
	end)
end

function Library:CreateWindow(Config, Parent)
	local WindowInit = {}
	local Folder = game:GetObjects("rbxassetid://7141683860")[1]
	local Screen = Folder.Bracket:Clone()
	local Main = Screen.Main
	local Holder = Main.Holder
	local Topbar = Main.Topbar
	local TContainer = Holder.TContainer
	local TBContainer = Holder.TBContainer.Holder

	-- 🧱 Plain background (no image)
	Holder.Image = ""
	Holder.ImageTransparency = 1
	Holder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

	Screen.Name = HttpService:GenerateGUID(false)
	Screen.Parent = Parent
	Topbar.WindowName.Text = Config.WindowName

	MakeDraggable(Topbar, Main)

	local function CloseAll()
		for _, Tab in pairs(TContainer:GetChildren()) do
			if Tab:IsA("ScrollingFrame") then
				Tab.Visible = false
			end
		end
	end

	local function ResetAll()
		for _, TabButton in pairs(TBContainer:GetChildren()) do
			if TabButton:IsA("TextButton") then
				TabButton.BackgroundTransparency = 1
				TabButton.Size = UDim2.new(0, 480 / Library.TabCount, 1, 0)
			end
		end
		for _, Pallete in pairs(Screen:GetChildren()) do
			if Pallete:IsA("Frame") and Pallete.Name ~= "Main" then
				Pallete.Visible = false
			end
		end
	end

	local function KeepFirst()
		for _, Tab in pairs(TContainer:GetChildren()) do
			if Tab:IsA("ScrollingFrame") then
				Tab.Visible = (Tab.Name == Library.FirstTab .. " T")
			end
		end
		for _, TabButton in pairs(TBContainer:GetChildren()) do
			if TabButton:IsA("TextButton") then
				TabButton.BackgroundTransparency = (TabButton.Name == Library.FirstTab .. " TB") and 0 or 1
			end
		end
	end

	local function Toggle(State)
		Main.Visible = State
		Library.Toggle = State
		if not State then
			for _, Pallete in pairs(Screen:GetChildren()) do
				if Pallete:IsA("Frame") and Pallete.Name ~= "Main" then
					Pallete.Visible = false
				end
			end
			Screen.ToolTip.Visible = false
		end
	end

	local function ChangeColor(Color)
		Config.Color = Color
		for _, v in pairs(Library.ColorTable) do
			if v.BackgroundColor3 ~= Color3.fromRGB(50, 50, 50) then
				v.BackgroundColor3 = Color
			end
		end
	end

	function WindowInit:Toggle(State)
		Toggle(State)
	end

	function WindowInit:ChangeColor(Color)
		ChangeColor(Color)
	end

	function WindowInit:SetBackgroundColor(Color)
		Holder.BackgroundColor3 = Color
	end

	function WindowInit:SetBackgroundTransparency(Transparency)
		Holder.BackgroundTransparency = Transparency
	end

	RunService.RenderStepped:Connect(function()
		if Library.Toggle then
			local mousePos = UserInputService:GetMouseLocation()
			Screen.ToolTip.Position = UDim2.new(0, mousePos.X + 10, 0, mousePos.Y - 5)
		end
	end)

	-- ===========================
	-- Tab System
	-- ===========================
	function WindowInit:CreateTab(Name)
		local TabInit = {}
		local Tab = Folder.Tab:Clone()
		local TabButton = Folder.TabButton:Clone()

		Tab.Name = Name .. " T"
		Tab.Parent = TContainer

		TabButton.Name = Name .. " TB"
		TabButton.Parent = TBContainer
		TabButton.Title.Text = Name
		TabButton.BackgroundColor3 = Config.Color

		table.insert(Library.ColorTable, TabButton)
		Library.TabCount += 1
		if Library.TabCount == 1 then
			Library.FirstTab = Name
		end

		CloseAll()
		ResetAll()
		KeepFirst()

		local function GetSide(Longest)
			if Longest then
				return (Tab.LeftSide.ListLayout.AbsoluteContentSize.Y > Tab.RightSide.ListLayout.AbsoluteContentSize.Y)
					and Tab.LeftSide or Tab.RightSide
			else
				return (Tab.LeftSide.ListLayout.AbsoluteContentSize.Y > Tab.RightSide.ListLayout.AbsoluteContentSize.Y)
					and Tab.RightSide or Tab.LeftSide
			end
		end

		TabButton.MouseButton1Click:Connect(function()
			CloseAll()
			ResetAll()
			Tab.Visible = true
			TabButton.BackgroundTransparency = 0
		end)

		Tab.LeftSide.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			local Side = GetSide(true)
			Tab.CanvasSize = UDim2.new(0, 0, 0, Side.ListLayout.AbsoluteContentSize.Y + 15)
		end)

		Tab.RightSide.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			local Side = GetSide(true)
			Tab.CanvasSize = UDim2.new(0, 0, 0, Side.ListLayout.AbsoluteContentSize.Y + 15)
		end)

		-- Sections, toggles, sliders, etc. (same as before)
		function TabInit:CreateSection(Name)
			local SectionInit = {}
			local Section = Folder.Section:Clone()
			local Side = GetSide(false)

			Section.Title.Text = Name
			Section.Parent = Side

			function SectionInit:CreateToggle(Text, Default, Callback)
				local Toggle = Folder.Toggle:Clone()
				Toggle.Title.Text = Text
				Toggle.Parent = Section.Holder
				Toggle.Switch.BackgroundColor3 = Default and Config.Color or Color3.fromRGB(50, 50, 50)

				local Value = Default

				Toggle.Button.MouseButton1Click:Connect(function()
					Value = not Value
					TweenService:Create(Toggle.Switch, TweenInfo.new(0.15), {
						BackgroundColor3 = Value and Config.Color or Color3.fromRGB(50, 50, 50)
					}):Play()
					Callback(Value)
				end)

				function Toggle:Set(State)
					Value = State
					Toggle.Switch.BackgroundColor3 = Value and Config.Color or Color3.fromRGB(50, 50, 50)
					Callback(Value)
				end

				function Toggle:AddToolTip(Text)
					Toggle.ToolTip.Text = Text
				end

				Toggle.Value = Value
				return Toggle
			end

			return SectionInit
		end

		return TabInit
	end

	return WindowInit
end

getgenv().library = Library
