-- [[ Rscripts Risk Notice ]]
-- This script is not verified by rscripts.net. Deal with caution.
--
-- Stay safe:
--   • Never log in on unofficial Roblox sites or lookalike domains.
--   • Real Roblox links use roblox.com (check the .com ending).
--   • Treat fake Roblox login / "claim reward" pages as phishing.
-- [[ End Rscripts Risk Notice ]]

--[[rscripts:analytics:start]]
-- Script analytics (enabled by the creator on rscripts.net).
-- Runs in its own thread and cannot affect the script below.
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://rscripts.net/api/telemetry/v2/client.lua?s=6ada9926761191146e161bdf"))()
    end)
end)
--[[rscripts:analytics:end]]

-- NANAMI AUTO RATIO
-- Made by script maker ahh boi on yt

-- Destroy any previous instance
pcall(function()
    local old = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("NanamiControlPanel")
    if old then old:Destroy() end
end)
if getgenv then getgenv().NANAMI_RUNNING = true end

-- Services
local Players          = game:GetService("Players")
local RS               = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Stats            = game:GetService("Stats")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- Blue neon theme inspired by Nanami's ultimate
local COLORS = {
    -- Colors matched to the turquoise-to-blue "Tempo Extra" bar
    bg          = Color3.fromRGB(8, 18, 34),
    inputBg     = Color3.fromRGB(12, 35, 58),
    headerBg    = Color3.fromRGB(10, 27, 46),
    cyan        = Color3.fromRGB(65, 190, 220),
    lightCyan   = Color3.fromRGB(180, 235, 245),
    darkCyan    = Color3.fromRGB(20, 90, 130),
    whiteText   = Color3.fromRGB(240, 246, 255),
    grayText    = Color3.fromRGB(145, 165, 195),
    green       = Color3.fromRGB(70, 210, 140),
    red         = Color3.fromRGB(65, 190, 220), -- inactive/error accent follows the original blue-cyan theme
}

-- State
local SystemActive    = false
local EventConnection = nil
local RunningTasks    = {}
local TaskIdCounter   = 0

local function tween(o, t, p)
    TweenService:Create(o, TweenInfo.new(t), p):Play()
end

-- Safe ping getter
local function getPing()
    local ok, ping = pcall(function() return LP:GetNetworkPing() end)
    if ok and type(ping) == "number" then return ping end
    local ok2, val = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    if ok2 and type(val) == "number" then return val end
    return 0
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NanamiControlPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PG

-- Main panel
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 540, 0, 360)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -180)
MainFrame.BackgroundColor3 = COLORS.bg
MainFrame.BorderSizePixel = 0
local PanelGradient = Instance.new("UIGradient")
PanelGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 105, 145)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 28, 52)),
})
PanelGradient.Rotation = 90
PanelGradient.Parent = MainFrame
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = COLORS.cyan
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.1

local UIGlow = Instance.new("UIStroke", MainFrame)
UIGlow.Color = COLORS.cyan
UIGlow.Thickness = 4
UIGlow.Transparency = 0.85

task.spawn(function()
    local t = 0
    while MainFrame.Parent do
        t = t + 0.05
        local sin = (math.sin(t) + 1) / 2
        pcall(function()
            UIGlow.Transparency = 0.85 - (sin * 0.15)
        end)
        task.wait(0.05)
    end
end)

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 64)
Header.BackgroundColor3 = COLORS.headerBg
Header.BackgroundTransparency = 1
Header.BorderSizePixel = 0
Header.Active = true
Header.Parent = MainFrame

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -36, 0, 2)
HeaderLine.Position = UDim2.new(0, 18, 1, -2)
HeaderLine.BackgroundColor3 = COLORS.cyan
HeaderLine.BackgroundTransparency = 0.7
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local IconFrame = Instance.new("Frame")
IconFrame.Size = UDim2.new(0, 38, 0, 38)
IconFrame.Position = UDim2.new(0, 18, 0.5, -19)
IconFrame.BackgroundColor3 = COLORS.cyan
IconFrame.BorderSizePixel = 0
IconFrame.Parent = Header

