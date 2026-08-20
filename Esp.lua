--by using this script you agree to the fact that you can NOT skid this,if you skid this you have to give credit to me


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local KeycapColors = require(ReplicatedStorage.Shared.KeycapColors)
local KEYCAPS_FOLDER = workspace:WaitForChild("Keycaps")
local MAP = workspace:WaitForChild("Map")

if _G.KeycapESP_Kill then pcall(_G.KeycapESP_Kill) end

local running = true
local highlights = {}
local boardBillboards = {}
local lastColor = nil
local enabled = true
local boardEspEnabled = true
local highlightColor = Color3.fromRGB(255, 60, 60)
local closeKeybind = Enum.KeyCode.RightControl

local T = {
    BG = Color3.fromRGB(15, 23, 42),
    BG2 = Color3.fromRGB(22, 33, 62),
    Accent = Color3.fromRGB(56, 189, 248),
    AccGlow = Color3.fromRGB(100, 210, 255),
    White = Color3.fromRGB(255, 255, 255),
    Dim = Color3.fromRGB(140, 160, 185),
    TogOn = Color3.fromRGB(56, 189, 248),
    TogOff = Color3.fromRGB(50, 58, 78),
    Shadow = Color3.fromRGB(6, 10, 20),
    Gold = Color3.fromRGB(255, 200, 60),
    Red = Color3.fromRGB(220, 60, 60),
    RedGlow = Color3.fromRGB(255, 90, 90),
}

local function colorClose(a, b)
    return (a.R - b.R)^2 + (a.G - b.G)^2 + (a.B - b.B)^2 < 0.005
end

local function clearHighlights()
    for kc, hl in pairs(highlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    highlights = {}
end

local function clearBoardBillboards()
    for name, entry in pairs(boardBillboards) do
        if entry and entry.gui and entry.gui.Parent then entry.gui:Destroy() end
    end
    boardBillboards = {}
end

local function clearAll()
    clearHighlights()
    clearBoardBillboards()
    lastColor = nil
end

local function unloadScript()
    running = false
    clearAll()
    local g = LocalPlayer.PlayerGui:FindFirstChild("KeycapHighlighterESP")
    if g then g:Destroy() end
    local tg = LocalPlayer.PlayerGui:FindFirstChild("KeycapHighlighterToggle")
    if tg then tg:Destroy() end
end

_G.KeycapESP_Kill = unloadScript

for _, gui in LocalPlayer.PlayerGui:GetChildren() do
    if gui.Name == "Maclib" or gui.Name == "ScreenGui" then
        if gui:FindFirstChild("MainFrame") or gui:FindFirstChildWhichIsA("Frame", true) then
            if gui:FindFirstChildOfClass("Frame", true) and gui.ClassName == "ScreenGui" then
                pcall(function() gui:Destroy() end)
            end
        end
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "KeycapHighlighterESP"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer.PlayerGui

local MIN_W, MIN_H = 360, 340
local MAX_W, MAX_H = 520, 560
local DEF_W, DEF_H = 420, 440

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, DEF_W, 0, DEF_H)
Main.Position = UDim2.new(0.5, -DEF_W/2, 1, 60)
Main.BackgroundColor3 = T.BG
Main.BackgroundTransparency = 0.01
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = T.Accent; mainStroke.Thickness = 1.5; mainStroke.Transparency = 0.15

local shd = Instance.new("Frame")
shd.Size = UDim2.new(1, 12, 1, 12)
shd.Position = UDim2.new(0, -6, 0, -6)
shd.BackgroundColor3 = T.Shadow
shd.BackgroundTransparency = 0.5
shd.BorderSizePixel = 0
shd.ZIndex = -1
shd.Parent = Main
Instance.new("UICorner", shd).CornerRadius = UDim.new(0, 18)

local TB = Instance.new("Frame")
TB.Size = UDim2.new(1, 0, 0, 46)
TB.BackgroundColor3 = T.BG2
TB.BorderSizePixel = 0
TB.Parent = Main
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 12)

local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 26, 0, 26)
icon.Position = UDim2.new(0, 10, 0.5, -13)
icon.BackgroundTransparency = 1
icon.Text = "⌨"; icon.TextSize = 16; icon.Font = Enum.Font.GothamBold
icon.Parent = TB

