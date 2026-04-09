-- ========================================================================
-- 🗡️ SERVICE: WEAPON MANAGER AND GLOBAL SETTINGS (UI)
-- ========================================================================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local UI = Import("Ui/UI")
local GameData = Import("Config/GameData") -- 🔥 Imports global configuration

local WeaponService = {
    SelectedWeapons = {},
    ActiveLabel = nil
}

function WeaponService:GetAvailableWeapons()
    local weapons = {}
    local char = LP.Character

    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then table.insert(weapons, tool.Name) end
        end
    end

    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then table.insert(weapons, tool.Name) end
        end
    end

    if #weapons == 0 then table.insert(weapons, "Nenhuma Arma Encontrada") end
    return weapons
end

function WeaponService:UpdateLabel()
    if not self.ActiveLabel then return end
    if #self.SelectedWeapons == 0 then
        self.ActiveLabel.Text = "Active Weapons: None (Will use the first available)"
    else
        self.ActiveLabel.Text = "Active Weapons: " .. table.concat(self.SelectedWeapons, ", ")
    end
end

function WeaponService:EquipWeapon(weaponName)
    local char = LP.Character
    if not char then return false end
    if char:FindFirstChild(weaponName) then return true end
    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild(weaponName)
        if tool then
            tool.Parent = char
            return true
        end
    end
    return false
end

