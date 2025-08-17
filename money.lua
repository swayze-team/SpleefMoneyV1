-- Service
local Event = game:GetService("ReplicatedStorage").Remotes.Server.CoinsUpdated

-- Valeur de départ
local value = 33227

-- Boucle infinie
while true do
    -- On envoie l’événement avec la valeur courante
    firesignal(Event.OnClientEvent, value, 10)

    -- On ajoute +1000 pour la prochaine itération
    value = value + 100000

    -- Petite pause pour éviter de freeze (tu peux ajuster le temps)
    task.wait(0.1)
end
