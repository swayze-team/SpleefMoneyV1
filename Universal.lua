--// LocalScript (StarterPlayerScripts)
--// Admin Test Menu for YOUR game (debug-only)
--// Uses Rayfield UI with KeySystem (key: SWEEKZI2K25)
--// IMPORTANT: This is for your own place/projects. Do not use to affect other games.

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

--------------------------------------------------------------------
-- UNIVERSAL TAB (movement + quality of life)
--------------------------------------------------------------------
local TabUniversal = Window:CreateTab("Universal", 4483362458)
TabUniversal:CreateSection("Movement & QoL (client debug)")

-- Noclip (dev)
local noclipOn = false
TabUniversal:CreateToggle({
    Name = "Noclip (dev)",
    CurrentValue = false,
    Callback = function(state)
        noclipOn = state
        if state then notify("Noclip", "Enabled", 2) else notify("Noclip", "Disabled", 2) end
        task.spawn(function()
            while noclipOn do
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
                RS.Heartbeat:Wait()
            end
        end)
    end
})

-- Fly (dev)
local flyOn, flySpeed = false, 60
TabUniversal:CreateToggle({
    Name = "Fly (WASD/Space/Ctrl)",
    CurrentValue = false,
    Callback = function(state)
        flyOn = state
        local hrp = getHRP()
        if not hrp then return end
        if flyOn then
            notify("Fly", "Enabled", 2)
            task.spawn(function()
                while flyOn and hrp do
                    local dir = Vector3.zero
                    if UIS:IsKeyDown(Enum.KeyCode.W) then dir += -hrp.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then dir += hrp.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then dir += -hrp.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then dir += hrp.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir += Vector3.new(0,-1,0) end
                    hrp.Velocity = dir * flySpeed
                    RS.Heartbeat:Wait()
                end
                if hrp then hrp.Velocity = Vector3.zero end
            end)
        else
            notify("Fly", "Disabled", 2)
        end
    end
})

TabUniversal:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 250},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = flySpeed,
    Callback = function(v) flySpeed = v end
})

-- Sprint (Shift) multiplier
local sprintMul = 2
local sprinting = false
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
        if h then
            h.WalkSpeed = h.WalkSpeed * sprintMul
            sprinting = true
        end
    end
end)

UIS.InputEnded:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.LeftShift then
        local h = getHumanoid()
        if h and sprinting then
            h.WalkSpeed = h.WalkSpeed / sprintMul
            sprinting = false
        end
    end
end)

-- WalkSpeed / JumpPower
TabUniversal:CreateSlider({
    Name = "WalkSpeed",
    Range = {8, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) local h=getHumanoid(); if h then h.WalkSpeed=v end end
})

TabUniversal:CreateSlider({
    Name = "JumpPower",
    Range = {25, 300},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) local h=getHumanoid(); if h then h.JumpPower=v end end
})

-- Anti-Fall & Anti-Idle
TabUniversal:CreateToggle({
    Name = "Anti-Fall (teleport Y<-100)",
    CurrentValue = false,
    Callback = function(state)
        if not state then return end
        task.spawn(function()
            while state do
                local hrp = getHRP()
                if hrp and hrp.Position.Y < -100 then
                    hrp.CFrame = CFrame.new(0, 15, 0)
                end
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
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
                task.wait(60)
            end
        end)
    end
})

TabUniversal:CreateButton({
    Name = "Respawn",
    Callback = function() LocalPlayer:LoadCharacter() end
})

--------------------------------------------------------------------
-- CAMERA TAB (freecam, FOV, zoom)
--------------------------------------------------------------------
local TabCam = Window:CreateTab("Camera", 4483362458)
TabCam:CreateSection("Freecam & View")

local cam = workspace.CurrentCamera
local freecamOn, camSpeed = false, 2

