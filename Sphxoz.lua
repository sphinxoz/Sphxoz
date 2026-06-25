-- ============================================
-- SPHXZ AUTH SYSTEM v4.2 + OG SNIPER INTEGRADO
-- Interface modificada - Sem emoji
-- ============================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local Workspace = game:GetService("Workspace")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

-- CONFIG FILE PATH
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
    InterfaceKey = "Insert",
}

-- ============================================
-- FLAGS PARA PLASTIC MAP (FPS BOOSTER)
-- ============================================
local PLASTIC_FLAGS = {
    DFFlagDisableDPIScale = "True",
    DFFlagFastGPULightCulling = "True",
    DFIntAnimationDelayOverride = "0",
    DFIntAnimationLerpFix = "0",
    DFIntCSGLevelOfDetailSwitchingDistance = "0",
    DFIntCSGLevelOfDetailSwitchingDistanceL12 = "0",
    DFIntCSGLevelOfDetailSwitchingDistanceL23 = "0",
    DFIntCSGLevelOfDetailSwitchingDistanceL34 = "0",
    DFIntDebugFRMQualityLevelOverride = "1",
    DFIntDebugSimulatedLatencyMs = "0",
    DFIntLightingExposureCompensation = "25",
    DFIntLightingGlobalBrightness = "200",
    DFIntLightingMaxExposure = "25",
    DFIntLightingMinExposure = "25",
    DFIntPhysicsMtuOverride = "1",
    DFIntRenderForceLowFps = "0",
    DFIntRenderMaxFrameTime = "0",
    DFIntRunServiceTargetFps = "999",
    DFIntRunServiceThrottleAdjust = "0",
    DFIntSmoothClusterPhysicsMaxIterations = "1",
    DFIntTaskSchedulerTargetFps = "120",
    DFIntTaskSchedulerThreadMaxBudget = "0",
    DFIntTaskSchedulerThreadMinBudget = "0",
    DFIntTextureCompositorActiveJobs = "0",
    DFIntTextureQualityOverride = "1",
    FFlagDebugBypassAnimationQueue = "True",
    FFlagDebugDisableAnimationLerp = "True",
    FFlagDebugDisableAtmosphere = "True",
    FFlagDebugDisableCloudEntity = "True",
    FFlagDebugDisableFog = "True",
    FFlagDebugDisableInterpolation = "True",
    FFlagDebugDisableParticleEmitter = "True",
    FFlagDebugDisablePhysicsInterpolation = "True",
    FFlagDebugDisableShadowCascades = "True",
    FFlagDebugForceFullBright = "True",
    FFlagDebugForceInstantInput = "True",
    FFlagDebugGraphicsDisableShadows = "True",
    FFlagDebugGraphicsPreferD3D11 = "True",
    FFlagDebugSimulateTouchLatency = "False",
    FFlagDisableControllerInputFiltering = "True",
    FFlagDisableMouseInputFiltering = "True",
    FFlagDisableShadows = "True",
    FFlagEnableAtmosphere = "False",
    FFlagEnableTextureStreaming = "True",
    FFlagGrassDisappear = "True",
    FFlagHandleAltEnterFullscreenManually = "False",
    FFlagMessageBusCallOptimization = "True",
    FFlagRenderAllowLowFpsRenderStep = "False",
    FFlagRenderDynamicResolutionScale9 = "True",
    FFlagRenderFixLightStep = "True",
    FFlagRenderLocalPlayerShadow = "False",
    FFlagTaskSchedulerForceRegionTick = "True",
    FFlagVisualEngineAtmosphere = "False",
    FIntCLI20390_2 = "1",
    FIntDebugForceMSAASamples = "-1",
    FIntDebugTextureManagerSkipMips = "-1",
    FIntFRMMaxGrassDistance = "0",
    FIntFRMMinGrassDistance = "0",
    FIntRenderGrassDetailStrands = "0",
    FIntRenderGrassHeightScaler = "0",
    FIntRenderShadowIntensity = "0",
    FIntRenderShadowmapBias = "1",
    FIntRenderTextureQuality = "0",
    FIntTerrainArraySliceSize = "0",
    FLogNetwork = "7",
}

-- ============================================
-- VARIAVEIS PLASTIC MAP
-- ============================================
local originalMaterials = {}
local originalTextures = {}
local originalTerrainMaterial = nil
local originalTerrainColor = nil
local originalLightingSettings = {}
local originalTerrainDecoration = nil
local plasticMapEnabled = false

-- ============================================
-- VARIAVEIS OG SNIPER
-- ============================================
local ogSniperEnabled = false
local scopeRemovalConnection = nil
local sniperDelayConnection = nil
local originalScopes = {}
local customCrosshair = nil

-- ============================================
-- TEMA
-- ============================================
local THEME = {
    bg = Color3.fromRGB(5, 5, 5),
    surface = Color3.fromRGB(15, 15, 15),
    surfaceLight = Color3.fromRGB(30, 30, 30),
    primary = Color3.fromRGB(180, 30, 30),
    accent = Color3.fromRGB(255, 80, 80),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(150, 150, 150),
    success = Color3.fromRGB(50, 255, 100),
    error = Color3.fromRGB(255, 50, 50)
}

-- ============================================
-- FUNCOES UTILITARIAS
-- ============================================
local function ReadFile(f)
    if typeof(readfile) == "function" and typeof(isfile) == "function" then
        if isfile(f) then
            local s, d = pcall(readfile, f)
            if s then return d end
        end
    end
    return nil
end

local function WriteFile(f, d)
    if typeof(writefile) == "function" then
        pcall(writefile, f, d)
    end
end

local function LoadDB()
    local d = ReadFile("SPHXZ_KeysDatabase.json")
    if d then
        local s, t = pcall(HttpService.JSONDecode, HttpService, d)
        if s then return t end
    end
    return { keys = {} }
end

local function SaveDB(db)
    WriteFile("SPHXZ_KeysDatabase.json", HttpService:JSONEncode(db))
end

local function GetHWID()
    return tostring(LocalPlayer.UserId) .. "-" .. tostring(game.PlaceId)
end

-- ============================================
-- VALIDACAO DE KEY
-- ============================================
local function ValidateKey(key)
    key = key:upper():gsub("%s+", "")
    local db = LoadDB()
    local dk = db.keys and db.keys[key]
    
    if dk then
        if not dk.active then return false, "Key desativada" end
        if os.time() > dk.expires then return false, "Key expirada" end
        
        if dk.maxUses and dk.useCount and dk.useCount >= dk.maxUses then
            if dk.usedBy ~= LocalPlayer.Name then
                return false, "Limite de usos atingido"
            end
        end
        
        if dk.usedBy ~= LocalPlayer.Name then
            dk.useCount = (dk.useCount or 0) + 1
        end
        dk.usedBy = LocalPlayer.Name
        dk.hwid = GetHWID()
        dk.lastUsed = os.time()
        SaveDB(db)
        return true, "OK"
    end
    
    return false, "Key invalida"
