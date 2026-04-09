local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

local UI = { Tabs = {}, ActiveTab = nil, OnClose = nil }

-- Theme
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

local function new(name, class)
    local obj = Instance.new(class)
    obj.Name = name
    return obj
end

function UI:Init(HubConfig)
    local uiName = "SailorPieceHubPro_Rayfield"
    local uiParent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")
    if uiParent:FindFirstChild(uiName) then uiParent[uiName]:Destroy() end

    self.ScreenGui = new(uiName, "ScreenGui")
    self.ScreenGui.Parent = uiParent

    -- Main
    self.MainFrame = new("MainFrame", "Frame")
    self.MainFrame.Size = UDim2.new(0, 700, 0, 420)
    self.MainFrame.Position = UDim2.new(0.5, -350, 0.5, -210)
    self.MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
    self.MainFrame.BackgroundColor3 = THEME.Window
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0,10)

    -- Topbar
    local top = new("TopBar", "Frame")
    top.Size = UDim2.new(1,0,0,48)
    top.BackgroundColor3 = THEME.Topbar
    top.Parent = self.MainFrame
    Instance.new("UICorner", top).CornerRadius = UDim.new(0,10)

    local title = new("Title", "TextLabel")
    title.Size = UDim2.new(1, -140, 1, 0)
    title.Position = UDim2.new(0,16,0,0)
    title.BackgroundTransparency = 1
    title.Text = (HubConfig and HubConfig.HubName or "Hub") .. " v" .. (HubConfig and HubConfig.Version or "?")
    title.TextColor3 = THEME.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top

    local closeBtn = new("CloseBtn", "TextButton")
    closeBtn.Size = UDim2.new(0,28,0,28)
    closeBtn.Position = UDim2.new(1, -46, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(210,60,60)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = top
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

    closeBtn.MouseButton1Click:Connect(function()
        if self.OnClose then pcall(self.OnClose) end
        if self.ScreenGui then self.ScreenGui:Destroy() end
    end)

    -- Sidebar
    self.Sidebar = new("Sidebar", "ScrollingFrame")
    self.Sidebar.Size = UDim2.new(0,160,1, -64)
    self.Sidebar.Position = UDim2.new(0,16,0,64)
    self.Sidebar.BackgroundTransparency = 1
    self.Sidebar.ScrollBarThickness = 3
    self.Sidebar.Parent = self.MainFrame
    local sLayout = new("SidebarLayout", "UIListLayout")
    sLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sLayout.Padding = UDim.new(0,6)
    sLayout.Parent = self.Sidebar

    -- Content area
    self.ContentArea = new("Content", "Frame")
    self.ContentArea.Size = UDim2.new(1, -200, 1, -64)
    self.ContentArea.Position = UDim2.new(0,188,0,64)
    self.ContentArea.BackgroundColor3 = Color3.fromRGB(28,28,30)
    self.ContentArea.Parent = self.MainFrame
    Instance.new("UICorner", self.ContentArea).CornerRadius = UDim.new(0,8)

    -- Make draggable via topbar
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    self.Tabs = {}
end

function UI:CreateTab(name)
    local tabBtn = new(name .. "_Btn", "TextButton")
    tabBtn.Size = UDim2.new(1, -12, 0, 34)
    tabBtn.BackgroundColor3 = THEME.Button
    tabBtn.Text = name
    tabBtn.TextColor3 = THEME.Text
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 13
    tabBtn.Parent = self.Sidebar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0,6)

    local tabContainer = new(name .. "_Container", "ScrollingFrame")
    tabContainer.Size = UDim2.new(1, -28, 1, -28)
    tabContainer.Position = UDim2.new(0,14,0,14)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 4
    tabContainer.Visible = false
    tabContainer.Parent = self.ContentArea

    local layout = new(name .. "_Layout", "UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,8)
    layout.Parent = tabContainer
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 16)
    end)

    tabBtn.MouseEnter:Connect(function() tabBtn.BackgroundColor3 = THEME.ButtonHover end)
    tabBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= name then tabBtn.BackgroundColor3 = THEME.Button end
    end)

    self.Tabs[name] = { Button = tabBtn, Container = tabContainer }
    tabBtn.MouseButton1Click:Connect(function() self:SelectTab(name) end)
    if not self.ActiveTab then self:SelectTab(name) end
    return tabContainer
