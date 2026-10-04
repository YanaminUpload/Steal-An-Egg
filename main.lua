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

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "AccountGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 40)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.3

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, -26, 1, 0)
label.Position = UDim2.new(0, 0, 0, 0)
label.BackgroundTransparency = 1
label.Text = "Account: " .. LocalPlayer.Name
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 20, 0, 20)
minBtn.Position = UDim2.new(1, -22, 0, 2)
minBtn.AnchorPoint = Vector2.new(1, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
minBtn.BackgroundTransparency = 0.3
minBtn.BorderSizePixel = 0
minBtn.Text = "–"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextScaled = true
minBtn.Font = Enum.Font.GothamBold

local minCorner = Instance.new("UICorner", minBtn)
minCorner.CornerRadius = UDim.new(0, 5)

local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 30, 0, 30)
toggle.Position = frame.Position
toggle.AnchorPoint = Vector2.new(0.5, 0.5)
toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggle.BackgroundTransparency = 0.35
toggle.BorderSizePixel = 0
toggle.Text = ""
toggle.Active = true
toggle.AutoButtonColor = false
toggle.Visible = false

local toggleCorner = Instance.new("UICorner", toggle)
toggleCorner.CornerRadius = UDim.new(1, 0)

-- Aksi meminimalkan GUI
minBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    toggle.Position = frame.Position
    toggle.AnchorPoint = Vector2.new(0.5, 0.5)
    toggle.Visible = true
end)

-- Aksi memaksimalkan GUI saat tombol toggle diklik (Bekerja di PC & HP)
toggle.MouseButton1Click:Connect(function()
    toggle.Visible = false
    frame.Visible = true
end)

-- Logika menyeret (dragging) tombol toggle khusus agar tidak mengganggu ketukan klik di HP
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    toggle.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
    frame.Position = toggle.Position -- Sinkronisasi posisi frame utama saat diseret
end

toggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggle.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

print("[MELOAD] Loaded - treadmill + reconnect + GUI aktif (HP & PC Fix)")

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
                print("[SUKSES CLOCK] Menemukan plot valid milikmu! Nomor Kavling: [" .. plot.Name .. "]")
                return plot
            end
        end
    end
    return nil
end

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
        print("[VALIDATOR] Karakter belum terkunci di treadmill. Siklus percobaan ke-" .. tostring(attempts))
        
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
            warn("[WARNING] Gagal melacak treadmill di plot milikmu. Mencoba bypass remote langsung sebagai cadangan...")
        end
        
        if Event and Event:IsA("RemoteFunction") then
            pcall(function()
                Event:InvokeServer()
            end)
        end
        
        task.wait(1)
    end
    
    if rootPart and rootPart.Anchored == true then
        print("[SUKSES MUTLAK] Karakter resmi ter-anchored di atas treadmill base milik sendiri!")
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

-- ==================== [ ANTI-LAG KUSTOM BARU ] ====================

local function setupAntiLag()
    local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    
    settings().Rendering.QualityLevel = 1
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CastShadow = false
            v.Material = "Plastic"
            v.Reflectance = 0
            v.BackSurface = "SmoothNoOutlines"
            v.BottomSurface = "SmoothNoOutlines"
            v.FrontSurface = "SmoothNoOutlines"
            v.LeftSurface = "SmoothNoOutlines"
            v.RightSurface = "SmoothNoOutlines"
            v.TopSurface = "SmoothNoOutlines"
        elseif v:IsA("Decal") then
            v.Transparency = 1
            v.Texture = ""
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        end
    end

    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") then
            v.Enabled = false
        end
    end

    workspace.DescendantAdded:Connect(function(child)
        task.spawn(function()
            if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                RunService.Heartbeat:Wait()
                child:Destroy()
            elseif child:IsA("BasePart") then
                child.CastShadow = false
            end
        end)
    end)
end

-- ==================== [ EKSEKUSI UTAMA ] ====================
setupSafeAntiAFK()
setupAntiLag()

task.spawn(requestEquip)

if setfpscap then
    setfpscap(15) 
else
    warn("Executor atau lingkungan ini tidak mendukung setfpscap!")
end

local lastLogTime = 0
RunService.RenderStepped:Connect(function(deltaTime)
    if os.clock() - lastLogTime >= 5 then
        local fps = math.floor(1 / deltaTime)
        print("💡 Monitor FPS - Saat ini: " .. fps)
        lastLogTime = os.clock()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(5) 
    requestEquip()
end)