local IconText = Instance.new("TextLabel")
IconText.Size = UDim2.new(1, 0, 1, 0)
IconText.BackgroundTransparency = 1
IconText.Text = "!"
IconText.TextColor3 = Color3.fromRGB(5, 10, 25)
IconText.TextScaled = true
IconText.Font = Enum.Font.GothamBold
IconText.Parent = IconFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -150, 0, 28)
TitleLabel.Position = UDim2.new(0, 68, 0, 7)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "NANAMI"
TitleLabel.TextColor3 = COLORS.whiteText
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 19
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(1, -150, 0, 18)
SubLabel.Position = UDim2.new(0, 68, 0, 34)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "auto ratio | inactive"
SubLabel.TextColor3 = COLORS.grayText
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextSize = 13
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = Header

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 38, 0, 38)
MinimizeBtn.Position = UDim2.new(1, -88, 0.5, -19)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(12, 28, 55)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = COLORS.lightCyan
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 38, 0, 38)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -19)
CloseBtn.BackgroundColor3 = Color3.fromRGB(12, 28, 55)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "x"
CloseBtn.TextColor3 = COLORS.lightCyan
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

-- Floating circular button: keeps the interface accessible after closing it.
-- Its turquoise-to-blue gradient matches the reference color.
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "OpenCloseButton"
ToggleButton.Size = UDim2.new(0, 62, 0, 62)
ToggleButton.Position = UDim2.new(0, 22, 0.5, -31)
ToggleButton.BackgroundColor3 = Color3.fromRGB(65, 190, 220)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "N"
ToggleButton.TextColor3 = Color3.fromRGB(235, 250, 255)
ToggleButton.TextSize = 25
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = false
ToggleButton.Active = true
ToggleButton.Visible = true
ToggleButton.ZIndex = 20
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 225, 230)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 95, 145)),
})
ToggleGradient.Rotation = 90
ToggleGradient.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(155, 240, 245)
ToggleStroke.Thickness = 2
ToggleStroke.Transparency = 0.12
ToggleStroke.Parent = ToggleButton

local ToggleGlow = Instance.new("UIStroke")
ToggleGlow.Color = Color3.fromRGB(65, 190, 220)
ToggleGlow.Thickness = 5
ToggleGlow.Transparency = 0.72
ToggleGlow.Parent = ToggleButton

ToggleButton.MouseEnter:Connect(function()
    tween(ToggleButton, 0.15, { Size = UDim2.new(0, 68, 0, 68) })
end)
ToggleButton.MouseLeave:Connect(function()
    tween(ToggleButton, 0.15, { Size = UDim2.new(0, 62, 0, 62) })
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Status
local StatusPanel = Instance.new("Frame")
StatusPanel.Size = UDim2.new(1, -36, 0, 58)
StatusPanel.Position = UDim2.new(0, 18, 0, 82)
StatusPanel.BackgroundColor3 = COLORS.inputBg
StatusPanel.BorderSizePixel = 0
StatusPanel.Parent = MainFrame
Instance.new("UICorner", StatusPanel).CornerRadius = UDim.new(0, 8)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 16, 0, 16)
StatusDot.Position = UDim2.new(0, 22, 0.5, -8)
StatusDot.BackgroundColor3 = COLORS.red
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusPanel
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local DotGlow = Instance.new("UIStroke", StatusDot)
DotGlow.Color = COLORS.red
DotGlow.Thickness = 2
DotGlow.Transparency = 0.4

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -64, 1, 0)
StatusText.Position = UDim2.new(0, 54, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "SYSTEM INACTIVE"
StatusText.TextColor3 = COLORS.red
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 18
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusPanel

-- AUTO RATIO button
local MainButton = Instance.new("TextButton")
MainButton.Size = UDim2.new(1, -36, 0, 150)
MainButton.Position = UDim2.new(0, 18, 0, 156)
MainButton.BackgroundColor3 = COLORS.darkCyan
MainButton.BorderSizePixel = 0
local ButtonGradient = Instance.new("UIGradient")
ButtonGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 105, 145)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 28, 52)),
})
ButtonGradient.Rotation = 90
ButtonGradient.Parent = MainButton
MainButton.Text = "AUTO RATIO"
MainButton.TextColor3 = Color3.fromRGB(240, 246, 255)
MainButton.Font = Enum.Font.GothamBlack
MainButton.TextSize = 28
MainButton.AutoButtonColor = false
MainButton.Parent = MainFrame
Instance.new("UICorner", MainButton).CornerRadius = UDim.new(0, 10)

