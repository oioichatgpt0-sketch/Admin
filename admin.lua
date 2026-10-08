--[[
╔════════════════════════════════════════════════════════════════════════╗
║  gOb ADMIN SCRIPT - VERSAO FINAL COMPLETA                              ║
║  Original: Shackluster | Ref2: ilikeices | Convert: gObl00x            ║
║  R6 + R15 (auto-conversao) + Netless + SimRadius + Crosshair 3/4       ║
║  Scanner de Remotes + God Mode + Mobile + Menu Fiel                    ║
║  Executor: Delta | Alvo: JJS + Natural Disaster Survival               ║
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
    AntiRagdoll        = true,
    LoadTime           = game:GetService("Players").RespawnTime + 0.5,
    Method             = 3,
    AlignMode          = 2,
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
-- [3] NOTIFICACAO INICIAL
-- ═══════════════════════════════════════════════════════════════════════
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "gOb scripts",
        Text  = "Corrigido + Scanner + God + Netless + R15->R6",
        Icon  = "rbxthumb://type=Asset&id=126389658690593&w=150&h=150",
        Duration = 15,
    })
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [4] SOUNDTRACK
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
-- [5] CONSTANTES
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
-- [6] ESTADOS GLOBAIS
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
local DISABLE_JUMP    = false
local SCREENS         = {}
local SCREENWELDS     = {}
local GUISTEXT        = {}
local GLASSESWLD      = nil
local Effects

