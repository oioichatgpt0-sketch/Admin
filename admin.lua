--[[
╔════════════════════════════════════════════════════════════════════════╗
║  gOb ADMIN SCRIPT - VERSAO FINAL COMPLETA                              ║
║  Autor: SP3CT4T0R_0 | Imagem: rbxassetid://9779422 | Have fun lol      ║
║  Original: Shackluster | Ref2: ilikeices                               ║
║  R6 + R15 + Netless + SimRadius + Crosshair 3/4 + Scanner JJS (101)    ║
╚════════════════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════════════
-- [1] CONFIGURACOES
-- ═══════════════════════════════════════════════════════════════════════
local Config = {
    UseNetless         = true,
    UseSimRadius       = true,
    SimRadiusModo      = "shp",
    SimRadiusValor     = 1e9,
    NetlessY           = 25.1,
    CrosshairSize      = 20,
    CrosshairThick     = 2,
    CrosshairAltura    = 0.25,
    GodModeAtivo       = true,
    Frame_Speed        = 1/60,
    Animation_Speed    = 3,
    DebounceSkill      = 0.5,
    LogScanner         = true,
    R15toR6            = true,
    LoadTime           = game:GetService("Players").RespawnTime + 0.5,
    AlignMode          = 2,
    -- Identidade (salvo pra uso futuro, nao usado em notificacao)
    Nick               = "SP3CT4T0R_0",
    IconeID            = "rbxassetid://9779422",
    Comentario         = "Have fun lol",
}

-- ═══════════════════════════════════════════════════════════════════════
-- [2] SERVICOS
-- ═══════════════════════════════════════════════════════════════════════
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local StarterGui        = game:GetService("StarterGui")
local TweenService      = game:GetService("TweenService")
local Debris            = game:GetService("Debris")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════
-- [3] SOUNDTRACK
-- ═══════════════════════════════════════════════════════════════════════
local Soundtrack
pcall(function()
    if not isfile("Server Admin Soundtrack.mp3") then
        writefile("Server Admin Soundtrack.mp3",
            game:HttpGet("https://github.com/gObl00x/Soundtracks/raw/refs/heads/main/Server%20Admin%20Soundtrack.mp3"))
    end
    Soundtrack = Instance.new("Sound")
    Soundtrack.SoundId = getcustomasset("Server Admin Soundtrack.mp3")
    Soundtrack.Volume  = 2
    Soundtrack.Looped  = true
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [4] CONSTANTES
-- ═══════════════════════════════════════════════════════════════════════
local IT      = Instance.new
local CF      = CFrame.new
local VT      = Vector3.new
local RAD     = math.rad
local C3      = Color3.new
local UD2     = UDim2.new
local BRICKC  = BrickColor.new
local ANGLES  = CFrame.Angles
local COS     = math.cos
local ACOS    = math.acos
local SIN     = math.sin
local ASIN    = math.asin
local ABS     = math.abs
local MRANDOM = math.random
local FLOOR   = math.floor
local V3_101  = VT(1, 0, 1)
local V3_0    = VT(0, 0, 0)
local INF     = math.huge

-- ═══════════════════════════════════════════════════════════════════════
-- [5] ESTADOS GLOBAIS
-- ═══════════════════════════════════════════════════════════════════════
local Animation_Speed = Config.Animation_Speed
local CHANGE          = 2 / Animation_Speed
local Speed           = 16
local SINE            = 0
local ATTACK          = false
local Rooted          = false
local ANIM            = "Idle"
local KEYHOLD         = false
local SC              = false
local LITTLEIDLE      = false
local INTRO           = false
local SCREENS         = {}
local SCREENWELDS     = {}
local GUISTEXT        = {}
local GLASSESWLD      = nil
local Effects
local MOVINGSCREENS   = false
local Conexoes        = {}
local ScriptAtivo     = true

local ROOTC0          = CF(0, 0, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local NECKC0          = CF(0, 1, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local RIGHTSHOULDERC0 = CF(-0.5, 0, 0) * ANGLES(RAD(0), RAD(90), RAD(0))
local LEFTSHOULDERC0  = CF(0.5, 0, 0) * ANGLES(RAD(0), RAD(-90), RAD(0))

-- Helper pra guardar conexoes
local function GuardarConexao(con)
    table.insert(Conexoes, con)
    return con
end

-- ═══════════════════════════════════════════════════════════════════════
-- [6] REFERENCIAS SEGURAS
-- ═══════════════════════════════════════════════════════════════════════
local Character, Humanoid, RootPart, Torso, Head
local RightArm, LeftArm, RightLeg, LeftLeg
local RootJoint, Neck, RightShoulder, LeftShoulder, RightHip, LeftHip
local ANIMATE, ANIMATOR

local function AtualizarReferencias(char)
    Character = char or LocalPlayer.Character
    if not Character then return end
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    RootPart = Character:FindFirstChild("HumanoidRootPart")
    Torso    = Character:FindFirstChild("Torso") or RootPart
    Head     = Character:FindFirstChild("Head")
    RightArm = Character:FindFirstChild("Right Arm")
    LeftArm  = Character:FindFirstChild("Left Arm")
    RightLeg = Character:FindFirstChild("Right Leg")
    LeftLeg  = Character:FindFirstChild("Left Leg")
    ANIMATE  = Character:FindFirstChild("Animate")
    ANIMATOR = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
    if Torso then
        RootJoint     = Torso:FindFirstChild("RootJoint")
        Neck          = Torso:FindFirstChild("Neck")
        RightShoulder = Torso:FindFirstChild("Right Shoulder")
        LeftShoulder  = Torso:FindFirstChild("Left Shoulder")
        RightHip      = Torso:FindFirstChild("Right Hip")
        LeftHip       = Torso:FindFirstChild("Left Hip")
    end
    Effects = Character:FindFirstChild("Effects")
    if not Effects and Character then
        Effects = IT("Folder", Character)
        Effects.Name = "Effects"
    end
    if Soundtrack and RootPart then Soundtrack.Parent = RootPart end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [7] CONVERSAO R15->R6 + NETLESS + SIMRADIUS
-- ═══════════════════════════════════════════════════════════════════════
local function gp(parent, name, className)
    if typeof(parent) == "Instance" then
        for _, v in pairs(parent:GetChildren()) do
            if v.Name == name and v:IsA(className) then return v end
        end
    end
    return nil
end

local function getNetlessVelocity(realVel)
    local nv = realVel * V3_101
    local mag = nv.Magnitude
    if mag > 0.1 then nv = (100 / mag) * nv end
    return VT(0, Config.NetlessY, 0) + nv
end

local function align(Part0, Part1)
    Part0.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.0001, 0.0001, 0.0001, 0.0001)
    local att0 = IT("Attachment", Part0)
    att0.Orientation = V3_0; att0.Position = V3_0; att0.Name = "att0_" .. Part0.Name
    local att1 = IT("Attachment", Part1)
    att1.Orientation = V3_0; att1.Position = V3_0; att1.Name = "att1_" .. Part1.Name
    if Config.AlignMode == 1 or Config.AlignMode == 2 then
        local ape = IT("AlignPosition", att0)
        ape.ApplyAtCenterOfMass = false; ape.MaxForce = INF; ape.MaxVelocity = INF
        ape.ReactionForceEnabled = false; ape.Responsiveness = 200
        ape.Attachment1 = att1; ape.Attachment0 = att0
        ape.Name = "AlignPositionRtrue"; ape.RigidityEnabled = true
    end
    if Config.AlignMode == 2 or Config.AlignMode == 3 then
        local apd = IT("AlignPosition", att0)
        apd.ApplyAtCenterOfMass = false; apd.MaxForce = INF; apd.MaxVelocity = INF
        apd.ReactionForceEnabled = false; apd.Responsiveness = 200
        apd.Attachment1 = att1; apd.Attachment0 = att0
        apd.Name = "AlignPositionRfalse"; apd.RigidityEnabled = false
    end
    local ao = IT("AlignOrientation", att0)
    ao.MaxAngularVelocity = INF; ao.MaxTorque = INF; ao.PrimaryAxisOnly = false
    ao.ReactionTorqueEnabled = false; ao.Responsiveness = 200
    ao.Attachment1 = att1; ao.Attachment0 = att0; ao.RigidityEnabled = false
    if Config.UseNetless then
        local realVelocity = V3_0
        local stepCon = RunService.Stepped:Connect(function() Part0.Velocity = realVelocity end)
        local hbCon = RunService.Heartbeat:Connect(function()
            realVelocity = Part0.Velocity
            Part0.Velocity = getNetlessVelocity(realVelocity)
        end)
        Part0.Destroying:Connect(function()
            stepCon:Disconnect(); hbCon:Disconnect()
        end)
    end
end

-- SimRadius
local fenv = getfenv()
if Config.UseSimRadius then
    if Config.SimRadiusModo == "shp" then
        local shp = fenv.sethiddenproperty or fenv.set_hidden_property or fenv.set_hidden_prop or fenv.sethiddenprop
        if shp then
            GuardarConexao(task.spawn(function()
                while ScriptAtivo and LocalPlayer and LocalPlayer.Parent do
                    pcall(function() shp(LocalPlayer, "SimulationRadius", Config.SimRadiusValor) end)
                    pcall(function() shp(LocalPlayer, "MaximumSimulationRadius", Config.SimRadiusValor) end)
                    RunService.Heartbeat:Wait()
                end
            end))
            print("[gOb] SimRadius ATIVO")
        end
    elseif Config.SimRadiusModo == "ssr" then
        local ssr = fenv.setsimulationradius or fenv.set_simulation_radius or fenv.set_sim_radius or fenv.setsimradius
        if ssr then
            GuardarConexao(task.spawn(function()
                while ScriptAtivo and LocalPlayer and LocalPlayer.Parent do
                    pcall(function() ssr(Config.SimRadiusValor) end)
                    RunService.Heartbeat:Wait()
                end
            end))
            print("[gOb] SimRadius (ssr) ATIVO")
        end
    end
end

local function ConverterR15R6()
    local c = LocalPlayer.Character
    if not c or not c.Parent then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.RigType ~= Enum.HumanoidRigType.R15 then return end
    print("[gOb] Convertendo R15 -> R6...")
    local part = gp(c, "HumanoidRootPart", "BasePart") or gp(c, "UpperTorso", "BasePart")
        or gp(c, "LowerTorso", "BasePart") or gp(c, "Head", "BasePart")
        or c:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local cfr = part.CFrame
    local R6parts = {
        head = { Name = "Head", Size = VT(2,1,1), R15 = { Head = 0 } },
        torso = { Name = "Torso", Size = VT(2,2,1), R15 = { UpperTorso = 0.2, LowerTorso = -0.8 } },
        root = { Name = "HumanoidRootPart", Size = VT(2,2,1), R15 = { HumanoidRootPart = 0 } },
        leftArm = { Name = "Left Arm", Size = VT(1,2,1), R15 = { LeftHand = -0.85, LeftLowerArm = -0.2, LeftUpperArm = 0.4 } },
        rightArm = { Name = "Right Arm", Size = VT(1,2,1), R15 = { RightHand = -0.85, RightLowerArm = -0.2, RightUpperArm = 0.4 } },
        leftLeg = { Name = "Left Leg", Size = VT(1,2,1), R15 = { LeftFoot = -0.85, LeftLowerLeg = -0.15, LeftUpperLeg = 0.6 } },
        rightLeg = { Name = "Right Leg", Size = VT(1,2,1), R15 = { RightFoot = -0.85, RightLowerLeg = -0.15, RightUpperLeg = 0.6 } },
    }
    for _, v in pairs(c:GetChildren()) do
        if v:IsA("BasePart") then
            for _, v1 in pairs(v:GetChildren()) do
                if v1:IsA("Motor6D") then v1.Part0 = nil end
            end
        end
    end
    part.Archivable = true
    for i, v in pairs(R6parts) do
        local newPart = part:Clone()
        newPart:ClearAllChildren()
        newPart.Name = v.Name
        newPart.Size = v.Size
        newPart.CFrame = cfr
        newPart.Anchored = false
        newPart.Transparency = 1
        newPart.CanCollide = false
        for i1, v1 in pairs(v.R15) do
            local R15part = gp(c, i1, "BasePart")
            local att = R15part and gp(R15part, "att1_" .. i1, "Attachment")
            if R15part then
                local weld = IT("Weld", R15part)
                weld.Name = "Weld_" .. i1
                weld.Part0 = newPart; weld.Part1 = R15part
                weld.C0 = CF(0, v1, 0); weld.C1 = CF(0, 0, 0)
                R15part.Massless = true
                R15part.Name = "R15_" .. i1
                R15part.Parent = newPart
                if att then att.Parent = newPart; att.Position = VT(0, v1, 0) end
            end
        end
        newPart.Parent = c
        R6parts[i] = newPart
    end
    local R6joints = {
        neck = { Parent = R6parts.torso, Name = "Neck", Part0 = R6parts.torso, Part1 = R6parts.head,
                 C0 = CF(0,1,0,-1,0,0,0,0,1,0,1,-0), C1 = CF(0,-0.5,0,-1,0,0,0,0,1,0,1,-0) },
        rootJoint = { Parent = R6parts.root, Name = "RootJoint", Part0 = R6parts.root, Part1 = R6parts.torso,
                      C0 = CF(0,0,0,-1,0,0,0,0,1,0,1,-0), C1 = CF(0,0,0,-1,0,0,0,0,1,0,1,-0) },
        rightShoulder = { Parent = R6parts.torso, Name = "Right Shoulder", Part0 = R6parts.torso, Part1 = R6parts.rightArm,
                          C0 = CF(1,0.5,0,0,0,1,0,1,-0,-1,0,0), C1 = CF(-0.5,0.5,0,0,0,1,0,1,-0,-1,0,0) },
        leftShoulder = { Parent = R6parts.torso, Name = "Left Shoulder", Part0 = R6parts.torso, Part1 = R6parts.leftArm,
                         C0 = CF(-1,0.5,0,0,0,-1,0,1,0,1,0,0), C1 = CF(0.5,0.5,0,0,0,-1,0,1,0,1,0,0) },
        rightHip = { Parent = R6parts.torso, Name = "Right Hip", Part0 = R6parts.torso, Part1 = R6parts.rightLeg,
                     C0 = CF(1,-1,0,0,0,1,0,1,-0,-1,0,0), C1 = CF(0.5,1,0,0,0,1,0,1,-0,-1,0,0) },
        leftHip = { Parent = R6parts.torso, Name = "Left Hip", Part0 = R6parts.torso, Part1 = R6parts.leftLeg,
                    C0 = CF(-1,-1,0,0,0,-1,0,1,0,1,0,0), C1 = CF(-0.5,1,0,0,0,-1,0,1,0,1,0,0) },
    }
    for i, v in pairs(R6joints) do
        local joint = IT("Motor6D")
        for prop, val in pairs(v) do joint[prop] = val end
        R6joints[i] = joint
    end
    hum.RigType = Enum.HumanoidRigType.R6
    hum.HipHeight = 0
    AtualizarReferencias(c)
    print("[gOb] R15->R6 OK!")
end

if LocalPlayer.Character then
    AtualizarReferencias(LocalPlayer.Character)
    if Config.R15toR6 then task.spawn(ConverterR15R6) end
else
    LocalPlayer.CharacterAdded:Wait(); task.wait(0.3)
    AtualizarReferencias(LocalPlayer.Character)
    if Config.R15toR6 then task.spawn(ConverterR15R6) end
end

GuardarConexao(LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    AtualizarReferencias(c)
    if Config.R15toR6 then task.spawn(ConverterR15R6) end
end))

-- ═══════════════════════════════════════════════════════════════════════
-- [8] SCANNER COM PRIORIDADE 101 (JJS) + CATEGORIA FISICA
-- ═══════════════════════════════════════════════════════════════════════
local JJS_PATTERNS = {
    "hit", "damage", "attack", "stun", "ragdoll",
    "hitbox", "connect", "velocity",
    "destroy", "break", "terrain", "debris",
    "combat", "melee", "m1", "skill", "move",
    "re_", "rem_", "event_", "action_",
}

local ScannerPalavras = {
    DANO     = { "damage","hit","attack","hurt","kill","combat","punch","slash","shoot","bullet","deal","inflict","apply","take","pvp" },
    ANIMACAO = { "anim","animation","emote","pose","movement","playanim","action","motion","gesture","dance","idle","swing" },
    EFEITO   = { "effect","visual","vfx","particle","beam","aura","glow","trail","screen","panel","hud","display","render","fx","glitch" },
    FISICA   = { "part","partdestroyed","physics","spawn","create","clone","instance","mesh","model","obj","object" },
}

local RemotesEncontrados = { DANO = {}, ANIMACAO = {}, EFEITO = {}, FISICA = {} }

local function ContemPalavra(nome, lista)
    local lower = string.lower(nome)
    for _, p in ipairs(lista) do
        if string.find(lower, p, 1, true) then return true, p end
    end
    return false, nil
end

local function CalcularScore(remote, categoria)
    local nome = string.lower(remote.Name)
    local score = 50
    -- Prioridade 101: padroes JJS
    for _, p in ipairs(JJS_PATTERNS) do
        if string.find(nome, p, 1, true) then score = 101; break end
    end
    if score == 50 then
        if string.find(nome, "deal_damage") then score = 100
        elseif string.find(nome, "takedamage") then score = 95
        elseif string.find(nome, "attack") then score = 90
        elseif string.find(nome, "damage") then score = 85
        elseif string.find(nome, "hit") then score = 80 end
    end
    return score
end

local function EscanearRemotes()
    if Config.LogScanner then print("[gOb Scanner] Iniciando...") end
    local locais = { ReplicatedStorage, Workspace, LocalPlayer }
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then table.insert(locais, pg) end
    local total = 0
    for _, l in ipairs(locais) do
        if l then
            for _, obj in ipairs(l:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("UnreliableRemoteEvent") then
                    total = total + 1
                    for cat, palavras in pairs(ScannerPalavras) do
                        local bateu, p = ContemPalavra(obj.Name, palavras)
                        if bateu then
                            table.insert(RemotesEncontrados[cat], {
                                remote = obj, nome = obj:GetFullName(),
                                palavra = p, classe = obj.ClassName,
                                score = CalcularScore(obj, cat),
                            })
                            break
                        end
                    end
                end
            end
        end
    end
    -- Ordena DANO por score (maior primeiro)
    table.sort(RemotesEncontrados.DANO, function(a,b) return a.score > b.score end)
    if Config.LogScanner then
        print(string.format("[gOb Scanner] Total: %d | DANO=%d ANIM=%d FX=%d FIS=%d",
            total, #RemotesEncontrados.DANO, #RemotesEncontrados.ANIMACAO,
            #RemotesEncontrados.EFEITO, #RemotesEncontrados.FISICA))
        -- Log top 10 DANO
        print("[gOb Scanner] TOP 10 DANO:")
        for i = 1, math.min(10, #RemotesEncontrados.DANO) do
            local e = RemotesEncontrados.DANO[i]
            print(string.format("  [%d] %s (%s)", e.score, e.nome, e.palavra))
        end
    end
end

GuardarConexao(task.spawn(function()
    task.wait(2)
    EscanearRemotes()
end))

local ultimoFire = {}
local function FiredRecent(remote, gap)
    gap = gap or 0.1
    local agora = tick()
    if ultimoFire[remote] and agora - ultimoFire[remote] < gap then return true end
    ultimoFire[remote] = agora
    return false
end

local gObServerAdminEvent
do
    local existing = ReplicatedStorage:FindFirstChild("gObServerAdminEvent")
    if existing and existing:IsA("RemoteEvent") then
        gObServerAdminEvent = existing
    else
        gObServerAdminEvent = IT("RemoteEvent")
        gObServerAdminEvent.Name = "gObServerAdminEvent"
        gObServerAdminEvent.Parent = ReplicatedStorage
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [9] CROSSHAIR 3/4 PRA CIMA
-- ═══════════════════════════════════════════════════════════════════════
local ScreenGui = IT("ScreenGui")
ScreenGui.Name = "gOb_AdminUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local crosshair = IT("Frame")
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundTransparency = 1
crosshair.Size = UDim2.new(0, Config.CrosshairSize, 0, Config.CrosshairSize)
crosshair.ZIndex = 100
crosshair.Parent = ScreenGui

local centerDot = IT("Frame")
centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
centerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
centerDot.Size = UDim2.new(0, 4, 0, 4)
centerDot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
centerDot.BorderSizePixel = 0
centerDot.ZIndex = 102
centerDot.Parent = crosshair
IT("UICorner", centerDot).CornerRadius = UDim.new(1, 0)

local function makeLine(size, pos)
    local l = IT("Frame")
    l.AnchorPoint = Vector2.new(0.5, 0.5)
    l.Position = pos; l.Size = size
    l.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    l.BackgroundTransparency = 0.2
    l.BorderSizePixel = 0; l.ZIndex = 101
    l.Parent = crosshair
end
makeLine(UDim2.new(0, Config.CrosshairThick, 0, 8), UDim2.new(0.5, 0, 0, 6))
makeLine(UDim2.new(0, Config.CrosshairThick, 0, 8), UDim2.new(0.5, 0, 1, -6))
makeLine(UDim2.new(0, 8, 0, Config.CrosshairThick), UDim2.new(0, 6, 0.5, 0))
makeLine(UDim2.new(0, 8, 0, Config.CrosshairThick), UDim2.new(1, -6, 0.5, 0))

local function updateCrosshairPos()
    local vp = Camera.ViewportSize
    crosshair.Position = UDim2.new(0, vp.X/2, 0, vp.Y * Config.CrosshairAltura)
end
updateCrosshairPos()
GuardarConexao(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCrosshairPos))

-- ═══════════════════════════════════════════════════════════════════════
-- [10] CROSSHAIR POSITION / TARGET
-- ═══════════════════════════════════════════════════════════════════════
local function GetCrosshairPosition()
    local ok, pos = pcall(function()
        local vp = Camera.ViewportSize
        local ray = Camera:ViewportPointToRay(vp.X/2, vp.Y * Config.CrosshairAltura)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = Character and {Character} or {}
        params.IgnoreWater = true
        local hit = Workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
        if hit then return hit.Position end
        return ray.Origin + ray.Direction * 500
    end)
    if ok and pos then return pos end
    return Camera.CFrame.Position + Camera.CFrame.LookVector * 100
end

local function GetCrosshairTarget()
    local ok, result = pcall(function()
        local vp = Camera.ViewportSize
        local ray = Camera:ViewportPointToRay(vp.X/2, vp.Y * Config.CrosshairAltura)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = Character and {Character} or {}
        params.IgnoreWater = true
        return Workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    end)
    if ok and result then return result.Instance, result.Position, result.Normal end
    return nil, nil, nil
end

-- ═══════════════════════════════════════════════════════════════════════
-- [11] APPLYAOE GLOBAL (ignora auto-dano + prioridade JJS)
-- ═══════════════════════════════════════════════════════════════════════
local function ApplyAoE_Global(position, damage, force, ignorarAuto)
    position = position or GetCrosshairPosition()
    damage   = damage or 50
    force    = force or 150
    ignorarAuto = ignorarAuto ~= false  -- default: true (nao se auto-atinge)

    -- 1. Dispara só nos top remotes (score alto primeiro)
    local disparados = 0
    for _, entry in ipairs(RemotesEncontrados.DANO) do
        if disparados >= 5 then break end
        if entry.score >= 80 and not FiredRecent(entry.remote, 0.1) then
            task.spawn(function()
                pcall(function()
                    if entry.classe == "RemoteFunction" then
                        entry.remote:InvokeServer(damage)
                    else
                        entry.remote:FireServer(damage)
                        task.wait(0.03)
                        entry.remote:FireServer(position, damage)
                        task.wait(0.03)
                        entry.remote:FireServer(Character, damage)
                    end
                end)
            end)
            disparados = disparados + 1
            task.wait(0.05)
        end
    end

    -- 2. Sincroniza entre clientes
    if gObServerAdminEvent then
        pcall(function()
            gObServerAdminEvent:FireServer("ApplyAoE", {Position = position, Radius = 25, Damage = damage, Force = force})
        end)
    end

    -- 3. Fallback local (pula a si mesmo se ignorarAuto)
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("Humanoid") and desc.Health > 0 then
            local isMe = (desc.Parent == Character)
            if not (ignorarAuto and isMe) then
                local root = desc.Parent and (desc.Parent:FindFirstChild("HumanoidRootPart") or desc.Parent:FindFirstChild("Torso"))
                if root and (root.Position - position).Magnitude <= 25 then
                    pcall(function() desc:TakeDamage(damage) end)
                    pcall(function() root.AssemblyLinearVelocity = (root.Position - position).Unit * force end)
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [12] GOD MODE
-- ═══════════════════════════════════════════════════════════════════════
local godConn
local function AtivarGodMode(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.MaxHealth = 9e9
    hum.Health    = 9e9
    if godConn then godConn:Disconnect() end
    godConn = GuardarConexao(RunService.RenderStepped:Connect(function()
        if Config.GodModeAtivo and hum and hum.Parent and hum.Health > 0 and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end))
end

if LocalPlayer.Character then AtivarGodMode(LocalPlayer.Character) end
GuardarConexao(LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.3); AtivarGodMode(c) end))

-- ═══════════════════════════════════════════════════════════════════════
-- [13] AUTO-DESTRUICAO AO MORRER
-- ═══════════════════════════════════════════════════════════════════════
local function Autodestruir()
    task.wait(0.3)
    ScriptAtivo = false
    print("[gOb] Morreu. Autodestruindo script...")

    -- Limpa UIs
    pcall(function() if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end end)
    pcall(function() if PlayerGui:FindFirstChild("Weapon GUI") then PlayerGui["Weapon GUI"]:Destroy() end end)

    -- Limpa efeitos
    pcall(function() if Effects and Effects.Parent then Effects:Destroy() end end)
    for _, s in ipairs(SCREENS) do pcall(function() s:Destroy() end) end
    for _, s in ipairs(SCREENWELDS) do pcall(function() s:Destroy() end) end

    -- Limpa sons
    pcall(function() if Soundtrack and Soundtrack.Parent then Soundtrack:Destroy() end end)

    -- Desconecta tudo
    for _, con in ipairs(Conexoes) do pcall(function() con:Disconnect() end) end

    pcall(function() script:Destroy() end)
end

local function InstalarAutoDestruir(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    GuardarConexao(hum.Died:Connect(Autodestruir))
end

if LocalPlayer.Character then InstalarAutoDestruir(LocalPlayer.Character) end
GuardarConexao(LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.3)
    InstalarAutoDestruir(c)
end))

