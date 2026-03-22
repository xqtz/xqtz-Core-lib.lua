local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════
-- THEMES
-- ═══════════════════════════════════════════
local THEMES = {
    crimson = {
        Name = "Crimson", Desc = "Deep blood red",
        Accent = Color3.fromRGB(130, 40, 40),
        AccentGlow = Color3.fromRGB(160, 50, 50),
        Primary = Color3.fromRGB(170, 100, 100),
    },
    obsidian = {
        Name = "Obsidian", Desc = "Dark ash with red glow",
        Accent = Color3.fromRGB(75, 45, 45),
        AccentGlow = Color3.fromRGB(140, 60, 60),
        Primary = Color3.fromRGB(135, 105, 105),
    },
    noir = {
        Name = "Noir", Desc = "Muted violet charcoal",
        Accent = Color3.fromRGB(110, 95, 135),
        AccentGlow = Color3.fromRGB(95, 80, 120),
        Primary = Color3.fromRGB(135, 140, 165),
    },
    ruby = {
        Name = "Ruby", Desc = "Soft deep red",
        Accent = Color3.fromRGB(150, 70, 70),
        AccentGlow = Color3.fromRGB(175, 85, 85),
        Primary = Color3.fromRGB(190, 125, 125),
    },
    forest = {
        Name = "Forest", Desc = "Calm natural green",
        Accent = Color3.fromRGB(65, 125, 85),
        AccentGlow = Color3.fromRGB(80, 150, 105),
        Primary = Color3.fromRGB(120, 175, 140),
    },
    ocean = {
        Name = "Ocean", Desc = "Balanced deep blue",
        Accent = Color3.fromRGB(70, 90, 150),
        AccentGlow = Color3.fromRGB(85, 110, 175),
        Primary = Color3.fromRGB(125, 140, 195),
    },
    sand = {
        Name = "Sand", Desc = "Warm neutral gold",
        Accent = Color3.fromRGB(155, 125, 70),
        AccentGlow = Color3.fromRGB(180, 145, 85),
        Primary = Color3.fromRGB(200, 175, 125),
    },
}

-- ═══════════════════════════════════════════
-- COLORS & FONTS
-- ═══════════════════════════════════════════
local Colors = {
    Background = Color3.fromRGB(18, 18, 22),
    Panel = Color3.fromRGB(24, 24, 30),
    PanelHeader = Color3.fromRGB(12, 12, 16),
    Card = Color3.fromRGB(28, 28, 34),
    Text = Color3.fromRGB(175, 172, 185),
    TextDim = Color3.fromRGB(90, 88, 100),
    TextBright = Color3.fromRGB(200, 198, 210),
    Border = Color3.fromRGB(42, 42, 52),
    TabActive = Color3.fromRGB(28, 28, 34),
    TabInactive = Color3.fromRGB(20, 20, 26),
    SilverDim = Color3.fromRGB(50, 50, 60),
    Button = Color3.fromRGB(35, 35, 45),
    Primary = Color3.fromRGB(120, 128, 155),
    Accent = Color3.fromRGB(120, 85, 130),
    AccentGlow = Color3.fromRGB(100, 58, 110),
}

local Fonts = {
    Title = Enum.Font.Antique,
    Header = Enum.Font.Antique,
    Body = Enum.Font.Garamond,
    Mono = Enum.Font.Code,
    Tab = Enum.Font.Antique,
}

local Sizes = {
    HeaderHeight = 48,
    TabHeight = 32,
    FooterHeight = 32,
    ContentPadding = 16,
    CornerRadius = 4,
    BorderWidth = 1,
    RowHeight = 34,
    RowSpacing = 6,
    ButtonHeight = 36,
}

-- ═══════════════════════════════════════════
-- INTERNAL HELPERS
-- ═══════════════════════════════════════════
local function create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

local function addCorner(parent, r)
    return create("UICorner", { CornerRadius = UDim.new(0, r or Sizes.CornerRadius), Parent = parent })
end

local function addStroke(parent, color, thickness)
    return create("UIStroke", { Color = color or Colors.Border, Thickness = thickness or Sizes.BorderWidth, Parent = parent })
