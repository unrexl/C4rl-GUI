--[[
    C4RL GUI LIBRARY - Config & Notifications Module
    Configuration save/load, search, theme switching, notifications
]]

local ConfigAndNotifications = {}
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

function ConfigAndNotifications.Inject(Library, Utils)
    
    -- NOTIFICATIONS
    function Library:ShowNotification(title, message, notifType, duration)
        title = title or "Notification"
        message = message or ""
        notifType = notifType or "Info"
        duration = duration or 3
        
        local typeColors = {
            Info = {Color = self.Colors.Accent, Icon = "ℹ️"},
            Success = {Color = self.Colors.SuccessGreen, Icon = "✓"},
            Warning = {Color = self.Colors.WarningYellow, Icon = "⚠"},
            Error = {Color = self.Colors.DangerRed, Icon = "✕"}
        }
        
        local typeData = typeColors[notifType] or typeColors.Info
        
        local Notification = Utils.CreateElement("Frame", {
            Name = "Notification",
            Size = UDim2.new(1, 0, 0, 70),
            BackgroundColor3 = self.Colors.CardBG,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 10, 0, 0),
            LayoutOrder = os.clock(),
            Parent = self._NotificationContainer
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Notification})
        Utils.CreateElement("UIStroke", {Color = typeData.Color, Thickness = 2, Parent = Notification})
        
        Utils.CreateElement("TextLabel", {
            Size = UDim2.new(0, 40, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            Text = typeData.Icon,
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            TextColor3 = typeData.Color,
            Parent = Notification
        })
        
        Utils.CreateElement("TextLabel", {
            Size = UDim2.new(1, -55, 0, 25),
            Position = UDim2.new(0, 45, 0, 8),
            BackgroundTransparency = 1,
            Text = title,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = self.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Notification
        })
        
        Utils.CreateElement("TextLabel", {
            Size = UDim2.new(1, -55, 0, 30),
            Position = UDim2.new(0, 45, 0, 33),
            BackgroundTransparency = 1,
            Text = message,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = self.Colors.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = Notification
        })
        
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        table.insert(self.Notifications, Notification)
        
        if #self.Notifications > 5 then
            local oldest = table.remove(self.Notifications, 1)
            if oldest then oldest:Destroy() end
        end
        
        task.delay(duration, function()
            local tween = TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 10, 0, 0)
            })
            tween:Play()
            tween.Completed:Connect(function()
                Notification:Destroy()
                local idx = table.find(self.Notifications, Notification)
                if idx then table.remove(self.Notifications, idx) end
            end)
        end)
    end
    
    -- SEARCH FUNCTIONALITY
    function Library:EnableSearch()
        if self.SearchEnabled then return end
        self.SearchEnabled = true
        
        local SearchContainer = Utils.CreateElement("Frame", {
            Name = "Search",
            Size = UDim2.new(0, 200, 0, 35),
            Position = UDim2.new(1, -210, 0, 12),
            BackgroundColor3 = self.Colors.InputBG,
            BorderSizePixel = 0,
            Parent = self._Header
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SearchContainer})
        
        Utils.CreateElement("TextLabel", {
            Size = UDim2.new(0, 30, 1, 0),
            BackgroundTransparency = 1,
            Text = "🔍",
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = self.Colors.TextSecondary,
            Parent = SearchContainer
        })
        
        local SearchBox = Utils.CreateElement("TextBox", {
            Size = UDim2.new(1, -35, 1, 0),
            Position = UDim2.new(0, 30, 0, 0),
            BackgroundTransparency = 1,
            PlaceholderText = "Search...",
            Text = "",
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = self.Colors.TextPrimary,
            PlaceholderColor3 = self.Colors.TextTertiary,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            Parent = SearchContainer
        })
        
        local debounce = false
        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            if debounce then return end
            debounce = true
            task.wait(0.3)
            
            local query = SearchBox.Text:lower()
            for _, tab in pairs(self.Tabs) do
                for _, element in ipairs(self.Elements[tab.Name] or {}) do
                    if element.Element and element.Name then
                        local visible = query == "" or element.Name:lower():find(query, 1, true)
                        element.Element.Visible = visible
                    end
                end
            end
            
            debounce = false
        end)
    end
    
    -- CONFIG MANAGEMENT
    function Library:SaveConfig(fileName)
        fileName = fileName or self.SaveConfigName
        local success = pcall(function()
            writefile(fileName .. ".json", HttpService:JSONEncode(self.Config))
        end)
        return success
    end
    
    function Library:LoadConfig(fileName)
        fileName = fileName or self.SaveConfigName
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName .. ".json"))
        end)
        
        if success and data then
            for key, value in pairs(data) do
                self.Config[key] = value
                for _, tab in pairs(self.Tabs) do
                    for _, element in ipairs(self.Elements[tab.Name] or {}) do
                        if element.Name == key and element.SetValue then
                            element.SetValue(value)
                        end
                    end
                end
            end
            return true
        end
        return false
    end
    
    function Library:GetConfig(key)
        return self.Config[key]
    end
    
    function Library:SetConfig(key, value)
        self.Config[key] = value
        for _, tab in pairs(self.Tabs) do
            for _, element in ipairs(self.Elements[tab.Name] or {}) do
                if element.Name == key and element.SetValue then
                    element.SetValue(value)
                end
            end
        end
    end
    
    function Library:StartAutoSave()
        task.spawn(function()
            while self.AutoSaveConfig do
                task.wait(self.AutoSaveInterval)
                self:SaveConfig()
            end
        end)
    end
    
    -- THEME SWITCHING
    function Library:SetTheme(themeName)
        if not self._Themes[themeName] then return end
        
        self.Theme = themeName
        self.Colors = self._Themes[themeName]
        
        self._MainFrame.BackgroundColor3 = self.Colors.MainBG
        self._Header.BackgroundColor3 = self.Colors.HeaderBG
        self._Sidebar.BackgroundColor3 = self.Colors.SidebarBG
        
        for _, tab in pairs(self.Tabs) do
            if tab.Button.BackgroundColor3 ~= self.Colors.Accent then
                tab.Button.BackgroundColor3 = self.Colors.ElementBG
            end
        end
    end
end

return ConfigAndNotifications
