-- EMERGENCY HAMBURG + SKY SYSTEM + SAVE/LOAD + SPINBOT
-- INTERFACE 800x500
-- ESP: POLICIAIS = AZUL, CRIMINOSOS COM ARMAS = ROSA
-- OG SNIPER COM RETÍCULA CORRETA DA G36

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================
-- CONFIG FILE PATH
-- ============================================
local CONFIG_FILE = "AimbotConfig_Saved.json"

-- ============================================
-- DEFAULT CONFIG
-- ============================================
local DEFAULT_CONFIG = {
    EH_Enabled = false,
    EH_AimPart = "Torso",
    EH_ESP = false,
    EH_ESPHealth = false,
    EH_FriendsMode = false,
    EH_Key = "Z",
    EH_SpinBot = false,
    EH_SpinSpeed = 100,
    EH_OGSniper = false,
    CurrentSkyId = 1,
    BlockedPlayers = {},
}

-- ============================================
-- LOAD OR CREATE CONFIG (CORRIGIDO)
-- ============================================
local function LoadConfig()
    if getgenv().AimbotConfig then
        return getgenv().AimbotConfig
    end
    
    -- Verificar se funções de arquivo existem
    if typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function" then
        local success, result = pcall(function()
            if isfile(CONFIG_FILE) then
                local data = readfile(CONFIG_FILE)
                return HttpService:JSONDecode(data)
            end
            return nil
        end)
        
        if success and result then
            for key, value in pairs(DEFAULT_CONFIG) do
                if result[key] == nil then
                    result[key] = value
                end
            end
            if not result.BlockedPlayers then
                result.BlockedPlayers = {}
            end
            return result
        end
    end
    
    return DEFAULT_CONFIG
end

getgenv().AimbotConfig = LoadConfig()
local Config = getgenv().AimbotConfig

if not Config.BlockedPlayers then
    Config.BlockedPlayers = {}
end

-- ============================================
-- LISTA DE ARMAS DO EH
-- ============================================
local EH_WEAPONS_LIST = {
    "g36", "sniper", "taser", "mp5", "m4", "ak47", "shotgun", "pistol",
    "revolver", "deagle", "uzi", "mp7", "p90", "scar", "famas", "aug",
    "galil", "hk416", "dragunov", "barret", "m24", "intervention", "awp",
    "knife", "taco", "baseball", "bat", "hammer", "crowbar", "machete",
    "grenade", "c4", "bomb", "flashbang", "smoke", "molotov", "rpg",
    "minigun", "flamethrower", "crossbow", "bow", "axe", "sword"
}

-- ============================================
-- SISTEMA DE CEUS
-- ============================================
local SKY_LIST = {
    {id = 1, name = "Céu Padrão", skyboxId = nil},
    
    {id = 2, name = "Red Sky", 
        skyboxBk = "rbxassetid://108929045660200",
        skyboxDn = "rbxassetid://78646480540009",
        skyboxFt = "rbxassetid://90546017435179",
        skyboxLf = "rbxassetid://109838453114563",
        skyboxRt = "rbxassetid://94190734796082",
        skyboxUp = "rbxassetid://126944775797063"
    },
    
    {id = 3, name = "Orange Sky", 
        skyboxBk = "rbxassetid://150939022",
        skyboxDn = "rbxassetid://150939038",
        skyboxFt = "rbxassetid://150939047",
        skyboxLf = "rbxassetid://150939056",
        skyboxRt = "rbxassetid://150939063",
        skyboxUp = "rbxassetid://150939082"
    },

    {id = 4, name = "Pink Sky", 
        skyboxBk = "rbxassetid://12635309703",
        skyboxDn = "rbxassetid://12635311686",
        skyboxFt = "rbxassetid://12635312870",
        skyboxLf = "rbxassetid://12635313718",
        skyboxRt = "rbxassetid://12635315817",
        skyboxUp = "rbxassetid://12635316856"
    }
}

-- Variáveis globais
local originalSky = nil
local currentSkyObject = nil
local PanelOpen = true
local isAiming = false
local isDragging = false
local dragStart, dragStartPos, dragConnection, dragEndConnection = nil, nil, nil, nil

-- Variáveis da interface
local mainFrame
local currentTab = "Emergency Hamburg"

-- Variáveis EH
local ehAimbotBtn, ehAimLockBtn, ehESPBtn, ehESPHealthBtn, ehFriendsModeBtn, ehSpinBotBtn, ehSpinSpeedSlider, ehSpinSpeedLabel, ehOGSniperBtn
local espObjects, espHealthObjects, espConnections = {}, {}, {}
local ehKeyBtn, lockedTarget, lockedPart = nil, nil, nil

-- Variáveis SpinBot
local spinRunning = false
local spinAngle = 0

-- Variáveis OG Sniper
local ogSniperConnection = nil
local customCrosshair = nil
local originalScopes = {}

-- Variáveis Sky
local skyButtons = {}

-- Variáveis Friends Mode
local blockedPlayersFrame = nil
local contentEHScroll = nil

-- ============================================
-- FUNÇÃO: VERIFICAR SE É POLICIAL (NOVO)
-- ============================================
local function IsPolice(player)
    if not player then return false end
    
    -- Verificar pelo time
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("police") or teamName:find("policia") or teamName:find("cop") or teamName:find("sheriff") or teamName:find("law") then
            return true
        end
    end
    
    -- Verificar leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local team = leaderstats:FindFirstChild("Team") or leaderstats:FindFirstChild("Time")
        if team and team:IsA("StringValue") then
            local teamName = team.Value:lower()
            if teamName:find("police") or teamName:find("policia") or teamName:find("cop") then
                return true
            end
        end
    end
    
    -- Verificar se tem ferramenta de policial
    if player.Character then
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("taser") or toolName:find("cassetete") or toolName:find("police") then
                    return true
                end
            end
        end
    end
    
    return false
end

-- ============================================
-- FUNÇÃO: VERIFICAR SE JOGADOR TEM ARMA (CORRIGIDO)
-- ============================================
local function PlayerHasWeapon(player)
    if not player then return false end
    
    -- Verificar Backpack (inventário) - não precisa estar equipado
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                -- Verificar se é arma de verdade (não é ferramenta de policial)
                for _, weaponName in ipairs(EH_WEAPONS_LIST) do
                    if toolName:find(weaponName) then
                        -- Se for policial, só conta se não for arma de polícia específica
                        if IsPolice(player) then
                            -- Policial só fica rosa se tiver armas ilegais (não taser/cassetete)
                            if not toolName:find("taser") and not toolName:find("cassetete") then
                                return true
                            end
                        else
                            return true
                        end
                    end
                end
            end
        end
    end
    
    -- Verificar mão atual também
    if player.Character then
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                for _, weaponName in ipairs(EH_WEAPONS_LIST) do
                    if toolName:find(weaponName) then
                        if IsPolice(player) then
                            if not toolName:find("taser") and not toolName:find("cassetete") then
                                return true
                            end
                        else
                            return true
                        end
                    end
                end
            end
        end
    end
    
    return false
end

-- ============================================
-- FUNÇÃO: OBTER COR DO TIME (CORRIGIDO)
-- ============================================
local function GetTeamColor(player)
    if not player then return Color3.fromRGB(200, 200, 200) end
    
    -- Policiais sempre AZUL
    if IsPolice(player) then
        return Color3.fromRGB(0, 100, 255) -- Azul policial
    end
    
    -- Criminosos/Não policiais com armas = ROSA
    if PlayerHasWeapon(player) then
        return Color3.fromRGB(255, 105, 180) -- Rosa
    end
    
    -- Verificar se o jogador tem um time
    if player.Team then
        return player.TeamColor.Color
    end
    
    return Color3.fromRGB(200, 200, 200)
end

-- ============================================
-- FUNÇÕES FRIENDS MODE (CORRIGIDO)
-- ============================================
local function IsBlockedPlayer(player)
    if not Config.EH_FriendsMode then return false end
    if not player then return false end
    
    local playerName = player.Name
    local displayName = player.DisplayName or ""
    
    for _, blockedName in ipairs(Config.BlockedPlayers or {}) do
        if typeof(blockedName) == "string" then
            if blockedName:lower() == playerName:lower() or blockedName:lower() == displayName:lower() then
                return true
            end
        end
    end
    
    return false
end

local function AddBlockedPlayer(playerName)
    if not playerName or playerName == "" then return false end
    
    for _, name in ipairs(Config.BlockedPlayers) do
        if typeof(name) == "string" and name:lower() == playerName:lower() then
            return false -- Já existe
        end
    end
    
    table.insert(Config.BlockedPlayers, playerName)
    return true
end

local function RemoveBlockedPlayer(index)
    if Config.BlockedPlayers and Config.BlockedPlayers[index] then
        table.remove(Config.BlockedPlayers, index)
        return true
    end
    return false
end