local tt = Instance.new("TextLabel")
tt.Size = UDim2.new(1, -70, 0, 16)
tt.Position = UDim2.new(0, 42, 0, 6)
tt.BackgroundTransparency = 1
tt.Text = "AQUA WAVE"
tt.TextColor3 = T.AccGlow; tt.TextSize = 15; tt.Font = Enum.Font.GothamBlack
tt.TextXAlignment = Enum.TextXAlignment.Left
tt.TextStrokeTransparency = 0.4; tt.TextStrokeColor3 = T.Shadow
tt.Parent = TB

local ts = Instance.new("TextLabel")
ts.Size = UDim2.new(1, -70, 0, 12)
ts.Position = UDim2.new(0, 42, 0, 24)
ts.BackgroundTransparency = 1
ts.Text = ""
ts.TextColor3 = T.Dim; ts.TextSize = 9; ts.Font = Enum.Font.Gotham
ts.TextXAlignment = Enum.TextXAlignment.Left
ts.Parent = TB

local SB = Instance.new("Frame")
SB.Size = UDim2.new(0, 100, 1, -46)
SB.Position = UDim2.new(0, 0, 0, 46)
SB.BackgroundColor3 = T.BG2
SB.BorderSizePixel = 0
SB.Parent = Main
Instance.new("UICorner", SB).CornerRadius = UDim.new(0, 12)
Instance.new("UIPadding", SB).PaddingTop = UDim.new(0, 10)
Instance.new("UIPadding", SB).PaddingBottom = UDim.new(0, 14)
Instance.new("UIPadding", SB).PaddingLeft = UDim.new(0, 7)
Instance.new("UIPadding", SB).PaddingRight = UDim.new(0, 7)
local sbLy = Instance.new("UIListLayout", SB)
sbLy.SortOrder = Enum.SortOrder.LayoutOrder; sbLy.Padding = UDim.new(0, 6)

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(1, -100, 1, -46)
Panel.Position = UDim2.new(0, 100, 0, 46)
Panel.BackgroundTransparency = 1
Panel.BorderSizePixel = 0
Panel.Parent = Main

local function mkPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = T.Accent
    page.ScrollBarImageTransparency = 0.5
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Panel
    local l = Instance.new("UIListLayout", page)
    l.SortOrder = Enum.SortOrder.LayoutOrder; l.Padding = UDim.new(0, 6)
    local p = Instance.new("UIPadding", page)
    p.PaddingLeft = UDim.new(0, 10); p.PaddingRight = UDim.new(0, 10)
    p.PaddingTop = UDim.new(0, 8); p.PaddingBottom = UDim.new(0, 10)
    return page
end

local infoPage = mkPage("Info")
local mainPage = mkPage("Main")
local colorPage = mkPage("Color")
local settingsPage = mkPage("Settings")

local tabData = {}
local activePage = mainPage

local function setTab(page)
    activePage = page
    for _, tab in ipairs(tabData) do
        local on = (tab.page == page)
        tab.page.Visible = on
        tab.frame.BackgroundColor3 = on and T.Accent or T.BG2
        tab.frame.BackgroundTransparency = on and 0.2 or 0.75
        tab.lbl.TextColor3 = on and Color3.fromRGB(255, 255, 255) or T.Dim
    end
end

local function mkTabButton(label, iconTxt, order, page)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = T.BG2
    btn.BackgroundTransparency = 0.75
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = SB
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -6, 1, 0)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = iconTxt .. " " .. label
    lbl.TextColor3 = T.Dim
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn
    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1; hit.Text = ""; hit.Parent = btn
    hit.MouseButton1Click:Connect(function() setTab(page) end)
    table.insert(tabData, { page = page, frame = btn, lbl = lbl })
end

mkTabButton("Info", "ℹ", 1, infoPage)
mkTabButton("ESP", "👁", 2, mainPage)
mkTabButton("Color", "🎨", 3, colorPage)
mkTabButton("Settings", "⚙", 4, settingsPage)
setTab(infoPage)

