-- Auto Enchant - Auto-enchant equipment
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}

function Module:Init()
    self.IsRunning = false
end

function Module:StartEnchant()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(1) do
            pcall(function()
                local enchantRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Enchant")
                if enchantRemote then
                    enchantRemote:FireServer()
                end
            end)
        end
    end)
end

function Module:StopEnchant()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartEnchant() else self:StopEnchant() end
end

function Module:Start()
    local tab = "Blessing"
    UI:CreateSection(tab, "Auto Enchant")
    UI:CreateToggle(tab, "Auto Enchant Equipment", function(state) self:Toggle(state) end)
end

return Module
