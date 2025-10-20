-- // Load the UI library
local lib = getgenv().library

-- // Create a main window
local window = lib:CreateWindow({
    WindowName = "My Game Control Panel",
    Color = Color3.fromRGB(0, 170, 255)
}, game.CoreGui)

-- // Create a tab
local mainTab = window:CreateTab("Main")

-- // Create a section
local mainSection = mainTab:CreateSection("Main Controls")

-- Label
local label = mainSection:CreateLabel("Welcome to the control panel!")

-- Button
local button = mainSection:CreateButton("Click Me!", function()
    print("Button clicked!")
    label:UpdateText("You clicked the button!")
end)
button:AddToolTip("Press to test callback")

-- Toggle
local toggle = mainSection:CreateToggle("Auto Farm", false, function(state)
    print("Auto Farm toggled:", state)
end)
toggle:AddToolTip("Enables or disables auto farming")

-- Add keybind to toggle
local keybind = toggle:CreateKeybind("F", function(key)
    print("Toggled Auto Farm with key:", key)
end)

-- Slider
local slider = mainSection:CreateSlider("Speed", 0, 100, 25, false, function(value)
    print("Speed set to:", value)
end)
slider:AddToolTip("Adjusts player speed")

-- Textbox
local textbox = mainSection:CreateTextBox("Nickname", "Enter name...", false, function(text)
    print("Nickname entered:", text)
end)
textbox:AddToolTip("Type your nickname here")

-- Dropdown
local dropdown = mainSection:CreateDropdown("Team", {"Red", "Blue", "Green"}, function(choice)
    print("Selected team:", choice)
end, "Red")
dropdown:AddToolTip("Choose your team")

-- Color Picker
local colorpicker = mainSection:CreateColorpicker("Theme Color", function(color)
    print("Selected color:", color)
    window:ChangeColor(color)
end)
colorpicker:AddToolTip("Changes UI theme color")

-- Example to toggle UI visibility with RightCtrl
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightControl then
        lib.Toggle = not lib.Toggle
        window:Toggle(lib.Toggle)
    end
end)

print("✅ UI Loaded successfully.")