end

local function SaveCache(key)
    WriteFile("SPHXZ_AuthCache.json", HttpService:JSONEncode({
        key = key, savedAt = os.time(), username = LocalPlayer.Name
    }))
end

local function LoadCache()
    local d = ReadFile("SPHXZ_AuthCache.json")
    if d then
        local s, t = pcall(HttpService.JSONDecode, HttpService, d)
        if s then return t.key end
    end
    return nil
end

local function ClearCache()
    if typeof(delfile) == "function" and typeof(isfile) == "function" then
        if isfile("SPHXZ_AuthCache.json") then pcall(delfile, "SPHXZ_AuthCache.json") end
    end
end

-- ============================================
-- LOAD OR CREATE CONFIG
-- ============================================
local function LoadConfig()
    if getgenv().AimbotConfig then
        return getgenv().AimbotConfig
    end
    
    if typeof(readfile) == "function" and typeof(isfile) == "function" then
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
    },

    {id = 5, name = "Galaxy Sky", 
        skyboxBk = "rbxassetid://15983968922",
        skyboxDn = "rbxassetid://15983966825",
        skyboxFt = "rbxassetid://15983965025",
        skyboxLf = "rbxassetid://15983967420",
        skyboxRt = "rbxassetid://15983966246",
        skyboxUp = "rbxassetid://15983964246"
    },

    {id = 6, name = "Green Sky", 
        skyboxBk = "rbxassetid://921882045",
        skyboxDn = "rbxassetid://921881907",
        skyboxFt = "rbxassetid://921882121",
        skyboxLf = "rbxassetid://921881811",
        skyboxRt = "rbxassetid://921881989",
        skyboxUp = "rbxassetid://921882259"
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
local mainFrame, miniButton, screenGui
local currentTab = "Emergency Hamburg"

-- Variáveis EH
local ehAimbotBtn, ehAimLockBtn, ehESPBtn, ehESPHealthBtn, ehFriendsModeBtn, ehSpinBotBtn, ehSpinSpeedSlider, ehSpinSpeedLabel, ehOGSniperBtn
local espObjects, espHealthObjects, espConnections = {}, {}, {}
local ehKeyBtn, interfaceKeyBtn, lockedTarget, lockedPart = nil, nil, nil, nil

-- Variáveis SpinBot
local spinRunning = false
local spinAngle = 0

-- Variáveis Friends Mode
local blockedPlayersFrame = nil
local contentEHScroll = nil

-- Variáveis MISC
local plasticMapBtn = nil

-- Variáveis Sky - INICIALIZAR A TABELA AQUI
local skyButtons = {}

-- ============================================
-- FUNÇÃO: VERIFICAR SE É POLICIAL
-- ============================================
local function IsPolice(player)
    if not player then return false end
    
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("police") or teamName:find("policia") or teamName:find("cop") or teamName:find("sheriff") or teamName:find("law") then
            return true
        end
    end
    
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
-- FUNÇÃO: VERIFICAR SE JOGADOR TEM ARMA
-- ============================================
local function PlayerHasWeapon(player)
    if not player then return false end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
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
-- FUNÇÃO: OBTER COR DO TIME
-- ============================================
local function GetTeamColor(player)
    if not player then return Color3.fromRGB(200, 200, 200) end
    
    if IsPolice(player) then
        return Color3.fromRGB(0, 100, 255)
    end
    
    if PlayerHasWeapon(player) then
        return Color3.fromRGB(255, 105, 180)
    end
    
    if player.Team then
        return player.TeamColor.Color
    end
    
    return Color3.fromRGB(200, 200, 200)
end

-- ============================================
-- FUNÇÕES FRIENDS MODE
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
            return false
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
    
    for _, child in ipairs(blockedPlayersFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
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
                local playerFrame = Instance.new("Frame")
                playerFrame.Size = UDim2.new(1, -10, 0, 50)
                playerFrame.Position = UDim2.new(0, 5, 0, yPos)
                playerFrame.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
                playerFrame.BorderSizePixel = 0
                playerFrame.ZIndex = 14
                playerFrame.Parent = blockedPlayersFrame
                
                local avatarImage = Instance.new("ImageLabel")
                avatarImage.Size = UDim2.new(0, 40, 0, 40)
                avatarImage.Position = UDim2.new(0, 5, 0, 5)
                avatarImage.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
                avatarImage.BorderSizePixel = 0
                avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=0&width=420&height=420&format=png"
                avatarImage.ZIndex = 15
                avatarImage.Parent = playerFrame
                
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
    
    local contentHeight = math.max(yPos + 10, 100)
    blockedPlayersFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
end

-- ============================================
-- SISTEMA OG SNIPER (DO PRIMEIRO SCRIPT)
-- ============================================

-- Função: No Scope
local function EnableNoScope()
    if scopeRemovalConnection then return end
    
    scopeRemovalConnection = RunService.Heartbeat:Connect(function()
        if not ogSniperEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local sniper = character:FindFirstChild("Sniper")
        if sniper then
            sniper:SetAttribute("Scope", false)
        end
    end)
end

local function DisableNoScope()
    if scopeRemovalConnection then
        scopeRemovalConnection:Disconnect()
        scopeRemovalConnection = nil
    end
end

-- Função: Fast Sniper
local function EnableFastSniper()
    if sniperDelayConnection then return end
    
    sniperDelayConnection = RunService.Heartbeat:Connect(function()
        if not ogSniperEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local sniper = character:FindFirstChild("Sniper")
        if sniper then
            sniper:SetAttribute("ShootDelay", 0.5)
            sniper:SetAttribute("AimDelay", 0)
        end
    end)
end

local function DisableFastSniper()
    if sniperDelayConnection then
        sniperDelayConnection:Disconnect()
        sniperDelayConnection = nil
    end
end

-- Função: Remover Mira Preta
local function removerMiraPreta()
    local guis = LocalPlayer.PlayerGui:GetChildren()
    for _, gui in pairs(guis) do
        if gui:IsA("ScreenGui") then
            for _, filho in pairs(gui:GetChildren()) do
                if filho:IsA("Frame") then
                    if filho.BackgroundColor3 == Color3.fromRGB(0, 0, 0) then
                        if filho.Size.X.Scale >= 0.3 or filho.Size.Y.Scale >= 0.3 then
                            pcall(function()
                                filho.Visible = false
                                filho.Enabled = false
                            end)
                        end
                    end
                    local nome = filho.Name:lower()
                    if nome:find("sniper") or nome:find("scope") or nome:find("crosshair") or nome:find("aim") or nome:find("black") or nome:find("overlay") then
                        pcall(function()
                            filho.Visible = false
                            filho.Enabled = false
                        end)
                    end
                end
                if filho:IsA("ImageLabel") then
                    local nome = filho.Name:lower()
                    if nome:find("sniper") or nome:find("scope") or nome:find("crosshair") or nome:find("aim") then
                        pcall(function()
                            filho.Visible = false
                            filho.Enabled = false
                        end)
                    end
                end
            end
        end
    end
end

-- Função: Ativar/Desativar OG Sniper
local function ToggleOGSniper()
    ogSniperEnabled = not ogSniperEnabled
    Config.EH_OGSniper = ogSniperEnabled
    
    if ogSniperEnabled then
        removerMiraPreta()
        EnableNoScope()
        EnableFastSniper()
        print("OG SNIPER ATIVADA!")
    else
        DisableNoScope()
        DisableFastSniper()
        print("OG SNIPER DESATIVADA!")
    end
    
    UpdateUI()
end

-- Manter mira preta removida
RunService.RenderStepped:Connect(function()
    if ogSniperEnabled then
        removerMiraPreta()
    end
end)

-- ============================================
-- SISTEMA PLASTIC MAP (FPS BOOSTER) - CORRIGIDO
-- ============================================
local function SaveOriginalLighting()
    originalLightingSettings = {
        Ambient = Lighting.Ambient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        ColorShift_Bottom = Lighting.ColorShift_Bottom,
        ColorShift_Top = Lighting.ColorShift_Top,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ShadowSoftness = Lighting.ShadowSoftness,
        Technology = Lighting.Technology,
    }
end

local function ApplyPlasticMap()
    if plasticMapEnabled then return end
    
    SaveOriginalLighting()
    
    originalMaterials = {}
    originalTextures = {}
    
    -- Salvar e remover material do Terrain (grama)
    if Terrain then
        originalTerrainMaterial = Terrain.Material
        originalTerrainColor = Terrain.Color
        
        -- Mudar para material liso e cor cinza
        Terrain.Material = Enum.Material.SmoothPlastic
        Terrain.Color = Color3.fromRGB(100, 100, 100)
        
        -- Desativar decoração do terrain (grass, etc)
        pcall(function()
            originalTerrainDecoration = Terrain.Decoration
            Terrain.Decoration = false
        end)
        
        -- Remover grama completamente
        pcall(function()
            Terrain:SetMaterialProperties(Enum.Material.Grass, {
                Density = 0,
                Size = 0,
                Height = 0
            })
        end)
    end
    
    -- Processar todo o workspace incluindo terreno
    local function ProcessInstance(instance)
        if instance:IsA("BasePart") then
            originalMaterials[instance] = instance.Material
            instance.Material = Enum.Material.Plastic
            
            for _, child in ipairs(instance:GetChildren()) do
                if child:IsA("Texture") or child:IsA("Decal") then
                    table.insert(originalTextures, {parent = instance, child = child, name = child.Name})
                    child:Destroy()
                end
            end
        elseif instance:IsA("MeshPart") then
            originalMaterials[instance] = instance.Material
            instance.Material = Enum.Material.Plastic
            
            for _, child in ipairs(instance:GetChildren()) do
                if child:IsA("Texture") or child:IsA("Decal") then
                    table.insert(originalTextures, {parent = instance, child = child, name = child.Name})
                    child:Destroy()
                end
            end
        elseif instance:IsA("SurfaceAppearance") then
            table.insert(originalTextures, {parent = instance.Parent, child = instance})
            instance:Destroy()
        elseif instance:IsA("UnionOperation") then
            originalMaterials[instance] = instance.Material
            instance.Material = Enum.Material.Plastic
        end
    end
    
    -- Processar todos os descendentes do Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            ProcessInstance(obj)
        end)
    end
    
    -- Configurar Lighting para máximo FPS
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness = 2
    Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
    Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.ShadowSoftness = 0
    Lighting.Technology = Enum.Technology.Compatibility
    
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("Atmosphere") or effect:IsA("Bloom") or effect:IsA("Blur") or 
           effect:IsA("ColorCorrection") or effect:IsA("SunRays") or effect:IsA("DepthOfField") then
            effect.Enabled = false
        end
    end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        end
    end
    
    -- Aplicar flags
    pcall(function()
        for flag, value in pairs(PLASTIC_FLAGS) do
            local numValue = tonumber(value)
            if numValue then
                settings()[flag] = numValue
            else
                settings()[flag] = (value == "True")
            end
        end
    end)
    
    plasticMapEnabled = true
    
    -- Atualizar UI
    if plasticMapBtn then
        plasticMapBtn.Text = "ATIVO"
        plasticMapBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end

-- ============================================
-- FUNÇÃO: ATUALIZAR INTERFACE
-- ============================================
function UpdateUI()
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
    if interfaceKeyBtn then
        interfaceKeyBtn.Text = Config.InterfaceKey or "Insert"
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
        ehOGSniperBtn.Text = ogSniperEnabled and "ON" or "OFF"
        ehOGSniperBtn.BackgroundColor3 = ogSniperEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
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
-- FUNÇÃO: IsValidTarget
-- ============================================
local function IsValidTarget(player)
    if not player then return false end
    if player == LocalPlayer then return false end
    
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
    
    if ogSniperEnabled and tool then
        local toolName = tool.Name:lower()
        if toolName:find("sniper") or toolName:find("barret") or toolName:find("intervention") then
            removerMiraPreta()
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
-- ESP FUNCTIONS
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
    
    if isPolice then
        nameLabel.Text = "[POLICE] " .. nameLabel.Text
    elseif hasWeapon then
        nameLabel.Text = "[ARMED] " .. nameLabel.Text
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
                nameLabel.Text = "[POLICE] " .. baseName
            elseif newHasWeapon then
                nameLabel.Text = "[ARMED] " .. baseName
            else
                nameLabel.Text = baseName
            end
        end
    end)
    table.insert(espConnections, teamConnection)
    
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
                nameLabel.Text = "[POLICE] " .. baseName
            elseif currentHasWeapon then
                nameLabel.Text = "[ARMED] " .. baseName
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
-- SISTEMA DE SAVE/LOAD (CORRIGIDO PARA INCLUIR CEU)
-- ============================================
local function SaveConfigToFile()
    if typeof(writefile) ~= "function" then
        return false
    end
    
    -- NÃO salvar o estado do Plastic Map (conforme solicitado)
    local configToSave = {}
    for key, value in pairs(Config) do
        configToSave[key] = value
    end
    
    local success, err = pcall(function()
        local configData = HttpService:JSONEncode(configToSave)
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
            -- Não carregar PlasticMap_Enabled (conforme solicitado)
            if key ~= "PlasticMap_Enabled" then
                Config[key] = value
            end
        end
        if not Config.BlockedPlayers then
            Config.BlockedPlayers = {}
        end
        
        -- Aplicar o céu salvo
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

function ApplySky(skyId)
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
-- INTERFACE AUTH
-- ============================================
local AuthSuccess = false

local function CreateAuthUI(callback)
    local sg = Instance.new("ScreenGui")
    sg.Name = "SPHXZ_Auth"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 99999
    
    local mf = Instance.new("Frame")
    mf.Size = UDim2.new(0, 400, 0, 280)
    mf.Position = UDim2.new(0.5, -200, 0.5, -140)
    mf.BackgroundColor3 = THEME.bg
    mf.BorderSizePixel = 0
    mf.ZIndex = 1000
    mf.Parent = sg
    
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 12)
    mc.Parent = mf
    
    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 50, 1, 50)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = 999
    shadow.Parent = mf
    
    for i = 1, 20 do
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        d.Position = UDim2.new(math.random(), 0, math.random(), 0)
        d.BackgroundColor3 = THEME.primary
        d.BackgroundTransparency = 0.7
        d.BorderSizePixel = 0
        d.ZIndex = 1
        d.Parent = mf
    end
    
    local hd = Instance.new("Frame")
    hd.Size = UDim2.new(1, 0, 0, 60)
    hd.BackgroundColor3 = THEME.surface
    hd.BorderSizePixel = 0
    hd.ZIndex = 1001
    hd.Parent = mf
    
    local hdc = Instance.new("UICorner")
    hdc.CornerRadius = UDim.new(0, 12)
    hdc.Parent = hd
    
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = "AUTENTICACAO"
    tl.TextColor3 = THEME.accent
    tl.TextSize = 22
    tl.Font = Enum.Font.GothamBold
    tl.ZIndex = 1002
    tl.Parent = hd
    
    local authLabel = Instance.new("TextLabel")
    authLabel.Size = UDim2.new(0, 100, 0, 25)
    authLabel.Position = UDim2.new(0.5, -50, 0, 75)
    authLabel.BackgroundTransparency = 1
    authLabel.Text = "AUTH"
    authLabel.TextColor3 = THEME.text
    authLabel.TextSize = 14
    authLabel.Font = Enum.Font.GothamBold
    authLabel.ZIndex = 1001
    authLabel.Parent = mf
    
    local inp = Instance.new("Frame")
    inp.Size = UDim2.new(0, 340, 0, 50)
    inp.Position = UDim2.new(0.5, -170, 0, 105)
    inp.BackgroundColor3 = THEME.surface
    inp.BorderSizePixel = 0
    inp.ZIndex = 1001
    inp.Parent = mf
    
    local inpc = Instance.new("UICorner")
    inpc.CornerRadius = UDim.new(0, 8)
    inpc.Parent = inp
    
    local inps = Instance.new("UIStroke")
    inps.Color = THEME.primary
    inps.Thickness = 1
    inps.Parent = inp
    
    local txt = Instance.new("TextBox")
    txt.Size = UDim2.new(1, -20, 1, 0)
    txt.Position = UDim2.new(0, 10, 0, 0)
    txt.BackgroundTransparency = 1
    txt.PlaceholderText = "SPHXZ-XXXX-XXXX-XXXX"
    txt.Text = ""
    txt.TextColor3 = THEME.text
    txt.PlaceholderColor3 = THEME.textDim
    txt.TextSize = 18
    txt.Font = Enum.Font.GothamBold
    txt.ClearTextOnFocus = false
    txt.ZIndex = 1002
    txt.Parent = inp
    
    txt:GetPropertyChangedSignal("Text"):Connect(function()
        if #txt.Text > 20 then
            txt.Text = txt.Text:sub(1, 20)
        end
    end)
    
    local rem = Instance.new("Frame")
    rem.Size = UDim2.new(0, 140, 0, 30)
    rem.Position = UDim2.new(0.5, -70, 0, 165)
    rem.BackgroundTransparency = 1
    rem.ZIndex = 1001
    rem.Parent = mf
    
    local rbox = Instance.new("Frame")
    rbox.Size = UDim2.new(0, 22, 0, 22)
    rbox.Position = UDim2.new(0, 0, 0.5, -11)
    rbox.BackgroundColor3 = THEME.surface
    rbox.BorderSizePixel = 1
    rbox.BorderColor3 = THEME.primary
    rbox.ZIndex = 1002
    rbox.Parent = rem
    
    local rbc = Instance.new("UICorner")
    rbc.CornerRadius = UDim.new(0, 4)
    rbc.Parent = rbox
    
    local chk = Instance.new("TextLabel")
    chk.Size = UDim2.new(1, 0, 1, 0)
    chk.BackgroundTransparency = 1
    chk.Text = "X"
    chk.TextColor3 = THEME.accent
    chk.TextSize = 14
    chk.Font = Enum.Font.GothamBold
    chk.Visible = false
    chk.ZIndex = 1003
    chk.Parent = rbox
    
    local rtl = Instance.new("TextLabel")
    rtl.Size = UDim2.new(0, 100, 1, 0)
    rtl.Position = UDim2.new(0, 30, 0, 0)
    rtl.BackgroundTransparency = 1
    rtl.Text = "Lembrar-me"
    rtl.TextColor3 = THEME.textDim
    rtl.TextSize = 13
    rtl.Font = Enum.Font.Gotham
    rtl.TextXAlignment = Enum.TextXAlignment.Left
    rtl.ZIndex = 1002
    rtl.Parent = rem
    
    local remOn = false
    rem.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            remOn = not remOn
            chk.Visible = remOn
        end
    end)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 340, 0, 45)
    btn.Position = UDim2.new(0.5, -170, 0, 210)
    btn.BackgroundColor3 = THEME.primary
    btn.BorderSizePixel = 0
    btn.Text = "ENTRAR"
    btn.TextColor3 = THEME.text
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 1001
    btn.Parent = mf
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = btn
    
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(1, -20, 0, 25)
    st.Position = UDim2.new(0, 10, 0, 260)
    st.BackgroundTransparency = 1
    st.Text = ""
    st.TextColor3 = THEME.error
    st.TextSize = 12
    st.Font = Enum.Font.GothamBold
    st.ZIndex = 1001
    st.Parent = mf
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.primary}):Play()
    end)
    
    local function DoLogin()
        local key = txt.Text
        if #key < 10 then
            st.Text = "Insira uma key valida!"
            return
        end
        
        st.TextColor3 = THEME.textDim
        st.Text = "Verificando..."
        
        local ok, msg = ValidateKey(key)
        if ok then
            st.TextColor3 = THEME.success
            st.Text = "Sucesso! Carregando..."
            if remOn then SaveCache(key) else ClearCache() end
            
            task.delay(1.5, function()
                AuthSuccess = true
                sg:Destroy()
                if callback then callback() end
            end)
        else
            st.TextColor3 = THEME.error
            st.Text = msg
            if msg:find("expirada") or msg:find("desativada") then ClearCache() end
        end
    end
    
    btn.MouseButton1Click:Connect(DoLogin)
    txt.FocusLost:Connect(function(ep) if ep then DoLogin() end end)
    
    local ck = LoadCache()
    if ck then
        local ok, msg = ValidateKey(ck)
        if ok then
            txt.Text = ck
            remOn = true
            chk.Visible = true
            st.TextColor3 = THEME.success
            st.Text = "Key salva encontrada!"
        else
            ClearCache()
        end
    end
    
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    mf.Size = UDim2.new(0, 400, 0, 0)
    TweenService:Create(mf, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 400, 0, 280)}):Play()
