-- Auto Blessing - Auto-apply blessings
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}

function Module:Init()
    self.IsRunning = false
end

function Module:StartBlessing()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(2) do
            pcall(function()
                local blessingRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ApplyBlessing")
                if blessingRemote then
                    blessingRemote:FireServer()
                end
            end)
        end
    end)
end

function Module:StopBlessing()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartBlessing() else self:StopBlessing() end
end

function Module:Start()
    local tab = "Blessing"
    UI:CreateSection(tab, "Auto Blessing")
    UI:CreateToggle(tab, "Auto Apply Blessings", function(state) self:Toggle(state) end)
end

return Module
