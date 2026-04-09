-- Auto Webhook Notify - Send webhook notifications every 5 minutes
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UI = Import("Ui/UI")

local Module = {}

function Module:Init()
    self.IsRunning = false
    self.WebhookURL = ""
    self.NotifyInterval = 300
end

function Module:StartNotify()
    if self.IsRunning then return end
    self.IsRunning = true
    
    self.Loop = task.spawn(function()
        while self.IsRunning and task.wait(self.NotifyInterval) do
            if self.WebhookURL ~= "" then
                pcall(function()
                    local char = LP.Character
                    local humanoid = char and char:FindFirstChild("Humanoid")
                    local data = {
                        content = "🎮 **" .. LP.Name .. "** is still online!",
                        embeds = {{
                            title = "Sailor Piece Hub Status",
                            description = "Auto-farming active",
                            fields = {
                                {name = "Player", value = LP.Name, inline = true},
                                {name = "Health", value = humanoid and tostring(humanoid.Health) or "N/A", inline = true}
                            }
                        }}
                    }
                    HttpService:PostAsync(self.WebhookURL, HttpService:JSONEncode(data))
                end)
            end
        end
    end)
end

function Module:StopNotify()
    self.IsRunning = false
    if self.Loop then task.cancel(self.Loop) end
end

function Module:Toggle(state)
    if state then self:StartNotify() else self:StopNotify() end
end

function Module:Start()
    local tab = "Webhook"
    UI:CreateSection(tab, "Auto Webhook Notification")
    UI:CreateToggle(tab, "Auto Notify Every 5 Min", function(state) self:Toggle(state) end)
end

return Module
