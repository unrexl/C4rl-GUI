--[[
    C4RL GUI LIBRARY - WindowManager Module (IMPROVED)
    Handles window creation, tabs, and core functionality
]]

local WindowManager = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Smart parent detection
local function GetGuiParent()
    local success, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    
    if success and coreGui:FindFirstChild("RobloxGui") then
        -- Full CoreGui access available
        return coreGui
    else
        -- Fallback to PlayerGui (works on all executors)
        local Players = game:GetService("Players")
        return Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

function WindowManager.Create(options, Themes, Utils)
    -- Defensive parameter validation
    assert(options, "WindowManager.Create: options table is required")
    assert(Themes, "WindowManager.Create: Themes module is required")
    assert(Utils, "WindowManager.Create: Utils module is required")
    
    options = options or {}
    
    local Library = {
        Title = options.Title or "C4RL GUI",
        Subtitle = options.Subtitle or "",
        Theme = options.Theme or "Dark",
        Keybind = options.Keybind or Enum.KeyCode.RightShift,
        Size = options.Size or UDim2.new(0, 750, 0, 550),
        AutoSaveConfig = options.AutoSaveConfig or false,
        SaveConfigName = options.SaveConfigName or "C4RL_Config",
        AutoSaveInterval = options.AutoSaveInterval or 60,
        ShowNotification = options.ShowNotification ~= false,
        
        Config = {},
        Tabs = {},
        Elements = {},
        Notifications = {},
        CurrentTab = nil,
        Visible = false,
        Minimized = false,
        SearchEnabled = false,
        Connections = {},
        
        -- Injection state tracking
        _Injected = false,
        _InjectionReady = false,
    }
    
    -- Validate theme exists
    if not Themes[Library.Theme] then
        warn("Theme '" .. Library.Theme .. "' not found, falling back to 'Dark'")
        Library.Theme = "Dark"
    end
    
    Library.Colors = Themes[Library.Theme]
    
    -- Create ScreenGui with safe parent
    local ScreenGui = Utils.CreateElement("ScreenGui", {
        Name = "C4RLGUI_" .. tick(), -- Unique name to avoid conflicts
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Enabled = false, -- Start hidden until Show() is called
    })
    
    -- Main Frame
    local MainFrame = Utils.CreateElement("Frame", {
        Name = "Main",
        Size = Library.Size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Colors.MainBG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    
    Utils.CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = MainFrame
    })
    
    Utils.CreateElement("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
        ImageColor3 = Library.Colors.Shadow,
        ImageTransparency = 0.7,
        ZIndex = 0,
        Parent = MainFrame
    })
    
    -- Header
    local Header = Utils.CreateElement("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Library.Colors.HeaderBG,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    Utils.CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = Header
    })
    
    -- Traffic Lights
    local CloseBtn = Utils.CreateElement("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 15, 0, 24),
        BackgroundColor3 = Library.Colors.DangerRed,
        Text = "",
        AutoButtonColor = false,
        Parent = Header
    })
    
    Utils.CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = CloseBtn
    })
    
    local MinimizeBtn = Utils.CreateElement("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 35, 0, 24),
        BackgroundColor3 = Library.Colors.WarningYellow,
        Text = "",
        AutoButtonColor = false,
        Parent = Header
    })
    
    Utils.CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = MinimizeBtn
    })
    
    local MaximizeBtn = Utils.CreateElement("TextButton", {
        Name = "Maximize",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 55, 0, 24),
        BackgroundColor3 = Library.Colors.SuccessGreen,
        Text = "",
        AutoButtonColor = false,
        Parent = Header
    })
    
    Utils.CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = MaximizeBtn
    })
    
    -- Title
    Utils.CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 400, 0, 25),
        Position = UDim2.new(0.5, 0, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Text = Library.Title,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Library.Colors.TextPrimary,
        Parent = Header
    })
    
    Utils.CreateElement("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 400, 0, 15),
        Position = UDim2.new(0.5, 0, 0, 37),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Text = Library.Subtitle,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Library.Colors.TextSecondary,
        Parent = Header
    })
    
    -- Sidebar
    local Sidebar = Utils.CreateElement("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 180, 1, -60),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundColor3 = Library.Colors.SidebarBG,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    Utils.CreateElement("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Library.Colors.Border,
        BorderSizePixel = 0,
        Parent = Sidebar
    })
    
    local TabList = Utils.CreateElement("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Library.Colors.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Sidebar
    })
    
    local TabLayout = Utils.CreateElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = TabList
    })
    
    -- Content Area
    local ContentArea = Utils.CreateElement("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -180, 1, -60),
        Position = UDim2.new(0, 180, 0, 60),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    -- Notification Container
    local NotificationContainer = Utils.CreateElement("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -310, 0, 10),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = ScreenGui
    })
    
    Utils.CreateElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = NotificationContainer
    })
    
    -- Minimized Button
    local MinimizedButton = Utils.CreateElement("TextButton", {
        Name = "MinimizedBtn",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(1, -60, 1, -60),
        BackgroundColor3 = Library.Colors.Accent,
        Text = Library.Title:sub(1, 2):upper(),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Visible = false,
        ZIndex = 50,
        Parent = ScreenGui
    })
    
    Utils.CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = MinimizedButton
    })
    
    Utils.MakeDraggable(MainFrame, Header)
    Utils.MakeDraggable(MinimizedButton)
    
    -- Window Controls
    CloseBtn.MouseButton1Click:Connect(function()
        Utils.CreateRipple(CloseBtn)
        Library:Destroy()
    end)
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        Utils.CreateRipple(MinimizeBtn)
        Library:ToggleMinimize()
    end)
    
    MaximizeBtn.MouseButton1Click:Connect(function()
        Utils.CreateRipple(MaximizeBtn)
        Library:ToggleMaximize()
    end)
    
    MinimizedButton.MouseButton1Click:Connect(function()
        Library:ToggleMinimize()
    end)
    
    -- Keybind Toggle
    table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Library.Keybind then
            Library:Toggle()
        end
    end))
    
    -- Library Functions
    function Library:Toggle()
        self.Visible = not self.Visible
        MainFrame.Visible = self.Visible
    end
    
    function Library:Show()
        local success, err = pcall(function()
            -- Smart parent selection
            local targetParent = GetGuiParent()
            ScreenGui.Parent = targetParent
            
            -- Enable the GUI
            ScreenGui.Enabled = true
            self.Visible = true
            MainFrame.Visible = true
            
            -- Show load notification if enabled
            if self.ShowNotification and self._Injected then
                -- Only show if notification system is injected
                pcall(function()
                    self:ShowNotification("GUI Loaded", self.Title .. " loaded successfully!", "Success", 3)
                end)
            end
            
            -- Start auto-save if enabled
            if self.AutoSaveConfig then
                self:StartAutoSave()
            end
        end)
        
        if not success then
            warn("C4RL GUI: Failed to show GUI - " .. tostring(err))
            warn("Attempting PlayerGui fallback...")
            
            -- Emergency fallback
            pcall(function()
                local Players = game:GetService("Players")
                ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
                ScreenGui.Enabled = true
                self.Visible = true
                MainFrame.Visible = true
            end)
        end
    end
    
    function Library:ToggleMinimize()
        self.Minimized = not self.Minimized
        MainFrame.Visible = not self.Minimized
        MinimizedButton.Visible = self.Minimized
    end
    
    function Library:ToggleMaximize()
        if MainFrame.Size == Library.Size then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Size = UDim2.new(1, -20, 1, -20),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Size = Library.Size,
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        end
    end
    
    function Library:Destroy()
        for _, conn in ipairs(self.Connections) do
            conn:Disconnect()
        end
        ScreenGui:Destroy()
    end
    
    -- Injection-safe tab methods (stubs until InteractiveElements injects real ones)
    function Library:AddTab(options)
        if not self._Injected then
            error("C4RL GUI: AddTab called before InteractiveElements injection. Call InteractiveElements.Inject(Library) first!", 2)
        end
        -- This will be overridden by InteractiveElements module
        error("Tab methods are injected by InteractiveElements module")
    end
    
    function Library:SwitchTab(tabName)
        if not self._Injected then
            error("C4RL GUI: SwitchTab called before InteractiveElements injection.", 2)
        end
        error("Tab methods are injected by InteractiveElements module")
    end
    
    function Library:GetTab(tabName)
        if not self._Injected then
            error("C4RL GUI: GetTab called before InteractiveElements injection.", 2)
        end
        error("Tab methods are injected by InteractiveElements module")
    end
    
    -- Mark injection readiness
    function Library:_MarkInjected()
        self._Injected = true
    end
    
    -- Store references
    Library._ScreenGui = ScreenGui
    Library._MainFrame = MainFrame
    Library._Header = Header
    Library._Sidebar = Sidebar
    Library._TabList = TabList
    Library._TabLayout = TabLayout
    Library._ContentArea = ContentArea
    Library._NotificationContainer = NotificationContainer
    Library._Utils = Utils
    Library._Themes = Themes
    
    return Library
end

return WindowManager
