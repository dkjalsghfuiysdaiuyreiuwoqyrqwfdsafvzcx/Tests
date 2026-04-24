-- BOT 2 — DEPOSIT BOT
-- petsadoptluck.com

print("STARTING BOT2")
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
getgenv().BOT1_NAME      = "adoptluckhandler"
getgenv().BOT2_NAME      = "DorisKrueger424"
getgenv().BOT3_NAME      = "JessicaVelazquez706"
getgenv().TRADE_TYPE     = nil
getgenv().TRADE_BOT2     = false
getgenv().IN_TRADE_BOT3  = false
getgenv().IN_TRADE_BOT1  = false
getgenv().CURRENT_PDATA  = nil

-- Per-record tracking tables (same fix applied to bot1)
local processingIds      = {}  -- record id -> true, prevents double-pickup
local acceptedIds        = {}  -- record id -> true, set when target bot accepts
local pDataByTradeId     = {}  -- tradeId -> pData, immune to CURRENT_PDATA timing issues

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

-- ============================================================
-- TRADE REQUEST RECEIVED
-- ============================================================
local function getTradeTypeForUser(username)
    if username == getgenv().BOT1_NAME then
        return true, "DEPOSIT"
    end
    if username == getgenv().BOT3_NAME then
        return true, "WITHDRAW"
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
            getgenv().IN_TRADE_BOT1 = true
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
                    getgenv().IN_TRADE_BOT1 = false
                    getgenv().CURRENT_PDATA = nil
                end
            end)
        end

        if tradetype == "WITHDRAW" and allowed then
            getgenv().TRADE_TYPE    = "WITHDRAW"
            getgenv().IN_TRADE      = true
            getgenv().IN_TRADE_BOT3 = true
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
                    getgenv().IN_TRADE_BOT3 = false
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
    -- DEPOSIT: BOT1 -> BOT2 (bot2 is recipient, just accept)
    -- -------------------------------------------------------
    if getgenv().TRADE_TYPE == "DEPOSIT" and senderName == getgenv().BOT1_NAME then
        getgenv().IN_TRADE      = true
        getgenv().IN_TRADE_BOT1 = true

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
            getgenv().IN_TRADE      = false
            getgenv().TRADE_TYPE    = nil
            getgenv().IN_TRADE_BOT1 = false
        end
    end

    -- -------------------------------------------------------
    -- DEPOSIT: BOT2 -> BOT3 (bot2 is sender, bot3 is recipient)
    -- polling spawn adds pets + accepts negotiation
    -- hook just confirms and updates progress
    -- -------------------------------------------------------
    if recipientName == getgenv().BOT3_NAME then
        getgenv().IN_TRADE = true

        -- ✅ Mark bot3 accepted per-record using pDataByTradeId
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

            -- ✅ Look up pData by tradeId — immune to CURRENT_PDATA race
            local pData = pDataByTradeId[tradeId]

            getgenv().CURRENT_PDATA  = nil
            getgenv().IN_TRADE       = false
            getgenv().IN_TRADE_BOT3  = false

            if pData and pData.id then
                httpJSON(CLIENT_URL .. "/api/bot/progress", "POST", {
                    id       = pData.id,
                    from     = "bot2",
                    to       = "bot3",
                    type     = "DEPOSIT",
                    progress = "DONE",
                    stageAt  = "bot3",
                    username = string.lower(pData.username)
                })
                processingIds[pData.id] = nil
                acceptedIds[pData.id]   = nil
                pDataByTradeId[tradeId] = nil
                print("✅ Progress updated to bot3 for record:", pData.id)
            else
                warn("❌ pData was nil at confirmation — progress NOT updated!")
            end

            print("✅ Bot2->Bot3 trade complete:", tradeId)
        end
    end

    -- -------------------------------------------------------
    -- WITHDRAW: BOT3 -> BOT2 (bot3 is sender, bot2 just accepts)
    -- -------------------------------------------------------
    if getgenv().TRADE_TYPE == "WITHDRAW" and senderName == getgenv().BOT3_NAME then
        getgenv().IN_TRADE      = true
        getgenv().IN_TRADE_BOT3 = true

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
            getgenv().IN_TRADE      = false
            getgenv().IN_TRADE_BOT3 = false
        end
    end

    -- -------------------------------------------------------
    -- WITHDRAW: BOT2 -> BOT1 (bot2 is sender, bot1 is recipient)
    -- polling spawn adds pets + accepts negotiation
    -- hook just confirms and updates progress
    -- -------------------------------------------------------
    if recipientName == getgenv().BOT1_NAME then
        getgenv().IN_TRADE = true

        -- ✅ Mark bot1 accepted per-record using pDataByTradeId
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

            -- ✅ Look up pData by tradeId — immune to CURRENT_PDATA race
            local pData = pDataByTradeId[tradeId]

            getgenv().CURRENT_PDATA  = nil
            getgenv().IN_TRADE       = false
            getgenv().IN_TRADE_BOT1  = false

            if pData and pData.id then
                httpJSON(CLIENT_URL .. "/api/bot/progress", "POST", {
                    id       = pData.id,
                    from     = "bot2",
                    to       = "bot1",
                    type     = "WITHDRAW",
                    progress = "DONE",
                    stageAt  = "bot1",
                    username = string.lower(pData.username)
                })
                processingIds[pData.id] = nil
                acceptedIds[pData.id]   = nil
                pDataByTradeId[tradeId] = nil
                print("✅ Progress updated to bot1 for record:", pData.id)
            else
                warn("❌ pData was nil at confirmation — progress NOT updated!")
            end

            print("✅ Bot2->Bot1 withdraw trade complete:", tradeId)
        end
    end
