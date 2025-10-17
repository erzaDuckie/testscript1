-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Variables for drag control
local dragging
local dragInput
local dragStart
local startPos

-- Main window
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 350)
Frame.Position = UDim2.new(0.35, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

-- Title bar (for dragging)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Frame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

-- Centered title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0.1, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "RN TEAM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = TitleBar

-- Minimize button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -30, 0, 0)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20
MinimizeButton.Parent = TitleBar

-- Container for tabs
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -10, 0, 35)
TabContainer.Position = UDim2.new(0, 5, 0, 35)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = Frame
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 6)

-- Horizontal layout for tabs
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 2)
TabLayout.Parent = TabContainer

-- Main container for content WITH SMOOTH SCROLLING
local MainContentContainer = Instance.new("ScrollingFrame")
MainContentContainer.Size = UDim2.new(1, -10, 1, -110)
MainContentContainer.Position = UDim2.new(0, 5, 0, 75)
MainContentContainer.BackgroundTransparency = 1
MainContentContainer.BorderSizePixel = 0
MainContentContainer.ScrollBarThickness = 0
MainContentContainer.ScrollBarImageTransparency = 1
MainContentContainer.ClipsDescendants = true
MainContentContainer.Parent = Frame

-- Fixed text at bottom (credits)
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 25)
Credits.Position = UDim2.new(0, 0, 1, -25)
Credits.BackgroundTransparency = 1
Credits.Text = "YouTube: RN_TEAM"
Credits.TextColor3 = Color3.fromRGB(200, 200, 200)
Credits.Font = Enum.Font.SourceSansBold
Credits.TextSize = 14
Credits.Parent = Frame

-- Background frame to allow dragging from entire interface
local BackgroundDrag = Instance.new("Frame")
BackgroundDrag.Size = UDim2.new(1, 0, 1, 0)
BackgroundDrag.BackgroundTransparency = 1
BackgroundDrag.BorderSizePixel = 0
BackgroundDrag.ZIndex = 0
BackgroundDrag.Parent = Frame

-- Tab System
local tabs = {}
local currentTab = nil

local function createTab(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.24, 0, 0.8, 0)
    tabButton.Position = UDim2.new(0, 0, 0.1, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.TextSize = 12
    tabButton.Parent = TabContainer
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 4)
    
    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = MainContentContainer
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Padding = UDim.new(0, 8)
    tabListLayout.Parent = tabContent
    
    local tab = {
        button = tabButton,
        content = tabContent,
        layout = tabListLayout
    }
    
    tabs[tabName] = tab
    
    tabButton.MouseButton1Click:Connect(function()
        -- Hide all tabs
        for name, tabData in pairs(tabs) do
            tabData.content.Visible = false
            tabData.button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            tabData.button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        
        -- Show clicked tab
        tab.content.Visible = true
        tab.button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        tab.button.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        currentTab = tabName
        adjustWindowHeight()
    end)
    
    return tab
end

-- Function to automatically adjust window height
local function adjustWindowHeight()
    local minHeight = 350
    local maxHeight = 450
    
    if currentTab and tabs[currentTab] then
        local tabContent = tabs[currentTab].content
        local contentHeight = tabs[currentTab].layout.AbsoluteContentSize.Y + 100
        
        local newHeight = math.clamp(contentHeight, minHeight, maxHeight)
        
        local tween = TweenService:Create(
            Frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 280, 0, newHeight)}
        )
        tween:Play()
        
        MainContentContainer.CanvasSize = UDim2.new(0, 0, 0, tabs[currentTab].layout.AbsoluteContentSize.Y)
    end
end

-- Function to drag window
local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

-- Connect drag events
local function connectDragEvents(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
end

connectDragEvents(TitleBar)
connectDragEvents(BackgroundDrag)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Function to minimize/maximize
local isMinimized = false
local originalSize = Frame.Size
local minimizedSize = UDim2.new(0, 280, 0, 30)

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        local tween = TweenService:Create(
            Frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = minimizedSize}
        )
        tween:Play()
        TabContainer.Visible = false
        MainContentContainer.Visible = false
        Credits.Visible = false
        BackgroundDrag.Visible = false
        MinimizeButton.Text = "+"
    else
        local tween = TweenService:Create(
            Frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = originalSize}
        )
        tween:Play()
        TabContainer.Visible = true
        MainContentContainer.Visible = true
        Credits.Visible = true
        BackgroundDrag.Visible = true
        MinimizeButton.Text = "-"
    end
