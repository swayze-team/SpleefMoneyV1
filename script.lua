--// LocalScript (StarterPlayerScripts)
--// Octopus Universal - Advanced Admin Menu
--// Rayfield UI + KeySystem (key: SWEEKZI2K25)
--// Designed for comprehensive game administration and debugging

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Theme configurations
local Themes = {
    Dark = {
        Name = "Dark",
        AccentColor = Color3.fromRGB(138, 43, 226),
        TextColor = Color3.fromRGB(255, 255, 255),
        BackgroundColor = Color3.fromRGB(30, 30, 30),
        ElementColor = Color3.fromRGB(40, 40, 40)
    },
    Ocean = {
        Name = "Ocean",
        AccentColor = Color3.fromRGB(0, 123, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        BackgroundColor = Color3.fromRGB(13, 27, 42),
        ElementColor = Color3.fromRGB(23, 37, 52)
    },
    Forest = {
        Name = "Forest",
        AccentColor = Color3.fromRGB(34, 139, 34),
        TextColor = Color3.fromRGB(255, 255, 255),
        BackgroundColor = Color3.fromRGB(22, 33, 22),
        ElementColor = Color3.fromRGB(32, 43, 32)
    },
    Sunset = {
        Name = "Sunset",
        AccentColor = Color3.fromRGB(255, 69, 0),
        TextColor = Color3.fromRGB(255, 255, 255),
        BackgroundColor = Color3.fromRGB(42, 22, 13),
        ElementColor = Color3.fromRGB(52, 32, 23)
    },
    Purple = {
        Name = "Purple",
        AccentColor = Color3.fromRGB(148, 0, 211),
        TextColor = Color3.fromRGB(255, 255, 255),
        BackgroundColor = Color3.fromRGB(33, 13, 42),
        ElementColor = Color3.fromRGB(43, 23, 52)
    },
    Neon = {
        Name = "Neon",
        AccentColor = Color3.fromRGB(0, 255, 127),
        TextColor = Color3.fromRGB(0, 0, 0),
        BackgroundColor = Color3.fromRGB(10, 10, 10),
        ElementColor = Color3.fromRGB(20, 20, 20)
    }
}

local currentTheme = Themes.Dark

-- Create window with KeySystem and theme
local Window = Rayfield:CreateWindow({
    Name = "🐙 Octopus Universal",
    LoadingTitle = "Octopus Universal Loading...",
    LoadingSubtitle = "Advanced Admin & Debug Tools",
    ConfigurationSaving = { 
        Enabled = true,
        FolderName = "OctopusUniversal",
        FileName = "OctopusConfig"
    },
    KeySystem = true,
    KeySettings = {
        Title = "🐙 Octopus Access",
        Subtitle = "Enter Universal Access Key",
        Note = "Advanced admin tools for YOUR place only",
        FileName = "OctopusUniversal_Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = "SWEEKZI2K25"
    },
    Theme = currentTheme.Name
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
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local InsertService = game:GetService("InsertService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local Chat = game:GetService("Chat")

-- Global Variables
local PlayerData = {
    originalWalkSpeed = 16,
    originalJumpHeight = 7.2,
    originalGravity = 196.2,
    originalFOV = 70,
    isFlying = false,
    isNoclipping = false,
    isSprinting = false,
    godMode = false,
    infiniteStamina = false,
    autoRespawn = false
}

local GameData = {
    startTime = tick(),
    totalPlayTime = 0,
    deaths = 0,
    jumps = 0,
    teleports = 0
}

-- Utility Functions
local function notify(title, content, dur, icon)
    Rayfield:Notify({
        Title = title or "Octopus Universal",
        Content = content or "",
        Duration = dur or 3,
        Image = icon or 4483362458
    })
end

local function getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function getRootPart()
    return getHRP()
end

local function getCharacter()
    return LocalPlayer.Character
end

local function onRespawn(callback)
    LocalPlayer.CharacterAdded:Connect(function()
        task.defer(callback)
    end)
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Octopus Universal] Error:", result)
    end
    return success, result
end

local function formatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(math.floor(num))
    end
end

local function getRainbowColor(offset)
    offset = offset or 0
    local hue = (tick() * 0.5 + offset) % 1
    return Color3.fromHSV(hue, 1, 1)
end

local function createSound(id, volume, pitch)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(id)
    sound.Volume = volume or 0.5
    sound.Pitch = pitch or 1
    sound.Parent = SoundService
    return sound
end

-- Advanced Movement System
local MovementSystem = {
    fly = {
        enabled = false,
        speed = 80,
        maxSpeed = 1000,
        acceleration = 5,
        bv = nil,
        bg = nil,
        conn = nil,
        antiGravity = nil,
        smoothness = 0.2
    },
    
    noclip = {
        enabled = false,
        originals = {},
        loop = nil,
        parts = {}
    },
    
    sprint = {
        enabled = false,
        multiplier = 2,
        maxSpeed = 1000,
        originalSpeed = 16,
        isActive = false,
        connection = nil
    },
    
    swim = {
        enabled = false,
        speed = 50,
        buoyancy = nil
    },
    
    wallClimb = {
        enabled = false,
        speed = 50,
        connection = nil
    }
}

-- Improved Sprint System
function MovementSystem.sprint:initialize()
    self.connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.LeftShift then
            self:activate()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.LeftShift then
            self:deactivate()
        end
    end)
end

function MovementSystem.sprint:activate()
    if not self.enabled or self.isActive then return end
    
    local humanoid = getHumanoid()
    if not humanoid then return end
    
    self.originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = math.min(self.originalSpeed * self.multiplier, self.maxSpeed)
    self.isActive = true
    
    -- Visual effect
    local character = getCharacter()
    if character then
        local effect = Instance.new("Sparkles")
        effect.Color = getRainbowColor()
        effect.Parent = character:FindFirstChild("HumanoidRootPart")
        effect.Name = "SprintEffect"
    end
end

function MovementSystem.sprint:deactivate()
    if not self.isActive then return end
    
    local humanoid = getHumanoid()
    if not humanoid then return end
    
    humanoid.WalkSpeed = self.originalSpeed
    self.isActive = false
    
    -- Remove visual effect
    local character = getCharacter()
    if character then
        local effect = character:FindFirstChild("HumanoidRootPart"):FindFirstChild("SprintEffect")
        if effect then effect:Destroy() end
    end
end

-- Advanced Fly System
function MovementSystem.fly:start()
    if self.enabled then return end
    
    local hrp = getHRP()
    if not hrp then return end
    
    self.enabled = true
    
    -- Create BodyVelocity for movement
    self.bv = Instance.new("BodyVelocity")
    self.bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    self.bv.Velocity = Vector3.zero
    self.bv.Parent = hrp

    -- Create BodyGyro for rotation
    self.bg = Instance.new("BodyGyro")
    self.bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    self.bg.P = 9e4
    self.bg.D = 5e3
    self.bg.CFrame = workspace.CurrentCamera.CFrame
    self.bg.Parent = hrp

    -- Anti-gravity
    self.antiGravity = Instance.new("BodyPosition")
    self.antiGravity.MaxForce = Vector3.new(0, 1e5, 0)
    self.antiGravity.Position = hrp.Position
    self.antiGravity.Parent = hrp

    local currentVelocity = Vector3.zero
    
    self.conn = RS.RenderStepped:Connect(function(dt)
        local camCF = workspace.CurrentCamera.CFrame
        self.bg.CFrame = camCF
        
        local targetVelocity = Vector3.zero
        
        -- Movement input
        if UIS:IsKeyDown(Enum.KeyCode.W) then targetVelocity += camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then targetVelocity += -camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then targetVelocity += -camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then targetVelocity += camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then 
            targetVelocity += Vector3.new(0, 1, 0) 
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) then 
            targetVelocity += Vector3.new(0, -1, 0) 
        end
        
        -- Speed boost
        local speed = self.speed
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            speed = speed * 2
        end
        
        if targetVelocity.Magnitude > 0 then
            targetVelocity = targetVelocity.Unit * speed
        end
        
        -- Smooth acceleration
        currentVelocity = currentVelocity:lerp(targetVelocity, self.smoothness)
        self.bv.Velocity = currentVelocity
        
        -- Update anti-gravity position
        self.antiGravity.Position = hrp.Position
    end)
    
    notify("Flight System", "Enabled - WASD to move, Space/E up, Ctrl/Q down, Shift to boost", 4)
end

function MovementSystem.fly:stop()
    if not self.enabled then return end
    
    self.enabled = false
    
    if self.conn then
        self.conn:Disconnect()
        self.conn = nil
    end
    
    if self.bv then self.bv:Destroy() self.bv = nil end
    if self.bg then self.bg:Destroy() self.bg = nil end
    if self.antiGravity then self.antiGravity:Destroy() self.antiGravity = nil end
    
    local hrp = getHRP()
    if hrp then
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end
    
    notify("Flight System", "Disabled", 2)
end

-- Advanced Noclip System
function MovementSystem.noclip:start()
    if self.enabled then return end
    
    self.enabled = true
    
    self.loop = RS.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if self.originals[part] == nil then
                    self.originals[part] = part.CanCollide
                end
                if part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    notify("Noclip System", "Enabled - Walk through walls and objects", 2)
end

function MovementSystem.noclip:stop()
    if not self.enabled then return end
    
    self.enabled = false
    
    if self.loop then
        self.loop:Disconnect()
        self.loop = nil
    end
    
    -- Restore original collision states
    for part, original in pairs(self.originals) do
        if part and part.Parent and part:IsA("BasePart") then
            part.CanCollide = original
        end
    end
    
    self.originals = {}
    notify("Noclip System", "Disabled", 2)
end

-- Advanced ESP System
local ESPSystem = {
    players = {
        enabled = false,
        showDistance = true,
        showHealth = true,
        showTeam = true,
        connections = {},
        objects = {}
    },
    
    items = {
        enabled = false,
        connections = {},
        objects = {}
    },
    
    vehicles = {
        enabled = false,
        connections = {},
        objects = {}
    }
}

function ESPSystem.players:toggle(state)
    self.enabled = state
    
    if state then
        -- Enable player ESP
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                self:createESP(player)
            end
        end
        
        -- Connect to new players
        self.connections.playerAdded = Players.PlayerAdded:Connect(function(player)
            self:createESP(player)
        end)
        
        self.connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
            self:removeESP(player)
        end)
        
        notify("Player ESP", "Enabled", 2)
    else
        -- Disable player ESP
        for _, connection in pairs(self.connections) do
            if connection then connection:Disconnect() end
        end
        self.connections = {}
        
        for _, object in pairs(self.objects) do
            if object then object:Destroy() end
        end
        self.objects = {}
        
        notify("Player ESP", "Disabled", 2)
    end