end

local function addPadding(parent, t, r, b, l)
    return create("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        Parent = parent,
    })
end

local function addListLayout(parent, spacing)
    return create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, spacing or Sizes.RowSpacing),
        Parent = parent,
    })
end

-- ═══════════════════════════════════════════
-- THEME ENGINE
-- ═══════════════════════════════════════════
local themedElements = { accent = {}, accentGlow = {}, primary = {} }

local function registerThemed(list, inst, prop)
    table.insert(list, { inst = inst, prop = prop })
end

-- ═══════════════════════════════════════════
-- LIBRARY
-- ═══════════════════════════════════════════
local XQTZ = {}
XQTZ.__index = XQTZ

function XQTZ:AddTheme(key, theme)
    THEMES[key] = theme
end

function XQTZ:CreateWindow(options)
    options = options or {}
    local title = options.Title or "XQTZ CORE"
    local width = (options.Size and options.Size[1]) or 520
    local height = (options.Size and options.Size[2]) or 480
    local themeKey = options.Theme or "crimson"
    local footerText = options.Footer or "Eendracht maakt macht"
    local versionText = options.Version or "v1"
    local toggleKey = options.ToggleKey or "Minus"

    local currentThemeKey = themeKey
    local tabButtonsUI = {}
    local tabPages = {}
    local tabOrder = {}
    local activeTab = nil
    local orderCounter = 0

    -- Screen GUI
    local screenGui = create("ScreenGui", {
        Name = "XQTZ_CORE",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = PlayerGui,
    })

    -- Main Panel
    local mainPanel = create("Frame", {
        Name = "MainPanel",
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
        BackgroundColor3 = Colors.Panel,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        Parent = screenGui,
    })
    addCorner(mainPanel)
    addStroke(mainPanel)

    -- Header
    local header = create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, Sizes.HeaderHeight),
        BackgroundColor3 = Colors.PanelHeader,
        BorderSizePixel = 0,
        Parent = mainPanel,
    })
    addCorner(header)

    local accentLine = create("Frame", {
        Size = UDim2.new(0.5, 0, 0, 2),
        Position = UDim2.new(0.25, 0, 0, 0),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Parent = header,
    })
    registerThemed(themedElements.accent, accentLine, "BackgroundColor3")

    local titleLabel = create("TextLabel", {
        Text = title,
        Font = Fonts.Title,
        TextSize = 18,
        TextColor3 = Colors.Primary,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    registerThemed(themedElements.primary, titleLabel, "TextColor3")

    local closeBtn = create("TextButton", {
        Text = "×",
        Font = Fonts.Body,
        TextSize = 18,
        TextColor3 = Colors.TextDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -34, 0.5, -14),
        Parent = header,
    })
    closeBtn.MouseButton1Click:Connect(function()
        mainPanel.Visible = not mainPanel.Visible
    end)

    -- Tab bar
    local tabBar = create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, Sizes.TabHeight),
        Position = UDim2.new(0, 0, 0, Sizes.HeaderHeight),
        BackgroundColor3 = Colors.TabInactive,
        BorderSizePixel = 0,
        Parent = mainPanel,
    })

    -- Content area
    local contentArea = create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, 0, 1, -(Sizes.HeaderHeight + Sizes.TabHeight + Sizes.FooterHeight)),
        Position = UDim2.new(0, 0, 0, Sizes.HeaderHeight + Sizes.TabHeight),
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = mainPanel,
    })

    -- Footer
    local footer = create("Frame", {
        Size = UDim2.new(1, 0, 0, Sizes.FooterHeight),
        Position = UDim2.new(0, 0, 1, -Sizes.FooterHeight),
        BackgroundColor3 = Colors.PanelHeader,
        BorderSizePixel = 0,
        Parent = mainPanel,
    })
    create("TextLabel", {
        Text = footerText,
        Font = Fonts.Body,
        TextSize = 11,
        TextColor3 = Colors.TextDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.75, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = footer,
    })
    create("TextLabel", {
        Text = versionText,
        Font = Fonts.Mono,
        TextSize = 9,
        TextColor3 = Colors.TextDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.2, 0, 1, 0),
        Position = UDim2.new(0.8, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = footer,
    })

    -- ═══════════════════════════════════
    -- TAB SWITCHING
    -- ═══════════════════════════════════
    local function switchTab(id)
        activeTab = id
        for tabId, data in pairs(tabButtonsUI) do
            local isActive = (tabId == id)
            data.button.BackgroundColor3 = isActive and Colors.TabActive or Colors.TabInactive
            data.button.TextColor3 = isActive and Colors.Primary or Colors.TextDim
            data.indicator.Visible = isActive
        end
        for pageId, pg in pairs(tabPages) do
            pg.Visible = (pageId == id)
        end
    end

    local function rebuildTabBar()
        for _, child in ipairs(tabBar:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        tabButtonsUI = {}
        local count = #tabOrder
        for i, tabId in ipairs(tabOrder) do
            local tabData = tabPages[tabId]
            if not tabData then continue end
            local label = tabData:GetAttribute("TabLabel") or tabId
            local btn = create("TextButton", {
                Name = "Tab_" .. tabId,
                Text = label,
                Font = Fonts.Tab,
                TextSize = 11,
                TextColor3 = Colors.TextDim,
                BackgroundColor3 = Colors.TabInactive,
                BorderSizePixel = 0,
                Size = UDim2.new(1 / count, 0, 1, 0),
                Position = UDim2.new((i - 1) / count, 0, 0, 0),
                AutoButtonColor = false,
                Parent = tabBar,
            })
            local indicator = create("Frame", {
                Size = UDim2.new(0.6, 0, 0, 1),
                Position = UDim2.new(0.2, 0, 1, -1),
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
                Visible = (tabId == activeTab),
                Parent = btn,
            })
            registerThemed(themedElements.accent, indicator, "BackgroundColor3")
            tabButtonsUI[tabId] = { button = btn, indicator = indicator }
            btn.MouseButton1Click:Connect(function()
                switchTab(tabId)
            end)
        end
        if activeTab then switchTab(activeTab) end
    end

    -- ═══════════════════════════════════
    -- APPLY THEME
    -- ═══════════════════════════════════
    local function applyTheme(key)
        local theme = THEMES[key]
        if not theme then return end
        currentThemeKey = key
        Colors.Primary = theme.Primary
        Colors.Accent = theme.Accent
        Colors.AccentGlow = theme.AccentGlow
        for _, entry in ipairs(themedElements.primary) do
            pcall(function() entry.inst[entry.prop] = theme.Primary end)
        end
        for _, entry in ipairs(themedElements.accent) do
            pcall(function() entry.inst[entry.prop] = theme.Accent end)
        end
        for _, entry in ipairs(themedElements.accentGlow) do
            pcall(function() entry.inst[entry.prop] = theme.AccentGlow end)
        end
    end

    -- ═══════════════════════════════════
    -- KEYBIND
    -- ═══════════════════════════════════
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode.Name == toggleKey then
                mainPanel.Visible = not mainPanel.Visible
            end
        end
    end)

    -- Apply default theme
    applyTheme(currentThemeKey)

    -- ═══════════════════════════════════
    -- WINDOW OBJECT
    -- ═══════════════════════════════════
    local Window = {}
    Window.__index = Window

    function Window:Show() mainPanel.Visible = true end
    function Window:Hide() mainPanel.Visible = false end
    function Window:Toggle() mainPanel.Visible = not mainPanel.Visible end
    function Window:SetTitle(t) titleLabel.Text = t end
    function Window:Destroy() screenGui:Destroy() end
    function Window:SetTheme(key) applyTheme(key) end
    function Window:SetActiveTab(tabObj) switchTab(tabObj._id) end

    function Window:AddTab(opts)
        opts = opts or {}
        orderCounter = orderCounter + 1
        local tabId = "tab_" .. orderCounter
        local tabName = opts.Name or ("Tab " .. orderCounter)

        local page = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Colors.SilverDim,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = contentArea,
        })
        page:SetAttribute("TabLabel", tabName)
        addPadding(page, Sizes.ContentPadding, Sizes.ContentPadding, Sizes.ContentPadding, Sizes.ContentPadding)
        addListLayout(page)

        tabPages[tabId] = page
        table.insert(tabOrder, tabId)

        if #tabOrder == 1 then
            activeTab = tabId
        end
        rebuildTabBar()

        -- ═══════════════════════════════
        -- TAB OBJECT (add elements here)
        -- ═══════════════════════════════
        local Tab = { _id = tabId, _page = page, _order = 0 }
        Tab.__index = Tab

        function Tab:_nextOrder()
            self._order = self._order + 1
            return self._order
        end

        function Tab:AddSection(text)
            create("TextLabel", {
                Text = text,
                Font = Fonts.Header,
                TextSize = 13,
                TextColor3 = Colors.Primary,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = self:_nextOrder(),
                Parent = self._page,
            })
        end

        function Tab:AddLabel(opts)
            opts = opts or {}
            local row = create("Frame", {
                Size = UDim2.new(1, 0, 0, Sizes.RowHeight),
                BackgroundColor3 = Colors.Panel,
                BorderSizePixel = 0,
                LayoutOrder = self:_nextOrder(),
                Parent = self._page,
            })
            addCorner(row, 3)
            addStroke(row)
            addPadding(row, 0, 10, 0, 10)
            create("TextLabel", {
                Text = string.upper(opts.Text or ""),
                Font = Fonts.Header,
                TextSize = 10,
                TextColor3 = Colors.TextDim,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.4, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })
            local valueLabel = create("TextLabel", {
                Text = opts.Value or "",
                Font = Fonts.Body,
                TextSize = 14,
                TextColor3 = Colors.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(0.4, 0, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })
            local obj = {}
            function obj:Set(val) valueLabel.Text = tostring(val) end
            return obj
        end

        function Tab:AddButton(opts)
            opts = opts or {}
            local btn = create("TextButton", {
                Text = opts.Text or "Button",
                Font = Fonts.Body,
                TextSize = 12,
                TextColor3 = Colors.TextBright,
                BackgroundColor3 = Colors.Panel,
                Size = UDim2.new(1, 0, 0, Sizes.ButtonHeight),
                BorderSizePixel = 0,
                AutoButtonColor = false,
                LayoutOrder = self:_nextOrder(),
                Parent = self._page,
            })
            addCorner(btn, 3)
            addStroke(btn)
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Colors.Button end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Colors.Panel end)
            if opts.Callback then
                btn.MouseButton1Click:Connect(opts.Callback)
            end
            return btn
        end

        function Tab:AddToggle(opts)
            opts = opts or {}
            local enabled = opts.Default or false
            local row = create("Frame", {
                Size = UDim2.new(1, 0, 0, Sizes.RowHeight),
                BackgroundColor3 = Colors.Panel,
                BorderSizePixel = 0,
                LayoutOrder = self:_nextOrder(),
                Parent = self._page,
            })
            addCorner(row, 3)
            addStroke(row)
            addPadding(row, 0, 10, 0, 10)
            create("TextLabel", {
                Text = opts.Text or "Toggle",
                Font = Fonts.Body,
                TextSize = 12,
                TextColor3 = Colors.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.7, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })
            local toggleBtn = create("TextButton", {
                Text = enabled and "ON" or "OFF",
                Font = Fonts.Mono,
                TextSize = 10,
                TextColor3 = enabled and Colors.AccentGlow or Colors.TextDim,
                BackgroundColor3 = enabled and Colors.Accent or Colors.Card,
                Size = UDim2.new(0, 48, 0, 22),
                Position = UDim2.new(1, -48, 0.5, -11),
                AutoButtonColor = false,
                Parent = row,
            })
            addCorner(toggleBtn, 11)
            toggleBtn.MouseButton1Click:Connect(function()
                enabled = not enabled
                toggleBtn.Text = enabled and "ON" or "OFF"
                toggleBtn.TextColor3 = enabled and Colors.AccentGlow or Colors.TextDim
                toggleBtn.BackgroundColor3 = enabled and Colors.Accent or Colors.Card
                if opts.Callback then opts.Callback(enabled) end
            end)
            local obj = {}
            function obj:Set(val)
                enabled = val
                toggleBtn.Text = enabled and "ON" or "OFF"
                toggleBtn.TextColor3 = enabled and Colors.AccentGlow or Colors.TextDim
                toggleBtn.BackgroundColor3 = enabled and Colors.Accent or Colors.Card
            end
            return obj
        end

        function Tab:AddSlider(opts)
            opts = opts or {}
            local min = opts.Min or 0
            local max = opts.Max or 100
            local default = opts.Default or min
            local currentValue = default

            local _, valueLabel
            if opts.Text then
                local row = create("Frame", {
                    Size = UDim2.new(1, 0, 0, Sizes.RowHeight),
                    BackgroundColor3 = Colors.Panel,
                    BorderSizePixel = 0,
                    LayoutOrder = self:_nextOrder(),
                    Parent = self._page,
                })
                addCorner(row, 3)
                addStroke(row)
                addPadding(row, 0, 10, 0, 10)
                create("TextLabel", {
                    Text = string.upper(opts.Text),
                    Font = Fonts.Header,
                    TextSize = 10,
                    TextColor3 = Colors.TextDim,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.4, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })
                valueLabel = create("TextLabel", {
                    Text = tostring(default),
                    Font = Fonts.Body,
                    TextSize = 14,
                    TextColor3 = Colors.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Position = UDim2.new(0.4, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = row,
                })
            end

            local sliderFrame = create("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Colors.Card,
                BorderSizePixel = 0,
                LayoutOrder = self:_nextOrder(),
                Parent = self._page,
            })
            addCorner(sliderFrame, 3)
            addStroke(sliderFrame)
            addPadding(sliderFrame, 10, 12, 10, 12)

            local track = create("Frame", {
                Size = UDim2.new(1, -10, 0, 6),
                Position = UDim2.new(0, 5, 0, 10),
                BackgroundColor3 = Colors.Border,
                BorderSizePixel = 0,
                Parent = sliderFrame,
            })
            addCorner(track, 3)

            local ratio = (default - min) / (max - min)
            local fill = create("Frame", {
                Size = UDim2.new(ratio, 0, 1, 0),
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
                Parent = track,
            })
            addCorner(fill, 3)
            registerThemed(themedElements.accent, fill, "BackgroundColor3")

            local knob = create("TextButton", {
                Text = "",
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(ratio, -9, 0.5, -9),
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
                ZIndex = 2,
                Parent = track,
            })
            addCorner(knob, 9)
            registerThemed(themedElements.accent, knob, "BackgroundColor3")

            local dragging = false

            local function updateSlider(r)
                r = math.clamp(r, 0, 1)
                local value = math.floor(min + r * (max - min))
                currentValue = value
                if valueLabel then valueLabel.Text = tostring(value) end
                fill.Size = UDim2.new(r, 0, 1, 0)
                knob.Position = UDim2.new(r, -9, 0.5, -9)
                if opts.Callback then opts.Callback(value) end
            end

            knob.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local trackPos = track.AbsolutePosition.X
                    local trackWidth = track.AbsoluteSize.X
                    local mouseX = input.Position.X
                    local r = (mouseX - trackPos) / trackWidth
                    updateSlider(r)
                end
            end)

            -- Presets
            if opts.Presets and #opts.Presets > 0 then
                local presetFrame = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    LayoutOrder = self:_nextOrder(),
                    Parent = self._page,
                })
                local count = #opts.Presets
                for i, preset in ipairs(opts.Presets) do
                    local pbtn = create("TextButton", {
                        Text = tostring(preset),
                        Font = Fonts.Mono,
                        TextSize = 11,
                        TextColor3 = Colors.TextDim,
                        BackgroundColor3 = Colors.Panel,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1 / count, -4, 1, 0),
                        Position = UDim2.new((i - 1) / count, 2, 0, 0),
                        Parent = presetFrame,
                    })
                    addCorner(pbtn, 3)
                    addStroke(pbtn)
                    pbtn.MouseButton1Click:Connect(function()
                        local r = (preset - min) / (max - min)
                        updateSlider(r)
                    end)
                end
            end

            local obj = {}
            function obj:Set(val)
                local r = (val - min) / (max - min)
                updateSlider(r)
            end
            return obj
        end

        function Tab:AddTextbox(opts)
            opts = opts or {}
            local row = create("Frame", {
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Colors.Panel,
                BorderSizePixel = 0,
                LayoutOrder = self:_nextOrder(),
                Parent = self._page,
            })
            addCorner(row, 3)
            addStroke(row)
            addPadding(row, 8, 10, 8, 10)
            create("TextLabel", {
                Text = string.upper(opts.Text or "INPUT"),
                Font = Fonts.Header,
                TextSize = 10,
                TextColor3 = Colors.TextDim,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })
            local inputBox = create("TextBox", {
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0, 20),
                PlaceholderText = opts.Placeholder or "Type here...",
                Font = Fonts.Mono,
                TextSize = 12,
                TextColor3 = Colors.Text,
                BackgroundColor3 = Colors.Card,
                ClearTextOnFocus = false,
                Parent = row,
            })
            addCorner(inputBox, 3)
            if opts.Callback then
                inputBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        opts.Callback(inputBox.Text)
                    end
                end)
            end
        end

        function Tab:AddDropdown(opts)
            opts = opts or {}
            local options = opts.Options or {}
            local selected = opts.Default or (options[1] or "")
            local expanded = false

            local container = create("Frame", {
                Size = UDim2.new(1, 0, 0, Sizes.RowHeight),
                BackgroundColor3 = Colors.Panel,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                LayoutOrder = self:_nextOrder(),
                Parent = self._page,
            })
            addCorner(container, 3)
            addStroke(container)
            addPadding(container, 0, 10, 0, 10)

            create("TextLabel", {
                Text = string.upper(opts.Text or "SELECT"),
                Font = Fonts.Header,
                TextSize = 10,
                TextColor3 = Colors.TextDim,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.4, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = container,
            })

            local selectedBtn = create("TextButton", {
                Text = selected .. " ▼",
                Font = Fonts.Body,
                TextSize = 12,
                TextColor3 = Colors.Text,
                BackgroundColor3 = Colors.Card,
                Size = UDim2.new(0.55, 0, 0, 24),
                Position = UDim2.new(0.4, 0, 0.5, -12),
                AutoButtonColor = false,
                Parent = container,
            })
            addCorner(selectedBtn, 3)

            local dropdownList = create("Frame", {
                Size = UDim2.new(0.55, 0, 0, #options * 24),
                Position = UDim2.new(0.4, 0, 1, 2),
                BackgroundColor3 = Colors.Card,
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 10,
                Parent = container,
            })
            addCorner(dropdownList, 3)
            addStroke(dropdownList)

            for i, option in ipairs(options) do
                local optBtn = create("TextButton", {
                    Text = option,
                    Font = Fonts.Body,
                    TextSize = 11,
                    TextColor3 = Colors.Text,
                    BackgroundColor3 = Colors.Card,
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, (i - 1) * 24),
                    AutoButtonColor = false,
                    ZIndex = 11,
                    Parent = dropdownList,
                })
                optBtn.MouseEnter:Connect(function() optBtn.BackgroundColor3 = Colors.Button end)
                optBtn.MouseLeave:Connect(function() optBtn.BackgroundColor3 = Colors.Card end)
                optBtn.MouseButton1Click:Connect(function()
                    selected = option
                    selectedBtn.Text = option .. " ▼"
                    dropdownList.Visible = false
                    expanded = false
                    if opts.Callback then opts.Callback(option) end
                end)
            end

            selectedBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                dropdownList.Visible = expanded
            end)
        end

        return Tab
    end

    return setmetatable(Window, Window)
end

return XQTZ
