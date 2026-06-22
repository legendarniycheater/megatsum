-- ============================================================
-- TSUM ESP + AUTOLOOT [КРЯКНУТАЯ ВЕРСИЯ]
-- БЕЗ КЛЮЧЕЙ, БЕЗ АКТИВАЦИИ, БЕЗ ОГРАНИЧЕНИЙ
-- ============================================================

-- ============================================================
-- БЛОК 1: СИСТЕМА КОНФИГОВ
-- ============================================================

local ConfigSystem = {
    SaveName = "TsumConfig",
    CurrentConfig = {},
    DefaultConfig = {
        ESP = {
            Enabled = false,
            ScanDropped = false,
            ScanDroppedColor = {R = 255, G = 220, B = 50},
            ShowName = false,
            NameSize = 10,
            ShowDistance = false,
            DistanceSize = 10,
            ShowPrice = false,
            PriceSize = 10,
            ShowSpawn = false,
            SpawnSize = 10,
            OffscreenEnabled = false,
            RenderDistEnabled = false,
            RenderDist = 100,
            ChamsEnabled = false,
            ChamsColor = {R = 255, G = 255, B = 255},
            ChamsTransparency = 0.5,
            FilterByChance = false,
            MaxChance = 0.20
        },
        Rarities = {
            Common = { Enabled = false, Color = {R = 180, G = 180, B = 180} },
            Uncommon = { Enabled = false, Color = {R = 80, G = 200, B = 80} },
            Rare = { Enabled = false, Color = {R = 80, G = 150, B = 255} },
            Epic = { Enabled = false, Color = {R = 180, G = 80, B = 255} },
            Legendary = { Enabled = true, Color = {R = 255, G = 180, B = 0} }
        },
        Sort = {
            Enabled = false
        },
        Style = {
            CustomEnabled = false,
            Mode = "Normal"
        },
        AutoLoot = {
            Enabled = false,
            Range = 10
        },
        Speed = {
            Enabled = false
        },
        CFLY = {
            Enabled = false,
            Speed = 50
        },
        NameTag = {
            BadgesEnabled = false,
            AllBadges = true,
            BadgeSize = 28,
            BadgeSpacing = 3,
            StudsOffset = {X = 0, Y = 4.5, Z = 0}
        },
        Keybinds = {
            GUIBind = "Insert"
        }
    }
}

-- Функция для конвертации Color3 в таблицу
local function color3ToTable(color)
    return {R = color.R * 255, G = color.G * 255, B = color.B * 255}
end

-- Функция для конвертации таблицы в Color3
local function tableToColor3(t)
    return Color3.fromRGB(t.R, t.G, t.B)
end

-- Функция для глубокого копирования таблицы
local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Функция для рекурсивного обновления конфига
local function mergeConfigs(base, override)
    local result = deepCopy(base)
    for k, v in pairs(override) do
        if type(v) == "table" and type(base[k]) == "table" then
            result[k] = mergeConfigs(base[k], v)
        else
            result[k] = v
        end
    end
    return result
end

-- Сохранение конфига
function ConfigSystem:Save()
    local success, err = pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(self.CurrentConfig)
        writefile(self.SaveName .. ".json", json)
    end)
    if not success then
        warn("[TSUM] Не удалось сохранить конфиг: " .. tostring(err))
    end
end

-- Загрузка конфига
function ConfigSystem:Load()
    local success, data = pcall(function()
        return readfile(self.SaveName .. ".json")
    end)
    
    if success and data then
        local decoded = game:GetService("HttpService"):JSONDecode(data)
        if decoded then
            self.CurrentConfig = mergeConfigs(self.DefaultConfig, decoded)
            return true
        end
    end
    self.CurrentConfig = deepCopy(self.DefaultConfig)
    return false
end

-- Сброс конфига
function ConfigSystem:Reset()
    self.CurrentConfig = deepCopy(self.DefaultConfig)
    self:Save()
end

-- Загрузка конфига при старте
ConfigSystem:Load()

-- ============================================================
-- БЛОК 2: ПОЛУЧЕНИЕ СЕРВИСОВ
-- ============================================================

local cloneref = cloneref or clonereference or function(instance) return instance end