end

function UI:SelectTab(tabName)
    self.ActiveTab = tabName
    for name, data in pairs(self.Tabs) do
        if name == tabName then
            data.Button.BackgroundColor3 = THEME.Accent
            data.Button.TextColor3 = Color3.new(1,1,1)
            data.Container.Visible = true
        else
            data.Button.BackgroundColor3 = THEME.Button
            data.Button.TextColor3 = THEME.Text
            data.Container.Visible = false
        end
    end
end

function UI:CreateSection(tabName, text)
    local container = self.Tabs[tabName] and self.Tabs[tabName].Container
    if not container then return end
    local lbl = new("SectionLabel", "TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 26)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = THEME.Section
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 13
    lbl.Text = "-- " .. text .. " --"
    lbl.TextTransparency = 0
    lbl.Parent = container
end

function UI:CreateToggle(tabName, text, callback)
    local container = self.Tabs[tabName] and self.Tabs[tabName].Container
    if not container then return end
    local frame = new("ToggleFrame", "Frame")
    frame.Size = UDim2.new(1, -20, 0, 36)
    frame.BackgroundTransparency = 1
    frame.Parent = container

    local lbl = new("ToggleLabel", "TextLabel")
    lbl.Size = UDim2.new(0.75, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": OFF"
    lbl.TextColor3 = THEME.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = new("ToggleBtn", "TextButton")
    btn.Size = UDim2.new(0.22, 0, 0.8, 0)
    btn.Position = UDim2.new(0.78, 0, 0.1, 0)
    btn.BackgroundColor3 = THEME.ToggleOff
    btn.Text = ""
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff
        lbl.Text = text .. ": " .. (state and "ON" or "OFF")
        if callback then pcall(callback, state) end
    end)
end

function UI:CreateButton(tabName, text, callback)
    local container = self.Tabs[tabName] and self.Tabs[tabName].Container
    if not container then return end
    local btn = new("Btn", "TextButton")
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.BackgroundColor3 = THEME.Accent
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = THEME.ButtonHover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = THEME.Accent end)
    btn.MouseButton1Click:Connect(function()
        pcall(function() if callback then callback() end end)
    end)
end

function UI:CreateDropdown(tabName, defaultText, options, callback)
    local container = self.Tabs[tabName] and self.Tabs[tabName].Container
    if not container then return end
    local frame = new("DropdownFrame", "Frame")
    frame.Size = UDim2.new(1, -20, 0, 36)
    frame.BackgroundTransparency = 1
    frame.Parent = container

    local main = new("MainBtn", "TextButton")
    main.Size = UDim2.new(1, 0, 1, 0)
    main.BackgroundColor3 = THEME.Button
    main.Text = defaultText .. " ▼"
    main.TextColor3 = THEME.Text
    main.Font = Enum.Font.Gotham
    main.TextSize = 13
    main.Parent = frame
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,6)

    local list = new("Options", "Frame")
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 1, 6)
    list.BackgroundColor3 = Color3.fromRGB(28,28,30)
    list.Parent = frame
    Instance.new("UICorner", list).CornerRadius = UDim.new(0,6)
    list.ClipsDescendants = true

    local layout = new("OptionsLayout", "UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,4)
    layout.Parent = list

    local isOpen = false
    main.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        main.Text = defaultText .. (isOpen and " ▲" or " ▼")
        if isOpen then
            list:TweenSize(UDim2.new(1,0,0, math.clamp(#options * 30, 30, 240)), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        else
            list:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        end
    end)

    local function populate(opts)
        for _, child in ipairs(list:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, opt in ipairs(opts) do
            local btn = new("Opt", "TextButton")
            btn.Size = UDim2.new(1, -8, 0, 28)
            btn.BackgroundColor3 = THEME.Button
            btn.Text = opt
            btn.TextColor3 = THEME.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.Parent = list
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
            btn.MouseButton1Click:Connect(function()
                isOpen = false
                main.Text = "📍 " .. opt .. " ▼"
                list:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
                pcall(function() if callback then callback(opt) end end)
            end)
        end
    end
    populate(options)
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

return UI