local function mkToggle(parent, label, desc, initial, order, cb)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 48)
    c.BackgroundColor3 = T.BG2; c.BackgroundTransparency = 0.25
    c.BorderSizePixel = 0; c.LayoutOrder = order; c.Parent = parent
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 8)
    local cs = Instance.new("UIStroke", c)
    cs.Color = T.Accent; cs.Thickness = 1; cs.Transparency = 0.8

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 0, 14)
    lbl.Position = UDim2.new(0, 10, 0, 7)
    lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.TextColor3 = T.White
    lbl.TextSize = 11; lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = c

    local dsc = Instance.new("TextLabel")
    dsc.Size = UDim2.new(0.7, 0, 0, 10)
    dsc.Position = UDim2.new(0, 10, 0, 23)
    dsc.BackgroundTransparency = 1
    dsc.Text = desc; dsc.TextColor3 = T.Dim
    dsc.TextSize = 8; dsc.Font = Enum.Font.Gotham
    dsc.TextXAlignment = Enum.TextXAlignment.Left
    dsc.TextWrapped = true; dsc.Parent = c

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 34, 0, 18)
    bg.Position = UDim2.new(1, -44, 0.5, -9)
    bg.BackgroundColor3 = initial and T.TogOn or T.TogOff
    bg.BorderSizePixel = 0; bg.Parent = c
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = initial and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = T.White; knob.BorderSizePixel = 0; knob.Parent = bg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local on = initial
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = c
    btn.MouseButton1Click:Connect(function()
        on = not on
        bg.BackgroundColor3 = on and T.TogOn or T.TogOff
        knob.Position = on and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        cs.Transparency = on and 0.45 or 0.8
        cb(on)
    end)
end

local function mkButton(parent, text, order, cb, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 30)
    b.LayoutOrder = order
    b.BackgroundColor3 = color or T.BG2
    b.BackgroundTransparency = 0.15
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = T.White
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- ============ INFO TAB ============
local infoSpacer = Instance.new("Frame")
infoSpacer.Size = UDim2.new(1, 0, 0, 8)
infoSpacer.BackgroundTransparency = 1; infoSpacer.LayoutOrder = 0
infoSpacer.Parent = infoPage

local avatarFrame = Instance.new("Frame")
avatarFrame.Size = UDim2.new(0, 80, 0, 80)
avatarFrame.Position = UDim2.new(0.5, -40, 0, 10)
avatarFrame.BackgroundColor3 = T.BG2
avatarFrame.BorderSizePixel = 0
avatarFrame.LayoutOrder = 1; avatarFrame.Parent = infoPage
Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(0, 12)
local avatarStroke = Instance.new("UIStroke", avatarFrame)
avatarStroke.Color = T.Accent; avatarStroke.Thickness = 2; avatarStroke.Transparency = 0.2

local avatarImg = Instance.new("ImageLabel")
avatarImg.Size = UDim2.new(1, 0, 1, 0); avatarImg.BackgroundTransparency = 1
avatarImg.ScaleType = Enum.ScaleType.Fit
avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
avatarImg.Parent = avatarFrame

local helloLabel = Instance.new("TextLabel")
helloLabel.Size = UDim2.new(1, -20, 0, 24)
helloLabel.Position = UDim2.new(0, 10, 0, 100)
helloLabel.BackgroundTransparency = 1
helloLabel.Text = "Hello, " .. LocalPlayer.DisplayName .. "!"
helloLabel.TextColor3 = T.AccGlow; helloLabel.TextSize = 16
helloLabel.Font = Enum.Font.GothamBlack
helloLabel.TextXAlignment = Enum.TextXAlignment.Center
helloLabel.LayoutOrder = 2; helloLabel.Parent = infoPage

local heartLabel = Instance.new("TextLabel")
heartLabel.Size = UDim2.new(1, -20, 0, 60)
heartLabel.Position = UDim2.new(0, 10, 0, 132)
heartLabel.BackgroundTransparency = 1
heartLabel.Text = "Thank you for using Aqua Wave. Every time you load this script, it means the world to me. You are the reason this keeps growing, and I hope it brings you even a little bit of joy in every round."
heartLabel.TextColor3 = T.Dim; heartLabel.TextSize = 10
heartLabel.Font = Enum.Font.Gotham
heartLabel.TextXAlignment = Enum.TextXAlignment.Center
heartLabel.TextWrapped = true; heartLabel.LayoutOrder = 3; heartLabel.Parent = infoPage

local discordCard = Instance.new("Frame")
discordCard.Size = UDim2.new(1, -20, 0, 36)
discordCard.BackgroundColor3 = T.BG2; discordCard.BackgroundTransparency = 0.2
discordCard.BorderSizePixel = 0; discordCard.LayoutOrder = 4; discordCard.Parent = infoPage
Instance.new("UICorner", discordCard).CornerRadius = UDim.new(0, 8)

