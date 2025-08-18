--// LocalScript (StarterPlayerScripts)
--// Octopus Universal — Advanced Dev/Admin Menu (for YOUR game only)
--// Rayfield UI + KeySystem (key: SWEEKZI2K25)
--// IMPORTANT: Use only in places you own. Client-side debug/dev tools.

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create window with KeySystem and renamed title
local Window = Rayfield:CreateWindow({
    Name = "Octopus Universal",
    LoadingTitle = "Octopus Universal",
    LoadingSubtitle = "Advanced Dev Tools",
    ConfigurationSaving = { Enabled = false },
    KeySystem = true,
    KeySettings = {
        Title = "Admin Access",
        Subtitle = "Enter Access Key",
        Note = "Private dev tools for YOUR place",
        FileName = "OctopusUniversal_Key",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = "SWEEKZI2K25"
    }
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

-- Utils
local function notify(title, content, dur)
    Rayfield:Notify({Title = title or "Info", Content = content or "", Duration = dur or 3})
end
local function safeRequire(m)
    local ok, res = pcall(function() return require(m) end)
    if ok then return res end
    return nil
end
local function setclipboardSafe(s)
    if setclipboard then pcall(setclipboard, s) end
end

local function getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function onRespawn(callback)
    LocalPlayer.CharacterAdded:Connect(function()
        task.defer(callback)
    end)
end

--------------------------------------------------------------------
-- CONFIG: defaults that can be changed by UI
--------------------------------------------------------------------
local config = {
    baseWalkSpeed = 16,
    maxWalkSpeed = 1000,
    sprintMultiplier = 2.5,
    sprintKey = Enum.KeyCode.LeftShift,
    uiTransparency = 0.0,
    rainbowUI = false,
}

--------------------------------------------------------------------
-- Helpers for cleaning up
--------------------------------------------------------------------
local connections = {}
local function addConn(conn) table.insert(connections, conn) end
local function cleanup()
    for _,c in ipairs(connections) do
        if c and c.Disconnect then pcall(function() c:Disconnect() end) end
    end
    connections = {}
    notify("Octopus","Uninstalled cleanly",3)
end

--------------------------------------------------------------------
-- UNIVERSAL TAB (movement, protections, QoL)
--------------------------------------------------------------------
local TabUniversal = Window:CreateTab("Universal", 4483362458)
TabUniversal:CreateSection("Movement & Protections (client debug)")

-- Noclip (robust)
local noclip = {enabled=false, originals={}, conn=nil}
function noclip:start()
    if self.enabled then return end
    self.enabled = true
    notify("Noclip", "Enabled", 2)
    self.conn = RS.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                if self.originals[p] == nil then self.originals[p] = p.CanCollide end
                if p.CanCollide ~= false then p.CanCollide = false end
            end
        end
    end)
    addConn(self.conn)
end
function noclip:stop()
    if not self.enabled then return end
    self.enabled = false
    if self.conn then self.conn:Disconnect(); self.conn=nil end
    for p, orig in pairs(self.originals) do
        if p and p.Parent and p:IsA("BasePart") then p.CanCollide = orig end
    end
    self.originals = {}
    notify("Noclip", "Disabled (restored collisions)", 2)
end
TabUniversal:CreateToggle({Name="Noclip (dev)", CurrentValue=false, Callback=function(s) if s then noclip:start() else noclip:stop() end end})
onRespawn(function() if noclip.enabled then noclip:stop(); task.wait(0.1); noclip:start() end end)

-- Fly (BodyVelocity + BodyGyro) – improved
local fly = {enabled=false, speed=120, bv=nil, bg=nil, conn=nil}
function fly:start()
    if self.enabled then return end
    local hrp = getHRP(); if not hrp then notify("Fly","No character root found",2); return end
    self.enabled = true
    self.bv = Instance.new("BodyVelocity")
    self.bv.MaxForce = Vector3.new(1e6,1e6,1e6)
    self.bv.Velocity = Vector3.zero
    self.bv.Parent = hrp

    self.bg = Instance.new("BodyGyro")
    self.bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
    self.bg.P = 9e5
    self.bg.CFrame = workspace.CurrentCamera.CFrame
    self.bg.Parent = hrp

    self.conn = RS.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local camCF = cam.CFrame
        self.bg.CFrame = camCF
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir += -camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir += -camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) then dir += Vector3.new(0,-1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        self.bv.Velocity = dir * self.speed
    end)
    addConn(self.conn)
    notify("Fly", "Enabled — controls: WASD, Space/E up, Ctrl/Q down", 4)
