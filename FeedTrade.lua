-- ============================================================
--  FEED & FUSE → TRADE SCRIPT
-- ============================================================
local router = nil

repeat
    for i, v in next, getgc(true) do
        if type(v) == "table" and rawget(v, "get_remote_from_cache") then
            router = v
            break
        end
    end
    if not router then
        print("⏳ Router retrying...")
        task.wait(1)
    end
until router ~= nil

print("✅ Router found!")

local function rename(remotename, hashedremote)
    hashedremote.Name = remotename
end

table.foreach(debug.getupvalue(router.get_remote_from_cache, 1), rename)
print("Done rename")

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerName        = Players.LocalPlayer.Name

-- ── CONFIG ───────────────────────────────────────────────────
local PET_RARITY     = 7
local TRADE_LIMIT    = 18
local TRADE_COOLDOWN = 5

-- You can put EITHER the kind (e.g. "sugarfest_2026_dark_choccybunny")
-- OR the display name (e.g. "Dark Choccybunny") — both will work
local TARGET_PET_NAMES = {
    "Violet Friend",
    "Sunflower Friend",
    "Pilot Gull",
    "Gecko Ducky"
    -- "Dark Choccybunny",
    -- "White Choccybunny",
    -- "Milk Choccybunny",
    -- "Gummy Guana"
    -- "Pupcake",
    -- "Easter Bunny",
    -- "Candicorn",
    -- "Munchkin Cat",
    -- "Latte Kitsune",
    -- "sugarfest_2026_dark_choccybunny",  -- kind also works
    -- "Latte Kitsune",
    -- "Pupcake",
}

