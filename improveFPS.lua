--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local HEIGHT = 550 -- ความสูงกล้อง

local function updateCamera()
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        local target = Vector3.new(pos.X, pos.Y + HEIGHT, pos.Z)
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = camera.CFrame:Lerp(
            CFrame.lookAt(target, pos, Vector3.new(0,0,-1)), 0.2
        )
    end
end

RunService.Heartbeat:Connect(updateCamera)

---------------------------------------------------------
-- 🔹 ลบ Notifications GUI
---------------------------------------------------------
pcall(function()
    local notifications = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("Notifications")
    if notifications then
        notifications:Destroy()
    end
end)

---------------------------------------------------------
-- 🔹 ลบ Effect.Container ที่ไม่ต้องการ
---------------------------------------------------------
pcall(function()
    local effectContainer = ReplicatedStorage:FindFirstChild("Effect")
    if effectContainer and effectContainer:FindFirstChild("Container") then
        local container = effectContainer.Container
        local targets = {"LevelUp", "Hit", "Death", "Respawn", "ActivateAura", "Tushita"}
        for _, name in ipairs(targets) do
            local obj = container:FindFirstChild(name)
            if obj then
                if obj:IsA("Folder") or obj:IsA("Model") then
                    for _, child in ipairs(obj:GetChildren()) do
                        child:Destroy()
                    end
                end
                obj:Destroy()
            end
        end
        -- ปิด Chop.Punch
        if container:FindFirstChild("Chop") and container.Chop:FindFirstChild("Punch") then
            container.Chop.Punch.Enabled = false
        end
    end
end)

---------------------------------------------------------
-- 🔹 ลบ DamageCounter
---------------------------------------------------------
pcall(function()
    local damageCounter = ReplicatedStorage:FindFirstChild("Assets")
    if damageCounter then
        damageCounter = damageCounter:FindFirstChild("GUI")
        if damageCounter then
            damageCounter = damageCounter:FindFirstChild("DamageCounter")
            if damageCounter then
                damageCounter:Destroy()
            end
        end
    end
end)

---------------------------------------------------------
-- 🔹 ลบ Foam / Wave
---------------------------------------------------------
pcall(function()
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    if origin then
        local foam = origin:FindFirstChild("Foam;")
        if foam then
            for _, child in ipairs(foam:GetChildren()) do
                child:Destroy()
            end
        end
        for _, child in ipairs(origin:GetChildren()) do
            if child.Name:lower():find("wave") then
                child:Destroy()
            end
        end
    end
end)

---------------------------------------------------------
-- 🔹 Ignore List สำหรับ _WorldOrigin
---------------------------------------------------------
local ignorelist = {
    "BoatSpawns",
    "FruitSpawns",
    "InteractiveEffects",
    "LightingZones",
    "LightningCache",
    "PermanentCampfires",
    "PlayerAccessoriesProxy",
    "PlayerSpawns",
    "SafeZones",
    "SubmarineLocations",
    "Tests",
    "Effect",
    "EnemyRegions",
    "EnemySpawns",
    "Locations",
    "PersistentParts",
    "SkinnedCylinders",
    "AshEmitterPart",
    "Foam;",
    "RainEmitterPart",
    "SnowEmitterPart"
}

local ignoreHash = {}
for _, name in ipairs(ignorelist) do
    ignoreHash[name] = true
end

-- ลบไฟล์ทันทีเมื่อมีไฟล์ใหม่ (ยกเว้นใน ignore list)
pcall(function()
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    if origin then
        origin.ChildAdded:Connect(function(child)
            if not ignoreHash[child.Name] then
                task.spawn(function()
                    child:Destroy()
                end)
            end
        end)

        -- ลบไฟล์ที่มีอยู่แล้ว
        for _, child in ipairs(origin:GetChildren()) do
            if not ignoreHash[child.Name] then
                child:Destroy()
            end
        end

        -- Loop ตรวจสอบแบบเร็ว
        task.spawn(function()
            while true do
                for _, child in ipairs(origin:GetChildren()) do
                    if not ignoreHash[child.Name] then
                        child:Destroy()
                    end
                end
                task.wait()
            end
        end)
    end
end)

---------------------------------------------------------
-- 🔹 ลบ FX ทั้งหมด และลบอัตโนมัติเมื่อโผล่มาใหม่
---------------------------------------------------------
pcall(function()
    local fxFolder = ReplicatedStorage:FindFirstChild("FX")
    if fxFolder then
        -- ลบ FX ที่มีอยู่แล้ว
        for _, child in ipairs(fxFolder:GetChildren()) do
            child:Destroy()
        end

        -- ลบ FX อัตโนมัติเมื่อมีตัวใหม่ถูกเพิ่ม
        fxFolder.ChildAdded:Connect(function(newChild)
            task.spawn(function()
                newChild:Destroy()
            end)
        end)
    end
end)


