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

getgenv().ADMIN_CODE   = "raprapissuperdupergwapo"
getgenv().IN_TRADE     = false
getgenv().BOT1_NAME    = "adoptluckhandler"
getgenv().BOT2_NAME    = "DorisKrueger424"
getgenv().BOT3_NAME    = "JessicaVelazquez706"
getgenv().TRADE_TYPE = nil
getgenv().TRADE_BOT2 = false
getgenv().IN_TRADE_BOT3 = false
getgenv().IN_TRADE_BOT1 = false
getgenv().CURRENT_PDATA = nil

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
local inFlightTradeIds = {}
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
        tradeType = "DEPOSIT"
        return true, tradeType
    end
    if username == getgenv().BOT3_NAME then
        tradeType = "WITHDRAW"
        return true, tradeType
    end
    
    return false
end
-- After AcceptOrDeclineTradeRequest, start a timeout
task.spawn(function()
    local timeoutTradeId = nil
    local startTime = tick()
    
    while tick() - startTime < 60 do
        task.wait(1)
        -- Check if trade completed or was finalized
        if not getgenv().IN_TRADE then
            return -- Trade finished normally
        end
    end
    
    -- 1 minute passed, still in trade — decline it
    if getgenv().IN_TRADE then
        warn("⏱️ Trade timeout — declining after 1 minute")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
        getgenv().IN_TRADE = false
        getgenv().TRADE_TYPE = nil
        getgenv().IN_TRADE_BOT2 = false
        getgenv().CURRENT_PDATA = nil
    end
end)
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
            getgenv().IN_TRADE = true
            getgenv().IN_TRADE_BOT1 = true
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(Players:WaitForChild(username), true)
            -- ⏱️ Start 1-minute timeout AFTER accepting
            task.spawn(function()
                local startTime = tick()
                while tick() - startTime < 60 do
                    task.wait(1)
                    if not getgenv().IN_TRADE then return end
                end
                if getgenv().IN_TRADE then
                    warn("⏱️ Trade timeout — declining after 1 minute")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                    getgenv().IN_TRADE = false
                    getgenv().TRADE_TYPE = nil
                    getgenv().IN_TRADE_BOT2 = false
                    getgenv().CURRENT_PDATA = nil
                    chatBubble("Trade takes too long.")
                end
            end)
        end

        if tradetype == "WITHDRAW" and allowed then
            getgenv().TRADE_TYPE = "WITHDRAW"
            getgenv().IN_TRADE = true
            getgenv().IN_TRADE_BOT3 = true
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(Players:WaitForChild(username), true)
            -- ⏱️ Start 1-minute timeout AFTER accepting
            task.spawn(function()
                local startTime = tick()
                while tick() - startTime < 60 do
                    task.wait(1)
                    if not getgenv().IN_TRADE then return end
                end
                if getgenv().IN_TRADE then
                    warn("⏱️ Trade timeout — declining after 1 minute")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                    getgenv().IN_TRADE = false
                    getgenv().TRADE_TYPE = nil
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
local finalizedTrades = {}

game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("DataAPI/DataChanged").OnClientEvent:Connect(function(...)
    local args = table.pack(...)
    if args.n < 3 or args[2] ~= "trade" then return end

    local tradeTable = args[3]
    if typeof(tradeTable) ~= "table" then 
        getgenv().TRADE_TYPE = nil
        getgenv().IN_TRADE = false
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
    local senderConfirmed  = sender.confirmed    == true
    local recipConfirmed   = recipient.confirmed == true

    if finalizedTrades[tradeId] then return end
    local snapshot = {
        tradeId = tradeId,
        senderName = tostring(sender.player_name),
        recipientName = tostring(recipient.player_name),
        senderConfirmed = sender.confirmed == true,
        recipientConfirmed = recipient.confirmed == true,
        senderItems = buildOfferItems(sender),
        recipientItems = buildOfferItems(recipient)
    }

    latestTradeSnapshot[tradeId] = snapshot
    local username = snapshot.senderName


    -- DEPOSIT FLOW

    -- DEPOSIT BOT 1 -> BOT 2 (BOT 1 IS SENDER) (BOT 2 IS THE RECIPIENT)
    -- WE JUST NEED TO ACCEPT THE TRADE FROM THE BOT 1
    if getgenv().TRADE_TYPE == "DEPOSIT" and senderName == getgenv().BOT1_NAME then
        getgenv().IN_TRADE = true
        getgenv().IN_TRADE_BOT1 = true

        if sender.negotiated and not sender.confirmed then
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
        end
        if sender.negotiated and sender.confirmed then
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            getgenv().IN_TRADE = false
            getgenv().TRADE_TYPE = nil
            getgenv().IN_TRADE_BOT1 = false
        end
    end

    -- DEPOSIT BOT 2 -> BOT 3 (BOT 2 IS THE SENDER) (BOT 3 IS THE RECIPIENT)
    -- WE ACCEPTED THE NEGOTIATION IN THE POLLING SPAWN
    if recipientName == getgenv().BOT3_NAME then
        getgenv().IN_TRADE = true
        getgenv().IN_TRADE_BOT3 = true

        -- SENDER IS BOT 2
        if sender.negotiated and recipient.negotiated and not recipient.confirmed then
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
        end

        -- IF BOT 2 AND BOT 3 CONFIRMED
        if snapshot.senderConfirmed and snapshot.recipientConfirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true

            local pData = getgenv().CURRENT_PDATA
            if pData then
                -- ✅ Only now update progress for this specific record
                httpJSON(CLIENT_URL .. "/api/bot/progress", "POST", {
                    id       = pData.id,
                    from     = "bot2",
                    to       = "bot3",
                    type     = "DEPOSIT",
                    progress = "DONE",
                    stageAt  = "bot3",
                    username = string.lower(pData.username)
                })
                print("✅ Progress updated to bot3 for record:", pData.id)
            end

            getgenv().IN_TRADE = false
            getgenv().IN_TRADE_BOT3 = false
            getgenv().CURRENT_PDATA = nil
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            print("✅ Bot2 trade complete:", tradeId)
        end
    end


    -- WITHDRAW FLOW:
    -- WITHDRAW BOT 3 -> BOT 2 (BOT 3 IS THE SENDER)
    -- WE JUST HAVE TO ACCEPT NEGOTIATION IF BOT 3 ACCEPTED NEGOTIATION
    -- WE JUST HAVE TO CONFIRM IF BOT 3 CONFIRMED
    if getgenv().TRADE_TYPE == "WITHDRAW" and senderName == getgenv().BOT3_NAME then
        getgenv().IN_TRADE = true
        getgenv().IN_TRADE_BOT3 = true

        if sender.negotiated and not sender.confirmed then
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
        end

        if sender.negotiated and sender.confirmed then
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            getgenv().IN_TRADE = false
            getgenv().IN_TRADE_BOT3 = false
        end
    end

    -- WITHDRAW BOT 2 -> BOT 1 (BOT 1 IS THE RECIPIENT)
    -- WE GAVE THE PETS AND ACCEPTED NEGOTIATION IN THE POLLING SPAWN
    if recipientName == getgenv().BOT1_NAME then
        getgenv().IN_TRADE = true
        getgenv().IN_TRADE_BOT1 = true

        -- SENDER IS BOT 2
        if sender.negotiated and recipient.negotiated and not recipient.confirmed then
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
        end

        -- IF BOT 2 AND BOT 3 CONFIRMED
        if snapshot.senderConfirmed and snapshot.recipientConfirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true

            local pData = getgenv().CURRENT_PDATA
            if pData then
                -- ✅ Only now update progress for this specific record
                httpJSON(CLIENT_URL .. "/api/bot/progress", "POST", {
                    id       = pData.id,
                    from     = "bot2",
                    to       = "bot1",
                    type     = "DEPOSIT",
                    progress = "DONE",
                    stageAt  = "bot1",
                    username = string.lower(pData.username)
                })
                print("✅ Progress updated to bot1 for record:", pData.id)
            end

            getgenv().IN_TRADE = false
            getgenv().IN_TRADE_BOT1 = false
            getgenv().CURRENT_PDATA = nil
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            print("✅ Bot2 trade complete:", tradeId)
        end
    end
end)

-- FOR DEPOSITING TO BOT 3
-- GIVING THE PETS TO BOT 3
task.spawn(function()
    while true do
        task.wait(60)
        if getgenv().IN_TRADE == false then
            local urlPoll = CLIENT_URL .. "/api/bot/progress?stageAt=bot2&from=bot1&type=DEPOSIT&progress=IN_PROGRESS"
            local s, data, r = httpJSON(urlPoll, "GET")

            if data and #data > 0 then
                -- ✅ Only take the FIRST record, not all of them
                local pData = data[1]
                
                getgenv().CURRENT_PDATA = pData  -- ✅ store so DataHook can use it
                getgenv().IN_TRADE = true  -- ✅ lock immediately so loop doesn't pick up another
                getgenv().IN_TRADE_BOT3 = false

                -- Keep sending trade request until bot3 accepts (max 5 tries)
                local tries = 0
                while not getgenv().IN_TRADE_BOT3 and tries < 5 do
                    tries = tries + 1
                    print("SENDING trade request to bot 3 (attempt " .. tries .. "/5)")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/SendTradeRequest"):FireServer(
                        game:GetService("Players"):WaitForChild(getgenv().BOT3_NAME)
                    )
                    task.wait(10)
                end

                -- ✅ If bot3 never accepted after 5 tries, skip this record and unlock
                if not getgenv().IN_TRADE_BOT3 then
                    warn("Bot3 did not accept after 5 tries, skipping record:", pData.id)
                    getgenv().IN_TRADE = false
                    getgenv().CURRENT_PDATA = nil
                    continue  -- skip to next loop iteration
                end

                -- Now add pets for this single record
                local successfullyAdded = {}
                local usedUniques = {}

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

                print("ACCEPT NEGOTIATION TO BOT 3")
                task.wait(7)
                -- ✅ Only accept negotiation after ALL pets are added
                if #successfullyAdded > 0 then
                    -- task.wait(5)
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
                    print("✅ Accepted negotiation with", #successfullyAdded, "pets added")
                    -- ❌ remove the progress update from here
                else
                    warn("No pets added, declining")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                    getgenv().IN_TRADE = false
                    getgenv().IN_TRADE_BOT3 = false
                    getgenv().CURRENT_PDATA = nil
                end
            end
        end
    end
end)

-- FOR WITHDRAW TO BOT 1
-- GIVING THE PETS TO BOT 1
task.spawn(function()
    while true do
        task.wait(60)

        if getgenv().IN_TRADE == false then
            local urlPoll = CLIENT_URL .. "/api/bot/progress?stageAt=bot2&from=bot3&type=WITHDRAW&progress=IN_PROGRESS"
            local s, data, r = httpJSON(urlPoll, "GET")

            if data and #data > 0 then
                -- ✅ Only take the FIRST record, not all of them
                local pData = data[1]
                
                getgenv().CURRENT_PDATA = pData  -- ✅ store so DataHook can use it
                getgenv().IN_TRADE = true  -- ✅ lock immediately so loop doesn't pick up another
                getgenv().IN_TRADE_BOT1 = false

                -- Keep sending trade request until bot1 accepts (max 5 tries)
                local tries = 0
                while not getgenv().IN_TRADE_BOT1 and tries < 5 do
                    tries = tries + 1
                    print("SENDING trade request to bot 1 (attempt " .. tries .. "/5)")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/SendTradeRequest"):FireServer(
                        game:GetService("Players"):WaitForChild(getgenv().BOT1_NAME)
                    )
                    task.wait(10)
                end

                -- ✅ If bot1 never accepted after 5 tries, skip this record and unlock
                if not getgenv().IN_TRADE_BOT1 then
                    warn("Bot2 did not accept after 5 tries, skipping record:", pData.id)
                    getgenv().IN_TRADE = false
                    getgenv().CURRENT_PDATA = nil
                    continue  -- skip to next loop iteration
                end

                -- Now add pets for this single record
                local successfullyAdded = {}
                local usedUniques = {}

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

                print("ACCEPT NEGOTIATION TO BOT 1")
                task.wait(7)
                -- ✅ Only accept negotiation after ALL pets are added
                if #successfullyAdded > 0 then
                    -- task.wait(5)
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
                    print("✅ Accepted negotiation with", #successfullyAdded, "pets added")
                    -- ❌ remove the progress update from here
                else
                    warn("No pets added, declining")
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                    local pData = getgenv().CURRENT_PDATA
                    if pData then
                        -- ✅ Only now update progress for this specific record
                        httpJSON(CLIENT_URL .. "/api/bot/progress", "POST", {
                            id       = pData.id,
                            from     = "bot2",
                            to       = "bot1",
                            type     = "DEPOSIT",
                            progress = "DONE",
                            stageAt  = "bot1",
                            username = string.lower(pData.username)
                        })
                        print("✅ Progress updated to bot1 for record:", pData.id)
                    end

                    getgenv().IN_TRADE = false
                    getgenv().IN_TRADE_BOT1 = false
                    getgenv().CURRENT_PDATA = nil
                    print("✅ Bot1 trade declined due to no pets but still changed the progress status:")
                end
            end
        end
    end
end)

print("✅ BOT2 ready")
