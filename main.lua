-- 1. Tunggu game selesai loading penuh
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local startPlaceId = game.PlaceId

-- ==================== [ GUI USERNAME AKUN ] ====================
local CoreGui = game:GetService("CoreGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccountInfoGui"
screenGui.ResetOnSpawn = false

local player = Players.LocalPlayer 
local myUserId = player.UserId
local myUsername = player.Name

local suksesGui, errGui = pcall(function()
    screenGui.Parent = CoreGui
end)
if not suksesGui then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 50)
frame.Position = UDim2.new(0.5, -125, 0.5, -25)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.2
frame.Parent = screenGui

pcall(function()
    GuiService.MenuOpened:Connect(function()
        screenGui.Enabled = false
    end)
    GuiService.MenuClosed:Connect(function()
        screenGui.Enabled = true
    end)
end)

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -40, 1, 0)
label.Position = UDim2.new(0, 10, 0, 0)
label.BackgroundTransparency = 1
label.Text = "Account: " .. myUsername
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 18
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 25, 0, 25)
toggleBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.Text = "-"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

local invisibleClicker = Instance.new("TextButton")
invisibleClicker.Size = UDim2.new(1, 0, 1, 0)
invisibleClicker.BackgroundTransparency = 1
invisibleClicker.Text = ""
invisibleClicker.Visible = false
invisibleClicker.Parent = frame

local isMinimized = false

