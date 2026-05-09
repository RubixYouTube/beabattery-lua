--[[
    Luau Omega Clicker
    Made by Rubix - v1.0.5
    Place this LocalScript in StarterGui
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ===================== STATE =====================
local tiers = {100, 0, 0, 0} -- Normal, Greek(1-24), Sub(1-3 -> _2,_3,_4), Power(1-7 -> ^2..^8)
local isFlashing = false
local isMinimized = false
local starsVisible = false
local currentThemeIndex = 6 -- Default Purple

-- ===================== CONSTANTS =====================
local ILLIONS = {"", "K", "M", "B", "T", "q", "Q", "s", "S", "O", "N", "D", "Ud"}
local GREEKS = {"Ω", "Ψ", "Χ", "Φ", "Υ", "Τ", "Σ", "Ρ", "Π", "Ο", "Ξ", "Ν", "Μ", "Λ", "Κ", "Ι", "Θ", "Η", "Ζ", "Ε", "Δ", "Γ", "Β", "Α"}

local THEMES = {
    {name="Red",    bg=Color3.fromRGB(40,10,10),  acc=Color3.fromRGB(200,50,50),  txt=Color3.fromRGB(255,200,200), btn=Color3.fromRGB(180,30,30),  btnTxt=Color3.new(1,1,1), glow=Color3.fromRGB(255,80,80)},
    {name="Orange", bg=Color3.fromRGB(40,25,10),  acc=Color3.fromRGB(230,140,30), txt=Color3.fromRGB(255,220,160), btn=Color3.fromRGB(200,100,10), btnTxt=Color3.new(1,1,1), glow=Color3.fromRGB(255,160,50)},
    {name="Yellow", bg=Color3.fromRGB(40,40,10),  acc=Color3.fromRGB(230,230,30), txt=Color3.fromRGB(255,255,180), btn=Color3.fromRGB(200,200,10), btnTxt=Color3.new(0,0,0), glow=Color3.fromRGB(255,255,80)},
    {name="Green",  bg=Color3.fromRGB(10,35,10),  acc=Color3.fromRGB(30,200,30),  txt=Color3.fromRGB(180,255,180), btn=Color3.fromRGB(10,160,10),  btnTxt=Color3.new(1,1,1), glow=Color3.fromRGB(50,255,50)},
    {name="Blue",   bg=Color3.fromRGB(10,15,40),  acc=Color3.fromRGB(30,100,230), txt=Color3.fromRGB(180,210,255), btn=Color3.fromRGB(10,70,200),  btnTxt=Color3.new(1,1,1), glow=Color3.fromRGB(50,130,255)},
    {name="Purple", bg=Color3.fromRGB(25,10,40),  acc=Color3.fromRGB(130,50,230), txt=Color3.fromRGB(210,180,255), btn=Color3.fromRGB(100,30,200), btnTxt=Color3.new(1,1,1), glow=Color3.fromRGB(160,80,255)},
    {name="Pink",   bg=Color3.fromRGB(40,10,30),  acc=Color3.fromRGB(230,50,160), txt=Color3.fromRGB(255,180,220), btn=Color3.fromRGB(200,30,130), btnTxt=Color3.new(1,1,1), glow=Color3.fromRGB(255,80,200)},
    {name="Brown",  bg=Color3.fromRGB(35,20,10),  acc=Color3.fromRGB(160,100,50), txt=Color3.fromRGB(220,190,150), btn=Color3.fromRGB(130,70,30),  btnTxt=Color3.new(1,1,1), glow=Color3.fromRGB(180,120,60)},
    {name="Black",  bg=Color3.fromRGB(10,10,10),  acc=Color3.fromRGB(60,60,60),   txt=Color3.fromRGB(180,180,180), btn=Color3.fromRGB(40,40,40),   btnTxt=Color3.new(1,1,1), glow=Color3.fromRGB(100,100,100)},
    {name="Grey",   bg=Color3.fromRGB(40,40,40),  acc=Color3.fromRGB(130,130,130),txt=Color3.fromRGB(220,220,220), btn=Color3.fromRGB(100,100,100),btnTxt=Color3.new(1,1,1), glow=Color3.fromRGB(160,160,160)},
    {name="White",  bg=Color3.fromRGB(200,200,200),acc=Color3.fromRGB(240,240,240),txt=Color3.fromRGB(50,50,50),   btn=Color3.fromRGB(230,230,230),btnTxt=Color3.new(0,0,0), glow=Color3.fromRGB(255,255,255)}
}

-- ===================== FORMATTING =====================
local function formatNormal(val, inOmega)
    if val <= 0 or val ~= val then return "0" end
    if inOmega then
        if val >= 100 then return string.format("%.1f", val)
        elseif val >= 10 then return string.format("%.2f", val)
        else return string.format("%.3f", val) end
    end
    if val < 1000 then
        if val == math.floor(val) then return tostring(math.floor(val))
        else return string.format("%.1f", val) end
    end
    local exp = math.floor(math.log10(val))
    local tier = math.floor(exp / 3)
    if tier >= #ILLIONS then return string.format("%.2fe%d", val / (10^exp), exp) end
    local coeff = val / (10 ^ (tier * 3))
    if coeff >= 100 then return string.format("%.1f%s", coeff, ILLIONS[tier+1])
    elseif coeff >= 10 then return string.format("%.2f%s", coeff, ILLIONS[tier+1])
    else return string.format("%.3f%s", coeff, ILLIONS[tier+1]) end
end

local function getDisplay()
    local inOmega = tiers[2] > 0 or tiers[3] > 0 or tiers[4] > 0
    local parts = {}

    if tiers[4] > 0 then
        table.insert(parts, tostring(tiers[4]) .. "Ω^" .. tostring(tiers[4] + 1))
    end
    if tiers[3] > 0 then
        local g = GREEKS[tiers[2]] or "?"
        local s = "_" .. tostring(tiers[3] + 1)
        local p = tiers[4] > 0 and ("^" .. tostring(tiers[4])) or ""
        table.insert(parts, tostring(tiers[3]) .. g .. s .. p)
    end
    if tiers[2] > 0 then
        local g = GREEKS[tiers[2]] or "?"
        local p = tiers[4] > 1 and ("^" .. tostring(tiers[4] - 1)) or ""
        table.insert(parts, tostring(tiers[2]) .. g .. p)
    end

    table.insert(parts, formatNormal(tiers[1], inOmega))
    return table.concat(parts, " + ")
end

local function getMultiplier()
    return 1.1 * (3 ^ tiers[2])
end

local function formatMult()
    local m = getMultiplier()
    if m < 10 then return "x" .. string.format("%.2f", m)
    elseif m < 1000 then return "x" .. string.format("%.1f", m)
    else return "x" .. string.format("%.2e", m) end
end

-- ===================== GUI SETUP =====================
local gui = Instance.new("ScreenGui")
gui.Name = "RubixClicker"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local starsFrame = Instance.new("Frame")
starsFrame.Size = UDim2.new(1, 0, 1, 0)
starsFrame.BackgroundTransparency = 1
starsFrame.Visible = false
starsFrame.ZIndex = 0
starsFrame.Parent = gui

for _ = 1, 80 do
    local star = Instance.new("Frame")
    star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.BackgroundColor3 = Color3.new(1, 1, 1)
    star.BackgroundTransparency = 0.5
    star.BorderSizePixel = 0
    star.ZIndex = 0
    star.Parent = starsFrame
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 260)
frame.Position = UDim2.new(0.5, -160, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(25, 10, 40)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.ZIndex = 1
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local glow = Instance.new("UIStroke")
glow.Color = Color3.fromRGB(130, 50, 230)
glow.Thickness = 2.5
glow.Parent = frame

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundTransparency = 1
topBar.ZIndex = 2
topBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -120, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Ω Clicker"
titleLabel.TextColor3 = Color3.fromRGB(210, 180, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 3
titleLabel.Parent = topBar

local function createCtrlBtn(text, posX)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 0, 22)
    b.Position = UDim2.new(1, posX, 0.5, -11)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.ZIndex = 4
    b.Parent = topBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local minBtn = createCtrlBtn("-", -34)
local themeBtn = createCtrlBtn("🎨", -68)
local starsBtn = createCtrlBtn("★", -102)
local descBtn = createCtrlBtn("?", -136)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -32)
content.Position = UDim2.new(0, 0, 0, 32)
content.BackgroundTransparency = 1
content.ZIndex = 2
content.Parent = frame

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, 0, 0, 48)
valueLabel.Position = UDim2.new(0, 0, 0, 10)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = "100"
valueLabel.TextColor3 = Color3.fromRGB(255, 220, 50)
valueLabel.TextSize = 36
valueLabel.Font = Enum.Font.GothamBold
valueLabel.TextStrokeTransparency = 0.5
valueLabel.TextStrokeColor3 = Color3.fromRGB(200, 130, 0)
valueLabel.ZIndex = 3
valueLabel.Parent = content

