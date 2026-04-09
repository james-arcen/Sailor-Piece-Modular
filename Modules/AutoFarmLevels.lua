-- Auto Farm Levels
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local CombatService = Import("Services/CombatService")
local TeleportService = Import("Services/Teleport")
local GameData = Import("Config/GameData")
local PriorityService = Import("Services/PriorityService")

local Module = {}

function Module:Init()
    self.IsRunning = false
    self.TargetLevel = 100
end

function Module:StartFarm()
    if self.IsRunning then return end
    self.IsRunning = true
    CombatService:Start()
    PriorityService:Request("AutoFarmLevels")
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(2) do
            local char = LP.Character
            if not char then continue end
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid:FindFirstChild("Level") then
                local currentLevel = humanoid.Level.Value
                if currentLevel >= self.TargetLevel then
                    self.IsRunning = false
                    CombatService:Stop()
                    PriorityService:Release("AutoFarmLevels")
                end
            end
        end
    end)
end

function Module:StopFarm()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
    CombatService:Stop()
    PriorityService:Release("AutoFarmLevels")
end

function Module:Toggle(state)
    if state then self:StartFarm() else self:StopFarm() end
end

function Module:Start()
    local tab = "Farm & Level"
    UI:CreateSection(tab, "Auto Farm Level")
    UI:CreateToggle(tab, "Auto Farm Until Level", function(state) self:Toggle(state) end)
end

return Module
