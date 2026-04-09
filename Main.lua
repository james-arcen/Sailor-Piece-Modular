local REPO_URL = "https://raw.githubusercontent.com/james-arcen/Sailor-Piece-Hub-modular/main/Sailor%20Piece%20Modular"
local moduleCache = {}

pcall(function()
    local Players = game:GetService("Players")
    local VirtualUser = game:GetService("VirtualUser")
    Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

getgenv().Import = function(modulePath)
    if moduleCache[modulePath] then return moduleCache[modulePath] end
    local url = REPO_URL .. modulePath .. ".lua?t=" .. tostring(math.random(1000, 9999))

    local result
    local success, err = pcall(function() result = game:HttpGet(url) end)
    if not success or not result or result:find("404: Not Found") then
        error("❌ Download Error (Check GitHub): " .. modulePath)
    end

    local loadedFunc, loadError = loadstring(result)
    if not loadedFunc then error("❌ Syntax Error: " .. tostring(loadError)) end

    local moduleData = loadedFunc()
    moduleCache[modulePath] = moduleData
    return moduleData
end

local Config = { HubName = "Sailor Piece Hub Pro", Version = "1.0.2" }
local Core = { Modules = {} }

Core.UI = Import("Ui/UI")
local CombatService = Import("Services/CombatService")
CombatService:Init()

function Core:RegisterModule(name, category, moduleTable)
    assert(type(moduleTable.Init) == "function", "Error in module " .. name)
    moduleTable.Name = name
    moduleTable.Category = category
    self.Modules[name] = moduleTable
end

-- ==========================================
-- 📦 MODULE REGISTRATION
-- ==========================================

-- Farm & Level
local AutoQuestModule = Import("Modules/AutoQuest")
Core:RegisterModule("Auto Quest (Single)", "Farm & Level", AutoQuestModule)
task.wait(0.2)

local AutoFarmModule = Import("Modules/AutoFarm")
Core:RegisterModule("Auto Farm (Any Mob)", "Farm & Level", AutoFarmModule)
task.wait(0.2)

local AutoFarmLevelsModule = Import("Modules/AutoFarmLevels")
Core:RegisterModule("Auto Farm Level", "Farm & Level", AutoFarmLevelsModule)
task.wait(0.2)

-- Stats
local AutoStatModule = Import("Modules/AutoStat")
Core:RegisterModule("Auto Stat Spend", "Stats", AutoStatModule)
task.wait(0.2)

local AutoAscensionModule = Import("Modules/AutoAscension")
Core:RegisterModule("Auto Ascension", "Stats", AutoAscensionModule)
task.wait(0.2)

local AutoRedeemCodesModule = Import("Modules/AutoRedeemCodes")
Core:RegisterModule("Auto Redeem Codes", "Stats", AutoRedeemCodesModule)
task.wait(0.2)

-- Skills
local AutoUseHakiModule = Import("Modules/AutoUseHaki")
Core:RegisterModule("Auto Use Haki", "Skills", AutoUseHakiModule)
task.wait(0.2)

local KillAuraModule = Import("Modules/KillAura")
Core:RegisterModule("Kill Aura", "Skills", KillAuraModule)
task.wait(0.2)

-- Boss
local AutoBossModule = Import("Modules/AutoBoss")
Core:RegisterModule("Auto Boss (Queue)", "Boss", AutoBossModule)
task.wait(0.2)

local AutoBossKillModule = Import("Modules/AutoBossKill")
Core:RegisterModule("Auto Boss Kill", "Boss", AutoBossKillModule)
task.wait(0.2)

local AutoSummonModule = Import("Modules/AutoSummon")
Core:RegisterModule("Auto Summon Boss", "Boss", AutoSummonModule)
task.wait(0.2)

-- Misc
local AutoCraftModule = Import("Modules/AutoCraft")
Core:RegisterModule("Auto Craft", "Misc & Config", AutoCraftModule)
task.wait(0.2)

local AutoUseChestModule = Import("Modules/AutoUseChest")
Core:RegisterModule("Auto Use Chest", "Misc & Config", AutoUseChestModule)
task.wait(0.2)

local AutoGemRerollModule = Import("Modules/AutoGemReroll")
Core:RegisterModule("Auto Gem Reroll", "Misc & Config", AutoGemRerollModule)
task.wait(0.2)

local AutoClanRerollModule = Import("Modules/AutoClanReroll")
Core:RegisterModule("Auto Clan Reroll", "Misc & Config", AutoClanRerollModule)
task.wait(0.2)

-- Blessing
local AutoEnchantModule = Import("Modules/AutoEnchant")
Core:RegisterModule("Auto Enchant", "Blessing", AutoEnchantModule)
task.wait(0.2)

local AutoBlessingModule = Import("Modules/AutoBlessing")
Core:RegisterModule("Auto Blessing", "Blessing", AutoBlessingModule)
task.wait(0.2)

-- Skill Tree
local AutoSkillTreeModule = Import("Modules/AutoSkillTree")
Core:RegisterModule("Auto Skill Tree", "Skill Tree", AutoSkillTreeModule)
task.wait(0.2)

local AutoArtifactModule = Import("Modules/AutoArtifact")
Core:RegisterModule("Auto Artifact", "Skill Tree", AutoArtifactModule)
task.wait(0.2)

-- Player
local AutoRejoinModule = Import("Modules/AutoRejoin")
Core:RegisterModule("Auto Rejoin", "Player", AutoRejoinModule)
task.wait(0.2)

local AutoDungeonModule = Import("Modules/AutoDungeon")
Core:RegisterModule("Auto Dungeon", "Player", AutoDungeonModule)
task.wait(0.2)

local AutoBossRushModule = Import("Modules/AutoBossRush")
Core:RegisterModule("Auto Boss Rush", "Player", AutoBossRushModule)
task.wait(0.2)

local AutoInfinityTowerModule = Import("Modules/AutoInfinityTower")
Core:RegisterModule("Auto Infinity Tower", "Player", AutoInfinityTowerModule)
task.wait(0.2)

-- Webhook
local AutoWebhookModule = Import("Modules/AutoWebhook")
Core:RegisterModule("Auto Webhook", "Webhook", AutoWebhookModule)
task.wait(0.2)

local AutoExecuteModule = Import("Modules/AutoExecute")
Core:RegisterModule("Auto Execute", "Webhook", AutoExecuteModule)
task.wait(0.2)

-- Teleport
local TeleportModule = Import("Services/Teleport")
Core:RegisterModule("World & Teleport", "World & Teleport", TeleportModule)
task.wait(0.2)

-- Collection
local AutoCollectModule = Import("Modules/AutoCollect")
Core:RegisterModule("Auto Collect", "Collection", AutoCollectModule)
task.wait(0.2)

-- Gacha
local GachaManager = Import("Modules/GachaManager")
Core:RegisterModule("Gacha System", "Gacha & Items", GachaManager)
task.wait(0.2)

function Core:Init()
    self.UI:Init(Config)
    
    self.UI.OnClose = function()
        for _, module in pairs(self.Modules) do
            if module.Stop then
                pcall(function() module:Stop() end)
            end
        end
    end
    
    for _, module in pairs(self.Modules) do module:Init() end
end

function Core:Start()
    self.UI:Start()
    local WeaponService = Import("Services/WeaponService")
    WeaponService:BuildUI("Misc & Config")
    
    for name, module in pairs(self.Modules) do
        if not module.NoToggle then
            self.UI:CreateToggle(module.Category, name, function(state)
                module:Toggle(state)
            end)
        else
            if module.Start then
                pcall(function() module:Start() end)
            end
        end
    end
end

Core:Init()
Core:Start()