local multLabel = Instance.new("TextLabel")
multLabel.Size = UDim2.new(1, 0, 0, 20)
multLabel.Position = UDim2.new(0, 0, 0, 58)
multLabel.BackgroundTransparency = 1
multLabel.Text = "x1.10"
multLabel.TextColor3 = Color3.fromRGB(170, 150, 255)
multLabel.TextSize = 14
multLabel.Font = Enum.Font.GothamMedium
multLabel.ZIndex = 3
multLabel.Parent = content

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 220, 0, 72)
button.Position = UDim2.new(0.5, -110, 0, 90)
button.BackgroundColor3 = Color3.fromRGB(100, 30, 200)
button.Text = "✦  CLICK  ✦"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 22
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.ZIndex = 4
button.Parent = content
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 14)

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(150, 110, 255)
btnStroke.Thickness = 1.5
btnStroke.Transparency = 0.3
btnStroke.Parent = button

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, 0, 0, 16)
creditLabel.Position = UDim2.new(0, 0, 1, -20)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "Made by Rubix - v1.0.5"
creditLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
creditLabel.TextSize = 11
creditLabel.Font = Enum.Font.Gotham
creditLabel.ZIndex = 3
creditLabel.Parent = content

local descWindow = Instance.new("Frame")
descWindow.Size = UDim2.new(0, 280, 0, 140)
descWindow.Position = UDim2.new(0.5, -140, 0.5, -70)
descWindow.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
descWindow.BackgroundTransparency = 0.05
descWindow.BorderSizePixel = 0
descWindow.Visible = false
descWindow.ZIndex = 10
descWindow.Parent = gui
Instance.new("UICorner", descWindow).CornerRadius = UDim.new(0, 12)

