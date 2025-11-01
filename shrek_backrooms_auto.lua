--[[
    Shrek in the Backrooms - Auto All Levels Script
    Game: Roblox - Shrek in the Backrooms
    Features: Auto complete all levels, auto collect items, teleport
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuration
local Config = {
    AutoLevel = true,
    AutoCollect = true,
    TeleportSpeed = 0.5,
    WalkSpeed = 50,
    JumpPower = 100,
    NoClip = true,
    AutoRespawn = true,
    SafeMode = true
}

-- Variables
local OriginalWalkSpeed = Humanoid.WalkSpeed
local OriginalJumpPower = Humanoid.JumpPower
local IsRunning = false
local CurrentLevel = 0

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShrekBackroomsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.BorderSizePixel = 0
Title.Text = "🟢 Shrek Backrooms Auto"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 60)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Level Label
local LevelLabel = Instance.new("TextLabel")
LevelLabel.Name = "LevelLabel"
LevelLabel.Size = UDim2.new(1, -20, 0, 30)
LevelLabel.Position = UDim2.new(0, 10, 0, 90)
LevelLabel.BackgroundTransparency = 1
LevelLabel.Text = "Current Level: 0"
LevelLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
LevelLabel.TextSize = 14
LevelLabel.Font = Enum.Font.Gotham
LevelLabel.TextXAlignment = Enum.TextXAlignment.Left
LevelLabel.Parent = MainFrame

-- Function to create buttons
local function CreateButton(name, text, position, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, -20, 0, 40)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.Parent = MainFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

-- Start/Stop Button
local StartButton = CreateButton("StartButton", "▶ Start Auto Level", UDim2.new(0, 10, 0, 130), function()
    IsRunning = not IsRunning
    if IsRunning then
        StartButton.Text = "⏸ Stop Auto Level"
        StartButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        StatusLabel.Text = "Status: Running..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        StartButton.Text = "▶ Start Auto Level"
        StartButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        StatusLabel.Text = "Status: Stopped"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- Speed Boost Button
CreateButton("SpeedButton", "⚡ Toggle Speed Boost", UDim2.new(0, 10, 0, 180), function()
    if Humanoid.WalkSpeed == OriginalWalkSpeed then
        Humanoid.WalkSpeed = Config.WalkSpeed
        Humanoid.JumpPower = Config.JumpPower
        StatusLabel.Text = "Status: Speed Boost ON"
    else
        Humanoid.WalkSpeed = OriginalWalkSpeed
        Humanoid.JumpPower = OriginalJumpPower
        StatusLabel.Text = "Status: Speed Boost OFF"
    end
end)

-- NoClip Button
CreateButton("NoClipButton", "👻 Toggle NoClip", UDim2.new(0, 10, 0, 230), function()
    Config.NoClip = not Config.NoClip
    StatusLabel.Text = "Status: NoClip " .. (Config.NoClip and "ON" or "OFF")
end)

-- Auto Collect Button
CreateButton("CollectButton", "💎 Toggle Auto Collect", UDim2.new(0, 10, 0, 280), function()
    Config.AutoCollect = not Config.AutoCollect
    StatusLabel.Text = "Status: Auto Collect " .. (Config.AutoCollect and "ON" or "OFF")
end)

-- Teleport to Exit Button
CreateButton("ExitButton", "🚪 Teleport to Exit", UDim2.new(0, 10, 0, 330), function()
    TeleportToExit()
end)

-- Close Button
CreateButton("CloseButton", "❌ Close GUI", UDim2.new(0, 10, 0, 380), function()
    ScreenGui:Destroy()
    IsRunning = false
    Humanoid.WalkSpeed = OriginalWalkSpeed
    Humanoid.JumpPower = OriginalJumpPower
end)

-- NoClip Function
local function NoClip()
    if Config.NoClip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

RunService.Stepped:Connect(NoClip)

-- Teleport Function
local function TeleportTo(position)
    if Character and HumanoidRootPart then
        local tweenInfo = TweenInfo.new(Config.TeleportSpeed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Find Exit Function
function TeleportToExit()
    local exit = Workspace:FindFirstChild("Exit", true) or 
                 Workspace:FindFirstChild("Door", true) or
                 Workspace:FindFirstChild("NextLevel", true) or
                 Workspace:FindFirstChild("Teleporter", true)
    
    if exit then
        StatusLabel.Text = "Status: Teleporting to exit..."
        TeleportTo(exit.Position)
        wait(0.5)
        StatusLabel.Text = "Status: At exit!"
    else
        StatusLabel.Text = "Status: Exit not found!"
    end
end

-- Auto Collect Items
local function AutoCollectItems()
    if not Config.AutoCollect then return end
    
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("BasePart") and (
            item.Name:lower():find("coin") or 
            item.Name:lower():find("key") or 
            item.Name:lower():find("item") or
            item.Name:lower():find("collectible") or
            item.Name:lower():find("pickup")
        ) then
            if (item.Position - HumanoidRootPart.Position).Magnitude < 50 then
                pcall(function()
                    item.CFrame = HumanoidRootPart.CFrame
                    wait(0.1)
                end)
            end
        end
    end
end

-- Get Current Level
local function GetCurrentLevel()
    local levelValue = LocalPlayer:FindFirstChild("Level") or 
                      LocalPlayer:FindFirstChild("CurrentLevel") or
                      LocalPlayer:WaitForChild("leaderstats"):FindFirstChild("Level")
    
    if levelValue then
        return levelValue.Value
    end
    return 0
end

-- Main Auto Level Loop
spawn(function()
    while wait(1) do
        if IsRunning then
            pcall(function()
                CurrentLevel = GetCurrentLevel()
                LevelLabel.Text = "Current Level: " .. CurrentLevel
                
                -- Auto collect items
                AutoCollectItems()
                
                -- Find and teleport to exit
                TeleportToExit()
                
                wait(2)
            end)
        end
    end
end)

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
    
    if Config.AutoRespawn and IsRunning then
        wait(1)
        StatusLabel.Text = "Status: Respawned, continuing..."
    end
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Notification
local function Notify(text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Shrek Backrooms Auto";
        Text = text;
        Duration = 3;
    })
end

Notify("Script loaded! Press Start to begin.")

print("=================================")
print("Shrek in the Backrooms Auto Script")
print("=================================")
print("Features:")
print("- Auto complete all levels")
print("- Auto collect items")
print("- Speed boost")
print("- NoClip")
print("- Teleport to exit")
print("=================================")