end

function ESPSystem.players:createESP(player)
    if not player.Character then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not hrp then return end
    
    -- Create highlight
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.FillColor = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    highlight.Parent = character
    
    -- Create billboard GUI
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = hrp
    billboardGui.Size = UDim2.new(0, 150, 0, 80)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = character
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = billboardGui
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = frame
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0.6, 0)
    infoLabel.Position = UDim2.new(0, 0, 0.4, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = frame
    
    -- Update info continuously
    local updateConnection
    updateConnection = RS.RenderStepped:Connect(function()
        if not player.Character or not getHRP() then
            updateConnection:Disconnect()
            return
        end
        
        local playerHRP = player.Character:FindFirstChild("HumanoidRootPart")
        local playerHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
        
        if playerHRP and playerHumanoid then
            local distance = (getHRP().Position - playerHRP.Position).Magnitude
            local health = playerHumanoid.Health
            local maxHealth = playerHumanoid.MaxHealth
            local team = player.Team and player.Team.Name or "No Team"
            
            local info = ""
            if self.showDistance then
                info = info .. "Distance: " .. math.floor(distance) .. " studs\n"
            end
            if self.showHealth then
                info = info .. "Health: " .. math.floor(health) .. "/" .. math.floor(maxHealth) .. "\n"
            end
            if self.showTeam then
                info = info .. "Team: " .. team
            end
            
            infoLabel.Text = info
            
            -- Update highlight color based on health
            local healthPercent = health / maxHealth
            highlight.FillColor = Color3.fromRGB(
                255 * (1 - healthPercent),
                255 * healthPercent,
                0
            )
        end
    end)
    
    self.objects[player] = {
        highlight = highlight,
        billboard = billboardGui,
        updateConnection = updateConnection
    }
end

function ESPSystem.players:removeESP(player)
    local objects = self.objects[player]
    if objects then
        if objects.highlight then objects.highlight:Destroy() end
        if objects.billboard then objects.billboard:Destroy() end
        if objects.updateConnection then objects.updateConnection:Disconnect() end
        self.objects[player] = nil
    end
end

-- Waypoint System
local WaypointSystem = {
    waypoints = {},
    maxWaypoints = 50,
    currentPath = nil,
    pathConnection = nil
}

function WaypointSystem:save(name, position, description)
    if #self.waypoints >= self.maxWaypoints then
        table.remove(self.waypoints, 1) -- Remove oldest
    end
    
    table.insert(self.waypoints, {
        name = name,
        position = position or getHRP().Position,
        cframe = CFrame.new(position or getHRP().Position),
        description = description or "",
        timestamp = os.time(),
        visits = 0
    })
    
    notify("Waypoint System", "Saved waypoint: " .. name, 2)
end

function WaypointSystem:teleportTo(name)
    for _, waypoint in ipairs(self.waypoints) do
        if waypoint.name == name then
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = waypoint.cframe + Vector3.new(0, 5, 0)
                waypoint.visits = waypoint.visits + 1
                GameData.teleports = GameData.teleports + 1
                notify("Waypoint System", "Teleported to: " .. name, 2)
                return true
            end
        end
    end
    
    notify("Waypoint System", "Waypoint not found: " .. name, 3)
    return false
end

function WaypointSystem:delete(name)
    for i, waypoint in ipairs(self.waypoints) do
        if waypoint.name == name then
            table.remove(self.waypoints, i)
            notify("Waypoint System", "Deleted waypoint: " .. name, 2)
            return true
        end
    end
    
    notify("Waypoint System", "Waypoint not found: " .. name, 3)
    return false
end

function WaypointSystem:createPath(targetName)
    local targetWaypoint = nil
    for _, waypoint in ipairs(self.waypoints) do
        if waypoint.name == targetName then
            targetWaypoint = waypoint
            break
        end
    end
    
    if not targetWaypoint then
        notify("Pathfinding", "Target waypoint not found", 3)
        return
    end
    
    local hrp = getHRP()
    if not hrp then return end
    
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentMaxSlope = 45,
        WaypointSpacing = 4
    })
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(hrp.Position, targetWaypoint.position)
    end)
    
    if not success then
        notify("Pathfinding", "Failed to create path: " .. errorMessage, 3)
        return
    end
    
    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        self:followPath(waypoints)
        notify("Pathfinding", "Following path to: " .. targetName, 3)
    else
        notify("Pathfinding", "Path computation failed", 3)
    end
