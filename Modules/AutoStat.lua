-- Auto Stat - Auto-spend stat points
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}

function Module:Init()
    self.IsRunning = false
    self.AutoSpendHealth = false
    self.AutoSpendMana = false
    self.AutoSpendStamina = false
end

function Module:StartSpend()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(3) do
            local char = LP.Character
            if not char then continue end
            
            pcall(function()
                local statRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SpendStat")
                if statRemote then
                    if self.AutoSpendHealth then pcall(function() statRemote:FireServer("Health", 1) end) end
                    if self.AutoSpendMana then pcall(function() statRemote:FireServer("Mana", 1) end) end
                    if self.AutoSpendStamina then pcall(function() statRemote:FireServer("Stamina", 1) end) end
                end
            end)
        end
    end)
end

function Module:StopSpend()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartSpend() else self:StopSpend() end
end

function Module:Start()
    local tab = "Stats"
    UI:CreateSection(tab, "Auto Stat Spend")
    UI:CreateToggle(tab, "Auto Spend Health", function(state)
        self.AutoSpendHealth = state
        if not self.IsRunning and (self.AutoSpendHealth or self.AutoSpendMana or self.AutoSpendStamina) then
            self:StartSpend()
        elseif self.IsRunning and not (self.AutoSpendHealth or self.AutoSpendMana or self.AutoSpendStamina) then
            self:StopSpend()
        end
    end)
    UI:CreateToggle(tab, "Auto Spend Mana", function(state)
        self.AutoSpendMana = state
        if not self.IsRunning and (self.AutoSpendHealth or self.AutoSpendMana or self.AutoSpendStamina) then
            self:StartSpend()
        elseif self.IsRunning and not (self.AutoSpendHealth or self.AutoSpendMana or self.AutoSpendStamina) then
            self:StopSpend()
        end
    end)
    UI:CreateToggle(tab, "Auto Spend Stamina", function(state)
        self.AutoSpendStamina = state
        if not self.IsRunning and (self.AutoSpendHealth or self.AutoSpendMana or self.AutoSpendStamina) then
            self:StartSpend()
        elseif self.IsRunning and not (self.AutoSpendHealth or self.AutoSpendMana or self.AutoSpendStamina) then
            self:StopSpend()
        end
    end)
end

return Module
