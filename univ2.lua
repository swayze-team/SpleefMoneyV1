--// LocalScript (StarterPlayerScripts)
--// Admin Test Menu for YOUR game (debug-only)
--// Rayfield UI + KeySystem (key: SWEEKZI2K25)
--// Designed for *your* place. Avoid using on games you don't own.

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create window with KeySystem
local Window = Rayfield:CreateWindow({
    Name = "Admin Test Menu",
    LoadingTitle = "Rayfield Admin Tools",
    LoadingSubtitle = "For your game only",
    ConfigurationSaving = { Enabled = false },
    KeySystem = true,
    KeySettings = {
        Title = "Admin Access",
        Subtitle = "Enter Access Key",
        Note = "Private dev tools for YOUR place",
        FileName = "AdminTest_Key",
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
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

-- Utils
local function notify(title, content, dur)
    Rayfield:Notify({Title = title or "Info", Content = content or "", Duration = dur or 3})
end

local function getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function onRespawn(callback)
    LocalPlayer.CharacterAdded:Connect(function()
        task.defer(callback)
    end)
end

--------------------------------------------------------------------
-- UNIVERSAL TAB (movement, protections, QoL)
--------------------------------------------------------------------
local TabUniversal = Window:CreateTab("Universal", 4483362458)
TabUniversal:CreateSection("Movement & Protections (client debug)")

--[[
  Robust Noclip: stores original CanCollide per part and restores on disable
]]
local noclip = {
    enabled = false,
    originals = {},
    loop = nil,
}

function noclip:start()
    if self.enabled then return end
    self.enabled = true
    notify("Noclip", "Enabled", 2)
    self.loop = RS.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                if self.originals[p] == nil then self.originals[p] = p.CanCollide end
                if p.CanCollide ~= false then p.CanCollide = false end
            end
        end
    end)
end

function noclip:stop()
    if not self.enabled then return end
    self.enabled = false
    if self.loop then self.loop:Disconnect() self.loop = nil end
    for p, orig in pairs(self.originals) do
        if p and p.Parent and p:IsA("BasePart") then p.CanCollide = orig end
    end
    self.originals = {}
    notify("Noclip", "Disabled", 2)
end

TabUniversal:CreateToggle({
    Name = "Noclip (dev)",
    CurrentValue = false,
    Callback = function(state)
        if state then noclip:start() else noclip:stop() end
    end
})

-- Re-apply noclip on respawn if still enabled
onRespawn(function()
    if noclip.enabled then noclip:stop(); task.wait(0.1); noclip:start() end
end)

--[[
  Fly (stable): BodyVelocity + BodyGyro, camera-relative controls
  Controls: WASD, ascend: Space/E, descend: LeftCtrl/Q
]]
local fly = {
    enabled = false,
    speed = 80,
    bv = nil,
    bg = nil,
    conn = nil,
}

function fly:start()
    if self.enabled then return end
    local hrp = getHRP(); if not hrp then return end
    self.enabled = true
    self.bv = Instance.new("BodyVelocity")
    self.bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    self.bv.Velocity = Vector3.zero
    self.bv.Parent = hrp

    self.bg = Instance.new("BodyGyro")
    self.bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    self.bg.P = 9e4
    self.bg.CFrame = workspace.CurrentCamera.CFrame
    self.bg.Parent = hrp

    self.conn = RS.RenderStepped:Connect(function()
        local camCF = workspace.CurrentCamera.CFrame
        self.bg.CFrame = camCF
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir += -camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir += -camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) then dir += Vector3.new(0,-1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit else dir = Vector3.zero end
        self.bv.Velocity = dir * self.speed
    end)
    notify("Fly", "Enabled (WASD + Space/E up, Ctrl/Q down)", 4)
end

function fly:stop()
    if not self.enabled then return end
    self.enabled = false
    if self.conn then self.conn:Disconnect() self.conn = nil end
    if self.bv then self.bv:Destroy() self.bv = nil end
    if self.bg then self.bg:Destroy() self.bg = nil end
    local hrp = getHRP(); if hrp then hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero end
    notify("Fly", "Disabled", 2)
end

TabUniversal:CreateToggle({
    Name = "Fly (WASD / Space/E / Ctrl/Q)",
    CurrentValue = false,
    Callback = function(state)
        if state then fly:start() else fly:stop() end
    end
})

TabUniversal:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 250},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = fly.speed,
    Callback = function(v) fly.speed = v end
})