local RUN_FEED_NORMAL = true 
local RUN_FUSE_NORMAL = true
local RUN_FEED_NEON   = true
local RUN_FUSE_NEON   = true
local RUN_TRADE       = true
print("Done TARGET")
local allowedRotation = {
    { name = "GriffinzKQnY", mode = { "mega_neon", "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 800 },
    -- { name = "PenelopeFrostAlpha43", mode = { "normal_under6" }, maxAmount = 2000 },
    -- { name = "bubblerice1", mode = { "mega_neon", "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 999999999 },
    -- { name = "NoraPixel437", mode = { "neon_under6", "neon_full", "normal_full" }, maxAmount = 99999999 },
    -- { name = "Upton0JO9z", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "Xandra7TBWOB", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "AdenaJ5CoY8", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "NicoyiVW4", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "KentarozjbRTU", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "RendaDGGRh2", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "HazelKcFAD", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "Lionel73IKwt", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "TannerzHGPGo", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "AneliaN3MMC", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "ChesterdD8B7n", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "RusdiEHCTi", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "Johanna9Roc8I", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "YannBVklz", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "Carter_Light861", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },
    -- { name = "ParisaHX7QsR", mode = { "neon_under6", "neon_full", "normal_full", "normal_under6" }, maxAmount = 120 },


}
-- ─────────────────────────────────────────────────────────────

-- ── API refs ─────────────────────────────────────────────────
local API               = ReplicatedStorage:WaitForChild("API")
local EquipPet          = API:WaitForChild("ToolAPI/Equip")
local DoNeonFusion      = API:WaitForChild("PetAPI/DoNeonFusion")
local SendTradeRequest  = API:WaitForChild("TradeAPI/SendTradeRequest")
local AddItemToOffer    = API:WaitForChild("TradeAPI/AddItemToOffer")
local AcceptNegotiation = API:WaitForChild("TradeAPI/AcceptNegotiation")
local ConfirmTrade      = API:WaitForChild("TradeAPI/ConfirmTrade")
local DataChanged       = API:WaitForChild("DataAPI/DataChanged")
-- ============================================================
--  PET NAME → KIND RESOLVER
-- ============================================================

local ContentPacks          = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("ContentPacks")
local ConvertedPetNameCache = {}
local function ConvertPetName(petname)
    if not petname or petname == "" then return petname end
    if ConvertedPetNameCache[petname] then return ConvertedPetNameCache[petname] end

    for _, pack in ipairs(ContentPacks:GetChildren()) do
        local inventorySubDB = pack:FindFirstChild("InventorySubDB")
        local petsModule     = inventorySubDB and inventorySubDB:FindFirstChild("Pets")

        if pack:IsA("Folder") and petsModule then
            local petsTable = require(petsModule)
            for _, petInfo in pairs(petsTable) do
                for _, value in pairs(petInfo) do
                    if tostring(value) == petname then
                        ConvertedPetNameCache[petname] = petInfo.kind
                        return petInfo.kind
                    end
                end
            end
        end
    end

    -- Not found in DB — assume it's already a kind string
    ConvertedPetNameCache[petname] = petname
    return petname
end

-- Build the resolved TARGET_PET_KINDS lookup at startup
-- Converts any display names to their kind strings
local TARGET_PET_KINDS = {}
for _, nameOrKind in ipairs(TARGET_PET_NAMES) do
    local resolvedKind = ConvertPetName(nameOrKind)
    if resolvedKind then
        TARGET_PET_KINDS[resolvedKind] = true
        print("🐾 Targeting pet kind: " .. resolvedKind .. (resolvedKind ~= nameOrKind and (" (from '" .. nameOrKind .. "')") or ""))
    end
end

-- ============================================================
--  SIMPLE STAGE UI
-- ============================================================

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("StageUI")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StageUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 52)
Frame.Position = UDim2.new(0.5, -140, 0, 16)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(80, 200, 255)
Stroke.Thickness = 1.5
Stroke.Transparency = 0.3
Stroke.Parent = Frame

local StageLabel = Instance.new("TextLabel")
StageLabel.Size = UDim2.new(1, 0, 0.5, 0)
StageLabel.Position = UDim2.new(0, 0, 0, 0)
StageLabel.BackgroundTransparency = 1
StageLabel.Text = "⏳  Starting..."
StageLabel.TextColor3 = Color3.fromRGB(80, 200, 255)
StageLabel.TextSize = 15
StageLabel.Font = Enum.Font.GothamBold
StageLabel.Parent = Frame

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(1, 0, 0.4, 0)
SubLabel.Position = UDim2.new(0, 0, 0.56, 0)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = ""
SubLabel.TextColor3 = Color3.fromRGB(140, 140, 170)
SubLabel.TextSize = 11
SubLabel.Font = Enum.Font.Gotham
SubLabel.Parent = Frame

task.wait(5)
print("Opening Play")
local sound = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("SoundPlayer")
local UI    = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")
sound.FX:play("BambooButton")
UI.set_app_visibility("NewsApp", false)

task.wait(5)

local stageColors = {
    ["FEED NORMAL"] = { stroke = Color3.fromRGB(255, 190, 60)  },
    ["FUSE NORMAL"] = { stroke = Color3.fromRGB(200, 100, 255) },
    ["FEED NEON"]   = { stroke = Color3.fromRGB(80,  220, 130) },
    ["FUSE NEON"]   = { stroke = Color3.fromRGB(255,  80, 180) },
    ["TRADING"]     = { stroke = Color3.fromRGB(80,  200, 255) },
    ["DONE"]        = { stroke = Color3.fromRGB(80,  220, 130) },
}

local stageIcons = {
    ["FEED NORMAL"] = "🍖",
    ["FUSE NORMAL"] = "⚡",
    ["FEED NEON"]   = "🌈",
    ["FUSE NEON"]   = "💥",
    ["TRADING"]     = "🤝",
    ["DONE"]        = "✅",
}

local function setStage(stage, sub)
    local icon   = stageIcons[stage] or "▸"
    local colors = stageColors[stage] or { stroke = Color3.fromRGB(80, 200, 255) }
    StageLabel.Text       = icon .. "  " .. stage
    StageLabel.TextColor3 = colors.stroke
    SubLabel.Text         = sub or ""
    Stroke.Color          = colors.stroke
end

-- ============================================================
--  FEED & FUSE
-- ============================================================

local function feedPet(petUnique)
    print("🍖 Equipping pet: " .. tostring(petUnique))

    local equipArgs = {
        [1] = petUnique,
        [2] = { use_sound_delay = true, equip_as_last = false }
    }

    local equipped = pcall(function()
        return EquipPet:InvokeServer(unpack(equipArgs))
    end)

    if equipped then
        print("✅ Equipped: " .. tostring(petUnique))
    else
        warn("❌ Failed to equip: " .. tostring(petUnique))
    end

    task.wait(1)

    local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
    local foodData   = ClientData.get_data()[playerName].inventory.food
    local potsUnique = {}
    local counter    = 0

    for _, potion in pairs(foodData) do
        if potion.kind == "pet_age_potion" and counter < PET_RARITY then
            table.insert(potsUnique, potion.unique)
            counter = counter + 1
        end
    end

    if #potsUnique == 0 then
        warn("❌ No potions found! Skipping: " .. tostring(petUnique))
        return false
    end

    local additional = {}
    for i = 2, #potsUnique do
        table.insert(additional, potsUnique[i])
    end

    local args = {
        "__Enum_PetObjectCreatorType_2",
        {
            additional_consume_uniques = additional,
            pet_unique                 = petUnique,
            unique_id                  = potsUnique[1]
        }
    }

    local success, result = pcall(function()
        return API:WaitForChild("PetObjectAPI/CreatePetObject"):InvokeServer(unpack(args))
    end)

    if not success then
        warn("❌ Failed to feed: " .. tostring(petUnique) .. " | " .. tostring(result))
        return false
    end

    local TIMEOUT    = 60
    local POLL_EVERY = 0.5
    local elapsed    = 0
    local reached6   = false

    print("⏳ Waiting for pet " .. tostring(petUnique) .. " to reach age 6...")

    while elapsed < TIMEOUT do
        task.wait(POLL_EVERY)
        elapsed = elapsed + POLL_EVERY

        local freshData = ClientData.get_data()[playerName].inventory.pets
        for _, pet in pairs(freshData) do
            if pet.unique == petUnique then
                if (pet.properties.age or 0) >= 6 then
                    reached6 = true
                end
                break
            end
        end

        if reached6 then break end
    end

    if reached6 then
        print("✅ Fed pet — age 6 confirmed: " .. tostring(petUnique))
    else
        warn("⚠️ Timeout waiting for age 6 on pet: " .. tostring(petUnique) .. " — moving on anyway")
    end

    return reached6
end

local function feedNormal()
    setStage("FEED NORMAL", "Feeding normal pets...")
    print("── FEED NORMAL ──────────────────────────────")
    local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
    local petsData   = ClientData.get_data()[playerName].inventory.pets
    local count      = 0

    for _, pet in pairs(petsData) do
        if TARGET_PET_KINDS[pet.kind]
            and not pet.properties.neon
            and not pet.properties.mega_neon
            and pet.properties.age < 6 then

            setStage("FEED NORMAL", "Feeding " .. pet.kind .. " | age " .. tostring(pet.properties.age))
            feedPet(pet.unique)
            count = count + 1
            task.wait(1)
        end
    end

    setStage("FEED NORMAL", "Done — fed " .. count .. " pets")
    print("✅ Feed normal done. Fed " .. count .. " pets.")
end

local function fuseNormal()
    setStage("FUSE NORMAL", "Fusing full grown normals...")
    print("── FUSE NORMAL ──────────────────────────────")
    local totalFused = 0

    while true do
        local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
        local petsData   = ClientData.get_data()[playerName].inventory.pets
        local grouped    = {}

        for _, pet in pairs(petsData) do
            if TARGET_PET_KINDS[pet.kind]
                and not pet.properties.neon
                and not pet.properties.mega_neon
                and pet.properties.age == 6 then

                grouped[pet.kind] = grouped[pet.kind] or {}
                table.insert(grouped[pet.kind], pet.unique)
            end
        end

        local fusionKind, fusionBatch = nil, nil
        for kind, uniques in pairs(grouped) do
            if #uniques >= 4 then
                fusionKind  = kind
                fusionBatch = { uniques[1], uniques[2], uniques[3], uniques[4] }
                break
            end
        end

        if not fusionBatch then
            print("⚠️ Not enough full grown normals to fuse. Stopping.")
            break
        end

        setStage("FUSE NORMAL", "Fusing 4x " .. fusionKind)
        local success, result = pcall(function()
            return DoNeonFusion:InvokeServer(fusionBatch)
        end)

        if success then
            totalFused = totalFused + 1
            print("✅ Fused 4x " .. fusionKind .. " → Neon!")
            setStage("FUSE NORMAL", "Fused " .. totalFused .. "x so far...")
        else
            warn("❌ Fuse failed: " .. tostring(result))
        end

        task.wait(1)
    end

    setStage("FUSE NORMAL", "Done — " .. totalFused .. " fusions")
    print("✅ Fuse normal done. Total fusions: " .. totalFused)
end

local function feedNeon()
    setStage("FEED NEON", "Feeding neon pets...")
    print("── FEED NEON ────────────────────────────────")
    local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
    local petsData   = ClientData.get_data()[playerName].inventory.pets
    local count      = 0

    for _, pet in pairs(petsData) do
        if TARGET_PET_KINDS[pet.kind]
            and pet.properties.neon == true
            and not pet.properties.mega_neon
            and pet.properties.age < 6 then

            setStage("FEED NEON", "Feeding " .. pet.kind .. " | age " .. tostring(pet.properties.age))
            feedPet(pet.unique)
            count = count + 1
            task.wait(1)
        end
    end

    setStage("FEED NEON", "Done — fed " .. count .. " pets")
    print("✅ Feed neon done. Fed " .. count .. " pets.")
end

local function fuseNeon()
    setStage("FUSE NEON", "Fusing full grown neons...")
    print("── FUSE NEON ────────────────────────────────")
    local totalFused = 0

    while true do
        local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
        local petsData   = ClientData.get_data()[playerName].inventory.pets
        local grouped    = {}

        for _, pet in pairs(petsData) do
            if TARGET_PET_KINDS[pet.kind]
                and pet.properties.neon == true
                and not pet.properties.mega_neon
                and pet.properties.age == 6 then

                grouped[pet.kind] = grouped[pet.kind] or {}
                table.insert(grouped[pet.kind], pet.unique)
            end
        end

        local fusionKind, fusionBatch = nil, nil
        for kind, uniques in pairs(grouped) do
            if #uniques >= 4 then
                fusionKind  = kind
                fusionBatch = { uniques[1], uniques[2], uniques[3], uniques[4] }
                break
            end
        end

        if not fusionBatch then
            print("⚠️ Not enough full grown neons to fuse. Stopping.")
            break
        end

        setStage("FUSE NEON", "Fusing 4x neon " .. fusionKind)
        local success, result = pcall(function()
            return DoNeonFusion:InvokeServer(fusionBatch)
        end)

        if success then
            totalFused = totalFused + 1
            print("✅ Fused 4x neon " .. fusionKind .. " → Mega Neon!")
            setStage("FUSE NEON", "Fused " .. totalFused .. "x so far...")
        else
            warn("❌ Fuse failed: " .. tostring(result))
        end

        task.wait(1)
    end

    setStage("FUSE NEON", "Done — " .. totalFused .. " fusions")
    print("✅ Fuse neon done. Total fusions: " .. totalFused)
end

-- ============================================================
--  TRADE
-- ============================================================

local rotationLookup = {}
for _, entry in ipairs(allowedRotation) do
    if not rotationLookup[entry.name] then
        rotationLookup[entry.name] = entry
    end
end

for _, entry in ipairs(allowedRotation) do
    entry.traded        = entry.traded        or 0
    entry.pending       = entry.pending       or 0
    entry.tradesCounted = entry.tradesCounted or {}
end

local rotationIndex = 1
local IN_TRADE      = false
local lastRequest   = 0
local currentEntry  = nil

local function isMatchingPet(pet, modes)
    if not TARGET_PET_KINDS[pet.kind] then return false end
    local props    = pet.properties
    local age      = props.age or 0
    local isNeon   = props.neon == true
    local isMega   = props.mega_neon == true
    local isNormal = not isNeon and not isMega

    for _, mode in ipairs(modes) do
        if mode == "neon_under6"       and isNeon   and not isMega and age < 6  then return true
        elseif mode == "neon_full"     and isNeon   and not isMega and age == 6 then return true
        elseif mode == "mega_neon"     and isMega                               then return true
        elseif mode == "normal_under6" and isNormal and age < 6                 then return true
        elseif mode == "normal_full"   and isNormal and age == 6                then return true
        end
    end

    return false
end

local function getMatchingPets(modes)
    local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
    local petsData   = ClientData.get_data()[playerName].inventory.pets
    local found = {}
    for _, pet in pairs(petsData) do
        if isMatchingPet(pet, modes) then
            table.insert(found, pet)
        end
    end
    return found
end

local function getRemainingAmount(entry)
    if not entry.maxAmount then return math.huge end
    return math.max(0, entry.maxAmount - entry.traded)
end

local function isEntryMaxed(entry)
    return entry.maxAmount ~= nil and entry.traded >= entry.maxAmount
end

local function getNextAvailableTarget()
    local tried = 0
    local total = #allowedRotation

    while tried < total do
        local entry = allowedRotation[rotationIndex]
        rotationIndex = (rotationIndex % total) + 1
        tried = tried + 1

        if isEntryMaxed(entry) then
            print("⏭ " .. entry.name .. " maxed out (" .. entry.traded .. "/" .. tostring(entry.maxAmount) .. "), skipping...")
            continue
        end

        local targetPlayer = Players:FindFirstChild(entry.name)
        if targetPlayer then
            return targetPlayer, entry.name, entry.mode, entry
        else
            warn("⏭ " .. entry.name .. " not in server, skipping...")
        end
    end

    return nil, nil, nil, nil
end

local function addPetsToOffer(maxCount, modes, entry)
    local pets  = getMatchingPets(modes)
    local added = 0
    local cap   = math.min(maxCount, getRemainingAmount(entry))

    for _, pet in ipairs(pets) do
        if added >= cap then break end
        AddItemToOffer:FireServer(pet.unique)
        task.wait(0.2)
        added = added + 1
        print(
            "✅ Added to offer: " .. pet.kind ..
            " | neon=" .. tostring(pet.properties.neon) ..
            " | mega=" .. tostring(pet.properties.mega_neon) ..
            " | age="  .. tostring(pet.properties.age)
        )
        -- task.wait(1)
    end

    print("📦 Offer: " .. added .. " pets added.")
    return added
end

local function startTrade()
    setStage("TRADING", "Waiting for trade...")
    print("── TRADE ────────────────────────────────────")

    DataChanged.OnClientEvent:Connect(function(...)
        local args = table.pack(...)
        if args.n < 3 or args[2] ~= "trade" then return end

        local tradeTable = args[3]

        if tradeTable == nil then
            if IN_TRADE then
                warn("⚠️ Trade window closed.")
                setStage("TRADING", "Trade ended — finding next target...")
                if currentEntry then
                    currentEntry.pending = 0
                end
            end
            IN_TRADE     = false
            currentEntry = nil
            return
        end

        if typeof(tradeTable) ~= "table" then return end

        local sender    = tradeTable.sender_offer
        local recipient = tradeTable.recipient_offer
        if not (sender and recipient) then return end

        local senderName    = tostring(sender.player_name    or "")
        local recipientName = tostring(recipient.player_name or "")

        local matchedEntry = nil
        for _, entry in ipairs(allowedRotation) do
            if entry.name == senderName or entry.name == recipientName then
                matchedEntry = entry
                break
            end
        end

        if not matchedEntry then return end

        IN_TRADE     = true
        currentEntry = matchedEntry

        -- Both confirmed → count pets
        if sender.confirmed and recipient.confirmed then
            local tradeId = tostring(tradeTable.trade_id or "")
            if currentEntry and currentEntry.pending > 0 and not currentEntry.tradesCounted[tradeId] then
                currentEntry.tradesCounted[tradeId] = true
                currentEntry.traded  = currentEntry.traded + currentEntry.pending
                currentEntry.pending = 0
                local q = currentEntry.maxAmount
                    and (" | quota=" .. currentEntry.traded .. "/" .. currentEntry.maxAmount)
                    or ""
                print("✅ Trade completed. Counted pets." .. q)
                setStage("TRADING", "Trade complete — " .. currentEntry.traded .. " sent to " .. recipientName)
            end
            return
        end

        local quotaText = matchedEntry.maxAmount
            and (" | quota=" .. matchedEntry.traded .. "/" .. matchedEntry.maxAmount)
            or ""

        setStage("TRADING", senderName .. " ↔ " .. recipientName .. quotaText)
        print("🤝 Trade active: " .. senderName .. " ↔ " .. recipientName .. " | modes=" .. table.concat(currentEntry.mode, ", ") .. quotaText)

        if recipient.negotiated and not recipient.confirmed then
            task.wait(5)
            ConfirmTrade:FireServer()
            print("✅ Trade confirmed.")
            setStage("TRADING", "Confirming trade...")
        end

        -- ── FIXED: we are the sender (local player), add pets when OUR negotiated is false ──
        if senderName == playerName and not sender.negotiated then

            if isEntryMaxed(currentEntry) then
                warn("⏭ " .. recipientName .. " maxed out. Skipping.")
                setStage("TRADING", recipientName .. " maxed out — skipping")
                return
            end

            local petCount = #getMatchingPets(currentEntry.mode)

            if petCount <= 0 then
                warn("❌ No matching pets. Skipping.")
                setStage("TRADING", "No pets for this target, skipping...")
                return
            end

            setStage("TRADING", "Adding pets to offer...")

            local remaining = getRemainingAmount(currentEntry)
            local toAdd     = math.min(TRADE_LIMIT, petCount, remaining)
            local added     = addPetsToOffer(toAdd, currentEntry.mode, currentEntry)

            if added > 0 then
                currentEntry.pending = added
                task.wait(2)

                local NEGOTIATE_TIMEOUT  = 15
                local NEGOTIATE_INTERVAL = 2
                local negotiateElapsed   = 0
                local negotiated         = false

                while negotiateElapsed < NEGOTIATE_TIMEOUT do
                    AcceptNegotiation:FireServer()
                    print("📤 AcceptNegotiation fired... waiting for confirmation")
                    task.wait(NEGOTIATE_INTERVAL)
                    negotiateElapsed = negotiateElapsed + NEGOTIATE_INTERVAL

                    local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
                    local tradeData  = ClientData.get_data()[playerName].trade
                    if tradeData and tradeData.sender_offer and tradeData.sender_offer.negotiated then
                        negotiated = true
                        break
                    end
                end

                if negotiated then
                    print("✅ Negotiation confirmed after " .. negotiateElapsed .. "s")
                else
                    warn("⚠️ Negotiation not confirmed after " .. NEGOTIATE_TIMEOUT .. "s — moving on")
                end

                local q = currentEntry.maxAmount
                    and (" | quota=" .. currentEntry.traded .. "/" .. currentEntry.maxAmount .. " (+" .. added .. " pending)")
                    or ""
                setStage("TRADING", "Offer sent to " .. recipientName .. q)
            else
                warn("⚠️ Nothing added to offer.")
                setStage("TRADING", "Nothing added to offer")
            end
        end
    end)

    while true do
        if not IN_TRADE then
            local now = tick()
            if now - lastRequest >= TRADE_COOLDOWN then
                lastRequest = now

                local anyPetsLeft = false
                for _, entry in ipairs(allowedRotation) do
                    if not isEntryMaxed(entry) and #getMatchingPets(entry.mode) > 0 then
                        anyPetsLeft = true
                        break
                    end
                end

                if not anyPetsLeft then
                    print("✅ No matching pets left for any rotation target. Trade phase done.")
                    setStage("DONE", "All pets traded — script complete!")
                    break
                end

                local targetPlayer, targetName, targetModes, targetEntry = getNextAvailableTarget()

                if not targetPlayer then
                    warn("⚠️ No rotation users online. Retrying in 10s...")
                    setStage("TRADING", "No users online — retrying in 10s...")
                    task.wait(10)
                else
                    local petCount  = #getMatchingPets(targetModes)
                    local remaining = getRemainingAmount(targetEntry)

                    if petCount <= 0 then
                        warn("⏭ Skipping " .. targetName .. " — no pets matching modes [" .. table.concat(targetModes, ", ") .. "]")
                        setStage("TRADING", "Skipping " .. targetName .. " — no matching pets")
                    else
                        local quotaText = targetEntry.maxAmount
                            and (" | quota=" .. targetEntry.traded .. "/" .. targetEntry.maxAmount)
                            or ""
                        setStage("TRADING", "Requesting " .. targetName .. " | " .. math.min(petCount, remaining) .. " pets ready" .. quotaText)
                        print(
                            "📨 Sending trade request to " .. targetName ..
                            " | modes=" .. table.concat(targetModes, ", ") ..
                            " | pets available: " .. petCount ..
                            quotaText
                        )
                        pcall(function()
                            SendTradeRequest:FireServer(targetPlayer)
                        end)
                    end
                end
            end
        end

        task.wait(1)
    end
end

-- ============================================================
--  RUN SEQUENCE
-- ============================================================
print("🚀 Starting sequence...")

if RUN_FEED_NORMAL then feedNormal() end
if RUN_FUSE_NORMAL then fuseNormal() end
if RUN_FEED_NEON   then feedNeon()   end
if RUN_FUSE_NEON   then fuseNeon()   end

if RUN_TRADE then
    print("✅ Feed/fuse complete. Starting trade phase...")
    startTrade()
else
    setStage("DONE", "All steps complete!")
    print("🏁 All done!")
end