local HttpService = cloneref(game:GetService("HttpService"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))
local TweenService = cloneref(game:GetService("TweenService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local ContextActionService = cloneref(game:GetService("ContextActionService"))

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do task.wait(0.1) LocalPlayer = Players.LocalPlayer end

local Camera = Workspace.CurrentCamera

-- ============================================================
-- БЛОК 3: ЗАГРУЗКА WINDUI (ГРАФИЧЕСКИЙ ИНТЕРФЕЙС)
-- ============================================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- ============================================================
-- БЛОК 4: КОНФИГУРАЦИЯ (ВСЕ ФУНКЦИИ РАЗБЛОКИРОВАНЫ)
-- ============================================================

local Config = ConfigSystem.CurrentConfig
local WindowVisible = true

-- ============================================================
-- БЛОК 5: ЗАГРУЗКА БАЗ ДАННЫХ ПРЕДМЕТОВ
-- ============================================================

local MeshMap = {}
local NameMap = {}

local function FetchDatabases()
    -- Основная база предметов
    local MAIN_DB_URL = "https://raw.githubusercontent.com/awaky1337/base/refs/heads/main/database.lua"
    local s1, mainRaw = pcall(function() return game:HttpGet(MAIN_DB_URL) end)
    local db = nil
    
    if (s1 and mainRaw) then
        local func = loadstring(mainRaw)
        db = func and func()
    end
    
    if (not db or (type(db.Items) ~= "table")) then
        db = { Items = { Shirt = {}, Pants = {} } }
    end
    
    -- База аксессуаров
    local ACCS_URL = "https://raw.githubusercontent.com/awaky1337/base/refs/heads/main/accs_db"
    local s2, accsRaw = pcall(function() return game:HttpGet(ACCS_URL) end)
    local accessories = {}
    
    if (s2 and accsRaw) then
        accsRaw = string.gsub(accsRaw, '\\"', '"')
        local func = loadstring("return {" .. accsRaw .. "}")
        local accsData = (func and func()) or {}
        accessories = accsData.Accessory or {}
    end
    
    -- Обработка аксессуаров
    for _, item in ipairs(accessories) do
        if (item.meshId and (item.meshId ~= "")) then
            local mId = item.meshId:lower()
            mId = string.gsub(mId, "\\", "")
            if not MeshMap[mId] then MeshMap[mId] = {} end
            table.insert(MeshMap[mId], item)
        else
            NameMap[item.name:lower()] = item
        end
    end
    
    -- Обработка одежды
    for _, category in ipairs({"Shirt", "Pants"}) do
        if db.Items[category] then
            for _, item in ipairs(db.Items[category]) do
                item.accessoryType = category
                local added = false
                for _, key in ipairs({"meshId", "templateId", "textureId"}) do
                    if (item[key] and (item[key] ~= "")) then
                        local kId = item[key]:lower()
                        kId = string.gsub(kId, "\\", "")
                        if not MeshMap[kId] then MeshMap[kId] = {} end
                        table.insert(MeshMap[kId], item)
                        added = true
                    end
                end
                if not added then
                    NameMap[item.name:lower()] = item
                end
            end
        end
    end
end

-- ============================================================
-- БЛОК 6: ОСНОВНАЯ СИСТЕМА ESP
-- ============================================================

local CachedItems = {}
local coreGui = game:GetService("CoreGui")

-- Создание GUI для ESP
local espGui = coreGui:FindFirstChild("TsumESP")
if espGui then espGui:Destroy() end
espGui = Instance.new("ScreenGui")
espGui.Name = "TsumESP"
espGui.Parent = coreGui

-- Создание папки для Highlight (подсветка)
local hlFolder = coreGui:FindFirstChild("TsumHighlights")
if hlFolder then hlFolder:Destroy() end
hlFolder = Instance.new("Folder")
hlFolder.Name = "TsumHighlights"
hlFolder.Parent = coreGui

-- Пул Highlight объектов (максимум 31)
local HighlightPool = {}
for i = 1, 31 do
    local hl = Instance.new("Highlight")
    hl.Enabled = false
    hl.Parent = hlFolder
    table.insert(HighlightPool, hl)
end

-- ============================================================
-- ФУНКЦИИ ДОБАВЛЕНИЯ/УДАЛЕНИЯ ПРЕДМЕТОВ В КЭШ
-- ============================================================

local function AddItemToCache(obj)
    if not obj then return end
    
    local droppedFolder = Workspace:FindFirstChild("DroppedItems")
    local isInDropped = false
    local inShopZone = false
    
    local ancestor = obj
    while ancestor and (ancestor ~= Workspace) and (ancestor ~= game) do
        if (ancestor:IsA("Model") and Players:GetPlayerFromCharacter(ancestor)) then
            return -- Игнорируем игроков
        end
        if (droppedFolder and (ancestor == droppedFolder)) then
            isInDropped = true
        end
        if (string.find(ancestor.Name, "Shop_ShopZone_") == 1) then
            inShopZone = true
        end
        ancestor = ancestor.Parent
    end
    
    if (not isInDropped and not inShopZone) then return end
    if (isInDropped and not Config.ESP.ScanDropped) then return end
    
    local detectedItem = nil
    local possibleIds = {}
    
    -- Функция сбора ID из объекта
    local function addId(instance)
        if (instance:IsA("MeshPart") or instance:IsA("SpecialMesh")) then
            if (instance.MeshId ~= "") then
                table.insert(possibleIds, instance.MeshId:lower())
            end
        elseif instance:IsA("Shirt") then
            if (instance.ShirtTemplate ~= "") then
                table.insert(possibleIds, instance.ShirtTemplate:lower())
            end
        elseif instance:IsA("Pants") then
            if (instance.PantsTemplate ~= "") then
                table.insert(possibleIds, instance.PantsTemplate:lower())
            end
        elseif instance:IsA("ShirtGraphic") then
            if (instance.Graphic ~= "") then
                table.insert(possibleIds, instance.Graphic:lower())
            end
        elseif instance:IsA("Decal") then
            if (instance.Texture ~= "") then
                table.insert(possibleIds, instance.Texture:lower())
            end
        end
    end
    
    -- Сбор ID из объекта и его потомков
    if obj:IsA("Model") then
        for _, child in ipairs(obj:GetDescendants()) do
            addId(child)
        end
    else
        addId(obj)
    end
    
    -- Поиск предмета по ID
    for _, rawId in ipairs(possibleIds) do
        local mId = string.gsub(rawId, "\\", "")
        local numberMatch = string.match(mId, "%d+")
        local possibleItems = nil
        
        for key, items in pairs(MeshMap) do
            if ((key == mId) or (string.match(key, "%d+") == numberMatch)) then
                possibleItems = items
                break
            end
        end
        
        if possibleItems then
            if (#possibleItems == 1) then
                detectedItem = possibleItems[1]
                break
            else
                local objName = obj.Name:lower()
                local parentName = (obj.Parent and obj.Parent.Name:lower()) or ""
                for _, item in ipairs(possibleItems) do
                    local iName = item.name:lower()
                    if ((objName == iName) or (parentName == iName) or string.find(parentName, iName, 1, true)) then
                        detectedItem = item
                        break
                    end
                end
                if not detectedItem then
                    detectedItem = possibleItems[1]
                end
                break
            end
        end
    end
    
    -- Поиск по имени, если не найден по ID
    if not detectedItem then
        local n = obj.Name:lower()
        if NameMap[n] then
            detectedItem = NameMap[n]
        end
    end
    
    if detectedItem then
        local posType = 0
        local position = nil
        
        if obj:IsA("BasePart") then
            posType = 1
            position = obj.Position
        elseif obj:IsA("Model") then
            if obj.PrimaryPart then
                posType = 2
                position = obj.PrimaryPart.Position
            else
                posType = 3
                position = obj:GetPivot().Position
            end
        end
        
        if not position then return end
        
        -- Проверка на дубликаты поблизости
        for existingObj, cacheData in pairs(CachedItems) do
            if (cacheData.Data and (cacheData.Data.name == detectedItem.name) and cacheData.Position) then
                if ((cacheData.Position - position).Magnitude < 5) then
                    return
                end
            end
        end
        
        -- Создание текстовой метки
        local textLabel = Instance.new("TextLabel")
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.ArialBold
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.RichText = true
        textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        textLabel.AutomaticSize = Enum.AutomaticSize.XY
        textLabel.Visible = false
        textLabel.Parent = espGui
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Parent = textLabel
        
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 0
        gradient.Parent = textLabel
        
        local drawings = {
            Label = textLabel,
            Gradient = gradient,
            OffArrow = nil
        }
        
        -- Поиск целевой модели для Highlight
        local targetMesh = obj
        local mannequin = nil
        
        if (obj.Name == "Mannequin") then
            mannequin = obj
        elseif obj:FindFirstChild("Mannequin") then
            mannequin = obj:FindFirstChild("Mannequin")
        elseif (obj.Parent and obj.Parent:FindFirstChild("Mannequin")) then
            mannequin = obj.Parent:FindFirstChild("Mannequin")
        elseif (obj.Parent and obj.Parent.Parent and obj.Parent.Parent:FindFirstChild("Mannequin")) then
            mannequin = obj.Parent.Parent:FindFirstChild("Mannequin")
        end
        
        if mannequin then
            targetMesh = mannequin
        elseif obj:IsA("Model") then
            local found = false
            for _, child in ipairs(obj:GetDescendants()) do
                if (child:IsA("MeshPart") or (child:IsA("Part") and child:FindFirstChildOfClass("SpecialMesh"))) then
                    targetMesh = child
                    found = true
                    break
                end
            end
            if (not found and obj.PrimaryPart) then
                targetMesh = obj.PrimaryPart
            end
        end
        
        CachedItems[obj] = {
            Data = detectedItem,
            Drawings = drawings,
            TargetMesh = targetMesh,
            PosType = posType,
            Position = position,
            IsDropped = isInDropped
        }
    end
end

local function RemoveItemFromCache(obj)
    if CachedItems[obj] then
        if CachedItems[obj].Drawings.Label then
            pcall(function() CachedItems[obj].Drawings.Label:Destroy() end)
        end
        if CachedItems[obj].Drawings.OffArrow then
            pcall(function() CachedItems[obj].Drawings.OffArrow:Destroy() end)
        end
        CachedItems[obj] = nil
    end
end

-- ============================================================
-- ИНИЦИАЛИЗАЦИЯ ESP
-- ============================================================

local DBReady = false
local ESPReady = false

task.spawn(function()
    FetchDatabases()
    DBReady = true
end)

task.spawn(function()
    while not DBReady do task.wait(0.1) end
    
    Workspace.DescendantAdded:Connect(function(obj)
        AddItemToCache(obj)
    end)
    
    Workspace.DescendantRemoving:Connect(RemoveItemFromCache)
    
    local objsToScan = {}
    for _, child in ipairs(Workspace:GetChildren()) do
        if ((child.Name == "DroppedItems") or (string.find(child.Name, "Shop_ShopZone_") == 1)) then
            table.insert(objsToScan, child)
            for _, desc in ipairs(child:GetDescendants()) do
                table.insert(objsToScan, desc)
            end
        end
    end
    
    for i, obj in ipairs(objsToScan) do
        AddItemToCache(obj)
        if ((i % 50) == 0) then
            task.wait()
        end
    end
    
    ESPReady = true
end)

-- ============================================================
-- БЛОК 7: ГРАФИЧЕСКИЙ ИНТЕРФЕЙС (GUI)
-- ============================================================

local Window = WindUI:CreateWindow({
    Title = "Script Tsum Colaba [КРЯК]",
    Folder = "ScriptTsumGui",
    Icon = "solar:folder-2-bold-duotone",
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "Open GUI",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(Color3.fromHex("#30FF6A"), Color3.fromHex("#e7ff2f"))
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac"
    },
    Acrylic = false
})

-- Функция для синхронизации конфига с GUI
local function syncConfigToGUI()
    Config = ConfigSystem.CurrentConfig
end

-- Функция для сохранения конфига после изменений
local function saveConfig()
    ConfigSystem:Save()
end

-- === ВКЛАДКА ESP ===
local ESPTab = Window:Tab({
    Title = "ESP",
    Desc = "ESP settings and display",
    Icon = "solar:eye-bold",
    Border = true
})

-- === ВКЛАДКА MISC ===
local MiscTab = Window:Tab({
    Title = "Misc",
    Desc = "Miscellaneous settings",
    Icon = "solar:hamburger-menu-bold",
    Border = true
})

-- === ВКЛАДКА AUTOLOOT ===
local AutoLootTab = Window:Tab({
    Title = "Autoloot",
    Desc = "Auto pickup settings",
    Icon = "solar:cursor-square-bold",
    Border = true
})

-- === ВКЛАДКА SETTINGS ===
local SettingsTab = Window:Tab({
    Title = "Settings",
    Desc = "Menu and appearance",
    Icon = "solar:folder-with-files-bold",
    Border = true
})

-- ============================================================
-- НАСТРОЙКИ ESP
-- ============================================================

local GlobalSection = ESPTab:Section({
    Title = "Global Settings",
    Box = true,
    Opened = true
})

GlobalSection:Toggle({
    Title = "Enable ESP",
    Value = Config.ESP.Enabled,
    Callback = function(v) 
        Config.ESP.Enabled = v
        saveConfig()
    end
})

GlobalSection:Space()

GlobalSection:Toggle({
    Title = "Dropped Items ESP",
    Value = Config.ESP.ScanDropped,
    Callback = function(v) 
        Config.ESP.ScanDropped = v
        saveConfig()
    end
})

GlobalSection:Colorpicker({
    Title = "Dropped Items Color",
    Default = tableToColor3(Config.ESP.ScanDroppedColor),
    Callback = function(c) 
        Config.ESP.ScanDroppedColor = color3ToTable(c)
        saveConfig()
    end
})

GlobalSection:Space()

GlobalSection:Toggle({
    Title = "Render Distance Limit",
    Value = Config.ESP.RenderDistEnabled,
    Callback = function(v) 
        Config.ESP.RenderDistEnabled = v
        saveConfig()
    end
})

GlobalSection:Slider({
    Title = "Render Distance (m)",
    Step = 1,
    Value = { Min = 10, Max = 200, Default = Config.ESP.RenderDist },
    Callback = function(v) 
        Config.ESP.RenderDist = v
        saveConfig()
    end
})

ESPTab:Space()

-- === НАСТРОЙКИ ОТОБРАЖЕНИЯ ===
local DisplaySection = ESPTab:Section({
    Title = "Display",
    Box = true,
    Opened = true
})

DisplaySection:Toggle({
    Title = "Show Chams",
    Value = Config.ESP.ChamsEnabled,
    Callback = function(v) 
        Config.ESP.ChamsEnabled = v
        saveConfig()
    end
})

DisplaySection:Colorpicker({
    Title = "Chams Color",
    Default = tableToColor3(Config.ESP.ChamsColor),
    Callback = function(c) 
        Config.ESP.ChamsColor = color3ToTable(c)
        saveConfig()
    end
})

DisplaySection:Slider({
    Title = "Chams Transparency",
    Step = 1,
    Value = { Min = 0, Max = 100, Default = math.floor(Config.ESP.ChamsTransparency * 100) },
    Callback = function(v) 
        Config.ESP.ChamsTransparency = v / 100
        saveConfig()
    end
})

DisplaySection:Space()

-- Функция добавления переключателей для отображения
local function AddDisplayToggleWithSize(title, stateKey, sizeKey, defaultSize)
    DisplaySection:Toggle({
        Title = title,
        Value = true,
        Callback = function(v) 
            Config.ESP[stateKey] = v
            saveConfig()
        end
    })
    DisplaySection:Slider({
        Title = title .. " Size",
        Step = 1,
        Value = { Min = 8, Max = 40, Default = defaultSize },
        Callback = function(v) 
            Config.ESP[sizeKey] = v
            saveConfig()
        end
    })
    DisplaySection:Space()
end

AddDisplayToggleWithSize("Show Name", "ShowName", "NameSize", 10)
AddDisplayToggleWithSize("Show Distance", "ShowDistance", "DistanceSize", 10)
AddDisplayToggleWithSize("Show Price", "ShowPrice", "PriceSize", 10)
AddDisplayToggleWithSize("Show Spawn Chance", "ShowSpawn", "SpawnSize", 10)

ESPTab:Space()

-- === ФИЛЬТРЫ ПО РЕДКОСТИ ===
local RaritySection = ESPTab:Section({
    Title = "Rarity Filters",
    Box = true,
    Opened = true
})

RaritySection:Toggle({
    Title = "Legendary",
    Value = Config.Rarities.Legendary.Enabled,
    Callback = function(v) 
        Config.Rarities.Legendary.Enabled = v
        saveConfig()
    end
})

RaritySection:Colorpicker({
    Title = "Legendary Color",
    Default = tableToColor3(Config.Rarities.Legendary.Color),
    Callback = function(c) 
        Config.Rarities.Legendary.Color = color3ToTable(c)
        saveConfig()
    end
})

ESPTab:Space()

-- === ФИЛЬТР ПО ШАНСУ ===
local FilterSection = ESPTab:Section({
    Title = "Filter by Chance",
    Box = true,
    Opened = true
})

FilterSection:Toggle({
    Title = "Enable Filter",
    Value = Config.Sort.Enabled,
    Callback = function(v) 
        Config.Sort.Enabled = v
        saveConfig()
    end
})

FilterSection:Space()

FilterSection:Toggle({
    Title = "Filter by Chance",
    Value = Config.ESP.FilterByChance,
    Callback = function(v) 
        Config.ESP.FilterByChance = v
        saveConfig()
    end
})

FilterSection:Slider({
    Title = "Max Chance",
    Step = 0.001,
    Value = { Min = 0.001, Max = 100, Default = Config.ESP.MaxChance },
    Callback = function(v) 
        Config.ESP.MaxChance = v
        saveConfig()
    end
})

-- ============================================================
-- НАСТРОЙКИ MISC
-- ============================================================

-- === СКОРОСТЬ ПЕРСОНАЖА (ТОЛЬКО ВКЛ/ВЫКЛ) ===
local SpeedSection = MiscTab:Section({
    Title = "Скорость персонажа",
    Box = true,
    Opened = true
})

SpeedSection:Toggle({
    Title = "Включить ускорение",
    Value = Config.Speed.Enabled,
    Callback = function(v)
        Config.Speed.Enabled = v
        saveConfig()
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                if v then
                    humanoid.WalkSpeed = 33
                else
                    humanoid.WalkSpeed = 16
                end
            end
        end
    end
})

-- Система скорости (только вкл/выкл)
local function setupSpeed(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    if Config.Speed.Enabled then
        humanoid.WalkSpeed = 33
    end
    
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Config.Speed.Enabled and humanoid.WalkSpeed ~= 33 then
            humanoid.WalkSpeed = 33
        end
    end)
end

if LocalPlayer.Character then
    setupSpeed(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(setupSpeed)

MiscTab:Space()

-- === CFLY (СВОБОДНАЯ КАМЕРА) ===
local CFLYSection = MiscTab:Section({
    Title = "CFLY (Свободная камера)",
    Box = true,
    Opened = true
})

local freecamEnabled = Config.CFLY.Enabled
local freecamSpeed = Config.CFLY.Speed
local freecamConnection = nil
local originalCamera = nil
local freecamPart = nil
local freecamCFrame = nil

local function toggleFreecam(enabled)
    freecamEnabled = enabled
    Config.CFLY.Enabled = enabled
    saveConfig()
    
    if enabled then
        -- Сохраняем оригинальную камеру
        originalCamera = Camera.CFrame
        
        -- Создаем невидимую часть для камеры
        freecamPart = Instance.new("Part")
        freecamPart.Anchored = true
        freecamPart.CanCollide = false
        freecamPart.Transparency = 1
        freecamPart.Size = Vector3.new(1, 1, 1)
        freecamPart.Parent = Workspace
        
        -- Устанавливаем камеру на позицию игрока
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            freecamPart.CFrame = hrp.CFrame
        else
            freecamPart.CFrame = CFrame.new(Vector3.new(0, 10, 0))
        end
        
        freecamCFrame = freecamPart.CFrame
        
        -- Отключаем стандартный контроль камеры
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = freecamPart.CFrame
        
        -- Включаем захват мыши для вращения камеры
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        
        -- Основной цикл свободной камеры
        freecamConnection = RunService.RenderStepped:Connect(function()
            if not freecamEnabled or not freecamPart then return end
            
            local moveDirection = Vector3.new(0, 0, 0)
            local forward = freecamCFrame.LookVector
            local right = freecamCFrame.RightVector
            local up = freecamCFrame.UpVector
            
            -- Управление WASD + пробел/Shift
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + forward
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - forward
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - right
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + right
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + up
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - up
            end
            
            -- Вращение камеры мышью
            local mouseDelta = UserInputService:GetMouseDelta()
            local sensitivity = 0.002
            
            if mouseDelta.X ~= 0 or mouseDelta.Y ~= 0 then
                local yaw = -mouseDelta.X * sensitivity
                local pitch = -mouseDelta.Y * sensitivity
                
                freecamCFrame = freecamCFrame * CFrame.Angles(0, yaw, 0)
                freecamCFrame = freecamCFrame * CFrame.Angles(pitch, 0, 0)
            end
            
            -- Движение
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * freecamSpeed
                local newPos = freecamCFrame.Position + moveDirection
                freecamCFrame = CFrame.new(newPos, newPos + freecamCFrame.LookVector)
            end
            
            -- Обновляем позицию части и камеры
            freecamPart.CFrame = freecamCFrame
            Camera.CFrame = freecamCFrame
        end)
        
    else
        -- Восстанавливаем камеру
        Camera.CameraType = Enum.CameraType.Custom
        
        if freecamPart then
            freecamPart:Destroy()
            freecamPart = nil
        end
        
        if freecamConnection then
            freecamConnection:Disconnect()
            freecamConnection = nil
        end
        
        -- Возвращаемся к игроку
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            Camera.CFrame = hrp.CFrame
        end
    end
end

CFLYSection:Toggle({
    Title = "Включить свободную камеру",
    Value = freecamEnabled,
    Callback = function(v)
        toggleFreecam(v)
    end
})

CFLYSection:Slider({
    Title = "Скорость камеры",
    Step = 1,
    Value = { Min = 5, Max = 200, Default = freecamSpeed },
    Callback = function(v)
        freecamSpeed = v
        Config.CFLY.Speed = v
        saveConfig()
    end
})

-- Подключаем к персонажу
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    if freecamEnabled then
        toggleFreecam(true)
    end
end)

-- ============================================================
-- АВТОМАТИЧЕСКИЙ ПОДБОР (AUTOLOOT)
-- ============================================================

local AutoPickup = {
    Enabled = false,
    Range = 10,
    Busy = false
}

local PickupSection = AutoLootTab:Section({
    Title = "Auto Pickup",
    Box = true,
    Opened = true
})

PickupSection:Toggle({
    Title = "Enable Auto Pickup",
    Value = Config.AutoLoot.Enabled,
    Callback = function(v) 
        Config.AutoLoot.Enabled = v
        AutoPickup.Enabled = v
        saveConfig()
    end
})

PickupSection:Slider({
    Title = "Pickup Range",
    Step = 1,
    Value = { Min = 5, Max = 50, Default = Config.AutoLoot.Range },
    Callback = function(v) 
        Config.AutoLoot.Range = v
        AutoPickup.Range = v
        saveConfig()
    end
})

-- Функция подбора предмета
local function doPickup(item)
    if AutoPickup.Busy then return end
    
    local torso = item:FindFirstChild("Torso")
    if not torso then return end
    
    local prompt = torso:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    AutoPickup.Busy = true
    local savedCF = hrp.CFrame
    
    task.wait(0.1)
    
    -- Телепортация к предмету
    local tweenIn = TweenService:Create(hrp, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = CFrame.new(torso.Position)
    })
    tweenIn:Play()
    task.wait(0.15)
    
    -- Активация ProximityPrompt
    if fireproximityprompt then
        pcall(fireproximityprompt, prompt)
    else
        pcall(function()
            prompt:InputHoldBegin()
            task.wait((prompt.HoldDuration or 0) + 0.05)
            prompt:InputHoldEnd()
        end)
    end
    
    tweenIn.Completed:Wait()
    task.wait(0.05)
    
    -- Возврат на исходную позицию
    local tweenOut = TweenService:Create(hrp, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = savedCF
    })
    tweenOut:Play()
    tweenOut.Completed:Wait()
    task.wait(0.35)
    
    AutoPickup.Busy = false
