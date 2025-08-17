-- Charge Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Création de la fenêtre
local Window = Rayfield:CreateWindow({
   Name = "Auto Increment System",
   LoadingTitle = "Auto Coins",
   LoadingSubtitle = "Rayfield UI",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false,
})

-- Services Roblox
local CoinsEvent = game:GetService("ReplicatedStorage").Remotes.Server.CoinsUpdated
local FriendBoostEvent = game:GetService("ReplicatedStorage").Remotes.Server.FriendCoinBoostUpdated

-- Variables
local running = false
local value = 33227
local step = 100000

-- Onglet principal
local Tab = Window:CreateTab("Main", 4483362458)

-- Section config
Tab:CreateSection("Configuration")

-- Input pour valeur de départ
Tab:CreateInput({
   Name = "Valeur de départ",
   PlaceholderText = "33227",
   RemoveTextAfterFocusLost = true,
   Callback = function(txt)
      local num = tonumber(txt)
      if num then
         value = num
         Rayfield:Notify({
            Title = "✅ Valeur de départ changée",
            Content = "Nouvelle valeur: " .. tostring(value),
            Duration = 3
         })
      end
   end,
})

-- Input pour l’incrément
Tab:CreateInput({
   Name = "Incrément (+)",
   PlaceholderText = "100000",
   RemoveTextAfterFocusLost = true,
   Callback = function(txt)
      local num = tonumber(txt)
      if num then
         step = num
         Rayfield:Notify({
            Title = "✅ Incrément changé",
            Content = "Nouveau step: " .. tostring(step),
            Duration = 3
         })
      end
   end,
})

-- Toggle Auto Increment
Tab:CreateToggle({
   Name = "Auto Increment",
   CurrentValue = false,
   Flag = "AutoIncrement",
   Callback = function(state)
      running = state
      if running then
         Rayfield:Notify({
            Title = "▶ Auto Increment démarré",
            Content = "Valeur initiale: " .. tostring(value),
            Duration = 4
         })
         task.spawn(function()
            while running do
                -- CoinsUpdated
                firesignal(CoinsEvent.OnClientEvent, value, 10)

                -- FriendCoinBoostUpdated (+1)
                firesignal(FriendBoostEvent.OnClientEvent, 1)

                -- Ajout incrément
                value = value + step

                task.wait(0.5) -- délai entre chaque envoi
            end
         end)
      else
         Rayfield:Notify({
            Title = "■ Auto Increment arrêté",
            Content = "La boucle est stoppée",
            Duration = 3
         })
      end
   end,
})