local ROOTC0          = CF(0, 0, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local NECKC0          = CF(0, 1, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local RIGHTSHOULDERC0 = CF(-0.5, 0, 0) * ANGLES(RAD(0), RAD(90), RAD(0))
local LEFTSHOULDERC0  = CF(0.5, 0, 0) * ANGLES(RAD(0), RAD(-90), RAD(0))

-- ═══════════════════════════════════════════════════════════════════════
-- [7] REFERENCIAS SEGURAS
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
-- [8] CONVERSAO R15 -> R6 + NETLESS + SIMRADIUS
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
            Part0 = nil
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
            task.spawn(function()
                while LocalPlayer and LocalPlayer.Parent do
                    pcall(function() shp(LocalPlayer, "SimulationRadius", Config.SimRadiusValor) end)
                    pcall(function() shp(LocalPlayer, "MaximumSimulationRadius", Config.SimRadiusValor) end)
                    RunService.Heartbeat:Wait()
                end
            end)
            print("[gOb] SimRadius (shp) ATIVO")
        else
            print("[gOb] sethiddenproperty NAO disponivel")
        end
    elseif Config.SimRadiusModo == "ssr" then
        local ssr = fenv.setsimulationradius or fenv.set_simulation_radius or fenv.set_sim_radius or fenv.setsimradius
        if ssr then
            task.spawn(function()
                while LocalPlayer and LocalPlayer.Parent do
                    pcall(function() ssr(Config.SimRadiusValor) end)
                    RunService.Heartbeat:Wait()
                end
            end)
            print("[gOb] SimRadius (ssr) ATIVO")
        else
            print("[gOb] setsimulationradius NAO disponivel")
        end
    end
end

local function ConverterR15R6()
    local c = LocalPlayer.Character
    if not c or not c.Parent then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.RigType ~= Enum.HumanoidRigType.R15 then
        print("[gOb] Personagem ja e R6.")
        return
    end

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

LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    AtualizarReferencias(c)
    if Config.R15toR6 then task.spawn(ConverterR15R6) end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [9] SCANNER
-- ═══════════════════════════════════════════════════════════════════════
local ScannerPalavras = {
    DANO     = { "damage","hit","attack","hurt","kill","combat","punch","slash","shoot","bullet","deal","inflict","apply","take","pvp" },
    ANIMACAO = { "anim","animation","emote","pose","movement","playanim","action","motion","gesture","dance","idle","swing" },
    EFEITO   = { "effect","visual","vfx","particle","beam","aura","glow","trail","screen","panel","hud","display","render","fx","glitch" },
}
local RemotesEncontrados = { DANO = {}, ANIMACAO = {}, EFEITO = {} }

local function ContemPalavra(nome, lista)
    local lower = string.lower(nome)
    for _, p in ipairs(lista) do
        if string.find(lower, p, 1, true) then return true, p end
    end
    return false, nil
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
                            table.insert(RemotesEncontrados[cat], {remote = obj, nome = obj:GetFullName(), palavra = p, classe = obj.ClassName})
                            if Config.LogScanner then print(string.format("[gOb Scanner] [%s] %s (%s)", cat, obj:GetFullName(), p)) end
                            break
                        end
                    end
                end
            end
        end
    end
    if Config.LogScanner then
        print(string.format("[gOb Scanner] Total: %d | DANO=%d ANIM=%d FX=%d",
            total, #RemotesEncontrados.DANO, #RemotesEncontrados.ANIMACAO, #RemotesEncontrados.EFEITO))
    end
end

task.spawn(function()
    task.wait(2)
    EscanearRemotes()
    local total = #RemotesEncontrados.DANO + #RemotesEncontrados.ANIMACAO + #RemotesEncontrados.EFEITO
    local texto = total > 0 and string.format("DANO:%d | ANIM:%d | FX:%d | Total:%d",
        #RemotesEncontrados.DANO, #RemotesEncontrados.ANIMACAO, #RemotesEncontrados.EFEITO, total)
        or "Nenhum remote util encontrado"
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = "gOb Scanner", Text = texto, Duration = 6})
    end)
end)

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
-- [10] CROSSHAIR 3/4 PRA CIMA
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
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCrosshairPos)

-- ═══════════════════════════════════════════════════════════════════════
-- [11] CROSSHAIR POSITION / TARGET
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
-- [12] APPLYAOE GLOBAL
-- ═══════════════════════════════════════════════════════════════════════
local function ApplyAoE_Global(position, damage, force)
    position = position or GetCrosshairPosition()
    damage   = damage or 50
    force    = force or 150
    for _, entry in ipairs(RemotesEncontrados.DANO) do
        if not FiredRecent(entry.remote, 0.1) then
            pcall(function()
                if entry.classe == "RemoteFunction" then
                    entry.remote:InvokeServer(position, damage, force)
                else
                    entry.remote:FireServer(position, damage, force)
                    entry.remote:FireServer(damage)
                    entry.remote:FireServer(position)
                end
            end)
        end
    end
    if gObServerAdminEvent then
        pcall(function()
            gObServerAdminEvent:FireServer("ApplyAoE", {Position = position, Radius = 25, Damage = damage, Force = force})
        end)
    end
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("Humanoid") and desc.Health > 0 then
            local root = desc.Parent and (desc.Parent:FindFirstChild("HumanoidRootPart") or desc.Parent:FindFirstChild("Torso"))
            if root and (root.Position - position).Magnitude <= 25 then
                pcall(function() desc:TakeDamage(damage) end)
                pcall(function() root.AssemblyLinearVelocity = (root.Position - position).Unit * force end)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [13] GOD MODE
-- ═══════════════════════════════════════════════════════════════════════
local godConn
local function AtivarGodMode(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.MaxHealth = 9e9
    hum.Health    = 9e9
    if godConn then godConn:Disconnect() end
    godConn = RunService.RenderStepped:Connect(function()
        if Config.GodModeAtivo and hum and hum.Parent and hum.Health > 0 and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)
    hum.Died:Connect(function()
        if Config.GodModeAtivo then
            task.wait(0.1)
            if hum and hum.Parent then hum.Health = hum.MaxHealth end
        end
    end)
end

if LocalPlayer.Character then AtivarGodMode(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.3); AtivarGodMode(c) end)

-- ═══════════════════════════════════════════════════════════════════════
-- [14] ARTIFICIAL HEARTBEAT
-- ═══════════════════════════════════════════════════════════════════════
local ArtificialHB = IT("BindableEvent", script)
ArtificialHB.Name = "ArtificialHB"
local frame = Config.Frame_Speed
local tf = 0
local allowframeloss = false
local tossremainder = false
ArtificialHB:Fire()
RunService.Heartbeat:Connect(function(s, p)
    tf = tf + s
    if tf >= frame then
        if allowframeloss then
            ArtificialHB:Fire()
        else
            for i = 1, math.floor(tf / frame) do ArtificialHB:Fire() end
        end
        if tossremainder then tf = 0
        else tf = tf - frame * math.floor(tf / frame) end
    end
end)

local function Swait(n)
    if n == 0 or n == nil then
        ArtificialHB.Event:Wait()
    else
        for i = 1, n do ArtificialHB.Event:Wait() end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [15] FUNCOES UTILITARIAS
-- ═══════════════════════════════════════════════════════════════════════
local function Raycast(POS, DIR, RANGE, IGNORE)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = IGNORE and {IGNORE} or {}
    local hit = Workspace:Raycast(POS, DIR.Unit * RANGE, params)
    if hit then return hit.Instance, hit.Position, hit.Normal end
    return nil, nil, nil
end

local function CreatePart(formFactor, parent, material, reflectance, transparency, brickColor, name, size, anchor)
    local p = IT("Part")
    p.Reflectance  = reflectance
    p.Transparency = transparency
    p.CanCollide   = false
    p.Locked       = true
    p.Anchored     = anchor ~= false
    p.BrickColor   = BRICKC(tostring(brickColor))
    p.Name         = name
    p.Size         = size
    p.Position     = Torso and Torso.Position or VT(0,0,0)
    p.Material     = material
    p.Parent       = parent
    return p
end

local function CreateMesh(MESH, PARENT, MESHTYPE, MESHID, TEXTUREID, SCALE, OFFSET)
    local NEWMESH = IT(MESH)
    if MESH == "SpecialMesh" then
        NEWMESH.MeshType = MESHTYPE
        if MESHID and MESHID ~= "nil" and MESHID ~= "" then
            NEWMESH.MeshId = "http://www.roblox.com/asset/?id="..MESHID
        end
        if TEXTUREID and TEXTUREID ~= "nil" and TEXTUREID ~= "" then
            NEWMESH.TextureId = "http://www.roblox.com/asset/?id="..TEXTUREID
        end
    end
    NEWMESH.Offset = OFFSET or VT(0,0,0)
    NEWMESH.Scale  = SCALE
    NEWMESH.Parent = PARENT
    return NEWMESH
end

local function CreateSound(ID, PARENT, VOLUME, PITCH, DOESLOOP)
    local s = IT("Sound")
    s.Parent  = PARENT
    s.Volume  = VOLUME or 1
    s.Pitch   = PITCH or 1
    s.SoundId = "rbxassetid://"..ID
    s.Looped  = DOESLOOP == true
    s:Play()
    if not DOESLOOP then Debris:AddItem(s, 8) end
    return s
end

local function CreateFrame(PARENT, TRANSPARENCY, BORDERSIZEPIXEL, POSITION, SIZE, COLOR, BORDERCOLOR, NAME)
    local fr = IT("Frame")
    fr.BackgroundTransparency = TRANSPARENCY
    fr.BorderSizePixel = BORDERSIZEPIXEL
    fr.Position = POSITION
    fr.Size = SIZE
    fr.BackgroundColor3 = COLOR
    fr.BorderColor3 = BORDERCOLOR
    fr.Name = NAME
    fr.Parent = PARENT
    return fr
end

local function CreateLabel(PARENT, TEXT, TEXTCOLOR, TEXTFONTSIZE, TEXTFONT, TRANSPARENCY, BORDERSIZEPIXEL, STROKETRANSPARENCY, NAME)
    local l = IT("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UD2(1, 0, 1, 0)
    l.Position = UD2(0, 0, 0, 0)
    l.TextColor3 = TEXTCOLOR
    l.TextStrokeTransparency = STROKETRANSPARENCY
    l.TextTransparency = TRANSPARENCY
    l.FontSize = TEXTFONTSIZE
    l.Font = TEXTFONT
    l.BorderSizePixel = BORDERSIZEPIXEL
    l.TextScaled = false
    l.Text = TEXT
    l.Name = NAME
    l.Parent = PARENT
    return l
end

local function CreateWeldOrSnapOrMotor(TYPE, PARENT, PART0, PART1, C0, C1)
    local w = IT(TYPE)
    w.Part0 = PART0; w.Part1 = PART1
    w.C0 = C0; w.C1 = C1
    w.Parent = PARENT
    return w
end

local function QuaternionFromCFrame(cf)
    local mx, my, mz, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cf:components()
    local trace = m00 + m11 + m22
    if trace > 0 then
        local s = math.sqrt(1 + trace)
        local recip = 0.5/s
        return (m21-m12)*recip, (m02-m20)*recip, (m10-m01)*recip, s*0.5
    else
        local i = 0
        if m11 > m00 then i = 1 end
        if m22 > (i == 0 and m00 or m11) then i = 2 end
        if i == 0 then
            local s = math.sqrt(m00-m11-m22+1); local recip = 0.5/s
            return 0.5*s, (m10+m01)*recip, (m20+m02)*recip, (m21-m12)*recip
        elseif i == 1 then
            local s = math.sqrt(m11-m22-m00+1); local recip = 0.5/s
            return (m01+m10)*recip, 0.5*s, (m21+m12)*recip, (m02-m20)*recip
        else
            local s = math.sqrt(m22-m00-m11+1); local recip = 0.5/s
            return (m02+m20)*recip, (m12+m21)*recip, 0.5*s, (m10-m01)*recip
        end
    end
end

local function QuaternionToCFrame(px, py, pz, x, y, z, w)
    local xs, ys, zs = x+x, y+y, z+z
    local wx, wy, wz = w*xs, w*ys, w*zs
    local xx, xy, xz = x*xs, x*ys, x*zs
    local yy, yz, zz = y*ys, y*zs, z*zs
    return CFrame.new(px, py, pz,
        1-(yy+zz), xy-wz, xz+wy,
        xy+wz, 1-(xx+zz), yz-wx,
        xz-wy, yz+wx, 1-(xx+yy))
end

local function QuaternionSlerp(a, b, t)
    local cosTheta = a[1]*b[1] + a[2]*b[2] + a[3]*b[3] + a[4]*b[4]
    local startInterp, finishInterp
    if cosTheta >= 0.0001 then
        if (1-cosTheta) > 0.0001 then
            local theta = ACOS(cosTheta); local invSinTheta = 1/SIN(theta)
            startInterp  = SIN((1-t)*theta)*invSinTheta
            finishInterp = SIN(t*theta)*invSinTheta
        else
            startInterp, finishInterp = 1-t, t
        end
    else
        if (1+cosTheta) > 0.0001 then
            local theta = ACOS(-cosTheta); local invSinTheta = 1/SIN(theta)
            startInterp  = SIN((t-1)*theta)*invSinTheta
            finishInterp = SIN(t*theta)*invSinTheta
        else
            startInterp, finishInterp = t-1, t
        end
    end
    return a[1]*startInterp + b[1]*finishInterp, a[2]*startInterp + b[2]*finishInterp,
           a[3]*startInterp + b[3]*finishInterp, a[4]*startInterp + b[4]*finishInterp
end

local function Clerp(a, b, t)
    local qa = {QuaternionFromCFrame(a)}
    local qb = {QuaternionFromCFrame(b)}
    local ax, ay, az = a.x, a.y, a.z
    local bx, by, bz = b.x, b.y, b.z
    local _t = 1 - t
    return QuaternionToCFrame(_t*ax + t*bx, _t*ay + t*by, _t*az + t*bz, QuaternionSlerp(qa, qb, t))
end

-- ═══════════════════════════════════════════════════════════════════════
-- [16] WACKYEFFECT
-- ═══════════════════════════════════════════════════════════════════════
local function WACKYEFFECT(Table)
    local TYPE            = Table.EffectType or "Sphere"
    local SIZE            = Table.Size or VT(1,1,1)
    local ENDSIZE         = Table.Size2 or VT(0,0,0)
    local TRANSPARENCY    = Table.Transparency or 0
    local ENDTRANSPARENCY = Table.Transparency2 or 1
    local CFRAME          = Table.CFrame or (Torso and Torso.CFrame or CF(0,0,0))
    local MOVEDIRECTION   = Table.MoveToPos
    local ROTATION1       = Table.RotationX or 0
    local ROTATION2       = Table.RotationY or 0
    local ROTATION3       = Table.RotationZ or 0
    local MATERIAL        = Table.Material or "Neon"
    local COLOR           = Table.Color or C3(1,1,1)
    local TIME            = Table.Time or 45
    local SOUNDID         = Table.SoundID
    local SOUNDPITCH      = Table.SoundPitch
    local SOUNDVOLUME     = Table.SoundVolume
    local USEBOOMERANGMATH= Table.UseBoomerangMath or false
    local BOOMERANG       = Table.Boomerang or 0
    local SIZEBOOMERANG   = Table.SizeBoomerang or 0

    task.spawn(function()
        local PLAYSSOUND = false
        local EFFECT = CreatePart(3, Effects, MATERIAL, 0, TRANSPARENCY, BRICKC("Pearl"), "Effect", VT(1,1,1), true)
        if SOUNDID and SOUNDPITCH and SOUNDVOLUME then
            PLAYSSOUND = true
            CreateSound(SOUNDID, EFFECT, SOUNDVOLUME, SOUNDPITCH, false)
        end
        EFFECT.Color = COLOR
        local MSH
        if TYPE == "Sphere" then MSH = CreateMesh("SpecialMesh", EFFECT, "Sphere", "", "", SIZE, VT(0,0,0))
        elseif TYPE == "Block" or TYPE == "Box" then MSH = IT("BlockMesh", EFFECT); MSH.Scale = SIZE
        elseif TYPE == "Wave" then MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "20329976", "", SIZE, VT(0,0,-SIZE.X/8))
        elseif TYPE == "Ring" then MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "559831844", "", VT(SIZE.X,SIZE.X,0.1), VT(0,0,0))
        elseif TYPE == "Slash" then MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "662586858", "", VT(SIZE.X/10,0,SIZE.X/10), VT(0,0,0))
        elseif TYPE == "Round Slash" then MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "662585058", "", VT(SIZE.X/10,0,SIZE.X/10), VT(0,0,0))
        elseif TYPE == "Swirl" then MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "168892432", "", SIZE, VT(0,0,0))
        elseif TYPE == "Skull" then MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "4770583", "", SIZE, VT(0,0,0))
        elseif TYPE == "Crystal" then MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "9756362", "", SIZE, VT(0,0,0)) end

        if MSH then
            local BOOMR1 = 1 + BOOMERANG/50
            local BOOMR2 = 1 + SIZEBOOMERANG/50
            local MOVESPEED
            if MOVEDIRECTION then
                MOVESPEED = ((CFRAME.p - MOVEDIRECTION).Magnitude/TIME) * (USEBOOMERANGMATH and BOOMR1 or 1)
            end
            local GROWTH = USEBOOMERANGMATH and (SIZE-ENDSIZE)*(BOOMR2+1) or (SIZE-ENDSIZE)
            local TRANS  = TRANSPARENCY - ENDTRANSPARENCY
            EFFECT.CFrame = (TYPE == "Block") and
                CFRAME*ANGLES(RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360))) or CFRAME
            for LOOP = 1, TIME+1 do
                Swait()
                if USEBOOMERANGMATH then
                    MSH.Scale = MSH.Scale - VT((GROWTH.X)*((1-(LOOP/TIME)*BOOMR2)),
                        (GROWTH.Y)*((1-(LOOP/TIME)*BOOMR2)),
                        (GROWTH.Z)*((1-(LOOP/TIME)*BOOMR2)))*BOOMR2/TIME
                else MSH.Scale = MSH.Scale - GROWTH/TIME end
                if TYPE == "Wave" then MSH.Offset = VT(0,0,-MSH.Scale.Z/8) end
                EFFECT.Transparency = EFFECT.Transparency - TRANS/TIME
                if TYPE == "Block" then
                    EFFECT.CFrame = CFRAME*ANGLES(RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)))
                else EFFECT.CFrame = EFFECT.CFrame*ANGLES(RAD(ROTATION1),RAD(ROTATION2),RAD(ROTATION3)) end
                if MOVEDIRECTION then
                    local ORI = EFFECT.Orientation
                    EFFECT.CFrame = CF(EFFECT.Position, MOVEDIRECTION)*CF(0,0,-MOVESPEED)
                    EFFECT.CFrame = CF(EFFECT.Position)*ANGLES(RAD(ORI.X),RAD(ORI.Y),RAD(ORI.Z))
                end
            end
            EFFECT.Transparency = 1
            if not PLAYSSOUND then EFFECT:Destroy()
            else
                repeat Swait() until EFFECT:FindFirstChildOfClass("Sound") == nil
                EFFECT:Destroy()
            end
        else EFFECT:Destroy() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [17] DEBREE