end

-- Цикл автоподбора
task.spawn(function()
    while true do
        task.wait(0.15)
        
        if (AutoPickup.Enabled and not AutoPickup.Busy) then
            local droppedFolder = Workspace:FindFirstChild("DroppedItems")
            
            if droppedFolder then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    for _, item in ipairs(droppedFolder:GetChildren()) do
                        local torso = item:FindFirstChild("Torso")
                        if torso then
                            local distance = (hrp.Position - torso.Position).Magnitude
                            if distance <= AutoPickup.Range then
                                task.spawn(doPickup, item)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- БЛОК 8: НАСТРОЙКИ МЕНЮ
-- ============================================================

local MenuSection = SettingsTab:Section({
    Title = "Menu",
    Box = true,
    Opened = true
})

local accentColor = Color3.fromHex("#30FF6A")
local isWaitingForKey = false

MenuSection:Colorpicker({
    Title = "Accent Color",
    Default = accentColor,
    Callback = function(c)
        accentColor = c
        Window:SetAccent(c)
    end
})

MenuSection:Space()

-- Бинд на открытие GUI с захватом клавиши
local guiBindButton = MenuSection:Button({
    Title = "Set GUI Keybind (Current: " .. Config.Keybinds.GUIBind .. ")",
    Color = Color3.fromHex("#3099FF"),
    Justify = "Center",
    Callback = function()
        if isWaitingForKey then return end
        isWaitingForKey = true
        guiBindButton.Title = "Press any key..."
        WindUI:Notify({
            Title = "Keybind",
            Content = "Press any key to set as GUI toggle",
            Duration = 3
        })
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = input.KeyCode.Name
                if keyName then
                    -- Сохраняем бинд
                    Config.Keybinds.GUIBind = keyName
                    saveConfig()
                    
                    -- Перепривязываем
                    ContextActionService:UnbindAction("ToggleGUI")
                    local key = Enum.KeyCode[keyName]
                    if key then
                        ContextActionService:BindAction("ToggleGUI", function(actionName, inputState, inputObject)
                            if inputState == Enum.UserInputState.Begin then
                                WindowVisible = not WindowVisible
                                Window:SetVisible(WindowVisible)
                            end
                        end, false, key)
                    end
                    
                    guiBindButton.Title = "Set GUI Keybind (Current: " .. keyName .. ")"
                    isWaitingForKey = false
                    connection:Disconnect()
                    
                    WindUI:Notify({
                        Title = "Keybind Set",
                        Content = "GUI keybind set to: " .. keyName,
                        Duration = 2
                    })
                end
            end
        end)
        
        -- Таймаут через 5 секунд
        task.delay(5, function()
            if isWaitingForKey then
                isWaitingForKey = false
                guiBindButton.Title = "Set GUI Keybind (Current: " .. Config.Keybinds.GUIBind .. ")"
                connection:Disconnect()
                WindUI:Notify({
                    Title = "Keybind",
                    Content = "Keybind setting timed out",
                    Duration = 2
                })
            end
        end)
    end
})

