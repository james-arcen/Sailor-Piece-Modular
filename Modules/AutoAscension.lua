-- Auto Ascension - Auto-ascend characters
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local TeleportService = Import("Services/Teleport")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}

function Module:Init()
    self.IsRunning = false
end

function Module:StartAscend()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(5) do
            local char = LP.Character
            if not char then continue end
            
            pcall(function()
                local ascendRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("AscendPlayer")
                if ascendRemote then
                    ascendRemote:FireServer()
                end
            end)
        end
    end)
end

function Module:StopAscend()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartAscend() else self:StopAscend() end
end

function Module:Start()
    local tab = "Stats"
    UI:CreateSection(tab, "Auto Ascension")
    UI:CreateToggle(tab, "Auto Ascend", function(state) self:Toggle(state) end)
end

return Module