-- ═══════════════════════════════════════════════════════════════════════
local function Debree(Table)
    local KindOf     = Table.Variant or "Ring"
    local Position   = Table.Location or (Torso and Torso.Position or VT(0,0,0))
    local Coloration = Table.Color or C3(1,1,1)
    local Texture    = Table.Material or "Slate"
    local Fling      = Table.Scatter or 1
    local Number     = Table.Amount or 1
    local Rocks      = Table.DebreeCount or 1
    local Range      = Table.Distance or 1
    local Scale      = Table.Size or 1
    local Timer      = Table.Delay or 1.5

    task.spawn(function()
        local SV = VT(Scale,Scale,Scale)
        local Boulders = {}
        Position = CF(Position)
        if KindOf == "Ring" or KindOf == "Both" then
            for RV = 1, Number do
                local LOC = Position * ANGLES(RAD(0), RAD((360/Number)*RV), RAD(0))*CF(0,MRANDOM(-math.ceil(Scale/4),math.ceil(Scale/4)),Range)
                local B = CreatePart(3, Workspace, Texture, 0, 0, BRICKC("Pearl"), "Debree", SV, true)
                B.CanCollide = true
                B.CFrame = LOC*ANGLES(RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)))
                B.Color = Coloration
                table.insert(Boulders,B)
            end
        end
        if KindOf == "Loose" or KindOf == "Both" then
            for RV = 1, Rocks do
                local LOC = Position * ANGLES(RAD(0), RAD((360/Number)*RV), RAD(0))*CF(0,MRANDOM(-math.ceil(Scale-(Scale/2)),math.ceil(Scale-(Scale/2))),0.7)
                local B = CreatePart(3, Workspace, Texture, 0, 0, BRICKC("Pearl"), "Debree", SV, false)
                B.CanCollide = true
                B.CFrame = LOC*ANGLES(RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)))
                B.Velocity = CF(B.Position-VT(0,4,0),B.CFrame*ANGLES(RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)))*CF(0,5,0).p).lookVector*MRANDOM(Fling-(Fling/1.5),Fling+(Fling/1.5))
                B.Color = Coloration
                table.insert(Boulders,B)
            end
        end
        if KindOf == "Random" then
            for RV = 1, Number do
                local LOC = Position * ANGLES(RAD(0), RAD((360/Number)*RV), RAD(0))*CF(0,MRANDOM(-math.ceil(Scale/4),math.ceil(Scale/4)),MRANDOM(0,Range))
                local B = CreatePart(3, Workspace, Texture, 0, 0, BRICKC("Pearl"), "Debree", SV, true)
                B.CanCollide = true
                B.CFrame = LOC*ANGLES(RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)))
                B.Color = Coloration
                table.insert(Boulders,B)
            end
        end
        task.wait(Timer)
        for E = 1, 45 do
            Swait()
            for A = 1, #Boulders do Boulders[A].Transparency = Boulders[A].Transparency + 1/45 end
        end
        for A = 1, #Boulders do Boulders[A]:Destroy() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [18] SCREENING
-- ═══════════════════════════════════════════════════════════════════════
local function Screening(Text, FinishesMoveEnd, WaitTillFinished)
    local ok, err = pcall(function()
        local SCREEN = CreatePart(3, Effects, "Neon", 0, 1, BRICKC("Cyan"), "SCREEN", VT(2.5,0.8,0)*1.5, false)
        local SCREENWELD = CreateWeldOrSnapOrMotor("Weld", RootPart, RootPart, SCREEN,
            CF(0,0,0) * ANGLES(RAD(-12),RAD(180),RAD(0)) * CF(0,0,1.5), CF(0,0,0))
        local GUI = IT("SurfaceGui", SCREEN)
        local FRAME = CreateFrame(GUI, 1, 2, UD2(0,0,0,0), UD2(1,0,1,0), C3(0,0,0), C3(0,0,0), "TESTING.exe")
        local TLBL = CreateLabel(FRAME, Text, C3(1,1,1), Enum.FontSize.Size48, "Code", 0.5, 1, 1, "RunningTests")
        TLBL.TextScaled = true

        task.spawn(function()
            task.spawn(function()
                for i = 1, 5 do Swait(); SCREEN.Transparency = SCREEN.Transparency - 1/5 end
            end)

            if WaitTillFinished == false then
                for i=0, 1.7, 0.1 / Animation_Speed do
                    Swait()
                    if RootJoint and Neck and RightShoulder and LeftShoulder and RightHip and LeftHip then
                        RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0-0.04*COS(SINE/24), 0, 0+0.05*COS(SINE/12)) * ANGLES(RAD(0), RAD(0-2.5*COS(SINE/24)), RAD(0)), 1/Animation_Speed)
                        Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(15-7*COS(SINE/12)), RAD(0), RAD(0)), 1/Animation_Speed)
                        RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.3,0.45+0.1*COS(SINE/12),-0.2) * ANGLES(RAD(45),RAD(0),RAD(-15)) * ANGLES(RAD(0),RAD(15),RAD(0)) * RIGHTSHOULDERC0, 1/Animation_Speed)
                        LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.1,0.35+0.1*COS(SINE/12),0.2) * ANGLES(RAD(-44-1.5*COS(SINE/12)),RAD(0),RAD(45)) * ANGLES(RAD(0),RAD(-25),RAD(0)) * LEFTSHOULDERC0, 1/Animation_Speed)
                        RightHip.C0 = Clerp(RightHip.C0, CF(1,-1+0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(85),RAD(0)) * ANGLES(RAD(-2-2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Animation_Speed)
                        LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1-0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(-85),RAD(0)) * ANGLES(RAD(-2+2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Animation_Speed)
                    end
                end
            elseif WaitTillFinished == true then
                repeat
                    Swait()
                    if RootJoint and Neck and RightShoulder and LeftShoulder and RightHip and LeftHip then
                        RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0-0.04*COS(SINE/24), 0, 0+0.05*COS(SINE/12)) * ANGLES(RAD(0), RAD(0-2.5*COS(SINE/24)), RAD(0)), 1/Animation_Speed)
                        Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(15-7*COS(SINE/12)), RAD(0), RAD(0)), 1/Animation_Speed)
                        RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.3,0.45+0.1*COS(SINE/12),-0.2) * ANGLES(RAD(45),RAD(0),RAD(-15)) * ANGLES(RAD(0),RAD(15),RAD(0)) * RIGHTSHOULDERC0, 1/Animation_Speed)
                        LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.1,0.35+0.1*COS(SINE/12),0.2) * ANGLES(RAD(-44-1.5*COS(SINE/12)),RAD(0),RAD(45)) * ANGLES(RAD(0),RAD(-25),RAD(0)) * LEFTSHOULDERC0, 1/Animation_Speed)
                        RightHip.C0 = Clerp(RightHip.C0, CF(1,-1+0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(85),RAD(0)) * ANGLES(RAD(-2-2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Animation_Speed)
                        LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1-0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(-85),RAD(0)) * ANGLES(RAD(-2+2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Animation_Speed)
                    end
                until ATTACK == false
            end

            task.spawn(function()
                if SCREENWELD then SCREENWELD:Destroy() end
                SCREEN.Anchored = true
                for i = 1, 5 do Swait(); SCREEN.Transparency = SCREEN.Transparency + 1/5 end
                if SCREEN then SCREEN:Destroy() end
            end)

            if FinishesMoveEnd == true then ATTACK = false; Rooted = false end
        end)
    end)
    if not ok then warn("[Screening]", err) end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [19] INTROTHING (voa + cai com tecla/clique/toque)