end)

-- Bar style button
local function CreateButton(text, callback, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 16
    Button.ZIndex = 1
    Button.Parent = parent or MainContentContainer
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- Toggle (checkbox) FIXED
local function CreateToggle(text, callback, parent)
    local ToggleContainer = Instance.new("Frame")
    ToggleContainer.Size = UDim2.new(1, 0, 0, 30)
    ToggleContainer.BackgroundTransparency = 1
    ToggleContainer.ZIndex = 1
    ToggleContainer.Parent = parent or MainContentContainer

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1, 0, 1, 0)
    Toggle.BackgroundTransparency = 1
    Toggle.Text = text
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.Font = Enum.Font.SourceSansBold
    Toggle.TextSize = 16
    Toggle.TextXAlignment = Enum.TextXAlignment.Left
    Toggle.ZIndex = 1
    Toggle.Parent = ToggleContainer

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 20, 0, 20)
    Box.Position = UDim2.new(1, -25, 0.5, -10)
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Box.ZIndex = 1
    Box.Parent = ToggleContainer
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

    -- Initial state
    local isActive = false
    
    local function updateToggle()
        if isActive then
            Box.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
    end
    
    Toggle.MouseButton1Click:Connect(function()
        isActive = not isActive
        updateToggle()
        callback(isActive)
    end)
    
    -- Initialize
    updateToggle()
    
    return Toggle, Box, function(state) 
        isActive = state 
        updateToggle()
    end
end

-- ===== MAIN TAB =====
local function setupMainTab()
    -- Auto Hat Toggle FIXED
    local AutoHatToggle, AutoHatBox, setAutoHatState = CreateToggle("Auto Hat", function(isActive)
        _G.autoHat = isActive
        
        if isActive then
            print("🟢 Auto Hat ACTIVATED")
            task.spawn(function()
                while _G.autoHat do
                    pcall(function()
                        local args = {400001}
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RerollOrnament"):InvokeServer(unpack(args))
                    end)
                    task.wait(0.2)
                end
            end)
        else
            print("🔴 Auto Hat DEACTIVATED")
        end
    end, tabs["Main"].content)

    -- Auto Backpack Toggle FIXED
    local AutoBackpackToggle, AutoBackpackBox, setAutoBackpackState = CreateToggle("Auto Backpack", function(isActive)
        _G.autoBackpack = isActive
        
        if isActive then
            print("🟢 Auto Backpack ACTIVATED")
            task.spawn(function()
                while _G.autoBackpack do
                    pcall(function()
                        local args = {400002}
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RerollOrnament"):InvokeServer(unpack(args))
                    end)
                    task.wait(0.2)
                end
            end)
        else
            print("🔴 Auto Backpack DEACTIVATED")
        end
    end, tabs["Main"].content)
end

