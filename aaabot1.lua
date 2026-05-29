-- BOT 1 — DEPOSIT BOT (SECURED)
-- petsadoptluck.com

print("STARTING BOT1")
task.wait(1)
loadstring(game:HttpGet('https://raw.githubusercontent.com/dkjalsghfuiysdaiuyreiuwoqyrqwfdsafvzcx/Tests/refs/heads/main/showconsole.lua'))()

-- ============================================================
-- SETUP: Rename hashed remotes
-- ============================================================
local router
for i, v in next, getgc(true) do
    if type(v) == 'table' and rawget(v, 'get_remote_from_cache') then
        router = v
    end
end

local function rename(remotename, hashedremote)
    hashedremote.Name = remotename
end
table.foreach(debug.getupvalue(router.get_remote_from_cache, 1), rename)

-- ============================================================
-- HIDE UI + PLAY SOUND ON STARTUP
-- ============================================================
task.wait(10)
local sound = require(game:GetService("ReplicatedStorage"):WaitForChild("Fsys")).load("SoundPlayer")
local UI    = require(game:GetService("ReplicatedStorage"):WaitForChild("Fsys")).load("UIManager")
sound.FX:play("BambooButton")
UI.set_app_visibility("NewsApp", false)
UI.set_app_visibility("DialogApp", false)
UI.set_app_visibility("DailyLoginApp", false)
game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("PayAPI/Collect"):FireServer()
game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("PayAPI/DisablePopups"):FireServer()
getgenv().fsysCore = require(game:GetService("ReplicatedStorage").ClientModules.Core.InteriorsM.InteriorsM)
local targetCFrame = CFrame.new(-250.99, 29.58, -1525.42, -0.9798217415809631, 0.0000227206928684609, 0.19986890256404877, -0.000003862579433189239, 1, -0.00013261348067317158, -0.19986890256404877, -0.00013070966815575957, -0.9798217415809631)
local OrigThreadID = getthreadidentity()
task.wait(1)
setidentity(2)
task.wait(1)
fsysCore.enter_smooth("MainMap", "MainDoor", {
    ["spawn_cframe"] = targetCFrame * CFrame.Angles(0, 0, 0)
})
setidentity(OrigThreadID)

task.wait(10)

-- ============================================================
-- SERVICES & CONSTANTS
-- ============================================================
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player     = Players.LocalPlayer
local CLIENT_URL = "https://petsadoptluck.com"

local BOT1_NAME = tostring(Player.Name)

getgenv().ADMIN_CODE     = "raprapissuperdupergwapo"
getgenv().IN_TRADE       = false
getgenv().BOT1_NAME      = "Adoptluck_1"
getgenv().BOT2_NAME      = "DorisKrueger1"
getgenv().BOT3_NAME      = "JessicaVelazquez706"
getgenv().TRADE_TYPE     = nil
getgenv().TRADE_BOT2     = false
getgenv().IN_TRADE_BOT2  = false
getgenv().CURRENT_PDATA  = nil

local processingIds        = {}
local acceptedIds          = {}
local pDataByTradeId       = {}
local botNegotiatedByTrade = {}

local withdrawLockByUser = {}
local WITHDRAW_LOCK_TIMEOUT = 90
local withdrawLockTime = {}

local processingStartTime = {}
local PROCESSING_TIMEOUT  = 60

-- ✅ FIX 5: Track records that exhausted all trade attempts so the poll loop
-- skips them for a cooldown window instead of immediately re-picking them.
-- Prevents the bot from hammering bot2 with the same dead record every 10s.
local failedIds           = {}
local FAILED_COOLDOWN     = 120  -- seconds before retrying a failed record

-- ============================================================
-- 📦 DEPOSIT QUEUE — holds up to QUEUE_MAX backend records.
-- The poll loop fills this from the backend. While any entry
-- exists, all real-user trade requests are declined so the bot
-- can drain the queue without interference. Bot2 is never blocked.
-- ============================================================
local depositQueue  = {}   -- ordered array of pData records, max QUEUE_MAX
local queuedIds     = {}   -- set: queuedIds[id]=true to prevent duplicates
local QUEUE_MAX     = 5

local function depositQueueSize()
    return #depositQueue
end

local function depositQueueContains(id)
    return queuedIds[id] == true
end

local function depositQueuePush(pData)
    if depositQueueSize() >= QUEUE_MAX then return false end
    if depositQueueContains(pData.id) then return false end
    table.insert(depositQueue, pData)
    queuedIds[pData.id] = true
    print(string.format("📦 [QUEUE] Pushed record %s for user '%s' — queue size now %d/%d",
        tostring(pData.id), tostring(pData.username), depositQueueSize(), QUEUE_MAX))
    return true
end

local function depositQueueRemove(id)
    for i, entry in ipairs(depositQueue) do
        if entry.id == id then
            table.remove(depositQueue, i)
            queuedIds[id] = nil
            print(string.format("📦 [QUEUE] Removed record %s — queue size now %d/%d",
                tostring(id), depositQueueSize(), QUEUE_MAX))
            return true
        end
    end
    return false
end

local function depositQueuePeek()
    return depositQueue[1]
end

-- ============================================================
-- 🔥 FORCE-POLL SIGNALS
-- ============================================================
local depositReadySignal  = Instance.new("BindableEvent")
local withdrawReadySignal = Instance.new("BindableEvent")

local function waitOrSignal(signal, maxSeconds)
    local fired = false
    local conn
    conn = signal.Event:Connect(function()
        fired = true
    end)
    local elapsed = 0
    while elapsed < maxSeconds and not fired do
        task.wait(1)
        elapsed += 1
    end
    conn:Disconnect()
end

-- ============================================================
-- HELPERS
-- ============================================================

local function decodeJSON(str)
    if type(str) ~= "string" or str == "" then return nil end
    local ok, result = pcall(function() return HttpService:JSONDecode(str) end)
    return ok and result or nil
end

local function httpJSON(url, method, bodyTable)
    local response = http_request({
        Url    = url,
        Method = method or "GET",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Accept"]       = "application/json"
        },
        Body = bodyTable and HttpService:JSONEncode(bodyTable) or nil
    })
    local status = response.StatusCode or response.status_code or 0
    local body   = response.Body or response.body or ""
    print("HTTP " .. method .. " " .. url .. " → " .. status)
    return status, decodeJSON(body), body
end

local function ConvertPetName(petname)
    if not petname or petname == "" then return petname end
    for _, pack in pairs(game:GetService("ReplicatedStorage").SharedModules.ContentPacks:GetChildren()) do
        if pack:IsA("Folder") and pack:FindFirstChild("InventorySubDB") then
            if pack.InventorySubDB:FindFirstChild("Pets") then
                local petsTable = require(pack.InventorySubDB.Pets)
                for _, Pet in pairs(petsTable) do
                    for _, value in pairs(Pet) do
                        if tostring(value) == petname then
                            return Pet.name
                        end
                    end
                end
            end
        end
    end
    return petname
end

local function CheckRarity(petname)
    for _, z in pairs(game:GetService("ReplicatedStorage").SharedModules.ContentPacks:GetChildren()) do
        if z:IsA("Folder") and z:FindFirstChild("InventorySubDB") then
            if z.InventorySubDB:FindFirstChild("Pets") then
                for _, Pet in pairs(require(z.InventorySubDB.Pets)) do
                    for _, b in pairs(Pet) do
                        if tostring(b) == petname then
                            return Pet.rarity or "Unknown"
                        end
                    end
                end
            end
        end
    end
    return "Unknown"
