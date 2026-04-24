-- BOT 1 — DEPOSIT BOT
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

local processingIds  = {}  -- record id -> true, prevents double-pickup
local acceptedIds    = {}  -- record id -> true, set when bot2 accepts
-- KEY FIX: store pData by tradeId so the DataChanged hook can always find it
-- regardless of timing or when CURRENT_PDATA global gets cleared
local pDataByTradeId = {}

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
                if ride == true and pet.properties.rideable then
                    if fly == true and pet.properties.flyable then return pet.unique end
                    return pet.unique
                end
                if fly == true and pet.properties.flyable then
                    if ride == true and pet.properties.rideable then return pet.unique end
                    return pet.unique
                end
                if ride == false and fly == false then return pet.unique end
            end
            if variant == "NEON" and pet.properties.neon then
                if ride == true and pet.properties.rideable then
                    if fly == true and pet.properties.flyable then return pet.unique end
                    return pet.unique
                end
                if fly == true and pet.properties.flyable then
                    if ride == true and pet.properties.rideable then return pet.unique end
                    return pet.unique
                end
                if ride == false and fly == false then return pet.unique end
            end
            if variant == "NORMAL" and not pet.properties.neon and not pet.properties.mega_neon then
                if ride == true and pet.properties.rideable then
                    if fly == true and pet.properties.flyable then return pet.unique end
                    return pet.unique
                end
                if fly == true and pet.properties.flyable then
                    if ride == true and pet.properties.rideable then return pet.unique end
                    return pet.unique
                end
                if ride == false and fly == false then return pet.unique end
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
    print("Giving Pets Now")
    local url = CLIENT_URL .. "/api/pets/addpetstouser"
    local status, data, raw = httpJSON(url, "POST", {
        userId = userId,
        username = username,
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

local function describeItem(item)
    local props = item.properties or {}
    local variant = "NORMAL"
    if props.mega_neon then variant = "MEGA"
    elseif props.neon then variant = "NEON" end
    return {
        petname = ConvertPetName(tostring(item.kind)),
        variant = variant,
        petkind = tostring(item.kind),
        fly = props.flyable == true,
        ride = props.rideable == true
    }
end

local function buildOfferItems(offer)
    local out = {}
    for _, item in pairs(offer.items or {}) do
        table.insert(out, describeItem(item))
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
        admin_code           = getgenv().ADMIN_CODE,
        username             = string.lower(username),
        status               = "DONE",
        type                 = "DONE",
        lastRequestFinished  = true,
        note                 = note or "DONE"
    })
end

local pendingWithdrawByUser  = {}
local pendingWithdrawByTrade = {}
local withdrawSentByTrade    = {}

local function buildKey(petkind, variant, fly, ride)
    return string.lower(tostring(petkind or "")) .. "|" .. string.upper(tostring(variant or "NORMAL")) .. "|" ..
               tostring(fly == true) .. "|" .. tostring(ride == true)
end

local function handleWithdraw(username)
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
        return false
    end

    local successfullyAdded = {}
    local usedUniques = {}

    for _, datapet in pairs(data.pets) do
        local petUnique = findPets(
            datapet.pet_type.petkind,
            datapet.pet_type.variant,
            datapet.pet_type.ride,
            datapet.pet_type.fly,
            usedUniques
        )

        if petUnique then
            usedUniques[petUnique] = true
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AddItemToOffer")
                :FireServer(petUnique)
            table.insert(successfullyAdded, datapet)
        else
            warn("Pet not in bot inventory, skipping: " .. tostring(datapet.pet_type.petkind) .. " | " .. tostring(datapet.pet_type.variant))
        end
    end

    print("Handling Withdraw for the User")
    print("Giving pets to the user")
    task.wait(7)
    if #successfullyAdded > 0 then
        pendingWithdrawByUser[username] = successfullyAdded
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
        task.wait(3)
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
        task.wait(1)
        UI.set_app_visibility("DialogApp", false)
    else
        warn("No pets could be added for withdrawal, declining trade")
        getgenv().TypeTrade = nil
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
        chatBubble("Pet not in bot inventory... Try again later")
        notifyBackendDone(username, "Pet not in bot inventory")
    end