end

-- ============================================
-- CRIAR INTERFACE PRINCIPAL
-- ============================================
local function CreateMainGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    
    -- BOTÃO MINI (QUADRADO FLUTUANTE) - PARA CELULAR
    miniButton = Instance.new("TextButton")
    miniButton.Name = "MiniButton"
    miniButton.Size = UDim2.new(0, 60, 0, 60)
    miniButton.Position = UDim2.new(0, 10, 0.5, -30)
    miniButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    miniButton.BorderSizePixel = 2
    miniButton.BorderColor3 = Color3.fromRGB(255, 50, 50)
    miniButton.Text = "SPH"
    miniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    miniButton.TextSize = 14
    miniButton.Font = Enum.Font.GothamBold
    miniButton.ZIndex = 1000
    miniButton.Visible = false -- Começa invisível
    miniButton.Parent = screenGui
    
    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 8)
    miniCorner.Parent = miniButton
    
    -- IMAGEM DO BOTÃO MINI (opcional)
    local miniImage = Instance.new("ImageLabel")
    miniImage.Name = "MiniImage"
    miniImage.Size = UDim2.new(1, -10, 1, -10)
    miniImage.Position = UDim2.new(0, 5, 0, 5)
    miniImage.BackgroundTransparency = 1
    miniImage.Image = "" -- Deixe vazio ou coloque um ID de imagem
    miniImage.ZIndex = 1001
    miniImage.Parent = miniButton
    
    -- PAINEL PRINCIPAL
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainPanel"
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
    closeBtn.Name = "CloseBtn"
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
    
    -- IMAGENS DAS ABAS
    local IMAGE_EH = "rbxassetid://15286668292"
    local IMAGE_CONFIG = "rbxassetid://6966627582"
    local IMAGE_SKY = "rbxassetid://108577521816678"
    local IMAGE_MISC = "rbxassetid://108577521816678"
    
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
    
    -- ABAS - ORDEM ALTERADA: Misc acima de Config
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
    
    -- MISC agora vem antes de CONFIG
    local tabMisc = Instance.new("TextButton")
    tabMisc.Size = UDim2.new(1, 0, 0, 65)
    tabMisc.Position = UDim2.new(0, 0, 0, 145)
    tabMisc.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    tabMisc.BorderSizePixel = 0
    tabMisc.Text = ""
    tabMisc.ZIndex = 12
    tabMisc.Parent = tabFrame
    CreateImageLabel(tabMisc, IMAGE_MISC, UDim2.new(0.5, -18, 0, 8), UDim2.new(0, 36, 0, 36))
    local tabMiscText = Instance.new("TextLabel")
    tabMiscText.Size = UDim2.new(1, 0, 0, 20)
    tabMiscText.Position = UDim2.new(0, 0, 0, 44)
    tabMiscText.BackgroundTransparency = 1
    tabMiscText.Text = "MISC"
    tabMiscText.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabMiscText.TextSize = 10
    tabMiscText.Font = Enum.Font.GothamBold
    tabMiscText.ZIndex = 13
    tabMiscText.Parent = tabMisc
    
    -- CONFIG agora vem depois de MISC
    local tabConfig = Instance.new("TextButton")
    tabConfig.Size = UDim2.new(1, 0, 0, 65)
    tabConfig.Position = UDim2.new(0, 0, 0, 215)
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
    
    -- EH OG Sniper (INTEGRADO DO PRIMEIRO SCRIPT)
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
    ehOGSniperBtn.BackgroundColor3 = ogSniperEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    ehOGSniperBtn.BorderSizePixel = 1
    ehOGSniperBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehOGSniperBtn.Text = ogSniperEnabled and "ON" or "OFF"
    ehOGSniperBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehOGSniperBtn.TextSize = 14
    ehOGSniperBtn.Font = Enum.Font.GothamBold
    ehOGSniperBtn.ZIndex = 12
    ehOGSniperBtn.Parent = contentEH
    
    -- FRIENDS MODE COM LISTA DE BLOQUEADOS
    local ehLabel7 = Instance.new("TextLabel")
    ehLabel7.Size = UDim2.new(0, 150, 0, 35)
    ehLabel7.Position = UDim2.new(0, 15, 0, 365)
    ehLabel7.BackgroundTransparency = 1
    ehLabel7.Text = "Friends Mode"
    ehLabel7.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehLabel7.TextSize = 16
    ehLabel7.Font = Enum.Font.GothamBold
    ehLabel7.TextXAlignment = Enum.TextXAlignment.Left
    ehLabel7.ZIndex = 12
    ehLabel7.Parent = contentEH
    
    ehFriendsModeBtn = Instance.new("TextButton")
    ehFriendsModeBtn.Size = UDim2.new(0, 100, 0, 35)
    ehFriendsModeBtn.Position = UDim2.new(0, 200, 0, 365)
    ehFriendsModeBtn.BackgroundColor3 = Config.EH_FriendsMode and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    ehFriendsModeBtn.BorderSizePixel = 1
    ehFriendsModeBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehFriendsModeBtn.Text = Config.EH_FriendsMode and "ON" or "OFF"
    ehFriendsModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehFriendsModeBtn.TextSize = 14
    ehFriendsModeBtn.Font = Enum.Font.GothamBold
    ehFriendsModeBtn.ZIndex = 12
    ehFriendsModeBtn.Parent = contentEH
    
    -- Lista de jogadores bloqueados
    local blockedLabel = Instance.new("TextLabel")
    blockedLabel.Size = UDim2.new(0, 200, 0, 25)
    blockedLabel.Position = UDim2.new(0, 15, 0, 410)
    blockedLabel.BackgroundTransparency = 1
    blockedLabel.Text = "Jogadores Bloqueados:"
    blockedLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
    blockedLabel.TextSize = 14
    blockedLabel.Font = Enum.Font.GothamBold
    blockedLabel.TextXAlignment = Enum.TextXAlignment.Left
    blockedLabel.ZIndex = 12
    blockedLabel.Parent = contentEH
    
    -- Frame scroll para lista de bloqueados
    blockedPlayersFrame = Instance.new("ScrollingFrame")
    blockedPlayersFrame.Size = UDim2.new(0, 350, 0, 200)
    blockedPlayersFrame.Position = UDim2.new(0, 15, 0, 440)
    blockedPlayersFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    blockedPlayersFrame.BackgroundTransparency = 0.5
    blockedPlayersFrame.BorderSizePixel = 1
    blockedPlayersFrame.BorderColor3 = Color3.fromRGB(150, 0, 0)
    blockedPlayersFrame.ZIndex = 13
    blockedPlayersFrame.ScrollBarThickness = 6
    blockedPlayersFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 0)
    blockedPlayersFrame.Parent = contentEH
    
    -- Input para adicionar jogador
    local addPlayerInput = Instance.new("TextBox")
    addPlayerInput.Size = UDim2.new(0, 250, 0, 30)
    addPlayerInput.Position = UDim2.new(0, 15, 0, 650)
    addPlayerInput.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    addPlayerInput.BorderSizePixel = 1
    addPlayerInput.BorderColor3 = Color3.fromRGB(200, 0, 0)
    addPlayerInput.Text = ""
    addPlayerInput.PlaceholderText = "Nome do jogador..."
    addPlayerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    addPlayerInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    addPlayerInput.TextSize = 12
    addPlayerInput.Font = Enum.Font.Gotham
    addPlayerInput.ZIndex = 12
    addPlayerInput.Parent = contentEH
    
    local addPlayerBtn = Instance.new("TextButton")
    addPlayerBtn.Size = UDim2.new(0, 90, 0, 30)
    addPlayerBtn.Position = UDim2.new(0, 275, 0, 650)
    addPlayerBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    addPlayerBtn.BorderSizePixel = 0
    addPlayerBtn.Text = "Bloquear"
    addPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    addPlayerBtn.TextSize = 12
    addPlayerBtn.Font = Enum.Font.GothamBold
    addPlayerBtn.ZIndex = 12
    addPlayerBtn.Parent = contentEH
    
    addPlayerBtn.MouseButton1Click:Connect(function()
        local playerName = addPlayerInput.Text
        if playerName and playerName ~= "" then
            if AddBlockedPlayer(playerName) then
                addPlayerInput.Text = ""
                UpdateBlockedPlayersList()
            end
        end
    end)
    
    -- EH Key (Tecla Aimbot)
    local ehLabel8 = Instance.new("TextLabel")
    ehLabel8.Size = UDim2.new(0, 150, 0, 35)
    ehLabel8.Position = UDim2.new(0, 15, 0, 690)
    ehLabel8.BackgroundTransparency = 1
    ehLabel8.Text = "Tecla Aimbot"
    ehLabel8.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehLabel8.TextSize = 16
    ehLabel8.Font = Enum.Font.GothamBold
    ehLabel8.TextXAlignment = Enum.TextXAlignment.Left
    ehLabel8.ZIndex = 12
    ehLabel8.Parent = contentEH
    
    ehKeyBtn = Instance.new("TextButton")
    ehKeyBtn.Size = UDim2.new(0, 100, 0, 35)
    ehKeyBtn.Position = UDim2.new(0, 200, 0, 690)
    ehKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ehKeyBtn.BorderSizePixel = 1
    ehKeyBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehKeyBtn.Text = Config.EH_Key
    ehKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehKeyBtn.TextSize = 14
    ehKeyBtn.Font = Enum.Font.GothamBold
    ehKeyBtn.ZIndex = 12
    ehKeyBtn.Parent = contentEH
    
    -- CONTEÚDO SKY
    local contentSky = Instance.new("Frame")
    contentSky.Size = UDim2.new(1, -85, 1, -35)
    contentSky.Position = UDim2.new(0, 80, 0, 35)
    contentSky.BackgroundTransparency = 1
    contentSky.Visible = false
    contentSky.ZIndex = 11
    contentSky.Parent = mainFrame
    
    local skyTitle = Instance.new("TextLabel")
    skyTitle.Size = UDim2.new(1, -20, 0, 40)
    skyTitle.Position = UDim2.new(0, 10, 0, 10)
    skyTitle.BackgroundTransparency = 1
    skyTitle.Text = "Selecione o Céu"
    skyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    skyTitle.TextSize = 20
    skyTitle.Font = Enum.Font.GothamBold
    skyTitle.ZIndex = 12
    skyTitle.Parent = contentSky
    
    -- Lista de céus - AGORA COM A TABELA INICIALIZADA
    skyButtons = {} -- LIMPAR E RECRIAR A TABELA
    
    for i, skyData in ipairs(SKY_LIST) do
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        
        local skyBtn = Instance.new("TextButton")
        skyBtn.Size = UDim2.new(0, 280, 0, 50)
        skyBtn.Position = UDim2.new(0, 20 + col * 300, 0, 70 + row * 60)
        skyBtn.BackgroundColor3 = (Config.CurrentSkyId == skyData.id) and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
        skyBtn.BorderSizePixel = 1
        skyBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
        skyBtn.Text = (Config.CurrentSkyId == skyData.id and "✓ " or "") .. skyData.name
        skyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        skyBtn.TextSize = 14
        skyBtn.Font = Enum.Font.GothamBold
        skyBtn.ZIndex = 12
        skyBtn.Parent = contentSky
        
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
    
    local configTitle = Instance.new("TextLabel")
    configTitle.Size = UDim2.new(1, -20, 0, 40)
    configTitle.Position = UDim2.new(0, 10, 0, 10)
    configTitle.BackgroundTransparency = 1
    configTitle.Text = "Configurações"
    configTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    configTitle.TextSize = 20
    configTitle.Font = Enum.Font.GothamBold
    configTitle.ZIndex = 12
    configTitle.Parent = contentConfig
    
    -- Tecla da Interface
    local interfaceKeyLabel = Instance.new("TextLabel")
    interfaceKeyLabel.Size = UDim2.new(0, 200, 0, 35)
    interfaceKeyLabel.Position = UDim2.new(0, 20, 0, 70)
    interfaceKeyLabel.BackgroundTransparency = 1
    interfaceKeyLabel.Text = "Tecla Interface"
    interfaceKeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    interfaceKeyLabel.TextSize = 16
    interfaceKeyLabel.Font = Enum.Font.GothamBold
    interfaceKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    interfaceKeyLabel.ZIndex = 12
    interfaceKeyLabel.Parent = contentConfig
    
    interfaceKeyBtn = Instance.new("TextButton")
    interfaceKeyBtn.Size = UDim2.new(0, 100, 0, 35)
    interfaceKeyBtn.Position = UDim2.new(0, 240, 0, 70)
    interfaceKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    interfaceKeyBtn.BorderSizePixel = 1
    interfaceKeyBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    interfaceKeyBtn.Text = Config.InterfaceKey or "Insert"
    interfaceKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    interfaceKeyBtn.TextSize = 14
    interfaceKeyBtn.Font = Enum.Font.GothamBold
    interfaceKeyBtn.ZIndex = 12
    interfaceKeyBtn.Parent = contentConfig
    
    interfaceKeyBtn.MouseButton1Click:Connect(function()
        interfaceKeyBtn.Text = "..."
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Config.InterfaceKey = input.KeyCode.Name
                interfaceKeyBtn.Text = Config.InterfaceKey
                connection:Disconnect()
            end
        end)
    end)
    
    -- Botão Salvar Config
    local saveConfigBtn = Instance.new("TextButton")
    saveConfigBtn.Size = UDim2.new(0, 200, 0, 50)
    saveConfigBtn.Position = UDim2.new(0, 20, 0, 130)
    saveConfigBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    saveConfigBtn.BorderSizePixel = 1
    saveConfigBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    saveConfigBtn.Text = "Salvar Config"
    saveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveConfigBtn.TextSize = 16
    saveConfigBtn.Font = Enum.Font.GothamBold
    saveConfigBtn.ZIndex = 12
    saveConfigBtn.Parent = contentConfig
    
    -- Botão Carregar Config
    local loadConfigBtn = Instance.new("TextButton")
    loadConfigBtn.Size = UDim2.new(0, 200, 0, 50)
    loadConfigBtn.Position = UDim2.new(0, 240, 0, 130)
    loadConfigBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    loadConfigBtn.BorderSizePixel = 1
    loadConfigBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    loadConfigBtn.Text = "Carregar Config"
    loadConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadConfigBtn.TextSize = 16
    loadConfigBtn.Font = Enum.Font.GothamBold
    loadConfigBtn.ZIndex = 12
    loadConfigBtn.Parent = contentConfig
    
    -- Status
    local configStatus = Instance.new("TextLabel")
    configStatus.Size = UDim2.new(1, -40, 0, 30)
    configStatus.Position = UDim2.new(0, 20, 0, 200)
    configStatus.BackgroundTransparency = 1
    configStatus.Text = ""
    configStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
    configStatus.TextSize = 14
    configStatus.Font = Enum.Font.GothamBold
    configStatus.ZIndex = 12
    configStatus.Parent = contentConfig
    
    saveConfigBtn.MouseButton1Click:Connect(function()
        if SaveConfigToFile() then
            configStatus.Text = "Config salva com sucesso!"
            task.delay(3, function()
                configStatus.Text = ""
            end)
        else
            configStatus.Text = "Erro ao salvar config!"
            configStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
    
    loadConfigBtn.MouseButton1Click:Connect(function()
        if LoadConfigFromFile() then
            configStatus.Text = "Config carregada com sucesso!"
            configStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
            UpdateUI()
            task.delay(3, function()
                configStatus.Text = ""
            end)
        else
            configStatus.Text = "Erro ao carregar config!"
            configStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
    
    -- CONTEÚDO MISC (COM BOTÃO DE ATIVAÇÃO ÚNICA)
    local contentMisc = Instance.new("ScrollingFrame")
    contentMisc.Size = UDim2.new(1, -85, 1, -35)
    contentMisc.Position = UDim2.new(0, 80, 0, 35)
    contentMisc.BackgroundTransparency = 1
    contentMisc.Visible = false
    contentMisc.ZIndex = 11
    contentMisc.ScrollBarThickness = 6
    contentMisc.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 0)
    contentMisc.Parent = mainFrame
    
    local miscContainer = Instance.new("Frame")
    miscContainer.Size = UDim2.new(1, 0, 0, 500)
    miscContainer.BackgroundTransparency = 1
    miscContainer.ZIndex = 11
    miscContainer.Parent = contentMisc
    
    contentMisc.CanvasSize = UDim2.new(0, 0, 0, 500)
    
    -- Título MISC
    local miscTitle = Instance.new("TextLabel")
    miscTitle.Size = UDim2.new(1, -20, 0, 40)
    miscTitle.Position = UDim2.new(0, 10, 0, 10)
    miscTitle.BackgroundTransparency = 1
    miscTitle.Text = "MISC"
    miscTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    miscTitle.TextSize = 20
    miscTitle.Font = Enum.Font.GothamBold
    miscTitle.ZIndex = 12
    miscTitle.Parent = miscContainer
    
    -- Plastic Map Section
    local plasticMapLabel = Instance.new("TextLabel")
    plasticMapLabel.Size = UDim2.new(0, 200, 0, 35)
    plasticMapLabel.Position = UDim2.new(0, 20, 0, 70)
    plasticMapLabel.BackgroundTransparency = 1
    plasticMapLabel.Text = "Plastic Map (FPS)"
    plasticMapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    plasticMapLabel.TextSize = 16
    plasticMapLabel.Font = Enum.Font.GothamBold
    plasticMapLabel.TextXAlignment = Enum.TextXAlignment.Left
    plasticMapLabel.ZIndex = 12
    plasticMapLabel.Parent = miscContainer
    
    -- BOTÃO DE ATIVAÇÃO ÚNICA (Não pode ser desativado, apenas ativado)
    plasticMapBtn = Instance.new("TextButton")
    plasticMapBtn.Size = UDim2.new(0, 100, 0, 35)
    plasticMapBtn.Position = UDim2.new(0, 240, 0, 70)
    plasticMapBtn.BackgroundColor3 = plasticMapEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    plasticMapBtn.BorderSizePixel = 1
    plasticMapBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    plasticMapBtn.Text = plasticMapEnabled and "ATIVO" or "ATIVAR"
    plasticMapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plasticMapBtn.TextSize = 14
    plasticMapBtn.Font = Enum.Font.GothamBold
    plasticMapBtn.ZIndex = 12
    plasticMapBtn.Parent = miscContainer
    
    -- Descrição
    local plasticMapDesc = Instance.new("TextLabel")
    plasticMapDesc.Size = UDim2.new(1, -40, 0, 40)
    plasticMapDesc.Position = UDim2.new(0, 20, 0, 120)
    plasticMapDesc.BackgroundTransparency = 1
    plasticMapDesc.Text = "Remove texturas do mapa todo para ganho de FPS. Remove grama e otimiza o terreno. Não pode ser desativado após ativar."
    plasticMapDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
    plasticMapDesc.TextSize = 12
    plasticMapDesc.Font = Enum.Font.Gotham
    plasticMapDesc.TextWrapped = true
    plasticMapDesc.TextXAlignment = Enum.TextXAlignment.Left
    plasticMapDesc.ZIndex = 12
    plasticMapDesc.Parent = miscContainer
    
    -- FUNÇÕES DE TROCA DE ABA
    local function SwitchTab(tabName)
        currentTab = tabName
        
        -- Resetar cores das abas
        tabEH.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabSky.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabConfig.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        tabMisc.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        
        -- Esconder todos os conteúdos
        ehScrollFrame.Visible = false
        contentSky.Visible = false
        contentConfig.Visible = false
        contentMisc.Visible = false
        
        -- Mostrar aba selecionada
        if tabName == "Emergency Hamburg" then
            tabEH.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            ehScrollFrame.Visible = true
        elseif tabName == "Sky" then
            tabSky.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            contentSky.Visible = true
        elseif tabName == "Config" then
            tabConfig.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            contentConfig.Visible = true
        elseif tabName == "MISC" then
            tabMisc.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            contentMisc.Visible = true
        end
    end
    
    -- CONEXÕES DOS BOTÕES
    tabEH.MouseButton1Click:Connect(function() SwitchTab("Emergency Hamburg") end)
    tabSky.MouseButton1Click:Connect(function() SwitchTab("Sky") end)
    tabConfig.MouseButton1Click:Connect(function() SwitchTab("Config") end)
    tabMisc.MouseButton1Click:Connect(function() SwitchTab("MISC") end)
    
    -- SISTEMA DE FECHAR/MINIMIZAR
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        miniButton.Visible = true
        PanelOpen = false
    end)
    
    miniButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        miniButton.Visible = false
        PanelOpen = true
    end)
    
    -- Botões EH
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
        if Config.EH_ESP then
            EnableESP()
        else
        ClearESP()
        end
        UpdateUI()
    end)
    
    ehESPHealthBtn.MouseButton1Click:Connect(function()
        Config.EH_ESPHealth = not Config.EH_ESPHealth
        if Config.EH_ESPHealth then
            EnableESP()
        else
            ClearESP()
        end
        UpdateUI()
    end)
    
    ehFriendsModeBtn.MouseButton1Click:Connect(function()
        Config.EH_FriendsMode = not Config.EH_FriendsMode
        UpdateUI()
    end)
    
    ehSpinBotBtn.MouseButton1Click:Connect(function()
        ToggleSpinBot()
    end)
    
    ehOGSniperBtn.MouseButton1Click:Connect(function()
        ToggleOGSniper()
    end)
    
    ehKeyBtn.MouseButton1Click:Connect(function()
        ehKeyBtn.Text = "..."
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Config.EH_Key = input.KeyCode.Name
                ehKeyBtn.Text = Config.EH_Key
                connection:Disconnect()
            end
        end)
    end)
    
    -- Botão Plastic Map (ATIVAÇÃO ÚNICA)
    plasticMapBtn.MouseButton1Click:Connect(function()
        if not plasticMapEnabled then
            ApplyPlasticMap()
            -- Mudar para estado ativo (não pode desativar)
            plasticMapBtn.Text = "ATIVO"
            plasticMapBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            plasticMapBtn.AutoButtonColor = false -- Desabilita interação
        end
    end)
    
    -- DRAG DO PAINEL
    local function StartDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            dragStartPos = mainFrame.Position
            
            if dragConnection then dragConnection:Disconnect() end
            if dragEndConnection then dragEndConnection:Disconnect() end
            
            dragConnection = UserInputService.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
                    local delta = input2.Position - dragStart
                    mainFrame.Position = UDim2.new(
                        dragStartPos.X.Scale,
                        dragStartPos.X.Offset + delta.X,
                        dragStartPos.Y.Scale,
                        dragStartPos.Y.Offset + delta.Y
                    )
                end
            end)
            
            dragEndConnection = UserInputService.InputEnded:Connect(function(input3)
                if input3.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                    if dragConnection then dragConnection:Disconnect() end
                    if dragEndConnection then dragEndConnection:Disconnect() end
                end
            end)
        end
    end
    
    titleBar.InputBegan:Connect(StartDrag)
    
    -- DRAG DO BOTÃO MINI
    local miniDragging = false
    local miniDragStart, miniDragStartPos = nil, nil
    
    miniButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            miniDragging = true
            miniDragStart = input.Position
            miniDragStartPos = miniButton.Position
            
            local miniDragConnection = UserInputService.InputChanged:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseMovement and miniDragging then
                    local delta = input2.Position - miniDragStart
                    miniButton.Position = UDim2.new(
                        miniDragStartPos.X.Scale,
                        miniDragStartPos.X.Offset + delta.X,
                        miniDragStartPos.Y.Scale,
                        miniDragStartPos.Y.Offset + delta.Y
                    )
                end
            end)
            
            local miniDragEndConnection = UserInputService.InputEnded:Connect(function(input3)
                if input3.UserInputType == Enum.UserInputType.MouseButton1 then
                    miniDragging = false
                    miniDragConnection:Disconnect()
                    miniDragEndConnection:Disconnect()
                end
            end)
        end
    end)
    
    -- TECLA DE ATALHO (SEM SHIFT+Z CONFORME SOLICITADO)
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local keyName = input.KeyCode.Name
            if keyName == (Config.InterfaceKey or "Insert") then
                if mainFrame.Visible then
                    mainFrame.Visible = false
                    miniButton.Visible = false
                    PanelOpen = false
                else
                    mainFrame.Visible = true
                    miniButton.Visible = false
                    PanelOpen = true
                end
            end
        end
    end)
    
    -- INICIALIZAR
    UpdateUI()
    UpdateBlockedPlayersList()
    
    -- Carregar config ao iniciar
    LoadConfigFromFile()
    
    print("[SPHXZ] Script carregado com sucesso!")
    print("[SPHXZ] OG Sniper integrado!")
end

-- ============================================
-- INICIALIZACAO
-- ============================================
local function InitAuth(callback)
    local ck = LoadCache()
    if ck then
        local ok, msg = ValidateKey(ck)
        if ok then
            AuthSuccess = true
            if callback then callback() end
            return
        else
            ClearCache()
        end
    end
    
    CreateAuthUI(callback)
end

-- ============================================
-- INICIAR
-- ============================================
InitAuth(function()
    print("[SPHXZ] Autenticado! Iniciando script...")
    CreateMainGUI()
end)
