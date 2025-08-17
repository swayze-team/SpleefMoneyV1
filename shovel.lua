--// LocalScript (StarterPlayerScripts)
-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--== Fenêtre avec KeySystem intégré
local Window = Rayfield:CreateWindow({
    Name = "Admin Test Menu",
    LoadingTitle = "Rayfield Admin Tools",
    LoadingSubtitle = "For YOUR game only",
    ConfigurationSaving = { Enabled = false },
    KeySystem = true,
    KeySettings = {
        Title = "Admin Access",
        Subtitle = "Enter Access Key",
        Note = "Private dev tools for YOUR place",
        FileName = "AdminTest_Key",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = "SWEEKZI2K25"  -- << ta clé
    }
})

--== Services & refs
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

--=====[ Onglet MAIN : compteur de test ]=====
local TabMain = Window:CreateTab("Main", 4483362458)
TabMain:CreateSection("Counter (client-only debug)")

local counterRunning = false
local counterValue = 33227
local counterStep  = 100000
local tickDelay    = 0.5

TabMain:CreateInput({
    Name = "Valeur de départ",
    PlaceholderText = tostring(counterValue),
    RemoveTextAfterFocusLost = true,
    Callback = function(txt) counterValue = tonumber(txt) or counterValue end
})

TabMain:CreateInput({
    Name = "Incrément (+)",
    PlaceholderText = tostring(counterStep),
    RemoveTextAfterFocusLost = true,
    Callback = function(txt) counterStep = tonumber(txt) or counterStep end
})

TabMain:CreateSlider({
    Name = "Délai (s)",
    Range = {0.05, 5},
    Increment = 0.05,
    Suffix = "sec",
    CurrentValue = tickDelay,
    Callback = function(val) tickDelay = val end
})

TabMain:CreateToggle({
    Name = "Start/Stop",
    CurrentValue = false,
    Callback = function(state)
        counterRunning = state
        if state then
            task.spawn(function()
                while counterRunning do
                    -- Ici: ton traitement de test local
                    print("[Counter]", counterValue)
                    counterValue += counterStep
                    task.wait(tickDelay)
                end
            end)
        end
    end
})

--=====[ Onglet UNIVERSAL : noclip / fly / freecam ]=====
local TabUni = Window:CreateTab("Universal", 4483362458)
TabUni:CreateSection("Movement (dev)")

-- Noclip (client debug)
local noclipOn = false
TabUni:CreateToggle({
    Name = "Noclip (dev)",
    CurrentValue = false,
    Callback = function(state)
        noclipOn = state
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
TabUni:CreateToggle({
    Name = "Fly (dev) - WASD / Space / Ctrl",
    CurrentValue = false,
    Callback = function(state)
        flyOn = state
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if flyOn then
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
        end
    end
})

TabUni:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = flySpeed,
    Callback = function(v) flySpeed = v end
})

-- Freecam (dev) – caméra scriptable
local freecamOn = false
local cam = workspace.CurrentCamera
local camSpeed = 2
TabUni:CreateToggle({
    Name = "Freecam (dev)",
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

TabUni:CreateSlider({
    Name = "Freecam Speed",
    Range = {0.5, 10},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = camSpeed,
    Callback = function(v) camSpeed = v end
})

--=====[ Onglet VISUAL DEBUG : “ESP” de debug via Highlight ]=====
local TabVis = Window:CreateTab("Visual Debug", 4483362458)
TabVis:CreateSection("Highlights (dev)")

-- Met un Highlight sur les entités taguées "Enemy" (à toi de taguer côté Studio)
local highlightEnemies = false
local activeHighlights = {}

local function clearHighlights()
    for inst, hl in pairs(activeHighlights) do
        if hl and hl.Parent then hl:Destroy() end
        activeHighlights[inst] = nil
    end
end

local function ensureHighlight(model)
    if activeHighlights[model] then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = model
    hl.Parent = model
    activeHighlights[model] = hl
end

TabVis:CreateToggle({
    Name = "Highlight: Enemies (CollectionService tag 'Enemy')",
    CurrentValue = false,
    Callback = function(state)
        highlightEnemies = state
        clearHighlights()
        if state then
            -- Appliquer aux existants
            for _, inst in ipairs(CollectionService:GetTagged("Enemy")) do
                if inst:IsA("Model") then ensureHighlight(inst) end
            end
            -- Écouter les nouveaux
            CollectionService:GetInstanceAddedSignal("Enemy"):Connect(function(inst)
                if highlightEnemies and inst:IsA("Model") then ensureHighlight(inst) end
            end)
            CollectionService:GetInstanceRemovedSignal("Enemy"):Connect(function(inst)
                local hl = activeHighlights[inst]
                if hl then hl:Destroy(); activeHighlights[inst] = nil end
            end)
        end
    end
})

TabVis:CreateButton({
    Name = "Clear Highlights",
    Callback = function() clearHighlights() end
})

--=====[ Onglet MOVEMENT : WalkSpeed / JumpPower (client debug) ]=====
local TabMove = Window:CreateTab("Movement", 4483362458)
TabMove:CreateSection("Humanoid Tweaks (client)")

local function getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

TabMove:CreateSlider({
    Name = "WalkSpeed",
    Range = {8, 200},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Callback = function(v)
        local h = getHumanoid()
        if h then h.WalkSpeed = v end
    end
})

TabMove:CreateSlider({
    Name = "JumpPower",
    Range = {25, 300},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Callback = function(v)
        local h = getHumanoid()
        if h then h.JumpPower = v end
    end
})

--=====[ Onglet TOOLS : utilitaires ]=====
local TabTools = Window:CreateTab("Tools", 4483362458)
TabTools:CreateSection("Utilities")

TabTools:CreateButton({
    Name = "Respawn Character",
    Callback = function()
        LocalPlayer:LoadCharacter()
    end
})

TabTools:CreateToggle({
    Name = "Anti-Fall (auto up if Y<-100)",
    CurrentValue = false,
    Callback = function(state)
        if not state then return end
        task.spawn(function()
            while state do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -100 then
                    hrp.CFrame = CFrame.new(0, 10, 0)
                end
                task.wait(0.25)
            end
        end)
    end
})

-- Fin : tout est côté client pour **debug dans TON jeu**. 
