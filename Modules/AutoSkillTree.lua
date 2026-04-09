-- Auto Skill Tree - Auto-spend skill tree points
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}

function Module:Init()
    self.IsRunning = false
end

function Module:StartSpendPoints()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(1) do
            pcall(function()
                local skillTreeRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SkillTreeSpend")
                if skillTreeRemote then
                    skillTreeRemote:FireServer()
                end
            end)
        end
    end)
end

function Module:StopSpendPoints()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartSpendPoints() else self:StopSpendPoints() end
end

function Module:Start()
    local tab = "Skill Tree"
    UI:CreateSection(tab, "Auto Skill Tree")
    UI:CreateToggle(tab, "Auto Spend Skill Points", function(state) self:Toggle(state) end)
end

return Module