end)

-- ============================================================
-- POLLING SPAWN — DEPOSIT: bot2 -> bot3
-- ============================================================
task.spawn(function()
    while true do
        task.wait(60)

        if getgenv().IN_TRADE == false then
            local urlPoll = CLIENT_URL .. "/api/bot/progress?stageAt=bot2&from=bot1&type=DEPOSIT&progress=IN_PROGRESS"
            local s, data, r = httpJSON(urlPoll, "GET")

            if data and #data > 0 then
                -- ✅ Find first record not already being processed
                local pData = nil
                for _, record in ipairs(data) do
                    if not processingIds[record.id] then
                        pData = record
                        break
                    end
                end

                if not pData then
                    print("All deposit records already in-flight, skipping")
                    continue
                end

                processingIds[pData.id] = true
                acceptedIds[pData.id]   = false
                getgenv().CURRENT_PDATA = pData
                getgenv().IN_TRADE      = true
                getgenv().IN_TRADE_BOT3 = false

                local tries = 0
                while not acceptedIds[pData.id] and tries < 5 do
                    tries = tries + 1
                    print("SENDING trade request to bot 3 (attempt " .. tries .. "/5)")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/SendTradeRequest"):FireServer(
                        game:GetService("Players"):WaitForChild(getgenv().BOT3_NAME)
                    )
                    task.wait(10)
                end

                if not acceptedIds[pData.id] then
                    warn("Bot3 did not accept after 5 tries, skipping record:", pData.id)
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
                            task.wait(1)
                        else
                            warn("Pet not found in inventory:", petId)
                        end
                    else
                        warn("Could not fetch pet data for:", petId, rFindPets)
                    end
                end

                task.wait(7)
                print("ACCEPT NEGOTIATION TO BOT 3")

                if #successfullyAdded > 0 then
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
                    print("✅ Accepted negotiation with", #successfullyAdded, "pets added")
                    -- processingIds cleared in DataChanged confirmation block
                else
                    warn("No pets added, declining")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                    getgenv().IN_TRADE      = false
                    getgenv().IN_TRADE_BOT3 = false
                    getgenv().CURRENT_PDATA = nil
                    processingIds[pData.id] = nil
                    acceptedIds[pData.id]   = nil
                end
            end
        end
    end
end)

-- ============================================================
-- POLLING SPAWN — WITHDRAW: bot2 -> bot1
-- ============================================================
task.spawn(function()
    while true do
        task.wait(60)

        if getgenv().IN_TRADE == false then
            local urlPoll = CLIENT_URL .. "/api/bot/progress?stageAt=bot2&from=bot3&type=WITHDRAW&progress=IN_PROGRESS"
            local s, data, r = httpJSON(urlPoll, "GET")

            if data and #data > 0 then
                -- ✅ Find first record not already being processed
                local pData = nil
                for _, record in ipairs(data) do
                    if not processingIds[record.id] then
                        pData = record
                        break
                    end
                end

                if not pData then
                    print("All withdraw records already in-flight, skipping")
                    continue
                end

                processingIds[pData.id] = true
                acceptedIds[pData.id]   = false
                getgenv().CURRENT_PDATA = pData
                getgenv().IN_TRADE      = true
                getgenv().IN_TRADE_BOT1 = false

                local tries = 0
                while not acceptedIds[pData.id] and tries < 5 do
                    tries = tries + 1
                    print("SENDING trade request to bot 1 (attempt " .. tries .. "/5)")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/SendTradeRequest"):FireServer(
                        game:GetService("Players"):WaitForChild(getgenv().BOT1_NAME)
                    )
                    task.wait(10)
                end

                if not acceptedIds[pData.id] then
                    warn("Bot1 did not accept after 5 tries, skipping record:", pData.id)
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
                            task.wait(1)
                        else
                            warn("Pet not found in inventory:", petId)
                        end
                    else
                        warn("Could not fetch pet data for:", petId, rFindPets)
                    end
                end

                task.wait(7)
                print("ACCEPT NEGOTIATION TO BOT 1")

                if #successfullyAdded > 0 then
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
                    print("✅ Accepted negotiation with", #successfullyAdded, "pets added")
                    -- processingIds cleared in DataChanged confirmation block
                else
                    warn("No pets added, declining")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                    getgenv().IN_TRADE      = false
                    getgenv().IN_TRADE_BOT1 = false
                    getgenv().CURRENT_PDATA = nil
                    processingIds[pData.id] = nil
                    acceptedIds[pData.id]   = nil
                end
            end
        end
    end
end)

print("✅ BOT2 ready")
