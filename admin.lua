--[[
╔════════════════════════════════════════════════════════════════════════╗
║  gOb ADMIN SCRIPT - VERSAO FINAL CORRIGIDA E MELHORADA                 ║
║  Original: Shackluster | Convert: gObl00x                              ║
║  Correcoes + Melhorias: Compatibilidade, Scanner de Remotes,          ║
║  Crosshair, God Mode, Mobile, Janela Arrastavel                        ║
║  Executor: Delta | Jogos alvo: JJS + Natural Disaster Survival        ║
╚════════════════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════════════
-- [1] SERVICOS
-- ═══════════════════════════════════════════════════════════════════════
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local StarterGui         = game:GetService("StarterGui")
local TweenService       = game:GetService("TweenService")
local Debris             = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════
-- [2] CONFIGURACOES
-- ═══════════════════════════════════════════════════════════════════════
local Config = {
    DamageRadius    = 25,
    DefaultDamage   = 50,
    DefaultForce    = 150,
    CrosshairSize   = 20,
    CrosshairThick  = 2,
    GodModeAtivo    = true,
    Frame_Speed     = 1/60,
    Animation_Speed = 3,
    SomenteRemotes  = false,
    LogScanner      = true,
    DebounceSkill   = 0.5,
}

-- ═══════════════════════════════════════════════════════════════════════
-- [3] NOTIFICACAO
-- ═══════════════════════════════════════════════════════════════════════
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "gOb scripts",
        Text  = "Convert by gOb | Corrigido + Scanner + God Mode",
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

-- ═══════════════════════════════════════════════════════════════════════
-- [6] REFERENCIAS SEGURAS DO PERSONAGEM
-- ═══════════════════════════════════════════════════════════════════════
local Character, Humanoid, RootPart, Torso, Head
local RightArm, LeftArm, RightLeg, LeftLeg
local RootJoint, Neck, RightShoulder, LeftShoulder, RightHip, LeftHip
local ANIMATOR, ANIMATE

local function AtualizarReferencias(char)
    Character = char or LocalPlayer.Character
    if not Character then return end
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    RootPart = Character:FindFirstChild("HumanoidRootPart")
    Torso    = Character:FindFirstChild("Torso") or RootPart
    Head     = Character:FindFirstChild("Head")
    RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightArm")
    LeftArm  = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftArm")
    RightLeg = Character:FindFirstChild("Right Leg") or Character:FindFirstChild("RightLeg")
    LeftLeg  = Character:FindFirstChild("Left Leg") or Character:FindFirstChild("LeftLeg")
    ANIMATOR = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
    ANIMATE  = Character:FindFirstChild("Animate")
    if Torso then
        RootJoint     = Torso:FindFirstChild("RootJoint")
        Neck          = Torso:FindFirstChild("Neck")
        RightShoulder = Torso:FindFirstChild("Right Shoulder")
        LeftShoulder  = Torso:FindFirstChild("Left Shoulder")
        RightHip      = Torso:FindFirstChild("Right Hip")
        LeftHip       = Torso:FindFirstChild("Left Hip")
    end
    if Soundtrack and RootPart then
        Soundtrack.Parent = RootPart
    end
end

AtualizarReferencias(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.3)
    AtualizarReferencias(c)
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [7] SCANNER INTELIGENTE DE REMOTES
-- ═══════════════════════════════════════════════════════════════════════
local ScannerPalavras = {
    DANO = {
        "damage", "hit", "attack", "hurt", "kill",
        "combat", "punch", "slash", "shoot", "bullet",
        "deal", "inflict", "apply", "take", "pvp"
    },
    ANIMACAO = {
        "anim", "animation", "emote", "pose", "movement",
        "playanim", "action", "motion", "gesture",
        "dance", "idle", "swing"
    },
    EFEITO = {
        "effect", "visual", "vfx", "particle", "beam",
        "aura", "glow", "trail", "screen", "panel",
        "hud", "display", "render", "fx", "glitch"
    }
}

local RemotesEncontrados = {
    DANO     = {},
    ANIMACAO = {},
    EFEITO   = {},
}

local function ContemPalavra(nome, lista)
    local lower = string.lower(nome)
    for _, palavra in ipairs(lista) do
        if string.find(lower, palavra, 1, true) then
            return true, palavra
        end
    end
    return false, nil
end

local function EscanearRemotes()
    if Config.LogScanner then
        print("[gOb Scanner] ============ INICIANDO ============")
    end

    local locais = { ReplicatedStorage, workspace, LocalPlayer }
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then table.insert(locais, pg) end

    local total = 0
    for _, local_ in ipairs(locais) do
        if local_ then
            for _, obj in ipairs(local_:GetDescendants()) do
                local isRemote = obj:IsA("RemoteEvent")
                    or obj:IsA("RemoteFunction")
                    or obj:IsA("UnreliableRemoteEvent")
                if isRemote then
                    total = total + 1
                    local nome = obj.Name

                    for categoria, palavras in pairs(ScannerPalavras) do
                        local bateu, palavra = ContemPalavra(nome, palavras)
                        if bateu then
                            table.insert(RemotesEncontrados[categoria], {
                                remote  = obj,
                                nome    = obj:GetFullName(),
                                palavra = palavra,
                                classe  = obj.ClassName,
                            })
                            if Config.LogScanner then
                                print(string.format("[gOb Scanner] [%s] %s (%s)",
                                    categoria, obj:GetFullName(), palavra))
                            end
                            break
                        end
                    end
                end
            end
        end
    end

    if Config.LogScanner then
        print("[gOb Scanner] Total escaneado: "..total.." remotes")
        print(string.format("[gOb Scanner] DANO=%d | ANIM=%d | EFEITO=%d",
            #RemotesEncontrados.DANO,
            #RemotesEncontrados.ANIMACAO,
            #RemotesEncontrados.EFEITO))
        print("[gOb Scanner] ====================================")
    end
end

EscanearRemotes()

-- Debounce por remote para evitar spam
local ultimoFire = {}
local function FiredRecent(remote, gap)
    gap = gap or 0.1
    local agora = tick()
    if ultimoFire[remote] and agora - ultimoFire[remote] < gap then
        return true
    end
    ultimoFire[remote] = agora
    return false
end

-- ═══════════════════════════════════════════════════════════════════════
-- [8] CROSSHAIR CENTRALIZADO
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
    l.Position = pos
    l.Size = size
    l.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    l.BackgroundTransparency = 0.2
    l.BorderSizePixel = 0
    l.ZIndex = 101
    l.Parent = crosshair
end

makeLine(UDim2.new(0, Config.CrosshairThick, 0, 8), UDim2.new(0.5, 0, 0, 6))
makeLine(UDim2.new(0, Config.CrosshairThick, 0, 8), UDim2.new(0.5, 0, 1, -6))
makeLine(UDim2.new(0, 8, 0, Config.CrosshairThick), UDim2.new(0, 6, 0.5, 0))
makeLine(UDim2.new(0, 8, 0, Config.CrosshairThick), UDim2.new(1, -6, 0.5, 0))

local function updateCrosshairPos()
    local vp = Camera.ViewportSize
    crosshair.Position = UDim2.new(0, vp.X/2, 0, vp.Y/2)
end
updateCrosshairPos()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCrosshairPos)

-- ═══════════════════════════════════════════════════════════════════════
-- [9] GETCROSSHAIRPOSITION + RAYCAST HELPER
-- ═══════════════════════════════════════════════════════════════════════
local function GetCrosshairPosition()
    local ok, pos = pcall(function()
        local vp = Camera.ViewportSize
        local ray = Camera:ViewportPointToRay(vp.X/2, vp.Y/2)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = Character and {Character} or {}
        params.IgnoreWater = true
        local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
        if hit then return hit.Position end
        return ray.Origin + ray.Direction * 500
    end)
    if ok and pos then return pos end
    return Camera.CFrame.Position + Camera.CFrame.LookVector * 100
end

local function GetCrosshairTarget()
    local ok, result = pcall(function()
        local vp = Camera.ViewportSize
        local ray = Camera:ViewportPointToRay(vp.X/2, vp.Y/2)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = Character and {Character} or {}
        params.IgnoreWater = true
        return workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    end)
    if ok and result then return result.Instance, result.Position, result.Normal end
    return nil, nil, nil
end

-- ═══════════════════════════════════════════════════════════════════════
-- [10] REMOTE EVENT PROPRIO
-- ═══════════════════════════════════════════════════════════════════════
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
-- [11] APPLYAOE GLOBAL (usa scanner)
-- ═══════════════════════════════════════════════════════════════════════
local function ApplyAoE_Global(position, damage, force)
    position = position or GetCrosshairPosition()
    damage   = damage or Config.DefaultDamage
    force    = force or Config.DefaultForce

    -- Dispara em todos os remotes de DANO encontrados
    for _, entry in ipairs(RemotesEncontrados.DANO) do
        if not FiredRecent(entry.remote, 0.1) then
            pcall(function()
                if entry.classe == "RemoteFunction" then
                    entry.remote:InvokeServer(position, damage, force)
                else
                    entry.remote:FireServer(position, damage, force)
                    entry.remote:FireServer(damage)
                    entry.remote:FireServer(position)
                    entry.remote:FireServer("ApplyAoE", {Position = position, Damage = damage, Force = force})
                end
            end)
        end
    end

    -- FireServer no nosso remote tambem (sincroniza entre clientes)
    if gObServerAdminEvent then
        pcall(function()
            gObServerAdminEvent:FireServer("ApplyAoE", {
                Position = position, Radius = Config.DamageRadius,
                Damage = damage, Force = force,
            })
        end)
    end

    -- Fallback local SEMPRE
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("Humanoid") and desc.Health > 0 then
            local root = desc.Parent and desc.Parent:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - position).Magnitude <= Config.DamageRadius then
                pcall(function() desc:TakeDamage(damage) end)
                pcall(function()
                    root.AssemblyLinearVelocity = (root.Position - position).Unit * force
                end)
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
    godConn = RunService.RenderStepped:Connect(function()
        if Config.GodModeAtivo and hum and hum.Parent and hum.Health > 0 then
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
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
LocalPlayer.CharacterAdded:Connect(AtivarGodMode)

-- ═══════════════════════════════════════════════════════════════════════
-- [13] ARTIFICIAL HEARTBEAT
-- ═══════════════════════════════════════════════════════════════════════
local ArtificialHB = IT("BindableEvent", script)
ArtificialHB.Name = "ArtificialHB"
local frame = Config.Frame_Speed
local tf = 0
local allowframeloss = false
local tossremainder = false
local lastframe = tick()
ArtificialHB:Fire()
RunService.Heartbeat:Connect(function(s, p)
    tf = tf + s
    if tf >= frame then
        if allowframeloss then
            ArtificialHB:Fire()
            lastframe = tick()
        else
            for i = 1, math.floor(tf / frame) do
                ArtificialHB:Fire()
            end
            lastframe = tick()
        end
        if tossremainder then tf = 0
        else tf = tf - frame * math.floor(tf / frame) end
    end
end)

local function Swait(n)
    if n == 0 or n == nil then
        ArtificialHB.Event:Wait()
    else
        for i = 1, n do
            ArtificialHB.Event:Wait()
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [14] FUNCOES UTILITARIAS
-- ═══════════════════════════════════════════════════════════════════════
local function Raycast(POS, DIR, RANGE, IGNORE)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = IGNORE and {IGNORE} or {}
    local hit = workspace:Raycast(POS, DIR.Unit * RANGE, params)
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
    if not DOESLOOP then Debris:AddItem(s, 5) end
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
    w.Part0 = PART0
    w.Part1 = PART1
    w.C0 = C0
    w.C1 = C1
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
            local s = math.sqrt(m00-m11-m22+1)
            local recip = 0.5/s
            return 0.5*s, (m10+m01)*recip, (m20+m02)*recip, (m21-m12)*recip
        elseif i == 1 then
            local s = math.sqrt(m11-m22-m00+1)
            local recip = 0.5/s
            return (m01+m10)*recip, 0.5*s, (m21+m12)*recip, (m02-m20)*recip
        else
            local s = math.sqrt(m22-m00-m11+1)
            local recip = 0.5/s
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
            local theta = ACOS(cosTheta)
            local invSinTheta = 1/SIN(theta)
            startInterp  = SIN((1-t)*theta)*invSinTheta
            finishInterp = SIN(t*theta)*invSinTheta
        else
            startInterp, finishInterp = 1-t, t
        end
    else
        if (1+cosTheta) > 0.0001 then
            local theta = ACOS(-cosTheta)
            local invSinTheta = 1/SIN(theta)
            startInterp  = SIN((t-1)*theta)*invSinTheta
            finishInterp = SIN(t*theta)*invSinTheta
        else
            startInterp, finishInterp = t-1, t
        end
    end
    return a[1]*startInterp + b[1]*finishInterp,
           a[2]*startInterp + b[2]*finishInterp,
           a[3]*startInterp + b[3]*finishInterp,
           a[4]*startInterp + b[4]*finishInterp
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
-- [15] PASTA DE EFEITOS
-- ═══════════════════════════════════════════════════════════════════════
local Effects = IT("Folder", Character or workspace)
Effects.Name = "Effects"

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
        if TYPE == "Sphere" then
            MSH = CreateMesh("SpecialMesh", EFFECT, "Sphere", "", "", SIZE, VT(0,0,0))
        elseif TYPE == "Block" or TYPE == "Box" then
            MSH = IT("BlockMesh", EFFECT); MSH.Scale = SIZE
        elseif TYPE == "Wave" then
            MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "20329976", "", SIZE, VT(0,0,-SIZE.X/8))
        elseif TYPE == "Ring" then
            MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "559831844", "", VT(SIZE.X,SIZE.X,0.1), VT(0,0,0))
        elseif TYPE == "Slash" then
            MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "662586858", "", VT(SIZE.X/10,0,SIZE.X/10), VT(0,0,0))
        elseif TYPE == "Round Slash" then
            MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "662585058", "", VT(SIZE.X/10,0,SIZE.X/10), VT(0,0,0))
        elseif TYPE == "Swirl" then
            MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "168892432", "", SIZE, VT(0,0,0))
        elseif TYPE == "Skull" then
            MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "4770583", "", SIZE, VT(0,0,0))
        elseif TYPE == "Crystal" then
            MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "9756362", "", SIZE, VT(0,0,0))
        end

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
                    MSH.Scale = MSH.Scale - VT(
                        (GROWTH.X)*((1-(LOOP/TIME)*BOOMR2)),
                        (GROWTH.Y)*((1-(LOOP/TIME)*BOOMR2)),
                        (GROWTH.Z)*((1-(LOOP/TIME)*BOOMR2)))*BOOMR2/TIME
                else
                    MSH.Scale = MSH.Scale - GROWTH/TIME
                end
                if TYPE == "Wave" then MSH.Offset = VT(0,0,-MSH.Scale.Z/8) end
                EFFECT.Transparency = EFFECT.Transparency - TRANS/TIME
                if TYPE == "Block" then
                    EFFECT.CFrame = CFRAME*ANGLES(RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)))
                else
                    EFFECT.CFrame = EFFECT.CFrame*ANGLES(RAD(ROTATION1),RAD(ROTATION2),RAD(ROTATION3))
                end
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
        else
            EFFECT:Destroy()
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [17] DEBREE (detritos)
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
        local ScaleVector = VT(Scale,Scale,Scale)
        local Boulders = {}
        Position = CF(Position)

        if KindOf == "Ring" or KindOf == "Both" then
            for RockValue = 1, Number do
                local LOCATION = Position * ANGLES(RAD(0), RAD((360/Number)*RockValue), RAD(0))*CF(0,MRANDOM(-math.ceil(Scale/4),math.ceil(Scale/4)),Range)
                local BOULDER = CreatePart(3, workspace, Texture, 0, 0, BRICKC("Pearl"), "Debree", ScaleVector, true)
                BOULDER.CanCollide = true
                BOULDER.CFrame = LOCATION*ANGLES(RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)))
                BOULDER.Color = Coloration
                table.insert(Boulders,BOULDER)
            end
        end
        if KindOf == "Loose" or KindOf == "Both" then
            for RockValue = 1, Rocks do
                local LOCATION = Position * ANGLES(RAD(0), RAD((360/Number)*RockValue), RAD(0))*CF(0,MRANDOM(-math.ceil(Scale-(Scale/2)),math.ceil(Scale-(Scale/2))),0.7)
                local BOULDER = CreatePart(3, workspace, Texture, 0, 0, BRICKC("Pearl"), "Debree", ScaleVector, false)
                BOULDER.CanCollide = true
                BOULDER.CFrame = LOCATION*ANGLES(RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)))
                BOULDER.Velocity = CF(BOULDER.Position-VT(0,4,0),BOULDER.CFrame*ANGLES(RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)))*CF(0,5,0).p).lookVector*MRANDOM(Fling-(Fling/1.5),Fling+(Fling/1.5))
                BOULDER.Color = Coloration
                table.insert(Boulders,BOULDER)
            end
        end
        if KindOf == "Random" then
            for RockValue = 1, Number do
                local LOCATION = Position * ANGLES(RAD(0), RAD((360/Number)*RockValue), RAD(0))*CF(0,MRANDOM(-math.ceil(Scale/4),math.ceil(Scale/4)),MRANDOM(0,Range))
                local BOULDER = CreatePart(3, workspace, Texture, 0, 0, BRICKC("Pearl"), "Debree", ScaleVector, true)
                BOULDER.CanCollide = true
                BOULDER.CFrame = LOCATION*ANGLES(RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)),RAD(MRANDOM(0,360)))
                BOULDER.Color = Coloration
                table.insert(Boulders,BOULDER)
            end
        end
        task.wait(Timer)
        for E = 1, 45 do
            Swait()
            for A = 1, #Boulders do
                Boulders[A].Transparency = Boulders[A].Transparency + 1/45
            end
        end
        for A = 1, #Boulders do Boulders[A]:Destroy() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [18] SCREENING — Painéis azuis holográficos