-- ============================================
-- FUNÇÃO: ATUALIZAR LISTA DE BLOQUEADOS
-- ============================================
local function UpdateBlockedPlayersList()
    if not blockedPlayersFrame then return end
    
    -- Limpar lista atual
    for _, child in ipairs(blockedPlayersFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Adicionar jogadores bloqueados
    local yPos = 5
    
    if #Config.BlockedPlayers == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, -10, 0, 30)
        emptyLabel.Position = UDim2.new(0, 5, 0, yPos)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "Nenhum jogador bloqueado"
        emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        emptyLabel.TextSize = 12
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.ZIndex = 14
        emptyLabel.Parent = blockedPlayersFrame
    else
        for i, name in ipairs(Config.BlockedPlayers) do
            if typeof(name) == "string" then
                -- Frame do jogador
                local playerFrame = Instance.new("Frame")
                playerFrame.Size = UDim2.new(1, -10, 0, 50)
                playerFrame.Position = UDim2.new(0, 5, 0, yPos)
                playerFrame.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
                playerFrame.BorderSizePixel = 0
                playerFrame.ZIndex = 14
                playerFrame.Parent = blockedPlayersFrame
                
                -- Avatar do jogador
                local avatarImage = Instance.new("ImageLabel")
                avatarImage.Size = UDim2.new(0, 40, 0, 40)
                avatarImage.Position = UDim2.new(0, 5, 0, 5)
                avatarImage.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
                avatarImage.BorderSizePixel = 0
                avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=0&width=420&height=420&format=png"
                avatarImage.ZIndex = 15
                avatarImage.Parent = playerFrame
                
                -- Tentar pegar o UserId do jogador
                local targetPlayer = nil
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Name:lower() == name:lower() or (p.DisplayName and p.DisplayName:lower() == name:lower()) then
                        targetPlayer = p
                        break
                    end
                end
                
                if targetPlayer then
                    avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. targetPlayer.UserId .. "&width=420&height=420&format=png"
                else
                    spawn(function()
                        local success, userId = pcall(function()
                            return Players:GetUserIdFromNameAsync(name)
                        end)
                        if success and userId then
                            avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
                        end
                    end)
                end
                
                -- Nome do jogador
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, -100, 1, 0)
                nameLabel.Position = UDim2.new(0, 50, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextSize = 14
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.ZIndex = 15
                nameLabel.Parent = playerFrame
                
                -- Botão X para remover
                local removeBtn = Instance.new("TextButton")
                removeBtn.Size = UDim2.new(0, 35, 0, 35)
                removeBtn.Position = UDim2.new(1, -40, 0.5, -17)
                removeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
                removeBtn.BorderSizePixel = 0
                removeBtn.Text = "X"
                removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                removeBtn.TextSize = 16
                removeBtn.Font = Enum.Font.GothamBold
                removeBtn.ZIndex = 15
                removeBtn.Parent = playerFrame
                
                removeBtn.MouseButton1Click:Connect(function()
                    RemoveBlockedPlayer(i)
                    UpdateBlockedPlayersList()
                end)
                
                yPos = yPos + 55
            end
        end
    end
    
    -- Ajustar tamanho do canvas
    local contentHeight = math.max(yPos + 10, 100)
    blockedPlayersFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
end

-- ============================================
-- FUNÇÃO: ATUALIZAR INTERFACE
-- ============================================
local function UpdateUI()
    if ehAimbotBtn then
        ehAimbotBtn.Text = Config.EH_Enabled and "ON" or "OFF"
        ehAimbotBtn.BackgroundColor3 = Config.EH_Enabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    if ehAimLockBtn then
        ehAimLockBtn.Text = Config.EH_AimPart == "Torso" and "TORSO" or "HEAD"
    end
    if ehESPBtn then
        ehESPBtn.Text = Config.EH_ESP and "ON" or "OFF"
        ehESPBtn.BackgroundColor3 = Config.EH_ESP and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    if ehESPHealthBtn then
        ehESPHealthBtn.Text = Config.EH_ESPHealth and "ON" or "OFF"
        ehESPHealthBtn.BackgroundColor3 = Config.EH_ESPHealth and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    if ehFriendsModeBtn then
        ehFriendsModeBtn.Text = Config.EH_FriendsMode and "ON" or "OFF"
        ehFriendsModeBtn.BackgroundColor3 = Config.EH_FriendsMode and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    if ehKeyBtn then
        ehKeyBtn.Text = Config.EH_Key
    end
    if ehSpinBotBtn then
        ehSpinBotBtn.Text = Config.EH_SpinBot and "ON" or "OFF"
        ehSpinBotBtn.BackgroundColor3 = Config.EH_SpinBot and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    if ehSpinSpeedLabel then
        ehSpinSpeedLabel.Text = "Velocidade: " .. tostring(Config.EH_SpinSpeed)
    end
    if ehSpinSpeedSlider then
        ehSpinSpeedSlider.Size = UDim2.new(Config.EH_SpinSpeed / 1000, 0, 1, 0)
    end
    if ehOGSniperBtn then
        ehOGSniperBtn.Text = Config.EH_OGSniper and "ON" or "OFF"
        ehOGSniperBtn.BackgroundColor3 = Config.EH_OGSniper and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    
    -- Atualizar botões do céu
    for i, btnData in ipairs(skyButtons) do
        if btnData and btnData.button then
            if btnData.skyId == Config.CurrentSkyId then
                btnData.button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                btnData.button.Text = "✓ " .. btnData.skyName
            else
                btnData.button.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
                btnData.button.Text = btnData.skyName
            end
        end
    end
    
    UpdateBlockedPlayersList()
end

-- ============================================
-- FUNÇÕES SPINBOT
-- ============================================
local function SpinBotLoop()
    while spinRunning and Config.EH_SpinBot do
        local character = LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                spinAngle = spinAngle + (Config.EH_SpinSpeed * 0.01)
                if spinAngle >= 360 then
                    spinAngle = spinAngle - 360
                end
                local currentCFrame = hrp.CFrame
                hrp.CFrame = CFrame.new(currentCFrame.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)
            end
        end
        task.wait(0.01)
    end
end

local function StartSpinBot()
    if spinRunning then return end
    spinRunning = true
    task.spawn(SpinBotLoop)
end

local function StopSpinBot()
    spinRunning = false
    spinAngle = 0
end

local function ToggleSpinBot()
    Config.EH_SpinBot = not Config.EH_SpinBot
    
    if Config.EH_SpinBot then
        StartSpinBot()
    else
        StopSpinBot()
    end
    
    UpdateUI()
end

-- ============================================
-- SISTEMA OG SNIPER (RETÍCULA G36 - CORRIGIDO)
-- ============================================
local function RemoveSniperScope()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "OGSniperCrosshair" then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                    local name = obj.Name:lower()
                    if name:find("scope") or name:find("sniper") or name:find("zoom") or name:find("overlay") then
                        if obj.BackgroundColor3 then
                            local color = obj.BackgroundColor3
                            if color.R < 0.2 and color.G < 0.2 and color.B < 0.2 then
                                if obj.Visible then
                                    obj.Visible = false
                                    table.insert(originalScopes, obj)
                                end
                            end
                        end
                        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                            if obj.Image:find("scope") or obj.Image:find("sniper") or name:find("scope") then
                                if obj.Visible then
                                    obj.Visible = false
                                    table.insert(originalScopes, obj)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function RestoreOriginalScopes()
    for _, obj in ipairs(originalScopes) do
        if obj and obj.Parent then
            obj.Visible = true
        end
    end
    originalScopes = {}
end

local function CreateG36Crosshair()
    -- Remover crosshair anterior
    if customCrosshair and customCrosshair.Parent then
        customCrosshair:Destroy()
        customCrosshair = nil
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OGSniperCrosshair"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local crosshairFrame = Instance.new("Frame")
    crosshairFrame.Size = UDim2.new(1, 0, 1, 0)
    crosshairFrame.BackgroundTransparency = 1
    crosshairFrame.ZIndex = 100
    crosshairFrame.Parent = screenGui
    
    -- Retícula da G36 no EH: Círculo fino com pontos nos cantos
    -- Círculo externo fino (vermelho)
    local outerCircle = Instance.new("Frame")
    outerCircle.Size = UDim2.new(0, 80, 0, 80)
    outerCircle.Position = UDim2.new(0.5, -40, 0.5, -40)
    outerCircle.BackgroundTransparency = 1
    outerCircle.BorderSizePixel = 2
    outerCircle.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho
    outerCircle.ZIndex = 101
    outerCircle.Parent = crosshairFrame
    
    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(1, 0)
    outerCorner.Parent = outerCircle
    
    -- Linha vertical fina (vermelha)
    local vLine = Instance.new("Frame")
    vLine.Size = UDim2.new(0, 1, 0, 20)
    vLine.Position = UDim2.new(0.5, -0.5, 0.5, -10)
    vLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    vLine.BorderSizePixel = 0
    vLine.ZIndex = 101
    vLine.Parent = crosshairFrame
    
    -- Linha horizontal fina (vermelha)
    local hLine = Instance.new("Frame")
    hLine.Size = UDim2.new(0, 20, 0, 1)
    hLine.Position = UDim2.new(0.5, -10, 0.5, -0.5)
    hLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    hLine.BorderSizePixel = 0
    hLine.ZIndex = 101
    hLine.Parent = crosshairFrame
    
    -- Ponto central (vermelho)
    local centerDot = Instance.new("Frame")
    centerDot.Size = UDim2.new(0, 4, 0, 4)
    centerDot.Position = UDim2.new(0.5, -2, 0.5, -2)
    centerDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    centerDot.BorderSizePixel = 0
    centerDot.ZIndex = 102
    centerDot.Parent = crosshairFrame
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = centerDot
    
    -- Marcas de distância (linhas horizontais pequenas em cima e embaixo)
    local topMark = Instance.new("Frame")
    topMark.Size = UDim2.new(0, 10, 0, 1)
    topMark.Position = UDim2.new(0.5, -5, 0.5, -25)
    topMark.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    topMark.BorderSizePixel = 0
    topMark.ZIndex = 101
    topMark.Parent = crosshairFrame
    
    local bottomMark = Instance.new("Frame")
    bottomMark.Size = UDim2.new(0, 10, 0, 1)
    bottomMark.Position = UDim2.new(0.5, -5, 0.5, 25)
    bottomMark.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    bottomMark.BorderSizePixel = 0
    bottomMark.ZIndex = 101
    bottomMark.Parent = crosshairFrame
    
    -- Linhas laterais pequenas
    local leftMark = Instance.new("Frame")
    leftMark.Size = UDim2.new(0, 1, 0, 10)
    leftMark.Position = UDim2.new(0.5, -25, 0.5, -5)
    leftMark.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    leftMark.BorderSizePixel = 0
    leftMark.ZIndex = 101
    leftMark.Parent = crosshairFrame
    
    local rightMark = Instance.new("Frame")
    rightMark.Size = UDim2.new(0, 1, 0, 10)
    rightMark.Position = UDim2.new(0.5, 25, 0.5, -5)
    rightMark.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    rightMark.BorderSizePixel = 0
    rightMark.ZIndex = 101
    rightMark.Parent = crosshairFrame
    
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    customCrosshair = screenGui
    
    return screenGui
end

local function RemoveG36Crosshair()
    if customCrosshair and customCrosshair.Parent then
        customCrosshair:Destroy()
        customCrosshair = nil
    end
end

local sniperActive = false

local function ApplyOGSniper()
    if sniperActive then return end
    sniperActive = true
    
    local character = LocalPlayer.Character
    if not character then 
        sniperActive = false
        return 
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then 
        sniperActive = false
        return 
    end
    
    local toolName = tool.Name:lower()
    if toolName:find("sniper") or toolName:find("barret") or toolName:find("intervention") or toolName:find("m24") or toolName:find("awp") or toolName:find("dragunov") then
        RemoveSniperScope()
        CreateG36Crosshair()
        
        pcall(function()
            local weaponModule = tool:FindFirstChild("WeaponModule") or tool:FindFirstChild("WeaponStats")
            if weaponModule then
                local currentFOV = weaponModule:GetAttribute("FOV") or weaponModule:FindFirstChild("FOV")
                if currentFOV then
                    if not tool:GetAttribute("OriginalFOV") then
                        if typeof(currentFOV) == "number" then
                            tool:SetAttribute("OriginalFOV", currentFOV)
                        elseif currentFOV:IsA("Value") then
                            tool:SetAttribute("OriginalFOV", currentFOV.Value)
                        end
                    end
                    
                    local newFOV = 50
                    if typeof(currentFOV) == "number" then
                        weaponModule:SetAttribute("FOV", newFOV)
                    elseif currentFOV:IsA("Value") then
                        currentFOV.Value = newFOV
                    end
                end
            end
        end)
    end
    
    sniperActive = false
end

local function RestoreOriginalSniper()
    RemoveG36Crosshair()
    RestoreOriginalScopes()
    
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("sniper") or toolName:find("barret") or toolName:find("intervention") or toolName:find("m24") or toolName:find("awp") or toolName:find("dragunov") then
                    local weaponModule = tool:FindFirstChild("WeaponModule") or tool:FindFirstChild("WeaponStats")
                    if weaponModule then
                        local originalFOV = tool:GetAttribute("OriginalFOV")
                        if originalFOV then
                            local currentFOV = weaponModule:GetAttribute("FOV") or weaponModule:FindFirstChild("FOV")
                            if currentFOV then
                                if typeof(currentFOV) == "number" then
                                    weaponModule:SetAttribute("FOV", originalFOV)
                                elseif currentFOV:IsA("Value") then
                                    currentFOV.Value = originalFOV
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function ToggleOGSniper()
    Config.EH_OGSniper = not Config.EH_OGSniper
    
    if Config.EH_OGSniper then
        ApplyOGSniper()
        
        if ogSniperConnection then
            ogSniperConnection:Disconnect()
            ogSniperConnection = nil
        end
        
        ogSniperConnection = LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if Config.EH_OGSniper then
                ApplyOGSniper()
            end
        end)
        
        if LocalPlayer.Character then
            LocalPlayer.Character.ChildAdded:Connect(function(child)
                if child:IsA("Tool") and Config.EH_OGSniper then
                    task.wait(0.1)
                    ApplyOGSniper()
                end
            end)
        end
    else
        RestoreOriginalSniper()
        if ogSniperConnection then
            ogSniperConnection:Disconnect()
            ogSniperConnection = nil
        end
    end
    
    UpdateUI()