-- Sprint boost (Shift)
local sprintMul, sprinting = 2, false
TabUniversal:CreateSlider({
    Name = "Sprint Multiplier (Shift)",
    Range = {1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = sprintMul,
    Callback = function(v) sprintMul = v end
})

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.LeftShift then
        local h = getHumanoid()
        if h and not sprinting then h.WalkSpeed = h.WalkSpeed * sprintMul; sprinting = true end
    end
end)

UIS.InputEnded:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.LeftShift then
        local h = getHumanoid()
        if h and sprinting then h.WalkSpeed = h.WalkSpeed / sprintMul; sprinting = false end
    end
end)

-- Anti-Fall, Anti-Idle, Anti-Fling, NoRagdoll
TabUniversal:CreateToggle({
    Name = "Anti-Fall (teleport if Y<-100)",
    CurrentValue = false,
    Callback = function(state)
        if not state then return end
        task.spawn(function()
            while state do
                local hrp = getHRP()
                if hrp and hrp.Position.Y < -100 then hrp.CFrame = CFrame.new(0, 15, 0) end
                task.wait(0.25)
            end
        end)
    end
})

TabUniversal:CreateToggle({
    Name = "Prevent Idle Disconnect",
    CurrentValue = false,
    Callback = function(state)
        if not state then return end
        local vu = game:GetService("VirtualUser")
        task.spawn(function()
            while state do
                vu:CaptureController(); vu:ClickButton2(Vector2.new())
                task.wait(60)
            end
        end)
    end
})

local antiFling = {enabled=false, conn=nil}
TabUniversal:CreateToggle({
    Name = "Anti-Fling (clamp extreme velocities)",
    CurrentValue = false,
    Callback = function(state)
        antiFling.enabled = state
        if state then
            antiFling.conn = RS.Heartbeat:Connect(function()
                local hrp = getHRP(); if not hrp then return end
                local v = hrp.AssemblyLinearVelocity
                if v.Magnitude > 180 then hrp.AssemblyLinearVelocity = v.Unit * 180 end
                local av = hrp.AssemblyAngularVelocity
                if av.Magnitude > 120 then hrp.AssemblyAngularVelocity = Vector3.zero end
            end)
            notify("Anti-Fling", "Enabled", 2)
        else
            if antiFling.conn then antiFling.conn:Disconnect(); antiFling.conn=nil end
            notify("Anti-Fling", "Disabled", 2)
        end
    end
})

local noRagdoll = false
TabUniversal:CreateToggle({
    Name = "No Ragdoll/No PlatformStand (client)",
    CurrentValue = false,
    Callback = function(state)
        noRagdoll = state
        local h = getHumanoid(); if not h then return end
        local list = {Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.FallingDown}
        for _,st in ipairs(list) do h:SetStateEnabled(st, not state) end
    end
})

-- Quick actions
TabUniversal:CreateButton({ Name = "Respawn", Callback = function() LocalPlayer:LoadCharacter() end })
TabUniversal:CreateButton({ Name = "Sit / Unsit", Callback = function() local h=getHumanoid(); if h then h.Sit = not h.Sit end end })

--------------------------------------------------------------------
-- CAMERA TAB (freecam, FOV, zoom, camera lock)
--------------------------------------------------------------------
local TabCam = Window:CreateTab("Camera", 4483362458)
TabCam:CreateSection("Freecam & View")

local cam = workspace.CurrentCamera
local freecam = {enabled=false, speed=2, conn=nil}