MenuSection:Space()

MenuSection:Button({
    Title = "Save Config",
    Color = Color3.fromHex("#30FF6A"),
    Justify = "Center",
    Callback = function()
        ConfigSystem:Save()
        WindUI:Notify({
            Title = "Config Saved",
            Content = "Configuration has been saved successfully!",
            Duration = 2
        })
    end
})

MenuSection:Space()

MenuSection:Button({
    Title = "Load Config",
    Color = Color3.fromHex("#3099FF"),
    Justify = "Center",
    Callback = function()
        ConfigSystem:Load()
        syncConfigToGUI()
        WindUI:Notify({
            Title = "Config Loaded",
            Content = "Configuration has been loaded successfully!",
            Duration = 2
        })
        Window:Destroy()
    end
})

MenuSection:Space()

MenuSection:Button({
    Title = "Reset Config",
    Color = Color3.fromHex("#FF4830"),
    Justify = "Center",
    Callback = function()
        ConfigSystem:Reset()
        syncConfigToGUI()
        WindUI:Notify({
            Title = "Config Reset",
            Content = "Configuration has been reset to defaults!",
            Duration = 2
        })
        Window:Destroy()
    end
})

MenuSection:Space()

MenuSection:Button({
    Title = "Destroy Window",
    Color = Color3.fromHex("#ff4830"),
    Justify = "Center",
    Callback = function()
        Window:Destroy()
    end
})