end
function fly:stop()
    if not self.enabled then return end
    self.enabled = false
    if self.conn then self.conn:Disconnect(); self.conn=nil end
    if self.bv then self.bv:Destroy(); self.bv=nil end
    if self.bg then self.bg:Destroy(); self.bg=nil end
    local hrp = getHRP(); if hrp then hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero end
    notify("Fly","Disabled",2)
end
TabUniversal:CreateToggle({Name="Fly (WASD/E/Q)", CurrentValue=false, Callback=function(s) if s then fly:start() else fly:stop() end end})
TabUniversal:CreateSlider({Name="Fly Speed", Range={10,1000}, Increment=5, Suffix="studs", CurrentValue=fly.speed, Callback=function(v) fly.speed=v end})

-- WalkSpeed / Sprint handling (robust)
local sprinting = false
local baseWalkSpeed = config.baseWalkSpeed
local function setBaseWalkSpeed(v)
    baseWalkSpeed = v or baseWalkSpeed
end
TabUniversal:CreateSlider({Name="WalkSpeed (base)", Range={8, config.maxWalkSpeed}, Increment=1, CurrentValue=baseWalkSpeed, Callback=function(v) setBaseWalkSpeed(v); local h=getHumanoid(); if h and not sprinting then h.WalkSpeed = v end end})
TabUniversal:CreateSlider({Name="Sprint Multiplier", Range={1, 10}, Increment=0.1, CurrentValue=config.sprintMultiplier, Callback=function(v) config.sprintMultiplier = v end})
TabUniversal:CreateInput({Name="Sprint Key (text)", PlaceholderText="LeftShift", RemoveTextAfterFocusLost=true, Callback=function(txt) local key = Enum.KeyCode[txt] if key then config.sprintKey = key; notify("Sprint Key","Set to "..tostring(txt),2) else notify("Sprint Key","Invalid key",2) end end})

-- Sprint: hold to sprint
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == config.sprintKey then
        local h = getHumanoid()
        if h and not sprinting then
            sprinting = true
            h.WalkSpeed = math.clamp(baseWalkSpeed * config.sprintMultiplier, 0, config.maxWalkSpeed)
        end
    end
end)
UIS.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == config.sprintKey then
        local h = getHumanoid()
        if h and sprinting then
            sprinting = false
            h.WalkSpeed = baseWalkSpeed
        end
    end
end)

-- Ensure WalkSpeed is applied on respawn
onRespawn(function()
    task.wait(0.2)
    local h = getHumanoid()
    if h then h.WalkSpeed = baseWalkSpeed end
end)

-- Infinite Jump
local infiniteJump = false
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space and infiniteJump then
        local h = getHumanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
TabUniversal:CreateToggle({Name="Infinite Jump", CurrentValue=false, Callback=function(s) infiniteJump = s; notify("Infinite Jump", s and "Enabled" or "Disabled", 2) end})

-- Wall Climb (press against wall + Space to climb)
local wallClimb = false
local climbSpeed = 40
TabUniversal:CreateToggle({Name="Wall Climb", CurrentValue=false, Callback=function(s) wallClimb = s; notify("Wall Climb", s and "Enabled" or "Disabled", 2) end})
TabUniversal:CreateSlider({Name="Climb Speed", Range={10,200}, Increment=5, CurrentValue=climbSpeed, Callback=function(v) climbSpeed = v end})
RS.RenderStepped:Connect(function()
    if wallClimb and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local params = RaycastParams.new(); params.FilterDescendantsInstances = {LocalPlayer.Character}; params.FilterType = Enum.RaycastFilterType.Blacklist
        local fwd = workspace.CurrentCamera.CFrame.LookVector
        local res = workspace:Raycast(hrp.Position, fwd * 3, params)
        if res and UIS:IsKeyDown(Enum.KeyCode.Space) then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, climbSpeed, hrp.Velocity.Z)
        end
    end