TabCam:CreateToggle({
    Name = "Freecam (Scriptable)",
    CurrentValue = false,
    Callback = function(state)
        freecam.enabled = state
        if state then
            cam.CameraType = Enum.CameraType.Scriptable
            freecam.conn = RS.RenderStepped:Connect(function()
                local move = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move += -cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move += -cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move += Vector3.new(0,-1,0) end
                cam.CFrame = cam.CFrame + (move * freecam.speed)
            end)
        else
            if freecam.conn then freecam.conn:Disconnect() freecam.conn=nil end
            cam.CameraType = Enum.CameraType.Custom
        end
    end
})

TabCam:CreateSlider({ Name = "Freecam Speed", Range = {0.5, 10}, Increment = 0.5, Suffix = "x", CurrentValue = freecam.speed, Callback = function(v) freecam.speed = v end })
TabCam:CreateSlider({ Name = "Field of View (FOV)", Range = {40, 120}, Increment = 1, CurrentValue = cam.FieldOfView, Callback = function(v) cam.FieldOfView = v end })
TabCam:CreateSlider({ Name = "Max Zoom Distance", Range = {4, 200}, Increment = 2, CurrentValue = LocalPlayer.CameraMaxZoomDistance, Callback = function(v) LocalPlayer.CameraMaxZoomDistance = v end })

--------------------------------------------------------------------
-- VISUAL DEBUG TAB (Highlights/labels for tagged instances)
--------------------------------------------------------------------
local TabVis = Window:CreateTab("Visual Debug", 4483362458)
TabVis:CreateSection("Highlights via CollectionService tags")

local activeHL, activeBB = {}, {}

local function clearHL()
    for inst, hl in pairs(activeHL) do if hl and hl.Parent then hl:Destroy() end activeHL[inst]=nil end
    for inst, bb in pairs(activeBB) do if bb and bb.Parent then bb:Destroy() end activeBB[inst]=nil end
end

local function ensureLabel(model)
    if activeBB[model] then return end
    local primary = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
    if not primary then return end
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0,120,0,28)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = primary
    bb.Parent = model

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1,0,1,0)
    tl.BackgroundTransparency = 1
    tl.TextScaled = true
    tl.Font = Enum.Font.GothamBold
    tl.TextColor3 = Color3.fromRGB(255,255,255)
    tl.TextStrokeTransparency = 0.5
    tl.Parent = bb

    activeBB[model] = bb

    -- update distance text
    task.spawn(function()
        while bb.Parent do
            local hrp = getHRP();
            local pos = primary.Position
            local dist = (hrp and (hrp.Position - pos).Magnitude) or 0
            tl.Text = string.format("%s | %.0f", model.Name, dist)
            RS.RenderStepped:Wait()
        end
    end)
end

local function makeHL(model, fillTrans)
    if activeHL[model] then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = model
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = fillTrans or 0.75
    hl.OutlineTransparency = 0
    hl.Parent = model
    activeHL[model] = hl
end

local function toggleTag(tagName, state)
    if not state then
        for inst, hl in pairs(activeHL) do
            if CollectionService:HasTag(inst, tagName) then if hl and hl.Parent then hl:Destroy() end activeHL[inst]=nil end
        end
        for inst, bb in pairs(activeBB) do
            if CollectionService:HasTag(inst, tagName) then if bb and bb.Parent then bb:Destroy() end activeBB[inst]=nil end
        end
        return
    end
    for _, inst in ipairs(CollectionService:GetTagged(tagName)) do
        if inst:IsA("Model") then makeHL(inst); ensureLabel(inst) end
    end
    CollectionService:GetInstanceAddedSignal(tagName):Connect(function(inst)
        if inst:IsA("Model") then makeHL(inst); ensureLabel(inst) end
    end)
    CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(inst)
        local hl = activeHL[inst]; if hl then hl:Destroy(); activeHL[inst]=nil end
        local bb = activeBB[inst]; if bb then bb:Destroy(); activeBB[inst]=nil end
    end)
end