-- ═══════════════════════════════════════════════════════════════════════
local function IntroThing()
    ATTACK = true
    Rooted = true
    if RootJoint then RootJoint.C0 = CF(0, 250, 0) end

    local jaCaiu = false
    local conexao

    local function CairAgora()
        if jaCaiu then return end
        jaCaiu = true
        if conexao then conexao:Disconnect() end

        local HITFLOOR, HITPOS = Raycast(RootPart.Position,
            (CF(RootPart.Position, RootPart.Position + VT(0,-1,0))).lookVector, 4, Character)
        if HITFLOOR then
            local SOUND = CreateSound(606241996, Effects, 5, 1)
            task.spawn(function()
                repeat Swait() until SOUND.Playing == false
            end)

            -- Etapa 1: 0.4s
            for i=0, 0.4, 0.1 / Animation_Speed do
                Swait()
                if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0,-0.31,-0.65+0.05*COS(SINE/12)) * ANGLES(RAD(60),RAD(0),RAD(0)), 1/Animation_Speed) end
                if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(0-2.5*SIN(SINE/12)),RAD(0),RAD(0)), 1/Animation_Speed) end
                if RightShoulder then RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.35,0.5,-1.4) * ANGLES(RAD(65),RAD(0),RAD(-15)) * RIGHTSHOULDERC0, 1/Animation_Speed) end
                if LeftShoulder then LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0) * ANGLES(RAD(0),RAD(5),RAD(-35)) * LEFTSHOULDERC0, 1/Animation_Speed) end
                if RightHip then RightHip.C0 = Clerp(RightHip.C0, CF(1,-0.3-0.05*COS(SINE/12),-0.4) * ANGLES(RAD(20),RAD(90),RAD(0)) * ANGLES(RAD(-15),RAD(0),RAD(0)), 1/Animation_Speed) end
                if LeftHip then LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-0.1-0.05*COS(SINE/12),-0.4) * ANGLES(RAD(60),RAD(-90),RAD(0)) * ANGLES(RAD(-15),RAD(0),RAD(0)), 1/Animation_Speed) end
            end

            for i = 1, 3 do
                WACKYEFFECT({EffectType = "Wave", Size = VT(0,5,0), Size2 = VT(i*12,5,i*12),
                    Transparency = 0.6, Transparency2 = 1,
                    CFrame = CF(HITPOS) * ANGLES(RAD(0), RAD(MRANDOM(0,360)), RAD(MRANDOM(-5,5))),
                    RotationX = 0.1, RotationY = 1, RotationZ = -0.1,
                    Material = "Neon", Color = C3(1,1,1),
                    SoundID = 765590102, SoundPitch = MRANDOM(5,15)/10, SoundVolume = 5})
            end

            Debree({Delay = 4, Variant = "Ring", Location = HITPOS, Color = HITFLOOR.Color,
                Size = 3, Distance = 15, Material = HITFLOOR.Material, Scatter = 1, Amount = 30, DebreeCount = 8})

            -- Etapa 2: 0.85s
            for i=0, 0.85, 0.1 / Animation_Speed do
                Swait()
                if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0,-0.31,-0.65+0.05*COS(SINE/12)) * ANGLES(RAD(60),RAD(0),RAD(0)), 1/Animation_Speed) end
                if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(0-2.5*SIN(SINE/12)),RAD(0),RAD(0)), 1/Animation_Speed) end
                if RightShoulder then RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.35,0.5,-1.4) * ANGLES(RAD(65),RAD(0),RAD(-15)) * RIGHTSHOULDERC0, 1/Animation_Speed) end
                if LeftShoulder then LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0) * ANGLES(RAD(0),RAD(5),RAD(-35)) * LEFTSHOULDERC0, 1/Animation_Speed) end
            end

            -- Etapa 3: 1s
            for i=0, 1, 0.1 / Animation_Speed do
                Swait()
                if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0,-0.31,-0.65+0.05*COS(SINE/12)) * ANGLES(RAD(60),RAD(0),RAD(0)), 1/Animation_Speed) end
                if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(-50-2.5*SIN(SINE/12)),RAD(0),RAD(0)), 0.2/Animation_Speed) end
                if RightShoulder then RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.35,0.5,-1.4) * ANGLES(RAD(65),RAD(0),RAD(-15)) * RIGHTSHOULDERC0, 1/Animation_Speed) end
                if LeftShoulder then LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0) * ANGLES(RAD(0),RAD(5),RAD(-35)) * LEFTSHOULDERC0, 1/Animation_Speed) end
            end

            -- Etapa 4: levanta
            for i=0, 1, 0.1 / Animation_Speed do
                Swait()
                if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0,0,0) * ANGLES(RAD(0),RAD(0),RAD(0)), 1/Animation_Speed) end
                if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(45),RAD(0),RAD(-45)), 1/Animation_Speed) end
                if RightShoulder then RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.25,0.5,0.7) * ANGLES(RAD(-45),RAD(0),RAD(-45)) * RIGHTSHOULDERC0, 1/Animation_Speed) end
                if LeftShoulder then LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0) * ANGLES(RAD(0),RAD(5),RAD(0)) * LEFTSHOULDERC0, 1/Animation_Speed) end
                if RightHip then RightHip.C0 = Clerp(RightHip.C0, CF(1,-1,0) * ANGLES(RAD(0),RAD(85),RAD(0)), 1/Animation_Speed) end
                if LeftHip then LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1,0) * ANGLES(RAD(0),RAD(-85),RAD(0)), 1/Animation_Speed) end
            end

            -- Glasses
            local GLASSES = CreatePart(3, Character, "Fabric", 0, 0, BRICKC("Pearl"), "Glasses", VT(0,0,0), false)
            CreateMesh("SpecialMesh", GLASSES, "FileMesh", "1577360", "1577349", VT(1,1.3,1), VT(0,0,0))
            local HELDWELD = CreateWeldOrSnapOrMotor("Weld", RightArm, RightArm, GLASSES, CF(0,-1.4,0) * ANGLES(RAD(90),RAD(0),RAD(180)), CF(0,0,0))
            CreateSound(147722227, GLASSES, 2, 1.3, false)

            for i=0, 0.25, 0.1 / Animation_Speed do
                Swait()
                if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0,0,0), 1/Animation_Speed) end
                if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(45),RAD(0),RAD(-35)), 1/Animation_Speed) end
                if RightShoulder then RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5,0.45,-0.1) * ANGLES(RAD(30),RAD(-5),RAD(35)) * RIGHTSHOULDERC0, 1/Animation_Speed) end
            end

            for i=0, 0.3, 0.1 / Animation_Speed do
                Swait()
                HELDWELD.C1 = Clerp(HELDWELD.C1, CF(0,0,0) * ANGLES(RAD(0),RAD(0),RAD(-35)), 0.1)
            end

            HELDWELD.Part0 = Head
            HELDWELD.Parent = Head
            HELDWELD.C0 = CF(0,0.1,-0.15)
            HELDWELD.C1 = CF(0,0,0)

            for i = 1, 3 do
                for i=0, 0.4, 0.1 / Animation_Speed do
                    Swait()
                    HELDWELD.C1 = Clerp(HELDWELD.C1, CF(0,0,0) * ANGLES(RAD(0),RAD(0),RAD(-5)), 0.25)
                end
                for i=0, 0.4, 0.1 / Animation_Speed do
                    Swait()
                    HELDWELD.C1 = Clerp(HELDWELD.C1, CF(0,0,0) * ANGLES(RAD(0),RAD(0),RAD(5)), 0.25)
                end
            end

            -- Cria 4 telas rotativas
            for i = 1, 4 do
                Swait()
                local SCREEN = CreatePart(3, Effects, "Neon", 0, 1, BRICKC("Cyan"), "SCREEN", VT(2.5,0.8,0)*2, false)
                local SCREENWELD = CreateWeldOrSnapOrMotor("Weld", RootPart, RootPart, SCREEN,
                    CF(0,0,0) * ANGLES(RAD(0),RAD((360/6)*i),RAD(0)) * CF(0,0,3+(i/1.5)), CF(0,0,0))
                table.insert(SCREENS, SCREEN)
                table.insert(SCREENWELDS, SCREENWELD)
                local GUI = IT("SurfaceGui", SCREEN)
                for j = 1, 5 do
                    local FRAME = CreateFrame(GUI, 1, 2, UD2(0,0,((1/5)*j)-1/5,0), UD2(1,0,1/5,0), C3(0,0,0), C3(0,0,0), "TESTING.exe")
                    local TLBL = CreateLabel(FRAME, "[BOOTING UP...]", C3(1,1,1), Enum.FontSize.Size48, "Code", 0.5, 1, 1, "RunningTests")
                    TLBL.TextXAlignment = "Left"
                    TLBL.TextWrapped = true
                    table.insert(GUISTEXT, TLBL)
                end
            end

            for i=0, 1, 0.1 / Animation_Speed do
                Swait()
                HELDWELD.C1 = Clerp(HELDWELD.C1, CF(0,0,0) * ANGLES(RAD(0),RAD(0),RAD(0)), 0.4)
            end

            for i=0, 0.1, 0.1 / Animation_Speed do
                Swait()
                if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0,0,0), 1/Animation_Speed) end
                if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0), 1/Animation_Speed) end
                if RightShoulder then RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5,0.5,0) * ANGLES(RAD(0),RAD(-5),RAD(0)) * RIGHTSHOULDERC0, 1/Animation_Speed) end
                if LeftShoulder then LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0) * ANGLES(RAD(0),RAD(5),RAD(0)) * LEFTSHOULDERC0, 1/Animation_Speed) end
            end

            GLASSESWLD = HELDWELD
            INTRO = true
        end
        ATTACK = false
        Rooted = false
    end

    conexao = UserInputService.InputBegan:Connect(function(input, processado)
        if processado then return end
        if input.UserInputType == Enum.UserInputType.Keyboard
        or input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            CairAgora()
        end
    end)

    task.spawn(function()
        task.wait(15)
        if not jaCaiu then CairAgora() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [20] SKILLS
-- ═══════════════════════════════════════════════════════════════════════
local Fling = function()
    ATTACK = true
    Rooted = false
    Screening(";Fling", true, false)
    task.wait(0.25)
    if RightShoulder then RightShoulder.C0 = RightShoulder.C0 * CF(0,-0.12,0) end
    CreateSound(138204323, RightArm, 2, 1.3, false)

    local HITFLOOR, HITPOS = Raycast(RootPart.Position,
        (CF(RootPart.Position, RootPart.Position + VT(0,-1,0))).lookVector, 4, Character)
    if HITFLOOR then
        Debree({Delay = 4, Variant = "Ring", Location = HITPOS, Color = HITFLOOR.Color,
            Size = 4, Distance = 75, Material = HITFLOOR.Material, Scatter = 1, Amount = MRANDOM(75,85), DebreeCount = 8})
    end

    ApplyAoE_Global(RootPart.Position - VT(0,4,0), 100, 550)

    WACKYEFFECT({Time = 35, EffectType = "Sphere", Size = VT(0,0,0), Size2 = VT(150,150,150),
        Transparency = 0.75, Transparency2 = 1, CFrame = CF(RootPart.Position),
        Material = "Neon", Color = C3(1,1,1),
        SoundID = 610359590, SoundPitch = 1, SoundVolume = 6,
        UseBoomerangMath = true, SizeBoomerang = 5})
end

local TpTo = function()
    ATTACK = true
    Rooted = true

    local SCREEN = CreatePart(3, Effects, "Neon", 0, 1, BRICKC("Cyan"), "SCREEN", VT(2.5,0.8,0)*1.5, false)
    local SCREENWELD = CreateWeldOrSnapOrMotor("Weld", RootPart, RootPart, SCREEN,
        CF(0,0,0) * ANGLES(RAD(-12),RAD(180),RAD(0)) * CF(0,0,1.5), CF(0,0,0))
    local GUI = IT("SurfaceGui", SCREEN)
    local FRAME = CreateFrame(GUI, 1, 2, UD2(0,0,0,0), UD2(1,0,1,0), C3(0,0,0), C3(0,0,0), "TESTING.exe")
    local TLBL = CreateLabel(FRAME, "", C3(1,1,1), Enum.FontSize.Size48, "Code", 0.5, 1, 1, "RunningTests")
    TLBL.TextScaled = true

    for i = 1, 35 do
        Swait()
        local mira = GetCrosshairPosition()
        TLBL.Text = string.format("TPTO: [%d.%d.%d]", math.ceil(mira.X), math.ceil(mira.Y+3.15), math.ceil(mira.Z))
    end

    if RightShoulder then RightShoulder.C0 = RightShoulder.C0 * CF(0,-0.12,0) end
    CreateSound(138204323, RightArm, 2, 1.3, false)
    CreateSound(1127492102, Torso, 2, 1, false)

    local mira = GetCrosshairPosition()
    RootPart.CFrame = CF(mira + VT(0,3.15,0)) * ANGLES(RAD(0), RAD(RootPart.Orientation.Y), RAD(0))

    task.wait(0.1)
    if SCREENWELD then SCREENWELD:Destroy() end
    if SCREEN then SCREEN:Destroy() end
    ATTACK = false
    Rooted = false
end

local Hurl = function()
    ATTACK = true
    Rooted = false

    local SCREEN = CreatePart(3, Effects, "Neon", 0, 1, BRICKC("Cyan"), "SCREEN", VT(2.5,0.8,0)*1.5, false)
    local SCREENWELD = CreateWeldOrSnapOrMotor("Weld", RootPart, RootPart, SCREEN,
        CF(0,0,0) * ANGLES(RAD(-12),RAD(180),RAD(0)) * CF(0,0,1.5), CF(0,0,0))
    local GUI = IT("SurfaceGui", SCREEN)
    local FRAME = CreateFrame(GUI, 1, 2, UD2(0,0,0,0), UD2(1,0,1,0), C3(0,0,0), C3(0,0,0), "TESTING.exe")
    local TEXT = CreateLabel(FRAME, "[COLLECTING DEBREE]", C3(1,1,1), Enum.FontSize.Size48, "Code", 0.5, 1, 1, "RunningTests")
    TEXT.TextScaled = true

    local ROCKS = {}
    task.spawn(function()
        for i = 1, 5 do Swait(); SCREEN.Transparency = SCREEN.Transparency - 1/5 end
    end)

    for i = 1, 12 do
        local SPOT = CF(RootPart.Position) * ANGLES(RAD(0), RAD(MRANDOM(0,360)), RAD(0)) * CF(0,0,MRANDOM(4,15))
        local HITFLOOR, HITPOS = Raycast(RootPart.Position,
            (CF(RootPart.Position, RootPart.Position + VT(0,-1,0))).lookVector, 4, Character)
        if HITFLOOR then
            task.spawn(function()
                local B = CreatePart(3, Effects, HITFLOOR.Material, 0, 0, BRICKC("Cyan"), "Debree", VT(1,1,1)*(MRANDOM(5,25)/10), true)
                B.Color = HITFLOOR.Color
                B.CFrame = CF(HITPOS-VT(0,5,0)) * ANGLES(RAD(0), RAD(MRANDOM(0,360)), RAD(0))
                local CFRAME = SPOT*CF(0,MRANDOM(7,12),0)
                table.insert(ROCKS,B)
                for i = 1, 35 do
                    Swait()
                    if B and B.Parent then B.CFrame = Clerp(B.CFrame, CFRAME, 0.1) end
                end
            end)
        end
    end

    for i=0, 1.7, 0.1 / Animation_Speed do
        Swait()
        if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0-0.04*COS(SINE/24),0,0+0.05*COS(SINE/12)) * ANGLES(RAD(0),RAD(0-2.5*COS(SINE/24)),RAD(0)), 1/Animation_Speed) end
        if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(15-7*COS(SINE/12)),RAD(0),RAD(0)), 1/Animation_Speed) end
        if RightShoulder then RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.3,0.75+0.1*COS(SINE/12),-0.1) * ANGLES(RAD(145),RAD(0),RAD(-15)) * ANGLES(RAD(0),RAD(15),RAD(0)) * RIGHTSHOULDERC0, 1/Animation_Speed) end
        if LeftShoulder then LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.1,0.35+0.1*COS(SINE/12),0.2) * ANGLES(RAD(-44-1.5*COS(SINE/12)),RAD(0),RAD(45)) * ANGLES(RAD(0),RAD(-25),RAD(0)) * LEFTSHOULDERC0, 1/Animation_Speed) end
    end

    if #ROCKS > 0 then
        TEXT.Text = "[HURLING DEBREE]"
        local GYRO = IT("BodyGyro", RootPart)
        GYRO.D = 2; GYRO.P = 20000; GYRO.MaxTorque = VT(0,4000000,0)
        local mira = GetCrosshairPosition()
        GYRO.CFrame = CF(RootPart.Position, mira)
        task.spawn(function()
            repeat
                Swait()
                local mira2 = GetCrosshairPosition()
                GYRO.CFrame = CF(RootPart.Position, mira2)
            until ATTACK == false
            if GYRO then GYRO:Destroy() end
        end)

        local THROWING = true
        task.spawn(function()
            repeat
                Swait()
                if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0-0.04*COS(SINE/24),0,0+0.05*COS(SINE/12)) * ANGLES(RAD(0),RAD(0-2.5*COS(SINE/24)),RAD(25)), 1/Animation_Speed) end
                if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(15-7*COS(SINE/12)),RAD(0),RAD(-25)), 1/Animation_Speed) end
            until THROWING == false
        end)

        for E = 1, #ROCKS do
            task.wait(0.05)
            local ROCK = ROCKS[E]
            task.spawn(function()
                local mira = GetCrosshairPosition()
                ROCK.CFrame = CF(ROCK.Position, mira)
                CreateSound(147722227, ROCK, 2, 1.3, false)
                local KILLED = false
                for i = 1, 70 do
                    Swait()
                    for j = 1, 4 do
                        ROCK.CFrame = ROCK.CFrame * CF(0,0,-ROCK.Size.Z/2)
                        local HIT, POS = Raycast(ROCK.Position, ROCK.CFrame.lookVector, ROCK.Size.Z/1.5, Character)
                        if HIT then
                            KILLED = true
                            CreateSound(174580476, ROCK, 2, 1.6, false)
                            ApplyAoE_Global(ROCK.Position, 100, 12)
                            Debree({Delay = 0.8, Variant = "Loose", Location = ROCK.Position, Color = ROCK.Color,
                                Size = ROCK.Size.Z/3, Distance = 75, Material = ROCK.Material, Scatter = 35,
                                Amount = MRANDOM(75,85), DebreeCount = 8})
                            break
                        end
                    end
                    if KILLED then break end
                end
                if ROCK and ROCK.Parent then
                    ROCK.Transparency = 1
                    Debris:AddItem(ROCK, 5)
                end
            end)
            task.wait(0.05)
        end
        THROWING = false
    end

    task.spawn(function()
        if SCREENWELD then SCREENWELD:Destroy() end
        SCREEN.Anchored = true
        for i = 1, 5 do Swait(); SCREEN.Transparency = SCREEN.Transparency + 1/5 end
        if SCREEN then SCREEN:Destroy() end
    end)
    ATTACK = false
    Rooted = false