-- ===== FARM TAB =====
local function setupFarmTab()
    -- AUTO FARM SYSTEM (NPC Gatherer) FIXED
    local autoFarmSystem = {
        active = false,
        connection = nil,
        
        SETTINGS = {
            NPC_FOLDER_NAMES = {"Enemies"},
            MAX_DISTANCE = 900,
            PULL_DISTANCE = 30,
            LOOP_DELAY = 0.2,
            BUFF_COOLDOWN = 60
        },
        
        lastBuffTime = 0,
        npcFolder = nil,
        
        findNPCDirectory = function(self)
            for _, folderName in ipairs(self.SETTINGS.NPC_FOLDER_NAMES) do
                local folder = workspace:FindFirstChild(folderName)
                if folder then
                    return folder
                end
            end
            return nil
        end,
        
        applyBuffs = function(self)
            if time() - self.lastBuffTime < self.SETTINGS.BUFF_COOLDOWN then
                return
            end
            
            print("[BUFF] Applying buffs...")
            self.lastBuffTime = time()
            
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 90
                    delay(10, function()
                        if humanoid then
                            humanoid.WalkSpeed = 90
                        end
                    end)
                end
            end
        end,
        
        pullNPC = function(self, npcModel, humanoidRootPart)
            if not npcModel or not npcModel:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
                return false
            end
            
            local npcHRP = npcModel.HumanoidRootPart
            local distance = (humanoidRootPart.Position - npcHRP.Position).Magnitude
            
            if distance > self.SETTINGS.PULL_DISTANCE and distance < self.SETTINGS.MAX_DISTANCE then
                local direction = (humanoidRootPart.Position - npcHRP.Position).Unit
                npcHRP.CFrame = CFrame.new(
                    humanoidRootPart.Position + direction * 5,
                    humanoidRootPart.Position
                )
                return true
            end
            return false
        end,
        
        mainLoop = function(self)
            if not self.active then return end
            
            local character = LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if not character or not humanoidRootPart then
                return
            end
            
            self:applyBuffs()
            
            if not self.npcFolder then
                self.npcFolder = self:findNPCDirectory()
                if not self.npcFolder then
                    warn("No NPC folders found!")
                    return
                end
            end
            
            local gathered = 0
            for _, npc in ipairs(self.npcFolder:GetChildren()) do
                if not self.active then break end
                
                if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                    if self:pullNPC(npc, humanoidRootPart) then
                        gathered += 1
                        wait(0.3)
                    end
                end
            end
            
            if gathered > 0 then
                print("[NPC GATHER] " .. gathered .. " NPCs gathered!")
            end
        end,
        
        start = function(self)
            if self.active then return end
            
            self.active = true
            self.npcFolder = nil
            self.lastBuffTime = 0
            
            print("🟢 Auto Farm STARTED!")
            
            self.connection = RunService.Heartbeat:Connect(function()
                if not self.active then return end
                pcall(function() self:mainLoop() end)
                wait(self.SETTINGS.LOOP_DELAY)
            end)
        end,
        
        stop = function(self)
            if not self.active then return end
            
            self.active = false
            
            if self.connection then
                self.connection:Disconnect()
                self.connection = nil
            end
            
            print("🔴 Auto Farm STOPPED!")
        end
    }

    -- Auto Farm Toggle FIXED
    local AutoFarmToggle, AutoFarmBox, setAutoFarmState = CreateToggle("Auto Farm NPC", function(isActive)
        if isActive then
            autoFarmSystem:start()
        else
            autoFarmSystem:stop()
        end
    end, tabs["Farm"].content)

    -- Auto Click Toggle FIXED
    local AutoClickToggle, AutoClickBox, setAutoClickState = CreateToggle("Auto Click", function(isActive)
        _G.autoClick = isActive
        
        if isActive then
            print("🟢 Auto Click ACTIVATED")
            task.spawn(function()
                while _G.autoClick do
                    pcall(function()
                        local args = {
                            {
                                attackEnemyGUID = "3b887f80-7ae5-42ad-8915-73f94f2c87e1"
                            }
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlayerClickAttackSkill"):FireServer(unpack(args))
                    end)
                    wait(-999999999999)
                end
            end)
        else
            print("🔴 Auto Click DEACTIVATED")
        end
    end, tabs["Farm"].content)

    local potion1 = CreateButton("Potion Luck V1", function()
        pcall(function()
            local args = {
                {
                    id = 10047,
                    count = 5
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PotionMerge"):InvokeServer(unpack(args))
            print("✅ Potion Luck used!")
        end)
    end, tabs["Farm"].content)

    local potion2 = CreateButton("Potion Damage V1", function()
        pcall(function()
            local args = {
                {
                    id = 10048,
                    count = 5
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PotionMerge"):InvokeServer(unpack(args))
            print("✅ Potion Damage used!")
        end)
    end, tabs["Farm"].content)

    local potion3 = CreateButton("Potion Gold V1", function()
        pcall(function()
            local args = {
                {
                    id = 10049,
                    count = 5
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PotionMerge"):InvokeServer(unpack(args))
            print("✅ Potion Gold used!")
        end)
    end, tabs["Farm"].content)

    local potion4 = CreateButton("Potion Luck V2", function()
        pcall(function()
            local args = {
                {
                    id = 10050,
                    count = 5
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PotionMerge"):InvokeServer(unpack(args))
            print("✅ Potion Luck used!")
        end)
    end, tabs["Farm"].content)

    local potion5 = CreateButton("Potion Damage V2", function()
        pcall(function()
            local args = {
                {
                    id = 10051,
                    count = 5
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PotionMerge"):InvokeServer(unpack(args))
            print("✅ Potion Damage used!")
        end)
    end, tabs["Farm"].content)

    local potion6 = CreateButton("Potion Gold V2", function()
        pcall(function()
            local args = {
                {
                    id = 10052,
                    count = 5
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PotionMerge"):InvokeServer(unpack(args))
            print("✅ Potion Gold used!")
        end)
    end, tabs["Farm"].content)
end

-- ===== AUTO TAB =====
local function setupAutoTab()
    -- Auto Raid World 3 Toggle FIXED
    local AutoRaidW3Toggle, AutoRaidW3Box, setAutoRaidW3State = CreateToggle("Auto Raid World 3", function(isActive)
        _G.autoRaidW3 = isActive
        
        if isActive then
            print("🟢 Auto Raid W3 ACTIVATED")
            task.spawn(function()
                while _G.autoRaidW3 do
                    pcall(function()
                        local args = {[1] = 1000001}
                        game:GetService("ReplicatedStorage").Remotes.EnterCityRaidMap:FireServer(unpack(args))
                    end)
                    task.wait(80.0)
                end
            end)
        else
            print("🔴 Auto Raid W3 DEACTIVATED")
        end
    end, tabs["Auto"].content)

    -- Auto Raid World 7 Toggle FIXED
    local AutoRaidW7Toggle, AutoRaidW7Box, setAutoRaidW7State = CreateToggle("Auto Raid World 7", function(isActive)
        _G.autoRaidW7 = isActive
        
        if isActive then
            print("🟢 Auto Raid W7 ACTIVATED")
            task.spawn(function()
                while _G.autoRaidW7 do
                    pcall(function()
                        local args = {[1] = 1000002}
                        game:GetService("ReplicatedStorage").Remotes.EnterCityRaidMap:FireServer(unpack(args))
                    end)
                    task.wait(80.0)
                end
            end)
        else
            print("🔴 Auto Raid W7 DEACTIVATED")
        end
    end, tabs["Auto"].content)
    
local collect1 = CreateButton("auto collect", function()
    if autoCollectActive then
        -- Turn off
        autoCollectActive = false
        if autoCollectConnection then
            autoCollectConnection:Disconnect()
            autoCollectConnection = nil
        end
        print("🔴 Auto Collect deactivated!")
    else
        -- Turn on
        autoCollectActive = true
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Workspace = game:GetService("Workspace")
        
        if not LocalPlayer.Character then
            LocalPlayer.CharacterAdded:Wait()
        end
        
        local Character = LocalPlayer.Character
        local RootPart = Character:WaitForChild("HumanoidRootPart")
        local Golds = Workspace:WaitForChild("Golds")

        autoCollectConnection = RunService.Heartbeat:Connect(function()
            if not autoCollectActive then return end
            
            for _, part in ipairs(Golds:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CFrame = RootPart.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end)
        print("🟢 Auto Collect activated!")
    end
end, tabs["Auto"].content)

local autoraid0 = CreateButton("auto raid beta", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/erzaDuckie/testscript1/refs/heads/main/autoraid.js"))()
end, tabs["Auto"].content)
end

-- ===== PLAYER TAB =====
local function setupPlayerTab()
    -- Caixa de Walk Speed
    local WalkContainer = Instance.new("Frame")
    WalkContainer.Size = UDim2.new(1, 0, 0, 30)
    WalkContainer.BackgroundTransparency = 1
    WalkContainer.ZIndex = 1
    WalkContainer.Parent = tabs["Player"].content

    local WalkLabel = Instance.new("TextLabel")
    WalkLabel.Size = UDim2.new(0.6, 0, 1, 0)
    WalkLabel.BackgroundTransparency = 1
    WalkLabel.Text = "Speed"
    WalkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    WalkLabel.Font = Enum.Font.SourceSansBold
    WalkLabel.TextSize = 16
    WalkLabel.TextXAlignment = Enum.TextXAlignment.Left
    WalkLabel.ZIndex = 1
    WalkLabel.Parent = WalkContainer

    local WalkBox = Instance.new("TextBox")
    WalkBox.Size = UDim2.new(0.35, 0, 1, 0)
    WalkBox.Position = UDim2.new(0.62, 0, 0, 0)
    WalkBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    WalkBox.BorderSizePixel = 0
    WalkBox.Text = "16"
    WalkBox.PlaceholderText = "0-200"
    WalkBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    WalkBox.Font = Enum.Font.SourceSansBold
    WalkBox.TextSize = 14
    WalkBox.ZIndex = 1
    WalkBox.Parent = WalkContainer
    Instance.new("UICorner", WalkBox).CornerRadius = UDim.new(0, 6)

    -- Efeitos visuais na WalkBox
    WalkBox.Focused:Connect(function()
        local tween = TweenService:Create(
            WalkBox,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}
        )
        tween:Play()
    end)

    WalkBox.FocusLost:Connect(function()
        local tween = TweenService:Create(
            WalkBox,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}
        )
        tween:Play()
        
        local val = tonumber(WalkBox.Text)
        if val then
            if val >= 0 and val <= 200 then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.WalkSpeed = val
                    print("🟢 Walk Speed: " .. val)
                end
            else
                WalkBox.Text = "16"
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.WalkSpeed = 16
                end
            end
        else
            WalkBox.Text = "16"
        end
    end)

    -- Sistema de Hitbox Size (CORRIGIDO - igual ao seu exemplo)
    local HitboxContainer = Instance.new("Frame")
    HitboxContainer.Size = UDim2.new(1, 0, 0, 30)
    HitboxContainer.BackgroundTransparency = 1
    HitboxContainer.ZIndex = 1
    HitboxContainer.Parent = tabs["Player"].content

    local HitboxLabel = Instance.new("TextLabel")
    HitboxLabel.Size = UDim2.new(0.6, 0, 1, 0)
    HitboxLabel.BackgroundTransparency = 1
    HitboxLabel.Text = "Kill Aura"
    HitboxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HitboxLabel.Font = Enum.Font.SourceSansBold
    HitboxLabel.TextSize = 16
    HitboxLabel.TextXAlignment = Enum.TextXAlignment.Left
    HitboxLabel.ZIndex = 1
    HitboxLabel.Parent = HitboxContainer

    local HitboxBox = Instance.new("TextBox")
    HitboxBox.Size = UDim2.new(0.35, 0, 1, 0)
    HitboxBox.Position = UDim2.new(0.62, 0, 0, 0)
    HitboxBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    HitboxBox.BorderSizePixel = 0
    HitboxBox.Text = "60"
    HitboxBox.PlaceholderText = "0-3000"
    HitboxBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    HitboxBox.Font = Enum.Font.SourceSansBold
    HitboxBox.TextSize = 14
    HitboxBox.ZIndex = 1
    HitboxBox.Parent = HitboxContainer
    Instance.new("UICorner", HitboxBox).CornerRadius = UDim.new(0, 6)

    -- Efeitos visuais na HitboxBox
    HitboxBox.Focused:Connect(function()
        local tween = TweenService:Create(
            HitboxBox,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}
        )
        tween:Play()
    end)

    HitboxBox.FocusLost:Connect(function()
        local tween = TweenService:Create(
            HitboxBox,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}
        )
        tween:Play()
        
        local val = tonumber(HitboxBox.Text)
        if val then
            if val == 0 then
                print("🔴 Kill Aura DESATIVADO")
                _G.HitboxEnabled = false
            elseif val > 0 and val <= 3000 then
                _G.HitboxSize = val
                _G.HitboxEnabled = true
                print("🟢 Kill Aura: " .. val)
            else
                HitboxBox.Text = "60"
                _G.HitboxSize = 60
            end
        else
            HitboxBox.Text = "0"
            _G.HitboxSize = 60
        end
    end)

    -- Configurações do sistema de Hitbox
    _G.HitboxSize = 60
    _G.HitboxEnabled = true
    _G.NPCFolder = workspace:FindFirstChild("Enemys") -- Pasta onde os NPCs estão

    -- Função para modificar a HumanoidRootPart dos NPCs (apenas tamanho)
    local function modifyNPCs()
        if _G.NPCFolder then
            for _, npc in pairs(_G.NPCFolder:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        if _G.HitboxEnabled then
                            npc.HumanoidRootPart.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                            npc.HumanoidRootPart.CanCollide = false
                        else
                            -- Restaura o tamanho original quando desativado
                            npc.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                            npc.HumanoidRootPart.CanCollide = true
                        end
                    end)
                end
            end
        end
    end

    -- Loop para modificar os NPCs continuamente
    game:GetService('RunService').RenderStepped:Connect(function()
        pcall(function()
            modifyNPCs()
        end)
    end)

local noclipBtn = CriarBotao("noclip", function()
    pcall(function()
        -- Script de Noclip Automático
        local Player = game.Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()

        -- Esperar o personagem spawnar
        if not Character then
            Character = Player.CharacterAdded:Wait()
        end

        -- Função para ativar noclip
        local function EnableNoclip()
            print("Noclip ATIVADO automaticamente!")
            
            -- Conexão permanente para noclip
            local noclipConnection
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if Character and Character:FindFirstChild("Humanoid") then
                    for _, part in pairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                else
                    -- Se o personagem morrer, reconectar quando renascer
                    noclipConnection:Disconnect()
                    wait(2)
                    Character = Player.CharacterAdded:Wait()
                    EnableNoclip()
                end
            end)
        end

        -- Ativar noclip imediatamente
        EnableNoclip()

        -- Mensagem de confirmação
        print("Noclip está ativo! Você pode atravessar paredes.")
    end)
end, tabs["Player"].content)
end

-- Criar as abas
tabs["Main"] = createTab("Main")
tabs["Farm"] = createTab("Farm")
tabs["Auto"] = createTab("Auto")
tabs["Player"] = createTab("Player")

-- Configurar todas as abas
setupMainTab()
setupFarmTab()
setupAutoTab()
setupPlayerTab()

-- Conectar eventos de layout para ajustar altura
for _, tab in pairs(tabs) do
    tab.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if currentTab then
            ajustarAlturaJanela()
        end
    end)
end

-- Sistema de rolagem suave com mouse
local function setupSmoothScrolling()
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            if currentTab and tabs[currentTab] then
                local currentCanvasPosition = MainContentContainer.CanvasPosition
                local newCanvasPosition = currentCanvasPosition - Vector2.new(0, input.Position.Z * 20)
                
                local maxCanvasPosition = MainContentContainer.CanvasSize.Y.Offset - MainContentContainer.AbsoluteWindowSize.Y
                
                if newCanvasPosition.Y < 0 then
                    newCanvasPosition = Vector2.new(0, 0)
                elseif newCanvasPosition.Y > maxCanvasPosition then
                    newCanvasPosition = Vector2.new(0, maxCanvasPosition)
                end
                
                MainContentContainer.CanvasPosition = newCanvasPosition
            end
        end
    end)
end

setupSmoothScrolling()

-- Activate first tab by default
if tabs["Main"] then
    tabs["Main"].button:MouseButton1Click()
end

-- Initialize global variables
_G.autoHat = false
_G.autoBackpack = false
_G.autoRaidW3 = false
_G.autoRaidW7 = false
_G.autoClick = true
_G.HitboxSize = 2000
_G.HitboxEnabled = true

print("🚀 RN TEAM INTERFACE LOADED!")

print("✅ Hitbox/Kill Aura system working perfectly!")