local discordIcon = Instance.new("TextLabel")
discordIcon.Size = UDim2.new(0, 30, 1, 0); discordIcon.Position = UDim2.new(0, 10, 0, 0)
discordIcon.BackgroundTransparency = 1; discordIcon.Text = "💬"
discordIcon.TextSize = 14; discordIcon.TextColor3 = T.White; discordIcon.Parent = discordCard

local discordText = Instance.new("TextLabel")
discordText.Size = UDim2.new(1, -50, 1, 0); discordText.Position = UDim2.new(0, 38, 0, 0)
discordText.BackgroundTransparency = 1; discordText.Text = "2q4p on Discord"
discordText.TextColor3 = T.Accent; discordText.TextSize = 12
discordText.Font = Enum.Font.GothamBold; discordText.TextXAlignment = Enum.TextXAlignment.Left
discordText.Parent = discordCard

local disclaimerCard = Instance.new("Frame")
disclaimerCard.Size = UDim2.new(1, -20, 0, 60)
disclaimerCard.BackgroundColor3 = T.BG2; disclaimerCard.BackgroundTransparency = 0.2
disclaimerCard.BorderSizePixel = 0; disclaimerCard.LayoutOrder = 5; disclaimerCard.Parent = infoPage
Instance.new("UICorner", disclaimerCard).CornerRadius = UDim.new(0, 8)

local disclaimerText = Instance.new("TextLabel")
disclaimerText.Size = UDim2.new(1, -16, 1, -8); disclaimerText.Position = UDim2.new(0, 8, 0, 4)
disclaimerText.BackgroundTransparency = 1
disclaimerText.Text = "⚠ Color presets: if you have something in hand, drop it first, select the color preset, then pick it up again for it to register."
disclaimerText.TextColor3 = T.Gold; disclaimerText.TextSize = 11
disclaimerText.Font = Enum.Font.Gotham
disclaimerText.TextXAlignment = Enum.TextXAlignment.Left
disclaimerText.TextWrapped = true; disclaimerText.Parent = disclaimerCard

-- ============ ESP TAB ============
local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, 0, 0, 92)
statusCard.BackgroundColor3 = T.BG2; statusCard.BackgroundTransparency = 0.25
statusCard.BorderSizePixel = 0; statusCard.LayoutOrder = 1; statusCard.Parent = mainPage
Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", statusCard).Color = T.Accent; Instance.new("UIStroke", statusCard).Thickness = 1; Instance.new("UIStroke", statusCard).Transparency = 0.6

local statusIcon = Instance.new("TextLabel")
statusIcon.Size = UDim2.new(0, 30, 0, 30); statusIcon.Position = UDim2.new(0, 10, 0, 10)
statusIcon.BackgroundTransparency = 1; statusIcon.Text = "🔑"; statusIcon.TextSize = 18; statusIcon.Parent = statusCard

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -50, 0, 16); statusLabel.Position = UDim2.new(0, 40, 0, 12)
statusLabel.BackgroundTransparency = 1; statusLabel.Text = "Held: None"
statusLabel.TextColor3 = T.AccGlow; statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamBold; statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusCard

local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -50, 0, 14); countLabel.Position = UDim2.new(0, 40, 0, 32)
countLabel.BackgroundTransparency = 1; countLabel.Text = "Matching: 0"
countLabel.TextColor3 = T.Dim; countLabel.TextSize = 10
countLabel.Font = Enum.Font.Gotham; countLabel.TextXAlignment = Enum.TextXAlignment.Left
countLabel.Parent = statusCard

local hlColorLabel = Instance.new("TextLabel")
hlColorLabel.Size = UDim2.new(1, -50, 0, 14); hlColorLabel.Position = UDim2.new(0, 40, 0, 48)
hlColorLabel.BackgroundTransparency = 1; hlColorLabel.Text = "Highlight: Red"
hlColorLabel.TextColor3 = T.Dim; hlColorLabel.TextSize = 9
hlColorLabel.Font = Enum.Font.Gotham; hlColorLabel.TextXAlignment = Enum.TextXAlignment.Left
hlColorLabel.Parent = statusCard

