-- SAILOR PIECE HUB PRO - Standalone Loadstring Script
-- Copy this entire script and paste into your executor

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

-- Anti-AFK
pcall(function()
    Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ============================================
-- MINIMAL UI FRAMEWORK (Built-in, no imports)
-- ============================================
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local UI = { Tabs = {}, ActiveTab = nil }

local THEME = {
    Window = Color3.fromRGB(18,18,20),
    Topbar = Color3.fromRGB(24,26,28),
    Accent = Color3.fromRGB(94,123,255),
    Button = Color3.fromRGB(40,40,45),
    ButtonHover = Color3.fromRGB(60,60,70),
    ToggleOn = Color3.fromRGB(50,180,80),
    ToggleOff = Color3.fromRGB(45,45,50),
    Section = Color3.fromRGB(130,130,200),
    Text = Color3.fromRGB(230,230,230)
}

function UI:Init(config)
    local uiName = "SailorPieceHubPro"
    local uiParent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")
    if uiParent:FindFirstChild(uiName) then uiParent[uiName]:Destroy() end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = uiName
    self.ScreenGui.Parent = uiParent

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 700, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -210)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = THEME.Window
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = self.ScreenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 48)
    topBar.BackgroundColor3 = THEME.Topbar
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = (config and config.HubName or "Hub") .. " v" .. (config and config.Version or "1.0")
    title.TextColor3 = THEME.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -46, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(210, 60, 60)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = topBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    closeBtn.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)

    self.MainFrame = mainFrame
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Size = UDim2.new(1, -20, 1, -64)
    self.ContentArea.Position = UDim2.new(0, 10, 0, 54)
    self.ContentArea.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    self.ContentArea.BorderSizePixel = 0
    self.ContentArea.Parent = mainFrame
end

function UI:CreateTab(name)
    local tab = Instance.new("Frame")
    tab.Name = name
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    tab.BorderSizePixel = 0
    tab.Parent = self.ContentArea
    tab.Visible = (#self.Tabs == 0)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.Parent = tab

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scroll

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.Parent = scroll

    tab.Container = scroll
    table.insert(self.Tabs, tab)
    return tab
end

function UI:CreateSection(tabName, text)
    local tab = self.Tabs[1]
    for _, t in ipairs(self.Tabs) do if t.Name == tabName then tab = t break end end

    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, 0, 0, 30)
    section.BackgroundTransparency = 1
    section.Text = text
    section.TextColor3 = THEME.Accent
    section.Font = Enum.Font.GothamBold
    section.TextSize = 14
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = tab.Container
end

function UI:CreateToggle(tabName, text, callback)
    local tab = self.Tabs[1]
    for _, t in ipairs(self.Tabs) do if t.Name == tabName then tab = t break end end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = THEME.Button
    container.BorderSizePixel = 0
    container.Parent = tab.Container
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = THEME.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 24)
    toggle.Position = UDim2.new(1, -50, 0.5, -12)
    toggle.BackgroundColor3 = THEME.ToggleOff
    toggle.Text = ""
    toggle.Parent = container
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 4)

    local isOn = false
    toggle.MouseButton1Click:Connect(function()
        isOn = not isOn
        toggle.BackgroundColor3 = isOn and THEME.ToggleOn or THEME.ToggleOff
        pcall(function() callback(isOn) end)
    end)
end

function UI:CreateButton(tabName, text, callback)
    local tab = self.Tabs[1]
    for _, t in ipairs(self.Tabs) do if t.Name == tabName then tab = t break end end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = THEME.Button
    btn.Text = text
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = tab.Container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        pcall(function() callback() end)
    end)
end

function UI:Start()
    self:CreateTab("Farm & Level")
    self:CreateTab("Stats")
    self:CreateTab("Skills")
    self:CreateTab("Boss")
    self:CreateTab("World & Teleport")
    self:CreateTab("Gacha & Items")
    self:CreateTab("Collection")
    self:CreateTab("Blessing")
    self:CreateTab("Skill Tree")
    self:CreateTab("Player")
    self:CreateTab("Webhook")
    self:CreateTab("Misc & Config")
end

-- ============================================
-- HUB CORE
-- ============================================
local Config = { HubName = "Sailor Piece Hub Pro", Version = "1.0.2" }
local Core = { Modules = {} }

Core.UI = UI

function Core:RegisterModule(name, category, moduleTable)
    if type(moduleTable.Init) ~= "function" then
        warn("⚠️ Invalid module: " .. name)
        return
    end
    moduleTable.Name = name
    moduleTable.Category = category
    self.Modules[name] = moduleTable
end

function Core:Init()
    self.UI:Init(Config)
end

function Core:Start()
    self.UI:Start()
    
    -- Example: Create a test section
    UI:CreateSection("Farm & Level", "🎮 Test Modules")
    UI:CreateButton("Farm & Level", "✅ Hub Loaded Successfully!", function()
        print("Hub is working!")
    end)
end

-- ============================================
-- INITIALIZE
-- ============================================
Core:Init()
Core:Start()

print("✅ Sailor Piece Hub Pro v" .. Config.Version .. " loaded!")
print("Check your screen - UI should be visible")