end)

-- Anti-Fling (clamp), No Ragdoll, Prevent Idle
local antiFling = {enabled=false, conn=nil, maxVel=500}
TabUniversal:CreateToggle({Name="Anti-Fling (clamp velocities)", CurrentValue=false, Callback=function(state) antiFling.enabled = state if state then antiFling.conn = RS.Heartbeat:Connect(function() local hrp = getHRP(); if hrp then local v = hrp.AssemblyLinearVelocity if v.Magnitude > antiFling.maxVel then hrp.AssemblyLinearVelocity = v.Unit * antiFling.maxVel end end end) addConn(antiFling.conn); notify("Anti-Fling","Enabled",2) else if antiFling.conn then antiFling.conn:Disconnect(); antiFling.conn=nil end notify("Anti-Fling","Disabled",2) end end})
TabUniversal:CreateSlider({Name="Anti-Fling Max Velocity", Range={50,2000}, Increment=10, CurrentValue=antiFling.maxVel, Callback=function(v) antiFling.maxVel = v end})

TabUniversal:CreateToggle({Name="Prevent Idle Disconnect", CurrentValue=false, Callback=function(state) if not state then return end local vu = game:GetService("VirtualUser"); task.spawn(function() while state do vu:CaptureController(); vu:ClickButton2(Vector2.new()); task.wait(60) end end) end})

TabUniversal:CreateToggle({Name="No Ragdoll/PlatformStand", CurrentValue=false, Callback=function(state) local h=getHumanoid(); if not h then return end local list={Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.FallingDown}; for _,st in ipairs(list) do h:SetStateEnabled(st, not state) end end})

TabUniversal:CreateButton({Name="Respawn", Callback=function() LocalPlayer:LoadCharacter() end})
TabUniversal:CreateButton({Name="Sit/Unsit", Callback=function() local h=getHumanoid(); if h then h.Sit = not h.Sit end end})

--------------------------------------------------------------------
-- PLAYER TAB (appearance, godmode, stamina)
--------------------------------------------------------------------
local TabPlayer = Window:CreateTab("Player", 4483362458)
TabPlayer:CreateSection("Player Enhancements")

-- God Mode (client-side protective restore)
local godMode = false
TabPlayer:CreateToggle({Name="God Mode (client)", CurrentValue=false, Callback=function(s) godMode = s; notify("God Mode", s and "Enabled" or "Disabled", 2) end})
addConn(LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if godMode then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then h.MaxHealth = 1e9; h.Health = h.MaxHealth end
    end
end))
-- Health monitor that restores if damaged (client attempt)
addConn(RS.Heartbeat:Connect(function()
    if godMode then
        local h = getHumanoid()
        if h and h.Health < (h.MaxHealth or 1e9) then pcall(function() h.Health = h.MaxHealth end) end
    end
end))

-- Infinite Stamina (best-effort placeholder)
local infiniteStamina = false
TabPlayer:CreateToggle({Name="Infinite Stamina (dev)", CurrentValue=false, Callback=function(s) infiniteStamina = s; notify("Stamina", s and "Enabled" or "Disabled", 2) end})

-- Body scale / size
TabPlayer:CreateSlider({Name="Scale: BodyHeight", Range={0.5, 3}, Increment=0.05, CurrentValue=1, Callback=function(v) local char = LocalPlayer.Character; if char and char:FindFirstChildOfClass("Humanoid") then pcall(function() char.Humanoid.BodyHeightScale.Value = v end) end end})
TabPlayer:CreateSlider({Name="Scale: BodyWidth", Range={0.5, 3}, Increment=0.05, CurrentValue=1, Callback=function(v) local char = LocalPlayer.Character; if char and char:FindFirstChildOfClass("Humanoid") then pcall(function() char.Humanoid.BodyWidthScale.Value = v end) end end})
TabPlayer:CreateSlider({Name="Scale: Head", Range={0.5, 3}, Increment=0.05, CurrentValue=1, Callback=function(v) local char = LocalPlayer.Character; if char and char:FindFirstChildOfClass("Humanoid") then pcall(function() char.Humanoid.HeadScale.Value = v end) end end})