end

local function confirmWithdrawByTrade(tradeId, username, withdrawItems)
    print("----- confirmWithdrawByTrade START -----")
    print("TradeId:", tradeId)
    print("Username:", username)

    if withdrawSentByTrade[tradeId] then
        print("Already sent for trade:", tradeId)
        return true
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

    return true
end

-- ============================================================
-- TRADE REQUEST RECEIVED
-- ============================================================
local function getTradeTypeForUser(username)
    if username == getgenv().BOT2_NAME then
        return true, "WITHDRAW"
    end

    local status, data, raw = httpJSON(CLIENT_URL .. "/api/cookie/getcookies", "POST", {
        admin_code = getgenv().ADMIN_CODE,
        username   = username
    })

    if status ~= 200 or not data or not data.result or #data.result == 0 then
        local s, d, r = httpJSON(CLIENT_URL .. "/api/users/" .. username, "GET")

        if s ~= 200 or not d then
            warn("getcookies and user not found failed:", s, d)
            return false, nil
        end

        print("STATUS: " .. s)
        local tradeType = "DEPOSIT"
        print("Trade type for " .. username .. ": " .. tostring(tradeType))
        return true, tradeType
    end
    print("STATUS: " .. status)
    local tradeType = data.result[1].type
    print("Trade type for " .. username .. ": " .. tostring(tradeType))
    return true, tradeType
end

local function createBotProgress(username, pets)
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

        local allowed, tradetype = getTradeTypeForUser(username)
        if not allowed then
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
        end

        if tradetype == "DEPOSIT" and allowed then
            getgenv().TRADE_TYPE = "DEPOSIT"
            getgenv().IN_TRADE   = true
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
                    chatBubble("Trade takes too long.")
                end
            end)
        end

        if tradetype == "WITHDRAW" and allowed and username ~= getgenv().BOT2_NAME then
            getgenv().TRADE_TYPE = "WITHDRAW"
            getgenv().IN_TRADE   = true
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(Players:WaitForChild(username), true)
            game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.Visible = false
            handleWithdraw(username)
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
        getgenv().TRADE_TYPE    = nil
        getgenv().IN_TRADE      = false
        getgenv().IN_TRADE_BOT2 = false
        getgenv().IN_TRADE_BOT1 = false
        getgenv().IN_TRADE_BOT3 = false
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
    -- DEPOSIT FROM USER -> BOT 1
    -- -------------------------------------------------------
    if getgenv().TRADE_TYPE == "DEPOSIT" and senderName ~= getgenv().BOT2_NAME then
        getgenv().IN_TRADE = true

        if sender.negotiated and not sender.confirmed then
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
        end
        if sender.negotiated and sender.confirmed then
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            task.wait(1)
            UI.set_app_visibility("DialogApp", false)
        end

        if snapshot.senderConfirmed and snapshot.recipientConfirmed then
            finalizedTrades[tradeId] = true
            local depositItems = snapshot.senderItems

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

                handleFindUsernamePetTypeId(username, depositItems)
            end

            createBotProgress(username, resolvedPetTypeIds)

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

        -- ✅ Mark bot2 accepted using the record id stored by tradeId
        local pDataNow = pDataByTradeId[tradeId] or getgenv().CURRENT_PDATA
        if pDataNow and pDataNow.id then
            acceptedIds[pDataNow.id] = true
            -- Also store by tradeId in case it wasn't already
            pDataByTradeId[tradeId] = pDataNow
        end

        if sender.negotiated and recipient.negotiated then
            task.wait(7)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            task.wait(1)
            UI.set_app_visibility("DialogApp", false)
        end

        if snapshot.senderConfirmed and snapshot.recipientConfirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true

            -- ✅ Look up pData by tradeId — immune to CURRENT_PDATA being cleared
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
                processingIds[pData.id]  = nil
                acceptedIds[pData.id]    = nil
                pDataByTradeId[tradeId]  = nil
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

        -- FIX: removed premature IN_TRADE/IN_TRADE_BOT2 clear from here
        -- Only send ConfirmTrade here; clearing happens after both sides confirmed below
        if sender.negotiated and recipient.negotiated then
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            task.wait(1)
            UI.set_app_visibility("DialogApp", false)
        end

        -- ✅ Only clear after BOTH sides confirmed
        if snapshot.senderConfirmed and snapshot.recipientConfirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true
            getgenv().IN_TRADE      = false
            getgenv().IN_TRADE_BOT2 = false
        end
    end

    -- -------------------------------------------------------
    -- WITHDRAW FROM BOT 1 -> USER
    -- -------------------------------------------------------
    if getgenv().TRADE_TYPE == "WITHDRAW" and senderName ~= getgenv().BOT2_NAME then
        getgenv().IN_TRADE = true

        if sender.confirmed and recipient.confirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true

            local withdrawItems = snapshot.recipientItems

            print("⏳ Both confirmed — declaring withdraw to backend before confirming trade...")
            local withdrawOk = confirmWithdrawByTrade(tradeId, username, withdrawItems)

            if withdrawOk then
                print("✅ Backend confirmed — confirming trade in-game...")
                task.wait(1)
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
                task.wait(1)
                UI.set_app_visibility("DialogApp", false)

                local depositItems = snapshot.senderItems
                local depositOk    = true
                if depositItems and #depositItems > 0 then
                    depositOk = handleFindUsernamePetTypeId(username, depositItems)
                end

                markTradeDone(tradeId, depositOk)
                notifyBackendDone(username, "DONE")
                print(("✅ Trade %s processed | withdraw=true deposit=%s"):format(tradeId, tostring(depositOk)))
                getgenv().IN_TRADE = false
            else
                warn("❌ Backend withdraw failed — cancelling trade!")
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                markTradeDone(tradeId, false)
                notifyBackendDone(username, "Withdraw API failed - trade cancelled")
            end
        end
    end