end

-- ============================================
-- FUNÇÕES EMERGENCY HAMBURG
-- ============================================
local function IsInEmergencyHamburg()
    return game.PlaceId == 7711635737
end

local EH_WEAPONS = {
    "g36", "sniper", "taser", "mp5", "m4", "ak47", "shotgun", "pistol",
    "revolver", "deagle", "uzi", "mp7", "p90", "scar", "famas", "aug",
    "galil", "hk416", "dragunov", "barret", "m24", "intervention", "awp"
}

local function IsEHWeapon(tool)
    if not tool then return false end
    if not tool:FindFirstChild("Handle") then return false end
    local name = tool.Name:lower()
    for _, weapon in ipairs(EH_WEAPONS) do
        if name:find(weapon) then
            return true
        end
    end
    return false
end

-- ============================================
-- FUNÇÃO: IsValidTarget (CORRIGIDO)
-- ============================================
local function IsValidTarget(player)
    if not player then return false end
    if player == LocalPlayer then return false end
    
    -- VERIFICAR SE ESTÁ BLOQUEADO (FRIENDS MODE)
    if Config.EH_FriendsMode == true then
        if IsBlockedPlayer(player) == true then
            return false
        end
    end
    
    if not player.Character then return false end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    if humanoid.Health <= 0 then return false end
    if humanoid:GetState() == Enum.HumanoidStateType.Dead then return false end
    
    local head = player.Character:FindFirstChild("Head")
    if not head then return false end
    
    local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
    if not torso then return false end
    
    return true
end