end

local Kill = function()
    local TARGET, HITPOS = GetCrosshairTarget()
    if not TARGET then return end
    local hum = TARGET.Parent and TARGET.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local ROOT = hum.Parent:FindFirstChild("HumanoidRootPart") or hum.Parent:FindFirstChild("Torso")
    if not ROOT then return end

    local FOE = ROOT.Parent
    ATTACK = true
    Rooted = false
    Screening(";Kill", true, false)
    task.wait(0.25)
    if RightShoulder then RightShoulder.C0 = RightShoulder.C0 * CF(0,-0.12,0) end
    CreateSound(138204323, RightArm, 2, 1.3, false)

    for _, CHILD in pairs(FOE:GetChildren()) do
        if CHILD:IsA("BasePart") then
            if CHILD.Name == "Head" then
                WACKYEFFECT({Time = MRANDOM(10,30), EffectType = "Box",
                    Size = VT(CHILD.Size.Z,CHILD.Size.Y,CHILD.Size.Z),
                    Size2 = VT(CHILD.Size.Z,CHILD.Size.Y,CHILD.Size.Z)*2,
                    Transparency = CHILD.Transparency, Transparency2 = 1,
                    CFrame = CHILD.CFrame, Material = "Neon", Color = C3(1,0,0),
                    UseBoomerangMath = true, SizeBoomerang = 0, Boomerang = 50})
            elseif CHILD.Name ~= "HumanoidRootPart" then
                WACKYEFFECT({Time = MRANDOM(10,30), EffectType = "Box",
                    Size = CHILD.Size, Size2 = CHILD.Size*2,
                    Transparency = CHILD.Transparency, Transparency2 = 1,
                    CFrame = CHILD.CFrame, Material = "Neon", Color = C3(1,0,0),
                    UseBoomerangMath = true, SizeBoomerang = 0, Boomerang = 35})
            end
        end
    end

    ApplyAoE_Global(ROOT.Position, 9e9, 0)
    pcall(function() hum.Health = 0 end)
    pcall(function() FOE:BreakJoints() end)
