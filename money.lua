-- Charge Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

-- Création de la fenêtre
local Window = Rayfield:CreateWindow({
   Name = "Auto Increment System",
   LoadingTitle = "Auto Coins",
   LoadingSubtitle = "by ChatGPT",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

-- Valeurs
local running = false
local value = 33227
local step = 100000

-- Onglet
local Tab = Window:CreateTab("Main", 4483362458) -- Icône de Roblox par défaut

-- Section principale
Tab:CreateSection("Auto Increment Config")

-- Slider pour la valeur de départ
local StartValue = Tab:CreateInput({
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

-- Slider pour l'incrément
local StepValue = Tab:CreateInput({
   Name = "Incrément",
   PlaceholderText = "100000",
   RemoveTextAfterFocusLost = true,
   Callback = function(txt)
      local num = tonumber(txt)
      if num then
         step = num
      end
   end,
})

-- Toggle Start/Stop
local Toggle = Tab:CreateToggle({
   Name = "Auto Increment",
   CurrentValue = false,
   Flag = "AutoIncrement",
   Callback = function(state)
      running = state
      if running then
         task.spawn(function()
            while running do
                print("Valeur actuelle :", value) -- 🔹 Ici tu mets ton code firesignal
                value = value + step
                task.wait(0.5)
            end
         end)
      end
   end,
})