end

local RARITY_MAP = {
    ["common"]     = "Common",
    ["uncommon"]   = "Uncommon",
    ["rare"]       = "Rare",
    ["ultra_rare"] = "UltraRare",
    ["ultrarare"]  = "UltraRare",
    ["legendary"]  = "Legendary",
}

local function NormalizeRarity(raw)
    if not raw then return nil end
    return RARITY_MAP[string.lower(raw)]
end

local function findPets(petkind, variant, ride, fly, usedUniques)
    usedUniques = usedUniques or {}
    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    local inventory = fsys.get("inventory")
    print("Looking for: " .. tostring(petkind) .. " Variant: " .. tostring(variant) .. " Ride: " .. tostring(ride) .. " Fly: " .. tostring(fly))

    local inventoryPets = inventory and inventory.pets or {}
    for _, pet in pairs(inventoryPets) do
        if petkind == pet.kind and not usedUniques[pet.unique] then
            if variant == "MEGA" and pet.properties.mega_neon then
                if ride == true and fly == true then
                    if pet.properties.rideable and pet.properties.flyable then return pet.unique end
                elseif ride == true and fly == false then
                    if pet.properties.rideable and not pet.properties.flyable then return pet.unique end
                elseif ride == false and fly == true then
                    if not pet.properties.rideable and pet.properties.flyable then return pet.unique end
                elseif ride == false and fly == false then
                    if not pet.properties.rideable and not pet.properties.flyable then return pet.unique end
                end
            end
            if variant == "NEON" and pet.properties.neon and not pet.properties.mega_neon then
                if ride == true and fly == true then
                    if pet.properties.rideable and pet.properties.flyable then return pet.unique end
                elseif ride == true and fly == false then
                    if pet.properties.rideable and not pet.properties.flyable then return pet.unique end
                elseif ride == false and fly == true then
                    if not pet.properties.rideable and pet.properties.flyable then return pet.unique end
                elseif ride == false and fly == false then
                    if not pet.properties.rideable and not pet.properties.flyable then return pet.unique end
                end
            end
            if variant == "NORMAL" and not pet.properties.neon and not pet.properties.mega_neon then
                if ride == true and fly == true then
                    if pet.properties.rideable and pet.properties.flyable then return pet.unique end
                elseif ride == true and fly == false then
                    if pet.properties.rideable and not pet.properties.flyable then return pet.unique end
                elseif ride == false and fly == true then
                    if not pet.properties.rideable and pet.properties.flyable then return pet.unique end
                elseif ride == false and fly == false then
                    if not pet.properties.rideable and not pet.properties.flyable then return pet.unique end
                end
            end
        end
    end

    local otherCategories = {
        inventory.food, inventory.strollers, inventory.toys,
        inventory.transport, inventory.gifts, inventory.pet_accessories, inventory.stickers,
    }
    for _, categoryItems in ipairs(otherCategories) do
        if type(categoryItems) ~= "table" then continue end
        for _, item in pairs(categoryItems) do
            if petkind == item.kind and not usedUniques[item.unique] then
                print("Found in other category: " .. tostring(petkind))
                return item.unique
            end
        end
    end

    warn("Could not find item in any inventory category: " .. tostring(petkind))
    return nil
end

-- ============================================================
-- FUNCTIONS
-- ============================================================
local function chatBubble(msg)
    local TextChatService = game:GetService("TextChatService")
    local channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
    channel:SendAsync(msg)
end

local function handleDeposit(userId, username, petTypeIds)
    if not userId or userId == "" then
        warn("handleDeposit: missing userId")
        return false
    end
    if not username or username == "" then
        warn("handleDeposit: missing username")
        return false
    end
    if type(petTypeIds) ~= "table" or #petTypeIds == 0 then
        warn("handleDeposit: petTypeIds empty")
        return false
    end

    if string.lower(username) == string.lower(BOT1_NAME) then
        warn("🚫 SECURITY: Attempted to create deposit record for bot1 itself! Blocked. Username: " .. username)
        return false
    end
    if string.lower(username) == string.lower(getgenv().BOT2_NAME) then
        warn("🚫 SECURITY: Attempted to create deposit record for bot2! Blocked. Username: " .. username)
        return false
    end
    if string.lower(username) == string.lower(getgenv().BOT3_NAME) then
        warn("🚫 SECURITY: Attempted to create deposit record for bot3! Blocked. Username: " .. username)
        return false
    end

    print("Giving Pets Now")
    local url = CLIENT_URL .. "/api/pets/addpetstouser"
    local status, data, raw = httpJSON(url, "POST", {
        userId     = userId,
        username   = username,
        petTypeIds = petTypeIds
    })
    print("ADD STATUS:", status)
    print("ADD RAW:", raw)
    if status ~= 201 or not data then
        warn("addpetstouser failed:", status, raw)
        return false
    end
    print("✅ addpetstouser success")
    return true
end