TabCam:CreateToggle({
    Name = "Freecam (Scriptable)",
    CurrentValue = false,
    Callback = function(state)
        freecamOn = state
        if state then
            cam.CameraType = Enum.CameraType.Scriptable
            task.spawn(function()
                while freecamOn do
                    local move = Vector3.zero
                    if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then move += -cam.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then move += -cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move += Vector3.new(0,-1,0) end
                    cam.CFrame = cam.CFrame + (move * camSpeed)
                    RS.RenderStepped:Wait()
                end
                cam.CameraType = Enum.CameraType.Custom
            end)
        else
            cam.CameraType = Enum.CameraType.Custom
        end
    end
})

TabCam:CreateSlider({
    Name = "Freecam Speed",
    Range = {0.5, 10},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = camSpeed,
    Callback = function(v) camSpeed = v end
})

TabCam:CreateSlider({
    Name = "Field of View (FOV)",
    Range = {40, 120},
    Increment = 1,
    CurrentValue = cam.FieldOfView,
    Callback = function(v) cam.FieldOfView = v end
})

TabCam:CreateSlider({
    Name = "Max Zoom Distance",
    Range = {4, 200},
    Increment = 2,
    CurrentValue = LocalPlayer.CameraMaxZoomDistance,
    Callback = function(v) LocalPlayer.CameraMaxZoomDistance = v end
})

--------------------------------------------------------------------
-- VISUAL DEBUG TAB (Highlights/ESP-like for tagged instances)
--------------------------------------------------------------------
local TabVis = Window:CreateTab("Visual Debug", 4483362458)
TabVis:CreateSection("Highlights via CollectionService tags")

local activeHL = {}
local function clearHL()
    for inst, hl in pairs(activeHL) do
        if hl and hl.Parent then hl:Destroy() end
        activeHL[inst] = nil
    end
end

local function makeHL(model, fillTrans, outline)
    if activeHL[model] then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = model
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = fillTrans or 0.75
    hl.OutlineTransparency = outline or 0
    hl.Parent = model
    activeHL[model] = hl
end

local function toggleTagHighlights(tagName, state)
    if not state then
        -- remove this tag highlights only
        for inst, hl in pairs(activeHL) do
            if CollectionService:HasTag(inst, tagName) then
                if hl and hl.Parent then hl:Destroy() end
                activeHL[inst] = nil
            end
        end
        return
    end
    for _, inst in ipairs(CollectionService:GetTagged(tagName)) do
        if inst:IsA("Model") then makeHL(inst) end
    end
    CollectionService:GetInstanceAddedSignal(tagName):Connect(function(inst)
        if inst:IsA("Model") then makeHL(inst) end
    end)
    CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(inst)
        local hl = activeHL[inst]
        if hl then hl:Destroy(); activeHL[inst] = nil end
    end)
end

TabVis:CreateToggle({
    Name = "Tag: Enemy",
    CurrentValue = false,
    Callback = function(state) toggleTagHighlights("Enemy", state) end
})

TabVis:CreateToggle({
    Name = "Tag: NPC",
    CurrentValue = false,
    Callback = function(state) toggleTagHighlights("NPC", state) end
})

TabVis:CreateToggle({
    Name = "Tag: Item",
    CurrentValue = false,
    Callback = function(state) toggleTagHighlights("Item", state) end
})

TabVis:CreateButton({
    Name = "Clear All Highlights",
    Callback = function() clearHL() end
})

--------------------------------------------------------------------
-- TELEPORT & WAYPOINTS TAB
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
        local hrp = getHRP()
        if not hrp then return end
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
        if cf and hrp then
            hrp.CFrame = cf + Vector3.new(0, 3, 0)
        else
            notify("Teleport", "Waypoint not found", 2)
        end
    end
})

TabTP:CreateButton({
    Name = "List Waypoints (output)",
    Callback = function()
        local list = {}
        for k,_ in pairs(waypoints) do table.insert(list, k) end
        print("[Waypoints]", table.concat(list, ", "))
        notify("Waypoints", "Printed in output", 2)
    end
})

