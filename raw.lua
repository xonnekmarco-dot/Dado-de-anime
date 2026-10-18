-- OMA FAMILY | Anime Dice Hub (VERSIÓN MEJORADA Y FUNCIONAL)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Anti-AFK integrado (evita desconexión a los 20 minutos)
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

local LOGO_IMAGE = "rbxassetid://0"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmaFamilyAnimeDice"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(320, 420)
Main.Position = UDim2.new(0.5, -160, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Border = Instance.new("UIStroke")
Border.Color = Color3.fromRGB(255, 184, 35)
Border.Thickness = 2
Border.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(32, 26, 12)
Header.BorderSizePixel = 0
Header.Active = true
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "OMA FAMILY | ANIME DICE"
Title.TextColor3 = Color3.fromRGB(255, 195, 45)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(38, 34)
Minimize.Position = UDim2.new(1, -44, 0, 7)
Minimize.Text = "—"
Minimize.TextSize = 22
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.BackgroundColor3 = Color3.fromRGB(65, 50, 20)
Minimize.Parent = Header
Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 8)

local Body = Instance.new("ScrollingFrame")
Body.Name = "Options"
Body.Position = UDim2.fromOffset(10, 58)
Body.Size = UDim2.new(1, -20, 1, -68)
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.ScrollBarThickness = 4
Body.CanvasSize = UDim2.fromOffset(0, 480)
Body.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Body

-- Variables de Estado
local AutoRollActive = false
local FastFarmActive = false
local AutoCollectActive = false
local SuperSpeedActive = false

-- Función para crear botones con cambio de color ON/OFF
local function AddToggleButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -5, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
    Button.TextColor3 = Color3.fromRGB(255, 210, 90)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = text .. " [OFF]"
    Button.Parent = Body
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
    
    local state = false
    Button.Activated:Connect(function()
        state = not state
        if state then
            Button.Text = text .. " [ON]"
            Button.BackgroundColor3 = Color3.fromRGB(45, 120, 55)
        else
            Button.Text = text .. " [OFF]"
            Button.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
        end
        callback(state)
    end)
    return Button
end

-- 1. Auto-Roll Rápidos
AddToggleButton("Auto-Roll Rápido", function(enabled)
    AutoRollActive = enabled
    task.spawn(function()
        while AutoRollActive do
            pcall(function()
                ReplicatedStorage:FindFirstChild("Roll", true):FireServer()
            end)
            task.wait(0.1)
        end
    end)
end)

-- 2. Fast Farm de Torre
AddToggleButton("Fast Tower Farm", function(enabled)
    FastFarmActive = enabled
    task.spawn(function()
        while FastFarmActive do
            pcall(function()
                for _, enemy in pairs(workspace:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Name ~= Player.Name then
                        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (Player.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                            if dist < 50 then
                                ReplicatedStorage:FindFirstChild("Attack", true):FireServer(enemy)
                            end
                        end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end)

-- 3. Recolección Automática de Gemas/Drops
AddToggleButton("Magnet Gemas / Drops", function(enabled)
    AutoCollectActive = enabled
    task.spawn(function()
        while AutoCollectActive do
            pcall(function()
                for _, item in pairs(workspace:GetChildren()) do
                    if item:IsA("BasePart") and (item.Name:find("Gem") or item.Name:find("Coin") or item.Name:find("Drop")) then
                        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                            item.CFrame = Player.Character.HumanoidRootPart.CFrame
                        end
                    end
                end
            end)
            task.wait(0.3)
        end
    end)
end)

-- 4. Super Velocidad
AddToggleButton("Super Velocidad", function(enabled)
    SuperSpeedActive = enabled
    task.spawn(function()
        while SuperSpeedActive do
            pcall(function()
                if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                    Player.Character.Humanoid.WalkSpeed = 50
                end
            end)
            task.wait(0.2)
        end
        if not SuperSpeedActive and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = 16
        end
    end)
end)

-- Controles de arrastrar interfaz
local dragging, dragInput, dragStart, startPosition
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)

-- Botón flotante para restaurar
local Restore = Instance.new("ImageButton")
Restore.Name = "Restore"
Restore.Size = UDim2.fromOffset(58, 58)
Restore.Position = UDim2.new(0, 18, 0.5, -29)
Restore.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Restore.Image = LOGO_IMAGE
Restore.ScaleType = Enum.ScaleType.Crop
Restore.Visible = false
Restore.Active = true
Restore.Parent = ScreenGui
Instance.new("UICorner", Restore).CornerRadius = UDim.new(1, 0)

local RestoreBorder = Instance.new("UIStroke")
RestoreBorder.Color = Color3.fromRGB(255, 184, 35)
RestoreBorder.Thickness = 2
RestoreBorder.Parent = Restore

Minimize.Activated:Connect(function()
    Main.Visible = false
    Restore.Visible = true
end)

Restore.Activated:Connect(function()
    Restore.Visible = false
    Main.Visible = true
end)

print("OMA FAMILY | Script cargado correctamente")