-- ═══════════════════════════════════════════════════════════════════════
local SC = false
local ATTACK = false
local Rooted = false
local SINE = 0
local CHANGE = 2 / Config.Animation_Speed
local LITTLEIDLE = false
local GLASSESWLD = nil
local SCREENS = {}
local SCREENWELDS = {}
local GUISTEXT = {}
local ANIM = "Idle"

local function Screening(Text, FinishesMoveEnd, WaitTillFinished)
    local ok, err = pcall(function()
        local SCREEN = CreatePart(3, Effects, "Neon", 0, 1, BRICKC("Cyan"), "SCREEN", VT(2.5,0.8,0)*1.5, false)
        local SCREENWELD = CreateWeldOrSnapOrMotor("Weld", RootPart, RootPart, SCREEN,
            CF(0,0,0) * ANGLES(RAD(-12),RAD(180),RAD(0)) * CF(0,0,1.5), CF(0,0,0))
        local GUI = IT("SurfaceGui", SCREEN)
        local SCREENFRAME = CreateFrame(GUI, 1, 2, UD2(0,0,0,0), UD2(1,0,1,0), C3(0,0,0), C3(0,0,0), "TESTING.exe")
        local TEXT = CreateLabel(SCREENFRAME, Text, C3(1,1,1), Enum.FontSize.Size48, "Code", 0.5, 1, 1, "RunningTests")
        TEXT.TextScaled = true

        task.spawn(function()
            task.spawn(function()
                for i = 1, 5 do
                    Swait()
                    SCREEN.Transparency = SCREEN.Transparency - 0.1/5
                end
            end)

            if WaitTillFinished == false then
                for i=0, 1.7, 0.1 / Config.Animation_Speed do
                    Swait()
                    if RootJoint and Neck and RightShoulder and LeftShoulder and RightHip and LeftHip then
                        RootJoint.C0 = Clerp(RootJoint.C0, CF(0-0.04*COS(SINE/24),0,0+0.05*COS(SINE/12)) * ANGLES(RAD(0), RAD(0-2.5*COS(SINE/24)), RAD(0)), 1/Config.Animation_Speed)
                        Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180)) * CF(0,0,0) * ANGLES(RAD(15-7*COS(SINE/12)), RAD(0), RAD(0)), 1/Config.Animation_Speed)
                        RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.3,0.45+0.1*COS(SINE/12),-0.2) * ANGLES(RAD(45),RAD(0),RAD(-15)) * ANGLES(RAD(0),RAD(15),RAD(0)) * CF(-0.5,0,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 1/Config.Animation_Speed)
                        LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.1,0.35+0.1*COS(SINE/12),0.2) * ANGLES(RAD(-44-1.5*COS(SINE/12)),RAD(0),RAD(45)) * ANGLES(RAD(0),RAD(-25),RAD(0)) * CF(0.5,0,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 1/Config.Animation_Speed)
                        RightHip.C0 = Clerp(RightHip.C0, CF(1,-1+0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(85),RAD(0)) * ANGLES(RAD(-2-2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                        LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1-0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(-85),RAD(0)) * ANGLES(RAD(-2+2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                    end
                end
            elseif WaitTillFinished == true then
                repeat
                    Swait()
                    if RootJoint and Neck and RightShoulder and LeftShoulder and RightHip and LeftHip then
                        RootJoint.C0 = Clerp(RootJoint.C0, CF(0-0.04*COS(SINE/24),0,0+0.05*COS(SINE/12)) * ANGLES(RAD(0), RAD(0-2.5*COS(SINE/24)), RAD(0)), 1/Config.Animation_Speed)
                        Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180)) * CF(0,0,0) * ANGLES(RAD(15-7*COS(SINE/12)), RAD(0), RAD(0)), 1/Config.Animation_Speed)
                        RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.3,0.45+0.1*COS(SINE/12),-0.2) * ANGLES(RAD(45),RAD(0),RAD(-15)) * ANGLES(RAD(0),RAD(15),RAD(0)) * CF(-0.5,0,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 1/Config.Animation_Speed)
                        LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.1,0.35+0.1*COS(SINE/12),0.2) * ANGLES(RAD(-44-1.5*COS(SINE/12)),RAD(0),RAD(45)) * ANGLES(RAD(0),RAD(-25),RAD(0)) * CF(0.5,0,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 1/Config.Animation_Speed)
                        RightHip.C0 = Clerp(RightHip.C0, CF(1,-1+0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(85),RAD(0)) * ANGLES(RAD(-2-2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                        LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1-0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(-85),RAD(0)) * ANGLES(RAD(-2+2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                    end
                until ATTACK == false
            end

            task.spawn(function()
                if SCREENWELD then SCREENWELD:Destroy() end
                SCREEN.Anchored = true
                for i = 1, 5 do
                    Swait()
                    SCREEN.Transparency = SCREEN.Transparency + 1/5
                end
                if SCREEN then SCREEN:Destroy() end
            end)

            if FinishesMoveEnd == true then
                ATTACK = false
                Rooted = false
            end
        end)
    end)
    if not ok then warn("[Screening] erro:", err) end
end

-- ═══════════════════════════════════════════════════════════════════════
-- [19] INTROTHING — Voando até apertar tecla/clicar/tocar
-- ═══════════════════════════════════════════════════════════════════════
local INTRO = false

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

            for i=0, 0.4, 0.1 / Config.Animation_Speed do
                Swait()
                if RootJoint and Neck and RightShoulder and LeftShoulder and RightHip and LeftHip then
                    RootJoint.C0 = Clerp(RootJoint.C0, CF(0,-0.31,-0.65+0.05*COS(SINE/12)) * ANGLES(RAD(60),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                    Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180)) * CF(0,0,0) * ANGLES(RAD(0-2.5*SIN(SINE/12)), RAD(0), RAD(0)), 1/Config.Animation_Speed)
                    RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.35,0.5,-1.4) * ANGLES(RAD(65),RAD(0),RAD(-15)) * CF(-0.5,0,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 1/Config.Animation_Speed)
                    LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0) * ANGLES(RAD(0),RAD(5),RAD(-35)) * CF(0.5,0,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 1/Config.Animation_Speed)
                    RightHip.C0 = Clerp(RightHip.C0, CF(1,-0.3-0.05*COS(SINE/12),-0.4) * ANGLES(RAD(20),RAD(90),RAD(0)) * ANGLES(RAD(-15),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                    LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-0.1-0.05*COS(SINE/12),-0.4) * ANGLES(RAD(60),RAD(-90),RAD(0)) * ANGLES(RAD(-15),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                end
            end

            for i = 1, 3 do
                WACKYEFFECT({EffectType = "Wave", Size = VT(0,5,0), Size2 = VT(i*12,5,i*12),
                    Transparency = 0.6, Transparency2 = 1,
                    CFrame = CF(HITPOS) * ANGLES(RAD(0), RAD(MRANDOM(0,360)), RAD(MRANDOM(-5,5))),
                    Material = "Neon", Color = C3(1,1,1),
                    SoundID = 765590102, SoundPitch = MRANDOM(5,15)/10, SoundVolume = 5})
            end

            Debree({Delay = 4, Variant = "Ring", Location = HITPOS, Color = HITFLOOR.Color,
                Size = 3, Distance = 15, Material = HITFLOOR.Material, Scatter = 1, Amount = 30, DebreeCount = 8})

            for i=0, 0.85, 0.1 / Config.Animation_Speed do
                Swait()
                if RootJoint and Neck and RightShoulder and LeftShoulder and RightHip and LeftHip then
                    RootJoint.C0 = Clerp(RootJoint.C0, CF(0,-0.31,-0.65+0.05*COS(SINE/12)) * ANGLES(RAD(60),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                    Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180)) * CF(0,0,0) * ANGLES(RAD(0-2.5*SIN(SINE/12)), RAD(0), RAD(0)), 1/Config.Animation_Speed)
                    RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.35,0.5,-1.4) * ANGLES(RAD(65),RAD(0),RAD(-15)) * CF(-0.5,0,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 1/Config.Animation_Speed)
                    LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0) * ANGLES(RAD(0),RAD(5),RAD(-35)) * CF(0.5,0,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 1/Config.Animation_Speed)
                    RightHip.C0 = Clerp(RightHip.C0, CF(1,-0.3-0.05*COS(SINE/12),-0.4) * ANGLES(RAD(20),RAD(90),RAD(0)) * ANGLES(RAD(-15),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                    LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-0.1-0.05*COS(SINE/12),-0.4) * ANGLES(RAD(60),RAD(-90),RAD(0)) * ANGLES(RAD(-15),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                end
            end

            for i=0, 1, 0.1 / Config.Animation_Speed do
                Swait()
                if RootJoint and Neck and RightShoulder and LeftShoulder and RightHip and LeftHip then
                    RootJoint.C0 = Clerp(RootJoint.C0, CF(0,-0.31,-0.65+0.05*COS(SINE/12)) * ANGLES(RAD(60),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                    Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180)) * CF(0,0,0) * ANGLES(RAD(-50-2.5*SIN(SINE/12)), RAD(0), RAD(0)), 0.2/Config.Animation_Speed)
                    RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.35,0.5,-1.4) * ANGLES(RAD(65),RAD(0),RAD(-15)) * CF(-0.5,0,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 1/Config.Animation_Speed)
                    LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0) * ANGLES(RAD(0),RAD(5),RAD(-35)) * CF(0.5,0,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 1/Config.Animation_Speed)
                    RightHip.C0 = Clerp(RightHip.C0, CF(1,-0.3-0.05*COS(SINE/12),-0.4) * ANGLES(RAD(20),RAD(90),RAD(0)) * ANGLES(RAD(-15),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                    LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-0.1-0.05*COS(SINE/12),-0.4) * ANGLES(RAD(60),RAD(-90),RAD(0)) * ANGLES(RAD(-15),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                end
            end

            -- Óculos
            local GLASSES = CreatePart(3, Character, "Fabric", 0, 0, BRICKC("Pearl"), "Glasses", VT(0,0,0), false)
            CreateMesh("SpecialMesh", GLASSES, "FileMesh", "1577360", "1577349", VT(1,1.3,1), VT(0,0,0))
            local HELDWELD = CreateWeldOrSnapOrMotor("Weld", RightArm, RightArm, GLASSES, CF(0,-1.4,0) * ANGLES(RAD(90),RAD(0),RAD(180)), CF(0,0,0))
            CreateSound(147722227, GLASSES, 2, 1.3, false)

            for i=0, 0.25, 0.1 / Config.Animation_Speed do
                Swait()
                if RootJoint and Neck and RightShoulder and LeftShoulder and RightHip and LeftHip then
                    RootJoint.C0 = Clerp(RootJoint.C0, CF(0,0,0) * ANGLES(RAD(0),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                    Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180)) * CF(0,0,0) * ANGLES(RAD(45), RAD(0), RAD(-35)), 1/Config.Animation_Speed)
                    RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5,0.45,-0.1) * ANGLES(RAD(30),RAD(-5),RAD(35)) * CF(-0.5,0,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 1/Config.Animation_Speed)
                    LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0) * ANGLES(RAD(0),RAD(5),RAD(0)) * CF(0.5,0,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 1/Config.Animation_Speed)
                    RightHip.C0 = Clerp(RightHip.C0, CF(1,-1,0) * ANGLES(RAD(0),RAD(85),RAD(0)), 1/Config.Animation_Speed)
                    LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1,0) * ANGLES(RAD(0),RAD(-85),RAD(0)), 1/Config.Animation_Speed)
                end
            end

            -- Telas rotativas
            for i = 1, 4 do
                Swait()
                local SCREEN = CreatePart(3, Effects, "Neon", 0, 1, BRICKC("Cyan"), "SCREEN", VT(2.5,0.8,0)*2, false)
                local SCREENWELD = CreateWeldOrSnapOrMotor("Weld", RootPart, RootPart, SCREEN,
                    CF(0,0,0) * ANGLES(RAD(0),RAD((360/6)*i),RAD(0)) * CF(0,0,3+(i/1.5)), CF(0,0,0))
                table.insert(SCREENS, SCREEN)
                table.insert(SCREENWELDS, SCREENWELD)
                local GUI = IT("SurfaceGui", SCREEN)
                for j = 1, 5 do
                    local SCREENFRAME = CreateFrame(GUI, 1, 2, UD2(0, 0, ((1/5)*j)-1/5, 0), UD2(1, 0, 1/5, 0), C3(0,0,0), C3(0,0,0), "TESTING.exe")
                    local TEXT = CreateLabel(SCREENFRAME, "[BOOTING UP...]", C3(1,1,1), Enum.FontSize.Size48, "Code", 0.5, 1, 1, "RunningTests")
                    TEXT.TextXAlignment = "Left"
                    TEXT.TextWrapped = true
                    table.insert(GUISTEXT, TEXT)
                end
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

    -- Timeout de seguranca (15s) — cai sozinho se ninguem tocar
    task.spawn(function()
        task.wait(15)
        if not jaCaiu then CairAgora() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [20] FLING, TPTO, HURL, KILL (com crosshair)
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
        Material = "Neon", Color = C3(1,1,1), SoundID = 610359590, SoundPitch = 1, SoundVolume = 6,
        UseBoomerangMath = true, SizeBoomerang = 5})