--------------------------------------------------------------------
-- TOOLS TAB (lighting, time, tween TP, console)
--------------------------------------------------------------------
local TabTools = Window:CreateTab("Tools", 4483362458)
TabTools:CreateSection("World & Utilities")

TabTools:CreateSlider({
    Name = "TimeOfDay",
    Range = {0, 24},
    Increment = 0.25,
    Suffix = "h",
    CurrentValue = tonumber(Lighting.ClockTime),
    Callback = function(v) Lighting.ClockTime = v end
})

TabTools:CreateToggle({
    Name = "Global Shadows",
    CurrentValue = Lighting.GlobalShadows,
    Callback = function(state) Lighting.GlobalShadows = state end
})

TabTools:CreateToggle({
    Name = "Ambient Boost",
    CurrentValue = false,
    Callback = function(state)
        if state then
            Lighting.Ambient = Color3.fromRGB(80,80,80)
            Lighting.OutdoorAmbient = Color3.fromRGB(80,80,80)
        else
            Lighting.Ambient = Color3.fromRGB(0,0,0)
            Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
        end
    end
})

-- Tween Teleport to current camera look point
TabTools:CreateButton({
    Name = "Tween to Camera Look (20 studs)",
    Callback = function()
        local hrp = getHRP(); if not hrp then return end
        local target = workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * 20
        local tween = TweenService:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(target)})
        tween:Play()
    end
})

-- Simple console logger (prints)
TabTools:CreateButton({
    Name = "Print Player Info",
    Callback = function()
        local h = getHumanoid()
        local hrp = getHRP()
        print("[PlayerInfo]",
            "Name=", LocalPlayer.Name,
            "WS=", h and h.WalkSpeed,
            "JP=", h and h.JumpPower,
            "Pos=", hrp and hrp.Position
        )
        notify("Info", "Printed in output", 2)
    end
})

--------------------------------------------------------------------
-- DEBUG & METRICS TAB (FPS, memory)
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
                local last = tick()
                local frames = 0
                while showFps do
                    RS.RenderStepped:Wait()
                    frames += 1
                    local now = tick()
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

TabDbg:CreateButton({
    Name = "Print Memory (MB)",
    Callback = function()
        local mem = (Stats:GetTotalMemoryUsageMb())
        print("[Memory]", mem)
        notify("Memory", string.format("%.1f MB", mem), 3)
    end
})

--------------------------------------------------------------------
-- INTEGRATIONS TAB (HD Admin, custom modules)
--------------------------------------------------------------------
local TabInt = Window:CreateTab("Integrations", 4483362458)
TabInt:CreateSection("Admin & Modules (safe)")

-- HD Admin helper: detect presence and guide
TabInt:CreateButton({
    Name = "Detect HD Admin",
    Callback = function()
        local found = game:GetService("ReplicatedStorage"):FindFirstChild("HDAdminClient") or game:GetService("ReplicatedStorage"):FindFirstChild("HDAdminHDClient") or game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
        if found then
            notify("HD Admin", "Detected some HD Admin client assets. Use chat :cmds", 5)
        else
            notify("HD Admin", "Not detected. Insert HD Admin from Toolbox in YOUR game.", 5)
        end
    end
})

-- Custom Module Loader (from ReplicatedStorage.AdminModules)
TabInt:CreateButton({
    Name = "Load All Custom Modules (ReplicatedStorage/AdminModules)",
    Callback = function()
        local folder = game:GetService("ReplicatedStorage"):FindFirstChild("AdminModules")
        if not folder then
            notify("Modules", "No AdminModules folder in ReplicatedStorage", 4)
            return
        end
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

-- NOTE: We do NOT auto-load third-party exploits (e.g., Infinite Yield). Keep modules first-party & safe.

--------------------------------------------------------------------
-- END
--------------------------------------------------------------------
notify("Admin Menu", "Loaded. Use responsibly in YOUR game.", 4)
