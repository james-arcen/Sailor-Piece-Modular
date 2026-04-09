-- Auto Use Haki - Auto-use Haki for damage boost
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}

function Module:Init()
    self.IsRunning = false
    self.HakiType = "Observation"
end

function Module:StartUseHaki()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(2) do
            local char = LP.Character
            if not char then continue end
            
            pcall(function()
                local hakiRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("UseHaki")
                if hakiRemote then
                    hakiRemote:FireServer(self.HakiType)
                end
            end)
        end
    end)
end

function Module:StopUseHaki()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartUseHaki() else self:StopUseHaki() end
end

function Module:Start()
    local tab = "Skills"
    UI:CreateSection(tab, "Auto Haki Usage")
    UI:CreateToggle(tab, "Auto Use Observation Haki", function(state) self:Toggle(state) end)
end

return Module