-- ========================================================================
-- 🖥️ CONSTRUTOR DE INTERFACE (Aba: Misc & Config)
-- ========================================================================
function WeaponService:BuildUI(tabName)
    local container = UI.Tabs[tabName].Container
    local CombatService = Import("Services/CombatService")

    -- ==========================================
    -- 🔧 HELPER: Simple function to create TextBoxes
    -- ==========================================
    local function CreateInput(labelText, defaultVal, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 35)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        frame.Parent = container
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.35, -5, 0.8, 0)
        input.Position = UDim2.new(0.65, 0, 0.1, 0)
        input.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        input.TextColor3 = Color3.fromRGB(150, 255, 150)
        input.Font = Enum.Font.GothamBold
        input.TextSize = 14
        input.Text = tostring(defaultVal)
        input.Parent = frame
        Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
        
        input.FocusLost:Connect(function()
            local num = tonumber(input.Text)
            if num then callback(num)
            else input.Text = tostring(defaultVal) end
        end)
    end

    -- ==========================================
    -- ⚙️ GLOBAL SETTINGS SECTION (NEW)
    -- ==========================================
    UI:CreateSection(tabName, "⚙️ Performance & Control")

    CreateInput("🚀 Flight Speed (Studs/s):", GameData.Settings.SlideSpeed, function(val)
        GameData.Settings.SlideSpeed = val
    end)

    CreateInput("⏱️ Action Delay (Seconds):", GameData.Settings.ActionDelay, function(val)
        GameData.Settings.ActionDelay = val
    end)

    -- ==========================================
    -- 🪄 SKILL SELECTION SECTION (AUTO SKILL)
    -- ==========================================
    UI:CreateSection(tabName, "🪄 Ability Usage (Auto Skill)")

    UI:CreateToggle(tabName, "Use Ability [Z]", function(state) 
        CombatService.EnabledSkills.Z = state 
        CombatService.SkillQueue = {}
    end)
    UI:CreateToggle(tabName, "Use Ability [X]", function(state) 
        CombatService.EnabledSkills.X = state 
        CombatService.SkillQueue = {}
    end)
    UI:CreateToggle(tabName, "Use Ability [C]", function(state) 
        CombatService.EnabledSkills.C = state 
        CombatService.SkillQueue = {}
    end)
    UI:CreateToggle(tabName, "Use Ability [V]", function(state) 
        CombatService.EnabledSkills.V = state 
        CombatService.SkillQueue = {}
    end)
    UI:CreateToggle(tabName, "Use Ability [F]", function(state) 
        CombatService.EnabledSkills.F = state 
        CombatService.SkillQueue = {}
    end)

    -- ==========================================
    -- 🛡️ TACTICAL POSITIONING SECTION
    -- ==========================================
    UI:CreateSection(tabName, "🛡️ Attack Positioning (Combat)")

    UI:CreateDropdown(tabName, "Attack Position", {"Behind", "Front", "Above", "Below", "Orbital", "Diagonal"}, function(val)
        CombatService.AttackPosition = val
    end)

    CreateInput("📏 Attack Distance (Studs):", CombatService.AttackDistance or 6, function(val)
        CombatService.AttackDistance = val
    end)

    -- ==========================================
    -- 🗡️ WEAPONS SECTION
    -- ==========================================
    UI:CreateSection(tabName, "🗡️ Weapon Manager")
    
    self.ActiveLabel = Instance.new("TextLabel")
    self.ActiveLabel.Size = UDim2.new(1, -10, 0, 30)
    self.ActiveLabel.BackgroundTransparency = 1
    self.ActiveLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    self.ActiveLabel.Font = Enum.Font.GothamSemibold
    self.ActiveLabel.TextSize = 12
    self.ActiveLabel.TextWrapped = true
    self.ActiveLabel.Parent = container
    self:UpdateLabel()

    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, -10, 0, 35)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.Parent = container

    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.new(1, -35, 0, 35)
    mainBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainBtn.Font = Enum.Font.GothamBold
    mainBtn.TextSize = 13
    mainBtn.Text = "🗡️ Choose Weapon ▼"
    mainBtn.Parent = dropdownFrame
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 4)

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 30, 0, 35)
    refreshBtn.Position = UDim2.new(1, -30, 0, 0)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 150)
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 16
    refreshBtn.Text = "🔄"
    refreshBtn.Parent = dropdownFrame
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)

    local optionsContainer = Instance.new("ScrollingFrame")
    optionsContainer.Size = UDim2.new(1, 0, 1, -40)
    optionsContainer.Position = UDim2.new(0, 0, 0, 40)
    optionsContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    optionsContainer.ScrollBarThickness = 2
    optionsContainer.Parent = dropdownFrame
    Instance.new("UICorner", optionsContainer).CornerRadius = UDim.new(0, 4)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = optionsContainer

    local isOpen = false
    local selectedToolToManage = ""

    local function populate()
        for _, child in ipairs(optionsContainer:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local weapons = self:GetAvailableWeapons()
        for _, wName in ipairs(weapons) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -5, 0, 25)
            optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            optBtn.Font = Enum.Font.GothamSemibold
            optBtn.TextSize = 12
            optBtn.Text = wName
            optBtn.Parent = optionsContainer
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

            optBtn.MouseButton1Click:Connect(function()
                isOpen = false
                selectedToolToManage = wName
                mainBtn.Text = "🗡️ " .. wName .. " ▼"
                dropdownFrame.Size = UDim2.new(1, -10, 0, 35)
            end)
        end
        task.wait(0.1)
        optionsContainer.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end

    mainBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropdownFrame.Size = isOpen and UDim2.new(1, -10, 0, 130) or UDim2.new(1, -10, 0, 35)
    end)

    refreshBtn.MouseButton1Click:Connect(function()
        populate()
        mainBtn.Text = "🗡️ Weapons Updated! ▼"
    end)

    populate()

    UI:CreateButton(tabName, "➕ Add Weapon to List", function()
        if selectedToolToManage ~= "" and selectedToolToManage ~= "No Weapon Found" then
            for _, w in ipairs(self.SelectedWeapons) do if w == selectedToolToManage then return end end
            table.insert(self.SelectedWeapons, selectedToolToManage)
            self:UpdateLabel()
        end
    end)

    UI:CreateButton(tabName, "➖ Remove Weapon from List", function()
        for i, w in ipairs(self.SelectedWeapons) do
            if w == selectedToolToManage then
                table.remove(self.SelectedWeapons, i)
                self:UpdateLabel()
                break
            end
        end
    end)

    UI:CreateButton(tabName, "🗑️ Clear All Weapons", function()
        self.SelectedWeapons = {}
        self:UpdateLabel()
    end)
end

return WeaponService
