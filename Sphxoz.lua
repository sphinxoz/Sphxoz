-- AIMBOT RIVALS + EMERGENCY HAMBURG
-- INTERFACE 800x500

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

-- ============================================
-- SALVAR CONFIGURACOES
-- ============================================

if not getgenv().AimbotConfig then
    getgenv().AimbotConfig = {
        -- RIVALS
        Enabled = false,
        Smoothness = 3.0,
        FOV = 180,
        AimPart = "Torso",
        Humanize = true,
        InterfaceKey = "Insert",
        AimbotKey = "X",
        -- EMERGENCY HAMBURG
        EH_Enabled = false,
        EH_AimPart = "Torso",
        EH_ESP = false,
        EH_ESPHealth = false,
        EH_FriendsMode = false,
        EH_Key = "Z",
        -- SKY
        CurrentSky = "Default",
    }
end

local Config = getgenv().AimbotConfig

if Config.Smoothness < 1.0 then
    Config.Smoothness = 3.0
end

local PanelOpen = true
local isAiming = false
local isDragging = false
local dragStart = nil
local dragStartPos = nil
local dragConnection = nil
local dragEndConnection = nil

-- ============================================
-- ⭐ CONFIGURACAO DOS CEUS
-- ============================================
-- ⭐ COMO ADICIONAR UM NOVO CEU:
-- 1. Faça upload da imagem do céu no Roblox (Create > Decals)
-- 2. Copie o ID do decalque
-- 3. Adicione uma nova linha na tabela SKY_DATA abaixo
-- 4. O script vai criar automaticamente o botão na aba Sky
-- ============================================

local SKY_DATA = {
    -- {Nome, ID do Decalque}
    {"Default", nil},  -- ⭐ Céu padrão (não muda nada)
    {"Céu 1", "rbxassetid://SEU_ID_AQUI_1"},
    {"Céu 2", "rbxassetid://SEU_ID_AQUI_2"},
    {"Céu 3", "rbxassetid://SEU_ID_AQUI_3"},
    {"Céu 4", "rbxassetid://SEU_ID_AQUI_4"},
    -- ⭐ ADICIONE NOVOS CEUS AQUI:
    -- {"Nome do Céu", "rbxassetid://ID_DO_DECALQUE"},
}

-- ============================================
-- ⭐ FUNCAO: TROCAR CEU
-- ============================================

local function ChangeSky(skyId, skyName)
    -- Remove o céu atual
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end
    
    -- Se for "Default", não cria novo céu
    if skyId == nil or skyId == "Default" then
        Config.CurrentSky = "Default"
        return
    end
    
    -- Cria o novo céu
    local newSky = Instance.new("Sky")
    newSky.SkyboxBk = skyId
    newSky.SkyboxDn = skyId
    newSky.SkyboxFt = skyId
    newSky.SkyboxLf = skyId
    newSky.SkyboxRt = skyId
    newSky.SkyboxUp = skyId
    newSky.Parent = Lighting
    
    Config.CurrentSky = skyName
end

-- ============================================
-- VARIAVEIS DA INTERFACE
-- ============================================

local aimbotBtn = nil
local aimLockBtn = nil
local smoothSliderBtn = nil
local smoothProgress = nil
local smoothValueLabel = nil
local fovSliderBtn = nil
local fovProgress = nil
local fovValueLabel = nil
local interfaceKeyBtn = nil
local aimbotKeyBtn = nil
local mainFrame = nil
local currentTab = "Rivals"
local isDraggingSmooth = false
local isDraggingFOV = false
local waitingForKey = false
local waitingForWhich = nil

-- ============================================
-- VARIAVEIS EMERGENCY HAMBURG
-- ============================================

local ehAimbotBtn = nil
local ehAimLockBtn = nil
local ehESPBtn = nil
local ehESPHealthBtn = nil
local ehFriendsModeBtn = nil
local espObjects = {}
local espHealthObjects = {}
local espConnections = {}
local ehKeyBtn = nil
local espActive = false
local lockedTarget = nil
local lockedPart = nil

-- ============================================
-- VARIAVEIS SKY
-- ============================================

local skyButtons = {}

-- ============================================
-- FUNCAO: VERIFICA SE E INIMIGO (RIVALS)
-- ============================================

local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    local myTeam = LocalPlayer.Team
    local theirTeam = player.Team
    if myTeam and theirTeam then
        return myTeam ~= theirTeam
    end
    return true
end

-- ============================================
-- FUNCAO: VERIFICA SE O ALVO ESTA VISIVEL (RIVALS)
-- ============================================

local function IsTargetVisible(targetPart)
    if not targetPart then return false end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit
    local distance = (targetPart.Position - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local ray = workspace:Raycast(origin, direction * distance, raycastParams)
    
    if ray then
        local hit = ray.Instance
        if hit and not hit:IsDescendantOf(targetPart.Parent) then
            return false
        end
    end
    
    return true, screenPos
end

-- ============================================
-- FUNCAO: PEGA A PARTE DO CORPO (RIVALS)
-- ============================================

local function GetAimPart(player)
    if not player or not player.Character then return nil end
    
    local character = player.Character
    
    if Config.AimPart == "Head" then
        local head = character:FindFirstChild("Head")
        if head then return head end
    end
    
    if Config.AimPart == "Torso" then
        local torso = character:FindFirstChild("UpperTorso")
        if torso then return torso end
    end
    
    return character:FindFirstChild("HumanoidRootPart")
end

-- ============================================
-- FUNCAO: ADICIONA ERRO ALEATORIO
-- ============================================

local function GetHumanizedOffset()
    return math.random(-3, 3)
end

-- ============================================
-- FUNCAO: ENCONTRA O ALVO MAIS PROXIMO (RIVALS)
-- ============================================

local function GetTarget()
    local targetPart = nil
    local targetScreenPos = nil
    local dist = Config.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) then
            local part = GetAimPart(player)
            
            if part then
                local visible, screenPos = IsTargetVisible(part)
                if visible and screenPos then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if mag < dist then
                        dist = mag
                        targetPart = part
                        targetScreenPos = screenPos
                    end
                end
            end
        end
    end
    
    return targetPart, targetScreenPos