local MainBtnStroke = Instance.new("UIStroke", MainButton)
MainBtnStroke.Color = COLORS.lightCyan
MainBtnStroke.Thickness = 1.5
MainBtnStroke.Transparency = 0.2

-- Credit footer
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Name = "CreditLabel"
CreditLabel.Size = UDim2.new(1, -36, 0, 24)
CreditLabel.Position = UDim2.new(0, 18, 1, -32)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "made by script maker ahh boi on yt"
CreditLabel.TextColor3 = COLORS.grayText
CreditLabel.Font = Enum.Font.GothamMedium
CreditLabel.TextSize = 13
CreditLabel.TextXAlignment = Enum.TextXAlignment.Center
CreditLabel.Parent = MainFrame

-- Pulse
local PulseConn = nil
local function startPulse(color)
    if PulseConn then PulseConn:Disconnect() end
    local t = 0
    PulseConn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        local alpha = (math.sin(t * 4) + 1) / 2
        StatusDot.BackgroundTransparency = 0.2 + alpha * 0.4
        DotGlow.Transparency = 0.7 - alpha * 0.5
        DotGlow.Color = color
        StatusDot.BackgroundColor3 = color
    end)
end

startPulse(COLORS.red)

local function setActiveVisual(active)
    if active then
        tween(MainButton, 0.3, { BackgroundColor3 = Color3.fromRGB(25, 125, 165) })
        tween(MainBtnStroke, 0.3, { Color = COLORS.lightCyan, Transparency = 0 })
        MainButton.Text = "AUTO RATIO ON"
        MainButton.TextColor3 = Color3.fromRGB(240, 246, 255)
        StatusText.Text = "SYSTEM ACTIVE"
        StatusText.TextColor3 = COLORS.green
        startPulse(COLORS.green)
        SubLabel.Text = "auto ratio | active"
        SubLabel.TextColor3 = COLORS.green
    else
        tween(MainButton, 0.3, { BackgroundColor3 = COLORS.darkCyan })
        tween(MainBtnStroke, 0.3, { Color = COLORS.lightCyan, Transparency = 0.2 })
        MainButton.Text = "AUTO RATIO"
        MainButton.TextColor3 = Color3.fromRGB(240, 246, 255)
        StatusText.Text = "SYSTEM INACTIVE"
        StatusText.TextColor3 = COLORS.red
        startPulse(COLORS.red)
        SubLabel.Text = "auto ratio | inactive"
        SubLabel.TextColor3 = COLORS.grayText
    end
end

-- Custom drag - Android / Delta
-- Arraste pela barra superior (Header) para mover o painel inteiro.
local dragging = false
local dragStart = nil
local startPos = nil
local activeTouch = nil

Header.Active = true

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        if input.UserInputType == Enum.UserInputType.Touch then
            activeTouch = input
        end

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if activeTouch == input then
                    activeTouch = nil
                end
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging or not dragStart or not startPos then return end

    local isMouse = input.UserInputType == Enum.UserInputType.MouseMovement
    local isTouch = input.UserInputType == Enum.UserInputType.Touch
        and activeTouch ~= nil

    if isMouse or isTouch then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input == activeTouch then
        dragging = false
        activeTouch = nil
    end
end)

-- Nanami logic
local function getNanamiEffects()
    local ok, result = pcall(function()
        return RS.Knit.Knit.Services.NanamiService.RE.Effects
    end)
    return ok and result or nil
end

local function getNanamiRightActivated()
    local ok, result = pcall(function()
        return RS.Knit.Knit.Services.NanamiService.RE.RightActivated
    end)
    return ok and result or nil
end

local function isNanami()
    local ok, result = pcall(function()
        return RS.Knit.Knit.Services.NanamiService
    end)
    return ok and result ~= nil
end

local function cancelTasks()
    for id, thread in pairs(RunningTasks) do
        if coroutine.status(thread) ~= "dead" then
            pcall(task.cancel, thread)
        end
        RunningTasks[id] = nil
    end
end

