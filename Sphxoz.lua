-- ============================================
-- SPHXZ AUTH SYSTEM v4.6 + OG SNIPER INTEGRADO
-- Melhorias: Aimbot Head aprimorado, Filtrar time, Freeze Time CORRIGIDO
-- KEYS EMBUTIDAS DIRETAMENTE NO SCRIPT
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
-- KEYS VALIDAS (DIRETAMENTE NO SCRIPT)
-- ============================================
local VALID_KEYS = {
    ["SPHXZ-ZK91-LO6C-OC0L"] = true,
    ["SPHXZ-7PEX-GZIM-EHW1"] = true,
    ["SPHXZ-CHYY-MWH5-CASW"] = true,
    ["SPHXZ-HHJO-4AMX-SIJP"] = true,
    ["SPHXZ-4GZI-FBL6-6ELH"] = true,
}

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
    EH_TeamFilter = "All",
    FreezeTime = false,
    FrozenTime = 12,
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
local lastSniperCheck = 0

-- ============================================
-- VARIAVEIS FREEZE TIME
-- ============================================
local freezeTimeConnection = nil
local freezeTimeBtn = nil
local timeSlider = nil
local timeLabel = nil

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

local function GetHWID()
    return tostring(LocalPlayer.UserId) .. "-" .. tostring(game.PlaceId)
end

-- ============================================
-- VALIDACAO DE KEY
-- ============================================
local function ValidateKey(key)
    key = key:upper():gsub("%s+", "")
    
    if VALID_KEYS[key] then
        return true, "OK"
    end
    
    return false, "Key invalida ou nao autorizada"
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
            if result.EH_OGSniper ~= nil then
                ogSniperEnabled = result.EH_OGSniper
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

if Config.EH_TeamFilter == nil then Config.EH_TeamFilter = "All" end
if Config.FreezeTime == nil then Config.FreezeTime = false end
if Config.FrozenTime == nil then Config.FrozenTime = 12 end

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
    {id = 1, name = "Ceu Padrao", skyboxId = nil},
    
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

-- Variaveis globais
local originalSky = nil
local currentSkyObject = nil
local PanelOpen = true
local isAiming = false
local isDragging = false
local dragStart, dragStartPos, dragConnection, dragEndConnection = nil, nil, nil, nil

-- Variaveis da interface
local mainFrame, miniButton, screenGui
local currentTab = "Emergency Hamburg"

-- Variaveis EH
local ehAimbotBtn, ehAimLockBtn, ehESPBtn, ehESPHealthBtn, ehFriendsModeBtn, ehSpinBotBtn, ehSpinSpeedSlider, ehSpinSpeedLabel, ehOGSniperBtn
local filterCriminalBtn, filterAllBtn, filterPoliciaBtn
local espObjects, espHealthObjects, espConnections = {}, {}, {}
local ehKeyBtn, interfaceKeyBtn, lockedTarget, lockedPart = nil, nil, nil, nil

-- Variaveis SpinBot
local spinRunning = false
local spinAngle = 0

-- Variaveis Friends Mode
local blockedPlayersFrame = nil
local contentEHScroll = nil

-- Variaveis MISC
local plasticMapBtn = nil

-- Variaveis para miniButton draggable
local miniButtonDragging = false
local miniButtonDragStart = nil
local miniButtonStartPos = nil
local closedByX = false

-- Variaveis Mobile
local mobileAimbotBtn = nil
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Variaveis para movimento do painel
local panelDragging = false
local panelDragStart = nil
local panelStartPos = nil

-- Variaveis Sky
local skyButtons = {}

-- ============================================
-- FUNCAO: VERIFICAR SE E POLICIAL
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
-- FUNCAO: VERIFICAR SE JOGADOR TEM ARMA
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
-- FUNCAO: OBTER COR DO TIME
-- ============================================
local function GetTeamColor(player)
    if not player then return Color3.fromRGB(200, 200, 200) end
    
    if IsPolice(player) then
        return Color3.fromRGB(0, 100, 255)
    end
    
    if PlayerHasWeapon(player) then
        return Color3.fromRGB(255, 255, 255)
    end
    
    if player.Team then
        return player.TeamColor.Color
    end
    
    return Color3.fromRGB(200, 200, 200)
end

-- ============================================
-- FUNCOES FRIENDS MODE
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
-- FUNCAO: ATUALIZAR LISTA DE BLOQUEADOS
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
        emptyLabel.Text = "Nenhum jogador na whitelist"
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
-- SISTEMA OG SNIPER
-- ============================================
local function EnableNoScope()
    if scopeRemovalConnection then return end
    
    scopeRemovalConnection = RunService.Heartbeat:Connect(function()
        if not ogSniperEnabled then return end
        
        local currentTime = tick()
        if currentTime - lastSniperCheck < 0.1 then return end
        lastSniperCheck = currentTime
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            local toolName = tool.Name:lower()
            if toolName:find("sniper") or toolName:find("barret") or toolName:find("intervention") or toolName:find("awp") then
                pcall(function()
                    tool:SetAttribute("Scope", false)
                    tool:SetAttribute("Scoped", false)
                end)
            end
        end
    end)
end

local function DisableNoScope()
    if scopeRemovalConnection then
        scopeRemovalConnection:Disconnect()
        scopeRemovalConnection = nil
    end
end

local function EnableFastSniper()
    if sniperDelayConnection then return end
    
    sniperDelayConnection = RunService.Heartbeat:Connect(function()
        if not ogSniperEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            local toolName = tool.Name:lower()
            if toolName:find("sniper") or toolName:find("barret") or toolName:find("intervention") or toolName:find("awp") then
                pcall(function()
                    tool:SetAttribute("ShootDelay", 0.1)
                    tool:SetAttribute("AimDelay", 0)
                    tool:SetAttribute("ReloadDelay", 0.1)
                end)
            end
        end
    end)
end

local function DisableFastSniper()
    if sniperDelayConnection then
        sniperDelayConnection:Disconnect()
        sniperDelayConnection = nil
    end
end