TabVis:CreateToggle({ Name = "Tag: Enemy", CurrentValue = false, Callback = function(s) toggleTag("Enemy", s) end })
TabVis:CreateToggle({ Name = "Tag: NPC", CurrentValue = false, Callback = function(s) toggleTag("NPC", s) end })
TabVis:CreateToggle({ Name = "Tag: Item", CurrentValue = false, Callback = function(s) toggleTag("Item", s) end })
TabVis:CreateButton({ Name = "Clear All Highlights", Callback = function() clearHL() end })

--------------------------------------------------------------------
-- TELEPORT TAB (waypoints, tween)
--------------------------------------------------------------------
local TabTP = Window:CreateTab("Teleport", 4483362458)
TabTP:CreateSection("Waypoints (client)")

local waypoints = {}

TabTP:CreateInput({
    Name = "Create Waypoint (name)",
    PlaceholderText = "ex: Base",
    RemoveTextAfterFocusLost = true,
    Callback = function(name)
        name = tostring(name)
        local hrp = getHRP(); if not hrp then return end
        waypoints[name] = hrp.CFrame
        notify("Waypoint", "Saved '"..name.."'", 2)
    end
})

TabTP:CreateInput({
    Name = "Teleport to Waypoint (name)",
    PlaceholderText = "name",
    RemoveTextAfterFocusLost = true,
    Callback = function(name)
        local cf = waypoints[name]
        local hrp = getHRP()
        if cf and hrp then hrp.CFrame = cf + Vector3.new(0, 3, 0) else notify("Teleport", "Waypoint not found", 2) end
    end
})

TabTP:CreateButton({ Name = "List Waypoints (output)", Callback = function() local list = {}; for k,_ in pairs(waypoints) do table.insert(list, k) end; print("[Waypoints]", table.concat(list, ", ")); notify("Waypoints", "Printed in output", 2) end })

TabTP:CreateButton({
    Name = "Tween to Camera Look (20 studs)",
    Callback = function()
        local hrp = getHRP(); if not hrp then return end
        local target = workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * 20
        local tween = TweenService:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(target)})
        tween:Play()
    end
})

--------------------------------------------------------------------
-- WORLD TAB (lighting, gravity, ambience)
--------------------------------------------------------------------
local TabWorld = Window:CreateTab("World", 4483362458)
TabWorld:CreateSection("Environment")

TabWorld:CreateSlider({ Name = "TimeOfDay", Range = {0, 24}, Increment = 0.25, Suffix = "h", CurrentValue = tonumber(Lighting.ClockTime), Callback = function(v) Lighting.ClockTime = v end })
TabWorld:CreateToggle({ Name = "Global Shadows", CurrentValue = Lighting.GlobalShadows, Callback = function(s) Lighting.GlobalShadows = s end })
TabWorld:CreateToggle({ Name = "Bright Ambient", CurrentValue = false, Callback = function(s) if s then Lighting.Ambient=Color3.fromRGB(80,80,80); Lighting.OutdoorAmbient=Color3.fromRGB(80,80,80) else Lighting.Ambient=Color3.fromRGB(0,0,0); Lighting.OutdoorAmbient=Color3.fromRGB(0,0,0) end end })
TabWorld:CreateSlider({ Name = "Gravity", Range = {0, 400}, Increment = 5, Suffix = "g", CurrentValue = Workspace.Gravity, Callback = function(v) Workspace.Gravity = v end })
TabWorld:CreateSlider({ Name = "Brightness", Range = {0, 5}, Increment = 0.1, CurrentValue = Lighting.Brightness, Callback = function(v) Lighting.Brightness = v end })

--------------------------------------------------------------------
-- TOOLS TAB (console, player info)
--------------------------------------------------------------------
local TabTools = Window:CreateTab("Tools", 4483362458)
TabTools:CreateSection("Utilities")

TabTools:CreateButton({
    Name = "Print Player Info",
    Callback = function()
        local h = getHumanoid(); local hrp = getHRP()
        print("[PlayerInfo]", "Name=", LocalPlayer.Name, "WS=", h and h.WalkSpeed, "JP=", h and h.JumpPower, "Pos=", hrp and hrp.Position)
        notify("Info", "Printed in output", 2)
    end
})

