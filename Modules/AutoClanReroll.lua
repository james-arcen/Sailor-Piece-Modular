-- Auto Clan Reroll - Auto-reroll clan
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}

function Module:Init()
    self.IsRunning = false
end

function Module:StartReroll()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(2) do
            pcall(function()
                local rerollRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("RerollClan")
                if rerollRemote then
                    rerollRemote:FireServer()
                end
            end)
        end
    end)
end

function Module:StopReroll()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartReroll() else self:StopReroll() end
end

function Module:Start()
    local tab = "Misc & Config"
    UI:CreateSection(tab, "Auto Clan Reroll")
    UI:CreateToggle(tab, "Auto Reroll Clan", function(state) self:Toggle(state) end)
end

return Module