end

-- ============================================
-- LOOP PRINCIPAL (RIVALS)
-- ============================================

RunService.RenderStepped:Connect(function()
    if not Config.Enabled then return end
    if not isAiming then return end
    if PanelOpen then return end
    
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        isAiming = false
        return
    end
    
    local targetPart, screenPos = GetTarget()
    if not targetPart or not screenPos then return end
    
    local mousePos = UserInputService:GetMouseLocation()
    
    local offsetX = Config.Humanize and GetHumanizedOffset() or 0
    local offsetY = Config.Humanize and GetHumanizedOffset() or 0
    
    local x = (screenPos.X - mousePos.X + offsetX) * (Config.Smoothness / 10)
    local y = (screenPos.Y - mousePos.Y + offsetY) * (Config.Smoothness / 10)
    
    if mousemoverel then
        mousemoverel(x, y)
    end
end)

-- ============================================
-- FUNCAO: CONTROLAR CURSOR
-- ============================================

local function UpdateMouseBehavior()
    if PanelOpen then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        return
    end
    
    if isAiming and Config.Enabled then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false
        return
    end
    
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
end

-- ============================================
-- FUNCAO: ATUALIZAR INTERFACE
-- ============================================

local function UpdateUI()
    -- RIVALS
    if aimbotBtn then
        aimbotBtn.Text = Config.Enabled and "ON" or "OFF"
        aimbotBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    if aimLockBtn then
        aimLockBtn.Text = Config.AimPart == "Torso" and "TORSO" or "HEAD"
    end
    if interfaceKeyBtn then
        interfaceKeyBtn.Text = Config.InterfaceKey
    end
    if aimbotKeyBtn then
        aimbotKeyBtn.Text = Config.AimbotKey
    end
    if smoothValueLabel then
        smoothValueLabel.Text = string.format("%.1f", Config.Smoothness)
    end
    if fovValueLabel then
        fovValueLabel.Text = tostring(Config.FOV)
    end
    if smoothProgress then
        smoothProgress.Size = UDim2.new((Config.Smoothness - 0.1) / 2.9, 0, 1, 0)
    end
    if smoothSliderBtn then
        smoothSliderBtn.Position = UDim2.new((Config.Smoothness - 0.1) / 2.9, -8, 0.5, -8)
    end
    if fovProgress then
        fovProgress.Size = UDim2.new((Config.FOV - 50) / 450, 0, 1, 0)
    end
    if fovSliderBtn then
        fovSliderBtn.Position = UDim2.new((Config.FOV - 50) / 450, -8, 0.5, -8)
    end
    -- EMERGENCY HAMBURG
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
end

-- ============================================
-- FUNCAO: CRIAR IMAGEM
-- ============================================

local IMAGE_RIVALS = "rbxassetid://13832750495"
local IMAGE_EH = "rbxassetid://13832761876"
local IMAGE_CONFIG = "rbxassetid://13832758139"
local IMAGE_SKY = "rbxassetid://13832758139"

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

-- ============================================
-- FUNCAO: VERIFICA SE ESTA NO EMERGENCY HAMBURG
-- ============================================

local function IsInEmergencyHamburg()
    return game.PlaceId == 7711635737
end

-- ============================================
-- FUNCAO: VERIFICA SE E AMIGO (FRIENDS MODE)
-- ============================================

local function IsFriend(player)
    if not Config.EH_FriendsMode then return false end
    if not player then return false end
    local friends = LocalPlayer.Friends
    if friends then
        for _, friend in ipairs(friends:GetChildren()) do
            if friend.Name == player.Name then
                return true
            end
        end
    end
    return false
end

-- ============================================
-- FUNCAO: VERIFICA SE ESTA EM UM VEICULO
-- ============================================

local function IsInVehicle()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        local seatPart = humanoid.SeatPart
        if seatPart then
            local vehicle = seatPart.Parent
            if vehicle and vehicle:FindFirstChild("VehicleSeat") then
                return true
            end
        end
    end
    return false
end

-- ============================================
-- FUNCOES EMERGENCY HAMBURG
-- ============================================

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

local function IsValidTarget(player)
    if not player then return false end
    if player == LocalPlayer then return false end
    
    if IsFriend(player) then
        return false
    end
    
    if not player.Character then return false end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    return true
end