local tipLabel = Instance.new("TextLabel")
tipLabel.Size = UDim2.new(1, -20, 0, 24); tipLabel.Position = UDim2.new(0, 10, 0, 72)
tipLabel.BackgroundTransparency = 1
tipLabel.Text = "Pick up a keycap to highlight all same-color keycaps"
tipLabel.TextColor3 = T.Accent; tipLabel.TextSize = 9; tipLabel.Font = Enum.Font.Gotham
tipLabel.TextWrapped = true; tipLabel.TextXAlignment = Enum.TextXAlignment.Left
tipLabel.Parent = statusCard

mkToggle(mainPage, "ESP", "Toggle highlighting on/off", true, 2, function(on)
    enabled = on
    if not on then
        clearHighlights()
        statusLabel.Text = "Held: None"
        countLabel.Text = "Matching: 0"
    end
end)

mkToggle(mainPage, "Board ESP", "Show markers on matching boards", true, 3, function(on)
    boardEspEnabled = on
    if not on then
        clearBoardBillboards()
    end
end)

-- ============ COLOR TAB ============
local hlColorHeader = Instance.new("TextLabel")
hlColorHeader.Size = UDim2.new(1, 0, 0, 20)
hlColorHeader.LayoutOrder = 1; hlColorHeader.BackgroundTransparency = 1
hlColorHeader.Text = "🎨  Highlight Color"
hlColorHeader.TextColor3 = T.AccGlow; hlColorHeader.TextSize = 12
hlColorHeader.Font = Enum.Font.GothamBold; hlColorHeader.TextXAlignment = Enum.TextXAlignment.Left
hlColorHeader.Parent = colorPage

local presetColors = {
    {"Red", Color3.fromRGB(255, 60, 60)},
    {"Orange", Color3.fromRGB(255, 160, 40)},
    {"Yellow", Color3.fromRGB(255, 240, 40)},
    {"Green", Color3.fromRGB(60, 255, 100)},
    {"Cyan", Color3.fromRGB(40, 240, 255)},
    {"Blue", Color3.fromRGB(60, 120, 255)},
    {"Purple", Color3.fromRGB(180, 60, 255)},
    {"Pink", Color3.fromRGB(255, 100, 200)},
    {"White", Color3.fromRGB(255, 255, 255)},
    {"Gold", Color3.fromRGB(255, 200, 60)},
}

local checkMarks = {}
for i, preset in ipairs(presetColors) do
    local pName, pColor = preset[1], preset[2]
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 32)
    c.BackgroundColor3 = T.BG2; c.BackgroundTransparency = 0.25
    c.BorderSizePixel = 0; c.LayoutOrder = i + 1; c.Parent = colorPage
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 6)

    local swatch = Instance.new("Frame")
    swatch.Size = UDim2.new(0, 20, 0, 20)
    swatch.Position = UDim2.new(0, 8, 0.5, -10)
    swatch.BackgroundColor3 = pColor
    swatch.BorderSizePixel = 0; swatch.Parent = c
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 4)

    local checkMark = Instance.new("TextLabel")
    checkMark.Size = UDim2.new(1, 0, 1, 0); checkMark.BackgroundTransparency = 1
    checkMark.Text = ""; checkMark.TextColor3 = T.White; checkMark.TextSize = 14
    checkMark.Font = Enum.Font.GothamBold; checkMark.Parent = swatch
    checkMarks[i] = checkMark

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -48, 1, 0); lbl.Position = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = pName
    lbl.TextColor3 = T.White; lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = c

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.Parent = c
    btn.MouseButton1Click:Connect(function()
        highlightColor = pColor
        for idx, cm in checkMarks do
            cm.Text = (idx == i) and "✓" or ""
        end
        hlColorLabel.Text = "Highlight: " .. pName
        if lastColor then
            local count = highlightByColor(lastColor)
            countLabel.Text = "Matching: " .. count
        end
    end)
end

checkMarks[1].Text = "✓"

-- ============ SETTINGS TAB ============
mkButton(settingsPage, "🗑  Clear Highlights", 1, function()
    clearAll()
    statusLabel.Text = "Held: None"
    countLabel.Text = "Matching: 0"
end)

mkToggle(settingsPage, "🔒  Lock UI", "Disable dragging", false, 2, function(on)
    Main.Draggable = not on
    if rh then rh.Visible = not on end
end)

