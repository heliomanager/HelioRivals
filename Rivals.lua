--==================================================
-- HELIO CLIENT - SIMPLE AUTHENTICATION VERSION
--==================================================

local Services = setmetatable({}, {
    __index = function(self, ind)
        local success, service = pcall(function()
            return game:GetService(ind)
        end)
        if success then return service end
        return nil
    end
})

local function CreateInstance(cls, props)
    local inst = Instance.new(cls)
    for i, v in pairs(props) do
        inst[i] = v
    end
    return inst
end

local Players = Services.Players
local UIS = Services.UserInputService
local TweenService = Services.TweenService
local CoreGui = Services.CoreGui
local GuiService = Services.GuiService
local RunService = Services.RunService
local Workspace = Services.Workspace
local HttpService = Services.HttpService
local MarketplaceService = Services.MarketplaceService

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

--==================================================
-- VERSION CHECK
--==================================================
local GAME_VERSION = 0.1
local VERSION_URL  = "https://pastebin.com/raw/3N641DcM"

local function InitializeUpdateCheck()
    local success, content = pcall(function()
        return game:HttpGet(VERSION_URL)
    end)

    if success then
        local remoteVersion = nil
        
        for line in string.gmatch(content, "[^\r\n]+") do
            local cleanLine = string.match(line, "^%s*(.-)%s*$")
            
            if cleanLine ~= "" and string.sub(cleanLine, 1, 2) ~= "//" then
                remoteVersion = tonumber(cleanLine)
                if remoteVersion then break end
            end
        end

        if remoteVersion then
            if remoteVersion ~= GAME_VERSION then
                player:Kick("\n[HELIO CLIENT]\nPlease update menu version!\nLocal: " .. GAME_VERSION .. "\nRequired: " .. remoteVersion)
            else
                print("Helio Client: Version match confirmed (" .. GAME_VERSION .. ")")
            end
        else
            warn("Helio Client: No valid version number found in Pastebin.")
        end
    else
        warn("Helio Client: Failed to fetch version from host.")
    end
end

InitializeUpdateCheck()

--==================================================
-- SIMPLE AUTHENTICATION CHECK
--==================================================
local WHITELIST_URL = "https://pastebin.com/raw/WyUHp2Ah"
local KEY_SITE_URL = "https://helioclient.great-site.net/"

-- Key decryption map for pastebin
local decryptMap = {
    ["7"]="0", ["4"]="1", ["9"]="2", ["1"]="3", ["0"]="4",
    ["6"]="5", ["8"]="6", ["2"]="7", ["5"]="8", ["3"]="9"
}

local function decrypt(str)
    local out = ""
    for i = 1, #str do
        local c = str:sub(i,i)
        out = out .. (decryptMap[c] or c)
    end
    return out
end

-- Create simple auth UI
local authGui = CreateInstance("ScreenGui", {
    Name = "AuthScreen",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui or player:WaitForChild("PlayerGui")
})

local authFrame = CreateInstance("Frame", {
    Parent = authGui,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 400, 0, 200),
    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
    BorderSizePixel = 0,
})
CreateInstance("UIStroke", { Parent = authFrame, Color = Color3.fromRGB(70, 70, 86), Thickness = 1 })
CreateInstance("UICorner", { Parent = authFrame, CornerRadius = UDim.new(0, 4) })

local authTitle = CreateInstance("TextLabel", {
    Parent = authFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 30),
    Size = UDim2.new(1, 0, 0, 40),
    Text = "HELIO CLIENT",
    Font = Enum.Font.GothamBold,
    TextSize = 24,
    TextColor3 = Color3.fromRGB(230, 230, 240),
    TextXAlignment = Enum.TextXAlignment.Center,
})

local statusLabel = CreateInstance("TextLabel", {
    Parent = authFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 80),
    Size = UDim2.new(1, 0, 0, 30),
    Text = "Checking authentication...",
    Font = Enum.Font.Gotham,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(170, 170, 185),
    TextXAlignment = Enum.TextXAlignment.Center,
})

-- Get Key Button (hidden initially)
local getKeyButton = CreateInstance("TextButton", {
    Parent = authFrame,
    Position = UDim2.new(0.5, -100, 0.5, 10),
    Size = UDim2.new(0, 200, 0, 40),
    BackgroundColor3 = Color3.fromRGB(36, 36, 44),
    Text = "GET KEY",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(230, 230, 240),
    AutoButtonColor = false,
    Visible = false,
})
CreateInstance("UICorner", { Parent = getKeyButton, CornerRadius = UDim.new(0, 4) })
CreateInstance("UIStroke", { 
    Parent = getKeyButton, 
    Color = Color3.fromRGB(70, 70, 86), 
    Thickness = 1 
})

local keySiteLabel = CreateInstance("TextLabel", {
    Parent = authFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0.8, 0),
    Size = UDim2.new(1, 0, 0, 20),
    Text = KEY_SITE_URL,
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(155, 110, 255),
    TextXAlignment = Enum.TextXAlignment.Center,
    Visible = false,
})

-- Button hover effect
getKeyButton.MouseEnter:Connect(function()
    TweenService:Create(getKeyButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
end)
getKeyButton.MouseLeave:Connect(function()
    TweenService:Create(getKeyButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(36, 36, 44)}):Play()
end)

-- Copy to clipboard function
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        return true
    elseif writeclipboard then
        writeclipboard(text)
        return true
    elseif toclipboard then
        toclipboard(text)
        return true
    elseif set_clipboard then
        set_clipboard(text)
        return true
    end
    return false
end

-- Get Key button click handler
getKeyButton.MouseButton1Click:Connect(function()
    if copyToClipboard(KEY_SITE_URL) then
        statusLabel.Text = "Copied to clipboard!"
        statusLabel.TextColor3 = Color3.fromRGB(80, 200, 120)
        
        -- Try to open the URL
        if request then
            pcall(function()
                request({
                    Url = KEY_SITE_URL,
                    Method = "GET"
                })
            end)
        end
    else
        statusLabel.Text = "Failed to copy. Visit: " .. KEY_SITE_URL
    end
end)

-- Function to check pastebin authentication
local function checkPastebinAuth()
    statusLabel.Text = "Checking whitelist..."
    
    local success, response = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)

    if not success or not response then
        statusLabel.Text = "Failed to load whitelist."
        return false
    end

    local myUserId = tostring(player.UserId)
    
    for line in response:gmatch("[^\r\n]+") do
        line = line:gsub("%s+", "")

        if line ~= "" and not line:match("^//") then
            local decryptedId = decrypt(line)

            if decryptedId == myUserId then
                statusLabel.Text = "✓ Authentication successful!"
                statusLabel.TextColor3 = Color3.fromRGB(80, 200, 120)
                task.wait(1)
                return true
            end
        end
    end
    
    -- Not in whitelist
    statusLabel.Text = "Not in whitelist."
    getKeyButton.Visible = true
    keySiteLabel.Visible = true
    return false
end

-- Start authentication check
task.spawn(function()
    if checkPastebinAuth() then
        authGui:Destroy()
        loadMainScript()
    end
    -- If not authenticated, the "Get Key" button will remain visible
end)

