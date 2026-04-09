-- Auto Artifact - Auto-upgrade artifacts
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}

function Module:Init()
    self.IsRunning = false
end

function Module:StartUpgrade()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(2) do
            pcall(function()
                local artifactRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("UpgradeArtifact")
                if artifactRemote then
                    artifactRemote:FireServer()
                end
            end)
        end
    end)
end

function Module:StopUpgrade()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartUpgrade() else self:StopUpgrade() end
end

function Module:Start()
    local tab = "Skill Tree"
    UI:CreateSection(tab, "Auto Artifact")
    UI:CreateToggle(tab, "Auto Upgrade Artifacts", function(state) self:Toggle(state) end)
end

return Module