local function mkKeybindPicker(parent, label, desc, initial, order, cb)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 48)
    c.BackgroundColor3 = T.BG2; c.BackgroundTransparency = 0.25
    c.BorderSizePixel = 0; c.LayoutOrder = order; c.Parent = parent
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 8)
    local cs = Instance.new("UIStroke", c)
    cs.Color = T.Accent; cs.Thickness = 1; cs.Transparency = 0.8

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 0, 14)
    lbl.Position = UDim2.new(0, 10, 0, 7)
    lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.TextColor3 = T.White
    lbl.TextSize = 11; lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = c

    local dsc = Instance.new("TextLabel")
    dsc.Size = UDim2.new(0.6, 0, 0, 10)
    dsc.Position = UDim2.new(0, 10, 0, 23)
    dsc.BackgroundTransparency = 1
    dsc.Text = desc; dsc.TextColor3 = T.Dim
    dsc.TextSize = 8; dsc.Font = Enum.Font.Gotham
    dsc.TextXAlignment = Enum.TextXAlignment.Left
    dsc.TextWrapped = true; dsc.Parent = c

    local keyLabel = Instance.new("TextButton")
    keyLabel.Size = UDim2.new(0, 90, 0, 24)
    keyLabel.Position = UDim2.new(1, -100, 0.5, -12)
    keyLabel.BackgroundColor3 = T.Shadow
    keyLabel.BorderSizePixel = 0
    keyLabel.Text = initial.Name
    keyLabel.TextColor3 = T.Accent
    keyLabel.TextSize = 10
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.Parent = c
    Instance.new("UICorner", keyLabel).CornerRadius = UDim.new(0, 6)

    local listening = false
    local conn = nil
    keyLabel.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyLabel.Text = "..."
        keyLabel.BackgroundColor3 = T.Accent
        keyLabel.TextColor3 = T.Shadow
        cs.Transparency = 0.2

        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                if conn then conn:Disconnect(); conn = nil end
                keyLabel.Text = input.KeyCode.Name
                keyLabel.BackgroundColor3 = T.Shadow
                keyLabel.TextColor3 = T.Accent
                cs.Transparency = 0.8
                cb(input.KeyCode)
            end
        end)
    end)
end

mkKeybindPicker(settingsPage, "Close UI Keybind", "Click then press a key", closeKeybind, 3, function(key)
    closeKeybind = key
end)

mkButton(settingsPage, "❌  Unload", 4, function() unloadScript() end)

-- ============ STATUS BAR ============
local sbFrame = Instance.new("Frame")
sbFrame.Size = UDim2.new(1, -16, 0, 24)
sbFrame.Position = UDim2.new(0, 8, 1, -32)
sbFrame.BackgroundColor3 = T.BG2; sbFrame.BackgroundTransparency = 0.4
sbFrame.BorderSizePixel = 0; sbFrame.ZIndex = 3; sbFrame.Parent = Main
Instance.new("UICorner", sbFrame).CornerRadius = UDim.new(0, 6)

local stxt = Instance.new("TextLabel")
stxt.Size = UDim2.new(1, -10, 1, 0); stxt.Position = UDim2.new(0, 6, 0, 0)
stxt.BackgroundTransparency = 1
stxt.Text = "⌨ " .. closeKeybind.Name .. "  •  0 FPS"
stxt.TextColor3 = T.Dim; stxt.TextSize = 9
stxt.Font = Enum.Font.Gotham; stxt.TextXAlignment = Enum.TextXAlignment.Left
stxt.Parent = sbFrame

local vr = Instance.new("TextLabel")
vr.Size = UDim2.new(0, 40, 1, 0); vr.Position = UDim2.new(1, -44, 0, 0)
vr.BackgroundTransparency = 1; vr.Text = "v1.5"
vr.TextColor3 = T.Accent; vr.TextSize = 9
vr.Font = Enum.Font.GothamBold; vr.TextXAlignment = Enum.TextXAlignment.Right
vr.Parent = sbFrame

local fpsFrames = 0
local fpsLast = 0
RunService.RenderStepped:Connect(function()
    fpsFrames = fpsFrames + 1
    local now = os.clock()
    local delta = now - fpsLast
    if delta >= 0.5 then
        stxt.Text = "⌨ " .. closeKeybind.Name .. "  •  " .. tostring(math.round(fpsFrames / delta)) .. " FPS"
        fpsFrames = 0; fpsLast = now
    end
end)

