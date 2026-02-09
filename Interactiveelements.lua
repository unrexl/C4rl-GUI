--[[
    C4RL GUI LIBRARY - Interactive Elements Module
    Toggle, Slider, Button, Dropdown, ColorPicker, Keybind, TextInput
]]

local InteractiveElements = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function InteractiveElements.Inject(Library, Utils)
    
    -- TOGGLE
    function Library:AddToggle(tabName, options)
        options = options or {}
        local tab = self:GetTab(tabName)
        if not tab then return end
        
        local name = options.Name or "Toggle"
        local description = options.Description or ""
        local default = options.Default or false
        local callback = options.Callback or function() end
        
        local Toggle = Utils.CreateElement("Frame", {
            Name = name,
            Size = UDim2.new(1, -20, 0, description ~= "" and 65 or 50),
            BackgroundColor3 = self.Colors.CardBG,
            BorderSizePixel = 0,
            Parent = tab.Content
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Toggle})
        
        Utils.CreateElement("TextLabel", {
            Name = "Name",
            Size = UDim2.new(1, -70, 0, 20),
            Position = UDim2.new(0, 15, 0, 10),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            TextColor3 = self.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Toggle
        })
        
        if description ~= "" then
            Utils.CreateElement("TextLabel", {
                Name = "Description",
                Size = UDim2.new(1, -70, 0, 30),
                Position = UDim2.new(0, 15, 0, 30),
                BackgroundTransparency = 1,
                Text = description,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = self.Colors.TextSecondary,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                Parent = Toggle
            })
        end
        
        local ToggleButton = Utils.CreateElement("TextButton", {
            Name = "Button",
            Size = UDim2.new(0, 50, 0, 28),
            Position = UDim2.new(1, -60, 0, 11),
            BackgroundColor3 = default and self.Colors.SuccessGreen or self.Colors.ElementBG,
            Text = "",
            AutoButtonColor = false,
            Parent = Toggle
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleButton})
        
        local Circle = Utils.CreateElement("Frame", {
            Name = "Circle",
            Size = UDim2.new(0, 22, 0, 22),
            Position = default and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = ToggleButton
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})
        
        local toggled = default
        self.Config[name] = default
        
        local function SetValue(value)
            toggled = value
            self.Config[name] = value
            
            TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = value and self.Colors.SuccessGreen or self.Colors.ElementBG
            }):Play()
            
            TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = value and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            }):Play()
            
            callback(value)
        end
        
        ToggleButton.MouseButton1Click:Connect(function()
            Utils.CreateRipple(ToggleButton)
            SetValue(not toggled)
        end)
        
        table.insert(self.Elements[tabName], {
            Type = "Toggle",
            Name = name,
            Element = Toggle,
            SetValue = SetValue,
            GetValue = function() return toggled end
        })
        
        return {SetValue = SetValue, GetValue = function() return toggled end}
    end
    
    -- SLIDER
    function Library:AddSlider(tabName, options)
        options = options or {}
        local tab = self:GetTab(tabName)
        if not tab then return end
        
        local name = options.Name or "Slider"
        local description = options.Description or ""
        local min = options.Min or 0
        local max = options.Max or 100
        local default = options.Default or min
        local increment = options.Increment or 1
        local suffix = options.Suffix or ""
        local callback = options.Callback or function() end
        
        local Slider = Utils.CreateElement("Frame", {
            Name = name,
            Size = UDim2.new(1, -20, 0, description ~= "" and 80 or 65),
            BackgroundColor3 = self.Colors.CardBG,
            BorderSizePixel = 0,
            Parent = tab.Content
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Slider})
        
        Utils.CreateElement("TextLabel", {
            Name = "Name",
            Size = UDim2.new(1, -80, 0, 20),
            Position = UDim2.new(0, 15, 0, 10),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            TextColor3 = self.Colors.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Slider
        })
        
        local ValueLabel = Utils.CreateElement("TextLabel", {
            Name = "Value",
            Size = UDim2.new(0, 60, 0, 20),
            Position = UDim2.new(1, -70, 0, 10),
            BackgroundTransparency = 1,
            Text = tostring(default) .. suffix,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = self.Colors.Accent,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = Slider
        })
        
        if description ~= "" then
            Utils.CreateElement("TextLabel", {
                Name = "Description",
                Size = UDim2.new(1, -30, 0, 20),
                Position = UDim2.new(0, 15, 0, 30),
                BackgroundTransparency = 1,
                Text = description,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = self.Colors.TextSecondary,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = Slider
            })
        end
        
        local SliderTrack = Utils.CreateElement("Frame", {
            Name = "Track",
            Size = UDim2.new(1, -30, 0, 6),
            Position = UDim2.new(0, 15, 1, -20),
            BackgroundColor3 = self.Colors.ElementBG,
            BorderSizePixel = 0,
            Parent = Slider
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderTrack})
        
        local SliderFill = Utils.CreateElement("Frame", {
            Name = "Fill",
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = self.Colors.Accent,
            BorderSizePixel = 0,
            Parent = SliderTrack
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
        
        local SliderDot = Utils.CreateElement("Frame", {
            Name = "Dot",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = SliderTrack
        })
        
        Utils.CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderDot})
        
        local dragging = false
        local value = default
        self.Config[name] = default
        
        local function SetValue(val)
            val = math.clamp(val, min, max)
            val = math.floor((val - min) / increment + 0.5) * increment + min
            val = math.clamp(val, min, max)
            value = val
            self.Config[name] = val
            
            local percent = (val - min) / (max - min)
            ValueLabel.Text = tostring(val) .. suffix
            
            TweenService:Create(SliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = UDim2.new(percent, 0, 1, 0)
            }):Play()
            
            TweenService:Create(SliderDot, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Position = UDim2.new(percent, 0, 0.5, 0)
            }):Play()
            
            callback(val)
        end
        
        SliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local percent = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                SetValue(min + (max - min) * percent)
            end
        end)
        
        SliderTrack.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                SetValue(min + (max - min) * percent)
            end
        end))
        
        table.insert(self.Elements[tabName], {
            Type = "Slider",
            Name = name,
            Element = Slider,
            SetValue = SetValue,
            GetValue = function() return value end
        })
        
        return {SetValue = SetValue, GetValue = function() return value end}
    end
    
    -- See AdvancedElements.lua for: Button, Dropdown, ColorPicker, Keybind, TextInput, ProgressBar, ChipSelector, InfoCard
end

return InteractiveElements