---------------------------------------------------------
-- 🔹 ปิด WeaponAssetCache
---------------------------------------------------------
pcall(function()
    local weaponCache = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("WeaponAssetCache")
    if weaponCache then
        weaponCache.Enabled = false
    end
end)

---------------------------------------------------------
-- 🔹 ฟังก์ชันทำโปร่งใส (ตอนนี้รวมทั้งตัวเราและผู้เล่นคนอื่น)
---------------------------------------------------------
local function makeTransparentSafe(object: Instance)
    if not object then return end
    pcall(function()
        if object:IsA("BasePart") then
            object.Transparency = 1
            object.Material = Enum.Material.Plastic
            object.Reflectance = 0
            object.CastShadow = false
        elseif object:IsA("Decal") then
            object.Transparency = 1
        elseif object:IsA("ParticleEmitter") or
               object:IsA("Beam") or
               object:IsA("Fire") or
               object:IsA("Smoke") or
               object:IsA("Sparkles") or
               object:IsA("Trail") then
            object.Enabled = false
        elseif object:IsA("Light") then
            object.Enabled = false
        elseif object:IsA("Folder") or object:IsA("Model") then
            for _, child in ipairs(object:GetChildren()) do
                makeTransparentSafe(child)
            end
        elseif object:IsA("BillboardGui") or object:IsA("SurfaceGui") then
            object.Enabled = false
        elseif object:IsA("TextLabel") or object:IsA("ImageLabel") or object:IsA("ImageButton") then
            object.Visible = false
        end
    end)
end

---------------------------------------------------------
-- 🔹 ทำตัวละครผู้เล่นทุกคนโปร่งใส + อัพเดตเมื่อผู้เล่นใหม่เข้ามา
---------------------------------------------------------
local function handleCharacter(character: Model)
    makeTransparentSafe(character)
    -- เช็ค ChildAdded ใน Character เผื่อมีสิ่งใหม่โผล่มา
    character.DescendantAdded:Connect(function(desc)
        makeTransparentSafe(desc)
    end)
end

-- ตัวละครเรา
if localPlayer.Character then
    handleCharacter(localPlayer.Character)
end
localPlayer.CharacterAdded:Connect(handleCharacter)

-- ตัวละครผู้เล่นอื่น
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer and player.Character then
        handleCharacter(player.Character)
    end
    player.CharacterAdded:Connect(function(char)
        handleCharacter(char)
    end)
end

-- ตรวจสอบผู้เล่นใหม่เข้ามา
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        handleCharacter(char)
    end)
end)


---------------------------------------------------------
-- 🔹 Map / FishingLeaderboard / Arena โปร่งใส
---------------------------------------------------------
local function safeHandleFolder(folder)
    if folder then
        makeTransparentSafe(folder)
    end
end

safeHandleFolder(Workspace:FindFirstChild("Map"))
safeHandleFolder(Workspace:FindFirstChild("FishingLeaderboard"))
if Workspace:FindFirstChild("Arena's") then
    safeHandleFolder(Workspace["Arena's"]:FindFirstChild("FishSlapArena2"))
end

---------------------------------------------------------
-- 🔹 ลบ child ของ NPC แต่คงไว้ Humanoid, HRP, Head
---------------------------------------------------------
local function clearNPCKeepChildNPC(npc: Model)
    pcall(function()
        for _, child in ipairs(npc:GetChildren()) do
            if not (child:IsA("Humanoid")
                or child.Name == "HumanoidRootPart"
                or child.Name == "Head") then
                child:Destroy()
            end
        end
    end)
end

pcall(function()
    local npcsFolder = Workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, npc in ipairs(npcsFolder:GetChildren()) do
            if npc:IsA("Model") then
                clearNPCKeepChildNPC(npc)
            end
        end
        npcsFolder.ChildAdded:Connect(function(newNPC)
            if newNPC:IsA("Model") then
                clearNPCKeepChildNPC(newNPC)
            end
        end)
    end
end)

---------------------------------------------------------
-- 🔹 Descendant ใหม่ทำโปร่งใสอัตโนมัติ
---------------------------------------------------------
Workspace.DescendantAdded:Connect(function(desc)
    pcall(function()
        if localPlayer and localPlayer.Character and desc:IsDescendantOf(localPlayer.Character) then
            return
        end
        makeTransparentSafe(desc)
    end)
end)

print("Blox Fruits optimizer applied: Notifications, FX, Effect.Container, WeaponAssetCache removed/disabled, NPC cleared, map transparent.")