-- Function to load main script (will be defined after authentication)
function loadMainScript()
    --==================================================
    -- WEBHOOK LOGGER
    --==================================================
    local VERSION = "PAID"
    local gameName = "Unknown Game"
    local placeId = game.PlaceId

    local success, result = pcall(function()
        local productInfo = MarketplaceService:GetProductInfo(placeId)
        return productInfo.Name
    end)

    if success and result then
        gameName = result
    end

    local WEBHOOK_URL = "https://discord.com/api/webhooks/1462497284788060379/Y0Et2AabQzHxkfdkIrt7J2xSO4Vh4sygYPGo7a4jhouRh2q4V130eTQXpdthXtXwf_w0"

    local payload = HttpService:JSONEncode({
        content = string.format(
            "**Script Injected**\nUSER: %s\nUSER ID: %d\nGAME: %s\nPLACE ID: %d\nVERSION: %s",
            player.Name,
            player.UserId,
            gameName,
            placeId,
            VERSION
        )
    })

    local function sendWebhook()
        local success = pcall(function()
            HttpService:PostAsync(
                WEBHOOK_URL,
                payload,
                Enum.HttpContentType.ApplicationJson
            )
        end)
        if success then return end

        if fluxus and fluxus.request then
            pcall(function()
                fluxus.request({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = payload
                })
            end)
            return
        end

        if http_request then
            pcall(function()
                http_request({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = payload
                })
            end)
            return
        end

        warn("Webhook failed: executor does not support HTTP requests")
    end

    sendWebhook()

    print("HELIO CLIENT PAID LOADED")

    --==================================================
    -- FONTS AND UTILITIES
    --==================================================
    local FONT_MAIN = Enum.Font.Code
    local FONT_BOLD = Enum.Font.GothamBold

    local function Tween(o, t, goal)
        local tw = TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
        tw:Play()
        return tw
    end

    local function Clamp(x, a, b)
        if x < a then return a end
        if x > b then return b end
        return x
    end

    local function ClampInt(x, a, b)
        x = math.floor(tonumber(x) or 0)
        if x < a then return a end
        if x > b then return b end
        return x
    end

    local function GetMouse()
        local p = UIS:GetMouseLocation()
        local inset = GuiService and GuiService:GetGuiInset() or Vector2.new(0, 0)
        return Vector2.new(p.X - inset.X, p.Y - inset.Y)
    end

    local function ColorTo255(c3)
        return ClampInt(c3.R * 255, 0, 255), ClampInt(c3.G * 255, 0, 255), ClampInt(c3.B * 255, 0, 255)
    end

    local function ColorFrom255(r, g, b)
        return Color3.fromRGB(ClampInt(r,0,255), ClampInt(g,0,255), ClampInt(b,0,255))
    end

    local function Darken(c3, f)
        return Color3.fromRGB(
            ClampInt(c3.R * 255 * f, 0, 255),
            ClampInt(c3.G * 255 * f, 0, 255),
            ClampInt(c3.B * 255 * f, 0, 255)
        )
    end

    --==================================================
    -- THEME
    --==================================================
    local C = {
        MainBG      = Color3.fromRGB(18, 18, 22),
        PanelBG     = Color3.fromRGB(24, 24, 30),
        PanelBG2    = Color3.fromRGB(20, 20, 26),

        Stroke      = Color3.fromRGB(70, 70, 86),
        StrokeSoft  = Color3.fromRGB(48, 48, 60),

        Text        = Color3.fromRGB(230, 230, 240),
        TextDim     = Color3.fromRGB(170, 170, 185),

        Accent      = Color3.fromRGB(155, 110, 255),
        Accent2     = Color3.fromRGB(120, 80, 210),

        TabBG       = Color3.fromRGB(36, 36, 44),
        TabBG2      = Color3.fromRGB(30, 30, 38),

        Track       = Color3.fromRGB(60, 60, 72),
        Fill        = Color3.fromRGB(155, 110, 255),

        SectionBG   = Color3.fromRGB(22, 22, 28),
    }

    local Theme = {
        Accent = C.Accent,
        Accent2 = C.Accent2,
        Fill = C.Fill,
        _bindings = {},
    }

    function Theme:Bind(obj, prop, key)
        if not obj then return end
        table.insert(self._bindings, {obj = obj, prop = prop, key = key})
        pcall(function()
            obj[prop] = self[key]
        end)
    end

    function Theme:Set(key, value)
        self[key] = value
        C[key] = value
        if key == "Accent" then
            self.Fill = value
            C.Fill = value
        end

        for i = #self._bindings, 1, -1 do
            local b = self._bindings[i]
            if not b.obj or b.obj.Parent == nil then
                table.remove(self._bindings, i)
            else
                if b.key == key then
                    pcall(function()
                        b.obj[b.prop] = value
                    end)
                elseif key == "Accent" and b.key == "Fill" then
                    pcall(function()
                        b.obj[b.prop] = self.Fill
                    end)
                end
            end
        end
    end

    --==================================================
    -- ROOT GUI
    --==================================================
    local GUI_NAME = "PurpleMalevolenceTemplate"

    pcall(function()
        local old = CoreGui:FindFirstChild(GUI_NAME)
        if old then old:Destroy() end
    end)

    local ScreenGui = CreateInstance("ScreenGui", {
        Name = GUI_NAME,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    do
        local ok = pcall(function()
            ScreenGui.Parent = CoreGui
        end)
        if not ok then
            ScreenGui.Parent = player:WaitForChild("PlayerGui")
        end
    end

    local Overlay = CreateInstance("TextLabel", {
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -6, 1, -6),
        Size = UDim2.new(0, 320, 0, 16),
        Text = "https://discord.gg/sGnSuahz6x",
        Font = FONT_MAIN,
        TextSize = 12,
        TextColor3 = C.TextDim,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        ZIndex = 9999,
    })
    CreateInstance("UIStroke", { Parent = Overlay, Color = Color3.fromRGB(0,0,0), Thickness = 1, Transparency = 0.65 })

    --==================================================
    -- MAIN WINDOW
    --==================================================
    local Main = CreateInstance("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 520, 0, 600),
        BackgroundColor3 = C.MainBG,
        BorderSizePixel = 0,
    })
    CreateInstance("UIStroke", { Parent = Main, Color = C.Stroke, Thickness = 1, Transparency = 0.1 })
    CreateInstance("UICorner", { Parent = Main, CornerRadius = UDim.new(0, 2) })

    local TopStrip = CreateInstance("Frame", {
        Parent = Main,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 18),
    })
    Theme:Bind(TopStrip, "BackgroundColor3", "Accent")

    local TopStripStroke = CreateInstance("UIStroke", { Parent = TopStrip, Thickness = 1, Transparency = 0.2 })
    Theme:Bind(TopStripStroke, "Color", "Accent2")

    CreateInstance("TextLabel", {
        Parent = TopStrip,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "Helio Client ┃ Rivals",
        TextColor3 = Color3.fromRGB(245,245,255),
        TextTransparency = 0.05,
        Font = FONT_MAIN,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local TabsBar = CreateInstance("Frame", {
        Parent = Main,
        BackgroundColor3 = C.PanelBG,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 26),
        Size = UDim2.new(1, -20, 0, 44),
    })
    CreateInstance("UIStroke", { Parent = TabsBar, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.15 })

    local TabsBottomLine = CreateInstance("Frame", {
        Parent = TabsBar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
    })
    Theme:Bind(TabsBottomLine, "BackgroundColor3", "Accent")

    do
        local dragging, dragStart, startPos
        Main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mpos = GetMouse()
                local topY = Main.AbsolutePosition.Y
                if mpos.Y <= topY + 80 then
                    dragging = true
                    dragStart = input.Position
                    startPos = Main.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    --==================================================
    -- CONTENT PANEL
    --==================================================
    local ContentPanel = CreateInstance("Frame", {
        Parent = Main,
        BackgroundColor3 = C.PanelBG2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 82),
        Size = UDim2.new(1, -20, 1, -92),
    })
    CreateInstance("UIStroke", { Parent = ContentPanel, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

    local PageHost = CreateInstance("Frame", {
        Parent = ContentPanel,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true,
    })

    --==================================================
    -- HOOKS SYSTEM
    --==================================================
    local Hooks = { 
        player = {}, 
        aim = {}, 
        visuals = {}, 
        settings = {}, 
        global = {} 
    }

    local function FireHook(tabName, key, ...)
        tabName = string.lower(tabName)
        local t = Hooks[tabName]
        if t and t[key] then
            local ok, err = pcall(t[key], ...)
            if not ok then
                warn(("Hook error [%s.%s]: %s"):format(tabName, key, tostring(err)))
            end
        end
    end

    local function FireGlobal(key, ...)
        if Hooks.global and Hooks.global[key] then
            local ok, err = pcall(Hooks.global[key], ...)
            if not ok then
                warn(("Hook error [global.%s]: %s"):format(key, tostring(err)))
            end
        end
    end

    --==================================================
    -- PAGE + SCROLLBAR
    --==================================================
    local function CreatePage()
        local page = CreateInstance("Frame", {
            Parent = PageHost,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
        })

        local track = CreateInstance("Frame", {
            Parent = page,
            BackgroundColor3 = C.Track,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -10, 0, 10),
            Size = UDim2.new(0, 12, 1, -20),
        })
        CreateInstance("UIStroke", { Parent = track, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

        local thumb = CreateInstance("Frame", {
            Parent = track,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 2, 0, 2),
            Size = UDim2.new(1, -4, 0, 90),
        })
        Theme:Bind(thumb, "BackgroundColor3", "Accent")
        local thumbStroke = CreateInstance("UIStroke", { Parent = thumb, Thickness = 1, Transparency = 0.2 })
        Theme:Bind(thumbStroke, "Color", "Accent2")

        local scroll = CreateInstance("ScrollingFrame", {
            Parent = page,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -36, 1, -20),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingEnabled = true,
        })

        CreateInstance("UIListLayout", {
            Parent = scroll,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 14),
        })

        local function updateThumb()
            local viewH = scroll.AbsoluteWindowSize.Y
            local canvasH = scroll.AbsoluteCanvasSize.Y
            local needsScroll = (canvasH > viewH + 2)

            scroll.ScrollingEnabled = needsScroll
            thumb.Visible = needsScroll
            track.Visible = needsScroll

            if not needsScroll then
                scroll.CanvasPosition = Vector2.new(0, 0)
                return
            end

            local ratio = viewH / canvasH
            local th = math.floor((track.AbsoluteSize.Y - 4) * ratio)
            th = Clamp(th, 28, track.AbsoluteSize.Y - 4)

            local maxScroll = canvasH - viewH
            local y = 0
            if maxScroll > 0 then
                y = (scroll.CanvasPosition.Y / maxScroll) * (((track.AbsoluteSize.Y - 4) - th))
            end

            thumb.Size = UDim2.new(1, -4, 0, th)
            thumb.Position = UDim2.new(0, 2, 0, 2 + y)
        end

        scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(updateThumb)
        scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateThumb)
        scroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateThumb)
        track:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateThumb)

        do
            local dragging = false
            local dragStartY, startThumbY

            thumb.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragStartY = GetMouse().Y
                    startThumbY = thumb.AbsolutePosition.Y
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then dragging = false end
                    end)
                end
            end)

            UIS.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local viewH = scroll.AbsoluteWindowSize.Y
                    local canvasH = scroll.AbsoluteCanvasSize.Y
                    if canvasH <= viewH + 2 then return end

                    local th = thumb.AbsoluteSize.Y
                    local trackTop = track.AbsolutePosition.Y + 2
                    local trackSpan = (track.AbsoluteSize.Y - 4) - th

                    local dy = GetMouse().Y - dragStartY
                    local newY = Clamp((startThumbY + dy) - trackTop, 0, trackSpan)
                    local maxScroll = canvasH - viewH
                    scroll.CanvasPosition = Vector2.new(0, (newY / trackSpan) * maxScroll)
                end
            end)

            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
        end

        task.defer(updateThumb)
        return page, scroll
    end

    --==================================================
    -- SECTION + CONTROLS
    --==================================================
    local function MakeSection(scroll, tabName, title)
        local wrap = CreateInstance("Frame", {
            Parent = scroll,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })

        local panel = CreateInstance("Frame", {
            Parent = wrap,
            BackgroundColor3 = C.SectionBG,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        CreateInstance("UICorner", { Parent = panel, CornerRadius = UDim.new(0, 2) })
        CreateInstance("UIStroke", { Parent = panel, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

        local line = CreateInstance("Frame", {
            Parent = panel,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 8, 0, 10),
            Size = UDim2.new(0, 3, 1, -20),
        })
        Theme:Bind(line, "BackgroundColor3", "Accent")

        local inner = CreateInstance("Frame", {
            Parent = panel,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 10),
            Size = UDim2.new(1, -28, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })

        CreateInstance("TextLabel", {
            Parent = inner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = string.lower(title),
            Font = FONT_BOLD,
            TextSize = 18,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local body = CreateInstance("Frame", {
            Parent = inner,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 22),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })

        CreateInstance("UIListLayout", {
            Parent = body,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        })

        CreateInstance("UIPadding", {
            Parent = inner,
            PaddingBottom = UDim.new(0, 10),
        })

        return { __tab = tabName, Body = body }
    end

    local function MakeToggle(section, text, default, hookKey)
        local row = CreateInstance("Frame", {
            Parent = section.Body,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
        })

        local box = CreateInstance("Frame", {
            Parent = row,
            BackgroundColor3 = C.PanelBG,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, -7),
            Size = UDim2.new(0, 14, 0, 14),
        })
        local bs = CreateInstance("UIStroke", { Parent = box, Thickness = 1, Transparency = 0.15 })
        Theme:Bind(bs, "Color", "Accent")

        local fill = CreateInstance("Frame", {
            Parent = box,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 3, 0, 3),
            Size = UDim2.new(0, 8, 0, 8),
            Visible = default and true or false,
        })
        Theme:Bind(fill, "BackgroundColor3", "Accent")

        CreateInstance("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 22, 0, 0),
            Size = UDim2.new(1, -22, 1, 0),
            Text = string.lower(text),
            Font = FONT_MAIN,
            TextSize = 16,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local hit = CreateInstance("TextButton", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
        })

        local state = default and true or false
        local function set(v, silent)
            state = v and true or false
            fill.Visible = state
            if not silent then FireHook(section.__tab, hookKey, state) end
        end

        hit.MouseButton1Click:Connect(function()
            set(not state, false)
        end)

        return { Set = function(v) set(v, true) end, Get = function() return state end }
    end

    local function MakeSlider(section, leftText, minV, maxV, defaultV, hookKey, rightLabelText)
        local row = CreateInstance("Frame", {
            Parent = section.Body,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
        })

        CreateInstance("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 120, 1, 0),
            Text = string.lower(leftText),
            Font = FONT_MAIN,
            TextSize = 16,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local track = CreateInstance("Frame", {
            Parent = row,
            BackgroundColor3 = C.Track,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 130, 0.5, -6),
            Size = UDim2.new(0, 240, 0, 12),
        })
        CreateInstance("UIStroke", { Parent = track, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

        local fill = CreateInstance("Frame", {
            Parent = track,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0),
        })
        Theme:Bind(fill, "BackgroundColor3", "Fill")

        local valueLabel = CreateInstance("TextLabel", {
            Parent = track,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = tostring(defaultV),
            Font = FONT_BOLD,
            TextSize = 14,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Center,
        })

        CreateInstance("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 380, 0, 0),
            Size = UDim2.new(1, -380, 1, 0),
            Text = string.lower(rightLabelText or ""),
            Font = FONT_MAIN,
            TextSize = 16,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = rightLabelText and 0 or 1,
        })

        local grabbing = false
        local val = defaultV

        local function setFromX(x, silent)
            local aX = track.AbsolutePosition.X
            local w = track.AbsoluteSize.X
            local t = Clamp((x - aX) / w, 0, 1)
            val = math.floor(minV + (maxV - minV) * t + 0.5)
            fill.Size = UDim2.new(t, 0, 1, 0)
            valueLabel.Text = tostring(val)
            if not silent then FireHook(section.__tab, hookKey, val) end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                grabbing = true
                setFromX(GetMouse().X, false)
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if grabbing and input.UserInputType == Enum.UserInputType.MouseMovement then
                setFromX(GetMouse().X, false)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                grabbing = false
            end
        end)

        task.defer(function()
            local t = (defaultV - minV) / (maxV - minV)
            setFromX(track.AbsolutePosition.X + (track.AbsoluteSize.X * t), true)
        end)

        return { Set = function(v)
            v = Clamp(v, minV, maxV)
            local t = (v - minV) / (maxV - minV)
            setFromX(track.AbsolutePosition.X + (track.AbsoluteSize.X * t), true)
        end, Get = function() return val end }
    end

    local function MakeButton(section, text, hookKey)
        local row = CreateInstance("Frame", {
            Parent = section.Body,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 26),
        })

        local btn = CreateInstance("TextButton", {
            Parent = row,
            BackgroundColor3 = C.TabBG2,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Text = string.lower(text),
            Font = FONT_MAIN,
            TextSize = 16,
            TextColor3 = C.Text,
            AutoButtonColor = false,
        })
        CreateInstance("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 1) })
        CreateInstance("UIStroke", { Parent = btn, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

        local under = CreateInstance("Frame", {
            Parent = btn,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundTransparency = 0.35,
        })
        Theme:Bind(under, "BackgroundColor3", "Accent")

        btn.MouseEnter:Connect(function() Tween(btn, 0.1, {BackgroundColor3 = C.TabBG}) end)
        btn.MouseLeave:Connect(function() Tween(btn, 0.1, {BackgroundColor3 = C.TabBG2}) end)

        btn.MouseButton1Click:Connect(function()
            FireHook(section.__tab, hookKey, true)
        end)

        return btn
    end

    local function MakeKeybindButton(section, text, defaultKey, hookKey)
        local row = CreateInstance("Frame", {
            Parent = section.Body,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 26),
        })

        local btn = CreateInstance("TextButton", {
            Parent = row,
            BackgroundColor3 = C.TabBG2,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Text = string.lower(text) .. ": " .. defaultKey,
            Font = FONT_MAIN,
            TextSize = 16,
            TextColor3 = C.Text,
            AutoButtonColor = false,
        })
        CreateInstance("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 1) })
        CreateInstance("UIStroke", { Parent = btn, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

        local under = CreateInstance("Frame", {
            Parent = btn,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundTransparency = 0.35,
        })
        Theme:Bind(under, "BackgroundColor3", "Accent")

        local isListening = false
        local currentKey = defaultKey

        local function startListening()
            isListening = true
            btn.Text = "press a key"
            btn.BackgroundColor3 = C.Accent
            
            local connection
            connection = UIS.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode.Name
                    btn.Text = string.lower(text) .. ": " .. currentKey
                    btn.BackgroundColor3 = C.TabBG2
                    isListening = false
                    connection:Disconnect()
                    FireHook(section.__tab, hookKey, currentKey)
                end
            end)
        end

        btn.MouseButton1Click:Connect(function()
            if not isListening then
                startListening()
            end
        end)

        btn.MouseEnter:Connect(function() 
            if not isListening then
                Tween(btn, 0.1, {BackgroundColor3 = C.TabBG}) 
            end
        end)
        btn.MouseLeave:Connect(function() 
            if not isListening then
                Tween(btn, 0.1, {BackgroundColor3 = C.TabBG2}) 
            end
        end)

        return { Set = function(key) 
            currentKey = key
            btn.Text = string.lower(text) .. ": " .. currentKey
        end, Get = function() return currentKey end }
    end

    local function MakeDropdown(section, text, items, defaultItem, hookKey)
        local wrap = CreateInstance("Frame", {
            Parent = section.Body,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
        })

        CreateInstance("TextLabel", {
            Parent = wrap,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 140, 1, 0),
            Text = string.lower(text),
            Font = FONT_MAIN,
            TextSize = 16,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local btn = CreateInstance("TextButton", {
            Parent = wrap,
            BackgroundColor3 = C.TabBG2,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 150, 0.5, -10),
            Size = UDim2.new(1, -150, 0, 20),
            Text = string.lower(defaultItem or (items[1] or "select")),
            Font = FONT_MAIN,
            TextSize = 15,
            TextColor3 = C.TextDim,
            AutoButtonColor = false,
        })
        CreateInstance("UIStroke", { Parent = btn, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

        local open = false
        local listFrame

        local function closeList()
            open = false
            if listFrame then listFrame:Destroy() listFrame = nil end
        end

        btn.MouseButton1Click:Connect(function()
            if open then closeList() return end
            open = true

            listFrame = CreateInstance("Frame", {
                Parent = ScreenGui,
                BackgroundColor3 = C.PanelBG,
                BorderSizePixel = 0,
                Size = UDim2.new(0, btn.AbsoluteSize.X, 0, math.min(200, (#items * 22) + 6)),
                Position = UDim2.new(0, btn.AbsolutePosition.X, 0, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y + 2),
                ZIndex = 5000,
            })
            CreateInstance("UIStroke", { Parent = listFrame, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

            local sc = CreateInstance("ScrollingFrame", {
                Parent = listFrame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 4,
                ZIndex = 5001,
            })
            Theme:Bind(sc, "ScrollBarImageColor3", "Accent")
            CreateInstance("UIListLayout", { Parent = sc, Padding = UDim.new(0, 2) })

            for _, it in ipairs(items) do
                local opt = CreateInstance("TextButton", {
                    Parent = sc,
                    BackgroundColor3 = C.TabBG2,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -6, 0, 20),
                    Position = UDim2.new(0, 3, 0, 0),
                    Text = string.lower(tostring(it)),
                    Font = FONT_MAIN,
                    TextSize = 15,
                    TextColor3 = C.Text,
                    AutoButtonColor = false,
                    ZIndex = 5002,
                })
                opt.MouseEnter:Connect(function() Tween(opt, 0.1, {BackgroundColor3 = C.TabBG}) end)
                opt.MouseLeave:Connect(function() Tween(opt, 0.1, {BackgroundColor3 = C.TabBG2}) end)
                opt.MouseButton1Click:Connect(function()
                    btn.Text = string.lower(tostring(it))
                    FireHook(section.__tab, hookKey, it)
                    closeList()
                end)
            end
        end)

        UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
                local m = GetMouse()
                if listFrame then
                    local p = listFrame.AbsolutePosition
                    local s = listFrame.AbsoluteSize
                    local inside = (m.X >= p.X and m.X <= p.X + s.X and m.Y >= p.Y and m.Y <= p.Y + s.Y)
                    local bp = btn.AbsolutePosition
                    local bs = btn.AbsoluteSize
                    local insideBtn = (m.X >= bp.X and m.X <= bp.X + bs.X and m.Y >= bp.Y and m.Y <= bp.Y + bs.Y)
                    if not inside and not insideBtn then closeList() end
                end
            end
        end)

        return { Close = closeList }
    end

    local function MakeColorPicker(section, text, defaultColor, hookKey)
        defaultColor = defaultColor or C.Accent

        local row = CreateInstance("Frame", {
            Parent = section.Body,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
        })

        CreateInstance("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 160, 1, 0),
            Text = string.lower(text),
            Font = FONT_MAIN,
            TextSize = 16,
            TextColor3 = C.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local preview = CreateInstance("Frame", {
            Parent = row,
            BackgroundColor3 = defaultColor,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -44, 0.5, -9),
            Size = UDim2.new(0, 18, 0, 18),
        })
        CreateInstance("UICorner", { Parent = preview, CornerRadius = UDim.new(0, 2) })
        CreateInstance("UIStroke", { Parent = preview, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

        local btn = CreateInstance("TextButton", {
            Parent = row,
            BackgroundColor3 = C.TabBG2,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -140, 0.5, -10),
            Size = UDim2.new(0, 90, 0, 20),
            Text = "pick",
            Font = FONT_MAIN,
            TextSize = 15,
            TextColor3 = C.TextDim,
            AutoButtonColor = false,
        })
        CreateInstance("UIStroke", { Parent = btn, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

        local open = false
        local pop
        local popPrev
        local current = defaultColor

        local function fire()
            preview.BackgroundColor3 = current
            FireHook(section.__tab, hookKey, current)
        end

        local function MakeInlineSlider(parent, label, minV, maxV, value0, onChange)
            local srow = CreateInstance("Frame", {
                Parent = parent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
            })

            CreateInstance("TextLabel", {
                Parent = srow,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 24, 1, 0),
                Text = label,
                Font = FONT_BOLD,
                TextSize = 14,
                TextColor3 = C.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            local track = CreateInstance("Frame", {
                Parent = srow,
                BackgroundColor3 = C.Track,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 28, 0.5, -6),
                Size = UDim2.new(0, 200, 0, 12),
            })
            CreateInstance("UIStroke", { Parent = track, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

            local fill = CreateInstance("Frame", {
                Parent = track,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 0, 1, 0),
            })
            Theme:Bind(fill, "BackgroundColor3", "Fill")

            local valueLabel = CreateInstance("TextLabel", {
                Parent = track,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = tostring(value0),
                Font = FONT_MAIN,
                TextSize = 13,
                TextColor3 = C.Text,
                TextXAlignment = Enum.TextXAlignment.Center,
            })

            local grabbing = false
            local val = value0

            local function setFromX(x, silent)
                local aX = track.AbsolutePosition.X
                local w = track.AbsoluteSize.X
                local t = Clamp((x - aX) / w, 0, 1)
                val = math.floor(minV + (maxV - minV) * t + 0.5)
                fill.Size = UDim2.new(t, 0, 1, 0)
                valueLabel.Text = tostring(val)
                if not silent and onChange then onChange(val) end
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    grabbing = true
                    setFromX(GetMouse().X, false)
                end
            end)

            UIS.InputChanged:Connect(function(input)
                if grabbing and input.UserInputType == Enum.UserInputType.MouseMovement then
                    setFromX(GetMouse().X, false)
                end
            end)

            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    grabbing = false
                end
            end)

            task.defer(function()
                local t = (value0 - minV) / (maxV - minV)
                setFromX(track.AbsolutePosition.X + (track.AbsoluteSize.X * t), true)
            end)

            return { Get = function() return val end }
        end

        local function closePop()
            open = false
            if pop then pop:Destroy() pop = nil end
            popPrev = nil
        end

        btn.MouseButton1Click:Connect(function()
            if open then closePop() return end
            open = true

            local bx, by = btn.AbsolutePosition.X, btn.AbsolutePosition.Y
            local bw, bh = btn.AbsoluteSize.X, btn.AbsoluteSize.Y

            pop = CreateInstance("Frame", {
                Parent = ScreenGui,
                BackgroundColor3 = C.PanelBG,
                BorderSizePixel = 0,
                Position = UDim2.new(0, bx, 0, by + bh + 6),
                Size = UDim2.new(0, 260, 0, 150),
                ZIndex = 6000,
            })
            CreateInstance("UIStroke", { Parent = pop, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })
            CreateInstance("UICorner", { Parent = pop, CornerRadius = UDim.new(0, 2) })

            CreateInstance("TextLabel", {
                Parent = pop,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 8),
                Size = UDim2.new(1, -20, 0, 16),
                Text = "rgb picker",
                Font = FONT_BOLD,
                TextSize = 14,
                TextColor3 = C.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6001,
            })

            local tline = CreateInstance("Frame", {
                Parent = pop,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 28),
                Size = UDim2.new(1, -20, 0, 2),
                ZIndex = 6001,
                BackgroundTransparency = 0.35,
            })
            Theme:Bind(tline, "BackgroundColor3", "Accent")

            popPrev = CreateInstance("Frame", {
                Parent = pop,
                BackgroundColor3 = current,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -10, 0, 8),
                Size = UDim2.new(0, 20, 0, 20),
                ZIndex = 6002,
            })
            CreateInstance("UICorner", { Parent = popPrev, CornerRadius = UDim.new(0, 2) })
            CreateInstance("UIStroke", { Parent = popPrev, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })

            local body = CreateInstance("Frame", {
                Parent = pop,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 36),
                Size = UDim2.new(1, -20, 1, -46),
                ZIndex = 6001,
            })
            CreateInstance("UIListLayout", { Parent = body, Padding = UDim.new(0, 8) })

            local function apply(r, g, b)
                current = ColorFrom255(r, g, b)
                preview.BackgroundColor3 = current
                if popPrev then popPrev.BackgroundColor3 = current end
            end

            local rr, gg, bb = ColorTo255(current)
            MakeInlineSlider(body, "r", 0, 255, rr, function(v)
                local _, g, b = ColorTo255(current)
                apply(v, g, b)
                fire()
            end)
            MakeInlineSlider(body, "g", 0, 255, gg, function(v)
                local r, _, b = ColorTo255(current)
                apply(r, v, b)
                fire()
            end)
            MakeInlineSlider(body, "b", 0, 255, bb, function(v)
                local r, g, _ = ColorTo255(current)
                apply(r, g, v)
                fire()
            end)
        end)

        UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
                local m = GetMouse()

                local insidePop = false
                if pop then
                    local p = pop.AbsolutePosition
                    local s = pop.AbsoluteSize
                    insidePop = (m.X >= p.X and m.X <= p.X + s.X and m.Y >= p.Y and m.Y <= p.Y + s.Y)
                end

                local bp = btn.AbsolutePosition
                local bs = btn.AbsoluteSize
                local insideBtn = (m.X >= bp.X and m.X <= bp.X + bs.X and m.Y >= bp.Y and m.Y <= bp.Y + bs.Y)

                if not insidePop and not insideBtn then
                    closePop()
                end
            end
        end)

        return {
            Set = function(c3, silent)
                current = c3 or current
                preview.BackgroundColor3 = current
                if popPrev then popPrev.BackgroundColor3 = current end
                if not silent then fire() end
            end,
            Get = function() return current end,
            Close = closePop,
        }
    end

    --==================================================
    -- TAB SYSTEM
    --==================================================
    local Tabs = {}
    local ActiveTab = nil

    local TabButtonsHolder = CreateInstance("Frame", {
        Parent = TabsBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 7),
        Size = UDim2.new(1, -20, 0, 30),
    })

    CreateInstance("UIListLayout", {
        Parent = TabButtonsHolder,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
    })

    local function MakeTabButton(name, order)
        local btn = CreateInstance("TextButton", {
            Parent = TabButtonsHolder,
            BackgroundColor3 = C.TabBG2,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 110, 0, 28),
            Text = string.lower(name),
            Font = FONT_MAIN,
            TextSize = 16,
            TextColor3 = C.TextDim,
            AutoButtonColor = false,
            LayoutOrder = order,
        })
        CreateInstance("UIStroke", { Parent = btn, Color = C.StrokeSoft, Thickness = 1, Transparency = 0.2 })
        CreateInstance("UICorner", { CornerRadius = UDim.new(0, 1), Parent = btn })

        local underline = CreateInstance("Frame", {
            Parent = btn,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundTransparency = 1,
        })
        Theme:Bind(underline, "BackgroundColor3", "Accent")

        return btn, underline
    end

    local function SwitchTab(name)
        name = string.lower(name)
        if ActiveTab == name then return end
        local newTab = Tabs[name]
        if not newTab then return end

        if ActiveTab and Tabs[ActiveTab] then
            local old = Tabs[ActiveTab]
            old.Button.TextColor3 = C.TextDim
            old.Underline.BackgroundTransparency = 1
            if old.Page then
                old.Page.Visible = false
                old.Page.Position = UDim2.new(0, 0, 0, 0)
            end
        end

        ActiveTab = name
        newTab.Button.TextColor3 = C.Text
        newTab.Underline.BackgroundTransparency = 0

        if newTab.Page then
            newTab.Page.Position = UDim2.new(0.06, 0, 0, 0)
            newTab.Page.Visible = true
            Tween(newTab.Page, 0.12, {Position = UDim2.new(0, 0, 0, 0)})
        end

        FireGlobal("tab_changed", name)
    end

    local function RegisterTab(name, order)
        name = string.lower(name)
        local btn, underline = MakeTabButton(name, order)
        local page, scroll = CreatePage()

        Tabs[name] = { Name = name, Button = btn, Underline = underline, Page = page, Scroll = scroll }

        btn.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)

        return Tabs[name]
    end

    local UI = {}
    function UI:Section(tabName, title)
        tabName = string.lower(tabName)
        local tab = Tabs[tabName]
        if not tab then return nil end
        return MakeSection(tab.Scroll, tabName, title)
    end

    function UI:Toggle(section, text, default, hookKey) return MakeToggle(section, text, default, hookKey) end
    function UI:Slider(section, text, minV, maxV, defaultV, hookKey, rightLabel) return MakeSlider(section, text, minV, maxV, defaultV, hookKey, rightLabel) end
    function UI:Dropdown(section, text, items, defaultItem, hookKey) return MakeDropdown(section, text, items, defaultItem, hookKey) end
    function UI:Button(section, text, hookKey) return MakeButton(section, text, hookKey) end
    function UI:Keybind(section, text, defaultKey, hookKey) return MakeKeybindButton(section, text, defaultKey, hookKey) end
    function UI:ColorPicker(section, text, defaultColor, hookKey) return MakeColorPicker(section, text, defaultColor, hookKey) end

    --==================================================
    -- GAME VARIABLES - MOVEMENT FIXED
    --==================================================
    -- Walkspeed - ALWAYS ENABLED
    local WS_Target = 16
    local WS_Enabled = true  -- Always enabled now

    -- Jump Power - ALWAYS ENABLED
    local JP_Target = 50
    local JP_Enabled = true  -- Always enabled now

    -- Bunny Hop - ALWAYS ENABLED WHEN TOGGLED ON
    local BunnyHopEnabled = false
    local BunnyHopConnection = nil
    local BunnyHopKey = Enum.KeyCode.Space
    local BunnyHopForce = 100

    -- Spin - ALWAYS ENABLED WHEN VALUE > 0
    local SpinSpeed = 0
    local SpinConnection = nil

    -- Noclip - ALWAYS ENABLED WHEN TOGGLED ON
    local NoclipEnabled = false
    local NoclipConnection = nil

    -- ESP
    local ESPEnabled = false
    local ESPBoxes = {}
    local ESPConnection = nil
    local ESPColor = Color3.fromRGB(255, 50, 50)
    local ESPTextColor = Color3.fromRGB(255, 255, 255)
    local ESPShowHealth = true
    local ESPShowDistance = true
    local ESPShowName = true
    local ESPMaxDistance = 2000

    -- Aimbot
    local AimbotEnabled = false
    local AimbotActive = false
    local AimbotMode = "Toggle"
    local AimbotKey = Enum.KeyCode.Q
    local AimbotTargetPart = "Head"
    local AimbotConnection = nil
    local AimbotFOV = 200
    local AimbotSmoothness = 50
    local IgnoreDeadTargets = true
    local PredictionEnabled = false
    local PredictionStrength = 0
    local DistanceLimiterEnabled = false
    local DistanceLimiterMax = 1000
    local FOVColor = Color3.fromRGB(255, 50, 50)
    local FOVCircle = nil
    local LockedTarget = nil

    -- Menu Toggle
    local menuToggleKey = Enum.KeyCode.RightShift

    local ESPTextGui = CreateInstance("ScreenGui", {
        Name = "ESPTextGui",
        ResetOnSpawn = false,
        DisplayOrder = 999,
        Enabled = true,
        Parent = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
    })

    --==================================================
    -- MOVEMENT FUNCTIONS - FIXED (ALWAYS WORK)
    --==================================================
    local MovementConnection = RunService.Stepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            
            -- WALKSPEED - ALWAYS APPLIES VALUE
            humanoid.WalkSpeed = WS_Target
            
            -- JUMP POWER - ALWAYS APPLIES VALUE
            humanoid.JumpPower = JP_Target
        end
    end)

    -- Bunny Hop function - works when enabled
    local function startBunnyHop()
        if BunnyHopConnection then BunnyHopConnection:Disconnect() end
        
        BunnyHopConnection = RunService.Stepped:Connect(function()
            if not BunnyHopEnabled or not player.Character then return end
            
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoidRootPart and UIS:IsKeyDown(BunnyHopKey) then
                local ray = Ray.new(humanoidRootPart.Position, Vector3.new(0, -3, 0))
                local part = Workspace:FindPartOnRayWithIgnoreList(ray, {character})
                
                if not part then
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Velocity = Vector3.new(0, BunnyHopForce, 0)
                    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
                    bodyVelocity.Parent = humanoidRootPart
                    
                    game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
                end
            end
        end)
    end

    local function stopBunnyHop()
        if BunnyHopConnection then
            BunnyHopConnection:Disconnect()
            BunnyHopConnection = nil
        end
    end

    -- Spin function - works when value > 0
    local function updateSpin()
        if SpinConnection then SpinConnection:Disconnect() end
        
        SpinConnection = RunService.Stepped:Connect(function()
            if not player.Character then return end
            
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart and SpinSpeed > 0 then
                humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
            end
        end)
    end

    -- Noclip function - works when enabled
    local function startNoclip()
        if NoclipConnection then NoclipConnection:Disconnect() end
        
        NoclipConnection = RunService.Stepped:Connect(function()
            if not NoclipEnabled or not player.Character then return end
            
            local character = player.Character
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end

    local function stopNoclip()
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
            
            if player.Character then
                local character = player.Character
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end

    --==================================================
    -- ESP FUNCTIONS
    --==================================================
    local function createESPBox(targetPlayer)
        if ESPBoxes[targetPlayer] then return end
        if not targetPlayer.Character then return end
        
        local character = targetPlayer.Character
        
        local highlight = Instance.new("Highlight")
        highlight.Name = targetPlayer.Name .. "_ESP"
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
        highlight.OutlineColor = ESPColor
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = character
        highlight.Parent = character
        
        local billboard = CreateInstance("BillboardGui", {
            Name = targetPlayer.Name .. "_ESPBillboard",
            Active = true,
            Size = UDim2.new(0, 200, 0, 100),
            StudsOffset = Vector3.new(0, 3, 0),
            MaxDistance = ESPMaxDistance,
            AlwaysOnTop = true,
            Parent = character:FindFirstChild("Head") or character
        })
        
        local nameLabel = CreateInstance("TextLabel", {
            Name = "NameLabel",
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = targetPlayer.Name,
            TextColor3 = ESPTextColor,
            TextStrokeTransparency = 0.5,
            TextStrokeColor3 = Color3.new(0, 0, 0),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextScaled = false,
            Parent = billboard
        })
        
        local healthLabel = CreateInstance("TextLabel", {
            Name = "HealthLabel",
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = "HP: 100/100",
            TextColor3 = ESPTextColor,
            TextStrokeTransparency = 0.5,
            TextStrokeColor3 = Color3.new(0, 0, 0),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextScaled = false,
            Parent = billboard
        })
        
        local distanceLabel = CreateInstance("TextLabel", {
            Name = "DistanceLabel",
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 0, 0, 38),
            BackgroundTransparency = 1,
            Text = "Dist: 0 studs",
            TextColor3 = ESPTextColor,
            TextStrokeTransparency = 0.5,
            TextStrokeColor3 = Color3.new(0, 0, 0),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextScaled = false,
            Parent = billboard
        })
        
        ESPBoxes[targetPlayer] = {
            Highlight = highlight,
            Billboard = billboard,
            NameLabel = nameLabel,
            HealthLabel = healthLabel,
            DistanceLabel = distanceLabel,
            Character = character
        }
        
        local head = character:FindFirstChild("Head")
        if head then
            billboard.Adornee = head
        else
            billboard.Adornee = character
        end
    end

    local function cleanupESP(targetPlayer)
        if ESPBoxes[targetPlayer] then
            local espData = ESPBoxes[targetPlayer]
            if espData.Highlight then espData.Highlight:Destroy() end
            if espData.Billboard then espData.Billboard:Destroy() end
            ESPBoxes[targetPlayer] = nil
        end
    end

    local function updateESP()
        if not ESPEnabled then return end
        
        local camera = Workspace.CurrentCamera
        if not camera or not player.Character then return end
        
        local localHRP = player.Character:FindFirstChild("HumanoidRootPart")
        if not localHRP then return end
        
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
                if targetPlayer.Character then
                    local character = targetPlayer.Character
                    local humanoid = character:FindFirstChild("Humanoid")
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and humanoidRootPart then
                        local distance = (localHRP.Position - humanoidRootPart.Position).Magnitude
                        
                        if not ESPBoxes[targetPlayer] then
                            createESPBox(targetPlayer)
                        end
                        
                        local espData = ESPBoxes[targetPlayer]
                        if not espData then continue end
                        
                        local withinDistance = distance <= ESPMaxDistance
                        
                        if withinDistance then
                            if espData.Highlight then
                                espData.Highlight.Enabled = true
                                espData.Highlight.OutlineColor = ESPColor
                            end
                            
                            if espData.Billboard then
                                espData.Billboard.Enabled = true
                                espData.Billboard.MaxDistance = ESPMaxDistance
                            end
                            
                            if ESPShowName then
                                if espData.NameLabel then
                                    espData.NameLabel.Text = targetPlayer.Name
                                    espData.NameLabel.Visible = true
                                    espData.NameLabel.TextColor3 = ESPTextColor
                                end
                            elseif espData.NameLabel then
                                espData.NameLabel.Visible = false
                            end
                            
                            if ESPShowHealth then
                                if espData.HealthLabel then
                                    local health = math.floor(humanoid.Health)
                                    local maxHealth = humanoid.MaxHealth
                                    espData.HealthLabel.Text = "HP: " .. health .. "/" .. maxHealth
                                    espData.HealthLabel.Visible = true
                                    local healthPercent = health / maxHealth
                                    if healthPercent > 0.6 then
                                        espData.HealthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                                    elseif healthPercent > 0.3 then
                                        espData.HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                                    else
                                        espData.HealthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                                    end
                                end
                            elseif espData.HealthLabel then
                                espData.HealthLabel.Visible = false
                            end
                            
                            if ESPShowDistance then
                                if espData.DistanceLabel then
                                    espData.DistanceLabel.Text = "Dist: " .. math.floor(distance) .. " studs"
                                    espData.DistanceLabel.Visible = true
                                    local distancePercent = distance / ESPMaxDistance
                                    if distancePercent > 0.7 then
                                        espData.DistanceLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                                    elseif distancePercent > 0.4 then
                                        espData.DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 50)
                                    else
                                        espData.DistanceLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                                    end
                                end
                            elseif espData.DistanceLabel then
                                espData.DistanceLabel.Visible = false
                            end
                        else
                            if espData.Highlight then espData.Highlight.Enabled = false end
                            if espData.Billboard then espData.Billboard.Enabled = false end
                            if espData.NameLabel then espData.NameLabel.Visible = false end
                            if espData.HealthLabel then espData.HealthLabel.Visible = false end
                            if espData.DistanceLabel then espData.DistanceLabel.Visible = false end
                        end
                    end
                elseif ESPBoxes[targetPlayer] then
                    local espData = ESPBoxes[targetPlayer]
                    if espData.Highlight then espData.Highlight.Enabled = false end
                    if espData.Billboard then espData.Billboard.Enabled = false end
                    if espData.NameLabel then espData.NameLabel.Visible = false end
                    if espData.HealthLabel then espData.HealthLabel.Visible = false end
                    if espData.DistanceLabel then espData.DistanceLabel.Visible = false end
                end
            end
        end
    end

    local function startESP()
        if ESPConnection then ESPConnection:Disconnect() end
        
        for targetPlayer, _ in pairs(ESPBoxes) do
            cleanupESP(targetPlayer)
        end
        ESPBoxes = {}
        
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
                createESPBox(targetPlayer)
            end
        end
        
        Players.PlayerAdded:Connect(function(targetPlayer)
            if ESPEnabled then
                createESPBox(targetPlayer)
            end
        end)
        
        Players.PlayerRemoving:Connect(function(targetPlayer)
            cleanupESP(targetPlayer)
        end)
        
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
                targetPlayer.CharacterAdded:Connect(function(character)
                    if ESPEnabled then
                        task.wait(0.5)
                        cleanupESP(targetPlayer)
                        createESPBox(targetPlayer)
                    end
                end)
                
                targetPlayer.CharacterRemoving:Connect(function()
                    if ESPBoxes[targetPlayer] then
                        local espData = ESPBoxes[targetPlayer]
                        if espData.Highlight then espData.Highlight.Enabled = false end
                        if espData.Billboard then espData.Billboard.Enabled = false end
                    end
                end)
            end
        end
        
        ESPConnection = RunService.RenderStepped:Connect(updateESP)
    end

    local function stopESP()
        if ESPConnection then
            ESPConnection:Disconnect()
            ESPConnection = nil
        end
        
        for targetPlayer, _ in pairs(ESPBoxes) do
            cleanupESP(targetPlayer)
        end
        ESPBoxes = {}
    end

    --==================================================
    -- AIMBOT FUNCTIONS
    --==================================================
    local function createFOVCircle()
        if not Drawing then return end
        if FOVCircle then FOVCircle:Remove() end

        local success, circle = pcall(function()
            return Drawing.new("Circle")
        end)
        if not success then return end

        FOVCircle = circle
        FOVCircle.Visible = false
        FOVCircle.Thickness = 2
        FOVCircle.Color = FOVColor
        FOVCircle.Transparency = 0.5
        FOVCircle.Filled = false
        FOVCircle.NumSides = 64
        FOVCircle.Radius = AimbotFOV
    end

    local function updateFOVCircle()
        if not FOVCircle then return end
        local mousePos = UIS:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Radius = AimbotFOV
        FOVCircle.Color = FOVColor
        FOVCircle.Visible = AimbotEnabled
    end

    local function getTargetPart(character)
        if AimbotTargetPart == "Head" then
            return character:FindFirstChild("Head")
        elseif AimbotTargetPart == "Torso" then
            return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        elseif AimbotTargetPart == "HumanoidRootPart" then
            return character:FindFirstChild("HumanoidRootPart")
        end
        return character:FindFirstChild("Head")
    end

    local function getDistanceToPlayer(targetPlayer)
        if not player.Character or not targetPlayer.Character then return math.huge end
        local localHRP = player.Character:FindFirstChild("HumanoidRootPart")
        local targetPart = getTargetPart(targetPlayer.Character)
        if not localHRP or not targetPart then return math.huge end
        return (localHRP.Position - targetPart.Position).Magnitude
    end

    local function isValidTarget(targetPlayer)
        if not targetPlayer or not targetPlayer.Character then return false end
        local targetPart = getTargetPart(targetPlayer.Character)
        if not targetPart then return false end
        
        if IgnoreDeadTargets then
            local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health <= 0 then return false end
        end
        
        if DistanceLimiterEnabled then
            local distance = getDistanceToPlayer(targetPlayer)
            if distance > DistanceLimiterMax then return false end
        end
        
        return true
    end

    local function getClosestPlayer()
        local closestPlayer = nil
        local closestDistance = AimbotFOV
        local localCamera = Workspace.CurrentCamera
        
        if not localCamera or not player.Character then return nil end
        
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                if not isValidTarget(targetPlayer) then continue end
                local targetPart = getTargetPart(targetPlayer.Character)
                if targetPart then
                    local screenPoint, onScreen = localCamera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local mousePos = UIS:GetMouseLocation()
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = targetPlayer
                        end
                    end
                end
            end
        end
        
        return closestPlayer
    end

    local function getSmoothnessFactor()
        return 0.05 + (AimbotSmoothness / 100) * 0.9
    end

    local function moveMouseToPosition(targetPos)
        local mouse = UIS:GetMouseLocation()
        local delta = targetPos - mouse
        local smoothness = getSmoothnessFactor()
        delta = delta * smoothness
        if mousemoverel then
            mousemoverel(delta.X, delta.Y)
        end
    end

    local function aimAtLockedTarget()
        if not LockedTarget or not isValidTarget(LockedTarget) then
            LockedTarget = nil
            if AimbotMode == "Toggle" then AimbotActive = false end
            return
        end
        
        local targetPart = getTargetPart(LockedTarget.Character)
        if not targetPart then 
            LockedTarget = nil
            if AimbotMode == "Toggle" then AimbotActive = false end
            return 
        end
        
        local camera = Workspace.CurrentCamera
        if not camera then return end
        
        local targetPos3D = targetPart.Position
        
        if PredictionEnabled and PredictionStrength > 0 then
            local humanoid = LockedTarget.Character:FindFirstChild("Humanoid")
            if humanoid then
                local velocity = targetPart.AssemblyLinearVelocity or (humanoid.RootPart and humanoid.RootPart.AssemblyLinearVelocity)
                if velocity then
                    local predictionMultiplier = PredictionStrength / 100 * 0.5
                    targetPos3D = targetPos3D + (velocity * predictionMultiplier)
                end
            end
        end
        
        local targetScreenPos, onScreen = camera:WorldToViewportPoint(targetPos3D)
        if onScreen then
            local targetPos2D = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
            moveMouseToPosition(targetPos2D)
        end
    end

    local function toggleAimbotKey()
        if not AimbotEnabled then return end
        if AimbotMode ~= "Toggle" then return end
        
        AimbotActive = not AimbotActive
        
        if AimbotActive then
            LockedTarget = getClosestPlayer()
            if not LockedTarget then
                AimbotActive = false
                print("[aim] No valid target found")
            else
                print("[aim] Locked onto:", LockedTarget.Name)
            end
        else
            LockedTarget = nil
            print("[aim] Aimbot disabled")
        end
    end

    local function startAimbot()
        if AimbotConnection then AimbotConnection:Disconnect() end
        createFOVCircle()
        
        AimbotConnection = RunService.RenderStepped:Connect(function()
            updateFOVCircle()
            local shouldAim = false
            
            if AimbotEnabled then
                if AimbotMode == "Toggle" then
                    shouldAim = AimbotActive
                elseif AimbotMode == "Hold" then
                    shouldAim = UIS:IsKeyDown(AimbotKey)
                end
            end
            
            if AimbotMode == "Hold" and shouldAim and not LockedTarget then
                LockedTarget = getClosestPlayer()
            elseif AimbotMode == "Hold" and not shouldAim then
                LockedTarget = nil
            end
            
            if LockedTarget and not isValidTarget(LockedTarget) then
                LockedTarget = nil
                if AimbotMode == "Toggle" then AimbotActive = false end
            end
            
            if shouldAim and LockedTarget then
                aimAtLockedTarget()
            end
            
            if AimbotMode == "Toggle" and AimbotActive and not LockedTarget then
                LockedTarget = getClosestPlayer()
                if not LockedTarget then
                    AimbotActive = false
                end
            end
        end)
    end

    local function stopAimbot()
        if AimbotConnection then
            AimbotConnection:Disconnect()
            AimbotConnection = nil
        end
        
        if FOVCircle then
            FOVCircle:Remove()
            FOVCircle = nil
        end
        
        AimbotActive = false
        LockedTarget = nil
    end

    -- Aimbot key listener
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == AimbotKey then
                toggleAimbotKey()
            end
        end
    end)

    --==================================================
    -- BUILD GUI CONTENT (NO TELEPORT TAB)
    --==================================================
    do
        -- Only 4 tabs now (removed teleport)
        RegisterTab("player", 1)
        RegisterTab("aim", 2)
        RegisterTab("visuals", 3)
        RegisterTab("settings", 4)
        
        -- PLAYER TAB - NO ENABLE TOGGLES, ALL SLIDERS WORK IMMEDIATELY
        local playerSection = UI:Section("player", "movement")
        UI:Slider(playerSection, "walkspeed", 0, 200, 16, "walkspeed_slider", "studs/s")
        UI:Slider(playerSection, "jump power", 0, 200, 50, "jumppower_slider", "power")
        UI:Toggle(playerSection, "bunny hop", false, "bunny_hop_toggle")
        UI:Slider(playerSection, "bunny hop force", 0, 100, 100, "bunny_hop_force_slider", "force")
        UI:Toggle(playerSection, "noclip", false, "noclip_toggle")
        UI:Slider(playerSection, "spin speed", 0, 200, 0, "spin_speed_slider", "speed")
        
        local advancedSection = UI:Section("player", "advanced")
        UI:Slider(advancedSection, "Camera FOV", 0, 120, 80, "Fieldofviewcamera", "degree")

        -- AIM TAB
        local aimSection = UI:Section("aim", "aimbot")
        UI:Toggle(aimSection, "aimbot enabled", false, "aimbot_toggle")
        UI:Dropdown(aimSection, "aimbot mode", {"Toggle", "Hold"}, "Toggle", "aimbot_mode_dropdown")
        UI:Dropdown(aimSection, "target part", {"Head", "Torso", "HumanoidRootPart"}, "Head", "aimbot_target_dropdown")
        UI:Keybind(aimSection, "aimbot key", "Q", "aimbot_key_keybind")
        UI:Slider(aimSection, "aimbot fov", 50, 500, 200, "aimbot_fov_slider", "fov")
        UI:Slider(aimSection, "aimbot smoothness", 0, 100, 50, "aimbot_smoothness_slider", "%")
        UI:Toggle(aimSection, "distance limiter", false, "distance_limiter_toggle")
        UI:Slider(aimSection, "max distance", 0, 1000, 1000, "max_distance_slider", "studs")
        UI:Toggle(aimSection, "prediction", false, "prediction_toggle")
        UI:Slider(aimSection, "prediction strength", 0, 100, 0, "prediction_strength_slider", "%")
        UI:Toggle(aimSection, "ignore dead targets", true, "ignore_dead_toggle")
        UI:ColorPicker(aimSection, "fov circle color", FOVColor, "fov_color_picker")
        
        -- VISUALS TAB
        local visualsSection = UI:Section("visuals", "player esp")
        UI:Toggle(visualsSection, "esp enabled", false, "esp_toggle")
        UI:Toggle(visualsSection, "show name", true, "esp_show_name_toggle")
        UI:Toggle(visualsSection, "show health", true, "esp_show_health_toggle")
        UI:Toggle(visualsSection, "show distance", true, "esp_show_distance_toggle")
        UI:Slider(visualsSection, "esp max distance", 0, 2000, 2000, "esp_max_distance_slider", "studs")
        UI:ColorPicker(visualsSection, "esp box color", ESPColor, "esp_color_picker")
        UI:ColorPicker(visualsSection, "esp text color", ESPTextColor, "esp_text_color_picker")
        
        -- SETTINGS TAB
        local settingsSection = UI:Section("settings", "menu controls")
        UI:Button(settingsSection, "destroy menu", "destroy_menu_button")
        UI:Keybind(settingsSection, "toggle menu key", "RightShift", "menu_toggle_keybind")
        UI:ColorPicker(settingsSection, "accent color", Theme.Accent, "theme_accent")
        UI:ColorPicker(settingsSection, "menu color", C.MainBG, "menu_color_picker")
    end

    SwitchTab("player")

    --==================================================
    -- HOOK IMPLEMENTATIONS - FIXED FOR MOVEMENT
    --==================================================
    -- Player Hooks - ALL SLIDERS WORK IMMEDIATELY
   Hooks.player.walkspeed_slider = function(value)
    -- Store target CFrame walk speed
    WS_Target = value
    
    print("[player] CFrame WalkSpeed:", value)
    
    -- Stop any existing CFrame walk loop if value is 0 or less
    if value <= 0 then
        if Hooks.player.cframe_walk_loop then
            Hooks.player.cframe_walk_loop:Disconnect()
            Hooks.player.cframe_walk_loop = nil
        end
        return
    end
    
    -- Stop existing CFrame walk loop
    if Hooks.player.cframe_walk_loop then
        Hooks.player.cframe_walk_loop:Disconnect()
    end
    
    -- Start CFrame movement loop
    Hooks.player.cframe_walk_loop = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart and humanoid.MoveDirection.Magnitude > 0 then
                local camera = workspace.CurrentCamera
                if camera then
                    -- Get horizontal camera direction
                    local lookVector = camera.CFrame.LookVector
                    lookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
                    
                    -- Calculate movement based on input direction relative to camera
                    local moveDirection = humanoid.MoveDirection
                    
                    -- Normalize movement to camera orientation
                    local forward = lookVector
                    local right = camera.CFrame.RightVector
                    right = Vector3.new(right.X, 0, right.Z).Unit
                    
                    local moveX = moveDirection:Dot(right)
                    local moveZ = moveDirection:Dot(forward)
                    
                    local movement = (right * moveX + forward * moveZ).Unit
                    
                    -- Apply CFrame movement (horizontal only)
                    local distance = value * deltaTime
                    
                    -- Get current position and apply movement
                    local currentPos = rootPart.Position
                    local newPos = currentPos + (movement * distance)
                    
                    -- Keep original Y position for movement (allows jumping/falling)
                    rootPart.CFrame = CFrame.new(newPos) * (rootPart.CFrame - rootPart.CFrame.Position)
                end
            end
        end
    end)
