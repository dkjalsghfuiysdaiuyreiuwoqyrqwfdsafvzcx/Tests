-- BOT 3 — DEPOSIT BOT
-- petsadoptluck.com

print("STARTING BOT3")
task.wait(1)

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
game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()

task.wait(10)

-- ============================================================
-- SERVICES & CONSTANTS
-- ============================================================
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player     = Players.LocalPlayer
local CLIENT_URL = "https://petsadoptluck.com"

getgenv().ADMIN_CODE     = "raprapissuperdupergwapo"
getgenv().IN_TRADE       = false
getgenv().BOT2_NAME      = "DorisKrueger424"
getgenv().BOT3_NAME      = "JessicaVelazquez706"
getgenv().TRADE_TYPE     = nil
getgenv().TRADE_BOT2     = false
getgenv().IN_TRADE_BOT2  = false
getgenv().CURRENT_PDATA  = nil

local processingIds  = {}
local acceptedIds    = {}
local pDataByTradeId = {}

-- ============================================================
-- 🔥 FORCE-POLL SIGNALS
-- withdrawReadySignal: fires when a new withdraw record appears at bot3
--                      → wakes bot3->bot2 polling loop early
-- ============================================================
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

    print("Finding User now")
    local userUrl = CLIENT_URL .. "/api/users/" .. HttpService:UrlEncode(username)
    local status1, data1, raw1 = httpJSON(userUrl, "GET")
    print("STATUS 1:", status1)

    if data1 and data1.user and data1.user.id then
        print("USER ID:", data1.user.id)
    else
        warn("User data missing")
        print("Raw response:", raw1)
    end
    if status1 ~= 200 or not data1 then
        warn("User lookup failed:", status1, raw1)
        return false
    end

    local userId = data1.userId or (data1.user and data1.user.id)
    if not userId then
        warn("userId missing in response:", raw1)
        return false
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
    return {
        petname = name,
        variant = variant,
        petkind = kind,
        fly  = props.flyable  == true,
        ride = props.rideable == true
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
    httpJSON(CLIENT_URL .. "/api/cookie/updatecookie", "POST", {
        admin_code          = getgenv().ADMIN_CODE,
        username            = string.lower(username),
        status              = "DONE",
        type                = "DONE",
        lastRequestFinished = true,
        note                = note or "DONE"
    })
end

-- ============================================================
-- TRADE REQUEST RECEIVED
-- ============================================================
local function getTradeTypeForUser(username)
    if username == getgenv().BOT2_NAME then
        return true, "DEPOSIT"
    end
    return false, nil
end

game:GetService("ReplicatedStorage")
    :WaitForChild("API")
    :WaitForChild("TradeAPI/TradeRequestReceived")
    .OnClientEvent:Connect(function(player)
        local username = tostring(player)
        print("Trade request from:", username)

        local allowed, tradetype = getTradeTypeForUser(username)
        if not allowed then
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
            return
        end

        if tradetype == "DEPOSIT" and allowed then
            getgenv().TRADE_TYPE    = "DEPOSIT"
            getgenv().IN_TRADE      = true
            getgenv().IN_TRADE_BOT2 = true
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(Players:WaitForChild(username), true)
            task.spawn(function()
                local startTime = tick()
                while tick() - startTime < 60 do
                    task.wait(1)
                    if not getgenv().IN_TRADE then return end
                end
                if getgenv().IN_TRADE then
                    warn("⏱️ Trade timeout — declining after 1 minute")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                    getgenv().IN_TRADE      = false
                    getgenv().TRADE_TYPE    = nil
                    getgenv().IN_TRADE_BOT2 = false
                    getgenv().CURRENT_PDATA = nil
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
        getgenv().TRADE_TYPE    = nil
        getgenv().IN_TRADE      = false
        getgenv().IN_TRADE_BOT2 = false
        getgenv().CURRENT_PDATA = nil
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
    local username = snapshot.senderName

    -- -------------------------------------------------------
    -- DEPOSIT: BOT2 -> BOT3 (bot3 is recipient, just accept)
    -- -------------------------------------------------------
    if getgenv().TRADE_TYPE == "DEPOSIT" and senderName == getgenv().BOT2_NAME then
        getgenv().IN_TRADE      = true
        getgenv().IN_TRADE_BOT2 = true

        if sender.negotiated and not sender.confirmed then
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
        end
        if sender.negotiated and sender.confirmed then
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            task.wait(1)
            UI.set_app_visibility("DialogApp", false)
        end

        -- ✅ Only clear after both confirmed
        if snapshot.senderConfirmed and snapshot.recipientConfirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true

            -- Bot3 is the final destination — give pets to the user
            local depositItems = snapshot.senderItems
            if depositItems and #depositItems > 0 then
                handleFindUsernamePetTypeId(username, depositItems)
            end

            getgenv().IN_TRADE      = false
            getgenv().TRADE_TYPE    = nil
            getgenv().IN_TRADE_BOT2 = false
        end
    end

    -- -------------------------------------------------------
    -- WITHDRAW: BOT3 -> BOT2 (bot3 sends pets back to bot2)
    -- -------------------------------------------------------
    if recipientName == getgenv().BOT2_NAME then
        getgenv().IN_TRADE = true

        local pDataNow = pDataByTradeId[tradeId] or getgenv().CURRENT_PDATA
        if pDataNow and pDataNow.id then
            acceptedIds[pDataNow.id] = true
            pDataByTradeId[tradeId]  = pDataNow
        end

        if sender.negotiated and recipient.negotiated then
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            task.wait(1)
            UI.set_app_visibility("DialogApp", false)
        end

        if snapshot.senderConfirmed and snapshot.recipientConfirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true

            local pData = pDataByTradeId[tradeId]

            getgenv().CURRENT_PDATA  = nil
            getgenv().IN_TRADE       = false
            getgenv().IN_TRADE_BOT2  = false

            if pData and pData.id then
                httpJSON(CLIENT_URL .. "/api/bot/progress", "POST", {
                    id       = pData.id,
                    from     = "bot3",
                    to       = "bot2",
                    type     = "WITHDRAW",
                    progress = "IN_PROGRESS",
                    stageAt  = "bot2",
                    username = string.lower(pData.username)
                })
                processingIds[pData.id] = nil
                acceptedIds[pData.id]   = nil
                pDataByTradeId[tradeId] = nil
                print("✅ Progress updated to bot2 for record:", pData.id)
            else
                warn("❌ pData was nil at confirmation — progress NOT updated!")
            end

            print("✅ Bot3->Bot2 withdraw trade complete:", tradeId)
        end
    end
end)

-- ============================================================
-- POLLING SPAWN — WITHDRAW: bot3 -> bot2
-- 🔥 waitOrSignal replaces task.wait(60) — wakes early via withdrawReadySignal
-- ============================================================
task.spawn(function()
    while true do
        waitOrSignal(withdrawReadySignal, 10)

        if getgenv().IN_TRADE == false then
            local ok, err = pcall(function()
                local urlPoll = CLIENT_URL .. "/api/bot/progress?stageAt=bot3&from=website&type=WITHDRAW&progress=IN_PROGRESS"
                local s, data, r = httpJSON(urlPoll, "GET")

                if data and #data > 0 then
                    local pData = nil
                    for _, record in ipairs(data) do
                        if not processingIds[record.id] then
                            pData = record
                            break
                        end
                    end

                    if not pData then
                        print("All withdraw records already in-flight, skipping")
                        return  -- was: continue
                    end

                    processingIds[pData.id] = true
                    acceptedIds[pData.id]   = false
                    getgenv().CURRENT_PDATA = pData
                    getgenv().IN_TRADE      = true
                    getgenv().IN_TRADE_BOT2 = false

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
                        getgenv().IN_TRADE      = false
                        getgenv().CURRENT_PDATA = nil
                        processingIds[pData.id] = nil
                        acceptedIds[pData.id]   = nil
                        return  -- was: continue
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
                                task.wait(1)
                            else
                                warn("Pet not found in inventory:", petId)
                            end
                        else
                            warn("Could not fetch pet data for:", petId, rFindPets)
                        end
                    end

                    task.wait(7)
                    print("ACCEPT NEGOTIATION TO BOT 2")

                    if #successfullyAdded > 0 then
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
                        print("✅ Accepted negotiation with", #successfullyAdded, "pets added")
                    else
                        warn("No pets added, declining")
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                        getgenv().IN_TRADE      = false
                        getgenv().IN_TRADE_BOT2 = false
                        getgenv().CURRENT_PDATA = nil
                        processingIds[pData.id] = nil
                        acceptedIds[pData.id]   = nil
                    end
                end
            end)
            if not ok then
                warn("❌ Withdraw loop error:", err)
                if getgenv().CURRENT_PDATA then
                    local id = getgenv().CURRENT_PDATA.id
                    processingIds[id] = nil
                    acceptedIds[id]   = nil
                end
                getgenv().IN_TRADE      = false
                getgenv().IN_TRADE_BOT2 = false
                getgenv().CURRENT_PDATA = nil
                task.wait(5)
            end
        end
    end
end)

-- ============================================================
-- 🔥 WEBSITE WITHDRAW WATCHER — polls every 5s for new website-originated
-- withdraw requests and fires withdrawReadySignal immediately so bot3
-- doesn't have to wait up to 60s to notice a new withdrawal.
-- ============================================================
task.spawn(function()
    local knownIds = {}
    while true do
        task.wait(5)
        if getgenv().IN_TRADE == false then
            local ok, err = pcall(function()
                local s, data, r = httpJSON(
                    CLIENT_URL .. "/api/bot/progress?stageAt=bot3&from=website&type=WITHDRAW&progress=IN_PROGRESS", "GET"
                )
                if data and #data > 0 then
                    for _, record in ipairs(data) do
                        if not knownIds[record.id] and not processingIds[record.id] then
                            knownIds[record.id] = true
                            print("🔔 New website withdraw detected:", record.id, "— waking polling loop")
                            withdrawReadySignal:Fire()
                            break
                        end
                    end
                end
            end)
            if not ok then
                warn("❌ Website withdraw watcher error:", err)
                task.wait(5)
            end
        end
    end
end)

print("✅ BOT3 ready")