local function GetBestTargetPart(player)
    if not player or not player.Character then return nil end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end
    
    local character = player.Character
    local targetPart = nil
    
    if Config.EH_AimPart == "Head" then
        targetPart = character:FindFirstChild("Head")
    else
        targetPart = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end
    
    if targetPart then
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if onScreen then
            return targetPart
        end
    end
    
    local parts = {"Head", "UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart",
                   "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
    
    for _, partName in ipairs(parts) do
        local part = character:FindFirstChild(partName)
        if part then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                return part
            end
        end
    end
    
    return nil
end

local function GetTargetVelocity(player)
    if not player or not player.Character then return Vector3.new() end
    local character = player.Character
    local velocity = Vector3.new()
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        velocity = humanoid.MoveDirection
        if velocity.Magnitude > 0.1 then
            return velocity
        end
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        velocity = rootPart.Velocity
        if velocity.Magnitude > 1 then
            return velocity.Unit
        end
    end
    return Vector3.new()
end

-- ============================================
-- LOOP EMERGENCY HAMBURG
-- ============================================
local lastCheck = 0
RunService.RenderStepped:Connect(function()
    if not Config.EH_Enabled then return end
    if not IsInEmergencyHamburg() then return end
    if PanelOpen then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    
    -- Verificar OG Sniper
    if Config.EH_OGSniper and tool then
        local toolName = tool.Name:lower()
        if toolName:find("sniper") or toolName:find("barret") or toolName:find("intervention") then
            if not customCrosshair or not customCrosshair.Parent then
                task.spawn(function()
                    ApplyOGSniper()
                end)
            end
        else
            if customCrosshair and customCrosshair.Parent then
                task.spawn(function()
                    RemoveG36Crosshair()
                    RestoreOriginalScopes()
                end)
            end
        end
    end
    
    if not IsEHWeapon(tool) then 
        lockedTarget = nil
        lockedPart = nil
        return 
    end
    
    local isPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    
    if not isPressed then
        lockedTarget = nil
        lockedPart = nil
        return
    end
    
    if lockedTarget and lockedPart then
        if IsValidTarget(lockedTarget) and lockedPart.Parent and lockedPart.Parent == lockedTarget.Character then
            local screenPos, onScreen = Camera:WorldToViewportPoint(lockedPart.Position)
            if onScreen then
                local mousePos2 = UserInputService:GetMouseLocation()
                local smoothFactor = 3.0 / 10
                
                local leadX, leadY = 0, 0
                local velocity = GetTargetVelocity(lockedTarget)
                local magnitude = (velocity * Vector3.new(1, 0, 1)).Magnitude
                local distance = (lockedPart.Position - Camera.CFrame.Position).Magnitude
                
                local leadFactor = 0.01 + (0.02 * (1 - math.min(distance / 300, 1)))
                leadFactor = math.max(leadFactor, 0.005)
                
                if magnitude > 0.3 then
                    local worldVelocity = velocity * distance * leadFactor
                    local screenVelocity, onScreen2 = Camera:WorldToViewportPoint(lockedPart.Position + worldVelocity)
                    if onScreen2 then
                        leadX = (screenVelocity.X - screenPos.X)
                        leadY = (screenVelocity.Y - screenPos.Y)
                    end
                end
                
                local x = (screenPos.X - mousePos2.X + leadX) * smoothFactor
                local y = (screenPos.Y - mousePos2.Y + leadY) * smoothFactor
                
                if mousemoverel then
                    mousemoverel(x, y)
                end
                return
            else
                lockedTarget = nil
                lockedPart = nil
            end
        else
            lockedTarget = nil
            lockedPart = nil
        end
    end
    
    local currentTime = tick()
    if currentTime - lastCheck < 0.05 then return end
    lastCheck = currentTime
    
    local closestPart, closestPlayer, closestScore = nil, nil, 999999
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local part = GetBestTargetPart(player)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    local dist3D = (part.Position - Camera.CFrame.Position).Magnitude
                    local score = mag + (dist3D / 8)
                    if score < closestScore then
                        closestScore = score
                        closestPart = part
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    if closestPart and closestPlayer then
        lockedTarget = closestPlayer
        lockedPart = closestPart
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(closestPart.Position)
        if onScreen then
            local mousePos2 = UserInputService:GetMouseLocation()
            local smoothFactor = 3.0 / 10
            
            local leadX, leadY = 0, 0
            local velocity = GetTargetVelocity(closestPlayer)
            local magnitude = (velocity * Vector3.new(1, 0, 1)).Magnitude
            local distance = (closestPart.Position - Camera.CFrame.Position).Magnitude
            
            local leadFactor = 0.01 + (0.02 * (1 - math.min(distance / 300, 1)))
            leadFactor = math.max(leadFactor, 0.005)
            
            if magnitude > 0.3 then
                local worldVelocity = velocity * distance * leadFactor
                local screenVelocity, onScreen2 = Camera:WorldToViewportPoint(closestPart.Position + worldVelocity)
                if onScreen2 then
                    leadX = (screenVelocity.X - screenPos.X)
                    leadY = (screenVelocity.Y - screenPos.Y)
                end
            end
            
            local x = (screenPos.X - mousePos2.X + leadX) * smoothFactor
            local y = (screenPos.Y - mousePos2.Y + leadY) * smoothFactor
            
            if mousemoverel then
                mousemoverel(x, y)
            end
        end
    end
end)

-- ============================================
-- ESP FUNCTIONS (CORRIGIDO COM CORES)
-- ============================================
local function ClearESP()
    for _, conn in ipairs(espConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    espConnections = {}
    
    for _, group in ipairs(espObjects) do
        for _, obj in ipairs(group) do
            if obj and obj.Parent then pcall(function() obj:Destroy() end) end
        end
    end
    espObjects = {}
    
    for _, group in ipairs(espHealthObjects) do
        for _, obj in ipairs(group) do
            if obj and obj.Parent then pcall(function() obj:Destroy() end) end
        end
    end
    espHealthObjects = {}
end

local function CreateESPForPlayer(player)
    if not player or player == LocalPlayer then return nil end
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end
    
    local teamColor = GetTeamColor(player)
    
    local group = {}
    local parts = {}
    local partNames = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
    local sizes = {Head=5, UpperTorso=8, LowerTorso=6, LeftUpperArm=4, RightUpperArm=4, LeftUpperLeg=4, RightUpperLeg=4}
    
    for _, name in ipairs(partNames) do
        local part = character:FindFirstChild(name)
        if part then
            parts[name] = part
            local size = sizes[name] or 4
            local esp = Instance.new("BillboardGui")
            esp.Size = UDim2.new(0, size, 0, size)
            esp.Adornee = part
            esp.AlwaysOnTop = true
            esp.StudsOffset = Vector3.new(0, 0, 0)
            esp.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            esp.Parent = part
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = teamColor
            frame.BackgroundTransparency = size <= 3 and 0.4 or 0.2
            frame.BorderSizePixel = 0
            frame.Parent = esp
            
            table.insert(group, esp)
        end
    end
    
    local connections = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
        {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
    }
    
    for _, conn in ipairs(connections) do
        local p1, p2 = parts[conn[1]], parts[conn[2]]
        if p1 and p2 then
            local line = Instance.new("BillboardGui")
            line.Size = UDim2.new(0, 2, 0, 2)
            line.Adornee = p1
            line.AlwaysOnTop = true
            line.StudsOffset = Vector3.new(0, 0, 0)
            line.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            line.Parent = p1
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = teamColor
            frame.BackgroundTransparency = 0.3
            frame.BorderSizePixel = 0
            frame.Parent = line
            
            table.insert(group, line)
        end
    end
    return group
end

local function CreateESPHealthForPlayer(player)
    if not player or player == LocalPlayer then return nil end
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return nil end
    
    local head = character:FindFirstChild("Head")
    if not head then return nil end
    
    local teamColor = GetTeamColor(player)
    local isPolice = IsPolice(player)
    local hasWeapon = PlayerHasWeapon(player)
    
    local espGroup = {}
    local infoEsp = Instance.new("BillboardGui")
    infoEsp.Size = UDim2.new(0, 200, 0, 40)
    infoEsp.Adornee = head
    infoEsp.AlwaysOnTop = true
    infoEsp.StudsOffset = Vector3.new(0, 3.5, 0)
    infoEsp.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    infoEsp.Parent = head
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = infoEsp
    
    -- Nome com cor apropriada
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName or player.Name
    nameLabel.TextColor3 = teamColor
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = frame
    
    -- Adicionar indicador de policial ou armado
    if isPolice then
        nameLabel.Text = "👮 " .. nameLabel.Text
    elseif hasWeapon then
        nameLabel.Text = "🔫 " .. nameLabel.Text
    end
    
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(1, 0, 0.3, 0)
    healthBarBg.Position = UDim2.new(0, 0, 0.55, 0)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = frame
    
    local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
    
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(hpPercent, 0, 1, 0)
    healthBar.BackgroundColor3 = teamColor
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBg
    
    local healthText = Instance.new("TextLabel")
    healthText.Size = UDim2.new(1, 0, 1, 0)
    healthText.BackgroundTransparency = 1
    healthText.Text = tostring(math.floor(humanoid.Health)) .. "/" .. tostring(humanoid.MaxHealth)
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.TextSize = 9
    healthText.Font = Enum.Font.GothamBold
    healthText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthText.TextStrokeTransparency = 0.3
    healthText.Parent = healthBarBg
    
    table.insert(espGroup, infoEsp)
    
    local healthConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid and healthBar and healthBar.Parent then
            local newPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            healthBar.Size = UDim2.new(newPercent, 0, 1, 0)
            healthText.Text = tostring(math.floor(humanoid.Health)) .. "/" .. tostring(humanoid.MaxHealth)
        end
    end)
    table.insert(espConnections, healthConnection)
    
    local teamConnection = player:GetPropertyChangedSignal("Team"):Connect(function()
        if infoEsp and infoEsp.Parent then
            local newTeamColor = GetTeamColor(player)
            local newIsPolice = IsPolice(player)
            local newHasWeapon = PlayerHasWeapon(player)
            
            nameLabel.TextColor3 = newTeamColor
            healthBar.BackgroundColor3 = newTeamColor
            
            local baseName = player.DisplayName or player.Name
            if newIsPolice then
                nameLabel.Text = "👮 " .. baseName
            elseif newHasWeapon then
                nameLabel.Text = "🔫 " .. baseName
            else
                nameLabel.Text = baseName
            end
        end
    end)
    table.insert(espConnections, teamConnection)
    
    -- Verificar mudanças no inventário a cada 2 segundos
    task.spawn(function()
        while infoEsp and infoEsp.Parent do
            task.wait(2)
            if not infoEsp or not infoEsp.Parent then break end
            
            local currentTeamColor = GetTeamColor(player)
            local currentIsPolice = IsPolice(player)
            local currentHasWeapon = PlayerHasWeapon(player)
            
            nameLabel.TextColor3 = currentTeamColor
            healthBar.BackgroundColor3 = currentTeamColor
            
            local baseName = player.DisplayName or player.Name
            if currentIsPolice then
                nameLabel.Text = "👮 " .. baseName
            elseif currentHasWeapon then
                nameLabel.Text = "🔫 " .. baseName
            else
                nameLabel.Text = baseName
            end
        end
    end)
    
    return espGroup
end

local function EnableESP()
    ClearESP()
    if not Config.EH_ESP and not Config.EH_ESPHealth then return end
    if not IsInEmergencyHamburg() then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Config.EH_ESP then
                local group = CreateESPForPlayer(player)
                if group and #group > 0 then
                    table.insert(espObjects, group)
                end
            end
            if Config.EH_ESPHealth then
                local healthGroup = CreateESPHealthForPlayer(player)
                if healthGroup and #healthGroup > 0 then
                    table.insert(espHealthObjects, healthGroup)
                end
            end
        end
    end
end

local function DisableESP()
    ClearESP()
end

coroutine.wrap(function()
    while true do
        if (Config.EH_ESP or Config.EH_ESPHealth) and IsInEmergencyHamburg() then
            EnableESP()
        else
            ClearESP()
        end
        task.wait(0.5)
    end
end)()

-- ============================================
-- SISTEMA DE SAVE/LOAD (CORRIGIDO)
-- ============================================
local function SaveConfigToFile()
    if typeof(writefile) ~= "function" then
        return false
    end
    
    local success, err = pcall(function()
        local configData = HttpService:JSONEncode(Config)
        writefile(CONFIG_FILE, configData)
    end)
    
    return success
end

local function LoadConfigFromFile()
    if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then
        return false
    end
    
    if not isfile(CONFIG_FILE) then
        return false
    end
    
    local success, result = pcall(function()
        local data = readfile(CONFIG_FILE)
        return HttpService:JSONDecode(data)
    end)
    
    if success and result then
        for key, value in pairs(result) do
            Config[key] = value
        end
        if not Config.BlockedPlayers then
            Config.BlockedPlayers = {}
        end
        UpdateUI()
        if Config.CurrentSkyId then
            ApplySky(Config.CurrentSkyId)
        end
        return true
    else
        return false
    end
end

-- ============================================
-- FUNÇÕES SKY
-- ============================================
local function SaveOriginalSky()
    if not originalSky then
        originalSky = Lighting:FindFirstChildOfClass("Sky")
        if originalSky then
            originalSky = originalSky:Clone()
        end
    end
end

local function ApplySky(skyId)
    local skyData = nil
    for _, sky in ipairs(SKY_LIST) do
        if sky.id == skyId then
            skyData = sky
            break
        end
    end
    if not skyData then return end
    
    if currentSkyObject then
        currentSkyObject:Destroy()
        currentSkyObject = nil
    end
    
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then
            obj:Destroy()
        end
    end
    
    if skyData.skyboxId then
        local newSky = Instance.new("Sky")
        newSky.Name = "CustomSky_" .. skyData.name
        newSky.SkyboxBk = skyData.skyboxId
        newSky.SkyboxDn = skyData.skyboxId
        newSky.SkyboxFt = skyData.skyboxId
        newSky.SkyboxLf = skyData.skyboxId
        newSky.SkyboxRt = skyData.skyboxId
        newSky.SkyboxUp = skyData.skyboxId
        newSky.Parent = Lighting
        currentSkyObject = newSky
    elseif skyData.skyboxBk then
        local newSky = Instance.new("Sky")
        newSky.Name = "CustomSky_" .. skyData.name
        newSky.SkyboxBk = skyData.skyboxBk
        newSky.SkyboxDn = skyData.skyboxDn or skyData.skyboxBk
        newSky.SkyboxFt = skyData.skyboxFt or skyData.skyboxBk
        newSky.SkyboxLf = skyData.skyboxLf or skyData.skyboxBk
        newSky.SkyboxRt = skyData.skyboxRt or skyData.skyboxBk
        newSky.SkyboxUp = skyData.skyboxUp or skyData.skyboxBk
        newSky.Parent = Lighting
        currentSkyObject = newSky
    else
        if originalSky then
            local restoredSky = originalSky:Clone()
            restoredSky.Parent = Lighting
            currentSkyObject = restoredSky
        end
    end
    
    Config.CurrentSkyId = skyId
end

-- ============================================
-- CRIAR INTERFACE
-- ============================================
local IMAGE_EH = "rbxassetid://16029076040"
local IMAGE_CONFIG = "rbxassetid://6966627582"
local IMAGE_SKY = "rbxassetid://108577521816678"

local function CreateImageLabel(parent, imageId, position, size, color)
    local image = Instance.new("ImageLabel")
    image.Size = size or UDim2.new(0, 32, 0, 32)
    image.Position = position or UDim2.new(0.5, -16, 0, 10)
    image.BackgroundTransparency = 1
    image.Image = imageId
    image.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
    image.ZIndex = 13
    image.Parent = parent
    return image
end

local function CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 800, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.ZIndex = 10
    mainFrame.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = mainFrame
    
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    border.BackgroundTransparency = 0.7
    border.BorderSizePixel = 0
    border.ZIndex = 5
    border.Parent = mainFrame
    
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 12)
    borderCorner.Parent = border
    
    for i = 1, 60 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
        dot.Position = UDim2.new(0, math.random(10, 780), 0, math.random(30, 480))
        dot.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        dot.BackgroundTransparency = 0.4
        dot.BorderSizePixel = 0
        dot.ZIndex = 1
        dot.Parent = mainFrame
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
    end
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 11
    titleBar.Parent = mainFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.5, 0, 1, 0)
    titleText.Position = UDim2.new(0.25, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Sphxz"
    titleText.TextColor3 = Color3.fromRGB(200, 50, 50)
    titleText.TextSize = 18
    titleText.Font = Enum.Font.GothamBold
    titleText.ZIndex = 12
    titleText.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 12
    closeBtn.Parent = titleBar
    
    -- Frame das abas
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0, 80, 1, -35)
    tabFrame.Position = UDim2.new(0, 0, 0, 35)
    tabFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    tabFrame.BackgroundTransparency = 0.3
    tabFrame.BorderSizePixel = 0
    tabFrame.ZIndex = 11
    tabFrame.Parent = mainFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabFrame
    
    local dividerLine = Instance.new("Frame")
    dividerLine.Size = UDim2.new(0, 1, 1, -35)
    dividerLine.Position = UDim2.new(0, 80, 0, 35)
    dividerLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dividerLine.BackgroundTransparency = 0.3
    dividerLine.BorderSizePixel = 0
    dividerLine.ZIndex = 11
    dividerLine.Parent = mainFrame
    
    -- ABAS
    local tabEH = Instance.new("TextButton")
    tabEH.Size = UDim2.new(1, 0, 0, 65)
    tabEH.Position = UDim2.new(0, 0, 0, 5)
    tabEH.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    tabEH.BorderSizePixel = 0
    tabEH.Text = ""
    tabEH.ZIndex = 12
    tabEH.Parent = tabFrame
    CreateImageLabel(tabEH, IMAGE_EH, UDim2.new(0.5, -18, 0, 8), UDim2.new(0, 36, 0, 30))
    local tabEHText = Instance.new("TextLabel")
    tabEHText.Size = UDim2.new(1, 0, 0, 20)
    tabEHText.Position = UDim2.new(0, 0, 0, 44)
    tabEHText.BackgroundTransparency = 1
    tabEHText.Text = "EH"
    tabEHText.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabEHText.TextSize = 10
    tabEHText.Font = Enum.Font.GothamBold
    tabEHText.ZIndex = 13
    tabEHText.Parent = tabEH
    
    local tabSky = Instance.new("TextButton")
    tabSky.Size = UDim2.new(1, 0, 0, 65)
    tabSky.Position = UDim2.new(0, 0, 0, 75)
    tabSky.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    tabSky.BorderSizePixel = 0
    tabSky.Text = ""
    tabSky.ZIndex = 12
    tabSky.Parent = tabFrame
    CreateImageLabel(tabSky, IMAGE_SKY, UDim2.new(0.5, -18, 0, 8), UDim2.new(0, 36, 0, 36))
    local tabSkyText = Instance.new("TextLabel")
    tabSkyText.Size = UDim2.new(1, 0, 0, 20)
    tabSkyText.Position = UDim2.new(0, 0, 0, 44)
    tabSkyText.BackgroundTransparency = 1
    tabSkyText.Text = "SKY"
    tabSkyText.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabSkyText.TextSize = 10
    tabSkyText.Font = Enum.Font.GothamBold
    tabSkyText.ZIndex = 13
    tabSkyText.Parent = tabSky
    
    local tabConfig = Instance.new("TextButton")
    tabConfig.Size = UDim2.new(1, 0, 0, 65)
    tabConfig.Position = UDim2.new(0, 0, 0, 145)
    tabConfig.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    tabConfig.BorderSizePixel = 0
    tabConfig.Text = ""
    tabConfig.ZIndex = 12
    tabConfig.Parent = tabFrame
    CreateImageLabel(tabConfig, IMAGE_CONFIG, UDim2.new(0.5, -18, 0, 8), UDim2.new(0, 36, 0, 36))
    local tabConfigText = Instance.new("TextLabel")
    tabConfigText.Size = UDim2.new(1, 0, 0, 20)
    tabConfigText.Position = UDim2.new(0, 0, 0, 44)
    tabConfigText.BackgroundTransparency = 1
    tabConfigText.Text = "CONFIG"
    tabConfigText.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabConfigText.TextSize = 10
    tabConfigText.Font = Enum.Font.GothamBold
    tabConfigText.ZIndex = 13
    tabConfigText.Parent = tabConfig
    
    -- CONTEÚDO EH COM SCROLL
    local ehScrollFrame = Instance.new("ScrollingFrame")
    ehScrollFrame.Size = UDim2.new(1, -85, 1, -35)
    ehScrollFrame.Position = UDim2.new(0, 80, 0, 35)
    ehScrollFrame.BackgroundTransparency = 1
    ehScrollFrame.Visible = true
    ehScrollFrame.ZIndex = 11
    ehScrollFrame.ScrollBarThickness = 6
    ehScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 0)
    ehScrollFrame.Parent = mainFrame
    contentEHScroll = ehScrollFrame
    
    local contentEH = Instance.new("Frame")
    contentEH.Size = UDim2.new(1, 0, 0, 900)
    contentEH.BackgroundTransparency = 1
    contentEH.ZIndex = 11
    contentEH.Parent = ehScrollFrame
    
    ehScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 900)
    
    -- EH Aimbot
    local ehLabel1 = Instance.new("TextLabel")
    ehLabel1.Size = UDim2.new(0, 150, 0, 35)
    ehLabel1.Position = UDim2.new(0, 15, 0, 15)
    ehLabel1.BackgroundTransparency = 1
    ehLabel1.Text = "Aimbot"
    ehLabel1.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehLabel1.TextSize = 16
    ehLabel1.Font = Enum.Font.GothamBold
    ehLabel1.TextXAlignment = Enum.TextXAlignment.Left
    ehLabel1.ZIndex = 12
    ehLabel1.Parent = contentEH
    
    ehAimbotBtn = Instance.new("TextButton")
    ehAimbotBtn.Size = UDim2.new(0, 100, 0, 35)
    ehAimbotBtn.Position = UDim2.new(0, 200, 0, 15)
    ehAimbotBtn.BackgroundColor3 = Config.EH_Enabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    ehAimbotBtn.BorderSizePixel = 1
    ehAimbotBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehAimbotBtn.Text = Config.EH_Enabled and "ON" or "OFF"
    ehAimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehAimbotBtn.TextSize = 14
    ehAimbotBtn.Font = Enum.Font.GothamBold
    ehAimbotBtn.ZIndex = 12
    ehAimbotBtn.Parent = contentEH
    
    -- EH Aim Lock
    local ehLabel2 = Instance.new("TextLabel")
    ehLabel2.Size = UDim2.new(0, 150, 0, 35)
    ehLabel2.Position = UDim2.new(0, 15, 0, 65)
    ehLabel2.BackgroundTransparency = 1
    ehLabel2.Text = "Aim Lock"
    ehLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehLabel2.TextSize = 16
    ehLabel2.Font = Enum.Font.GothamBold
    ehLabel2.TextXAlignment = Enum.TextXAlignment.Left
    ehLabel2.ZIndex = 12
    ehLabel2.Parent = contentEH
    
    ehAimLockBtn = Instance.new("TextButton")
    ehAimLockBtn.Size = UDim2.new(0, 100, 0, 35)
    ehAimLockBtn.Position = UDim2.new(0, 200, 0, 65)
    ehAimLockBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ehAimLockBtn.BorderSizePixel = 1
    ehAimLockBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehAimLockBtn.Text = Config.EH_AimPart == "Torso" and "TORSO" or "HEAD"
    ehAimLockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehAimLockBtn.TextSize = 14
    ehAimLockBtn.Font = Enum.Font.GothamBold
    ehAimLockBtn.ZIndex = 12
    ehAimLockBtn.Parent = contentEH
    
    -- EH ESP
    local ehLabel3 = Instance.new("TextLabel")
    ehLabel3.Size = UDim2.new(0, 150, 0, 35)
    ehLabel3.Position = UDim2.new(0, 15, 0, 115)
    ehLabel3.BackgroundTransparency = 1
    ehLabel3.Text = "ESP"
    ehLabel3.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehLabel3.TextSize = 16
    ehLabel3.Font = Enum.Font.GothamBold
    ehLabel3.TextXAlignment = Enum.TextXAlignment.Left
    ehLabel3.ZIndex = 12
    ehLabel3.Parent = contentEH
    
    ehESPBtn = Instance.new("TextButton")
    ehESPBtn.Size = UDim2.new(0, 100, 0, 35)
    ehESPBtn.Position = UDim2.new(0, 200, 0, 115)
    ehESPBtn.BackgroundColor3 = Config.EH_ESP and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    ehESPBtn.BorderSizePixel = 1
    ehESPBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehESPBtn.Text = Config.EH_ESP and "ON" or "OFF"
    ehESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehESPBtn.TextSize = 14
    ehESPBtn.Font = Enum.Font.GothamBold
    ehESPBtn.ZIndex = 12
    ehESPBtn.Parent = contentEH
    
    -- EH ESP Health
    local ehLabel4 = Instance.new("TextLabel")
    ehLabel4.Size = UDim2.new(0, 150, 0, 35)
    ehLabel4.Position = UDim2.new(0, 15, 0, 165)
    ehLabel4.BackgroundTransparency = 1
    ehLabel4.Text = "ESP Health"
    ehLabel4.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehLabel4.TextSize = 16
    ehLabel4.Font = Enum.Font.GothamBold
    ehLabel4.TextXAlignment = Enum.TextXAlignment.Left
    ehLabel4.ZIndex = 12
    ehLabel4.Parent = contentEH
    
    ehESPHealthBtn = Instance.new("TextButton")
    ehESPHealthBtn.Size = UDim2.new(0, 100, 0, 35)
    ehESPHealthBtn.Position = UDim2.new(0, 200, 0, 165)
    ehESPHealthBtn.BackgroundColor3 = Config.EH_ESPHealth and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    ehESPHealthBtn.BorderSizePixel = 1
    ehESPHealthBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehESPHealthBtn.Text = Config.EH_ESPHealth and "ON" or "OFF"
    ehESPHealthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehESPHealthBtn.TextSize = 14
    ehESPHealthBtn.Font = Enum.Font.GothamBold
    ehESPHealthBtn.ZIndex = 12
    ehESPHealthBtn.Parent = contentEH
    
    -- EH SpinBot
    local ehLabel5 = Instance.new("TextLabel")
    ehLabel5.Size = UDim2.new(0, 150, 0, 35)
    ehLabel5.Position = UDim2.new(0, 15, 0, 215)
    ehLabel5.BackgroundTransparency = 1
    ehLabel5.Text = "SpinBot"
    ehLabel5.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehLabel5.TextSize = 16
    ehLabel5.Font = Enum.Font.GothamBold
    ehLabel5.TextXAlignment = Enum.TextXAlignment.Left
    ehLabel5.ZIndex = 12
    ehLabel5.Parent = contentEH
    
    ehSpinBotBtn = Instance.new("TextButton")
    ehSpinBotBtn.Size = UDim2.new(0, 100, 0, 35)
    ehSpinBotBtn.Position = UDim2.new(0, 200, 0, 215)
    ehSpinBotBtn.BackgroundColor3 = Config.EH_SpinBot and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    ehSpinBotBtn.BorderSizePixel = 1
    ehSpinBotBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehSpinBotBtn.Text = Config.EH_SpinBot and "ON" or "OFF"
    ehSpinBotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehSpinBotBtn.TextSize = 14
    ehSpinBotBtn.Font = Enum.Font.GothamBold
    ehSpinBotBtn.ZIndex = 12
    ehSpinBotBtn.Parent = contentEH
    
    -- Label velocidade SpinBot
    ehSpinSpeedLabel = Instance.new("TextLabel")
    ehSpinSpeedLabel.Size = UDim2.new(0, 150, 0, 25)
    ehSpinSpeedLabel.Position = UDim2.new(0, 15, 0, 260)
    ehSpinSpeedLabel.BackgroundTransparency = 1
    ehSpinSpeedLabel.Text = "Velocidade: " .. tostring(Config.EH_SpinSpeed)
    ehSpinSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehSpinSpeedLabel.TextSize = 14
    ehSpinSpeedLabel.Font = Enum.Font.GothamBold
    ehSpinSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    ehSpinSpeedLabel.ZIndex = 12
    ehSpinSpeedLabel.Parent = contentEH
    
    -- Container do slider
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(0, 200, 0, 10)
    sliderContainer.Position = UDim2.new(0, 200, 0, 267)
    sliderContainer.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    sliderContainer.BorderSizePixel = 1
    sliderContainer.BorderColor3 = Color3.fromRGB(200, 0, 0)
    sliderContainer.ZIndex = 12
    sliderContainer.Parent = contentEH
    
    ehSpinSpeedSlider = Instance.new("Frame")
    ehSpinSpeedSlider.Size = UDim2.new(Config.EH_SpinSpeed / 1000, 0, 1, 0)
    ehSpinSpeedSlider.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    ehSpinSpeedSlider.BorderSizePixel = 0
    ehSpinSpeedSlider.ZIndex = 13
    ehSpinSpeedSlider.Parent = sliderContainer
    
    local sliderClickArea = Instance.new("TextButton")
    sliderClickArea.Size = UDim2.new(1, 0, 1, 0)
    sliderClickArea.BackgroundTransparency = 1
    sliderClickArea.Text = ""
    sliderClickArea.ZIndex = 14
    sliderClickArea.Parent = sliderContainer
    
    local function UpdateSlider(input)
        local sliderPos = input.Position.X - sliderContainer.AbsolutePosition.X
        local sliderSize = sliderContainer.AbsoluteSize.X
        local percentage = math.clamp(sliderPos / sliderSize, 0, 1)
        local newSpeed = math.floor(percentage * 1000)
        
        Config.EH_SpinSpeed = newSpeed
        ehSpinSpeedSlider.Size = UDim2.new(percentage, 0, 1, 0)
        ehSpinSpeedLabel.Text = "Velocidade: " .. tostring(newSpeed)
    end
    
    local isDraggingSlider = false
    
    sliderClickArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingSlider = true
            UpdateSlider(input)
        end
    end)
    
    sliderClickArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingSlider = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end)
    
    -- EH OG Sniper
    local ehLabel6 = Instance.new("TextLabel")
    ehLabel6.Size = UDim2.new(0, 150, 0, 35)
    ehLabel6.Position = UDim2.new(0, 15, 0, 315)
    ehLabel6.BackgroundTransparency = 1
    ehLabel6.Text = "OG Sniper"
    ehLabel6.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehLabel6.TextSize = 16
    ehLabel6.Font = Enum.Font.GothamBold
    ehLabel6.TextXAlignment = Enum.TextXAlignment.Left
    ehLabel6.ZIndex = 12
    ehLabel6.Parent = contentEH
    
    ehOGSniperBtn = Instance.new("TextButton")
    ehOGSniperBtn.Size = UDim2.new(0, 100, 0, 35)
    ehOGSniperBtn.Position = UDim2.new(0, 200, 0, 315)
    ehOGSniperBtn.BackgroundColor3 = Config.EH_OGSniper and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    ehOGSniperBtn.BorderSizePixel = 1
    ehOGSniperBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehOGSniperBtn.Text = Config.EH_OGSniper and "ON" or "OFF"
    ehOGSniperBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehOGSniperBtn.TextSize = 14
    ehOGSniperBtn.Font = Enum.Font.GothamBold
    ehOGSniperBtn.ZIndex = 12
    ehOGSniperBtn.Parent = contentEH
    
    -- FRIENDS MODE COM SCROLL E AVATARES
    local dividerFriends = Instance.new("Frame")
    dividerFriends.Size = UDim2.new(1, -30, 0, 1)
    dividerFriends.Position = UDim2.new(0, 15, 0, 370)
    dividerFriends.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    dividerFriends.BackgroundTransparency = 0.5
    dividerFriends.BorderSizePixel = 0
    dividerFriends.ZIndex = 12
    dividerFriends.Parent = contentEH
    
    local ehLabelFriends = Instance.new("TextLabel")
    ehLabelFriends.Size = UDim2.new(0, 150, 0, 35)
    ehLabelFriends.Position = UDim2.new(0, 15, 0, 380)
    ehLabelFriends.BackgroundTransparency = 1
    ehLabelFriends.Text = "Friends Mode"
    ehLabelFriends.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehLabelFriends.TextSize = 16
    ehLabelFriends.Font = Enum.Font.GothamBold
    ehLabelFriends.TextXAlignment = Enum.TextXAlignment.Left
    ehLabelFriends.ZIndex = 12
    ehLabelFriends.Parent = contentEH
    
    ehFriendsModeBtn = Instance.new("TextButton")
    ehFriendsModeBtn.Size = UDim2.new(0, 100, 0, 35)
    ehFriendsModeBtn.Position = UDim2.new(0, 200, 0, 380)
    ehFriendsModeBtn.BackgroundColor3 = Config.EH_FriendsMode and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    ehFriendsModeBtn.BorderSizePixel = 1
    ehFriendsModeBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehFriendsModeBtn.Text = Config.EH_FriendsMode and "ON" or "OFF"
    ehFriendsModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehFriendsModeBtn.TextSize = 14
    ehFriendsModeBtn.Font = Enum.Font.GothamBold
    ehFriendsModeBtn.ZIndex = 12
    ehFriendsModeBtn.Parent = contentEH
    
    -- Container para adicionar jogador
    local addPlayerContainer = Instance.new("Frame")
    addPlayerContainer.Size = UDim2.new(0, 300, 0, 35)
    addPlayerContainer.Position = UDim2.new(0, 15, 0, 425)
    addPlayerContainer.BackgroundTransparency = 1
    addPlayerContainer.ZIndex = 12
    addPlayerContainer.Parent = contentEH
    
    local addPlayerInput = Instance.new("TextBox")
    addPlayerInput.Size = UDim2.new(0, 180, 1, 0)
    addPlayerInput.Position = UDim2.new(0, 0, 0, 0)
    addPlayerInput.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    addPlayerInput.BorderSizePixel = 1
    addPlayerInput.BorderColor3 = Color3.fromRGB(200, 0, 0)
    addPlayerInput.Text = "Nome do Jogador"
    addPlayerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    addPlayerInput.TextSize = 12
    addPlayerInput.Font = Enum.Font.Gotham
    addPlayerInput.PlaceholderText = "Digite o nome..."
    addPlayerInput.ZIndex = 13
    addPlayerInput.Parent = addPlayerContainer
    
    local addPlayerBtn = Instance.new("TextButton")
    addPlayerBtn.Size = UDim2.new(0, 100, 1, 0)
    addPlayerBtn.Position = UDim2.new(0, 190, 0, 0)
    addPlayerBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    addPlayerBtn.BorderSizePixel = 1
    addPlayerBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    addPlayerBtn.Text = "BLOQUEAR"
    addPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    addPlayerBtn.TextSize = 12
    addPlayerBtn.Font = Enum.Font.GothamBold
    addPlayerBtn.ZIndex = 13
    addPlayerBtn.Parent = addPlayerContainer
    
    local blockedLabel = Instance.new("TextLabel")
    blockedLabel.Size = UDim2.new(0, 200, 0, 25)
    blockedLabel.Position = UDim2.new(0, 15, 0, 470)
    blockedLabel.BackgroundTransparency = 1
    blockedLabel.Text = "Jogadores Bloqueados:"
    blockedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    blockedLabel.TextSize = 12
    blockedLabel.Font = Enum.Font.GothamBold
    blockedLabel.TextXAlignment = Enum.TextXAlignment.Left
    blockedLabel.ZIndex = 12
    blockedLabel.Parent = contentEH
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(0, 300, 0, 300)
    scrollFrame.Position = UDim2.new(0, 15, 0, 500)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    scrollFrame.BackgroundTransparency = 0.2
    scrollFrame.BorderSizePixel = 1
    scrollFrame.BorderColor3 = Color3.fromRGB(100, 0, 0)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 0)
    scrollFrame.ZIndex = 12
    scrollFrame.Parent = contentEH
    
    blockedPlayersFrame = scrollFrame
    
    -- CONTEÚDO SKY
    local contentSky = Instance.new("Frame")
    contentSky.Size = UDim2.new(1, -85, 1, -35)
    contentSky.Position = UDim2.new(0, 80, 0, 35)
    contentSky.BackgroundTransparency = 1
    contentSky.Visible = false
    contentSky.ZIndex = 11
    contentSky.Parent = mainFrame
    
    local skyTitle = Instance.new("TextLabel")
    skyTitle.Size = UDim2.new(1, -20, 0, 30)
    skyTitle.Position = UDim2.new(0, 10, 0, 10)
    skyTitle.BackgroundTransparency = 1
    skyTitle.Text = "SELECIONAR CÉU"
    skyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    skyTitle.TextSize = 18
    skyTitle.Font = Enum.Font.GothamBold
    skyTitle.ZIndex = 12
    skyTitle.Parent = contentSky
    
    local skyButtonsContainer = Instance.new("Frame")
    skyButtonsContainer.Size = UDim2.new(1, -20, 1, -50)
    skyButtonsContainer.Position = UDim2.new(0, 10, 0, 45)
    skyButtonsContainer.BackgroundTransparency = 1
    skyButtonsContainer.ZIndex = 12
    skyButtonsContainer.Parent = contentSky
    
    local buttonHeight, buttonSpacing, startY = 35, 10, 0
    for i, skyData in ipairs(SKY_LIST) do
        local skyBtn = Instance.new("TextButton")
        skyBtn.Size = UDim2.new(1, 0, 0, buttonHeight)
        skyBtn.Position = UDim2.new(0, 0, 0, startY + ((i-1) * (buttonHeight + buttonSpacing)))
        skyBtn.BackgroundColor3 = (skyData.id == Config.CurrentSkyId) and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
        skyBtn.BorderSizePixel = 1
        skyBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
        skyBtn.Text = (skyData.id == Config.CurrentSkyId) and ("✓ " .. skyData.name) or skyData.name
        skyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        skyBtn.TextSize = 14
        skyBtn.Font = Enum.Font.GothamBold
        skyBtn.ZIndex = 13
        skyBtn.Parent = skyButtonsContainer
        
        table.insert(skyButtons, {
            button = skyBtn,
            skyId = skyData.id,
            skyName = skyData.name
        })
        
        skyBtn.MouseButton1Click:Connect(function()
            ApplySky(skyData.id)
            UpdateUI()
        end)
    end
    
    -- CONTEÚDO CONFIG
    local contentConfig = Instance.new("Frame")
    contentConfig.Size = UDim2.new(1, -85, 1, -35)
    contentConfig.Position = UDim2.new(0, 80, 0, 35)
    contentConfig.BackgroundTransparency = 1
    contentConfig.Visible = false
    contentConfig.ZIndex = 11
    contentConfig.Parent = mainFrame
    
    local saveLoadTitle = Instance.new("TextLabel")
    saveLoadTitle.Size = UDim2.new(1, -20, 0, 25)
    saveLoadTitle.Position = UDim2.new(0, 10, 0, 10)
    saveLoadTitle.BackgroundTransparency = 1
    saveLoadTitle.Text = "CONFIGURAÇÕES"
    saveLoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveLoadTitle.TextSize = 16
    saveLoadTitle.Font = Enum.Font.GothamBold
    saveLoadTitle.ZIndex = 12
    saveLoadTitle.Parent = contentConfig
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 150, 0, 30)
    nameLabel.Position = UDim2.new(0, 15, 0, 45)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Nome do Arquivo:"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 12
    nameLabel.Parent = contentConfig
    
    local saveNameInput = Instance.new("TextBox")
    saveNameInput.Size = UDim2.new(0, 200, 0, 30)
    saveNameInput.Position = UDim2.new(0, 170, 0, 45)
    saveNameInput.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    saveNameInput.BorderSizePixel = 1
    saveNameInput.BorderColor3 = Color3.fromRGB(200, 0, 0)
    saveNameInput.Text = "MinhaConfig"
    saveNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveNameInput.TextSize = 14
    saveNameInput.Font = Enum.Font.GothamBold
    saveNameInput.ZIndex = 12
    saveNameInput.Parent = contentConfig
    
    local saveConfigBtn = Instance.new("TextButton")
    saveConfigBtn.Size = UDim2.new(0, 120, 0, 35)
    saveConfigBtn.Position = UDim2.new(0, 15, 0, 90)
    saveConfigBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    saveConfigBtn.BorderSizePixel = 1
    saveConfigBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    saveConfigBtn.Text = "SALVAR CONFIG"
    saveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveConfigBtn.TextSize = 12
    saveConfigBtn.Font = Enum.Font.GothamBold
    saveConfigBtn.ZIndex = 12
    saveConfigBtn.Parent = contentConfig
    
    local loadConfigBtn = Instance.new("TextButton")
    loadConfigBtn.Size = UDim2.new(0, 120, 0, 35)
    loadConfigBtn.Position = UDim2.new(0, 150, 0, 90)
    loadConfigBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    loadConfigBtn.BorderSizePixel = 1
    loadConfigBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    loadConfigBtn.Text = "CARREGAR CONFIG"
    loadConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadConfigBtn.TextSize = 12
    loadConfigBtn.Font = Enum.Font.GothamBold
    loadConfigBtn.ZIndex = 12
    loadConfigBtn.Parent = contentConfig
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -30, 0, 30)
    statusLabel.Position = UDim2.new(0, 15, 0, 135)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Pronto"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 12
    statusLabel.Parent = contentConfig
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -30, 0, 1)
    divider.Position = UDim2.new(0, 15, 0, 180)
    divider.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.ZIndex = 12
    divider.Parent = contentConfig
    
    local keysTitle = Instance.new("TextLabel")
    keysTitle.Size = UDim2.new(1, -20, 0, 25)
    keysTitle.Position = UDim2.new(0, 10, 0, 195)
    keysTitle.BackgroundTransparency = 1
    keysTitle.Text = "TECLAS DE ATALHO"
    keysTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    keysTitle.TextSize = 14
    keysTitle.Font = Enum.Font.GothamBold
    keysTitle.ZIndex = 12
    keysTitle.Parent = contentConfig
    
    local labelKey1 = Instance.new("TextLabel")
    labelKey1.Size = UDim2.new(0, 150, 0, 35)
    labelKey1.Position = UDim2.new(0, 15, 0, 225)
    labelKey1.BackgroundTransparency = 1
    labelKey1.Text = "Abrir Interface"
    labelKey1.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelKey1.TextSize = 14
    labelKey1.Font = Enum.Font.GothamBold
    labelKey1.TextXAlignment = Enum.TextXAlignment.Left
    labelKey1.ZIndex = 12
    labelKey1.Parent = contentConfig
    
    local interfaceKeyBtn = Instance.new("TextButton")
    interfaceKeyBtn.Size = UDim2.new(0, 100, 0, 35)
    interfaceKeyBtn.Position = UDim2.new(0, 200, 0, 225)
    interfaceKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    interfaceKeyBtn.BorderSizePixel = 1
    interfaceKeyBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    interfaceKeyBtn.Text = "Insert"
    interfaceKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    interfaceKeyBtn.TextSize = 14
    interfaceKeyBtn.Font = Enum.Font.GothamBold
    interfaceKeyBtn.ZIndex = 12
    interfaceKeyBtn.Parent = contentConfig
    
    local labelKey3 = Instance.new("TextLabel")
    labelKey3.Size = UDim2.new(0, 150, 0, 35)
    labelKey3.Position = UDim2.new(0, 15, 0, 270)
    labelKey3.BackgroundTransparency = 1
    labelKey3.Text = "Aimbot EH"
    labelKey3.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelKey3.TextSize = 14
    labelKey3.Font = Enum.Font.GothamBold
    labelKey3.TextXAlignment = Enum.TextXAlignment.Left
    labelKey3.ZIndex = 12
    labelKey3.Parent = contentConfig
    
    ehKeyBtn = Instance.new("TextButton")
    ehKeyBtn.Size = UDim2.new(0, 100, 0, 35)
    ehKeyBtn.Position = UDim2.new(0, 200, 0, 270)
    ehKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ehKeyBtn.BorderSizePixel = 1
    ehKeyBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehKeyBtn.Text = Config.EH_Key
    ehKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehKeyBtn.TextSize = 14
    ehKeyBtn.Font = Enum.Font.GothamBold
    ehKeyBtn.ZIndex = 12
    ehKeyBtn.Parent = contentConfig
    
    -- EVENTOS DAS ABAS
    tabEH.MouseButton1Click:Connect(function()
        currentTab = "Emergency Hamburg"
        ehScrollFrame.Visible = true
        contentSky.Visible = false
        contentConfig.Visible = false
        tabEH.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        tabSky.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabConfig.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    end)
    
    tabSky.MouseButton1Click:Connect(function()
        currentTab = "Sky"
        ehScrollFrame.Visible = false
        contentSky.Visible = true
        contentConfig.Visible = false
        tabEH.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabSky.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        tabConfig.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        UpdateUI()
    end)
    
    tabConfig.MouseButton1Click:Connect(function()
        currentTab = "Config"
        ehScrollFrame.Visible = false
        contentSky.Visible = false
        contentConfig.Visible = true
        tabEH.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabSky.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabConfig.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end)
    
    -- EVENTOS DOS BOTÕES EH
    ehAimbotBtn.MouseButton1Click:Connect(function()
        Config.EH_Enabled = not Config.EH_Enabled
        UpdateUI()
    end)
    
    ehAimLockBtn.MouseButton1Click:Connect(function()
        Config.EH_AimPart = (Config.EH_AimPart == "Torso") and "Head" or "Torso"
        UpdateUI()
    end)
    
    ehESPBtn.MouseButton1Click:Connect(function()
        Config.EH_ESP = not Config.EH_ESP
        UpdateUI()
        EnableESP()
    end)
    
    ehESPHealthBtn.MouseButton1Click:Connect(function()
        Config.EH_ESPHealth = not Config.EH_ESPHealth
        UpdateUI()
        EnableESP()
    end)
    
    -- EVENTO FRIENDS MODE
    ehFriendsModeBtn.MouseButton1Click:Connect(function()
        Config.EH_FriendsMode = not Config.EH_FriendsMode
        UpdateUI()
    end)
    
    -- EVENTO ADICIONAR JOGADOR
    addPlayerBtn.MouseButton1Click:Connect(function()
        local playerName = addPlayerInput.Text
        if playerName and playerName ~= "" and playerName ~= "Nome do Jogador" then
            if AddBlockedPlayer(playerName) then
                addPlayerInput.Text = "Nome do Jogador"
                UpdateBlockedPlayersList()
            else
                addPlayerInput.Text = "Já existe!"
                task.wait(1)
                addPlayerInput.Text = "Nome do Jogador"
            end
        end
    end)
    
    -- EVENTO SPINBOT
    ehSpinBotBtn.MouseButton1Click:Connect(function()
        ToggleSpinBot()
    end)
    
    -- EVENTO OG SNIPER
    ehOGSniperBtn.MouseButton1Click:Connect(function()
        ToggleOGSniper()
    end)
    
    -- EVENTOS SAVE/LOAD
    saveConfigBtn.MouseButton1Click:Connect(function()
        if SaveConfigToFile() then
            statusLabel.Text = "✓ Config salva!"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            statusLabel.Text = "✗ Erro ao salvar!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        task.wait(2)
        statusLabel.Text = "Pronto"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end)
    
    loadConfigBtn.MouseButton1Click:Connect(function()
        if LoadConfigFromFile() then
            statusLabel.Text = "✓ Config carregada!"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            statusLabel.Text = "✗ Erro ao carregar!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        task.wait(2)
        statusLabel.Text = "Pronto"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end)
    
    -- EVENTOS DE TECLAS
    local waitingForKey = false
    local waitingForWhich = nil
    
    local function SetupKeyButton(button, keyType)
        button.MouseButton1Click:Connect(function()
            local oldText = button.Text
            button.Text = "..."
            waitingForKey = true
            waitingForWhich = keyType
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    local keyName = input.KeyCode.Name
                    
                    if keyType == "Aimbot EH" then
                        Config.EH_Key = keyName
                    end
                    
                    waitingForKey = false
                    waitingForWhich = nil
                    connection:Disconnect()
                    UpdateUI()
                end
            end)
            
            task.wait(0.5)
            if waitingForKey then
                waitingForKey = false
                waitingForWhich = nil
                connection:Disconnect()
                button.Text = oldText
            end
        end)
    end
    
    SetupKeyButton(ehKeyBtn, "Aimbot EH")
    
    -- MOVER INTERFACE
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            dragStartPos = mainFrame.Position
            
            dragConnection = UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = input.Position - dragStart
                    local newX = math.clamp(dragStartPos.X.Offset + delta.X, 0, Camera.ViewportSize.X - mainFrame.AbsoluteSize.X)
                    local newY = math.clamp(dragStartPos.Y.Offset + delta.Y, 0, Camera.ViewportSize.Y - mainFrame.AbsoluteSize.Y)
                    mainFrame.Position = UDim2.new(0, newX, 0, newY)
                end
            end)
            
            dragEndConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                    if dragConnection then dragConnection:Disconnect() end
                    if dragEndConnection then dragEndConnection:Disconnect() end
                end
            end)
        end
    end)
    
    -- FECHAR
    closeBtn.MouseButton1Click:Connect(function()
        PanelOpen = false
        mainFrame.Visible = false
        DisableESP()
    end)
    
    UpdateUI()
    return screenGui, mainFrame
end

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
local PanelGui, PanelFrame = CreateGUI()
PanelFrame.Visible = true
PanelOpen = true

SaveOriginalSky()
if Config.CurrentSkyId and Config.CurrentSkyId > 1 then
    ApplySky(Config.CurrentSkyId)
end

-- INPUT EVENTS
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode.Name == "Insert" then
        PanelOpen = not PanelOpen
        PanelFrame.Visible = PanelOpen
        if not PanelOpen then
            DisableESP()
        end
    elseif input.KeyCode.Name == Config.EH_Key then
        Config.EH_Enabled = not Config.EH_Enabled
        UpdateUI()
    end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Config.EH_Enabled and not PanelOpen then
            isAiming = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
    end
end)

-- Limpar ao fechar
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        ClearESP()
        RemoveG36Crosshair()
        RestoreOriginalScopes()
    end
end)