end

local ATTAC = function()
    ATTACK = true
    Rooted = false
    for i=0, 1, 0.1 / Animation_Speed do
        Swait()
        if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0,0,0), 1/Animation_Speed) end
        if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0), 1/Animation_Speed) end
        if RightShoulder then RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5,0.5,0) * ANGLES(RAD(0),RAD(-5),RAD(0)) * RIGHTSHOULDERC0, 1/Animation_Speed) end
        if LeftShoulder then LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0) * ANGLES(RAD(0),RAD(5),RAD(0)) * LEFTSHOULDERC0, 1/Animation_Speed) end
        if RightHip then RightHip.C0 = Clerp(RightHip.C0, CF(1,-1,0) * ANGLES(RAD(0),RAD(85),RAD(0)), 1/Animation_Speed) end
        if LeftHip then LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1,0) * ANGLES(RAD(0),RAD(-85),RAD(0)), 1/Animation_Speed) end
    end
    ATTACK = false
    Rooted = false
end

-- ═══════════════════════════════════════════════════════════════════════
-- [21] UI DE SKILLS (FIEL AO ORIGINAL + MIN/CLOSE)
-- ═══════════════════════════════════════════════════════════════════════
local WEAPONGUI = IT("ScreenGui", PlayerGui)
WEAPONGUI.Name = "Weapon GUI"
WEAPONGUI.ResetOnSpawn = false

local COLOR      = C3(1,1,1)
local SKILLFONT  = "Legacy"
local SIZE       = 2.5
local MOUSE      = 2097542191
local MELEE      = 2097543015
local BODY       = 2097543382
local PROJECTILE = 2097544084
local AOE        = 2097544884
local ULTIMATE   = 2097545381

local ATTACKS = {
    {"Switch ScreenBehaviour", "m"},
    {";Fling", "z", AOE, function() Fling() end},
    {";TpTo", "x", BODY, function() TpTo() end},
    {";Hurl", "c", PROJECTILE, function() Hurl() end},
    {";Kill", "v", MOUSE, function() Kill() end},
}

local GUIS = {}
local SkillFrames = {}

for i = 1, #ATTACKS do
    local SKILLFRAME = CreateFrame(WEAPONGUI, 0.8, 2,
        UD2(1-(0.3*(SIZE/5)), 0, 1-((0.08*(SIZE/5))*i), 0),
        UD2(0.3*(SIZE/5), 0, 0.06*(SIZE/4), 0),
        C3(0,0,0), COLOR, "Skill Frame")
    local SKILLTEXT = CreateLabel(SKILLFRAME, "["..ATTACKS[i][1].."]", COLOR, SIZE, SKILLFONT, 0, 2, 0, "Skill text")
    SKILLTEXT.TextXAlignment = "Right"
    local BUTTONDISPLAY = CreateLabel(SKILLFRAME, "["..string.upper(ATTACKS[i][2]).."]", COLOR, SIZE-1, SKILLFONT, 0, 2, 0, "Skill text")
    BUTTONDISPLAY.TextXAlignment = "Left"
    if ATTACKS[i][3] then
        local IMG = IT("ImageLabel", SKILLFRAME)
        IMG.Image = "rbxassetid://"..ATTACKS[i][3]
        IMG.Size = UD2(0.2,0,1,0)
        IMG.Position = UD2(0.065,0,0,0)
        IMG.BackgroundTransparency = 1
        IMG.ZIndex = 0
    end
    -- Touch: toca na linha executa
    SKILLFRAME.Active = true
    table.insert(SkillFrames, {frame = SKILLFRAME, data = ATTACKS[i]})
    table.insert(GUIS, SKILLTEXT)