local function removerMiraPreta()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local scopeNames = {"sniper", "scope", "scopeframe", "snipergui", "aimscope", "scopeoverlay", "blackscope"}
    
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local guiName = gui.Name:lower()
            local isScopeGui = false
            for _, name in ipairs(scopeNames) do
                if guiName:find(name) then
                    isScopeGui = true
                    break
                end
            end
            
            if isScopeGui then
                for _, filho in ipairs(gui:GetChildren()) do
                    if filho:IsA("Frame") or filho:IsA("ImageLabel") then
                        if filho:IsA("Frame") and filho.BackgroundColor3 == Color3.fromRGB(0, 0, 0) then
                            if filho.Size.X.Scale >= 0.5 and filho.Size.Y.Scale >= 0.5 then
                                pcall(function()
                                    filho.Visible = false
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end

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

-- ============================================
-- SISTEMA FREEZE TIME (CORRIGIDO)
-- ============================================
local function EnableFreezeTime()
    if freezeTimeConnection then return end
    
    freezeTimeConnection = RunService.Heartbeat:Connect(function()
        if Config.FreezeTime then
            Lighting.ClockTime = Config.FrozenTime
        end
    end)
    
    -- Aplicar imediatamente
    if Config.FreezeTime then
        Lighting.ClockTime = Config.FrozenTime
    end
end

local function DisableFreezeTime()
    if freezeTimeConnection then
        freezeTimeConnection:Disconnect()
        freezeTimeConnection = nil
    end
end

local function ToggleFreezeTime()
    Config.FreezeTime = not Config.FreezeTime
    
    if Config.FreezeTime then
        -- Salvar o tempo atual antes de congelar
        if not Config.FrozenTime or Config.FrozenTime == 0 then
            Config.FrozenTime = Lighting.ClockTime
        end
        EnableFreezeTime()
        Lighting.ClockTime = Config.FrozenTime
        print("FREEZE TIME ATIVADO! Hora: " .. tostring(Config.FrozenTime))
    else
        DisableFreezeTime()
        print("FREEZE TIME DESATIVADO!")
    end
    
    if freezeTimeBtn then
        freezeTimeBtn.Text = Config.FreezeTime and "ON" or "OFF"
        freezeTimeBtn.BackgroundColor3 = Config.FreezeTime and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    UpdateUI()
end

-- ============================================
-- SISTEMA PLASTIC MAP (FPS BOOSTER)
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
    
    if Terrain then
        originalTerrainMaterial = Terrain.Material
        originalTerrainColor = Terrain.Color
        
        Terrain.Material = Enum.Material.SmoothPlastic
        Terrain.Color = Color3.fromRGB(100, 100, 100)
        
        pcall(function()
            originalTerrainDecoration = Terrain.Decoration
            Terrain.Decoration = false
        end)
        
        pcall(function()
            Terrain:SetMaterialProperties(Enum.Material.Grass, {
                Density = 0,
                Size = 0,
                Height = 0
            })
        end)
    end
    
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
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            ProcessInstance(obj)
        end)
    end
    
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
    
    if plasticMapBtn then
        plasticMapBtn.Text = "ATIVO"
        plasticMapBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end

-- ============================================
-- FUNCAO: ATUALIZAR INTERFACE
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
    
    -- BOTOES DE FILTRO ATUALIZADOS
    if filterCriminalBtn then
        filterCriminalBtn.BackgroundColor3 = Config.EH_TeamFilter == "Criminal" and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    if filterAllBtn then
        filterAllBtn.BackgroundColor3 = Config.EH_TeamFilter == "All" and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    if filterPoliciaBtn then
        filterPoliciaBtn.BackgroundColor3 = Config.EH_TeamFilter == "Policia" and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    
    if freezeTimeBtn then
        freezeTimeBtn.Text = Config.FreezeTime and "ON" or "OFF"
        freezeTimeBtn.BackgroundColor3 = Config.FreezeTime and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    end
    if timeLabel then
        timeLabel.Text = "Hora: " .. string.format("%.1f", Config.FrozenTime)
    end
    if timeSlider then
        timeSlider.Size = UDim2.new(Config.FrozenTime / 24, 0, 1, 0)
    end
    
    if skyButtons and type(skyButtons) == "table" then
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
    end
    
    UpdateBlockedPlayersList()
end

-- ============================================
-- FUNCOES SPINBOT
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
-- FUNCOES EMERGENCY HAMBURG
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
-- FUNCAO: IsValidTarget (COM FILTRO DE TIME CORRIGIDO)
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
    
    if humanoid.Health <= 35 then return false end
    
    if humanoid.Health <= 0 then return false end
    if humanoid:GetState() == Enum.HumanoidStateType.Dead then return false end
    
    -- FILTRO DE TIME CORRIGIDO:
    -- POLICIA = apenas time azul
    -- ALL = Armed (branco) + Civis (cinza) + Policia (azul)
    -- CRIMINAL = Armed (branco) + Civis (cinza) [TUDO QUE NAO E POLICIA]
    if Config.EH_TeamFilter == "Policia" then
        if not IsPolice(player) then return false end
    elseif Config.EH_TeamFilter == "Criminal" then
        if IsPolice(player) then return false end
    end
    -- "All" permite todos
    
    local head = player.Character:FindFirstChild("Head")
    if not head then return false end
    
    local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
    if not torso then return false end
    
    return true
end

-- ============================================
-- FUNCAO: GetBestTargetPart (MELHORADA PARA HEAD)
-- ============================================
local function GetBestTargetPart(player)
    if not player or not player.Character then return nil end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end
    
    if humanoid.Health <= 35 then return nil end
    
    local character = player.Character
    local targetPart = nil
    
    if Config.EH_AimPart == "Head" then
        targetPart = character:FindFirstChild("Head")
        if targetPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                return targetPart
            end
        end
    else
        targetPart = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        if targetPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                return targetPart
            end
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

-- ============================================
-- FUNCAO: GetTargetVelocity
-- ============================================
local function GetTargetVelocity(player)
    if not player or not player.Character then return Vector3.new() end
    local character = player.Character
    local velocity = Vector3.new()
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        velocity = humanoid.MoveDirection
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local yVelocity = rootPart.Velocity.Y
            
            if yVelocity > 2 then
                velocity = velocity + Vector3.new(0, yVelocity * 0.5, 0)
            elseif yVelocity < -2 then
                velocity = velocity + Vector3.new(0, yVelocity * 0.3, 0)
            end
        end
        
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
-- LOOP EMERGENCY HAMBURG MELHORADO
-- ============================================
local lastCheck = 0
local targetVelocitySmooth = Vector3.new()
local aimSmoothing = 0.15

