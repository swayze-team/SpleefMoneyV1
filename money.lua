-- Création d'un ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Frame principale
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- UICorner pour arrondir
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Titre
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Auto Increment GUI"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

-- TextBox pour valeur de départ
local startBox = Instance.new("TextBox")
startBox.Size = UDim2.new(0.8, 0, 0, 30)
startBox.Position = UDim2.new(0.1, 0, 0.3, 0)
startBox.PlaceholderText = "Valeur de départ"
startBox.Text = "33227"
startBox.Font = Enum.Font.Gotham
startBox.TextSize = 16
startBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
startBox.TextColor3 = Color3.fromRGB(255, 255, 255)
startBox.Parent = mainFrame

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 6)
corner2.Parent = startBox

-- TextBox pour l'incrément
local stepBox = Instance.new("TextBox")
stepBox.Size = UDim2.new(0.8, 0, 0, 30)
stepBox.Position = UDim2.new(0.1, 0, 0.5, 0)
stepBox.PlaceholderText = "Incrément (+)"
stepBox.Text = "100000"
stepBox.Font = Enum.Font.Gotham
stepBox.TextSize = 16
stepBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
stepBox.TextColor3 = Color3.fromRGB(255, 255, 255)
stepBox.Parent = mainFrame

local corner3 = Instance.new("UICorner")
corner3.CornerRadius = UDim.new(0, 6)
corner3.Parent = stepBox

-- Bouton Toggle
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.6, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.2, 0, 0.75, 0)
toggleBtn.Text = "▶ Start"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = mainFrame

local corner4 = Instance.new("UICorner")
corner4.CornerRadius = UDim.new(0, 8)
corner4.Parent = toggleBtn

-- Script logique
local running = false
local value = 0

toggleBtn.MouseButton1Click:Connect(function()
    running = not running
    if running then
        toggleBtn.Text = "■ Stop"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

        -- Récupère les paramètres
        value = tonumber(startBox.Text) or 0
        local step = tonumber(stepBox.Text) or 1

        -- Lancement de la boucle
        task.spawn(function()
            while running do
                print("Valeur actuelle :", value) -- 🔹 Ici tu mets ton propre code
                value = value + step
                task.wait(0.5) -- délai ajustable
            end
        end)
    else
        toggleBtn.Text = "▶ Start"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
    end
end)
