-- Auto Rejoin - Auto-rejoin on disconnect
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")

local Module = {}

function Module:Init()
    self.IsRunning = false
end

function Module:StartRejoin()
    if self.IsRunning then return end
    self.IsRunning = true
    
    LP.Parent.PlayerAdded:Connect(function(player)
        if player == LP and self.IsRunning then
            task.wait(5)
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
        end
    end)
end

function Module:StopRejoin()
    self.IsRunning = false
end

function Module:Toggle(state)
    if state then self:StartRejoin() else self:StopRejoin() end
end

function Module:Start()
    local tab = "Player"
    UI:CreateSection(tab, "Auto Rejoin")
    UI:CreateToggle(tab, "Auto Rejoin on Disconnect", function(state) self:Toggle(state) end)
end

return Module