local descStroke = Instance.new("UIStroke")
descStroke.Color = Color3.fromRGB(200, 200, 200)
descStroke.Thickness = 1.5
descStroke.Parent = descWindow

local descText = Instance.new("TextLabel")
descText.Size = UDim2.new(1, -20, 1, -40)
descText.Position = UDim2.new(0, 10, 0, 10)
descText.BackgroundTransparency = 1
descText.Text = "What is this - this is basically a mini version of be a battery; basically a Game in a script!"
descText.TextColor3 = Color3.fromRGB(220, 220, 220)
descText.TextSize = 14
descText.Font = Enum.Font.Gotham
descText.TextWrapped = true
descText.ZIndex = 11
descText.Parent = descWindow

local descClose = Instance.new("TextButton")
descClose.Size = UDim2.new(0, 60, 0, 28)
descClose.Position = UDim2.new(0.5, -30, 1, -34)
descClose.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
descClose.TextColor3 = Color3.new(1, 1, 1)
descClose.Text = "Close"
descClose.TextSize = 12
descClose.Font = Enum.Font.GothamBold
descClose.BorderSizePixel = 0
descClose.ZIndex = 11
descClose.Parent = descWindow
Instance.new("UICorner", descClose).CornerRadius = UDim.new(0, 8)

-- ===================== LOGIC =====================
local function triggerReset()
    isFlashing = true
    task.spawn(function()
        for i = 1, 14 do
            local on = (i % 2 == 0)
            button.BackgroundColor3 = on and Color3.fromRGB(255, 255, 120) or Color3.fromRGB(255, 80, 80)
            frame.BackgroundColor3 = on and Color3.fromRGB(60, 60, 15) or Color3.fromRGB(60, 15, 15)
            glow.Color = on and Color3.fromRGB(255, 255, 120) or Color3.fromRGB(255, 60, 60)
            valueLabel.TextColor3 = on and Color3.new(1, 1, 1) or Color3.fromRGB(255, 220, 50)
            task.wait(0.07)
        end
        tiers = {100, 0, 0, 0}
        applyTheme()
        isFlashing = false
        updateDisplay()
    end)
