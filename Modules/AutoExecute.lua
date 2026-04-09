-- Auto Execute - Execute custom scripts periodically
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UI = Import("Ui/UI")

local Module = {}

function Module:Init()
    self.IsRunning = false
    self.CustomScript = ""
end

function Module:StartExecute()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(5) do
            if self.CustomScript ~= "" then
                pcall(function()
                    local func, err = loadstring(self.CustomScript)
                    if func then func() end
                end)
            end
        end
    end)
end

function Module:StopExecute()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartExecute() else self:StopExecute() end
end

function Module:Start()
    local tab = "Webhook"
    UI:CreateSection(tab, "Auto Execute")
    UI:CreateToggle(tab, "Auto Execute Script", function(state) self:Toggle(state) end)
end

return Module
