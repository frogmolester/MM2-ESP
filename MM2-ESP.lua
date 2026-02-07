wait(1)
print("seabas6a")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ESPEnabled = true
local ESPObjects = {}

local COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    Innocent = Color3.fromRGB(0, 255, 0)
}

local function createESP(player)
    if player == LocalPlayer then return end
    
    local esp = {
        Player = player,
        BillboardGui = nil,
        TextLabel = nil,
        Highlight = nil
    }
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = game.CoreGui
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard
    
    esp.BillboardGui = billboard
    esp.TextLabel = textLabel
    
    return esp
end

local function getPlayerRole(player)
    local character = player.Character
    if not character then return "Innocent" end
    
    local backpack = player.Backpack
    
    if character:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
        return "Murderer"
    end
    
    if character:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    
    return "Innocent"
end

local function updateESP(esp)
    local player = esp.Player
    local character = player.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        esp.BillboardGui.Enabled = false
        if esp.Highlight then
            esp.Highlight.Enabled = false
        end
        return
    end
    
    local role = getPlayerRole(player)
    local hrp = character.HumanoidRootPart
    
    esp.BillboardGui.Adornee = hrp
    esp.BillboardGui.Enabled = ESPEnabled
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
        esp.TextLabel.Text = player.Name .. "\n[" .. role .. "]\n" .. distance .. "m"
    else
        esp.TextLabel.Text = player.Name .. "\n[" .. role .. "]"
    end
    
    esp.TextLabel.TextColor3 = COLORS[role]
    
    if not esp.Highlight or not esp.Highlight.Parent or esp.Highlight.Adornee ~= character then
        if esp.Highlight then
            esp.Highlight:Destroy()
        end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = character
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        esp.Highlight = highlight
    end
    
    if esp.Highlight then
        esp.Highlight.Enabled = ESPEnabled
        esp.Highlight.FillColor = COLORS[role]
        esp.Highlight.OutlineColor = COLORS[role]
    end
end

local function removeESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].BillboardGui then
            ESPObjects[player].BillboardGui:Destroy()
        end
        if ESPObjects[player].Highlight then
            ESPObjects[player].Highlight:Destroy()
        end
        ESPObjects[player] = nil
    end
end

local function setupAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not ESPObjects[player] then
            ESPObjects[player] = createESP(player)
        end
    end
end

local function setupCharacterAdded(player)
    player.CharacterAdded:Connect(function(character)
        wait(0.5)
        
        if ESPObjects[player] then
            if ESPObjects[player].Highlight then
                ESPObjects[player].Highlight:Destroy()
                ESPObjects[player].Highlight = nil
            end
            
            updateESP(ESPObjects[player])
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        ESPObjects[player] = createESP(player)
        setupCharacterAdded(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupCharacterAdded(player)
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        ESPEnabled = not ESPEnabled
        
        for player, esp in pairs(ESPObjects) do
            if esp.BillboardGui then
                esp.BillboardGui.Enabled = ESPEnabled
            end
            if esp.Highlight then
                esp.Highlight.Enabled = ESPEnabled
            end
        end
        
        print("ESP " .. (ESPEnabled and "ENABLED" or "DISABLED"))
    end
end)

RunService.RenderStepped:Connect(function()
    if not ESPEnabled then return end
    
    for player, esp in pairs(ESPObjects) do
        if player and player.Parent then
            updateESP(esp)
        else
            removeESP(player)
        end
    end
end)

setupAllPlayers()

print("MM2 ESP Loaded!")
print("Press 'V' to toggle ESP ON/OFF")
print("Murderer = RED | Sheriff = BLUE | Innocent = GREEN")