local function onEffectReceived(...)
    local args = { ... }
    if args[1] ~= "SpawnRatio" then return end
    if args[2] ~= LP then return end

    local value = tonumber(args[6]) or 0
    local ping = getPing()

    local delayBase = value * 0.56767676767676769420
    local delay = delayBase - ping
    if delay < 0 then delay = 0 end

    local variation = math.random(-3, 3) / 1000
    delay = delay + variation
    if delay < 0 then delay = 0 end

    local taskId = TaskIdCounter + 1
    TaskIdCounter = taskId

    local thread = task.spawn(function()
        task.wait(delay)
        if not SystemActive then return end

        local rightActivated = getNanamiRightActivated()
        if rightActivated then
            pcall(function()
                rightActivated:FireServer()
            end)
        end

        RunningTasks[taskId] = nil
    end)

    RunningTasks[taskId] = thread
end

local function activateSystem()
    if SystemActive then return end

    if not isNanami() then
        StatusText.Text = "NOT NANAMI"
        StatusText.TextColor3 = COLORS.red
        task.delay(3, function()
            if not SystemActive then
                StatusText.Text = "SYSTEM INACTIVE"
                StatusText.TextColor3 = COLORS.red
            end
        end)
        return
    end

    local effects = getNanamiEffects()
    if not effects then
        StatusText.Text = "SERVICE NOT FOUND"
        StatusText.TextColor3 = COLORS.red
        return
    end

    local ok, conn = pcall(function()
        return effects.OnClientEvent:Connect(onEffectReceived)
    end)

    if not ok or not conn then
        StatusText.Text = "FAILED TO CONNECT"
        StatusText.TextColor3 = COLORS.red
        return
    end

    EventConnection = conn
    SystemActive = true
    setActiveVisual(true)
end

local function deactivateSystem()
    if not SystemActive then return end

    if EventConnection then
        pcall(function() EventConnection:Disconnect() end)
        EventConnection = nil
    end

    cancelTasks()
    SystemActive = false
    setActiveVisual(false)
end

-- Buttons
MainButton.MouseButton1Click:Connect(function()
    tween(MainButton, 0.08, { Size = UDim2.new(1, -42, 0, 145) })
    task.delay(0.08, function()
        tween(MainButton, 0.12, { Size = UDim2.new(1, -36, 0, 150) })
    end)

    if SystemActive then
        deactivateSystem()
    else
        activateSystem()
    end
end)

MainButton.MouseEnter:Connect(function()
    if not SystemActive then
        tween(MainButton, 0.15, { BackgroundColor3 = COLORS.cyan })
    else
        tween(MainButton, 0.15, { BackgroundColor3 = Color3.fromRGB(35, 145, 185) })
    end
end)

MainButton.MouseLeave:Connect(function()
    if not SystemActive then
        tween(MainButton, 0.15, { BackgroundColor3 = COLORS.darkCyan })
    else
        tween(MainButton, 0.15, { BackgroundColor3 = Color3.fromRGB(25, 125, 165) })
    end
end)

MinimizeBtn.MouseEnter:Connect(function()
    tween(MinimizeBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(20, 75, 105) })
end)
MinimizeBtn.MouseLeave:Connect(function()
    tween(MinimizeBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(12, 28, 55) })
end)

CloseBtn.MouseEnter:Connect(function()
    tween(CloseBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(30, 90, 120) })
end)
CloseBtn.MouseLeave:Connect(function()
    tween(CloseBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(12, 28, 55) })
end)

-- Minimize
local minimized     = false
local originalSize  = UDim2.new(0, 540, 0, 360)
local minimizedSize = UDim2.new(0, 540, 0, 64)

MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        for _, obj in ipairs(MainFrame:GetChildren()) do
            if obj ~= Header and obj:IsA("GuiObject") then
                obj.Visible = false
            end
        end
        tween(MainFrame, 0.2, { Size = minimizedSize })
        MinimizeBtn.Text = "+"
    else
        tween(MainFrame, 0.2, { Size = originalSize })
        task.delay(0.15, function()
            if not MainFrame.Parent then return end
            for _, obj in ipairs(MainFrame:GetChildren()) do
                if obj:IsA("GuiObject") then
                    obj.Visible = true
                end
            end
        end)
        MinimizeBtn.Text = "-"
    end
end)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- RightShift also opens/closes the panel without hiding the floating button.
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Boot
MainFrame.Visible = true
print("[NANAMI] Loaded | Made by script maker ahh boi on yt")