end

local TpTo = function()
    ATTACK = true
    Rooted = true
    local SCR, TEXT = nil, nil
    Screening("", false, true)

    -- Cria uma tela temporaria so pra mostrar coordenada
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
        for i = 1, 5 do
            Swait()
            SCREEN.Transparency = SCREEN.Transparency - 1/5
        end
    end)

    for i = 1, 12 do
        local SPOT = CF(RootPart.Position) * ANGLES(RAD(0), RAD(MRANDOM(0,360)), RAD(0)) * CF(0,0,MRANDOM(4,15))
        local HITFLOOR, HITPOS = Raycast(RootPart.Position,
            (CF(RootPart.Position, RootPart.Position + VT(0,-1,0))).lookVector, 4, Character)
        if HITFLOOR then
            task.spawn(function()
                local BOULDER = CreatePart(3, Effects, HITFLOOR.Material, 0, 0, BRICKC("Cyan"), "Debree",
                    VT(1,1,1)*(MRANDOM(5,25)/10), true)
                BOULDER.Color = HITFLOOR.Color
                BOULDER.CFrame = CF(HITPOS-VT(0,5,0)) * ANGLES(RAD(0), RAD(MRANDOM(0,360)), RAD(0))
                local CFRAME = SPOT*CF(0,MRANDOM(7,12),0)
                table.insert(ROCKS, BOULDER)
                for i = 1, 35 do
                    Swait()
                    if BOULDER and BOULDER.Parent then
                        BOULDER.CFrame = Clerp(BOULDER.CFrame, CFRAME, 0.1)
                    end
                end
            end)
        end
    end

    for i=0, 1.7, 0.1 / Config.Animation_Speed do
        Swait()
        if RootJoint and Neck and RightShoulder and LeftShoulder and RightHip and LeftHip then
            RootJoint.C0 = Clerp(RootJoint.C0, CF(0-0.04*COS(SINE/24),0,0+0.05*COS(SINE/12)) * ANGLES(RAD(0),RAD(0-2.5*COS(SINE/24)),RAD(0)), 1/Config.Animation_Speed)
            Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180)) * CF(0,0,0) * ANGLES(RAD(15-7*COS(SINE/12)), RAD(0), RAD(0)), 1/Config.Animation_Speed)
            RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.3,0.75+0.1*COS(SINE/12),-0.1) * ANGLES(RAD(145),RAD(0),RAD(-15)) * ANGLES(RAD(0),RAD(15),RAD(0)) * CF(-0.5,0,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 1/Config.Animation_Speed)
            LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.1,0.35+0.1*COS(SINE/12),0.2) * ANGLES(RAD(-44-1.5*COS(SINE/12)),RAD(0),RAD(45)) * ANGLES(RAD(0),RAD(-25),RAD(0)) * CF(0.5,0,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 1/Config.Animation_Speed)
            RightHip.C0 = Clerp(RightHip.C0, CF(1,-1+0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(85),RAD(0)) * ANGLES(RAD(-2-2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Config.Animation_Speed)
            LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1-0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(-85),RAD(0)) * ANGLES(RAD(-2+2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Config.Animation_Speed)
        end
    end

    if #ROCKS > 0 then
        TEXT.Text = "[HURLING DEBREE]"
        local GYRO = IT("BodyGyro", RootPart)
        GYRO.D = 2
        GYRO.P = 20000
        GYRO.MaxTorque = VT(0,4000000,0)
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
                if RootJoint and Neck and RightShoulder and LeftShoulder and RightHip and LeftHip then
                    RootJoint.C0 = Clerp(RootJoint.C0, CF(0-0.04*COS(SINE/24),0,0+0.05*COS(SINE/12)) * ANGLES(RAD(0),RAD(0-2.5*COS(SINE/24)),RAD(25)), 1/Config.Animation_Speed)
                    Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180)) * CF(0,0,0) * ANGLES(RAD(15-7*COS(SINE/12)), RAD(0), RAD(-25)), 1/Config.Animation_Speed)
                    RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.3,0.45+0.1*COS(SINE/12),-0.2) * ANGLES(RAD(90),RAD(0),RAD(25)) * CF(-0.5,0,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 1/Config.Animation_Speed)
                    LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.3,0.45+0.1*COS(SINE/12),-0.2) * ANGLES(RAD(44-1.5*COS(SINE/12)),RAD(0),RAD(25)) * CF(0.5,0,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 1/Config.Animation_Speed)
                    RightHip.C0 = Clerp(RightHip.C0, CF(1,-1+0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(50),RAD(0)) * ANGLES(RAD(-2-2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                    LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1-0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(-100),RAD(0)) * ANGLES(RAD(-2+2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                end
            until THROWING == false
        end)

        for E = 1, #ROCKS do
            task.wait(0.05)
            local ROCK = ROCKS[E]
            task.spawn(function()
                local mira3 = GetCrosshairPosition()
                ROCK.CFrame = CF(ROCK.Position, mira3)
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
                            for E2 = 1, 2 do
                                for k = 1, 4 do
                                    WACKYEFFECT({Time = 50, EffectType = "Round Slash",
                                        Size = VT(0,0,0), Size2 = (VT(E2,0,E2)/15)*ROCK.Size.Z,
                                        Transparency = 0.8, Transparency2 = 1,
                                        CFrame = CF(ROCK.Position) * ANGLES(RAD(MRANDOM(0,360)), RAD(MRANDOM(0,360)), RAD(MRANDOM(0,360))),
                                        Material = "Neon", Color = C3(1,1,1),
                                        UseBoomerangMath = true, SizeBoomerang = 10})
                                end
                            end
                            Debree({Delay = 0.8, Variant = "Loose", Location = ROCK.Position, Color = ROCK.Color,
                                Size = ROCK.Size.Z/3, Distance = 75, Material = ROCK.Material, Scatter = 35,
                                Amount = MRANDOM(75,85), DebreeCount = 8})
                            break
                        else
                            WACKYEFFECT({Time = 6, EffectType = "Wave", Size = VT(0,0,0), Size2 = VT(3,1,3)*ROCK.Size.Z,
                                Transparency = 0.97, Transparency2 = 1,
                                CFrame = ROCK.CFrame*CF(0,0,-ROCK.Size.Z/2) * ANGLES(RAD(90), RAD(MRANDOM(0,360)), RAD(MRANDOM(-5,5))),
                                RotationX = MRANDOM(-1,1), RotationY = MRANDOM(-1,1), RotationZ = MRANDOM(-1,1),
                                Material = "Neon", Color = BRICKC("Cyan").Color,
                                SoundPitch = MRANDOM(5,15)/10, SoundVolume = 5,
                                UseBoomerangMath = true, SizeBoomerang = 25})
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
        for i = 1, 5 do
            Swait()
            SCREEN.Transparency = SCREEN.Transparency + 1/5
        end
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

-- ═══════════════════════════════════════════════════════════════════════
-- [21] UI DE SKILLS + JANELA ARRASTÁVEL
-- ═══════════════════════════════════════════════════════════════════════
local MainFrame = IT("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(1, 1)
MainFrame.Position = UDim2.new(1, -20, 1, -20)
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.ZIndex = 90
MainFrame.Parent = ScreenGui
IT("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local stroke = IT("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(80, 80, 90)
stroke.Thickness = 1.5

-- Barra de titulo (draggable)
local TitleBar = IT("TextButton")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Text = ""
TitleBar.AutoButtonColor = false
TitleBar.Active = true
TitleBar.ZIndex = 95
TitleBar.Parent = MainFrame
IT("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = IT("TextLabel")
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "⚙ ADMIN PANEL"
TitleLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 96
TitleLabel.Parent = TitleBar

-- Botao minimizar
local MinBtn = IT("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -52, 0, 3)
MinBtn.BackgroundColor3 = Color3.fromRGB(200, 180, 60)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.ZIndex = 96
MinBtn.Parent = TitleBar
IT("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Botao fechar
local CloseBtn = IT("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -26, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.ZIndex = 96
CloseBtn.Parent = TitleBar
IT("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Conteudo (scroll)
local ContentFrame = IT("ScrollingFrame")
ContentFrame.Name = "Content"
ContentFrame.Position = UDim2.new(0, 0, 0, 32)
ContentFrame.Size = UDim2.new(1, 0, 1, -32)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 130)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ContentFrame.ZIndex = 91
ContentFrame.Parent = MainFrame

local UIListLayout = IT("UIListLayout", ContentFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 3)

-- Secoes
local function CriarSecao(titulo)
    local sec = IT("Frame")
    sec.Size = UDim2.new(1, -16, 0, 22)
    sec.BackgroundTransparency = 1
    sec.ZIndex = 92
    sec.Parent = ContentFrame

    local lbl = IT("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = titulo
    lbl.TextColor3 = Color3.fromRGB(255, 200, 100)
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 93
    lbl.Parent = sec
    return sec
end

-- Stats
CriarSecao("▸ SERVER STATS")
local statLabel = IT("TextLabel")
statLabel.Size = UDim2.new(1, -16, 0, 45)
statLabel.BackgroundTransparency = 1
statLabel.Font = Enum.Font.Code
statLabel.Text = "Carregando..."
statLabel.TextColor3 = Color3.fromRGB(200, 220, 200)
statLabel.TextSize = 10
statLabel.TextXAlignment = Enum.TextXAlignment.Left
statLabel.TextYAlignment = Enum.TextYAlignment.Top
statLabel.TextWrapped = true
statLabel.ZIndex = 92
statLabel.Parent = ContentFrame

-- Skills
CriarSecao("▸ SKILLS")

local SkillsData = {
    {nome = ";Fling",    tecla = "Z", icone = "rbxthumb://type=Asset&id=2097544884&w=150&h=150", func = nil},
    {nome = ";TpTo",     tecla = "X", icone = "rbxthumb://type=Asset&id=2097543382&w=150&h=150", func = nil},
    {nome = ";Hurl",     tecla = "C", icone = "rbxthumb://type=Asset&id=2097544084&w=150&h=150", func = nil},
    {nome = ";Kill",     tecla = "V", icone = "rbxthumb://type=Asset&id=2097542191&w=150&h=150", func = nil},
    {nome = "Toggle SC", tecla = "M", icone = "rbxthumb://type=Asset&id=2097545381&w=150&h=150", func = function()
        SC = not SC
    end},
}

local SkillLinhas = {}

local function CriarSkillLinha(data, idx)
    local linha = IT("TextButton")
    linha.Name = "Skill_"..idx
    linha.Size = UDim2.new(1, -16, 0, 30)
    linha.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    linha.BackgroundTransparency = 0.3
    linha.BorderSizePixel = 0
    linha.Text = ""
    linha.AutoButtonColor = true
    linha.ZIndex = 92
    linha.Parent = ContentFrame
    IT("UICorner", linha).CornerRadius = UDim.new(0, 6)

    local icone = IT("ImageLabel")
    icone.Size = UDim2.new(0, 22, 0, 22)
    icone.Position = UDim2.new(0, 6, 0, 4)
    icone.BackgroundTransparency = 1
    icone.Image = data.icone
    icone.ZIndex = 93
    icone.Parent = linha

    local nomeLbl = IT("TextLabel")
    nomeLbl.BackgroundTransparency = 1
    nomeLbl.Position = UDim2.new(0, 34, 0, 0)
    nomeLbl.Size = UDim2.new(1, -75, 1, 0)
    nomeLbl.Font = Enum.Font.Gotham
    nomeLbl.Text = data.nome
    nomeLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nomeLbl.TextSize = 12
    nomeLbl.TextXAlignment = Enum.TextXAlignment.Left
    nomeLbl.ZIndex = 93
    nomeLbl.Parent = linha

    local tecla = IT("TextLabel")
    tecla.BackgroundTransparency = 1
    tecla.Position = UDim2.new(1, -38, 0, 0)
    tecla.Size = UDim2.new(0, 32, 1, 0)
    tecla.Font = Enum.Font.Code
    tecla.Text = "["..data.tecla.."]"
    tecla.TextColor3 = Color3.fromRGB(180, 180, 190)
    tecla.TextSize = 12
    tecla.TextXAlignment = Enum.TextXAlignment.Center
    tecla.ZIndex = 93
    tecla.Parent = linha

    table.insert(SkillLinhas, {linha = linha, data = data, nomeLbl = nomeLbl})

    local ultimo = 0
    linha.MouseButton1Click:Connect(function()
        if tick() - ultimo < Config.DebounceSkill then return end
        ultimo = tick()
        -- Feedback visual
        linha.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        task.delay(0.2, function()
            if linha and linha.Parent then
                linha.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
        end)
        if data.func then data.func() end
    end)
end

for i, data in ipairs(SkillsData) do
    CriarSkillLinha(data, i)
end

-- Status
CriarSecao("▸ STATUS")
local statusLabel = IT("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Code
statusLabel.Text = "God: ON | SC: OFF"
statusLabel.TextColor3 = Color3.fromRGB(140, 220, 160)
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.TextWrapped = true
statusLabel.ZIndex = 92
statusLabel.Parent = ContentFrame

-- Botoes rodape
CriarSecao("▸ ACOES")
local BtnRow = IT("Frame")
BtnRow.Size = UDim2.new(1, -16, 0, 30)
BtnRow.BackgroundTransparency = 1
BtnRow.ZIndex = 92
BtnRow.Parent = ContentFrame

local function CriarBotao(texto, cor, parent, xoffset, woffset)
    local b = IT("TextButton")
    b.Size = UDim2.new(0.32, 0, 1, 0)
    b.Position = UDim2.new(xoffset, 0, 0, 0)
    b.BackgroundColor3 = cor
    b.BorderSizePixel = 0
    b.Text = texto
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.ZIndex = 93
    b.Parent = parent
    IT("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local SoundBtn = CriarBotao("🔊 Som", Color3.fromRGB(60, 100, 160), BtnRow, 0, 0.32)
local GodBtn   = CriarBotao("🛡️ God", Color3.fromRGB(60, 160, 80), BtnRow, 0.34, 0.32)
local ScanBtn  = CriarBotao("🔍 Scan", Color3.fromRGB(160, 100, 60), BtnRow, 0.68, 0.32)

SoundBtn.MouseButton1Click:Connect(function()
    if Soundtrack then
        if Soundtrack.IsPlaying then Soundtrack:Stop() else Soundtrack:Play() end
    end
end)

GodBtn.MouseButton1Click:Connect(function()
    Config.GodModeAtivo = not Config.GodModeAtivo
    GodBtn.Text = "🛡️ God "..(Config.GodModeAtivo and "ON" or "OFF")
    GodBtn.BackgroundColor3 = Config.GodModeAtivo and Color3.fromRGB(60, 160, 80) or Color3.fromRGB(160, 60, 60)
end)

ScanBtn.MouseButton1Click:Connect(function()
    RemotesEncontrados = {DANO = {}, ANIMACAO = {}, EFEITO = {}}
    EscanearRemotes()
    ScanBtn.Text = "🔍 OK"
    task.delay(1.5, function()
        if ScanBtn and ScanBtn.Parent then ScanBtn.Text = "🔍 Scan" end
    end)
end)

-- Drag da janela
local arrastando = false
local offset = Vector2.new()

local function iniciarDrag(input)
    arrastando = true
    offset = Vector2.new(
        input.Position.X - MainFrame.AbsolutePosition.X,
        input.Position.Y - MainFrame.AbsolutePosition.Y
    )
    stroke.Color = Color3.fromRGB(255, 220, 120)
    stroke.Thickness = 2.5
end

local function terminarDrag()
    arrastando = false
    stroke.Color = Color3.fromRGB(80, 80, 90)
    stroke.Thickness = 1.5
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        iniciarDrag(input)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                terminarDrag()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not arrastando then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local vp = Camera.ViewportSize
    local novoX = input.Position.X - offset.X
    local novoY = input.Position.Y - offset.Y
    novoX = math.clamp(novoX, 0, vp.X - MainFrame.AbsoluteSize.X)
    novoY = math.clamp(novoY, 0, vp.Y - MainFrame.AbsoluteSize.Y)
    MainFrame.Position = UDim2.new(0, novoX, 0, novoY)
end)

-- Minimizar / Fechar / Reabrir
local minimizado = false
local fechado = false

MinBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    ContentFrame.Visible = not minimizado
    MainFrame.Size = minimizado and UDim2.new(0, 280, 0, 32) or UDim2.new(0, 280, 0, 320)
end)

CloseBtn.MouseButton1Click:Connect(function()
    fechado = true
    MainFrame.Visible = false
end)

-- Tecla P para reabrir
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.P then
        fechado = not fechado
        MainFrame.Visible = not fechado
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [22] BINDS DE SKILLS + LOOP PRINCIPAL
-- ═══════════════════════════════════════════════════════════════════════
-- Mapeia funcs nas linhas de skill
for _, entry in ipairs(SkillLinhas) do
    local nome = entry.data.nome
    if nome == ";Fling" then entry.data.func = Fling
    elseif nome == ";TpTo" then entry.data.func = TpTo
    elseif nome == ";Hurl" then entry.data.func = Hurl
    elseif nome == ";Kill" then entry.data.func = Kill
    end
end

local ultimoSkill = 0
local function DebounceGlobal()
    if tick() - ultimoSkill < 0.3 then return true end
    ultimoSkill = tick()
    return false
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if ATTACK or DebounceGlobal() then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.Z then Fling()
    elseif k == Enum.KeyCode.X then TpTo()
    elseif k == Enum.KeyCode.C then Hurl()
    elseif k == Enum.KeyCode.V then Kill()
    elseif k == Enum.KeyCode.M then SC = not SC
    elseif k == Enum.KeyCode.G then
        Config.GodModeAtivo = not Config.GodModeAtivo
        GodBtn.Text = "🛡️ God "..(Config.GodModeAtivo and "ON" or "OFF")
        GodBtn.BackgroundColor3 = Config.GodModeAtivo and Color3.fromRGB(60, 160, 80) or Color3.fromRGB(160, 60, 60)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [23] HUD LOOP + MONITORAMENTO ANTIVIRUS
-- ═══════════════════════════════════════════════════════════════════════
local MALWARE = {"BlurEffect","BloomEffect","Fire","ParticleEmitter","Smoke"}
local MOVINGSCREENS = false

task.spawn(function()
    while MainFrame.Parent do
        task.wait(0.1)
        pcall(function()
            local dt = workspace.DistributedGameTime
            local SEC = math.floor(dt) % 60
            local MIN = math.floor(dt/60) % 60
            local HOR = math.floor(dt/3600)
            statLabel.Text = string.format(
                "Time: %02d:%02d:%02d\nGravity: %.1f | Players: %d\nJobId: %.8s | Ver: %d",
                SEC, MIN, HOR, workspace.Gravity, #Players:GetPlayers(),
                game.JobId ~= "" and game.JobId or "Studio", game.PlaceVersion
            )
            statusLabel.Text = string.format("God: %s | SC: %s | Remotes: %d",
                Config.GodModeAtivo and "ON" or "OFF",
                SC and "ON" or "OFF",
                #RemotesEncontrados.DANO + #RemotesEncontrados.ANIMACAO + #RemotesEncontrados.EFEITO)
        end)

        -- Monitoramento fake dos GUISTEXT
        if #GUISTEXT > 0 then
            pcall(function()
                if MRANDOM(1,125) == 1 then
                    for E = 1, #GUISTEXT do
                        local TXT = GUISTEXT[E]
                        if E == 1 then TXT.Text = "SERVER STATS;"
                        elseif E == 2 then TXT.Text = "SERVER TIME = ["..math.floor(workspace.DistributedGameTime).."]"
                        elseif E == 3 then TXT.Text = "WORKSPACE GRAVITY = ["..workspace.Gravity.."]"
                        elseif E == 4 then TXT.Text = "SERVER JOBID = ["..game.JobId.."]"
                        elseif E == 5 then TXT.Text = "SERVER VERSION = ["..game.PlaceVersion.."]"
                        elseif E > 5 and E <= 15 then
                            if MRANDOM(1,3) == 1 then
                                local objs = workspace:GetChildren()
                                local alvo = objs[MRANDOM(1, #objs)]
                                if alvo then
                                    TXT.Text = ">>MONITORING; ["..alvo.Name.."]..."
                                    for _, mal in ipairs(MALWARE) do
                                        if alvo:FindFirstChildOfClass(mal) then
                                            TXT.Text = ">>!FOUND MALICIOUS CONTENT IN ["..alvo.Name.."]; FOUND: ["..mal.."]"
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
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [24] LOOP PRINCIPAL DE ANIMAÇÃO
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        Swait()
        SINE = SINE + CHANGE
        if not Character or not Character.Parent then
            task.wait(0.5)
            continue
        end

        pcall(function()
            local TORSOVELOCITY = (RootPart.Velocity * VT(1,0,1)).Magnitude
            local TORSOVERTICALVELOCITY = RootPart.Velocity.Y
            local HITFLOOR = Raycast(RootPart.Position,
                (CF(RootPart.Position, RootPart.Position + VT(0,-1,0))).lookVector, 4, Character)
            local WALKSPEEDVALUE = 8 / (Humanoid.WalkSpeed / 16)

            if ANIM == "Walk" and TORSOVELOCITY > 1 then
                RootJoint.C1 = Clerp(RootJoint.C1, CF(0,0,0.1*COS(SINE/(WALKSPEEDVALUE/2))), 2*(Humanoid.WalkSpeed/16)/Config.Animation_Speed)
                Neck.C1 = Clerp(Neck.C1, CF(0,-0.5,0)*ANGLES(RAD(-90),RAD(0),RAD(180)), 0.2/Config.Animation_Speed)
                RightHip.C1 = Clerp(RightHip.C1, CF(0.5,0.875-0.125*SIN(SINE/WALKSPEEDVALUE)-0.15*COS(SINE/WALKSPEEDVALUE*2),0.25*SIN(SINE/WALKSPEEDVALUE)) * ANGLES(RAD(0),RAD(90),RAD(0)) * ANGLES(RAD(0),RAD(0),RAD(10+50*COS(SINE/WALKSPEEDVALUE))), 0.6/Config.Animation_Speed)
                LeftHip.C1 = Clerp(LeftHip.C1, CF(-0.5,0.875+0.125*SIN(SINE/WALKSPEEDVALUE)-0.15*COS(SINE/WALKSPEEDVALUE*2),-0.25*SIN(SINE/WALKSPEEDVALUE)) * ANGLES(RAD(0),RAD(-90),RAD(0)) * ANGLES(RAD(0),RAD(0),RAD(-10+50*COS(SINE/WALKSPEEDVALUE))), 0.6/Config.Animation_Speed)
            else
                RootJoint.C1 = Clerp(RootJoint.C1, CF(0,0,0), 0.2/Config.Animation_Speed)
                Neck.C1 = Clerp(Neck.C1, CF(0,-0.5,0)*ANGLES(RAD(-90),RAD(0),RAD(180)), 0.2/Config.Animation_Speed)
                RightHip.C1 = Clerp(RightHip.C1, CF(0.5,1,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 0.7/Config.Animation_Speed)
                LeftHip.C1 = Clerp(LeftHip.C1, CF(-0.5,1,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 0.7/Config.Animation_Speed)
            end

            if ATTACK == false then
                if TORSOVERTICALVELOCITY > 1 and HITFLOOR == nil then
                    ANIM = "Jump"
                elseif TORSOVERTICALVELOCITY < -1 and HITFLOOR == nil then
                    ANIM = "Fall"
                elseif TORSOVELOCITY < 1 and HITFLOOR ~= nil then
                    ANIM = "Idle"
                    if MRANDOM(1,650) == 1 and LITTLEIDLE == false and GLASSESWLD then
                        LITTLEIDLE = true
                        task.spawn(function()
                            task.wait(2)
                            LITTLEIDLE = false
                        end)
                    end
                elseif TORSOVELOCITY > 1 and HITFLOOR ~= nil then
                    ANIM = "Walk"
                end
            end

            if ANIM == "Idle" and ATTACK == false and not LITTLEIDLE then
                RootJoint.C0 = Clerp(RootJoint.C0, CF(0-0.04*COS(SINE/24),0,0+0.05*COS(SINE/12)) * ANGLES(RAD(0),RAD(0-2.5*COS(SINE/24)),RAD(0)), 1/Config.Animation_Speed)
                Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180)) * CF(0,0,0) * ANGLES(RAD(3-7*COS(SINE/12)),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.1,0.35+0.1*COS(SINE/12),0.2) * ANGLES(RAD(-45-1.5*COS(SINE/12)),RAD(0),RAD(-45)) * ANGLES(RAD(0),RAD(25),RAD(0)) * CF(-0.5,0,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 1/Config.Animation_Speed)
                LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.1,0.35+0.1*COS(SINE/12),0.2) * ANGLES(RAD(-44-1.5*COS(SINE/12)),RAD(0),RAD(45)) * ANGLES(RAD(0),RAD(-25),RAD(0)) * CF(0.5,0,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 1/Config.Animation_Speed)
                RightHip.C0 = Clerp(RightHip.C0, CF(1,-1+0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(85),RAD(0)) * ANGLES(RAD(-2-2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1-0.035*COS(SINE/24)-0.05*COS(SINE/12),0) * ANGLES(RAD(0),RAD(-85),RAD(0)) * ANGLES(RAD(-2+2.5*COS(SINE/24)),RAD(0),RAD(0)), 1/Config.Animation_Speed)
            elseif ANIM == "Jump" and ATTACK == false then
                RootJoint.C0 = Clerp(RootJoint.C0, CF(0,0,0)*ANGLES(RAD(-5),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180))*CF(0,0,0)*ANGLES(RAD(-25),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5,0.5,0)*ANGLES(RAD(-35),RAD(0),RAD(25+10*COS(SINE/12)))*CF(-0.5,0,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 1/Config.Animation_Speed)
                LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0)*ANGLES(RAD(-35),RAD(0),RAD(-25-10*COS(SINE/12)))*CF(0.5,0,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 1/Config.Animation_Speed)
            elseif ANIM == "Fall" and ATTACK == false then
                RootJoint.C0 = Clerp(RootJoint.C0, CF(0,0,0)*ANGLES(RAD(15),RAD(0),RAD(0)), 1/Config.Animation_Speed)
                Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180))*CF(0,0,0)*ANGLES(RAD(15),RAD(0),RAD(0)), 1/Config.Animation_Speed)
            elseif ANIM == "Walk" and ATTACK == false then
                RootJoint.C0 = Clerp(RootJoint.C0, CF(0,0,-0.05)*ANGLES(RAD(5),RAD(0),RAD(-7*COS(SINE/WALKSPEEDVALUE))), 1/Config.Animation_Speed)
                Neck.C0 = Clerp(Neck.C0, CF(0,1,0)*ANGLES(RAD(-90),RAD(0),RAD(180))*CF(0,0,0)*ANGLES(RAD(5-1*SIN(SINE/(WALKSPEEDVALUE/2))),RAD(0),RAD(7*COS(SINE/WALKSPEEDVALUE))), 1/Config.Animation_Speed)
                RightShoulder.C0 = Clerp(RightShoulder.C0, CF(1.5,0.5,0)*ANGLES(RAD(60*COS(SINE/WALKSPEEDVALUE)),RAD(-5),RAD(5))*CF(-0.5,0,0)*ANGLES(RAD(0),RAD(90),RAD(0)), 1/Config.Animation_Speed)
                LeftShoulder.C0 = Clerp(LeftShoulder.C0, CF(-1.5,0.5,0)*ANGLES(RAD(-60*COS(SINE/WALKSPEEDVALUE)),RAD(5),RAD(-5))*CF(0.5,0,0)*ANGLES(RAD(0),RAD(-90),RAD(0)), 1/Config.Animation_Speed)
                RightHip.C0 = Clerp(RightHip.C0, CF(1,-1,0)*ANGLES(RAD(0),RAD(85),RAD(0)), 2/Config.Animation_Speed)
                LeftHip.C0 = Clerp(LeftHip.C0, CF(-1,-1,0)*ANGLES(RAD(0),RAD(-85),RAD(0)), 2/Config.Animation_Speed)
            end

            if Rooted then
                Humanoid.WalkSpeed = 0
            else
                Humanoid.WalkSpeed = 16
            end

            if ANIMATE and ANIMATE.Parent then ANIMATE.Parent = nil end
        end)

        -- Controla as telas (SC)
        if #SCREENWELDS > 0 then
            if SC == true then
                if MRANDOM(1,75) == 1 and not MOVINGSCREENS then
                    MOVINGSCREENS = true
                    task.wait(1)
                    MOVINGSCREENS = false
                    for E = 1, #SCREENWELDS do
                        task.spawn(function()
                            local MATH1 = MRANDOM(-25,25)/10+1
                            local MATH2 = MRANDOM(-45,45)
                            for i = 1, 55 do
                                Swait()
                                if SCREENWELDS[E] and SCREENWELDS[E].Parent then
                                    SCREENWELDS[E].C0 = Clerp(SCREENWELDS[E].C0, CF(0,MATH1,0) * ANGLES(RAD(0),RAD(MATH2+180),RAD(0)) * CF(0,0,3+(E/1.5)), 0.1)
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
            -- Deixa as telas semi-transparentes piscando
            for E = 1, #SCREENS do
                if SCREENS[E] and SCREENS[E].Parent then
                    SCREENS[E].Transparency = MRANDOM(90,99)/100
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- [25] INICIAR INTRO (após 3s pra dar tempo do char carregar)
-- ═══════════════════════════════════════════════════════════════════════
task.wait(3)
if not INTRO and Character and Character.Parent and Humanoid and Humanoid.Health > 0 then
    task.spawn(IntroThing)
end

-- ═══════════════════════════════════════════════════════════════════════
-- [26] FIM — Notificação final + prints
-- ═══════════════════════════════════════════════════════════════════════
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
print("[gOb Admin] Scanner: "..#RemotesEncontrados.DANO.." DANO | "..#RemotesEncontrados.ANIMACAO.." ANIM | "..#RemotesEncontrados.EFEITO.." EFEITO")
print("[gOb Admin] Crosshair + Mobile + RemoteEvent ativos")
print("[gOb Admin] Otimizado para JJS e Natural Disaster Survival")
print("[gOb Admin] =====================================")