local function GetBestTargetPart(player)
    if not player or not player.Character then return nil end
    
    local character = player.Character
    local targetPart = nil
    
    if Config.EH_AimPart == "Head" then
        targetPart = character:FindFirstChild("Head")
    else
        targetPart = character:FindFirstChild("UpperTorso")
    end
    
    if targetPart then
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if onScreen then
            return targetPart
        end
    end
    
    local parts = {"Head", "UpperTorso", "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "HumanoidRootPart"}
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

-- ============================================
-- FUNCAO: PEGA A VELOCIDADE (MESMO EM VEICULO)
-- ============================================

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
-- LOOP EMERGENCY HAMBURG (AIMBOT COM LOCK)
-- ============================================

RunService.RenderStepped:Connect(function()
    if not Config.EH_Enabled then return end
    if not IsInEmergencyHamburg() then return end
    if PanelOpen then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not IsEHWeapon(tool) then return end
    
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
                
                local leadX = 0
                local leadY = 0
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
    
    local closestPart = nil
    local closestPlayer = nil
    local closestScore = 999999
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
            
            local leadX = 0
            local leadY = 0
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
-- ESP (EMERGENCY HAMBURG)
-- ============================================

local function ClearESP()
    for _, conn in ipairs(espConnections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    espConnections = {}
    
    for _, group in ipairs(espObjects) do
        for _, obj in ipairs(group) do
            if obj and obj.Parent then
                pcall(function() obj:Destroy() end)
            end
        end
    end
    espObjects = {}
    
    for _, group in ipairs(espHealthObjects) do
        for _, obj in ipairs(group) do
            if obj and obj.Parent then
                pcall(function() obj:Destroy() end)
            end
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
            frame.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            frame.BackgroundTransparency = size <= 3 and 0.4 or 0.2
            frame.BorderSizePixel = 0
            frame.Parent = esp
            
            table.insert(group, esp)
        end
    end
    
    local connections = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"UpperTorso", "RightUpperArm"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LowerTorso", "RightUpperLeg"},
    }
    
    for _, conn in ipairs(connections) do
        local p1 = parts[conn[1]]
        local p2 = parts[conn[2]]
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
            frame.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
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
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName or player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = frame
    
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(1, 0, 0.3, 0)
    healthBarBg.Position = UDim2.new(0, 0, 0.55, 0)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = frame
    
    local healthBar = Instance.new("Frame")
    local hpPercent = humanoid.Health / humanoid.MaxHealth
    healthBar.Size = UDim2.new(hpPercent, 0, 1, 0)
    healthBar.BackgroundColor3 = humanoid.Health > 50 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBg
    
    local healthText = Instance.new("TextLabel")
    healthText.Size = UDim2.new(1, 0, 1, 0)
    healthText.Position = UDim2.new(0, 0, 0, 0)
    healthText.BackgroundTransparency = 1
    healthText.Text = tostring(math.floor(humanoid.Health)) .. "/" .. tostring(humanoid.MaxHealth)
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.TextSize = 9
    healthText.Font = Enum.Font.GothamBold
    healthText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthText.TextStrokeTransparency = 0.3
    healthText.Parent = healthBarBg
    
    table.insert(espGroup, infoEsp)
    
    local healthConnection
    healthConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid and healthBar then
            local newPercent = humanoid.Health / humanoid.MaxHealth
            healthBar.Size = UDim2.new(newPercent, 0, 1, 0)
            healthBar.BackgroundColor3 = humanoid.Health > 50 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            healthText.Text = tostring(math.floor(humanoid.Health)) .. "/" .. tostring(humanoid.MaxHealth)
        end
    end)
    
    table.insert(espConnections, healthConnection)
    
    return espGroup
end

-- ============================================
-- FUNCOES: ENABLE/DISABLE ESP
-- ============================================

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
    espActive = false
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
-- ⭐ FUNCAO: CRIAR INTERFACE
-- ============================================

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
    border.Position = UDim2.new(0, 0, 0, 0)
    border.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    border.BackgroundTransparency = 0.7
    border.BorderSizePixel = 0
    border.ZIndex = 5
    border.Parent = mainFrame
    
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 12)
    borderCorner.Parent = border
    
    local function CreateDot(x, y, size)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, size or 3, 0, size or 3)
        dot.Position = UDim2.new(0, x, 0, y)
        dot.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        dot.BackgroundTransparency = 0.4
        dot.BorderSizePixel = 0
        dot.ZIndex = 1
        dot.Parent = mainFrame
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        return dot
    end
    
    for i = 1, 60 do
        CreateDot(math.random(10, 780), math.random(30, 480), math.random(2, 5))
    end
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleBar.BackgroundTransparency = 0
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
    
    -- ============================================
    -- ABAS
    -- ============================================
    
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
    
    -- ABA RIVALS
    local tabRivals = Instance.new("TextButton")
    tabRivals.Size = UDim2.new(1, 0, 0, 55)
    tabRivals.Position = UDim2.new(0, 0, 0, 5)
    tabRivals.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    tabRivals.BorderSizePixel = 0
    tabRivals.Text = ""
    tabRivals.ZIndex = 12
    tabRivals.Parent = tabFrame
    
    local rivalsCorner = Instance.new("UICorner")
    rivalsCorner.CornerRadius = UDim.new(0, 6)
    rivalsCorner.Parent = tabRivals
    
    local rivalsIcon = CreateImageLabel(tabRivals, IMAGE_RIVALS, UDim2.new(0.5, -20, 0, 8), UDim2.new(0, 35, 0, 30))
    
    local tabRivalsText = Instance.new("TextLabel")
    tabRivalsText.Size = UDim2.new(1, 0, 0, 20)
    tabRivalsText.Position = UDim2.new(0, 0, 0, 38)
    tabRivalsText.BackgroundTransparency = 1
    tabRivalsText.Text = "RIVALS"
    tabRivalsText.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabRivalsText.TextSize = 9
    tabRivalsText.Font = Enum.Font.GothamBold
    tabRivalsText.ZIndex = 13
    tabRivalsText.Parent = tabRivals
    
    -- ABA EH
    local tabEH = Instance.new("TextButton")
    tabEH.Size = UDim2.new(1, 0, 0, 55)
    tabEH.Position = UDim2.new(0, 0, 0, 65)
    tabEH.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    tabEH.BorderSizePixel = 0
    tabEH.Text = ""
    tabEH.ZIndex = 12
    tabEH.Parent = tabFrame
    
    local ehCorner = Instance.new("UICorner")
    ehCorner.CornerRadius = UDim.new(0, 6)
    ehCorner.Parent = tabEH
    
    local ehIcon = CreateImageLabel(tabEH, IMAGE_EH, UDim2.new(0.5, -18, 0, 8), UDim2.new(0, 32, 0, 30))
    
    local tabEHText = Instance.new("TextLabel")
    tabEHText.Size = UDim2.new(1, 0, 0, 20)
    tabEHText.Position = UDim2.new(0, 0, 0, 38)
    tabEHText.BackgroundTransparency = 1
    tabEHText.Text = "EH"
    tabEHText.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabEHText.TextSize = 9
    tabEHText.Font = Enum.Font.GothamBold
    tabEHText.ZIndex = 13
    tabEHText.Parent = tabEH
    
    -- ⭐ ABA SKY (NOVA)
    local tabSky = Instance.new("TextButton")
    tabSky.Size = UDim2.new(1, 0, 0, 55)
    tabSky.Position = UDim2.new(0, 0, 0, 125)
    tabSky.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    tabSky.BorderSizePixel = 0
    tabSky.Text = ""
    tabSky.ZIndex = 12
    tabSky.Parent = tabFrame
    
    local skyCorner = Instance.new("UICorner")
    skyCorner.CornerRadius = UDim.new(0, 6)
    skyCorner.Parent = tabSky
    
    local skyIcon = CreateImageLabel(tabSky, IMAGE_SKY, UDim2.new(0.5, -18, 0, 8), UDim2.new(0, 32, 0, 30))
    
    local tabSkyText = Instance.new("TextLabel")
    tabSkyText.Size = UDim2.new(1, 0, 0, 20)
    tabSkyText.Position = UDim2.new(0, 0, 0, 38)
    tabSkyText.BackgroundTransparency = 1
    tabSkyText.Text = "SKY"
    tabSkyText.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabSkyText.TextSize = 9
    tabSkyText.Font = Enum.Font.GothamBold
    tabSkyText.ZIndex = 13
    tabSkyText.Parent = tabSky
    
    -- ABA CONFIG
    local tabConfig = Instance.new("TextButton")
    tabConfig.Size = UDim2.new(1, 0, 0, 55)
    tabConfig.Position = UDim2.new(0, 0, 0, 185)
    tabConfig.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    tabConfig.BorderSizePixel = 0
    tabConfig.Text = ""
    tabConfig.ZIndex = 12
    tabConfig.Parent = tabFrame
    
    local configCorner = Instance.new("UICorner")
    configCorner.CornerRadius = UDim.new(0, 6)
    configCorner.Parent = tabConfig
    
    local configIcon = CreateImageLabel(tabConfig, IMAGE_CONFIG, UDim2.new(0.5, -18, 0, 8), UDim2.new(0, 32, 0, 36))
    
    local tabConfigText = Instance.new("TextLabel")
    tabConfigText.Size = UDim2.new(1, 0, 0, 20)
    tabConfigText.Position = UDim2.new(0, 0, 0, 40)
    tabConfigText.BackgroundTransparency = 1
    tabConfigText.Text = "CONFIG"
    tabConfigText.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabConfigText.TextSize = 9
    tabConfigText.Font = Enum.Font.GothamBold
    tabConfigText.ZIndex = 13
    tabConfigText.Parent = tabConfig
    
    -- ============================================
    -- CONTEUDO RIVALS
    -- ============================================
    
    local contentRivals = Instance.new("Frame")
    contentRivals.Size = UDim2.new(1, -85, 1, -35)
    contentRivals.Position = UDim2.new(0, 80, 0, 35)
    contentRivals.BackgroundTransparency = 1
    contentRivals.ZIndex = 11
    contentRivals.Parent = mainFrame
    
    local label1 = Instance.new("TextLabel")
    label1.Size = UDim2.new(0, 120, 0, 35)
    label1.Position = UDim2.new(0, 15, 0, 15)
    label1.BackgroundTransparency = 1
    label1.Text = "Aimbot"
    label1.TextColor3 = Color3.fromRGB(255, 255, 255)
    label1.TextSize = 16
    label1.Font = Enum.Font.GothamBold
    label1.TextXAlignment = Enum.TextXAlignment.Left
    label1.ZIndex = 12
    label1.Parent = contentRivals
    
    aimbotBtn = Instance.new("TextButton")
    aimbotBtn.Size = UDim2.new(0, 100, 0, 35)
    aimbotBtn.Position = UDim2.new(0, 200, 0, 15)
    aimbotBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    aimbotBtn.BorderSizePixel = 1
    aimbotBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    aimbotBtn.Text = "OFF"
    aimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotBtn.TextSize = 14
    aimbotBtn.Font = Enum.Font.GothamBold
    aimbotBtn.ZIndex = 12
    aimbotBtn.Parent = contentRivals
    
    local label2 = Instance.new("TextLabel")
    label2.Size = UDim2.new(0, 120, 0, 35)
    label2.Position = UDim2.new(0, 15, 0, 65)
    label2.BackgroundTransparency = 1
    label2.Text = "Aim Lock"
    label2.TextColor3 = Color3.fromRGB(255, 255, 255)
    label2.TextSize = 16
    label2.Font = Enum.Font.GothamBold
    label2.TextXAlignment = Enum.TextXAlignment.Left
    label2.ZIndex = 12
    label2.Parent = contentRivals
    
    aimLockBtn = Instance.new("TextButton")
    aimLockBtn.Size = UDim2.new(0, 100, 0, 35)
    aimLockBtn.Position = UDim2.new(0, 200, 0, 65)
    aimLockBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    aimLockBtn.BorderSizePixel = 1
    aimLockBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    aimLockBtn.Text = "TORSO"
    aimLockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimLockBtn.TextSize = 14
    aimLockBtn.Font = Enum.Font.GothamBold
    aimLockBtn.ZIndex = 12
    aimLockBtn.Parent = contentRivals
    
    local label3 = Instance.new("TextLabel")
    label3.Size = UDim2.new(0, 120, 0, 30)
    label3.Position = UDim2.new(0, 15, 0, 115)
    label3.BackgroundTransparency = 1
    label3.Text = "Smooth"
    label3.TextColor3 = Color3.fromRGB(255, 255, 255)
    label3.TextSize = 16
    label3.Font = Enum.Font.GothamBold
    label3.TextXAlignment = Enum.TextXAlignment.Left
    label3.ZIndex = 12
    label3.Parent = contentRivals
    
    local smoothSliderFrame = Instance.new("Frame")
    smoothSliderFrame.Size = UDim2.new(0, 300, 0, 8)
    smoothSliderFrame.Position = UDim2.new(0, 140, 0, 125)
    smoothSliderFrame.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    smoothSliderFrame.BorderSizePixel = 1
    smoothSliderFrame.BorderColor3 = Color3.fromRGB(200, 0, 0)
    smoothSliderFrame.ZIndex = 12
    smoothSliderFrame.Parent = contentRivals
    
    smoothProgress = Instance.new("Frame")
    smoothProgress.Size = UDim2.new((Config.Smoothness - 0.1) / 2.9, 0, 1, 0)
    smoothProgress.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    smoothProgress.BorderSizePixel = 0
    smoothProgress.ZIndex = 13
    smoothProgress.Parent = smoothSliderFrame
    
    smoothSliderBtn = Instance.new("TextButton")
    smoothSliderBtn.Size = UDim2.new(0, 16, 0, 16)
    smoothSliderBtn.Position = UDim2.new((Config.Smoothness - 0.1) / 2.9, -8, 0.5, -8)
    smoothSliderBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    smoothSliderBtn.BorderSizePixel = 2
    smoothSliderBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    smoothSliderBtn.Text = ""
    smoothSliderBtn.ZIndex = 14
    smoothSliderBtn.Parent = smoothSliderFrame
    
    smoothValueLabel = Instance.new("TextLabel")
    smoothValueLabel.Size = UDim2.new(0, 60, 0, 30)
    smoothValueLabel.Position = UDim2.new(0, 450, 0, 115)
    smoothValueLabel.BackgroundTransparency = 1
    smoothValueLabel.Text = string.format("%.1f", Config.Smoothness)
    smoothValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    smoothValueLabel.TextSize = 14
    smoothValueLabel.Font = Enum.Font.GothamBold
    smoothValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    smoothValueLabel.ZIndex = 12
    smoothValueLabel.Parent = contentRivals
    
    local label4 = Instance.new("TextLabel")
    label4.Size = UDim2.new(0, 120, 0, 30)
    label4.Position = UDim2.new(0, 15, 0, 165)
    label4.BackgroundTransparency = 1
    label4.Text = "FOV"
    label4.TextColor3 = Color3.fromRGB(255, 255, 255)
    label4.TextSize = 16
    label4.Font = Enum.Font.GothamBold
    label4.TextXAlignment = Enum.TextXAlignment.Left
    label4.ZIndex = 12
    label4.Parent = contentRivals
    
    local fovSliderFrame = Instance.new("Frame")
    fovSliderFrame.Size = UDim2.new(0, 300, 0, 8)
    fovSliderFrame.Position = UDim2.new(0, 140, 0, 175)
    fovSliderFrame.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    fovSliderFrame.BorderSizePixel = 1
    fovSliderFrame.BorderColor3 = Color3.fromRGB(200, 0, 0)
    fovSliderFrame.ZIndex = 12
    fovSliderFrame.Parent = contentRivals
    
    fovProgress = Instance.new("Frame")
    fovProgress.Size = UDim2.new((Config.FOV - 50) / 450, 0, 1, 0)
    fovProgress.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    fovProgress.BorderSizePixel = 0
    fovProgress.ZIndex = 13
    fovProgress.Parent = fovSliderFrame
    
    fovSliderBtn = Instance.new("TextButton")
    fovSliderBtn.Size = UDim2.new(0, 16, 0, 16)
    fovSliderBtn.Position = UDim2.new((Config.FOV - 50) / 450, -8, 0.5, -8)
    fovSliderBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    fovSliderBtn.BorderSizePixel = 2
    fovSliderBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    fovSliderBtn.Text = ""
    fovSliderBtn.ZIndex = 14
    fovSliderBtn.Parent = fovSliderFrame
    
    fovValueLabel = Instance.new("TextLabel")
    fovValueLabel.Size = UDim2.new(0, 60, 0, 30)
    fovValueLabel.Position = UDim2.new(0, 450, 0, 165)
    fovValueLabel.BackgroundTransparency = 1
    fovValueLabel.Text = tostring(Config.FOV)
    fovValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovValueLabel.TextSize = 14
    fovValueLabel.Font = Enum.Font.GothamBold
    fovValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    fovValueLabel.ZIndex = 12
    fovValueLabel.Parent = contentRivals
    
    -- ============================================
    -- CONTEUDO EH
    -- ============================================
    
    local contentEH = Instance.new("Frame")
    contentEH.Size = UDim2.new(1, -85, 1, -35)
    contentEH.Position = UDim2.new(0, 80, 0, 35)
    contentEH.BackgroundTransparency = 1
    contentEH.Visible = false
    contentEH.ZIndex = 11
    contentEH.Parent = mainFrame
    
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
    ehAimbotBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ehAimbotBtn.BorderSizePixel = 1
    ehAimbotBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehAimbotBtn.Text = "OFF"
    ehAimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehAimbotBtn.TextSize = 14
    ehAimbotBtn.Font = Enum.Font.GothamBold
    ehAimbotBtn.ZIndex = 12
    ehAimbotBtn.Parent = contentEH
    
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
    ehAimLockBtn.Text = "TORSO"
    ehAimLockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehAimLockBtn.TextSize = 14
    ehAimLockBtn.Font = Enum.Font.GothamBold
    ehAimLockBtn.ZIndex = 12
    ehAimLockBtn.Parent = contentEH
    
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
    ehESPBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ehESPBtn.BorderSizePixel = 1
    ehESPBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehESPBtn.Text = "OFF"
    ehESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehESPBtn.TextSize = 14
    ehESPBtn.Font = Enum.Font.GothamBold
    ehESPBtn.ZIndex = 12
    ehESPBtn.Parent = contentEH
    
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
    ehESPHealthBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ehESPHealthBtn.BorderSizePixel = 1
    ehESPHealthBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehESPHealthBtn.Text = "OFF"
    ehESPHealthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehESPHealthBtn.TextSize = 14
    ehESPHealthBtn.Font = Enum.Font.GothamBold
    ehESPHealthBtn.ZIndex = 12
    ehESPHealthBtn.Parent = contentEH
    
    local ehLabel5 = Instance.new("TextLabel")
    ehLabel5.Size = UDim2.new(0, 150, 0, 35)
    ehLabel5.Position = UDim2.new(0, 15, 0, 215)
    ehLabel5.BackgroundTransparency = 1
    ehLabel5.Text = "Friends Mode"
    ehLabel5.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehLabel5.TextSize = 16
    ehLabel5.Font = Enum.Font.GothamBold
    ehLabel5.TextXAlignment = Enum.TextXAlignment.Left
    ehLabel5.ZIndex = 12
    ehLabel5.Parent = contentEH
    
    ehFriendsModeBtn = Instance.new("TextButton")
    ehFriendsModeBtn.Size = UDim2.new(0, 100, 0, 35)
    ehFriendsModeBtn.Position = UDim2.new(0, 200, 0, 215)
    ehFriendsModeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ehFriendsModeBtn.BorderSizePixel = 1
    ehFriendsModeBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehFriendsModeBtn.Text = "OFF"
    ehFriendsModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehFriendsModeBtn.TextSize = 14
    ehFriendsModeBtn.Font = Enum.Font.GothamBold
    ehFriendsModeBtn.ZIndex = 12
    ehFriendsModeBtn.Parent = contentEH
    
    -- ============================================
    -- ⭐ CONTEUDO SKY
    -- ============================================
    
    local contentSky = Instance.new("Frame")
    contentSky.Size = UDim2.new(1, -85, 1, -35)
    contentSky.Position = UDim2.new(0, 80, 0, 35)
    contentSky.BackgroundTransparency = 1
    contentSky.Visible = false
    contentSky.ZIndex = 11
    contentSky.Parent = mainFrame
    
    -- ⭐ TÍTULO DA ABA SKY
    local skyTitle = Instance.new("TextLabel")
    skyTitle.Size = UDim2.new(1, 0, 0, 30)
    skyTitle.Position = UDim2.new(0, 10, 0, 5)
    skyTitle.BackgroundTransparency = 1
    skyTitle.Text = "☀️ ESCOLHA SEU CÉU"
    skyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    skyTitle.TextSize = 16
    skyTitle.Font = Enum.Font.GothamBold
    skyTitle.ZIndex = 12
    skyTitle.Parent = contentSky
    
    -- ⭐ BOTÃO DEFAULT (CÉU PADRÃO)
    local defaultBtn = Instance.new("TextButton")
    defaultBtn.Size = UDim2.new(0.9, 0, 0, 35)
    defaultBtn.Position = UDim2.new(0.05, 0, 0, 45)
    defaultBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    defaultBtn.BorderSizePixel = 1
    defaultBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    defaultBtn.Text = "☀️ Céu Padrão"
    defaultBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    defaultBtn.TextSize = 14
    defaultBtn.Font = Enum.Font.GothamBold
    defaultBtn.ZIndex = 12
    defaultBtn.Parent = contentSky
    
    defaultBtn.MouseButton1Click:Connect(function()
        ChangeSky(nil, "Default")
    end)
    
    -- ⭐ CRIA OS BOTÕES DINAMICAMENTE
    local buttonY = 90
    local buttonHeight = 35
    local spacing = 45
    
    for i = 2, #SKY_DATA do  -- Começa do 2 pois o índice 1 é o "Default"
        local skyName = SKY_DATA[i][1]
        local skyId = SKY_DATA[i][2]
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, buttonHeight)
        btn.Position = UDim2.new(0.05, 0, 0, buttonY)
        btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(200, 0, 0)
        btn.Text = "☀️ " .. skyName
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.ZIndex = 12
        btn.Parent = contentSky
        
        btn.MouseButton1Click:Connect(function()
            ChangeSky(skyId, skyName)
        end)
        
        table.insert(skyButtons, btn)
        buttonY = buttonY + spacing
    end
    
    -- ============================================
    -- CONTEUDO CONFIG
    -- ============================================
    
    local contentConfig = Instance.new("Frame")
    contentConfig.Size = UDim2.new(1, -85, 1, -35)
    contentConfig.Position = UDim2.new(0, 80, 0, 35)
    contentConfig.BackgroundTransparency = 1
    contentConfig.Visible = false
    contentConfig.ZIndex = 11
    contentConfig.Parent = mainFrame
    
    local labelKey1 = Instance.new("TextLabel")
    labelKey1.Size = UDim2.new(0, 150, 0, 35)
    labelKey1.Position = UDim2.new(0, 15, 0, 20)
    labelKey1.BackgroundTransparency = 1
    labelKey1.Text = "Abrir Interface"
    labelKey1.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelKey1.TextSize = 16
    labelKey1.Font = Enum.Font.GothamBold
    labelKey1.TextXAlignment = Enum.TextXAlignment.Left
    labelKey1.ZIndex = 12
    labelKey1.Parent = contentConfig
    
    interfaceKeyBtn = Instance.new("TextButton")
    interfaceKeyBtn.Size = UDim2.new(0, 100, 0, 35)
    interfaceKeyBtn.Position = UDim2.new(0, 200, 0, 20)
    interfaceKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    interfaceKeyBtn.BorderSizePixel = 1
    interfaceKeyBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    interfaceKeyBtn.Text = Config.InterfaceKey
    interfaceKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    interfaceKeyBtn.TextSize = 14
    interfaceKeyBtn.Font = Enum.Font.GothamBold
    interfaceKeyBtn.ZIndex = 12
    interfaceKeyBtn.Parent = contentConfig
    
    local labelKey2 = Instance.new("TextLabel")
    labelKey2.Size = UDim2.new(0, 150, 0, 35)
    labelKey2.Position = UDim2.new(0, 15, 0, 70)
    labelKey2.BackgroundTransparency = 1
    labelKey2.Text = "Aimbot Rivals"
    labelKey2.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelKey2.TextSize = 16
    labelKey2.Font = Enum.Font.GothamBold
    labelKey2.TextXAlignment = Enum.TextXAlignment.Left
    labelKey2.ZIndex = 12
    labelKey2.Parent = contentConfig
    
    aimbotKeyBtn = Instance.new("TextButton")
    aimbotKeyBtn.Size = UDim2.new(0, 100, 0, 35)
    aimbotKeyBtn.Position = UDim2.new(0, 200, 0, 70)
    aimbotKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    aimbotKeyBtn.BorderSizePixel = 1
    aimbotKeyBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    aimbotKeyBtn.Text = Config.AimbotKey
    aimbotKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotKeyBtn.TextSize = 14
    aimbotKeyBtn.Font = Enum.Font.GothamBold
    aimbotKeyBtn.ZIndex = 12
    aimbotKeyBtn.Parent = contentConfig
    
    local labelKey3 = Instance.new("TextLabel")
    labelKey3.Size = UDim2.new(0, 150, 0, 35)
    labelKey3.Position = UDim2.new(0, 15, 0, 120)
    labelKey3.BackgroundTransparency = 1
    labelKey3.Text = "Aimbot EH"
    labelKey3.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelKey3.TextSize = 16
    labelKey3.Font = Enum.Font.GothamBold
    labelKey3.TextXAlignment = Enum.TextXAlignment.Left
    labelKey3.ZIndex = 12
    labelKey3.Parent = contentConfig
    
    ehKeyBtn = Instance.new("TextButton")
    ehKeyBtn.Size = UDim2.new(0, 100, 0, 35)
    ehKeyBtn.Position = UDim2.new(0, 200, 0, 120)
    ehKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ehKeyBtn.BorderSizePixel = 1
    ehKeyBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehKeyBtn.Text = Config.EH_Key
    ehKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehKeyBtn.TextSize = 14
    ehKeyBtn.Font = Enum.Font.GothamBold
    ehKeyBtn.ZIndex = 12
    ehKeyBtn.Parent = contentConfig
    
    -- ============================================
    -- FUNCOES DAS ABAS
    -- ============================================
    
    tabRivals.MouseButton1Click:Connect(function()
        currentTab = "Rivals"
        contentRivals.Visible = true
        contentEH.Visible = false
        contentSky.Visible = false
        contentConfig.Visible = false
        tabRivals.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        tabEH.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabSky.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabConfig.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    end)
    
    tabEH.MouseButton1Click:Connect(function()
        currentTab = "Emergency Hamburg"
        contentRivals.Visible = false
        contentEH.Visible = true
        contentSky.Visible = false
        contentConfig.Visible = false
        tabRivals.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabEH.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        tabSky.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabConfig.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    end)
    
    tabSky.MouseButton1Click:Connect(function()
        currentTab = "Sky"
        contentRivals.Visible = false
        contentEH.Visible = false
        contentSky.Visible = true
        contentConfig.Visible = false
        tabRivals.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabEH.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabSky.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        tabConfig.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    end)
    
    tabConfig.MouseButton1Click:Connect(function()
        currentTab = "Config"
        contentRivals.Visible = false
        contentEH.Visible = false
        contentSky.Visible = false
        contentConfig.Visible = true
        tabRivals.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabEH.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabSky.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabConfig.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end)
    
    -- ============================================
    -- FUNCOES DOS BOTOES
    -- ============================================
    
    aimbotBtn.MouseButton1Click:Connect(function()
        Config.Enabled = not Config.Enabled
        UpdateUI()
    end)
    
    aimLockBtn.MouseButton1Click:Connect(function()
        if Config.AimPart == "Torso" then
            Config.AimPart = "Head"
        else
            Config.AimPart = "Torso"
        end
        UpdateUI()
    end)
    
    ehAimbotBtn.MouseButton1Click:Connect(function()
        Config.EH_Enabled = not Config.EH_Enabled
        UpdateUI()
    end)
    
    ehAimLockBtn.MouseButton1Click:Connect(function()
        if Config.EH_AimPart == "Torso" then
            Config.EH_AimPart = "Head"
        else
            Config.EH_AimPart = "Torso"
        end
        UpdateUI()
    end)
    
    ehESPBtn.MouseButton1Click:Connect(function()
        Config.EH_ESP = not Config.EH_ESP
        UpdateUI()
        if not Config.EH_ESP then
            if Config.EH_ESPHealth then
                EnableESP()
            else
                DisableESP()
            end
        else
            EnableESP()
        end
    end)
    
    ehESPHealthBtn.MouseButton1Click:Connect(function()
        Config.EH_ESPHealth = not Config.EH_ESPHealth
        UpdateUI()
        if not Config.EH_ESPHealth then
            if Config.EH_ESP then
                EnableESP()
            else
                DisableESP()
            end
        else
            EnableESP()
        end
    end)
    
    ehFriendsModeBtn.MouseButton1Click:Connect(function()
        Config.EH_FriendsMode = not Config.EH_FriendsMode
        UpdateUI()
    end)
    
    -- ============================================
    -- FUNCAO: ESCOLHER TECLA
    -- ============================================
    
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
                    
                    if keyType == "Interface" then
                        Config.InterfaceKey = keyName
                        interfaceKeyBtn.Text = keyName
                    elseif keyType == "Aimbot Rivals" then
                        Config.AimbotKey = keyName
                        aimbotKeyBtn.Text = keyName
                    elseif keyType == "Aimbot EH" then
                        Config.EH_Key = keyName
                        ehKeyBtn.Text = keyName
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
    
    SetupKeyButton(interfaceKeyBtn, "Interface")
    SetupKeyButton(aimbotKeyBtn, "Aimbot Rivals")
    SetupKeyButton(ehKeyBtn, "Aimbot EH")
    
    -- ============================================
    -- SLIDER RIVALS - SMOOTH
    -- ============================================
    
    smoothSliderBtn.MouseButton1Down:Connect(function()
        isDraggingSmooth = true
        local connection
        connection = UserInputService.InputChanged:Connect(function(input)
            if isDraggingSmooth and input.UserInputType == Enum.UserInputType.MouseMovement then
                local sliderWidth = smoothSliderFrame.AbsoluteSize.X
                if sliderWidth == 0 then return
                local relativeX = math.clamp(input.Position.X - smoothSliderFrame.AbsolutePosition.X, 0, sliderWidth)
                local percent = relativeX / sliderWidth
                local value = 0.1 + (percent * 2.9)
                Config.Smoothness = math.round(value * 10) / 10
                smoothProgress.Size = UDim2.new(percent, 0, 1, 0)
                smoothSliderBtn.Position = UDim2.new(percent, -8, 0.5, -8)
                smoothValueLabel.Text = string.format("%.1f", Config.Smoothness)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDraggingSmooth = false
                connection:Disconnect()
            end
        end)
    end)
    
    -- ============================================
    -- SLIDER RIVALS - FOV
    -- ============================================
    
    fovSliderBtn.MouseButton1Down:Connect(function()
        isDraggingFOV = true
        local connection
        connection = UserInputService.InputChanged:Connect(function(input)
            if isDraggingFOV and input.UserInputType == Enum.UserInputType.MouseMovement then
                local sliderWidth = fovSliderFrame.AbsoluteSize.X
                if sliderWidth == 0 then return
                local relativeX = math.clamp(input.Position.X - fovSliderFrame.AbsolutePosition.X, 0, sliderWidth)
                local percent = relativeX / sliderWidth
                local value = 50 + (percent * 450)
                Config.FOV = math.round(value / 10) * 10
                fovProgress.Size = UDim2.new(percent, 0, 1, 0)
                fovSliderBtn.Position = UDim2.new(percent, -8, 0.5, -8)
                fovValueLabel.Text = tostring(Config.FOV)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDraggingFOV = false
                connection:Disconnect()
            end
        end)
    end)
    
    -- ============================================
    -- FUNCAO: MOVER INTERFACE
    -- ============================================
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            dragStartPos = mainFrame.Position
            
            if dragConnection then dragConnection:Disconnect() end
            if dragEndConnection then dragEndConnection:Disconnect() end
            
            dragConnection = UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = input.Position - dragStart
                    local newX = dragStartPos.X.Offset + delta.X
                    local newY = dragStartPos.Y.Offset + delta.Y
                    
                    local screenSize = Camera.ViewportSize
                    local frameSize = mainFrame.AbsoluteSize
                    newX = math.clamp(newX, 0, screenSize.X - frameSize.X)
                    newY = math.clamp(newY, 0, screenSize.Y - frameSize.Y)
                    
                    mainFrame.Position = UDim2.new(0, newX, 0, newY)
                end
            end)
            
            dragEndConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                    if dragConnection then
                        dragConnection:Disconnect()
                        dragConnection = nil
                    end
                    if dragEndConnection then
                        dragEndConnection:Disconnect()
                        dragEndConnection = nil
                    end
                end
            end)
        end
    end)
    
    -- ============================================
    -- BOTAO FECHAR
    -- ============================================
    
    closeBtn.MouseButton1Click:Connect(function()
        PanelOpen = false
        mainFrame.Visible = false
        UpdateMouseBehavior()
        if Config.EH_ESP or Config.EH_ESPHealth then
            DisableESP()
        end
    end)
    
    UpdateUI()
    return screenGui, mainFrame
