-- Auto Redeem Codes - Auto-redeem codes periodically
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}

function Module:Init()
    self.IsRunning = false
    self.RedeemCode = "SAILOR2025"
end

function Module:StartRedeem()
    if self.IsRunning then return end
    self.IsRunning = true
    UI:CreateButton("Stats", "Redeem Code Now", function() self:Redeem() end)
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(300) do
            self:Redeem()
        end
    end)
end

function Module:Redeem()
    pcall(function()
        local redeemRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("RedeemCode")
        if redeemRemote and self.RedeemCode ~= "" then
            redeemRemote:FireServer(self.RedeemCode)
        end
    end)
end

function Module:StopRedeem()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartRedeem() else self:StopRedeem() end
end

function Module:Start()
    local tab = "Stats"
    UI:CreateSection(tab, "Auto Redeem")
end

return Module