end

function WaypointSystem:followPath(waypoints)
    local humanoid = getHumanoid()
    if not humanoid then return end
    
    local currentWaypointIndex = 1
    
    if self.pathConnection then
        self.pathConnection:Disconnect()
    end
    
    self.pathConnection = humanoid.MoveToFinished:Connect(function(reached)
        if reached and currentWaypointIndex < #waypoints then
            currentWaypointIndex = currentWaypointIndex + 1
            humanoid:MoveTo(waypoints[currentWaypointIndex].Position)
        elseif currentWaypointIndex >= #waypoints then
            self.pathConnection:Disconnect()
            self.pathConnection = nil
            notify("Pathfinding", "Destination reached!", 2)
        end
    end)
    
    humanoid:MoveTo(waypoints[currentWaypointIndex].Position)
end

-- Chat Commands System
local ChatCommands = {
    prefix = "/",
    commands = {},
    enabled = false,
    connection = nil
}

function ChatCommands:register(command, description, func)
    self.commands[command] = {
        description = description,
        func = func
    }
end

function ChatCommands:process(message)
    if not message:sub(1, 1) == self.prefix then return end
    
    local args = {}
    for word in message:gmatch("%S+") do
        table.insert(args, word)
    end
    
    local command = args[1]:sub(2):lower() -- Remove prefix
    table.remove(args, 1) -- Remove command from args
    
    local cmd = self.commands[command]
    if cmd then
        local success, error = pcall(cmd.func, args)
        if not success then
            notify("Command Error", error, 3)
        end
    end