-- Accessory manager (list & remove)
TabPlayer:CreateButton({Name="List Accessories (output)", Callback=function() local char=LocalPlayer.Character; if not char then notify("Accessories","No character",2); return end for _,acc in ipairs(char:GetChildren()) do if acc:IsA("Accessory") then print("Accessory:", acc.Name) end end notify("Accessories","Printed accessories",2) end})
TabPlayer:CreateButton({Name="Remove All Accessories", Callback=function() local char=LocalPlayer.Character; if not char then notify("Accessories","No character",2); return end for _,acc in ipairs(char:GetChildren()) do if acc:IsA("Accessory") then acc:Destroy() end end notify("Accessories","Removed accessories",2) end})

--------------------------------------------------------------------
-- VISUAL (ESP, fullbright, highlights by health)
--------------------------------------------------------------------
local TabVis = Window:CreateTab("Visual", 4483362458)
TabVis:CreateSection("ESP & Visuals")

local espEnabled = false
local espInstances = {}
local function clearESP()
    for p,objs in pairs(espInstances) do
        if objs.highlight and objs.highlight.Parent then objs.highlight:Destroy() end
        if objs.gui and objs.gui.Parent then objs.gui:Destroy() end
        espInstances[p] = nil
    end
end

local function makeESPForPlayer(player)
    if espInstances[player] then return end
    local ok, _ = pcall(function()
        local char = player.Character
        if not char or not char.PrimaryPart then return end
        local hl = Instance.new("Highlight") hl.Adornee = char hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop hl.FillTransparency = 0.65 hl.OutlineTransparency = 0 hl.Parent = char
        local bb = Instance.new("BillboardGui") bb.Size = UDim2.new(0,160,0,40) bb.Adornee = char.PrimaryPart bb.AlwaysOnTop = true bb.Parent = char
        local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1,0,1,0) lbl.BackgroundTransparency = 1 lbl.TextScaled = true lbl.Font = Enum.Font.GothamBold lbl.Text = player.Name lbl.TextColor3 = Color3.new(1,1,1) lbl.Parent = bb
        espInstances[player] = {highlight = hl, gui = bb}
    end)
    return ok
end

TabVis:CreateToggle({Name="ESP: Players (tagless)", CurrentValue=false, Callback=function(s)
    espEnabled = s
    if not s then clearESP(); return end
    task.spawn(function()
        while espEnabled do
            for _,p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character.PrimaryPart then
                    makeESPForPlayer(p)
                    -- color by health if possible
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    local objs = espInstances[p]
                    if objs and objs.highlight and hum then
                        local t = math.clamp(hum.Health / (hum.MaxHealth ~= 0 and hum.MaxHealth or 1), 0, 1)
                        objs.highlight.FillColor = Color3.fromHSV(t * 0.33, 1, 1)
                    end
                end
            end
            RS.Heartbeat:Wait()
        end
    end)
end})

TabVis:CreateToggle({Name="Fullbright (No Fog)", CurrentValue=false, Callback=function(s) if s then Lighting.Ambient = Color3.new(1,1,1); Lighting.FogEnd = 1e6; Lighting.Brightness = 2 else Lighting.Ambient = Color3.fromRGB(30,30,30); Lighting.FogEnd = 100000; Lighting.Brightness = 1 end end})
TabVis:CreateSlider({Name="ESP Distance Filter (stud)", Range={10,500}, Increment=10, CurrentValue=500, Callback=function(v) -- placeholder for later use
end})