end

-- Botao [X] e [—] no topo (linha extra acima)
local MinBtn = CreateFrame(WEAPONGUI, 0.8, 2,
    UD2(1-(0.3*(SIZE/5)), 0, 1-((0.08*(SIZE/5))*(#ATTACKS+1)), 0),
    UD2(0.3*(SIZE/5), 0, 0.06*(SIZE/4), 0),
    C3(0,0,0), COLOR, "Controls Frame")

local minLbl = CreateLabel(MinBtn, "[—] Minimizar", COLOR, SIZE-1, SKILLFONT, 0, 2, 0, "MinLbl")
minLbl.TextXAlignment = "Left"
local closeLbl = CreateLabel(MinBtn, "[X] Fechar", COLOR, SIZE-1, SKILLFONT, 0, 2, 0, "CloseLbl")
closeLbl.TextXAlignment = "Right"

-- Ativa click/touch nos frames
for _, entry in ipairs(SkillFrames) do
    entry.frame.Active = true
    local ultimoClick = 0
    entry.frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if tick() - ultimoClick < Config.DebounceSkill then return end
            ultimoClick = tick()
            -- Feedback visual
            entry.frame.BackgroundColor3 = C3(0, 0.8, 1)
            task.delay(0.15, function()
                if entry.frame and entry.frame.Parent then
                    entry.frame.BackgroundColor3 = C3(0,0,0)
                end
            end)
            -- Executa
            local nome = entry.data[1]
            if nome == "Switch ScreenBehaviour" then
                SC = not SC
            elseif ATTACK == false then
                if entry.data[4] then entry.data[4]() end
            end
        end
    end)
end

-- Click no MinBtn
MinBtn.Active = true
local minimizado = false
MinBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        minimizado = not minimizado
        for _, f in ipairs(GUIS) do if f and f.Parent then f.Visible = not minimizado end end
        for _, entry in ipairs(SkillFrames) do
            if entry.frame and entry.frame.Parent then
                entry.frame.Visible = not minimizado
            end
        end
        minLbl.Text = minimizado and "[☰] Reabrir" or "[—] Minimizar"
    end
end)

-- Fechar tudo
local fechado = false
closeLbl.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        fechado = true
        WEAPONGUI.Enabled = false
    end
end)

-- Tecla P reabre
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.P then
        fechado = not fechado
        WEAPONGUI.Enabled = not fechado
    end
end)