RunService.RenderStepped:Connect(function(deltaTime)
    if not Config.EH_Enabled then return end
    if not IsInEmergencyHamburg() then return end
    if PanelOpen then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    
    if ogSniperEnabled and tool then
        local toolName = tool.Name:lower()
        if toolName:find("sniper") or toolName:find("barret") or toolName:find("intervention") then
            if tick() % 1 < 0.05 then
                removerMiraPreta()
            end
        end
    end
    
    if not IsEHWeapon(tool) then 
        lockedTarget = nil
        lockedPart = nil
        return 
    end
    
    local isPressed = false
    if isMobile then
        isPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or 
                   (mobileAimbotBtn and mobileAimbotBtn.BackgroundColor3 == Color3.fromRGB(200, 0, 0))
    else
        isPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end
    
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
                
                local leadX, leadY = 0, 0
                local velocity = GetTargetVelocity(lockedTarget)
                local magnitude = (velocity * Vector3.new(1, 0, 1)).Magnitude
                local distance = (lockedPart.Position - Camera.CFrame.Position).Magnitude
                
                local leadFactor = 0.012
                if Config.EH_AimPart == "Head" then
                    leadFactor = 0.006 + (0.010 * (1 - math.min(distance / 200, 1)))
                    leadFactor = math.clamp(leadFactor, 0.004, 0.018)
                    
                    if velocity.Y > 0.5 then
                        leadFactor = leadFactor * 1.4
                    end
                else
                    leadFactor = 0.015 + (0.020 * (1 - math.min(distance / 300, 1)))
                    leadFactor = math.clamp(leadFactor, 0.008, 0.030)
                end
                
                targetVelocitySmooth = targetVelocitySmooth:Lerp(velocity, 0.3)
                
                if magnitude > 0.1 or velocity.Y > 0.5 then
                    local worldVelocity = targetVelocitySmooth * distance * leadFactor
                    local screenVelocity, onScreen2 = Camera:WorldToViewportPoint(lockedPart.Position + worldVelocity)
                    
                    if onScreen2 then
                        leadX = (screenVelocity.X - screenPos.X)
                        leadY = (screenVelocity.Y - screenPos.Y)
                        
                        if Config.EH_AimPart == "Head" then
                            local maxLead = 30
                            leadX = math.clamp(leadX, -maxLead, maxLead)
                            leadY = math.clamp(leadY, -maxLead, maxLead)
                        end
                    end
                end
                
                local smoothFactor = 0.30
                if Config.EH_AimPart == "Head" then
                    smoothFactor = 0.35
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
                    
                    local score = mag + (dist3D / 10)
                    
                    if Config.EH_AimPart == "Head" and part.Name == "Head" then
                        score = score * 0.6
                    end
                    
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
            local smoothFactor = Config.EH_AimPart == "Head" and 0.40 or 0.35
            
            local x = (screenPos.X - mousePos2.X) * smoothFactor
            local y = (screenPos.Y - mousePos2.Y) * smoothFactor
            
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
-- SISTEMA DE SAVE/LOAD
-- ============================================
local function SaveConfigToFile()
    if typeof(writefile) ~= "function" then
        return false
    end
    
    local configToSave = {}
    for key, value in pairs(Config) do
        configToSave[key] = value
    end
    
    configToSave.EH_OGSniper = ogSniperEnabled
    
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
            if key ~= "PlasticMap_Enabled" then
                Config[key] = value
            end
        end
        if not Config.BlockedPlayers then
            Config.BlockedPlayers = {}
        end
        
        if Config.EH_TeamFilter == nil then Config.EH_TeamFilter = "All" end
        if Config.FreezeTime == nil then Config.FreezeTime = false end
        if Config.FrozenTime == nil then Config.FrozenTime = 12 end
        
        if result.EH_OGSniper ~= nil then
            ogSniperEnabled = result.EH_OGSniper
        end
        
        if Config.CurrentSkyId then
            ApplySky(Config.CurrentSkyId)
        end
        
        return true
    else
        return false
    end
end

-- ============================================
-- FUNCOES SKY
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
    
    if Config.FreezeTime then
        Lighting.ClockTime = Config.FrozenTime
    end
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
    
    -- BOTAO MINI
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
    miniButton.Visible = false
    miniButton.Parent = screenGui
    
    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 8)
    miniCorner.Parent = miniButton
    
    -- SISTEMA DE ARRASTAR MINI BOTAO
    local function UpdateMiniDrag(input)
        local delta = input.Position - miniButtonDragStart
        miniButton.Position = UDim2.new(miniButtonStartPos.X.Scale, miniButtonStartPos.X.Offset + delta.X, 
                                        miniButtonStartPos.Y.Scale, miniButtonStartPos.Y.Offset + delta.Y)
    end
    
    miniButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniButtonDragging = true
            miniButtonDragStart = input.Position
            miniButtonStartPos = miniButton.Position
            
            if mainFrame.Visible then
                mainFrame.Visible = false
                miniButton.Visible = true
                PanelOpen = false
            end
        end
    end)
    
    miniButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniButtonDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if miniButtonDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateMiniDrag(input)
        end
    end)
    
    -- BOTAO MOBILE
    if isMobile then
        mobileAimbotBtn = Instance.new("TextButton")
        mobileAimbotBtn.Name = "MobileAimbotBtn"
        mobileAimbotBtn.Size = UDim2.new(0, 80, 0, 80)
        mobileAimbotBtn.Position = UDim2.new(1, -90, 0.5, -40)
        mobileAimbotBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
        mobileAimbotBtn.BorderSizePixel = 2
        mobileAimbotBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
        mobileAimbotBtn.Text = "AIM"
        mobileAimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        mobileAimbotBtn.TextSize = 16
        mobileAimbotBtn.Font = Enum.Font.GothamBold
        mobileAimbotBtn.ZIndex = 1000
        mobileAimbotBtn.Parent = screenGui
        
        local mobileCorner = Instance.new("UICorner")
        mobileCorner.CornerRadius = UDim.new(1, 0)
        mobileCorner.Parent = mobileAimbotBtn
        
        mobileAimbotBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                Config.EH_Enabled = not Config.EH_Enabled
                mobileAimbotBtn.BackgroundColor3 = Config.EH_Enabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
                UpdateUI()
            end
        end)
    end
    
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
    
    -- Barra de titulo (ARRASTAVEL)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
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
    
    -- SISTEMA DE ARRASTAR O PAINEL
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            panelDragging = true
            panelDragStart = input.Position
            panelStartPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if panelDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - panelDragStart
            mainFrame.Position = UDim2.new(
                panelStartPos.X.Scale,
                panelStartPos.X.Offset + delta.X,
                panelStartPos.Y.Scale,
                panelStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            panelDragging = false
        end
    end)
    
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
    
    -- ABAS
    local tabEH = Instance.new("TextButton")
    tabEH.Size = UDim2.new(1, 0, 0, 65)
    tabEH.Position = UDim2.new(0, 0, 0, 5)
    tabEH.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    tabEH.BorderSizePixel = 0
    tabEH.Text = ""
    tabEH.ZIndex = 12
    tabEH.Parent = tabFrame
    
    local ehImage = CreateImageLabel(tabEH, IMAGE_EH, UDim2.new(0.5, -16, 0, 8), UDim2.new(0, 32, 0, 32))
    
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
    
    -- CONTEUDO EH COM SCROLL
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
    contentEH.Size = UDim2.new(1, 0, 0, 1100)
    contentEH.BackgroundTransparency = 1
    contentEH.ZIndex = 11
    contentEH.Parent = ehScrollFrame
    
    ehScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1100)
    
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
    
    -- BOTOES DE FILTRO DE TIME (POSIÇÃO CORRIGIDA - MAIS ABAIXO)
    -- Botao Criminal
    filterCriminalBtn = Instance.new("TextButton")
    filterCriminalBtn.Size = UDim2.new(0, 100, 0, 35)
    filterCriminalBtn.Position = UDim2.new(0, 15, 0, 70)
    filterCriminalBtn.BackgroundColor3 = Config.EH_TeamFilter == "Criminal" and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    filterCriminalBtn.BorderSizePixel = 1
    filterCriminalBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    filterCriminalBtn.Text = "CRIMINAL"
    filterCriminalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    filterCriminalBtn.TextSize = 12
    filterCriminalBtn.Font = Enum.Font.GothamBold
    filterCriminalBtn.ZIndex = 12
    filterCriminalBtn.Parent = contentEH
    
    -- Botao Todos
    filterAllBtn = Instance.new("TextButton")
    filterAllBtn.Size = UDim2.new(0, 100, 0, 35)
    filterAllBtn.Position = UDim2.new(0, 125, 0, 70)
    filterAllBtn.BackgroundColor3 = Config.EH_TeamFilter == "All" and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    filterAllBtn.BorderSizePixel = 1
    filterAllBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    filterAllBtn.Text = "TODOS"
    filterAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    filterAllBtn.TextSize = 12
    filterAllBtn.Font = Enum.Font.GothamBold
    filterAllBtn.ZIndex = 12
    filterAllBtn.Parent = contentEH
    
    -- Botao Policia
    filterPoliciaBtn = Instance.new("TextButton")
    filterPoliciaBtn.Size = UDim2.new(0, 100, 0, 35)
    filterPoliciaBtn.Position = UDim2.new(0, 235, 0, 70)
    filterPoliciaBtn.BackgroundColor3 = Config.EH_TeamFilter == "Policia" and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    filterPoliciaBtn.BorderSizePixel = 1
    filterPoliciaBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    filterPoliciaBtn.Text = "POLICIA"
    filterPoliciaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    filterPoliciaBtn.TextSize = 12
    filterPoliciaBtn.Font = Enum.Font.GothamBold
    filterPoliciaBtn.ZIndex = 12
    filterPoliciaBtn.Parent = contentEH
    
    -- Eventos dos botoes de filtro (ATUALIZAM A INTERFACE)
    filterCriminalBtn.MouseButton1Click:Connect(function()
        Config.EH_TeamFilter = "Criminal"
        UpdateUI()
        SaveConfigToFile()
    end)
    
    filterAllBtn.MouseButton1Click:Connect(function()
        Config.EH_TeamFilter = "All"
        UpdateUI()
        SaveConfigToFile()
    end)
    
    filterPoliciaBtn.MouseButton1Click:Connect(function()
        Config.EH_TeamFilter = "Policia"
        UpdateUI()
        SaveConfigToFile()
    end)
    
    -- EH Aim Lock
    local ehLabel2 = Instance.new("TextLabel")
    ehLabel2.Size = UDim2.new(0, 150, 0, 35)
    ehLabel2.Position = UDim2.new(0, 15, 0, 120)
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
    ehAimLockBtn.Position = UDim2.new(0, 200, 0, 120)
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
    ehLabel3.Position = UDim2.new(0, 15, 0, 170)
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
    ehESPBtn.Position = UDim2.new(0, 200, 0, 170)
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
    ehLabel4.Position = UDim2.new(0, 15, 0, 220)
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
    ehESPHealthBtn.Position = UDim2.new(0, 200, 0, 220)
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
    ehLabel5.Position = UDim2.new(0, 15, 0, 270)
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
    ehSpinBotBtn.Position = UDim2.new(0, 200, 0, 270)
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
    ehSpinSpeedLabel.Position = UDim2.new(0, 15, 0, 315)
    ehSpinSpeedLabel.BackgroundTransparency = 1
    ehSpinSpeedLabel.Text = "Velocidade: " .. tostring(Config.EH_SpinSpeed)
    ehSpinSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehSpinSpeedLabel.TextSize = 14
    ehSpinSpeedLabel.Font = Enum.Font.GothamBold
    ehSpinSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    ehSpinSpeedLabel.ZIndex = 12
    ehSpinSpeedLabel.Parent = contentEH
    
    -- Container do slider SpinBot
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(0, 200, 0, 10)
    sliderContainer.Position = UDim2.new(0, 15, 0, 345)
    sliderContainer.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    sliderContainer.BorderSizePixel = 0
    sliderContainer.ZIndex = 12
    sliderContainer.Parent = contentEH
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 5)
    sliderCorner.Parent = sliderContainer
    
    ehSpinSpeedSlider = Instance.new("Frame")
    ehSpinSpeedSlider.Size = UDim2.new(Config.EH_SpinSpeed / 1000, 0, 1, 0)
    ehSpinSpeedSlider.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    ehSpinSpeedSlider.BorderSizePixel = 0
    ehSpinSpeedSlider.ZIndex = 13
    ehSpinSpeedSlider.Parent = sliderContainer
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 5)
    sliderFillCorner.Parent = ehSpinSpeedSlider
    
    -- EH OG Sniper
    local ehLabel6 = Instance.new("TextLabel")
    ehLabel6.Size = UDim2.new(0, 150, 0, 35)
    ehLabel6.Position = UDim2.new(0, 15, 0, 375)
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
    ehOGSniperBtn.Position = UDim2.new(0, 200, 0, 375)
    ehOGSniperBtn.BackgroundColor3 = ogSniperEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    ehOGSniperBtn.BorderSizePixel = 1
    ehOGSniperBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehOGSniperBtn.Text = ogSniperEnabled and "ON" or "OFF"
    ehOGSniperBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehOGSniperBtn.TextSize = 14
    ehOGSniperBtn.Font = Enum.Font.GothamBold
    ehOGSniperBtn.ZIndex = 12
    ehOGSniperBtn.Parent = contentEH
    
    -- EH Friends Mode
    local ehLabel7 = Instance.new("TextLabel")
    ehLabel7.Size = UDim2.new(0, 150, 0, 35)
    ehLabel7.Position = UDim2.new(0, 15, 0, 425)
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
    ehFriendsModeBtn.Position = UDim2.new(0, 200, 0, 425)
    ehFriendsModeBtn.BackgroundColor3 = Config.EH_FriendsMode and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    ehFriendsModeBtn.BorderSizePixel = 1
    ehFriendsModeBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehFriendsModeBtn.Text = Config.EH_FriendsMode and "ON" or "OFF"
    ehFriendsModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehFriendsModeBtn.TextSize = 14
    ehFriendsModeBtn.Font = Enum.Font.GothamBold
    ehFriendsModeBtn.ZIndex = 12
    ehFriendsModeBtn.Parent = contentEH
    
    -- Frame de jogadores bloqueados (WHITELIST)
    local blockedLabel = Instance.new("TextLabel")
    blockedLabel.Size = UDim2.new(0, 200, 0, 30)
    blockedLabel.Position = UDim2.new(0, 320, 0, 15)
    blockedLabel.BackgroundTransparency = 1
    blockedLabel.Text = "WHITELIST"
    blockedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    blockedLabel.TextSize = 16
    blockedLabel.Font = Enum.Font.GothamBold
    blockedLabel.ZIndex = 12
    blockedLabel.Parent = contentEH
    
    blockedPlayersFrame = Instance.new("ScrollingFrame")
    blockedPlayersFrame.Size = UDim2.new(0, 350, 0, 350)
    blockedPlayersFrame.Position = UDim2.new(0, 320, 0, 50)
    blockedPlayersFrame.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
    blockedPlayersFrame.BorderSizePixel = 1
    blockedPlayersFrame.BorderColor3 = Color3.fromRGB(150, 0, 0)
    blockedPlayersFrame.ScrollBarThickness = 4
    blockedPlayersFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 0)
    blockedPlayersFrame.ZIndex = 13
    blockedPlayersFrame.Parent = contentEH
    
    local blockedCorner = Instance.new("UICorner")
    blockedCorner.CornerRadius = UDim.new(0, 8)
    blockedCorner.Parent = blockedPlayersFrame
    
    -- Input para adicionar jogador
    local addPlayerFrame = Instance.new("Frame")
    addPlayerFrame.Size = UDim2.new(0, 350, 0, 40)
    addPlayerFrame.Position = UDim2.new(0, 320, 0, 410)
    addPlayerFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    addPlayerFrame.BorderSizePixel = 1
    addPlayerFrame.BorderColor3 = Color3.fromRGB(150, 0, 0)
    addPlayerFrame.ZIndex = 13
    addPlayerFrame.Parent = contentEH
    
    local addPlayerCorner = Instance.new("UICorner")
    addPlayerCorner.CornerRadius = UDim.new(0, 8)
    addPlayerCorner.Parent = addPlayerFrame
    
    local addPlayerInput = Instance.new("TextBox")
    addPlayerInput.Size = UDim2.new(0.7, -10, 1, -10)
    addPlayerInput.Position = UDim2.new(0, 5, 0, 5)
    addPlayerInput.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    addPlayerInput.BorderSizePixel = 0
    addPlayerInput.PlaceholderText = "Nome do jogador..."
    addPlayerInput.Text = ""
    addPlayerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    addPlayerInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    addPlayerInput.TextSize = 14
    addPlayerInput.Font = Enum.Font.Gotham
    addPlayerInput.ZIndex = 14
    addPlayerInput.Parent = addPlayerFrame
    
    local addPlayerBtn = Instance.new("TextButton")
    addPlayerBtn.Size = UDim2.new(0.3, -10, 1, -10)
    addPlayerBtn.Position = UDim2.new(0.7, 5, 0, 5)
    addPlayerBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    addPlayerBtn.BorderSizePixel = 0
    addPlayerBtn.Text = "Bloquear"
    addPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    addPlayerBtn.TextSize = 14
    addPlayerBtn.Font = Enum.Font.GothamBold
    addPlayerBtn.ZIndex = 14
    addPlayerBtn.Parent = addPlayerFrame
    
    -- CONTEUDO SKY
    local contentSky = Instance.new("ScrollingFrame")
    contentSky.Name = "ContentSky"
    contentSky.Size = UDim2.new(1, -85, 1, -35)
    contentSky.Position = UDim2.new(0, 80, 0, 35)
    contentSky.BackgroundTransparency = 1
    contentSky.Visible = false
    contentSky.ZIndex = 11
    contentSky.ScrollBarThickness = 6
    contentSky.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 0)
    contentSky.Parent = mainFrame
    
    local skyContentFrame = Instance.new("Frame")
    skyContentFrame.Size = UDim2.new(1, 0, 0, 600)
    skyContentFrame.BackgroundTransparency = 1
    skyContentFrame.ZIndex = 11
    skyContentFrame.Parent = contentSky
    
    contentSky.CanvasSize = UDim2.new(0, 0, 0, 600)
    
    local skyTitle = Instance.new("TextLabel")
    skyTitle.Size = UDim2.new(1, -20, 0, 40)
    skyTitle.Position = UDim2.new(0, 10, 0, 10)
    skyTitle.BackgroundTransparency = 1
    skyTitle.Text = "Selecione o Ceu"
    skyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    skyTitle.TextSize = 20
    skyTitle.Font = Enum.Font.GothamBold
    skyTitle.ZIndex = 12
    skyTitle.Parent = skyContentFrame
    
    local yPos = 60
    for i, sky in ipairs(SKY_LIST) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 600, 0, 50)
        btn.Position = UDim2.new(0.5, -300, 0, yPos)
        btn.BackgroundColor3 = (Config.CurrentSkyId == sky.id) and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(200, 0, 0)
        btn.Text = (Config.CurrentSkyId == sky.id and "✓ " or "") .. sky.name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.ZIndex = 12
        btn.Parent = skyContentFrame
        
        table.insert(skyButtons, {button = btn, skyId = sky.id, skyName = sky.name})
        
        btn.MouseButton1Click:Connect(function()
            ApplySky(sky.id)
            SaveConfigToFile()
            UpdateUI()
        end)
        
        yPos = yPos + 60
    end
    
    -- CONTEUDO MISC
    local contentMisc = Instance.new("ScrollingFrame")
    contentMisc.Name = "ContentMisc"
    contentMisc.Size = UDim2.new(1, -85, 1, -35)
    contentMisc.Position = UDim2.new(0, 80, 0, 35)
    contentMisc.BackgroundTransparency = 1
    contentMisc.Visible = false
    contentMisc.ZIndex = 11
    contentMisc.ScrollBarThickness = 6
    contentMisc.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 0)
    contentMisc.Parent = mainFrame
    
    local miscContentFrame = Instance.new("Frame")
    miscContentFrame.Size = UDim2.new(1, 0, 0, 600)
    miscContentFrame.BackgroundTransparency = 1
    miscContentFrame.ZIndex = 11
    miscContentFrame.Parent = contentMisc
    
    contentMisc.CanvasSize = UDim2.new(0, 0, 0, 600)
    
    local miscTitle = Instance.new("TextLabel")
    miscTitle.Size = UDim2.new(1, -20, 0, 40)
    miscTitle.Position = UDim2.new(0, 10, 0, 10)
    miscTitle.BackgroundTransparency = 1
    miscTitle.Text = "Miscellaneous"
    miscTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    miscTitle.TextSize = 20
    miscTitle.Font = Enum.Font.GothamBold
    miscTitle.ZIndex = 12
    miscTitle.Parent = miscContentFrame
    
    -- Plastic Map Button
    local plasticLabel = Instance.new("TextLabel")
    plasticLabel.Size = UDim2.new(0, 200, 0, 35)
    plasticLabel.Position = UDim2.new(0, 15, 0, 70)
    plasticLabel.BackgroundTransparency = 1
    plasticLabel.Text = "Plastic Map (FPS)"
    plasticLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    plasticLabel.TextSize = 16
    plasticLabel.Font = Enum.Font.GothamBold
    plasticLabel.TextXAlignment = Enum.TextXAlignment.Left
    plasticLabel.ZIndex = 12
    plasticLabel.Parent = miscContentFrame
    
    plasticMapBtn = Instance.new("TextButton")
    plasticMapBtn.Size = UDim2.new(0, 200, 0, 40)
    plasticMapBtn.Position = UDim2.new(0, 250, 0, 70)
    plasticMapBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    plasticMapBtn.BorderSizePixel = 1
    plasticMapBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    plasticMapBtn.Text = "ATIVAR"
    plasticMapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plasticMapBtn.TextSize = 14
    plasticMapBtn.Font = Enum.Font.GothamBold
    plasticMapBtn.ZIndex = 12
    plasticMapBtn.Parent = miscContentFrame
    
    -- Freeze Time
    local freezeLabel = Instance.new("TextLabel")
    freezeLabel.Size = UDim2.new(0, 150, 0, 35)
    freezeLabel.Position = UDim2.new(0, 15, 0, 130)
    freezeLabel.BackgroundTransparency = 1
    freezeLabel.Text = "Freeze Time"
    freezeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    freezeLabel.TextSize = 16
    freezeLabel.Font = Enum.Font.GothamBold
    freezeLabel.TextXAlignment = Enum.TextXAlignment.Left
    freezeLabel.ZIndex = 12
    freezeLabel.Parent = miscContentFrame
    
    freezeTimeBtn = Instance.new("TextButton")
    freezeTimeBtn.Size = UDim2.new(0, 100, 0, 35)
    freezeTimeBtn.Position = UDim2.new(0, 200, 0, 130)
    freezeTimeBtn.BackgroundColor3 = Config.FreezeTime and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
    freezeTimeBtn.BorderSizePixel = 1
    freezeTimeBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    freezeTimeBtn.Text = Config.FreezeTime and "ON" or "OFF"
    freezeTimeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    freezeTimeBtn.TextSize = 14
    freezeTimeBtn.Font = Enum.Font.GothamBold
    freezeTimeBtn.ZIndex = 12
    freezeTimeBtn.Parent = miscContentFrame
    
    -- Label hora
    timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0, 150, 0, 25)
    timeLabel.Position = UDim2.new(0, 15, 0, 175)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "Hora: " .. string.format("%.1f", Config.FrozenTime)
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextSize = 14
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.ZIndex = 12
    timeLabel.Parent = miscContentFrame
    
    -- Container do slider de tempo
    local timeSliderContainer = Instance.new("Frame")
    timeSliderContainer.Size = UDim2.new(0, 200, 0, 10)
    timeSliderContainer.Position = UDim2.new(0, 15, 0, 205)
    timeSliderContainer.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    timeSliderContainer.BorderSizePixel = 0
    timeSliderContainer.ZIndex = 12
    timeSliderContainer.Parent = miscContentFrame
    
    local timeSliderCorner = Instance.new("UICorner")
    timeSliderCorner.CornerRadius = UDim.new(0, 5)
    timeSliderCorner.Parent = timeSliderContainer
    
    timeSlider = Instance.new("Frame")
    timeSlider.Size = UDim2.new(Config.FrozenTime / 24, 0, 1, 0)
    timeSlider.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    timeSlider.BorderSizePixel = 0
    timeSlider.ZIndex = 13
    timeSlider.Parent = timeSliderContainer
    
    local timeSliderFillCorner = Instance.new("UICorner")
    timeSliderFillCorner.CornerRadius = UDim.new(0, 5)
    timeSliderFillCorner.Parent = timeSlider
    
    -- CONTEUDO CONFIG
    local contentConfig = Instance.new("ScrollingFrame")
    contentConfig.Name = "ContentConfig"
    contentConfig.Size = UDim2.new(1, -85, 1, -35)
    contentConfig.Position = UDim2.new(0, 80, 0, 35)
    contentConfig.BackgroundTransparency = 1
    contentConfig.Visible = false
    contentConfig.ZIndex = 11
    contentConfig.ScrollBarThickness = 6
    contentConfig.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 0)
    contentConfig.Parent = mainFrame
    
    local configContentFrame = Instance.new("Frame")
    configContentFrame.Size = UDim2.new(1, 0, 0, 500)
    configContentFrame.BackgroundTransparency = 1
    configContentFrame.ZIndex = 11
    configContentFrame.Parent = contentConfig
    
    contentConfig.CanvasSize = UDim2.new(0, 0, 0, 500)
    
    local configTitle = Instance.new("TextLabel")
    configTitle.Size = UDim2.new(1, -20, 0, 40)
    configTitle.Position = UDim2.new(0, 10, 0, 10)
    configTitle.BackgroundTransparency = 1
    configTitle.Text = "Configuracoes"
    configTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    configTitle.TextSize = 20
    configTitle.Font = Enum.Font.GothamBold
    configTitle.ZIndex = 12
    configTitle.Parent = configContentFrame
    
    -- Interface Key
    local interfaceLabel = Instance.new("TextLabel")
    interfaceLabel.Size = UDim2.new(0, 200, 0, 35)
    interfaceLabel.Position = UDim2.new(0, 15, 0, 70)
    interfaceLabel.BackgroundTransparency = 1
    interfaceLabel.Text = "Tecla Interface"
    interfaceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    interfaceLabel.TextSize = 16
    interfaceLabel.Font = Enum.Font.GothamBold
    interfaceLabel.TextXAlignment = Enum.TextXAlignment.Left

    interfaceKeyBtn = Instance.new("TextButton")
    interfaceKeyBtn.Size = UDim2.new(0, 100, 0, 35)
    interfaceKeyBtn.Position = UDim2.new(0, 250, 0, 70)
    interfaceKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    interfaceKeyBtn.BorderSizePixel = 1
    interfaceKeyBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    interfaceKeyBtn.Text = Config.InterfaceKey or "Insert"
    interfaceKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    interfaceKeyBtn.TextSize = 14
    interfaceKeyBtn.Font = Enum.Font.GothamBold
    interfaceKeyBtn.ZIndex = 12
    interfaceKeyBtn.Parent = configContentFrame
    
    -- Aimbot Key
    local aimbotKeyLabel = Instance.new("TextLabel")
    aimbotKeyLabel.Size = UDim2.new(0, 200, 0, 35)
    aimbotKeyLabel.Position = UDim2.new(0, 15, 0, 120)
    aimbotKeyLabel.BackgroundTransparency = 1
    aimbotKeyLabel.Text = "Aimbot Toggle Key"
    aimbotKeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotKeyLabel.TextSize = 16
    aimbotKeyLabel.Font = Enum.Font.GothamBold
    aimbotKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimbotKeyLabel.ZIndex = 12
    aimbotKeyLabel.Parent = configContentFrame
    
    ehKeyBtn = Instance.new("TextButton")
    ehKeyBtn.Size = UDim2.new(0, 100, 0, 35)
    ehKeyBtn.Position = UDim2.new(0, 250, 0, 120)
    ehKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ehKeyBtn.BorderSizePixel = 1
    ehKeyBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    ehKeyBtn.Text = Config.EH_Key
    ehKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ehKeyBtn.TextSize = 14
    ehKeyBtn.Font = Enum.Font.GothamBold
    ehKeyBtn.ZIndex = 12
    ehKeyBtn.Parent = configContentFrame
    
    -- Save Config Button
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 280, 0, 50)
    saveBtn.Position = UDim2.new(0.5, -290, 0, 200)
    saveBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    saveBtn.BorderSizePixel = 1
    saveBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    saveBtn.Text = "SALVAR CONFIG"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.TextSize = 18
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.ZIndex = 12
    saveBtn.Parent = configContentFrame
    
    -- Load Config Button
    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0, 280, 0, 50)
    loadBtn.Position = UDim2.new(0.5, 10, 0, 200)
    loadBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    loadBtn.BorderSizePixel = 1
    loadBtn.BorderColor3 = Color3.fromRGB(200, 0, 0)
    loadBtn.Text = "CARREGAR CONFIG"
    loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadBtn.TextSize = 18
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.ZIndex = 12
    loadBtn.Parent = configContentFrame
    
    -- FUNCOES DE EVENTOS
    
    -- Fechar pelo X - mostra miniButton
    closeBtn.MouseButton1Click:Connect(function()
        closedByX = true
        mainFrame.Visible = false
        miniButton.Visible = true
        PanelOpen = false
    end)
    
    -- Mini button click
    miniButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        miniButton.Visible = false
        PanelOpen = true
        closedByX = false
    end)
    
    -- Tab switching
    local function SwitchTab(tabName)
        currentTab = tabName
        
        ehScrollFrame.Visible = (tabName == "Emergency Hamburg")
        contentSky.Visible = (tabName == "Sky")
        contentMisc.Visible = (tabName == "Misc")
        contentConfig.Visible = (tabName == "Config")
        
        tabEH.BackgroundColor3 = (tabName == "Emergency Hamburg") and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(60, 0, 0)
        tabSky.BackgroundColor3 = (tabName == "Sky") and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(60, 0, 0)
        tabMisc.BackgroundColor3 = (tabName == "Misc") and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(60, 0, 0)
        tabConfig.BackgroundColor3 = (tabName == "Config") and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(60, 0, 0)
    end
    
    tabEH.MouseButton1Click:Connect(function() SwitchTab("Emergency Hamburg") end)
    tabSky.MouseButton1Click:Connect(function() SwitchTab("Sky") end)
    tabMisc.MouseButton1Click:Connect(function() SwitchTab("Misc") end)
    tabConfig.MouseButton1Click:Connect(function() SwitchTab("Config") end)
    
    -- EH Events
    ehAimbotBtn.MouseButton1Click:Connect(function()
        Config.EH_Enabled = not Config.EH_Enabled
        UpdateUI()
        SaveConfigToFile()
    end)
    
    ehAimLockBtn.MouseButton1Click:Connect(function()
        Config.EH_AimPart = (Config.EH_AimPart == "Torso") and "Head" or "Torso"
        UpdateUI()
        SaveConfigToFile()
    end)
    
    ehESPBtn.MouseButton1Click:Connect(function()
        Config.EH_ESP = not Config.EH_ESP
        if Config.EH_ESP then EnableESP() else DisableESP() end
        UpdateUI()
        SaveConfigToFile()
    end)
    
    ehESPHealthBtn.MouseButton1Click:Connect(function()
        Config.EH_ESPHealth = not Config.EH_ESPHealth
        if Config.EH_ESPHealth then EnableESP() else DisableESP() end
        UpdateUI()
        SaveConfigToFile()
    end)
    
    ehSpinBotBtn.MouseButton1Click:Connect(function()
        ToggleSpinBot()
        SaveConfigToFile()
    end)
    
    ehOGSniperBtn.MouseButton1Click:Connect(function()
        ToggleOGSniper()
        SaveConfigToFile()
    end)
    
    ehFriendsModeBtn.MouseButton1Click:Connect(function()
        Config.EH_FriendsMode = not Config.EH_FriendsMode
        UpdateUI()
        SaveConfigToFile()
    end)
    
    -- Slider SpinBot
    local function UpdateSpinSpeed(input)
        local container = sliderContainer
        local relativeX = math.clamp((input.Position.X - container.AbsolutePosition.X) / container.AbsoluteSize.X, 0, 1)
        local newSpeed = math.floor(relativeX * 1000)
        Config.EH_SpinSpeed = newSpeed
        UpdateUI()
    end
    
    sliderContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input
            dragStartPos = ehSpinSpeedSlider.Size
            UpdateSpinSpeed(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSpinSpeed(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            SaveConfigToFile()
        end
    end)
    
    -- Slider Freeze Time
    local timeDragging = false
    local function UpdateTimeSlider(input)
        local container = timeSliderContainer
        local relativeX = math.clamp((input.Position.X - container.AbsolutePosition.X) / container.AbsoluteSize.X, 0, 1)
        local newTime = relativeX * 24
        Config.FrozenTime = newTime
        if Config.FreezeTime then
            Lighting.ClockTime = newTime
        end
        UpdateUI()
    end
    
    timeSliderContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            timeDragging = true
            UpdateTimeSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if timeDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateTimeSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            timeDragging = false
            SaveConfigToFile()
        end
    end)
    
    -- Key binding
    local waitingForKey = false
    local keyToBind = nil
    
    ehKeyBtn.MouseButton1Click:Connect(function()
        if waitingForKey then return end
        waitingForKey = true
        keyToBind = "EH_Key"
        ehKeyBtn.Text = "..."
    end)
    
    interfaceKeyBtn.MouseButton1Click:Connect(function()
        if waitingForKey then return end
        waitingForKey = true
        keyToBind = "InterfaceKey"
        interfaceKeyBtn.Text = "..."
    end)
    
    -- TOGGLE AIMBOT PELA TECLA SEM ABRIR INTERFACE
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
            local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            if keyToBind == "EH_Key" then
                Config.EH_Key = keyName
            elseif keyToBind == "InterfaceKey" then
                Config.InterfaceKey = keyName
            end
            waitingForKey = false
            keyToBind = nil
            UpdateUI()
            SaveConfigToFile()
            return
        end
        
        -- Toggle interface pela tecla configurada
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            
            -- Toggle Aimbot pela tecla configurada (sem abrir interface)
            if keyName == Config.EH_Key then
                Config.EH_Enabled = not Config.EH_Enabled
                UpdateUI()
                SaveConfigToFile()
                return
            end
            
            -- Toggle Interface pela tecla configurada
            if keyName == Config.InterfaceKey then
                PanelOpen = not PanelOpen
                mainFrame.Visible = PanelOpen
                if not PanelOpen then
                    closedByX = false
                    miniButton.Visible = false
                end
            end
        end
    end)
    
    -- Add player to blocked list
    addPlayerBtn.MouseButton1Click:Connect(function()
        local playerName = addPlayerInput.Text:gsub("^%s*(.-)%s*$", "%1")
        if playerName ~= "" then
            if AddBlockedPlayer(playerName) then
                addPlayerInput.Text = ""
                UpdateBlockedPlayersList()
                SaveConfigToFile()
            end
        end
    end)
    
    -- Plastic Map
    plasticMapBtn.MouseButton1Click:Connect(function()
        ApplyPlasticMap()
    end)
    
    -- Freeze Time
    freezeTimeBtn.MouseButton1Click:Connect(function()
        ToggleFreezeTime()
        SaveConfigToFile()
    end)
    
    -- Save/Load Config
    saveBtn.MouseButton1Click:Connect(function()
        if SaveConfigToFile() then
            print("Configuracao salva!")
        else
            print("Erro ao salvar configuracao!")
        end
    end)
    
    loadBtn.MouseButton1Click:Connect(function()
        if LoadConfigFromFile() then
            if ogSniperEnabled then
                EnableNoScope()
                EnableFastSniper()
            else
                DisableNoScope()
                DisableFastSniper()
            end
            
            if Config.EH_SpinBot then
                StartSpinBot()
            else
                StopSpinBot()
            end
            
            if Config.FreezeTime then
                EnableFreezeTime()
            else
                DisableFreezeTime()
            end
            
            UpdateUI()
            print("Configuracao carregada!")
        else
            print("Erro ao carregar configuracao!")
        end
    end)
    
    -- Inicializar
    UpdateUI()
    UpdateBlockedPlayersList()
    
    -- Carregar config salva
    LoadConfigFromFile()
    
    -- Aplicar ceu salvo
    if Config.CurrentSkyId then
        ApplySky(Config.CurrentSkyId)
    end
    
    -- Iniciar SpinBot se estiver ativo
    if Config.EH_SpinBot then
        StartSpinBot()
    end
    
    -- Iniciar OG Sniper se estiver ativo
    if ogSniperEnabled then
        EnableNoScope()
        EnableFastSniper()
    end
    
    -- Iniciar Freeze Time se estiver ativo
    if Config.FreezeTime then
        EnableFreezeTime()
    end
    
    print("SPHXZ Script Carregado!")
end

-- ============================================
-- INICIALIZACAO
-- ============================================
local function Initialize()
    local cachedKey = LoadCache()
    if cachedKey then
        local ok, msg = ValidateKey(cachedKey)
        if ok then
            AuthSuccess = true
            CreateMainGUI()
            return
        else
            ClearCache()
        end
    end
    
    CreateAuthUI(function()
        CreateMainGUI()
    end)
end

Initialize()
