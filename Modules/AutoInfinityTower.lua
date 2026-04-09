-- Auto Infinity Tower - Auto-farm infinity tower
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

function Module:StartTower()
    if self.IsRunning then return end
    self.IsRunning = true
    CombatService:Start()
    PriorityService:Request("AutoInfinityTower")
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(5) do
            pcall(function()
                local towerRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("StartTower")
                if towerRemote then
                    towerRemote:FireServer()
                end
            end)
        end
    end)
end

function Module:StopTower()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
    CombatService:Stop()
    PriorityService:Release("AutoInfinityTower")
end

function Module:Toggle(state)
    if state then self:StartTower() else self:StopTower() end
end

function Module:Start()
    local tab = "Player"
    UI:CreateSection(tab, "Auto Infinity Tower")
    UI:CreateToggle(tab, "Auto Farm Infinity Tower", function(state) self:Toggle(state) end)
end

return Module