-- Mobile: toque no canto inferior direito reabre
UserInputService.TouchTap:Connect(function(touchPos, processado)
    if processado then return end
    if not fechado then return end
    local vp = Camera.ViewportSize
    if touchPos.X > vp.X - 100 and touchPos.Y > vp.Y - 100 then
        fechado = false
        WEAPONGUI.Enabled = true
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [22] BINDS DE TECLADO (PC)
-- ═══════════════════════════════════════════════════════════════════════
local ultimoSkill = 0
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    KEYHOLD = true
    local k = input.KeyCode
    if k == Enum.KeyCode.M then SC = not SC end
    if ATTACK then return end
    if tick() - ultimoSkill < 0.3 then return end
    ultimoSkill = tick()
    if k == Enum.KeyCode.Z then Fling()
    elseif k == Enum.KeyCode.X then TpTo()
    elseif k == Enum.KeyCode.C then Hurl()
    elseif k == Enum.KeyCode.V then Kill()
    elseif k == Enum.KeyCode.G then Config.GodModeAtivo = not Config.GodModeAtivo end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        KEYHOLD = false
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [23] LOOP PRINCIPAL DE ANIMACAO
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        Swait()
        SINE = SINE + CHANGE
        if not Character or not Character.Parent or not Humanoid or Humanoid.Health <= 0 then
            task.wait(0.5)
            continue
        end

        if ANIMATE and ANIMATE.Parent then ANIMATE.Parent = nil end
        if ANIMATOR then
            for _, v in next, Humanoid:GetPlayingAnimationTracks() do v:Stop() end
        end

        pcall(function()
            local TORSO_VEL = (RootPart.Velocity * VT(1,0,1)).Magnitude
            local TORSO_Y   = RootPart.Velocity.Y
            local HITFLOOR  = Raycast(RootPart.Position,
                (CF(RootPart.Position, RootPart.Position + VT(0,-1,0))).lookVector, 4, Character)
            local WSV = 8 / (Humanoid.WalkSpeed / 16)

            -- C1 do Walk
            if ANIM == "Walk" and TORSO_VEL > 1 and RootJoint and Neck and RightHip and LeftHip then
                RootJoint.C1 = Clerp(RootJoint.C1, ROOTC0 * CF(0,0,0.1*COS(SINE/(WSV/2))) * ANGLES(RAD(0),RAD(0),RAD(0)), 2*(Humanoid.WalkSpeed/16)/Animation_Speed)
                Neck.C1 = Clerp(Neck.C1, CF(0,-0.5,0) * ANGLES(RAD(-90),RAD(0),RAD(180)), 0.2/Animation_Speed)
                RightHip.C1 = Clerp(RightHip.C1, CF(0.5,0.875-0.125*SIN(SINE/WSV)-0.15*COS(SINE/WSV*2),0.25*SIN(SINE/WSV)) * ANGLES(RAD(0),RAD(90),RAD(0)) * ANGLES(RAD(0),RAD(0),RAD(10+50*COS(SINE/WSV))), 0.6/Animation_Speed)
                LeftHip.C1 = Clerp(LeftHip.C1, CF(-0.5,0.875+0.125*SIN(SINE/WSV)-0.15*COS(SINE/WSV*2),-0.25*SIN(SINE/WSV)) * ANGLES(RAD(0),RAD(-90),RAD(0)) * ANGLES(RAD(0),RAD(0),RAD(-10+50*COS(SINE/WSV))), 0.6/Animation_Speed)
            else
                if RootJoint then RootJoint.C1 = Clerp(RootJoint.C1, ROOTC0 * CF(0,0,0), 0.2/Animation_Speed) end
                if Neck then Neck.C1 = Clerp(Neck.C1, CF(0,-0.5,0) * ANGLES(RAD(-90),RAD(0),RAD(180)), 0.2/Animation_Speed) end
                if RightHip then RightHip.C1 = Clerp(RightHip.C1, CF(0.5,1,0) * ANGLES(RAD(0),RAD(90),RAD(0)), 0.7/Animation_Speed) end
                if LeftHip then LeftHip.C1 = Clerp(LeftHip.C1, CF(-0.5,1,0) * ANGLES(RAD(0),RAD(-90),RAD(0)), 0.7/Animation_Speed) end
            end

            -- Detecta estado
            if ATTACK == false then
                if TORSO_Y > 1 and HITFLOOR == nil then
                    ANIM = "Jump"
                    if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0,0,0) * ANGLES(RAD(-5),RAD(0),RAD(0)), 1/Animation_Speed) end
                    if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(-25),RAD(0),RAD(0)), 1/Animation_Speed) end
                elseif TORSO_Y < -1 and HITFLOOR == nil then
                    ANIM = "Fall"
                    if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0,0,0) * ANGLES(RAD(15),RAD(0),RAD(0)), 1/Animation_Speed) end
                    if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(15),RAD(0),RAD(0)), 1/Animation_Speed) end
                elseif TORSO_VEL < 1 and HITFLOOR ~= nil then
                    ANIM = "Idle"
                    if MRANDOM(1,650) == 1 and LITTLEIDLE == false and GLASSESWLD then
                        LITTLEIDLE = true
                        task.spawn(function() task.wait(3); LITTLEIDLE = false end)
                    end
                    if not LITTLEIDLE then
                        if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0-0.04*COS(SINE/24),0,0+0.05*COS(SINE/12)) * ANGLES(RAD(0),RAD(0-2.5*COS(SINE/24)),RAD(0)), 1/Animation_Speed) end
                        if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(3-7*COS(SINE/12)),RAD(0),RAD(0)), 1/Animation_Speed) end
                        if RightShoulder then RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.1,0.35+0.1*COS(SINE/12),0.2) * ANGLES(RAD(-45-1.5*COS(SINE/12)),RAD(0),RAD(-45)) * ANGLES(RAD(0),RAD(25),RAD(0)) * RIGHTSHOULDERC0, 1/Animation_Speed) end
                        if LeftShoulder then LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.1,0.35+0.1*COS(SINE/12),0.2) * ANGLES(RAD(-44-1.5*COS(SINE/12)),RAD(0),RAD(45)) * ANGLES(RAD(0),RAD(-25),RAD(0)) * LEFTSHOULDERC0, 1/Animation_Speed) end
                        if RightHip then RightHip.C0 = Clerp(RightHip.C0, CF(1,-1+0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(85),RAD(0)) * ANGLES(RAD(-2-2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Animation_Speed) end
                        if LeftHip then LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1-0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(-85),RAD(0)) * ANGLES(RAD(-2+2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Animation_Speed) end
                    end
                elseif TORSO_VEL > 1 and HITFLOOR ~= nil then
                    ANIM = "Walk"
                    if RootJoint then RootJoint.C0 = Clerp(RootJoint.C0, ROOTC0 * CF(0,0,-0.05) * ANGLES(RAD(5),RAD(0),RAD(-7*COS(SINE/WSV))), 1/Animation_Speed) end
                    if Neck then Neck.C0 = Clerp(Neck.C0, NECKC0 * CF(0,0,0) * ANGLES(RAD(5-1*SIN(SINE/(WSV/2))),RAD(0),RAD(7*COS(SINE/WSV))), 1/Animation_Speed) end
                    if RightShoulder then RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5,0.5,0) * ANGLES(RAD(60*COS(SINE/WSV)),RAD(-5),RAD(5)) * RIGHTSHOULDERC0, 1/Animation_Speed) end
                    if LeftShoulder then LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0) * ANGLES(RAD(-60*COS(SINE/WSV)),RAD(5),RAD(-5)) * LEFTSHOULDERC0, 1/Animation_Speed) end
                    if RightHip then RightHip.C0 = Clerp(RightHip.C0, CF(1,-1,0) * ANGLES(RAD(0),RAD(85),RAD(0)), 2/Animation_Speed) end
                    if LeftHip then LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1,0) * ANGLES(RAD(0),RAD(-85),RAD(0)), 2/Animation_Speed) end
                end
            end

            -- Unanchor
            for _, c in pairs(Character:GetChildren()) do
                if c:IsA("BasePart") and c ~= RootPart then c.Anchored = false end
            end
            if RootPart then RootPart.Anchored = false end

            -- Rooted (WalkSpeed 0)
            if Rooted then
                Humanoid.WalkSpeed = 0
            else
                Humanoid.WalkSpeed = Speed
            end

            -- Face customizada
            if Head and Head:FindFirstChild("face") then
                Head.face.Texture = "rbxassetid://62682458"
            end

            -- Intro
            if INTRO == false and ATTACK == false then
                INTRO = true
                task.spawn(IntroThing)
            end

            -- Controle das telas (SC)
            if #SCREENWELDS > 0 then
                if SC == true then
                    if MRANDOM(1,75) == 1 and not MOVINGSCREENS then
                        MOVINGSCREENS = true
                        task.wait(1)
                        MOVINGSCREENS = false
                        for E = 1, #SCREENWELDS do
                            task.spawn(function()
                                local M1 = MRANDOM(-25,25)/10+1
                                local M2 = MRANDOM(-45,45)
                                for i = 1, 55 do
                                    Swait()
                                    if SCREENWELDS[E] and SCREENWELDS[E].Parent then
                                        SCREENWELDS[E].C0 = Clerp(SCREENWELDS[E].C0, CF(0,M1,0) * ANGLES(RAD(0),RAD(M2+180),RAD(0)) * CF(0,0,3+(E/1.5)), 0.1)
                                    end
                                end
                            end)
                        end
                    end
                else
                    for E = 1, #SCREENWELDS do
                        if SCREENWELDS[E] and SCREENWELDS[E].Parent then
                            if E == 1 then
                                SCREENWELDS[E].C0 = Clerp(SCREENWELDS[E].C0, CF(0,-1+0.05*COS(SINE/12),0)*ANGLES(RAD(0),RAD(-40+180),RAD(0))*CF(0,0,3.4), 0.1)
                            elseif E == 2 then
                                SCREENWELDS[E].C0 = Clerp(SCREENWELDS[E].C0, CF(0,-1+0.05*SIN(SINE/12),0)*ANGLES(RAD(0),RAD(40+180),RAD(0))*CF(0,0,3.4), 0.1)
                            elseif E == 3 then
                                SCREENWELDS[E].C0 = Clerp(SCREENWELDS[E].C0, CF(0,1.3+0.05*SIN(SINE/12),0)*ANGLES(RAD(0),RAD(-38+180),RAD(0))*CF(0,0,3.4), 0.1)
                            elseif E == 4 then
                                SCREENWELDS[E].C0 = Clerp(SCREENWELDS[E].C0, CF(0,1.3+0.05*COS(SINE/12),0)*ANGLES(RAD(0),RAD(38+180),RAD(0))*CF(0,0,3.4), 0.1)
                            end
                        end
                    end
                end
                for E = 1, #SCREENS do
                    if SCREENS[E] and SCREENS[E].Parent then
                        SCREENS[E].Transparency = MRANDOM(90,99)/100
                    end
                end
            end

            -- HUD / Antivirus fake
            if #GUISTEXT > 0 then
                local dt = workspace.DistributedGameTime
                local S = math.floor(dt) % 60
                local M = math.floor(dt/60) % 60
                local H = math.floor(dt/3600)
                for E = 1, #GUISTEXT do
                    local TXT = GUISTEXT[E]
                    if E == 1 then TXT.Text = "SERVER STATS;"
                    elseif E == 2 then TXT.Text = "SERVER TIME = ["..S..":"..M..":"..H.."]"
                    elseif E == 3 then TXT.Text = "WORKSPACE GRAVITY = ["..workspace.Gravity.."]"
                    elseif E == 4 then TXT.Text = "SERVER JOBID = ["..game.JobId.."]"
                    elseif E == 5 then TXT.Text = "SERVER VERSION = ["..game.PlaceVersion.."]"
                    end
                end
                if MRANDOM(1,125) == 1 then
                    for E = 1, #GUISTEXT do
                        local TXT = GUISTEXT[E]
                        if E > 5 and E <= 15 then
                            if MRANDOM(1,3) == 1 then
                                local objs = workspace:GetChildren()
                                local alvo = objs[MRANDOM(1, #objs)]
                                if alvo then
                                    TXT.Text = ">>MONITORING; ["..alvo.Name.."]..."
                                    local MAL = {"BlurEffect","BloomEffect","Fire","ParticleEmitter","Smoke"}
                                    for _, m in ipairs(MAL) do
                                        if alvo:FindFirstChildOfClass(m) then
                                            TXT.Text = ">>!FOUND MALICIOUS CONTENT IN ["..alvo.Name.."]; FOUND: ["..m.."]"
                                            TXT.TextColor3 = C3(1,0,0)
                                            break
                                        else
                                            TXT.TextColor3 = C3(1,1,1)
                                        end
                                    end
                                end
                            end
                        elseif E > 15 then
                            local pls = Players:GetPlayers()
                            local N = E - 15
                            if N <= #pls then
                                TXT.Text = ">>MONITORING USER; ["..pls[N].Name.."]..."
                            else
                                TXT.Text = ""
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [24] SOUNDTRACK TOGGLE (Space)
-- ═══════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space and Soundtrack then
        if Soundtrack.IsPlaying then Soundtrack:Stop()
        else Soundtrack:Play() end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [25] INICIAR INTRO + PRINTS FINAIS
-- ═══════════════════════════════════════════════════════════════════════
task.wait(3)
if not INTRO and Character and Character.Parent and Humanoid and Humanoid.Health > 0 then
    task.spawn(IntroThing)
end

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "gOb Admin Script",
        Text  = "Z=Fling | X=TpTo | C=Hurl | V=Kill | M=SC | G=God | P=Painel",
        Duration = 10,
    })
end)

print("[gOb Admin] =====================================")
print("[gOb Admin] Script carregado com sucesso!")
print("[gOb Admin] God Mode: "..(Config.GodModeAtivo and "ON" or "OFF"))
print("[gOb Admin] SimRadius: "..(Config.UseSimRadius and "ATIVO" or "OFF"))
print("[gOb Admin] Netless: "..(Config.UseNetless and "ATIVO" or "OFF"))
print("[gOb Admin] Scanner: "..#RemotesEncontrados.DANO.." DANO | "..#RemotesEncontrados.ANIMACAO.." ANIM | "..#RemotesEncontrados.EFEITO.." FX")
print("[gOb Admin] Crosshair 3/4 + Mobile + Menu Fiel")
print("[gOb Admin] Otimizado para JJS e Natural Disaster Survival")
print("[gOb Admin] =====================================")

--[[
═══════════════════════════════════════════════════════════════════════
 FIM DO SCRIPT
═══════════════════════════════════════════════════════════════════════
--]]
