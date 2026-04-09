-- Auto Dungeon - Auto-farm dungeons
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local TeleportService = Import("Services/Teleport")
local CombatService = Import("Services/CombatService")
local PriorityService = Import("Services/PriorityService")

local Module = {}

function Module:Init()
    self.IsRunning = false
end

function Module:StartDungeon()
    if self.IsRunning then return end
    self.IsRunning = true
    CombatService:Start()
    PriorityService:Request("AutoDungeon")
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(5) do
            local char = LP.Character
            if not char then continue end
            
            pcall(function()
                TeleportService:TeleportToIsland("Dungeon")
            end)
        end
    end)
end

function Module:StopDungeon()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
    CombatService:Stop()
    PriorityService:Release("AutoDungeon")
end

function Module:Toggle(state)
    if state then self:StartDungeon() else self:StopDungeon() end
end

function Module:Start()
    local tab = "Player"
    UI:CreateSection(tab, "Auto Dungeon")
    UI:CreateToggle(tab, "Auto Farm Dungeon", function(state) self:Toggle(state) end)
end

return Module