-- ============ RESIZE HANDLE ============
rh = Instance.new("TextButton")
rh.Size = UDim2.new(0, 18, 0, 18)
rh.Position = UDim2.new(1, -18, 1, -18)
rh.BackgroundColor3 = T.Accent; rh.BackgroundTransparency = 0.5
rh.BorderSizePixel = 0; rh.Text = "⤡"; rh.TextColor3 = T.White
rh.TextSize = 9; rh.Font = Enum.Font.GothamBold; rh.ZIndex = 10
rh.AutoButtonColor = false; rh.Parent = Main
Instance.new("UICorner", rh).CornerRadius = UDim.new(0, 5)

local resizing = false
local rStart, sStart
rh.MouseButton1Down:Connect(function()
    resizing = true
    rStart = UserInputService:GetMouseLocation()
    sStart = Main.AbsoluteSize
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local m = UserInputService:GetMouseLocation()
        local d = m - rStart
        Main.Size = UDim2.new(0, math.clamp(sStart.X + d.X, MIN_W, MAX_W), 0, math.clamp(sStart.Y + d.Y, MIN_H, MAX_H))
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
end)

-- ============ TOGGLE BUTTON ============
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "KeycapHighlighterToggle"
toggleGui.ResetOnSpawn = false; toggleGui.DisplayOrder = 999
toggleGui.Parent = LocalPlayer.PlayerGui

local TOGGLE_SIZE = 56
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "Toggle"
toggleBtn.Size = UDim2.new(0, TOGGLE_SIZE, 0, TOGGLE_SIZE)
toggleBtn.Position = UDim2.new(0, 16, 1, -126)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 120)
toggleBtn.BorderSizePixel = 0; toggleBtn.Text = ""
toggleBtn.AutoButtonColor = false; toggleBtn.ZIndex = 100
toggleBtn.Parent = toggleGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = T.AccGlow; toggleStroke.Thickness = 2; toggleStroke.Transparency = 0.3

local waveGrad = Instance.new("UIGradient", toggleBtn)
waveGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 50, 110)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 110, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 170, 240)),
})
waveGrad.Rotation = 135

local waveIcon = Instance.new("TextLabel")
waveIcon.Size = UDim2.new(0, 34, 0, 34)
waveIcon.Position = UDim2.new(0.5, -17, 0.5, -17)
waveIcon.BackgroundTransparency = 1; waveIcon.Text = "⌨"
waveIcon.TextSize = 20; waveIcon.ZIndex = 101; waveIcon.Parent = toggleBtn

local guiVisible = true
local toggleDragging = false
local toggleDragStart = nil
local toggleBtnStart = nil
local toggleHasMoved = false

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleDragging = true; toggleHasMoved = false
        toggleDragStart = input.Position; toggleBtnStart = toggleBtn.AbsolutePosition
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if toggleDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - toggleDragStart
        if not toggleHasMoved and delta.Magnitude > 10 then toggleHasMoved = true end
        if toggleHasMoved then
            local pa = toggleGui.AbsolutePosition
            toggleBtn.Position = UDim2.new(0, (toggleBtnStart.X - pa.X) + delta.X, 0, (toggleBtnStart.Y - pa.Y) + delta.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if toggleDragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleDragging = false
        if not toggleHasMoved then
            guiVisible = not guiVisible
            Main.Visible = guiVisible
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == closeKeybind then
        guiVisible = not guiVisible; Main.Visible = guiVisible
    end
end)

toggleBtn.MouseEnter:Connect(function() toggleStroke.Transparency = 0 end)
toggleBtn.MouseLeave:Connect(function() toggleStroke.Transparency = 0.3 end)

TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -DEF_W/2, 0.5, -DEF_H/2)
}):Play()
task.delay(0.15, function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 16, 1, -126)
    }):Play()
end)

-- ============ HIGHLIGHT KEYCAPS ============
local function highlightByColor(color)
    clearHighlights()
    if not color then return 0 end
    local count = 0
    for _, kc in KEYCAPS_FOLDER:GetChildren() do
        if colorClose(kc.Color, color) then
            local hl = Instance.new("Highlight")
            hl.Name = "_ESP"
            hl.FillColor = highlightColor
            hl.OutlineColor = highlightColor
            hl.FillTransparency = 0.4
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = kc
            highlights[kc] = hl
            count = count + 1
        end
    end
    return count
end

