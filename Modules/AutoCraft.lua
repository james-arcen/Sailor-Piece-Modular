-- Auto Craft - Auto-craft items
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local TeleportService = Import("Services/Teleport")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}

function Module:Init()
    self.IsRunning = false
end

function Module:StartCraft()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(2) do
            pcall(function()
                local craftRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Craft")
                if craftRemote then
                    craftRemote:FireServer()
                end
            end)
        end
    end)
end

function Module:StopCraft()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartCraft() else self:StopCraft() end
end

function Module:Start()
    local tab = "Misc & Config"
    UI:CreateSection(tab, "Auto Craft")
    UI:CreateToggle(tab, "Auto Craft Items", function(state) self:Toggle(state) end)
end

return Module