-- ============================================================
-- БЛОК 9: ОСНОВНОЙ ЦИКЛ ОТРИСОВКИ ESP
-- ============================================================

RunService.RenderStepped:Connect(function()
    if not ESPReady then return end
    
    local char = LocalPlayer.Character
    local hrpChar = char and char:FindFirstChild("HumanoidRootPart")
    local activeHighlights = 0
    
    -- Сброс Highlight'ов
    for _, hl in ipairs(HighlightPool) do
        hl.Enabled = false
    end
    
    for obj, cacheData in pairs(CachedItems) do
        local itemData = cacheData.Data
        local rarityState = Config.Rarities[itemData.rarity or "Common"]
        
        -- Скрываем все метки по умолчанию
        if cacheData.Drawings.Label then
            cacheData.Drawings.Label.Visible = false
        end
        
        -- Проверка на dropped
        local isDropped = cacheData.IsDropped
        if (isDropped == nil) then
            local droppedFolder = Workspace:FindFirstChild("DroppedItems")
            isDropped = false
            if droppedFolder then
                local p = obj.Parent
                while p do
                    if (p == droppedFolder) then
                        isDropped = true
                        break
                    end
                    p = p.Parent
                end
            end
            cacheData.IsDropped = isDropped
        end
        
        if not obj.Parent then
            continue
        end
        
        -- Фильтрация
        if isDropped then
            if not Config.ESP.ScanDropped then continue end
        else
            if (not Config.ESP.Enabled or not rarityState or not rarityState.Enabled) then
                continue
            end
            
            if Config.Sort.Enabled and Config.ESP.FilterByChance then
                if (not itemData.spawnChance or (itemData.spawnChance > Config.ESP.MaxChance)) then
                    continue
                end
            end
        end
        
        local activeColor = (isDropped and tableToColor3(Config.ESP.ScanDroppedColor)) or tableToColor3(rarityState.Color)
        
        -- Получение позиции
        local position
        if (cacheData.PosType == 1) then
            position = obj.Position
        elseif (cacheData.PosType == 2) then
            position = obj.PrimaryPart.Position
        elseif (cacheData.PosType == 3) then
            position = obj:GetPivot().Position
        else
            continue
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(position)
        
        if onScreen then
            -- Расчет смещения по Y
            local yOffset = 0
            if cacheData.TargetMesh then
                pcall(function()
                    if cacheData.TargetMesh:IsA("Model") then
                        yOffset = cacheData.TargetMesh:GetExtentsSize().Y / 2
                    elseif cacheData.TargetMesh:IsA("BasePart") then
                        yOffset = cacheData.TargetMesh.Size.Y / 2
                    end
                end)
            end
            
            local topPos, _ = Camera:WorldToViewportPoint(position + Vector3.new(0, yOffset + 0.5, 0))
            local baseZ = math.floor(10000 - pos.Z)
            
            -- Сбор информации для отображения
            local parts = {}
            
            if Config.ESP.ShowName then
                local nameText = (isDropped and ("DROP " .. itemData.name)) or itemData.name
                table.insert(parts, string.format('<font size="%d"><b>%s</b></font>', Config.ESP.NameSize, nameText))
            end
            
            if (Config.ESP.ShowPrice and itemData.fairPrice) then
                table.insert(parts, string.format('<font size="%d">%s$</font>', Config.ESP.PriceSize, tostring(itemData.fairPrice)))
            end
            
            local fullText = table.concat(parts, " ")
            
            local hrpChar = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local meters = (hrpChar and math.floor((hrpChar.Position - position).Magnitude * 0.28)) or 0
            
            if (Config.ESP.RenderDistEnabled and (meters > Config.ESP.RenderDist)) then
                cacheData.Drawings.Label.Visible = false
            else
                if (Config.ESP.ShowDistance and hrpChar) then
                    fullText = fullText .. string.format('\n<font size="%d" color="#FFFFFF">[%dm]</font>', Config.ESP.DistanceSize, meters)
                end
                
                if (Config.ESP.ShowSpawn and itemData.spawnChance) then
                    fullText = fullText .. string.format('\n<font size="%d" color="#FFFFFF">%s%%</font>', Config.ESP.SpawnSize, tostring(itemData.spawnChance))
                end
                
                cacheData.Drawings.Label.Text = fullText
                cacheData.Drawings.Label.Position = UDim2.new(0, topPos.X, 0, topPos.Y)
                cacheData.Drawings.Label.AnchorPoint = Vector2.new(0.5, 1)
                cacheData.Drawings.Label.ZIndex = baseZ
                
                -- Анимация градиента
                local gradAnimOffset = (tick() % 2) / 2
                cacheData.Drawings.Gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, activeColor),
                    ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, activeColor)
                })
                cacheData.Drawings.Gradient.Offset = Vector2.new(-1 + (gradAnimOffset * 2), 0)
                
                cacheData.Drawings.Label.Visible = true
                
                -- Chams (подсветка)
                if (Config.ESP.ChamsEnabled and (activeHighlights < 31)) then
                    activeHighlights = activeHighlights + 1
                    local hl = HighlightPool[activeHighlights]
                    hl.Adornee = cacheData.TargetMesh
                    hl.FillColor = tableToColor3(Config.ESP.ChamsColor)
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.FillTransparency = Config.ESP.ChamsTransparency
                    hl.OutlineTransparency = 0.2
                    hl.Enabled = true
                end
            end
        end
    end