end

    Hooks.player.jumppower_slider = function(value)
        JP_Target = value
        -- Immediately apply to character if exists
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = value
        end
        print("[player] JumpPower:", value)
    end

    Hooks.player.Fieldofviewcamera = function(value)
        JP_Target = value
    
        print("[player] FieldOfView:", value)
    
    -- Stop existing loop if value is 0 or less
        if value <= 0 then
            if Hooks.player.fov_loop then
                Hooks.player.fov_loop:Disconnect()
                Hooks.player.fov_loop = nil
            end
            return
        end
    
    -- Stop existing loop
        if Hooks.player.fov_loop then
            Hooks.player.fov_loop:Disconnect()
        end
    
    -- Apply immediately
        local camera = workspace.CurrentCamera
        if camera then
            camera.FieldOfView = value
        end
    
    -- Start constant checking loop using RenderStepped for visual consistency
        Hooks.player.fov_loop = game:GetService("RunService").RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            if camera and camera.FieldOfView ~= value then
                camera.FieldOfView = value
         end
     end)
    end
   

    Hooks.player.bunny_hop_toggle = function(state)
        BunnyHopEnabled = state
        if state then
            startBunnyHop()
        else
            stopBunnyHop()
        end
        print("[player] BunnyHop:", state)
    end

    Hooks.player.bunny_hop_force_slider = function(value)
        BunnyHopForce = value
        print("[player] BunnyHop force:", value)
    end

    Hooks.player.noclip_toggle = function(state)
        NoclipEnabled = state
        if state then
            startNoclip()
        else
            stopNoclip()
        end
        print("[player] Noclip:", state)
    end

    Hooks.player.spin_speed_slider = function(value)
        SpinSpeed = value
        updateSpin() -- This will handle enabling/disabling based on value
        print("[player] Spin speed:", value)
    end

    -- Aim Hooks
    Hooks.aim.aimbot_toggle = function(state)
        AimbotEnabled = state
        if state then
            startAimbot()
        else
            stopAimbot()
        end
        print("[aim] Aimbot:", state)
    end

    Hooks.aim.aimbot_mode_dropdown = function(mode)
        AimbotMode = mode
        AimbotActive = false
        LockedTarget = nil
        print("[aim] Aimbot mode:", mode)
    end

    Hooks.aim.aimbot_target_dropdown = function(part)
        AimbotTargetPart = part
        LockedTarget = nil
        print("[aim] Target part:", part)
    end

    Hooks.aim.aimbot_key_keybind = function(key)
        AimbotKey = Enum.KeyCode[key]
        print("[aim] Aimbot key:", key)
    end

    Hooks.aim.aimbot_fov_slider = function(value)
        AimbotFOV = value
        if FOVCircle then FOVCircle.Radius = value end
        print("[aim] FOV:", value)
    end

    Hooks.aim.aimbot_smoothness_slider = function(value)
        AimbotSmoothness = value
        print("[aim] Smoothness:", value)
    end

    Hooks.aim.distance_limiter_toggle = function(state)
        DistanceLimiterEnabled = state
        LockedTarget = nil
        print("[aim] Distance limiter:", state)
    end

    Hooks.aim.max_distance_slider = function(value)
        DistanceLimiterMax = value
        LockedTarget = nil
        print("[aim] Max distance:", value)
    end

    Hooks.aim.prediction_toggle = function(state)
        PredictionEnabled = state
        print("[aim] Prediction:", state)
    end

    Hooks.aim.prediction_strength_slider = function(value)
        PredictionStrength = value
        print("[aim] Prediction strength:", value)
    end

    Hooks.aim.ignore_dead_toggle = function(state)
        IgnoreDeadTargets = state
        LockedTarget = nil
        print("[aim] Ignore dead:", state)
    end

    Hooks.aim.fov_color_picker = function(color)
        FOVColor = color
        if FOVCircle then
            FOVCircle.Color = color
        end
        print("[aim] FOV color:", color)
    end

    -- Visuals Hooks
    Hooks.visuals.esp_toggle = function(state)
        ESPEnabled = state
        if state then
            for targetPlayer, _ in pairs(ESPBoxes) do
                cleanupESP(targetPlayer)
            end
            ESPBoxes = {}
            startESP()
        else
            stopESP()
        end
        print("[visuals] ESP:", state)
    end

    Hooks.visuals.esp_show_name_toggle = function(state)
        ESPShowName = state
        for _, espData in pairs(ESPBoxes) do
            if espData and espData.NameLabel then
                espData.NameLabel.Visible = state
            end
        end
        print("[visuals] Show name:", state)
    end

    Hooks.visuals.esp_show_health_toggle = function(state)
        ESPShowHealth = state
        for _, espData in pairs(ESPBoxes) do
            if espData and espData.HealthLabel then
                espData.HealthLabel.Visible = state
            end
        end
        print("[visuals] Show health:", state)
    end

    Hooks.visuals.esp_show_distance_toggle = function(state)
        ESPShowDistance = state
        for _, espData in pairs(ESPBoxes) do
            if espData and espData.DistanceLabel then
                espData.DistanceLabel.Visible = state
            end
        end
        print("[visuals] Show distance:", state)
    end

    Hooks.visuals.esp_max_distance_slider = function(value)
        ESPMaxDistance = value
        for _, espData in pairs(ESPBoxes) do
            if espData and espData.Billboard then
                espData.Billboard.MaxDistance = value
            end
        end
        print("[visuals] ESP max distance:", value)
    end

    Hooks.visuals.esp_color_picker = function(color)
        ESPColor = color
        for _, espData in pairs(ESPBoxes) do
            if espData and espData.Highlight then
                espData.Highlight.OutlineColor = color
            end
        end
        print("[visuals] ESP color:", color)
    end

    Hooks.visuals.esp_text_color_picker = function(color)
        ESPTextColor = color
        for _, espData in pairs(ESPBoxes) do
            if espData then
                if espData.NameLabel then espData.NameLabel.TextColor3 = color end
                if espData.HealthLabel then espData.HealthLabel.TextColor3 = color end
                if espData.DistanceLabel then espData.DistanceLabel.TextColor3 = color end
            end
        end
        print("[visuals] ESP text color:", color)
    end

    -- Settings Hooks
    Hooks.settings.destroy_menu_button = function()
        if ScreenGui and ScreenGui.Parent then
            ScreenGui:Destroy()
        end
        stopESP()
        stopAimbot()
        stopBunnyHop()
        stopNoclip()
        if SpinConnection then SpinConnection:Disconnect() end
        if MovementConnection then MovementConnection:Disconnect() end
        if ESPTextGui then ESPTextGui:Destroy() end
        print("[settings] Menu destroyed")
    end

    Hooks.settings.menu_toggle_keybind = function(key)
        menuToggleKey = Enum.KeyCode[key]
        print("[settings] Menu toggle key:", key)
    end

    Hooks.settings.theme_accent = function(c3)
        Theme:Set("Accent", c3)
        Theme:Set("Accent2", Darken(c3, 0.75))
        print("[settings] Accent color changed")
    end

    Hooks.settings.menu_color_picker = function(c3)
        C.MainBG = c3
        Main.BackgroundColor3 = c3
        print("[settings] Menu color changed")
    end

    -- Global Hooks
    Hooks.global.tab_changed = function(tabName)
        print("[global] Tab changed to:", tabName)
    end

    --==================================================
    -- MENU TOGGLE
    --==================================================
    local UIVisible = true

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == menuToggleKey then
                UIVisible = not UIVisible
                Main.Visible = UIVisible
                print("Menu toggled:", UIVisible)
            end
        end
    end)

    print("HELIO CLIENT PAID - ALL MOVEMENT CONTROLS WORK IMMEDIATELY")
    print("- Walkspeed slider works immediately")
    print("- Jump Power slider works immediately")  
    print("- Bunny Hop works when toggled on")
    print("- Spin works when speed > 0")
    print("- Teleport tab removed as requested")
end