local function handleFindUsernamePetTypeId(username, pets)
    username = tostring(username or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if username == "" then warn("Username empty") return false end
    if type(pets) ~= "table" then warn("Pets must be table") return false end

    local lowerUser = string.lower(username)
    if lowerUser == string.lower(BOT1_NAME) then
        warn("🚫 SECURITY: handleFindUsernamePetTypeId called with bot1 username! Blocked.")
        return false
    end
    if lowerUser == string.lower(getgenv().BOT2_NAME) then
        warn("🚫 SECURITY: handleFindUsernamePetTypeId called with bot2 username! Blocked.")
        return false
    end
    if lowerUser == string.lower(getgenv().BOT3_NAME) then
        warn("🚫 SECURITY: handleFindUsernamePetTypeId called with bot3 username! Blocked.")
        return false
    end

    print("Finding User now")
    local userUrl = CLIENT_URL .. "/api/users/" .. HttpService:UrlEncode(username)
    local status1, data1, raw1 = httpJSON(userUrl, "GET")
    print("STATUS 1:", status1)

    if status1 ~= 200 or not data1 then
        warn("User lookup failed:", status1, raw1)
        return false
    end

    local userId = data1.userId or (data1.user and data1.user.id)
    if not userId then
        warn("userId missing in response:", raw1)
        return false
    end

    local backendUsername = data1.username or (data1.user and data1.user.username)
    if backendUsername then
        if string.lower(backendUsername) ~= lowerUser then
            warn("🚫 SECURITY: Username mismatch! Trade sender='" .. username .. "' but backend returned='" .. backendUsername .. "' — aborting deposit!")
            return false
        end
        print("✅ Username cross-check passed: '" .. username .. "' matches backend")
    else
        print("USER ID:", userId)
        warn("⚠️ Backend did not return username for cross-check — proceeding with userId only")
    end

    local checkUrl = CLIENT_URL .. "/api/pets/checkpets"
    local status2, data2, raw2 = httpJSON(checkUrl, "POST", { pets = pets })
    print("STATUS 2:", status2)
    print("DATA 2:", data2 and HttpService:JSONEncode(data2) or "nil")

    if status2 ~= 200 or not data2 then
        warn("checkpets failed:", status2, raw2)
        return false
    end
    if data2.success ~= true then
        warn("checkpets not successful:", raw2)
        return false
    end

    local validPets = data2.existing_after
    if type(validPets) ~= "table" or #validPets == 0 then
        warn("No pets found/created:", raw2)
        return false
    end

    local idByKey = {}
    for _, p in ipairs(validPets) do
        local k = (tostring(p.name or ""):lower()) .. "|" .. tostring(p.variant) .. "|" .. tostring(p.fly) .. "|" .. tostring(p.ride)
        idByKey[k] = p.id
    end

    local petTypeIds = {}
    for _, inPet in ipairs(pets) do
        local k = (tostring(inPet.petname or ""):lower()) .. "|" .. tostring(inPet.variant) .. "|" .. tostring(inPet.fly) .. "|" .. tostring(inPet.ride)
        local id = idByKey[k]
        if not id then
            warn("Missing petTypeId for:", k)
        else
            table.insert(petTypeIds, id)
        end
    end

    if #petTypeIds == 0 then
        warn("No petTypeIds resolved:", raw2)
        return false
    end

    print("✅ petTypeIds:", HttpService:JSONEncode(petTypeIds))
    local ok = handleDeposit(userId, username, petTypeIds)
    return ok == true
end

local FOOD_KIND_NAMES = {
    ["pet_riding_potion"] = "Ride Potion",
    ["pet_flying_potion"]  = "Fly Potion",
}

local function describeItem(item)
    local props = item.properties or {}
    local variant = "NORMAL"
    if props.mega_neon then variant = "MEGA"
    elseif props.neon then variant = "NEON" end
    local kind = tostring(item.kind)
    local name = FOOD_KIND_NAMES[kind] or ConvertPetName(kind)
    local normalizedRarity = NormalizeRarity(CheckRarity(kind))
    return {
        petname = name,
        variant = variant,
        petkind = kind,
        fly     = props.flyable  == true,
        ride    = props.rideable == true,
        rarity  = normalizedRarity,
    }
end

local ALLOWED_FOOD_KINDS = {
    ["pet_riding_potion"] = true,
    ["pet_flying_potion"]  = true,
}

local function buildOfferItems(offer)
    local out = {}
    for _, item in pairs(offer.items or {}) do
        local category = tostring(item.category or "")
        local kind     = tostring(item.kind or "")
        if category == "pets" or ALLOWED_FOOD_KINDS[kind] then
            table.insert(out, describeItem(item))
        else
            print("Skipping item: " .. kind .. " (category: " .. category .. ")")
        end
    end
    return out
end

local processedTradeIds = {}
local inFlightTradeIds  = {}
local function markTradeDone(tradeId, success)
    tradeId = tostring(tradeId or "")
    inFlightTradeIds[tradeId] = nil
    if success then
        processedTradeIds[tradeId] = true
    end
end

local function notifyBackendDone(username, note)
    print("Notify Backend Done")
end

local pendingWithdrawByUser  = {}
local pendingWithdrawByTrade = {}
local withdrawSentByTrade    = {}

local function buildKey(petkind, variant, fly, ride)
    return string.lower(tostring(petkind or "")) .. "|" .. string.upper(tostring(variant or "NORMAL")) .. "|" ..
               tostring(fly == true) .. "|" .. tostring(ride == true)
end

local function verifyWithdrawPetsMatch(expectedPets, tradeSnapshotItems)
    if type(expectedPets) ~= "table" or type(tradeSnapshotItems) ~= "table" then
        warn("verifyWithdrawPetsMatch: invalid input types")
        return false
    end

    if #expectedPets ~= #tradeSnapshotItems then
        warn(string.format("verifyWithdrawPetsMatch: count mismatch — expected %d, got %d in trade", #expectedPets, #tradeSnapshotItems))
        return false
    end

    local expectedFreq = {}
    for _, p in ipairs(expectedPets) do
        local pt = p.pet_type or {}
        local k = buildKey(pt.petkind, pt.variant, pt.fly, pt.ride)
        expectedFreq[k] = (expectedFreq[k] or 0) + 1
    end

    for _, it in ipairs(tradeSnapshotItems) do
        local k = buildKey(it.petkind, it.variant, it.fly, it.ride)
        if not expectedFreq[k] or expectedFreq[k] == 0 then
            warn("verifyWithdrawPetsMatch: trade contains unexpected pet: " .. k)
            return false
        end
        expectedFreq[k] = expectedFreq[k] - 1
    end

    for k, count in pairs(expectedFreq) do
        if count ~= 0 then
            warn("verifyWithdrawPetsMatch: missing pet from trade: " .. k .. " (remaining: " .. count .. ")")
            return false
        end
    end

    print("✅ verifyWithdrawPetsMatch: all pets match correctly")
    return true
end

local function isDepositStillInPipeline(username)
    local encodedUser = HttpService:UrlEncode(string.lower(username))

    local s1, d1 = httpJSON(
        CLIENT_URL .. "/api/bot/progress?stageAt=bot1&from=bot1&type=DEPOSIT&progress=IN_PROGRESS&username=" .. encodedUser,
        "GET"
    )
    if s1 == 200 and d1 and #d1 > 0 then
        print("⚠️ Deposit still at bot1 for:", username)
        return true
    end

    local s2, d2 = httpJSON(
        CLIENT_URL .. "/api/bot/progress?stageAt=bot2&from=bot1&type=DEPOSIT&progress=IN_PROGRESS&username=" .. encodedUser,
        "GET"
    )
    if s2 == 200 and d2 and #d2 > 0 then
        print("⚠️ Deposit still at bot2 for:", username)
        return true
    end

    local s3, d3 = httpJSON(
        CLIENT_URL .. "/api/bot/progress?stageAt=bot3&from=bot2&type=DEPOSIT&progress=IN_PROGRESS&username=" .. encodedUser,
        "GET"
    )
    if s3 == 200 and d3 and #d3 > 0 then
        print("⚠️ Deposit still at bot3 (not finalized) for:", username)
        return true
    end

    return false
end

local function handleWithdraw(username)
    local now = tick()
    if withdrawLockByUser[username] then
        local lockAge = now - (withdrawLockTime[username] or 0)
        if lockAge < WITHDRAW_LOCK_TIMEOUT then
            warn("🔒 Withdraw already in progress for: " .. username .. " (locked " .. math.floor(lockAge) .. "s ago)")
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
            chatBubble("Your withdrawal is still processing. Please wait before trading again.")
            getgenv().IN_TRADE   = false
            getgenv().TRADE_TYPE = nil
            return false
        else
            warn("⏱️ Withdraw lock expired for: " .. username .. " — clearing")
            withdrawLockByUser[username] = nil
            withdrawLockTime[username]   = nil
        end
    end

    withdrawLockByUser[username] = true
    withdrawLockTime[username]   = now

    if isDepositStillInPipeline(username) then
        warn("🚫 Blocking withdraw for " .. username .. " — deposit still in pipeline")
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
        chatBubble("Your deposit is still processing... Please wait a moment and try again.")
        getgenv().IN_TRADE   = false
        getgenv().TRADE_TYPE = nil
        withdrawLockByUser[username] = nil
        withdrawLockTime[username]   = nil
        return false
    end

    local status, data, raw = httpJSON(CLIENT_URL .. "/api/pets/checkwithdrawpets", "POST", {
        username = string.lower(username)
    })

    if status ~= 200 or not data or not data.pets or #data.pets == 0 then
        warn("No withdraw pets found:", status, raw)
        getgenv().TypeTrade = nil
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
        chatBubble("Pets Not found... Try again later.")
        notifyBackendDone(username, "No withdraw pets found")
        withdrawLockByUser[username] = nil
        withdrawLockTime[username]   = nil
        return false
    end

    local usedUniques  = {}
    local resolvedPets = {}

    for _, datapet in pairs(data.pets) do
        local petUnique = findPets(
            datapet.pet_type.petkind,
            datapet.pet_type.variant,
            datapet.pet_type.ride,
            datapet.pet_type.fly,
            usedUniques
        )

        if not petUnique then
            warn("Pet not in bot inventory, declining trade: " .. tostring(datapet.pet_type.petkind) .. " | " .. tostring(datapet.pet_type.variant))
            getgenv().TypeTrade = nil
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
            chatBubble("Pet not in bot inventory... Try again later.")
            notifyBackendDone(username, "Pet not in bot inventory: " .. tostring(datapet.pet_type.petkind))
            withdrawLockByUser[username] = nil
            withdrawLockTime[username]   = nil
            return false
        end

        usedUniques[petUnique] = true
        table.insert(resolvedPets, { datapet = datapet, unique = petUnique })
    end

    pendingWithdrawByUser[username] = data.pets

    local successfullyAdded = {}
    for _, entry in pairs(resolvedPets) do
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AddItemToOffer")
            :FireServer(entry.unique)
        table.insert(successfullyAdded, entry.datapet)
    end

    print("All pets found — proceeding with withdraw for: " .. username)
    task.wait(7)
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
    task.wait(1)
    UI.set_app_visibility("DialogApp", false)
end

local function confirmWithdrawByTrade(tradeId, username, withdrawItems, expectedBackendPets)
    print("----- confirmWithdrawByTrade START -----")
    print("TradeId:", tradeId)
    print("Username:", username)

    if withdrawSentByTrade[tradeId] then
        print("Already sent for trade:", tradeId)
        withdrawLockByUser[username] = nil
        withdrawLockTime[username]   = nil
        return true
    end

    if expectedBackendPets and #expectedBackendPets > 0 then
        local petsMatch = verifyWithdrawPetsMatch(expectedBackendPets, withdrawItems)
        if not petsMatch then
            warn("🚫 SECURITY: Withdraw pet mismatch detected! Trade items do not match backend request.")
            warn("   Expected from backend: " .. HttpService:JSONEncode(expectedBackendPets))
            warn("   Got in trade snapshot: " .. HttpService:JSONEncode(withdrawItems))
            withdrawLockByUser[username] = nil
            withdrawLockTime[username]   = nil
            return false
        end
    else
        warn("🚫 SECURITY: No expected pet list available for withdraw verification — blocking!")
        withdrawLockByUser[username] = nil
        withdrawLockTime[username]   = nil
        return false
    end

    local chkStatus, chkData, chkRaw = httpJSON(
        CLIENT_URL .. "/api/roblox/withdraw?username=" .. username, "GET"
    )
    if chkStatus ~= 200 or not chkData or not chkData.data or chkData.data.type ~= "WITHDRAW" then
        warn("🚫 Backend says no active withdraw for: " .. username .. " — possible duplicate, declining!")
        withdrawLockByUser[username] = nil
        withdrawLockTime[username]   = nil
        return false
    end

    if chkData.data.progress == "DONE" then
        warn("🚫 Withdraw already marked DONE for: " .. username .. " — duplicate detected, declining!")
        withdrawLockByUser[username] = nil
        withdrawLockTime[username]   = nil
        return false
    end

    local pending = pendingWithdrawByTrade[tradeId] or pendingWithdrawByUser[username]

    if type(pending) ~= "table" or #pending == 0 then
        print("No pending withdraw list for trade:", tradeId)
        withdrawSentByTrade[tradeId] = true
        return true
    end

    print("Pending withdraw count:", #pending)
    print("WithdrawItems count:", withdrawItems and #withdrawItems or 0)

    local idsByKey = {}
    for i, p in ipairs(pending) do
        local pt = p.pet_type or {}
        local k = buildKey(pt.petkind, pt.variant, pt.fly, pt.ride)
        print(string.format("[PENDING %d] id=%s petkind=%s variant=%s fly=%s ride=%s KEY=%s",
            i, tostring(p.id), tostring(pt.petkind), tostring(pt.variant), tostring(pt.fly), tostring(pt.ride), k))
        idsByKey[k] = idsByKey[k] or {}
        table.insert(idsByKey[k], p.id)
    end

    local pickedIds = {}
    for i, it in ipairs(withdrawItems or {}) do
        local k = buildKey(it.petkind, it.variant, it.fly, it.ride)
        print(string.format("[TRADE %d] petkind=%s variant=%s fly=%s ride=%s KEY=%s",
            i, tostring(it.petkind), tostring(it.variant), tostring(it.fly), tostring(it.ride), k))
        local arr = idsByKey[k]
        if arr and #arr > 0 then
            local picked = table.remove(arr, 1)
            table.insert(pickedIds, picked)
            print("  ✅ MATCHED → user_pet_id:", picked)
        else
            print("  ❌ NO MATCH for key:", k)
        end
    end

    print("PickedIds count:", #pickedIds)

    if #pickedIds == 0 then
        warn("No withdraw ids matched for trade:", tradeId)
        print("----- confirmWithdrawByTrade END (FAIL) -----")
        return false
    end

    print("Sending withdraw to backend with IDs:", table.concat(pickedIds, ", "))

    local status, data, raw = httpJSON(CLIENT_URL .. "/api/pets/withdrawpets", "POST", {
        username = tostring(username),
        pets     = pickedIds
    })

    print("Withdraw API status:", status)
    print("Withdraw API raw:", raw)

    if status ~= 200 then
        warn("withdraw confirm failed:", status, raw)
        print("----- confirmWithdrawByTrade END (API FAIL) -----")
        return false
    end

    withdrawSentByTrade[tradeId] = true
    print("✅ Withdraw declared to backend successfully.")
    print("----- confirmWithdrawByTrade END (SUCCESS) -----")
    pendingWithdrawByTrade[tradeId] = nil
    pendingWithdrawByUser[username] = nil
    withdrawLockByUser[username] = nil
    withdrawLockTime[username]   = nil

    return true
end

local function createBotProgress(username, pets, callerContext)
    callerContext = callerContext or "unknown"

    username = tostring(username or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if username == "" then
        warn("🚫 createBotProgress blocked: empty username (caller: " .. callerContext .. ")")
        return false
    end

    local lowerUsername = string.lower(username)
    if lowerUsername == string.lower(BOT1_NAME) then
        warn("🚫 SECURITY: createBotProgress blocked for bot1 username '" .. username .. "' (caller: " .. callerContext .. ")")
        return false
    end
    if lowerUsername == string.lower(getgenv().BOT2_NAME) then
        warn("🚫 SECURITY: createBotProgress blocked for bot2 username '" .. username .. "' (caller: " .. callerContext .. ")")
        return false
    end
    if lowerUsername == string.lower(getgenv().BOT3_NAME) then
        warn("🚫 SECURITY: createBotProgress blocked for bot3 username '" .. username .. "' (caller: " .. callerContext .. ")")
        return false
    end

    if type(pets) ~= "table" or #pets == 0 then
        warn("🚫 createBotProgress blocked: no pets provided for username '" .. username .. "' (caller: " .. callerContext .. ")")
        return false
    end

    print("✅ createBotProgress: creating record for user='" .. username .. "' pets=" .. #pets .. " caller=" .. callerContext)

    local status, data, raw = httpJSON(CLIENT_URL .. "/api/bot/progress", "POST", {
        from     = "bot1",
        to       = "bot1",
        username = username,
        type     = "DEPOSIT",
        pets     = pets,
        progress = "IN_PROGRESS",
        stageAt  = "bot1"
    })
    print("RAW for CREATEBOTPROGRESS: " .. raw)

    if status ~= 200 and status ~= 201 then
        warn("❌ createBotProgress API error: " .. tostring(status) .. " | " .. raw)
        return false
    end

    return true
end

-- ============================================================
-- TRADE REQUEST RECEIVED EVENT
-- ============================================================
game:GetService("ReplicatedStorage")
    :WaitForChild("API")
    :WaitForChild("TradeAPI/TradeRequestReceived")
    .OnClientEvent:Connect(function(player)
        local username = tostring(player)
        print("Trade request from:", username)

        if string.lower(username) == string.lower(BOT1_NAME) then
            warn("🚫 Rejecting trade request from bot1 itself")
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
            return
        end

        local function getTradeTypeForUser(u)
            if u == getgenv().BOT2_NAME then
                return true, "WITHDRAW"
            end

            local status, data, raw = httpJSON(CLIENT_URL .. "/api/roblox/withdraw?username=" .. u, "GET")

            if status ~= 200 or not data or not data.data or data.data.type == nil then
                local s, d, r = httpJSON(CLIENT_URL .. "/api/users/" .. u, "GET")

                if s ~= 200 or not d then
                    warn("roblox withdraw and user not found failed:", s, d)
                    return false, nil
                end

                print("STATUS: " .. s)
                local tradeType = "DEPOSIT"
                print("Trade type for " .. u .. ": " .. tostring(tradeType))
                return true, tradeType
            end

            print("STATUS: " .. status)
            local tradeType = data.data.type
            print("Trade type for " .. u .. ": " .. tostring(tradeType))
            return true, tradeType
        end

        local allowed, tradetype = getTradeTypeForUser(username)
        if not allowed then
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
        end

        if tradetype == "DEPOSIT" and allowed then
            -- ✅ QUEUE: If the deposit queue has pending records, decline the user
            -- so the bot can drain them first without getting clogged.
            if depositQueueSize() > 0 then
                warn("📦 [QUEUE] Declining DEPOSIT from '" .. username .. "' — queue has " .. depositQueueSize() .. " pending record(s)")
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                chatBubble("Bot is busy processing deposits. Please try again in a moment!")
                return
            end

            getgenv().TRADE_TYPE = "DEPOSIT"
            getgenv().IN_TRADE   = true
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(Players:WaitForChild(username), true)
            task.spawn(function()
                local startTime = tick()
                local hasReset  = false
                while tick() - startTime < 60 do
                    task.wait(1)
                    if not getgenv().IN_TRADE then return end
                    if getgenv().BOTH_NEGOTIATED and not hasReset then
                        getgenv().BOTH_NEGOTIATED = false
                        startTime = tick()
                        hasReset  = true
                        print("⏱️ Timer reset — both negotiated")
                    end
                end
                if getgenv().IN_TRADE then
                    warn("⏱️ Trade timeout — declining after 1 minute")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                    getgenv().IN_TRADE      = false
                    getgenv().TRADE_TYPE    = nil
                    getgenv().IN_TRADE_BOT2 = false
                    getgenv().CURRENT_PDATA = nil
                    chatBubble("Trade takes too long.")
                end
            end)
        end

        if tradetype == "WITHDRAW" and allowed and username == getgenv().BOT2_NAME then
            getgenv().TRADE_TYPE    = "WITHDRAW"
            getgenv().IN_TRADE      = true
            getgenv().IN_TRADE_BOT2 = true
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(Players:WaitForChild(username), true)
            game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.Visible = false

            -- ✅ FIX 3: Signal acceptedIds immediately when bot2 accepts our trade request.
            -- Previously acceptedIds was only set in the DataChanged hook (after the trade
            -- snapshot fired), which could arrive AFTER the 10s wait expired in the loop.
            -- Now we set it the moment bot2 accepts so the loop exits on the first iteration.
            if getgenv().CURRENT_PDATA and getgenv().CURRENT_PDATA.id then
                print("✅ [FIX3] Bot2 accepted trade — signalling acceptedIds for record: " .. tostring(getgenv().CURRENT_PDATA.id))
                acceptedIds[getgenv().CURRENT_PDATA.id] = true
            end

            task.spawn(function()
                local startTime = tick()
                local hasReset  = false
                while tick() - startTime < 60 do
                    task.wait(1)
                    if not getgenv().IN_TRADE then return end
                    if getgenv().BOTH_NEGOTIATED and not hasReset then
                        getgenv().BOTH_NEGOTIATED = false
                        startTime = tick()
                        hasReset  = true
                        print("⏱️ Timer reset — both negotiated")
                    end
                end
                if getgenv().IN_TRADE then
                    warn("⏱️ Trade timeout — declining after 1 minute")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                    getgenv().IN_TRADE      = false
                    getgenv().TRADE_TYPE    = nil
                    getgenv().IN_TRADE_BOT2 = false
                    getgenv().CURRENT_PDATA = nil
                    chatBubble("Trade takes too long.")
                end
            end)
        end

        if tradetype == "WITHDRAW" and allowed and username ~= getgenv().BOT2_NAME then
            -- ✅ QUEUE: Same block for withdraws — don't let a user trade interrupt
            -- the queue drain. Bot2 (the relay path) is never blocked here.
            if depositQueueSize() > 0 then
                warn("📦 [QUEUE] Declining WITHDRAW from '" .. username .. "' — queue has " .. depositQueueSize() .. " pending record(s)")
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                chatBubble("Bot is busy processing deposits. Please try again in a moment!")
                return
            end

            getgenv().TRADE_TYPE = "WITHDRAW"
            getgenv().IN_TRADE   = true
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(Players:WaitForChild(username), true)
            game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.Visible = false
            handleWithdraw(username)
            task.spawn(function()
                local startTime = tick()
                local hasReset  = false
                while tick() - startTime < 60 do
                    task.wait(1)
                    if not getgenv().IN_TRADE then return end
                    if getgenv().BOTH_NEGOTIATED and not hasReset then
                        getgenv().BOTH_NEGOTIATED = false
                        startTime = tick()
                        hasReset  = true
                        print("⏱️ Timer reset — both negotiated")
                    end
                end
                if getgenv().IN_TRADE then
                    warn("⏱️ Trade timeout — declining after 1 minute")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                    getgenv().IN_TRADE      = false
                    getgenv().TRADE_TYPE    = nil
                    getgenv().IN_TRADE_BOT2 = false
                    getgenv().CURRENT_PDATA = nil
                    withdrawLockByUser[username] = nil
                    withdrawLockTime[username]   = nil
                    chatBubble("Trade takes too long.")
                end
            end)
        end
    end)

-- ============================================================
-- DATA HOOK — watches trade state changes
-- ============================================================
local latestTradeSnapshot = {}
local finalizedTrades     = {}

game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("DataAPI/DataChanged").OnClientEvent:Connect(function(...)
    local args = table.pack(...)
    if args.n < 3 or args[2] ~= "trade" then return end

    local tradeTable = args[3]
    if typeof(tradeTable) ~= "table" then
        if getgenv().TRADE_TYPE == "WITHDRAW" then
            for lockedUser, _ in pairs(withdrawLockByUser) do
                print("🔓 Trade ended — releasing withdraw lock for: " .. lockedUser)
                withdrawLockByUser[lockedUser] = nil
                withdrawLockTime[lockedUser]   = nil
            end
        end
        getgenv().TRADE_TYPE    = nil
        getgenv().IN_TRADE      = false
        getgenv().IN_TRADE_BOT2 = false
        getgenv().IN_TRADE_BOT1 = false
        getgenv().IN_TRADE_BOT3 = false
        getgenv().CURRENT_PDATA = nil
        botNegotiatedByTrade    = {}
        return
    end

    local tradeId   = tradeTable.trade_id
    local sender    = tradeTable.sender_offer
    local recipient = tradeTable.recipient_offer
    if not (tradeId and sender and recipient) then return end

    local senderName    = tostring(sender.player_name)
    local recipientName = tostring(recipient.player_name)

    if finalizedTrades[tradeId] then return end

    local snapshot = {
        tradeId            = tradeId,
        senderName         = tostring(sender.player_name),
        recipientName      = tostring(recipient.player_name),
        senderConfirmed    = sender.confirmed    == true,
        recipientConfirmed = recipient.confirmed == true,
        senderItems        = buildOfferItems(sender),
        recipientItems     = buildOfferItems(recipient)
    }

    latestTradeSnapshot[tradeId] = snapshot

    local username = senderName

    -- -------------------------------------------------------
    -- DEPOSIT FROM USER -> BOT 1
    -- -------------------------------------------------------
    if getgenv().TRADE_TYPE == "DEPOSIT"
        and senderName ~= getgenv().BOT2_NAME
        and senderName ~= BOT1_NAME then
        getgenv().IN_TRADE = true

        if sender.negotiated then
            if not botNegotiatedByTrade[tradeId] then
                botNegotiatedByTrade[tradeId] = true
                task.wait(1)
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
            end
        else
            if botNegotiatedByTrade[tradeId] then
                print("🔄 User modified trade — resetting bot negotiation flag")
                botNegotiatedByTrade[tradeId] = false
            end
        end

        if sender.negotiated and sender.confirmed then
            getgenv().BOTH_NEGOTIATED = true
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            task.wait(1)
            UI.set_app_visibility("DialogApp", false)
        end

        if snapshot.senderConfirmed and snapshot.recipientConfirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true
            botNegotiatedByTrade[tradeId] = nil

            local depositItems       = snapshot.senderItems
            local resolvedPetTypeIds = {}

            if depositItems and #depositItems > 0 then
                local checkUrl = CLIENT_URL .. "/api/pets/checkpets"
                local s2, d2 = httpJSON(checkUrl, "POST", { pets = depositItems })

                if s2 == 200 and d2 and d2.success and d2.existing_after then
                    local idByKey = {}
                    for _, p in ipairs(d2.existing_after) do
                        local k = string.lower(p.name or "") .. "|" .. tostring(p.variant) .. "|" .. tostring(p.fly) .. "|" .. tostring(p.ride)
                        idByKey[k] = p.id
                    end
                    for _, inPet in ipairs(depositItems) do
                        local k = string.lower(inPet.petname or "") .. "|" .. tostring(inPet.variant) .. "|" .. tostring(inPet.fly) .. "|" .. tostring(inPet.ride)
                        if idByKey[k] then
                            table.insert(resolvedPetTypeIds, idByKey[k])
                        end
                    end
                end

                local depositOk = handleFindUsernamePetTypeId(username, depositItems)

                if not depositOk then
                    warn("🚫 Deposit crediting failed for '" .. username .. "' — skipping bot progress relay")
                elseif #resolvedPetTypeIds > 0 then
                    createBotProgress(username, resolvedPetTypeIds, "DEPOSIT_USER_TO_BOT1")
                    task.wait(2)
                    depositReadySignal:Fire()
                else
                    print("⚠️ No valid pet type IDs resolved — skipping createBotProgress")
                end
            else
                print("ℹ️ User gave no pets — skipping deposit and progress entirely")
            end

            markTradeDone(tradeId, true)
            notifyBackendDone(username, "DONE")
            getgenv().IN_TRADE   = false
            getgenv().TRADE_TYPE = nil
        end
    end

    -- -------------------------------------------------------
    -- DEPOSIT FROM BOT 1 -> BOT 2
    -- -------------------------------------------------------
    if recipientName == getgenv().BOT2_NAME then
        getgenv().IN_TRADE = true

        local pDataNow = pDataByTradeId[tradeId] or getgenv().CURRENT_PDATA
        if pDataNow and pDataNow.id then
            acceptedIds[pDataNow.id] = true
            pDataByTradeId[tradeId]  = pDataNow
        end

        if sender.negotiated and recipient.negotiated then
            getgenv().BOTH_NEGOTIATED = true
            task.wait(7)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            task.wait(1)
            UI.set_app_visibility("DialogApp", false)
        end

        if snapshot.senderConfirmed and snapshot.recipientConfirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true

            local pData = pDataByTradeId[tradeId]

            getgenv().CURRENT_PDATA = nil
            getgenv().IN_TRADE      = false
            getgenv().IN_TRADE_BOT2 = false

            if pData and pData.id then
                httpJSON(CLIENT_URL .. "/api/bot/progress", "POST", {
                    id       = pData.id,
                    from     = "bot1",
                    to       = "bot2",
                    type     = "DEPOSIT",
                    progress = "IN_PROGRESS",
                    stageAt  = "bot2",
                    username = string.lower(pData.username)
                })
                processingStartTime[pData.id] = nil
                acceptedIds[pData.id]          = nil
                pDataByTradeId[tradeId]        = nil
                -- ✅ FIX 5: Trade with bot2 succeeded — clear any failed stamp
                failedIds[pData.id]            = nil
                -- ✅ QUEUE: Remove from queue and immediately signal the poll loop
                -- so the next queued record starts processing without waiting 10s.
                if depositQueueRemove(pData.id) then
                    print("📦 [QUEUE] Dequeued record " .. tostring(pData.id) .. " after successful bot2 trade — " .. depositQueueSize() .. " remaining")
                    if depositQueueSize() > 0 then
                        depositReadySignal:Fire()
                        print("📦 [QUEUE] Fired depositReadySignal for next queued record")
                    end
                end
                print("✅ Progress updated to bot2 for record:", pData.id)
            else
                warn("❌ pData was nil at confirmation — progress NOT updated!")
            end

            print("✅ Bot2 trade complete:", tradeId)
        end
    end

    -- -------------------------------------------------------
    -- WITHDRAW FROM BOT 2 -> BOT 1 (BOT 1 IS THE RECIPIENT)
    -- -------------------------------------------------------
    if senderName == getgenv().BOT2_NAME then
        getgenv().IN_TRADE      = true
        getgenv().IN_TRADE_BOT2 = true

        if sender.negotiated and not sender.confirmed then
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
        end

        if sender.negotiated and recipient.negotiated then
            getgenv().BOTH_NEGOTIATED = true
            task.wait(7)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            task.wait(1)
            UI.set_app_visibility("DialogApp", false)
        end

        if snapshot.senderConfirmed and snapshot.recipientConfirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true
            getgenv().IN_TRADE      = false
            getgenv().IN_TRADE_BOT2 = false
            task.wait(2)
            withdrawReadySignal:Fire()
        end
    end

    -- -------------------------------------------------------
    -- WITHDRAW FROM BOT 1 -> USER
    -- -------------------------------------------------------
    if getgenv().TRADE_TYPE == "WITHDRAW" and senderName ~= getgenv().BOT2_NAME then
        getgenv().IN_TRADE = true

        if sender.negotiated and not botNegotiatedByTrade[tradeId] then
            local expectedBackendPets = pendingWithdrawByUser[username]
            local currentWithdrawItems = snapshot.recipientItems

            if not expectedBackendPets or #expectedBackendPets == 0 then
                warn("🚫 No expected pet list for withdraw verification — declining trade for: " .. username)
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                chatBubble("Withdraw verification failed. Please try again.")
                getgenv().IN_TRADE   = false
                getgenv().TRADE_TYPE = nil
                withdrawLockByUser[username] = nil
                withdrawLockTime[username]   = nil
                return
            end

            local petsMatch = verifyWithdrawPetsMatch(expectedBackendPets, currentWithdrawItems)
            if not petsMatch then
                warn("🚫 SECURITY: Withdraw pet mismatch at negotiation stage — declining trade for: " .. username)
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                chatBubble("Trade items do not match your withdrawal request. Trade declined.")
                getgenv().IN_TRADE   = false
                getgenv().TRADE_TYPE = nil
                withdrawLockByUser[username] = nil
                withdrawLockTime[username]   = nil
                return
            end

            print("✅ Pet verification passed at negotiation stage — accepting negotiation")
            botNegotiatedByTrade[tradeId] = true
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()

        elseif not sender.negotiated and botNegotiatedByTrade[tradeId] then
            print("🔄 User modified trade after negotiation — resetting and waiting for re-lock")
            botNegotiatedByTrade[tradeId] = false
        end

        if sender.negotiated and recipient.negotiated then
            getgenv().BOTH_NEGOTIATED = true
            task.wait(7)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
        end

        if sender.confirmed and recipient.confirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true
            botNegotiatedByTrade[tradeId] = nil

            local withdrawItems = snapshot.recipientItems
            local depositItems  = snapshot.senderItems
            local expectedBackendPets = pendingWithdrawByUser[username]

            print("⏳ Both confirmed — declaring withdraw to backend...")
            local withdrawOk = confirmWithdrawByTrade(tradeId, username, withdrawItems, expectedBackendPets)

            if withdrawOk then
                print("✅ Backend confirmed — updating progress and finishing...")

                local wStatus, wData, wRaw = httpJSON(CLIENT_URL .. "/api/roblox/withdraw?username=" .. username, "GET")
                if wStatus == 200 and wData and wData.data and wData.data.id then
                    httpJSON(CLIENT_URL .. "/api/bot/progress", "POST", {
                        id       = wData.data.id,
                        from     = "bot1",
                        to       = "user",
                        type     = "WITHDRAW",
                        progress = "DONE",
                        stageAt  = "user",
                        username = string.lower(username)
                    })
                    print("✅ Withdraw progress updated to DONE for record:", wData.data.id)
                else
                    warn("⚠️ Could not fetch withdraw record to mark DONE:", wRaw)
                end

                task.wait(1)
                UI.set_app_visibility("DialogApp", false)

                if depositItems and #depositItems > 0 then
                    print("✅ User also sent pets — processing deposit...")
                    local depositOk = handleFindUsernamePetTypeId(username, depositItems)
                    if not depositOk then
                        warn("🚫 Deposit crediting failed for '" .. username .. "' during withdraw+deposit — skipping relay")
                    end

                    local checkUrl = CLIENT_URL .. "/api/pets/checkpets"
                    local s2, d2 = httpJSON(checkUrl, "POST", { pets = depositItems })

                    if s2 == 200 and d2 and d2.success and d2.existing_after then
                        local resolvedPetTypeIds = {}
                        local idByKey = {}
                        for _, p in ipairs(d2.existing_after) do
                            local k = string.lower(p.name or "") .. "|" .. tostring(p.variant) .. "|" .. tostring(p.fly) .. "|" .. tostring(p.ride)
                            idByKey[k] = p.id
                        end
                        for _, inPet in ipairs(depositItems) do
                            local k = string.lower(inPet.petname or "") .. "|" .. tostring(inPet.variant) .. "|" .. tostring(inPet.fly) .. "|" .. tostring(inPet.ride)
                            if idByKey[k] then
                                table.insert(resolvedPetTypeIds, idByKey[k])
                            end
                        end

                        if #resolvedPetTypeIds > 0 then
                            createBotProgress(username, resolvedPetTypeIds, "WITHDRAW_PLUS_DEPOSIT")
                            task.wait(2)
                            depositReadySignal:Fire()
                        else
                            warn("⚠️ No valid pet type IDs resolved for withdraw+deposit")
                        end
                    end
                else
                    print("ℹ️ User sent no pets — skipping deposit")
                end

                markTradeDone(tradeId, true)
                notifyBackendDone(username, "DONE")
                print(("✅ Trade %s processed | withdraw=true deposit=%s"):format(tradeId, tostring(depositItems and #depositItems > 0)))
                getgenv().IN_TRADE   = false
                getgenv().TRADE_TYPE = nil
            else
                warn("❌ Backend withdraw confirmation failed after trade completed!")
                markTradeDone(tradeId, false)
                notifyBackendDone(username, "Withdraw API failed after confirmation")
                getgenv().IN_TRADE   = false
                getgenv().TRADE_TYPE = nil
                withdrawLockByUser[username] = nil
                withdrawLockTime[username]   = nil
            end
        end
    end
end)

-- ============================================================
-- POLLING SPAWN — deposit bot1 -> bot2
-- ============================================================
task.spawn(function()
    while true do
        waitOrSignal(depositReadySignal, 10)

        if getgenv().IN_TRADE == false and getgenv().CURRENT_PDATA == nil then
            for id, _ in pairs(processingIds) do
                processingIds[id]       = nil
                acceptedIds[id]         = nil
                processingStartTime[id] = nil
                print("🧹 [BOT1 DEPOSIT] Cleared ghost lock for:", id)
            end
        end

        local now = tick()
        for id, startTime in pairs(processingStartTime) do
            if now - startTime > PROCESSING_TIMEOUT then
                warn("⏱️ [BOT1 DEPOSIT] timeout — clearing stuck record:", id)
                processingIds[id]       = nil
                acceptedIds[id]         = nil
                processingStartTime[id] = nil
                if getgenv().CURRENT_PDATA and getgenv().CURRENT_PDATA.id == id then
                    getgenv().IN_TRADE      = false
                    getgenv().CURRENT_PDATA = nil
                    getgenv().IN_TRADE_BOT2 = false
                    warn("⏱️ Force-reset IN_TRADE due to stuck record:", id)
                end
            end
        end

        if getgenv().IN_TRADE == false then
            local ok, err = pcall(function()
                local urlPoll = CLIENT_URL .. "/api/bot/progress?stageAt=bot1&from=bot1&type=DEPOSIT&progress=IN_PROGRESS"
                local s, data, r = httpJSON(urlPoll, "GET")

                -- ============================================================
                -- STEP A: Fill the queue from backend records (up to QUEUE_MAX)
                -- ============================================================
                if data and #data > 0 then
                    for _, record in ipairs(data) do
                        if depositQueueSize() >= QUEUE_MAX then
                            print("📦 [QUEUE] Queue full (" .. QUEUE_MAX .. ") — not adding more records this cycle")
                            break
                        end

                        local recUser = string.lower(tostring(record.username or ""))
                        if recUser == string.lower(BOT1_NAME) then
                            warn("🚫 [POLL] Skipping record with bot1 username: " .. tostring(record.id))
                        elseif recUser == string.lower(getgenv().BOT2_NAME) then
                            warn("🚫 [POLL] Skipping record with bot2 username: " .. tostring(record.id))
                        elseif recUser == string.lower(getgenv().BOT3_NAME) then
                            warn("🚫 [POLL] Skipping record with bot3 username: " .. tostring(record.id))
                        elseif processingIds[record.id] then
                            -- already in-flight
                        elseif failedIds[record.id] then
                            -- ✅ FIX 5: Skip records that recently exhausted all attempts.
                            local age = tick() - failedIds[record.id]
                            if age < FAILED_COOLDOWN then
                                print("⏳ [FIX5] Skipping record " .. tostring(record.id) .. " — in cooldown (" .. math.floor(age) .. "/" .. FAILED_COOLDOWN .. "s)")
                            else
                                failedIds[record.id] = nil
                                print("✅ [FIX5] Cooldown expired for record " .. tostring(record.id) .. " — re-queuing")
                                depositQueuePush(record)
                            end
                        else
                            depositQueuePush(record)
                        end
                    end
                end

                -- ============================================================
                -- STEP B: Process the head of the queue
                -- ============================================================
                local pData = depositQueuePeek()
                if not pData then
                    print("📦 [QUEUE] Queue empty — nothing to process")
                    return
                end

                -- ✅ FIX 1: Verify bot2 is actually present in the server before
                -- attempting any trade requests. If bot2 is absent there is zero
                -- chance of the trade succeeding — skip immediately and release all
                -- locks so the poll loop can try again on the next cycle.
                local bot2Player = game:GetService("Players"):FindFirstChild(getgenv().BOT2_NAME)
                if not bot2Player then
                    warn("🚫 [FIX1] Bot2 (" .. getgenv().BOT2_NAME .. ") is not in the server — queue head deferred: " .. tostring(pData.id))
                    -- Don't mark as failed — bot2 might rejoin soon. Just skip this cycle.
                    return
                end
                print("✅ [FIX1] Bot2 present — processing queue head: " .. tostring(pData.id) .. " for user '" .. tostring(pData.username) .. "'")

                processingIds[pData.id]       = true
                processingStartTime[pData.id] = tick()
                acceptedIds[pData.id]          = false
                getgenv().CURRENT_PDATA        = pData
                getgenv().IN_TRADE             = true
                getgenv().IN_TRADE_BOT2        = false

                local tries = 0
                while not acceptedIds[pData.id] and tries < 5 do
                    tries = tries + 1
                    print("SENDING trade request to bot 2 (attempt " .. tries .. "/5)")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/SendTradeRequest"):FireServer(
                        game:GetService("Players"):WaitForChild(getgenv().BOT2_NAME)
                    )
                    task.wait(10)
                end

                if not acceptedIds[pData.id] then
                    warn("Bot2 did not accept after 5 tries, skipping record:", pData.id)
                    getgenv().IN_TRADE             = false
                    getgenv().CURRENT_PDATA        = nil
                    processingIds[pData.id]        = nil
                    acceptedIds[pData.id]          = nil
                    processingStartTime[pData.id]  = nil

                    -- ✅ FIX 5: Stamp the failed record so the poll loop won't
                    -- immediately re-pick it. It will be skipped for FAILED_COOLDOWN
                    -- seconds, giving bot2 time to become free / rejoin.
                    failedIds[pData.id] = tick()
                    warn("⏳ [FIX5] Record " .. tostring(pData.id) .. " placed in failedIds cooldown for " .. FAILED_COOLDOWN .. "s")

                    -- ✅ QUEUE: Remove from queue head on failure so the next record
                    -- gets a chance. The failed record re-enters after cooldown expires.
                    depositQueueRemove(pData.id)

                    -- ✅ FIX 4: Explicit backoff before the loop re-polls.
                    -- Without this the loop immediately re-polls and re-picks
                    -- the same record within milliseconds, causing a storm.
                    print("⏳ [FIX4] Backing off 30s after failed bot2 trade attempt...")
                    task.wait(30)
                    return
                end

                local successfullyAdded = {}
                local usedUniques       = {}

                for _, petId in pairs(pData.petIds) do
                    local sFindPets, dFindPets, rFindPets = httpJSON(
                        CLIENT_URL .. "/api/pets/find?id=" .. HttpService:UrlEncode(petId), "GET"
                    )

                    if dFindPets then
                        local petUnique = findPets(
                            dFindPets.petkind,
                            dFindPets.variant,
                            dFindPets.ride,
                            dFindPets.fly,
                            usedUniques
                        )

                        if petUnique then
                            usedUniques[petUnique] = true
                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AddItemToOffer"):FireServer(petUnique)
                            table.insert(successfullyAdded, petId)
                        else
                            warn("Pet not found in inventory, skipping:", petId)
                        end
                    else
                        warn("Could not fetch pet data for:", petId, rFindPets)
                    end
                end

                task.wait(7)
                print("ACCEPT NEGOTIATION TO BOT 2")

                if #successfullyAdded > 0 then
                    print("✅ Adding " .. #successfullyAdded .. " pets to offer")
                else
                    warn("⚠️ No pets found in inventory — proceeding anyway to unblock record:", pData.id)
                end

                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
                print("✅ Accepted negotiation with", #successfullyAdded, "pets")
            end)
            if not ok then
                warn("❌ Deposit loop error:", err)
                if getgenv().CURRENT_PDATA then
                    local id = getgenv().CURRENT_PDATA.id
                    processingIds[id]       = nil
                    processingStartTime[id] = nil
                    acceptedIds[id]         = nil
                end
                getgenv().IN_TRADE      = false
                getgenv().CURRENT_PDATA = nil
                task.wait(5)
            end
        end
    end
end)

-- ============================================================
-- POLLING SPAWN — withdraw bot1 -> user
-- ============================================================
task.spawn(function()
    while true do
        waitOrSignal(withdrawReadySignal, 10)

        if getgenv().IN_TRADE == false then
            local ok, err = pcall(function()
                local urlPoll = CLIENT_URL .. "/api/bot/progress?stageAt=bot1&from=bot2&type=WITHDRAW&progress=IN_PROGRESS"
                local s, data, r = httpJSON(urlPoll, "GET")

                if data and #data > 0 then
                    print("✅ Withdraw record(s) staged at bot1 — waiting for user to initiate trade")
                end
            end)
            if not ok then
                warn("❌ Withdraw loop error:", err)
                task.wait(5)
            end
        end
    end
end)

print("✅ BOT1 SECURED ready")