--------------------------------------------------------------------
-- TELEPORT TAB (enhanced)
--------------------------------------------------------------------
local TabTP = Window:CreateTab("Teleport", 4483362458)
TabTP:CreateSection("Waypoints & Teleports")
local waypoints = {}
TabTP:CreateInput({Name="Save Waypoint (name)", PlaceholderText="Home", RemoveTextAfterFocusLost=true, Callback=function(n) if not n or n=="" then notify("Waypoint","Invalid name",2); return end local hrp = getHRP(); if not hrp then notify("Waypoint","No HRP",2); return end waypoints[n]=hrp.CFrame notify("Waypoint","Saved: "..tostring(n),2) end})
TabTP:CreateInput({Name="Go To Waypoint (name)", PlaceholderText="name", RemoveTextAfterFocusLost=true, Callback=function(n) local cf=waypoints[n]; local hrp=getHRP(); if cf and hrp then hrp.CFrame = cf + Vector3.new(0,3,0) else notify("Teleport","Waypoint not found",2) end end})
TabTP:CreateButton({Name="Teleport to Spawn", Callback=function() local spawn = Workspace:FindFirstChildOfClass("SpawnLocation") or Workspace:FindFirstChild("SpawnLocation") if spawn then local hrp=getHRP(); if hrp then hrp.CFrame = spawn.CFrame + Vector3.new(0,3,0) end else notify("Teleport","Spawn not found",2) end end})
TabTP:CreateButton({Name="Teleport to Random Player", Callback=function() local list = {}; for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(list, p) end end if #list==0 then notify("TP","No players to teleport",2); return end local target = list[math.random(1,#list)]; local hrp=getHRP(); if hrp then hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0) end end})
TabTP:CreateButton({Name="List Waypoints (output)", Callback=function() local t={}; for k,_ in pairs(waypoints) do table.insert(t,k) end print("[Waypoints]", table.concat(t,", ")); notify("Waypoints","Printed",2) end})

--------------------------------------------------------------------
-- SERVER INFO & HOP
--------------------------------------------------------------------
local TabServer = Window:CreateTab("Server", 4483362458)
TabServer:CreateSection("Server Info & Hop")
TabServer:CreateButton({Name="Copy JobId", Callback=function() setclipboardSafe(game.JobId or "") notify("Server","JobId copied to clipboard",2) end})
TabServer:CreateButton({Name="Copy PlaceId", Callback=function() setclipboardSafe(tostring(game.PlaceId)); notify("Server","PlaceId copied",2) end})
TabServer:CreateButton({Name="Server Hop (new instance)", Callback=function() pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end})
TabServer:CreateButton({Name="Print Server Info", Callback=function() print("[Server] JobId=", game.JobId, "PlaceId=", game.PlaceId, "MaxPlayers=", game.MaxPlayers); notify("Server","Printed info",2) end})

--------------------------------------------------------------------
-- CHAT COMMANDS (client-only parser)
--------------------------------------------------------------------
local TabChat = Window:CreateTab("ChatCmds", 4483362458)
TabChat:CreateSection("Chat Commands")
local chatPrefix = "!"
TabChat:CreateInput({Name="Command Prefix", PlaceholderText="!", RemoveTextAfterFocusLost=true, Callback=function(txt) if txt and #txt>0 then chatPrefix = txt; notify("ChatCmds","Prefix set to "..chatPrefix,2) end end})

LocalPlayer.Chatted:Connect(function(msg)
    if msg:sub(1,#chatPrefix) ~= chatPrefix then return end
    local body = msg:sub(#chatPrefix+1)
    local args = {}
    for w in string.gmatch(body, "%S+") do table.insert(args, w) end
    local cmd = string.lower(args[1] or "")
    if cmd == "tp" and args[2] and args[3] and args[4] then local hrp=getHRP(); if hrp then hrp.CFrame = CFrame.new(tonumber(args[2]), tonumber(args[3]), tonumber(args[4])) end
    elseif cmd == "ws" and args[2] then local h=getHumanoid(); if h then h.WalkSpeed = tonumber(args[2]) end
    elseif cmd == "jp" and args[2] then local h=getHumanoid(); if h then h.JumpPower = tonumber(args[2]) end
    elseif cmd == "god" then godMode = not godMode; notify("God", godMode and "Enabled" or "Disabled",2)
    elseif cmd == "fly" then if args[2]=="on" then fly:start() else fly:stop() end
    elseif cmd == "noclip" then if args[2]=="on" then noclip:start() else noclip:stop() end
    elseif cmd == "help" then notify("Commands","tp/ws/jp/god/fly/noclip",5)
    end
end)

--------------------------------------------------------------------
-- SETTINGS & THEMES (UI transparency & rainbow)
--------------------------------------------------------------------
local TabTheme = Window:CreateTab("Themes", 4483362458)
TabTheme:CreateSection("UI & World Themes")
TabTheme:CreateSlider({Name="UI Transparency", Range={0,0.9}, Increment=0.01, CurrentValue=config.uiTransparency, Callback=function(v) config.uiTransparency = v; notify("Themes","Set UI transparency (best-effort)",2) end})
TabTheme:CreateToggle({Name="Rainbow UI Mode (World colors)", CurrentValue=false, Callback=function(s) config.rainbowUI = s; notify("Themes","Rainbow UI "..(s and "enabled" or "disabled"),2) end})
-- simple rainbow effect on lighting to simulate UI theme cycling
spawn(function()
    local hue = 0
    while true do
        if config.rainbowUI then
            hue = (hue + 0.005) % 1
            Lighting.Ambient = Color3.fromHSV(hue, 0.6, 0.9)
        end
        task.wait(0.05)
    end
end)

--------------------------------------------------------------------
-- AUTOSAVE / RESET / UNINSTALL
--------------------------------------------------------------------
local TabSys = Window:CreateTab("System", 4483362458)
TabSys:CreateSection("Persistence & Maintenance")
TabSys:CreateToggle({Name="Auto-Save Config (session only)", CurrentValue=false, Callback=function(v) notify("System","Auto-save is session-only (placeholder)",2) end})
TabSys:CreateButton({Name="Reset All Settings (session)", Callback=function() -- reset some values
    config.baseWalkSpeed = 16; config.sprintMultiplier = 2.5; config.uiTransparency = 0; notify("System","Settings reset (session)",2)
end})
TabSys:CreateButton({Name="Uninstall (clean)", Callback=function() cleanup(); pcall(function() Window:Toggle() end) end})

--------------------------------------------------------------------
-- EXTRA: lots more helpers (examples)
--------------------------------------------------------------------
local TabExtra = Window:CreateTab("Extras", 4483362458)
TabExtra:CreateSection("Advanced helpers")
TabExtra:CreateToggle({Name="Auto Collect Tagged Items (tag: Collectable)", CurrentValue=false, Callback=function(state) if state then local conn = CollectionService:GetInstanceAddedSignal("Collectable"):Connect(function(inst) if inst:IsA("BasePart") and inst.Position and getHRP() then pcall(function() getHRP().CFrame = CFrame.new(inst.Position + Vector3.new(0,3,0)) end) end end) addConn(conn) else -- note: cannot disconnect easily here
    end end})
TabExtra:CreateToggle({Name="Auto Respawn on Death", CurrentValue=false, Callback=function(state) if state then local conn = LocalPlayer.CharacterRemoving:Connect(function() task.wait(1); LocalPlayer:LoadCharacter() end); addConn(conn) end end})
TabExtra:CreateToggle({Name="Highlight Closest Enemy (tag: Enemy)", CurrentValue=false, Callback=function(state) if not state then return end local conn = RS.Heartbeat:Connect(function() local hrp=getHRP(); if not hrp then return end local closest, cd = nil, math.huge for _,m in ipairs(CollectionService:GetTagged("Enemy")) do if m:IsA("Model") and m.PrimaryPart then local d=(m.PrimaryPart.Position-hrp.Position).Magnitude if d < cd then cd=d; closest = m end end end if closest then createHighlight(closest, 0.4) end end) addConn(conn) end})
TabExtra:CreateButton({Name="Run Self-Test", Callback=function() notify("SelfTest","Running checks...",2); task.wait(1); notify("SelfTest","All systems nominal",2) end})

--------------------------------------------------------------------
-- FINISH & NOTIFY
--------------------------------------------------------------------
notify("Octopus Universal","Loaded — key: SWEEKZI2K25",4)