-- Simple client console for quick dev commands
-- Supported: ws <n>, jp <n>, fov <n>, tp <x> <y> <z>
TabTools:CreateInput({
    Name = "Console (ws/jp/fov/tp)",
    PlaceholderText = "ex: ws 60 | tp 0 20 0",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local args = {}
        for w in string.gmatch(text, "%S+") do table.insert(args, w) end
        local cmd = string.lower(args[1] or "")
        if cmd == "ws" and tonumber(args[2]) then local h=getHumanoid(); if h then h.WalkSpeed = tonumber(args[2]) end
        elseif cmd == "jp" and tonumber(args[2]) then local h=getHumanoid(); if h then h.JumpPower = tonumber(args[2]) end
        elseif cmd == "fov" and tonumber(args[2]) then workspace.CurrentCamera.FieldOfView = tonumber(args[2])
        elseif cmd == "tp" and tonumber(args[2]) and tonumber(args[3]) and tonumber(args[4]) then local hrp=getHRP(); if hrp then hrp.CFrame = CFrame.new(tonumber(args[2]), tonumber(args[3]), tonumber(args[4])) end
        else notify("Console", "Unknown/invalid command", 3) end
    end
})

--------------------------------------------------------------------
-- DEBUG TAB (FPS/memory)
--------------------------------------------------------------------
local TabDbg = Window:CreateTab("Debug", 4483362458)
TabDbg:CreateSection("Metrics")

local showFps = false
TabDbg:CreateToggle({
    Name = "Show FPS (output)",
    CurrentValue = false,
    Callback = function(state)
        showFps = state
        if state then
            task.spawn(function()
                local last = os.clock()
                local frames = 0
                while showFps do
                    RS.RenderStepped:Wait()
                    frames += 1
                    local now = os.clock()
                    if now - last >= 1 then
                        print("[FPS]", frames)
                        frames = 0
                        last = now
                    end
                end
            end)
        end
    end
})

TabDbg:CreateButton({ Name = "Print Memory (MB)", Callback = function() local mem = Stats:GetTotalMemoryUsageMb(); print("[Memory]", mem); notify("Memory", string.format("%.1f MB", mem), 3) end })

--------------------------------------------------------------------
-- INTEGRATIONS TAB (HD Admin, custom modules)
--------------------------------------------------------------------
local TabInt = Window:CreateTab("Integrations", 4483362458)
TabInt:CreateSection("Admin & Modules (safe)")

TabInt:CreateButton({
    Name = "Detect HD Admin",
    Callback = function()
        local found = game:GetService("ReplicatedStorage"):FindFirstChild("HDAdminClient") or game:GetService("ReplicatedStorage"):FindFirstChild("HDAdminHDClient")
        if found then notify("HD Admin", "Detected. Use chat :cmds in YOUR game.", 5) else notify("HD Admin", "Not detected. Insert HD Admin from Toolbox in YOUR game.", 5) end
    end
})

-- Custom Module Loader (from ReplicatedStorage/AdminModules)
TabInt:CreateButton({
    Name = "Load Custom Modules (ReplicatedStorage/AdminModules)",
    Callback = function()
        local folder = game:GetService("ReplicatedStorage"):FindFirstChild("AdminModules")
        if not folder then notify("Modules", "No AdminModules folder in ReplicatedStorage", 4) return end
        local loaded = 0
        for _, m in ipairs(folder:GetChildren()) do
            if m:IsA("ModuleScript") then
                local ok, res = pcall(function()
                    local mod = require(m)
                    if typeof(mod) == "table" and mod.Init then mod.Init() end
                end)
                if ok then loaded += 1 else warn("[Module Error]", m.Name, res) end
            end
        end
        notify("Modules", "Loaded "..loaded.." module(s)", 4)
    end
})

-- NOTE: We do NOT load third-party exploit scripts (e.g., Infinite Yield). Keep modules first-party & safe.

--------------------------------------------------------------------
-- END
--------------------------------------------------------------------
notify("Admin Menu", "Loaded. Use responsibly in YOUR game.", 4)