toggleBtn.MouseButton1Click:Connect(function()
    if not isMinimized then
        isMinimized = true
        toggleBtn.Visible = false
        label.Visible = false
        frame:TweenSize(UDim2.new(0, 50, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        task.wait(0.3)
        invisibleClicker.Visible = true
    end
end)

invisibleClicker.MouseButton1Click:Connect(function()
    if isMinimized then
        isMinimized = false
        invisibleClicker.Visible = false
        frame:TweenSize(UDim2.new(0, 250, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        task.wait(0.15)
        label.Visible = true
        toggleBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
        toggleBtn.Text = "-"
        toggleBtn.Visible = true
    end
end)


-- Variabel Kontrol untuk Fitur Auto Reconnect
local autoReconnectEnabled = true
local isReconnecting = false

-- ==================== [ FUNGSI AUTO RECONNECT ] ====================

local function handleReconnect(reason)
    if isReconnecting or not autoReconnectEnabled then
        return
    end

    isReconnecting = true
    warn("[AutoReconnect]", reason)

    pcall(function()
        if #Players:GetPlayers() <= 1 then
            pcall(function() LocalPlayer:Kick("\nRejoining...") end)
        end
        TeleportService:Teleport(startPlaceId, LocalPlayer)
    end)
    isReconnecting = false
end

pcall(function()
    if GuiService then
        GuiService.ErrorMessageChanged:Connect(function(msg)
            if not autoReconnectEnabled or isReconnecting then
                return
            end

            msg = tostring(msg):lower()

            if #msg == 0
            or msg:find("729")
            or msg:find("277")
            or msg:find("disconnect")
            or msg:find("internet")
            or msg:find("connection")
            or msg:find("datastore")
            or msg:find("lock")
            or msg:find("locklost")
            or msg:find("lost")
            or msg:find("ownership")
            or msg:find("network")
            or msg:find("shut")
            or msg:find("closed")
            or msg:find("kicked")
            or msg:find("maintenance")
            or msg:find("update")
            or msg:find("769")
            or msg:find("536")
            or msg:find("522")
            or msg:find("273") then
                handleReconnect("Connection Error Detected")
            end
        end)
    end
end)

-- ==================== [ FUNGSI KAVLING BASE ] ====================

local function findMyOwnPlot()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    
    local myDisplayName = LocalPlayer.DisplayName
    local myUsername = LocalPlayer.Name

    for _, plot in pairs(plotsFolder:GetChildren()) do
        local plotSign = plot:FindFirstChild("PlotSign")
        local playerPlotSign = plotSign and plotSign:FindFirstChild("PlayerPlotSign")
        local frame = playerPlotSign and playerPlotSign:FindFirstChild("Frame")
        local playerNameLabel = frame and frame:FindFirstChild("PlayerName")
        
        if playerNameLabel and playerNameLabel:IsA("TextLabel") then
            local txt = playerNameLabel.Text
            if txt == myDisplayName or txt == myUsername then
                return plot
            end
        end
    end
    return nil
end

-- Bersihkan objek visual lokal yang tidak diperlukan setelah plot pemain ditemukan.
local function cleanupWorkspace()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if plotsFolder then
        local ownPlot = findMyOwnPlot()
        if ownPlot then
            for _, plot in ipairs(plotsFolder:GetChildren()) do
                if plot ~= ownPlot then
                    pcall(function() plot:Destroy() end)
                end
            end
        else
            warn("[Cleanup] Plot sendiri belum ditemukan; plot lain tidak dihapus.")
        end
    end

    for _, objectName in ipairs({ "ClientRenderedAssets", "PlacedEggRenders" }) do
        local object = workspace:FindFirstChild(objectName)
        if object then
            pcall(function() object:Destroy() end)
        end
    end
end

cleanupWorkspace()
-- ==================== [ FUNGSI UTAMA TREADMILL ] ====================

local function requestEquip()
    task.wait(2.5) 
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local Packages = ReplicatedStorage:WaitForChild("Packages", 15)
    local Networking = Packages and Packages:WaitForChild("Networking", 15)
    local Event = Networking and Networking:WaitForChild("RF/Treadmill/AskWearStill", 15)
    
    local attempts = 0
    while rootPart and rootPart.Anchored == false and attempts < 10 do
        attempts = attempts + 1
        
        local myPlot = findMyOwnPlot()
        local targetPosition = nil
        
        if myPlot then
            local treadmill = myPlot:FindFirstChild("TreadmillUpgrade", true)
            if treadmill then
                targetPosition = treadmill:IsA("Model") and (treadmill.PrimaryPart and treadmill.PrimaryPart.Position) or treadmill.Position
                
                if not targetPosition and treadmill:IsA("Model") then
                    for _, child in pairs(treadmill:GetChildren()) do
                        if child:IsA("BasePart") then targetPosition = child.Position break end
                    end
                end
            end
        end
        
        if targetPosition then
            local reached = false
            local connection
            
            connection = humanoid.MoveToFinished:Connect(function()
                reached = true
                if connection then connection:Disconnect() end
            end)
            
            humanoid:MoveTo(targetPosition)
            
            local timeout = 0
            while not reached and timeout < 15 do
                task.wait(0.5)
                timeout = timeout + 0.5
                
                if (rootPart.Position - targetPosition).Magnitude <= 4 then
                    reached = true
                    if connection then connection:Disconnect() end
                    break
                end
            end
            
            task.wait(0.5)
        else
        end
        
        if Event and Event:IsA("RemoteFunction") then
            pcall(function()
                Event:InvokeServer()
            end)
        end
        
        task.wait(1)
    end
    
    if rootPart and rootPart.Anchored == true then
    else
        warn("[GAGAL] Batas percobaan loop habis, karakter masih gagal naik ke treadmill.")
    end
end

-- ==================== [ ANTI-AFK INTERNAL ] ====================

local function setupSafeAntiAFK()
    if getconnections then
        for _, c in getconnections(LocalPlayer.Idled) do
            pcall(function() c:Disable() end)
            pcall(function() c:Disconnect() end)
        end
    end

    LocalPlayer.Idled:Connect(function()
        pcall(function()
            local VirtualInputManager = Instance.new("VirtualInputManager")
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            VirtualInputManager:Destroy()
        end)
    end)
end

-- ==================== [ EKSEKUSI UTAMA ] ====================
setupSafeAntiAFK()

task.spawn(requestEquip)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(5) 
    requestEquip()
end)

local player = Players.LocalPlayer
local upgradeEnabled = true
local upgradeRemote = ReplicatedStorage:WaitForChild("Packages", 15)
upgradeRemote = upgradeRemote and upgradeRemote:WaitForChild("Networking", 15)
upgradeRemote = upgradeRemote and upgradeRemote:WaitForChild("RF/Treadmill/AskTierRaise", 15)

local function textToNumber(txt)
    txt = tostring(txt or ""):lower():gsub("[%$,%s]", "")
    local suffix = txt:match("([a-z]+)$")
    local multipliers = {
        k = 1e3,
        m = 1e6,
        b = 1e9,
        t = 1e12,
        qa = 1e15,
    }
    local multiplier = multipliers[suffix] or 1
    if suffix and multipliers[suffix] then
        txt = txt:sub(1, #txt - #suffix)
    end
    return (tonumber(txt) or 0) * multiplier
end

local function getTreadmillFolder(plot)
    return plot and plot:FindFirstChild("TreadmillUpgrade", true)
end

local function findUpgradeUI(treadmillFolder)
    local sign = treadmillFolder and treadmillFolder:FindFirstChild("Sign", true)
    local surfaceGui = sign and sign:FindFirstChildWhichIsA("SurfaceGui", true)
    local frame = surfaceGui and surfaceGui:FindFirstChild("Frame", true)
    local button = frame and frame:FindFirstChild("Upgrade", true)
    local cost = button and button:FindFirstChild("Cost", true)
    return button, cost
end

_G.AutoUpgradeSmartFinal = true

local lastTriedUpgradePrice = nil
task.spawn(function()
    while _G.AutoUpgradeSmartFinal and upgradeEnabled do
        task.wait(1)
        local ok, err = pcall(function()
            if not upgradeRemote or not upgradeRemote:IsA("RemoteFunction") then return end

            local plot = findMyOwnPlot()
            local treadmillFolder = getTreadmillFolder(plot)
            local button, costLabel = findUpgradeUI(treadmillFolder)
            if not button or not costLabel or not costLabel:IsA("TextLabel") then return end

            local price = textToNumber(costLabel.Text)
            if price <= 0 then return end

            local hud = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("HUD")
            if not hud then return end
            local balance
            for _, descendant in ipairs(hud:GetDescendants()) do
                if descendant:IsA("TextLabel") and descendant.Name == "Value" then
                    local amount = textToNumber(descendant.Text)
                    if amount > 0 then balance = amount break end
                end
            end
            if not balance or balance < price then return end
            if lastTriedUpgradePrice == price then return end
            lastTriedUpgradePrice = price

            local data = ReplicatedStorage:FindFirstChild("Data")
            local treadmillData = data and data:FindFirstChild("Treadmills")
            local configs = treadmillData and treadmillData:FindFirstChild("Configs")
            if not configs then
                warn("[AutoUpgrade] Folder Data.Treadmills.Configs tidak ditemukan.")
                return
            end

            local tried = 0
            for _, config in ipairs(configs:GetChildren()) do
                if config:IsA("ModuleScript") and config.Name ~= "Treadmill" then
                    local invokeOk, invokeResult = pcall(function()
                        return upgradeRemote:InvokeServer(config.Name)
                    end)
                    if not invokeOk then
                        warn("[AutoUpgrade] Gagal untuk " .. config.Name .. ": " .. tostring(invokeResult))
                    end
                    tried = tried + 1
                    task.wait(0.5)
                end
            end
            if tried == 0 then
                warn("[AutoUpgrade] Tidak ada config treadmill untuk dicoba.")
            else
                task.spawn(requestEquip)
            end
        end)
        if not ok then warn("[AutoUpgrade]", err) end
    end
end)
