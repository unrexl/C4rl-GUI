--[[
    C4RL GUI LIBRARY - Advanced Elements Module
    Button, Dropdown, Keybind, TextInput, ColorPicker, ProgressBar, ChipSelector, InfoCard
]]

local AdvancedElements = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function AdvancedElements.Inject(Library, Utils)
    
    -- BUTTON
    function Library:AddButton(tabName, options)
        options = options or {}
        local tab = self:GetTab(tabName)
        if not tab then return end
        
        local name = options.Name or "Button"
        local description = options.Description or ""
        local color = options.Color or self.Colors.Accent
        local callback = options.Callback or function() end
        
        local Button = Utils.CreateElement("TextButton", {
            Name = name,
            Size = UDim2.new(1, -20, 0, description ~= "" and 65 or 45),
            BackgroundColor3 = color,
            Text = "",
            AutoButtonColor = false,
            ClipsDescendants = true,
            Parent = tab.Content
        })
        
        Button:SetAttribute("OriginalColor", Vector3.new(color.R * 255, color.G * 255, color.B * 255))
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Button})
        
        Utils.CreateElement("TextLabel", {
            Name = "Name",
            Size = UDim2.new(1, -30, 0, 20),
            Position = UDim2.new(0, 15, 0, description ~= "" and 10 or 12),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button
        })
        
        if description ~= "" then
            Utils.CreateElement("TextLabel", {
                Name = "Description",
                Size = UDim2.new(1, -30, 0, 30),
                Position = UDim2.new(0, 15, 0, 30),
                BackgroundTransparency = 1,
                Text = description,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                Parent = Button
            })
        end
        
        local hoverColor = Color3.fromRGB(
            math.min(color.R * 255 + 20, 255),
            math.min(color.G * 255 + 20, 255),
            math.min(color.B * 255 + 20, 255)
        )
        
        Utils.AddHoverEffect(Button, hoverColor)
        Button.MouseButton1Click:Connect(function()
            Utils.CreateRipple(Button)
            callback()
        end)
        
        return Button
    end
    
    -- DROPDOWN (simplified version)
    function Library:AddDropdown(tabName, options)
        options = options or {}
        local tab = self:GetTab(tabName)
        if not tab then return end
        
        local name = options.Name or "Dropdown"
        local items = options.Items or {}
        local default = options.Default or items[1]
        local callback = options.Callback or function() end
        
        local Dropdown = Utils.CreateElement("Frame", {
            Name = name,
            Size = UDim2.new(1, -20, 0, 50),
            BackgroundColor3 = self.Colors.CardBG,
            BorderSizePixel = 0,
            Parent = tab.Content
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Dropdown})
        
        Utils.CreateElement("TextLabel", {
            Size = UDim2.new(1, -30, 0, 20),
            Position = UDim2.new(0, 15, 0, 10),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            TextColor3 = self.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Dropdown
        })
        
        local DropButton = Utils.CreateElement("TextButton", {
            Size = UDim2.new(1, -30, 0, 25),
            Position = UDim2.new(0, 15, 0, 35),
            BackgroundColor3 = self.Colors.InputBG,
            Text = default,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = self.Colors.TextPrimary,
            AutoButtonColor = false,
            Parent = Dropdown
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropButton})
        
        local selected = default
        self.Config[name] = default
        
        -- Simplified - just cycles through items on click
        DropButton.MouseButton1Click:Connect(function()
            local currentIndex = table.find(items, selected) or 1
            local nextIndex = (currentIndex % #items) + 1
            selected = items[nextIndex]
            DropButton.Text = selected
            self.Config[name] = selected
            callback(selected)
        end)
        
        return {
            SetValue = function(val) selected = val; DropButton.Text = val; self.Config[name] = val end,
            GetValue = function() return selected end
        }
    end
    
    -- KEYBIND
    function Library:AddKeybind(tabName, options)
        options = options or {}
        local tab = self:GetTab(tabName)
        if not tab then return end
        
        local name = options.Name or "Keybind"
        local default = options.Default or Enum.KeyCode.F
        local callback = options.Callback or function() end
        
        local Keybind = Utils.CreateElement("Frame", {
            Name = name,
            Size = UDim2.new(1, -20, 0, 50),
            BackgroundColor3 = self.Colors.CardBG,
            BorderSizePixel = 0,
            Parent = tab.Content
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Keybind})
        
        Utils.CreateElement("TextLabel", {
            Size = UDim2.new(1, -100, 0, 20),
            Position = UDim2.new(0, 15, 0, 10),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            TextColor3 = self.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Keybind
        })
        
        local KeyButton = Utils.CreateElement("TextButton", {
            Size = UDim2.new(0, 80, 0, 28),
            Position = UDim2.new(1, -90, 0, 11),
            BackgroundColor3 = self.Colors.ElementBG,
            Text = default.Name,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = self.Colors.TextPrimary,
            AutoButtonColor = false,
            Parent = Keybind
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeyButton})
        
        local binding = false
        local currentKey = default
        self.Config[name] = default
        
        KeyButton.MouseButton1Click:Connect(function()
            if not binding then
                binding = true
                KeyButton.Text = "..."
                KeyButton.BackgroundColor3 = self.Colors.Accent
            end
        end)
        
        table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                self.Config[name] = currentKey
                KeyButton.Text = currentKey.Name
                KeyButton.BackgroundColor3 = self.Colors.ElementBG
                binding = false
            elseif not gameProcessed and input.KeyCode == currentKey then
                callback()
            end
        end))
        
        return {
            SetValue = function(key) currentKey = key; KeyButton.Text = key.Name; self.Config[name] = key end,
            GetValue = function() return currentKey end
        }
    end
    
    -- TEXT INPUT
    function Library:AddTextInput(tabName, options)
        options = options or {}
        local tab = self:GetTab(tabName)
        if not tab then return end
        
        local name = options.Name or "Text Input"
        local placeholder = options.Placeholder or "Enter text..."
        local default = options.Default or ""
        local callback = options.Callback or function() end
        
        local TextInput = Utils.CreateElement("Frame", {
            Name = name,
            Size = UDim2.new(1, -20, 0, 65),
            BackgroundColor3 = self.Colors.CardBG,
            BorderSizePixel = 0,
            Parent = tab.Content
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TextInput})
        
        Utils.CreateElement("TextLabel", {
            Size = UDim2.new(1, -30, 0, 20),
            Position = UDim2.new(0, 15, 0, 10),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            TextColor3 = self.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TextInput
        })
        
        local InputBox = Utils.CreateElement("TextBox", {
            Size = UDim2.new(1, -30, 0, 35),
            Position = UDim2.new(0, 15, 1, -40),
            BackgroundColor3 = self.Colors.InputBG,
            BorderSizePixel = 0,
            Text = default,
            PlaceholderText = placeholder,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = self.Colors.TextPrimary,
            PlaceholderColor3 = self.Colors.TextTertiary,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            Parent = TextInput
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = InputBox})
        Utils.CreateElement("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = InputBox})
        
        local currentText = default
        self.Config[name] = default
        
        InputBox.FocusLost:Connect(function(enterPressed)
            currentText = InputBox.Text
            self.Config[name] = currentText
            callback(currentText, enterPressed)
        end)
        
        return {
            SetValue = function(text) currentText = text; InputBox.Text = text; self.Config[name] = text end,
            GetValue = function() return currentText end
        }
    end
    
    -- INFO CARD
    function Library:AddInfoCard(tabName, options)
        options = options or {}
        local tab = self:GetTab(tabName)
        if not tab then return end
        
        local title = options.Title or "Info"
        local content = options.Content or ""
        local cardType = options.Type or "Info"
        
        local typeColors = {
            Info = self.Colors.Accent,
            Success = self.Colors.SuccessGreen,
            Warning = self.Colors.WarningYellow,
            Error = self.Colors.DangerRed
        }
        
        local color = typeColors[cardType] or self.Colors.Accent
        
        local InfoCard = Utils.CreateElement("Frame", {
            Size = UDim2.new(1, -20, 0, 0),
            BackgroundColor3 = self.Colors.CardBG,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = tab.Content
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = InfoCard})
        Utils.CreateElement("UIStroke", {Color = color, Thickness = 2, Parent = InfoCard})
        Utils.CreateElement("UIPadding", {
            PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), Parent = InfoCard
        })
        
        Utils.CreateElement("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = title,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = self.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = InfoCard
        })
        
        Utils.CreateElement("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 25),
            BackgroundTransparency = 1,
            Text = content,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = self.Colors.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = InfoCard
        })
        
        return InfoCard
    end
end

return AdvancedElements
