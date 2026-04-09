-- Auto Boss Rush - Auto-farm boss rush
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local TeleportService = Import("Services/Teleport")
local CombatService = Import("Services/CombatService")
local PriorityService = Import("Services/PriorityService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}

function Module:Init()
    self.IsRunning = false
end

function Module:StartBossRush()
    if self.IsRunning then return end
    self.IsRunning = true
    CombatService:Start()
    PriorityService:Request("AutoBossRush")
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(5) do
            pcall(function()
                local rushRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("StartBossRush")
                if rushRemote then
                    rushRemote:FireServer()
                end
            end)
        end
    end)
end

function Module:StopBossRush()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
    CombatService:Stop()
    PriorityService:Release("AutoBossRush")
end

function Module:Toggle(state)
    if state then self:StartBossRush() else self:StopBossRush() end
end

function Module:Start()
    local tab = "Player"
    UI:CreateSection(tab, "Auto Boss Rush")
    UI:CreateToggle(tab, "Auto Farm Boss Rush", function(state) self:Toggle(state) end)
end

return Module