-- ============ BOARD BILLBOARD BUILDER ============
local function makeBoardBillboard(board, colorData)
    local base = board:FindFirstChild("Base")
    if not base then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "KeyboardESP_" .. board.Name
    bb.Adornee = base
    bb.Size = UDim2.new(0, 160, 0, 56)
    bb.StudsOffset = Vector3.new(0, 5, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.MaxDistance = 500
    bb.Parent = LocalPlayer.PlayerGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = T.BG
    bg.BackgroundTransparency = 0.15
    bg.BorderSizePixel = 0
    bg.Parent = bb
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", bg)
    stroke.Color = highlightColor
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3

    local swatch = Instance.new("Frame")
    swatch.Size = UDim2.new(0, 24, 0, 24)
    swatch.Position = UDim2.new(0, 8, 0.5, -12)
    swatch.BackgroundColor3 = colorData.CapColor
    swatch.BorderSizePixel = 0
    swatch.Parent = bg
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 5)

    local boardLabel = Instance.new("TextLabel")
    boardLabel.Size = UDim2.new(1, -44, 0, 16)
    boardLabel.Position = UDim2.new(0, 38, 0, 6)
    boardLabel.BackgroundTransparency = 1
    boardLabel.Text = board.Name
    boardLabel.TextColor3 = T.White
    boardLabel.TextSize = 12
    boardLabel.Font = Enum.Font.GothamBold
    boardLabel.TextXAlignment = Enum.TextXAlignment.Left
    boardLabel.Parent = bg

    local colorName = Instance.new("TextLabel")
    colorName.Size = UDim2.new(1, -44, 0, 14)
    colorName.Position = UDim2.new(0, 38, 0, 24)
    colorName.BackgroundTransparency = 1
    colorName.Text = colorData.Name
    colorName.TextColor3 = colorData.CapColor
    colorName.TextSize = 11
    colorName.Font = Enum.Font.GothamBold
    colorName.TextXAlignment = Enum.TextXAlignment.Left
    colorName.Parent = bg

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, -8, 0, 12)
    distLabel.Position = UDim2.new(0, 4, 1, -16)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.TextColor3 = T.Dim
    distLabel.TextSize = 8
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextXAlignment = Enum.TextXAlignment.Right
    distLabel.Parent = bg

    return { gui = bb, distLabel = distLabel, board = board, stroke = stroke }
end

local function updateBoardESP(color)
    clearBoardBillboards()
    if not color then return 0 end
    local count = 0
    for _, child in ipairs(MAP:GetChildren()) do
        if child:IsA("Model") and child:GetAttribute("BoardId") then
            local boardId = child:GetAttribute("BoardId")
            local colorData = KeycapColors.getForBoard(boardId)
            if colorData and colorClose(colorData.CapColor, color) then
                local entry = makeBoardBillboard(child, colorData)
                if entry then
                    boardBillboards[child.Name] = entry
                    count = count + 1
                end
            end
        end
    end
    return count
end

-- ============ MAIN LOOP ============
RunService.RenderStepped:Connect(function()
    if not running then return end

    local vm = workspace:FindFirstChild("ClientViewmodel")
    if not vm then
        if lastColor then
            clearAll()
            statusLabel.Text = "Held: None"
            countLabel.Text = "Matching: 0"
        end
        return
    end

    local heldColor = nil
    local heldName = nil
    for _, child in vm:GetChildren() do
        if child:IsA("BasePart") then
            heldColor = child.Color; heldName = child.Name; break
        end
    end

    if heldColor and not (lastColor and colorClose(heldColor, lastColor)) then
        lastColor = heldColor

        if enabled then
            local count = highlightByColor(heldColor)
            statusLabel.Text = "Held: " .. (heldName or "?")
            countLabel.Text = "Matching: " .. count
        end

        if boardEspEnabled then
            updateBoardESP(heldColor)
        end
    elseif not heldColor and lastColor then
        clearAll()
        lastColor = nil
        statusLabel.Text = "Held: None"
        countLabel.Text = "Matching: 0"
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and lastColor and boardEspEnabled then
        local myPos = root.Position
        for name, entry in pairs(boardBillboards) do
            if entry and entry.gui and entry.gui.Parent then
                local base = entry.board:FindFirstChild("Base")
                if base then
                    local dist = (base.Position - myPos).Magnitude
                    entry.gui.Enabled = dist <= 500
                    entry.distLabel.Text = math.floor(dist) .. "m"
                end
            end
        end
    end
end)
