-- BOT 3 — STORAGE BOT
-- petsadoptluck.com

print("STARTING BOT3")
task.wait(60)


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

local function teleportPlayerNeeds(x, y, z)
    if x == 0 and y == 350 and z == 0 then
        x = math.random(10, 20)
    end
    local Player = game.Players.LocalPlayer
    if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

local function createPlatform()
        local Player = game.Players.LocalPlayer
        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

        -- Count existing platforms in the workspace
        local existingPlatforms = 0
        for _, object in pairs(workspace:GetChildren()) do
            if object.Name == "CustomPlatform" then
                existingPlatforms += 1
            end
        end

        -- Check if the number of platforms exceeds 5
        if existingPlatforms >= 5 then
            --print("Maximum number of platforms reached, skipping creation.")
            return
        end

        -- Debug message
        --print("Teleport successful, creating platform...")

        -- Create the platform part
        local platform = Instance.new("Part")
        platform.Name = "CustomPlatform" -- Unique name to identify the platform
        platform.Size = Vector3.new(1100, 1, 1100) -- Size of the platform
        platform.Anchored = true -- Make sure the platform doesn't fall
        platform.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -5, 0) -- Place 5 studs below the player

        -- Set part properties
        platform.BrickColor = BrickColor.new("Bright yellow") -- You can change the color
        platform.Parent = workspace -- Parent to the workspace so it's visible
end

print("Created Platform")
teleportPlayerNeeds(0, 350, 0)
createPlatform()
task.wait(5)

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

    -- -------------------------------------------------------
    -- DEPOSIT: BOT2 -> BOT3
    -- Bot3 is just storage — accept the trade and mark DONE.
    -- No pet giving here. Only Bot1 gives pets to users.
    -- -------------------------------------------------------
    if getgenv().TRADE_TYPE == "DEPOSIT" and senderName == getgenv().BOT2_NAME then
        getgenv().IN_TRADE      = true
        getgenv().IN_TRADE_BOT2 = true

        -- Fetch pData from backend since Bot3 has no local CURRENT_PDATA for deposits
        if not pDataByTradeId[tradeId] then
            local s, data, r = httpJSON(
                CLIENT_URL .. "/api/bot/progress?stageAt=bot3&from=bot2&type=DEPOSIT&progress=IN_PROGRESS", "GET"
            )
            if data and #data > 0 then
                pDataByTradeId[tradeId] = data[1]
                print("✅ Fetched pData for trade:", tradeId, "| username:", data[1].username)
            else
                warn("⚠️ Could not fetch pData from backend for trade:", tradeId)
            end
        end

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

        if snapshot.senderConfirmed and snapshot.recipientConfirmed and not finalizedTrades[tradeId] then
            finalizedTrades[tradeId] = true

            local pData = pDataByTradeId[tradeId]

            if pData and pData.id then
                -- ✅ Bot3 is storage only — just mark DONE, never give pets to user
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
                pDataByTradeId[tradeId] = nil
                print("✅ Deposit complete — pets stored at Bot3 for:", pData.username)
            else
                warn("❌ pData was nil at confirmation — progress NOT updated!")
            end

            getgenv().IN_TRADE      = false
            getgenv().TRADE_TYPE    = nil
            getgenv().IN_TRADE_BOT2 = false
            getgenv().CURRENT_PDATA = nil
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

task.wait(90)

-- ============================================================
-- POLLING SPAWN — WITHDRAW: bot3 -> bot2
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
                        return
                    end

                    processingIds[pData.id] = true
                    acceptedIds[pData.id]   = false
                    getgenv().CURRENT_PDATA = pData
                    getgenv().IN_TRADE      = true
                    getgenv().IN_TRADE_BOT2 = false
                    -- 🔥 SAFETY: verify all pets are actually in Bot3's inventory before sending trade
                    local allPetsFound = true
                    local verifyUniques = {}
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
                                verifyUniques
                            )
                            if petUnique then
                                verifyUniques[petUnique] = true
                            else
                                warn("⚠️ Pet not in Bot3 inventory yet, aborting:", petId)
                                allPetsFound = false
                                break
                            end
                        else
                            warn("⚠️ Could not fetch pet data for:", petId)
                            allPetsFound = false
                            break
                        end
                    end

                    if not allPetsFound then
                        warn("⏳ Not all pets arrived at Bot3 yet — requeueing in 15s")
                        getgenv().IN_TRADE      = false
                        getgenv().CURRENT_PDATA = nil
                        processingIds[pData.id] = nil
                        acceptedIds[pData.id]   = nil
                        task.wait(15)
                        withdrawReadySignal:Fire() -- retry soon
                        return
                    end

                    -- only now send the trade request
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
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/DeclineTrade"):FireServer()
                        getgenv().IN_TRADE      = false
                        getgenv().CURRENT_PDATA = nil
                        processingIds[pData.id] = nil
                        acceptedIds[pData.id]   = nil
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
-- withdraw requests and fires withdrawReadySignal immediately.
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