end)

-- ============================================================
-- БЛОК 10: СИСТЕМА БЕЙДЖЕЙ (ОПЦИОНАЛЬНО)
-- ============================================================

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local badgeIcons = {
    Developer = "rbxassetid://10885640682",
    YouTube = "rbxassetid://1275974017",
    TikTok = "rbxassetid://137014429261024",
    Moderator = "rbxassetid://9209424449",
    Verify = "rbxassetid://138018675655074"
}

local badgeOrder = {"Developer", "YouTube", "TikTok", "Moderator", "Verify"}

local function injectBadges()
    task.wait(0.05)
    local originalTag = PlayerGui:FindFirstChild("LocalResellerNameTag")
    if not originalTag then return end
    
    local mainContainer = originalTag:FindFirstChild("MainContainer")
    if not mainContainer then return end
    
    local oldRow = mainContainer:FindFirstChild("CustomMenuBadges")
    if oldRow then oldRow:Destroy() end
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "CustomMenuBadges"
    iconFrame.BackgroundTransparency = 1
    iconFrame.LayoutOrder = 1
    
    local totalBadges = #badgeOrder
    local frameWidth = (totalBadges * 16) + ((totalBadges - 1) * 3)
    iconFrame.Size = UDim2.fromOffset(frameWidth, 18)
    iconFrame.Parent = mainContainer
    
    local iconList = Instance.new("UIListLayout", iconFrame)
    iconList.FillDirection = Enum.FillDirection.Horizontal
    iconList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    iconList.VerticalAlignment = Enum.VerticalAlignment.Center
    iconList.Padding = UDim.new(0, 3)
    
    for i, badgeName in ipairs(badgeOrder) do
        local icon = Instance.new("ImageLabel", iconFrame)
        icon.Name = "Icon_" .. badgeName
        icon.Size = UDim2.fromOffset(16, 16)
        icon.Image = badgeIcons[badgeName]
        icon.BackgroundTransparency = 1
        icon.ScaleType = Enum.ScaleType.Fit
        icon.LayoutOrder = i
    end
