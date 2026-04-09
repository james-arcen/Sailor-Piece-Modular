-- ========================================================================
-- ⏱️ SERVICE: DELAY SERVICE (FORMER RANDOM SERVICE) - GLOBAL FIXED TIME
-- ========================================================================
local GameData = Import("Config/GameData")

local RandomService = {}

function RandomService:GetTime(min, max)
    return GameData.Settings.ActionDelay or 1.0
end

function RandomService:Wait(min, max)
    local waitTime = self:GetTime(min, max)
    task.wait(waitTime)
    return waitTime
end

return RandomService