end

local function normalize()
    -- Prevent infinity or NaN infinite loops
    if tiers[1] ~= tiers[1] or tiers[1] == math.huge then
        tiers = {999, 24, 3, 7}
        triggerReset()
        return
    end

    local inOmega = tiers[2] > 0 or tiers[3] > 0 or tiers[4] > 0
    
    if not inOmega then
        if tiers[1] >= 340e36 then
            tiers[1] = tiers[1] / 1000
            tiers[2] = 1
            -- Fall through to omega processing
        else
            return
        end
    end

    while tiers[1] >= 1000 do
        tiers[1] = tiers[1] / 1000
        tiers[2] = tiers[2] + 1
        if tiers[2] > 24 then
            tiers[2] = 1
            tiers[3] = tiers[3] + 1
            if tiers[3] > 3 then
                tiers[3] = 1
                tiers[4] = tiers[4] + 1
                if tiers[4] > 7 then
                    tiers = {999, 24, 3, 7}
                    triggerReset()
                    return
                end
            end
        end
    end
end

function updateDisplay()
    valueLabel.Text = getDisplay()
    multLabel.Text = formatMult()
end

function applyTheme()
    local t = THEMES[currentThemeIndex]
    if not t then return end
    frame.BackgroundColor3 = t.bg
    glow.Color = t.glow
    titleLabel.TextColor3 = t.txt
    valueLabel.TextColor3 = t.txt
    multLabel.TextColor3 = t.acc
    button.BackgroundColor3 = t.btn
    button.TextColor3 = t.btnTxt
    btnStroke.Color = t.glow
    minBtn.BackgroundColor3 = t.acc
    themeBtn.BackgroundColor3 = t.acc
    starsBtn.BackgroundColor3 = t.acc
    descBtn.BackgroundColor3 = t.acc
end

-- ===================== EVENTS =====================
local dragToggle, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
topBar.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 320, 0, 35) or UDim2.new(0, 320, 0, 260)
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
    content.Visible = not isMinimized
    minBtn.Text = isMinimized and "+" or "-"
end)

themeBtn.MouseButton1Click:Connect(function()
    currentThemeIndex = (currentThemeIndex % #THEMES) + 1
    applyTheme()
end)

starsBtn.MouseButton1Click:Connect(function()
    starsVisible = not starsVisible
    starsFrame.Visible = starsVisible
    starsBtn.Text = starsVisible and "★" or "☆"
end)

descBtn.MouseButton1Click:Connect(function()
    descWindow.Visible = true
end)
descClose.MouseButton1Click:Connect(function()
    descWindow.Visible = false
end)

button.MouseButton1Click:Connect(function()
    if isFlashing then return end

    tiers[1] = tiers[1] * getMultiplier()
    normalize()

    if not isFlashing then
        updateDisplay()
        task.spawn(function()
            TweenService:Create(button, TweenInfo.new(0.06, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 234, 0, 78)
            }):Play()
            task.wait(0.06)
            TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 220, 0, 72)
            }):Play()
        end)
    end
end)

-- ===================== ANIMATIONS =====================
task.spawn(function()
    local t = 0
    while task.wait(0.03) do
        t += 0.05
        valueLabel.Position = UDim2.new(0, 0, 0, 10 + math.sin(t) * 5)
    end
end)

task.spawn(function()
    local t = 0
    while task.wait(0.03) do
        t += 0.025
        local p = 0.5 + 0.5 * math.sin(t)
        local base = THEMES[currentThemeIndex].glow
        glow.Color = Color3.new(
            math.min(base.R * (0.6 + p * 0.4), 1),
            math.min(base.G * (0.6 + p * 0.4), 1),
            math.min(base.B * (0.6 + p * 0.4), 1)
        )
    end
end)

task.spawn(function()
    while task.wait(0.04) do
        for _, star in ipairs(starsFrame:GetChildren()) do
            if star:IsA("Frame") then
                local t = tick() + (star.Position.X.Offset * 10)
                star.BackgroundTransparency = 0.2 + 0.6 * math.abs(math.sin(t))
            end
        end
    end
end)

-- ===================== INITIALIZE =====================
applyTheme()
updateDisplay()
