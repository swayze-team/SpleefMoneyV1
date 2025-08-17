-- Charger Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Créer la fenêtre principale
local Window = Rayfield:CreateWindow({
   Name = "Admin Test Menu",
   LoadingTitle = "Rayfield Admin",
   LoadingSubtitle = "Test Functions",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false,
})

-- Services Roblox
local CoinsEvent = game:GetService("ReplicatedStorage").Remotes.Server.CoinsUpdated
local FriendBoostEvent = game:GetService("ReplicatedStorage").Remotes.Server.FriendCoinBoostUpdated
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variables globales
local running = false
local value = 33227
local step = 100000

----------------------------------------------------------------------
-- Onglet MAIN
----------------------------------------------------------------------

local TabMain = Window:CreateTab("Main", 4483362458)
TabMain:CreateSection("Auto Increment Config")

-- Input valeur de départ
TabMain:CreateInput({
   Name = "Valeur de départ",
   PlaceholderText = "33227",
   RemoveTextAfterFocusLost = true,
   Callback = function(txt)
      local num = tonumber(txt)
      if num then
         value = num
      end
   end,
})

-- Input incrément
TabMain:CreateInput({
   Name = "Incrément (+)",
   PlaceholderText = "100000",
   RemoveTextAfterFocusLost = true,
   Callback = function(txt)
      local num = tonumber(txt)
      if num then
         step = num
      end
   end,
})

-- Toggle Auto Increment
TabMain:CreateToggle({
   Name = "Auto Increment",
   CurrentValue = false,
   Flag = "AutoIncrement",
   Callback = function(state)
      running = state
      if running then
         task.spawn(function()
            while running do
                firesignal(CoinsEvent.OnClientEvent, value, 10)
                firesignal(FriendBoostEvent.OnClientEvent, 1)
                value = value + step
                task.wait(0.5)
            end
         end)
      end
   end,
})

----------------------------------------------------------------------
-- Onglet UNIVERSAL
----------------------------------------------------------------------

local TabUniversal = Window:CreateTab("Universal", 4483362458)
TabUniversal:CreateSection("Player Utilities")

-- Noclip
local noclip = false
TabUniversal:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(state)
      noclip = state
      task.spawn(function()
         while noclip do
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
               if part:IsA("BasePart") and part.CanCollide then
                  part.CanCollide = false
               end
            end
            task.wait()
         end
      end)
   end,
})

-- Antifling
TabUniversal:CreateToggle({
   Name = "Anti-Fling",
   CurrentValue = false,
   Flag = "AntiFling",
   Callback = function(state)
      if state then
         LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(1)
            for _, part in pairs(char:GetDescendants()) do
               if part:IsA("BasePart") then
                  part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
               end
            end
         end)
      end
   end,
})

-- Fly
local flying = false
local speed = 50
TabUniversal:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "Fly",
   Callback = function(state)
      flying = state
      local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if flying and humanoidRootPart then
         task.spawn(function()
            local UIS = game:GetService("UserInputService")
            local RunService = game:GetService("RunService")

            while flying do
               local moveDir = Vector3.zero
               if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += Vector3.new(0,0,-1) end
               if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir += Vector3.new(0,0,1) end
               if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir += Vector3.new(-1,0,0) end
               if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += Vector3.new(1,0,0) end
               if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
               if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir += Vector3.new(0,-1,0) end

               humanoidRootPart.Velocity = moveDir * speed
               RunService.Heartbeat:Wait()
            end

            humanoidRootPart.Velocity = Vector3.zero
         end)
      end
   end,
})

-- Slider pour vitesse du fly
TabUniversal:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 200},
   Increment = 10,
   Suffix = "Studs",
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(val)
      speed = val
   end,
})
