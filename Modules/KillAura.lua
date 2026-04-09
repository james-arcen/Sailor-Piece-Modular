-- Kill Aura - Damage aura around player
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local CombatService = Import("Services/CombatService")

local Module = {}

function Module:Init()
    self.IsRunning = false
    self.AuraRadius = 40
end

function Module:StartAura()
    if self.IsRunning then return end
    self.IsRunning = true
    CombatService:Start()
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(0.5) do
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            local npcs = Workspace:FindFirstChild("NPCs")
            if npcs then
                for _, npc in ipairs(npcs:GetChildren()) do
                    local npcHrp = npc:FindFirstChild("HumanoidRootPart")
                    local hum = npc:FindFirstChild("Humanoid")
                    if npcHrp and hum and hum.Health > 0 then
                        local dist = (hrp.Position - npcHrp.Position).Magnitude
                        if dist < self.AuraRadius then
                            CombatService:SetTarget(npc)
                        end
                    end
                end
            end
        end
    end)
end

function Module:StopAura()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
    CombatService:SetTarget(nil)
end

function Module:Toggle(state)
    if state then self:StartAura() else self:StopAura() end
end

function Module:Start()
    local tab = "Skills"
    UI:CreateSection(tab, "Kill Aura")
    UI:CreateToggle(tab, "Enable Kill Aura", function(state) self:Toggle(state) end)
end

return Module
