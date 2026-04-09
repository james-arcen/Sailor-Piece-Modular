-- Auto Use Chest - Auto-open chests
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")

local Module = {}

function Module:Init()
    self.IsRunning = false
end

function Module:StartOpenChests()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(1) do
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            for _, chest in ipairs(Workspace:FindFirstChild("Chests") and Workspace.Chests:GetChildren() or {}) do
                local chestHrp = chest:FindFirstChild("HumanoidRootPart")
                if chestHrp then
                    local dist = (hrp.Position - chestHrp.Position).Magnitude
                    if dist < 30 then
                        pcall(function() 
                            if chest:FindFirstChild("OpenTrigger") then
                                chest.OpenTrigger.Parent = nil
                            end
                        end)
                    end
                end
            end
        end
    end)
end

function Module:StopOpenChests()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartOpenChests() else self:StopOpenChests() end
end

function Module:Start()
    local tab = "Misc & Config"
    UI:CreateSection(tab, "Auto Chest Opening")
    UI:CreateToggle(tab, "Auto Open Chests", function(state) self:Toggle(state) end)
end

return Module