end

PlayerGui.ChildAdded:Connect(function(child)
    if (child.Name == "LocalResellerNameTag") then
        injectBadges()
    end
end)

-- === НАСТРОЙКИ НИКА ===
local BadgeSection = MiscTab:Section({
    Title = "Ник и Бейджи",
    Box = true,
    Opened = true
})

local currentNickText = ""

BadgeSection:Input({
    Title = "Новый ник",
    Placeholder = "Введите новый ник...",
    Callback = function(value)
        currentNickText = value
    end
})

BadgeSection:Button({
    Title = "Применить ник",
    Callback = function()
        local text = currentNickText
        if (text == "") then
            text = LocalPlayer.DisplayName or LocalPlayer.Name
        end
        LocalPlayer:SetAttribute("CustomNick", text)
        injectBadges()
    end
})

BadgeSection:Toggle({
    Title = "Включить RGB Ник",
    Value = false,
    Callback = function(v)
        if v then
            LocalPlayer:SetAttribute("NickMode", "Rainbow")
        else
            LocalPlayer:SetAttribute("NickMode", "Normal")
        end
        injectBadges()
    end
})

-- ============================================================
-- БЛОК 11: БИНД НА GUI (ПЕРВОНАЧАЛЬНАЯ НАСТРОЙКА)
-- ============================================================

local function setupGUIBind()
    local keyName = Config.Keybinds.GUIBind or "Insert"
    local key = Enum.KeyCode[keyName]
    if not key then
        key = Enum.KeyCode.Insert
        Config.Keybinds.GUIBind = "Insert"
        saveConfig()
    end
    
    ContextActionService:BindAction("ToggleGUI", function(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Begin then
            WindowVisible = not WindowVisible
            Window:SetVisible(WindowVisible)
        end
    end, false, key)
end

setupGUIBind()

-- ============================================================
-- ЗАВЕРШЕНИЕ
-- ============================================================

print("[TSUM] Крякнутая версия загружена! Все функции разблокированы.")
print("[TSUM] Конфиг загружен: " .. (ConfigSystem.CurrentConfig and "успешно" or "не удалось"))
WindUI:Notify({
    Title = "Script Tsum [КРЯК]",
    Content = "Все функции разблокированы! Бинд: " .. Config.Keybinds.GUIBind,
    Duration = 4
})
