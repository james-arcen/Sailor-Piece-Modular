-- Rayfield compatibility adapter (lightweight, wraps existing UI)
local Adapter = {}

local OriginalUI = Import("Ui/UI")

local Rayfield = {}

function Rayfield:Init(config)
    -- initialize underlying UI
    OriginalUI:Init(config)
    -- mirror expected properties
    self.Window = {
        Tabs = OriginalUI.Tabs,
        SelectTab = function(_, name) OriginalUI:SelectTab(name) end
    }
    -- expose top-level convenience
    Adapter.CoreUI = OriginalUI
    return self.Window
end

function Rayfield:Start()
    if OriginalUI.Start then OriginalUI:Start() end
end

-- Compatibility: keep the old UI API available (used by modules)
function Rayfield:CreateTab(name) return OriginalUI:CreateTab(name) end
function Rayfield:CreateSection(tabName, text) return OriginalUI:CreateSection(tabName, text) end
function Rayfield:CreateToggle(tabName, text, callback) return OriginalUI:CreateToggle(tabName, text, callback) end
function Rayfield:CreateButton(tabName, text, callback) return OriginalUI:CreateButton(tabName, text, callback) end
function Rayfield:CreateDropdown(tabName, defaultText, options, callback) return OriginalUI:CreateDropdown(tabName, defaultText, options, callback) end
function Rayfield:SelectTab(name) return OriginalUI:SelectTab(name) end

-- Rayfield-style API: CreateWindow -> CreateTab -> CreateToggle/CreateButton
function Rayfield:CreateWindow(opts)
    local win = {}
    win.Config = opts or {}
    function win:CreateTab(tabName)
        OriginalUI:CreateTab(tabName)
        local tab = {}
        function tab:CreateSection(text) OriginalUI:CreateSection(tabName, text) end
        function tab:CreateToggle(tbl) OriginalUI:CreateToggle(tabName, tbl.Name or tbl["Name"], tbl.Callback) end
        function tab:CreateButton(tbl) OriginalUI:CreateButton(tabName, tbl.Name or "Button", tbl.Callback) end
        function tab:CreateDropdown(tbl) OriginalUI:CreateDropdown(tabName, tbl.Name or "Dropdown", tbl.Options or {}, tbl.Callback) end
        return tab
    end
    return win
end

-- expose underlying UI for advanced use
Rayfield.Core = OriginalUI

return Rayfield