end

-- ============================================
-- CRIAR INTERFACE
-- ============================================

local PanelGui, PanelFrame = CreateGUI()
PanelFrame.Visible = true
PanelOpen = true

-- ============================================
-- INPUT: INTERFACE KEY
-- ============================================

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode.Name == Config.InterfaceKey then
        PanelOpen = not PanelOpen
        PanelFrame.Visible = PanelOpen
        UpdateMouseBehavior()
        if not PanelOpen and (Config.EH_ESP or Config.EH_ESPHealth) then
            DisableESP()
        end
    end
end)

-- ============================================
-- INPUT: AIMBOT KEY (RIVALS)
-- ============================================

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode.Name == Config.AimbotKey then
        Config.Enabled = not Config.Enabled
        UpdateUI()
    end
end)

-- ============================================
-- INPUT: AIMBOT KEY (EH)
-- ============================================

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode.Name == Config.EH_Key then
        Config.EH_Enabled = not Config.EH_Enabled
        UpdateUI()
    end
end)

-- ============================================
-- M2: ATIVA A MIRA (RIVALS)
-- ============================================

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Config.Enabled and not PanelOpen then
            isAiming = true
            UpdateMouseBehavior()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
        UpdateMouseBehavior()
    end
end)

-- ============================================
-- ATUALIZA COMPORTAMENTO DO CURSOR INICIAL
-- ============================================

UpdateMouseBehavior()
