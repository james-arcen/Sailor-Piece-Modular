-- ========================================================================
-- 🔥 MODULE: Auto Boss Kill — finds nearest boss and forces CombatService
-- ========================================================================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local CombatService = Import("Services/CombatService")
local AutoBoss = Import("Modules/AutoBoss")
local RandomService = Import("Services/RandomService")

local Module = {}

function Module:Init()
    self.IsRunning = false
    self.ScanInterval = 1
    self.OldThrottle = nil
    self.OldEnabled = nil
end

function Module:FindNearestBoss()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, b in ipairs(AutoBoss.AllBosses or {}) do
        local model = AutoBoss:GetBossModel(b.Target)
        if model and model:FindFirstChild("Humanoid") and model.Humanoid.Health > 0 then
            local mhrp = model:FindFirstChild("HumanoidRootPart")
            if mhrp then
                local d = (hrp.Position - mhrp.Position).Magnitude
                if d < bestDist then bestDist = d; best = model end
            end
        end
    end
    return best
end

function Module:StartKill()
    if self.IsRunning then return end
    self.IsRunning = true
    CombatService:Start()

    -- Save previous combat settings
    self.OldThrottle = CombatService.ThrottleDelay
    self.OldEnabled = {
        Z = CombatService.EnabledSkills.Z,
        X = CombatService.EnabledSkills.X,
        C = CombatService.EnabledSkills.C,
        V = CombatService.EnabledSkills.V,
        F = CombatService.EnabledSkills.F
    }

    CombatService.ThrottleDelay = 0.25
    for k,_ in pairs(CombatService.EnabledSkills) do CombatService.EnabledSkills[k] = true end

    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(self.ScanInterval) do
            local boss = self:FindNearestBoss()
            if boss then
                CombatService:SetTarget(boss)
            else
                CombatService:SetTarget(nil)
            end
        end
    end)
end

function Module:StopKill()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop); self.Loop = nil end
    CombatService:SetTarget(nil)
    if self.OldThrottle then CombatService.ThrottleDelay = self.OldThrottle end
    if self.OldEnabled then
        CombatService.EnabledSkills = self.OldEnabled
    end
end

function Module:Toggle(state)
    if state then self:StartKill() else self:StopKill() end
end

function Module:Start()
    local tab = "Chefes (Boss)"
    UI:CreateSection(tab, "Auto Boss Kill")
    UI:CreateToggle(tab, "Auto Kill Nearest Boss", function(state) self:Toggle(state) end)
end

return Module