end)

-- ============================================================
-- POLLING SPAWN — deposit bot1 -> bot2
-- ============================================================
task.spawn(function()
    while true do
        task.wait(60)

        if getgenv().IN_TRADE == false then
            local urlPoll = CLIENT_URL .. "/api/bot/progress?stageAt=bot1&from=bot1&type=DEPOSIT&progress=IN_PROGRESS"
            local s, data, r = httpJSON(urlPoll, "GET")

            if data and #data > 0 then
                -- ✅ Find first record NOT already being processed
                local pData = nil
                for _, record in ipairs(data) do
                    if not processingIds[record.id] then
                        pData = record
                        break
                    end
                end

                if not pData then
                    print("All pending records already in-flight, skipping")
                    continue
                end

                processingIds[pData.id] = true  -- mark as in-flight
                acceptedIds[pData.id]   = false -- reset accepted flag for this record
                getgenv().CURRENT_PDATA = pData
                getgenv().IN_TRADE      = true
                getgenv().IN_TRADE_BOT2 = false

                local tries = 0
                while not acceptedIds[pData.id] and tries < 5 do
                    tries = tries + 1
                    print("SENDING trade request to bot 2")
                    -- ✅ Store pData by tradeId BEFORE firing so the hook can find it instantly
                    -- We don't know the tradeId yet, so we use CURRENT_PDATA as fallback in the hook
                    -- The hook will write pDataByTradeId[tradeId] = pData when it fires
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
                    continue
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
                    -- ✅ processingIds[pData.id] is cleared in the DataChanged confirmation block above
                else
                    warn("No pets added, declining")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                    chatBubble("No pets added")
                    getgenv().IN_TRADE      = false
                    getgenv().IN_TRADE_BOT2 = false
                    getgenv().CURRENT_PDATA = nil
                    processingIds[pData.id] = nil  -- ✅ clear on failure
                end
            end
        end
    end
end)

print("✅ BOT1 ready")