end

function ChatCommands:enable()
    if self.enabled then return end
    self.enabled = true
    
    -- Try modern TextChatService first
    if TextChatService then
        self.connection = TextChatService.MessageReceived:Connect(function(textChatMessage)
            if textChatMessage.TextSource.UserId == LocalPlayer.UserId then
                self:process(textChatMessage.Text)
            end
        end)
    else
        -- Fallback to legacy Chat
        self.connection = LocalPlayer.Chatted:Connect(function(message)
            self:process(message)
        end)
    end
    
    notify("Chat Commands", "Enabled - Use " .. self.prefix .. "help for commands", 3)
end

function ChatCommands:disable()
    if not self.enabled then return end
    self.enabled = false
    
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
    
    notify("Chat Commands", "Disabled", 2)
end

-- Register default commands
ChatCommands:register("help", "Show available commands", function(args)
    print("=== Octopus Universal Commands ===")
    for cmd, info in pairs(ChatCommands.commands) do
        print(ChatCommands.prefix .. cmd .. " - " .. info.description)
    end
end)

ChatCommands:register("tp", "Teleport to coordinates (x, y, z)", function(args)
    local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
    if x and y and z then
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(x, y, z)
            notify("Teleport", string.format("Teleported to %.1f, %.1f, %.1f", x, y, z), 2)
        end
    end
end)

ChatCommands:register("ws", "Set walkspeed", function(args)
    local speed = tonumber(args[1])
    if speed and speed >= 0 and speed <= 1000 then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = speed
            notify("WalkSpeed", "Set to " .. speed, 2)
        end
    end
end)

ChatCommands:register("jp", "Set jump power", function(args)
    local power = tonumber(args[1])
    if power and power >= 0 and power <= 1000 then
        local humanoid = getHumanoid()
        if humanoid then
            if humanoid.UseJumpPower then
                humanoid.JumpPower = power
            else
                humanoid.JumpHeight = power
            end
            notify("Jump Power", "Set to " .. power, 2)
        end
    end
end)

ChatCommands:register("god", "Toggle god mode", function(args)
    PlayerData.godMode = not PlayerData.godMode
    local humanoid = getHumanoid()
    if humanoid and PlayerData.godMode then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    elseif humanoid then
        humanoid.MaxHealth = 100
        humanoid.Health = 100
    end
    notify("God Mode", PlayerData.godMode and "Enabled" or "Disabled", 2)
end)
