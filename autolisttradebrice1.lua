

if not getgenv().ScriptRunning then
    getgenv().ScriptRunning = true


    local sound = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("SoundPlayer")
    local UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")

    sound.FX:play("BambooButton")
    UI.set_app_visibility("NewsApp", false)

    task.wait(5)

    --// DataAPI Trade Hook (prints all args + dumps any tables safely)

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local DataApiHook = ReplicatedStorage:WaitForChild("API"):WaitForChild("DataAPI/DataChanged")
    local processedTradeIds = {}   -- [tradeId] = true
    local inFlightTradeIds = {}    -- [tradeId] = true
    local TRADE_TTL = 180          -- seconds (optional cleanup)
    local tradeSeenAt = {}         -- [tradeId] = os.clock()



    local function shouldProcessTrade(tradeId)
        tradeId = tostring(tradeId or "")
        if tradeId == "" then return false end

        if processedTradeIds[tradeId] or inFlightTradeIds[tradeId] then
            return false
        end

        inFlightTradeIds[tradeId] = true
        tradeSeenAt[tradeId] = os.clock()
        return true
    end

    local function markTradeDone(tradeId, success)
        tradeId = tostring(tradeId or "")
        inFlightTradeIds[tradeId] = nil

        if success then
            processedTradeIds[tradeId] = true
        end
    end

    -- Optional cleanup (keeps memory small)
    task.spawn(function()
        while true do
            task.wait(60)
            local now = os.clock()
            for id, t in pairs(tradeSeenAt) do
                if (now - t) > TRADE_TTL then
                    tradeSeenAt[id] = nil
                    inFlightTradeIds[id] = nil
                    processedTradeIds[id] = nil
                end
            end
        end
    end)



    -- Safe table dumper (handles nested tables + cycles)
    local function printTable(tbl, indent, visited)
        indent = indent or 0
        visited = visited or {}

        if visited[tbl] then
            print(string.rep("  ", indent) .. "*CYCLE*")
            return
        end
        visited[tbl] = true

        for k, v in pairs(tbl) do
            local keyStr = tostring(k)
            local pad = string.rep("  ", indent)

            if typeof(v) == "table" then
                print(pad .. keyStr .. ": {")
                printTable(v, indent + 1, visited)
                print(pad .. "}")
            else
                print(pad .. keyStr .. ": " .. tostring(v))
            end
        end
    end

    local HttpService = game:GetService("HttpService")

    local function checkAllow(username, botId)
        local url =
            "https://roblox-deposit-o8en.vercel.app/api/houses/check"
            .. "?username=" .. HttpService:UrlEncode(tostring(username))
            .. "&botId=" .. HttpService:UrlEncode(tostring(botId))

        local response = http_request({
            Url = url,
            Method = "GET",
            Headers = {
                ["Accept"] = "application/json"
            }
        })

        if not response then
            warn("No response returned")
            return false, nil
        end

        print("Status:", response.StatusCode)
        print("Raw body:", response.Body)

        if response.StatusCode ~= 200 then
            warn("checkAllow failed", response.StatusCode)
            return false, nil
        end

        local data
        local ok = pcall(function()
            data = HttpService:JSONDecode(response.Body)
        end)

        if not ok or type(data) ~= "table" then
            warn("Failed to JSON decode body")
            return false, nil
        end

        return data.allowed
    end

    local HttpService = game:GetService("HttpService")
    local function takeHouse(username, botId)
        local payload = {
            username = tostring(username),
            botId = tostring(botId),
        }
        local url =
            "https://roblox-deposit-o8en.vercel.app/api/houses/claim"

        local response = http_request({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Accept"] = "application/json",
            },
            Body = HttpService:JSONEncode(payload),
        })

        if not response then
            warn("No response returned")
            return false, nil
        end

        print("Status:", response.StatusCode)
        print("Raw body:", response.Body)

        if response.StatusCode ~= 200 then
            warn("takeHouse failed", response.StatusCode)
            return false, response.Body
        end

        local data
        local ok = pcall(function()
            data = HttpService:JSONDecode(response.Body)
        end)

        if not ok or type(data) ~= "table" then
            warn("Failed to JSON decode body")
            return false, nil
        end

        return data.success
    end

    local function checkHouse()
        print("=============Checking House================")

        local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
        local Data = ClientData.get_data()[game.Players.LocalPlayer.Name].house_manager

        local function isExcludedHouse(name)
            local n = name:lower()
            return n == "main house" or n == "s" or n == "my christmas pudding house"
        end

        local function isMainHouse(name)
            local n = name:lower()
            return n == "main house" or n == "s"
        end

        local activeHouse = { name = nil, active = false, house_id = nil }
        local mainHouseExists = false
        local farmingHouse = { name = nil, house_id = nil }

        for _, house in pairs(Data) do
            if house.active then
                activeHouse.name = house.name
                activeHouse.active = true
                activeHouse.house_id = house.house_id or house.id
            end

            if isMainHouse(house.name) then
                mainHouseExists = true
            end

            -- Farming house must not be main house OR christmas pudding house
            if not farmingHouse.house_id and not isExcludedHouse(house.name) then
                farmingHouse.name = house.name
                farmingHouse.house_id = house.house_id or house.id
            end
        end

        if not mainHouseExists then
            -- No main house found, buy one and rename it
            print("No main house found, buying one...")
            task.wait(1)

            local buyArgs = {
                "micro_2023",
                {},
                Color3.new(0.7012181878089905, 0.3500000238418579, 1)
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/BuyHouseWithAddons"):InvokeServer(unpack(buyArgs))
            task.wait(10)

            local existingIDs = {}
            for _, house in pairs(Data) do
                existingIDs[house.house_id or house.id] = true
            end

            local freshData = ClientData.get_data()[game.Players.LocalPlayer.Name].house_manager
            local newHouseID = nil

            for _, house in pairs(freshData) do
                local id = house.house_id or house.id
                if not existingIDs[id] then
                    newHouseID = id
                    break
                end
            end

            if newHouseID then
                print("Renaming new house to 'main house'")
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/RenameHouse"):FireServer(newHouseID, "main house")
            else
                warn("Could not find newly bought house to rename.")
            end

        elseif activeHouse.active and isExcludedHouse(activeHouse.name) and farmingHouse.house_id then
            -- Active house is excluded (main/pudding), switch to farming house
            print("Switching to farming house:", farmingHouse.name)
            getgenv().TradeHouseID = farmingHouse.house_id
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/SpawnHouse"):FireServer(farmingHouse.house_id)
            task.wait(5)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ListHouse"):InvokeServer()

        elseif activeHouse.active and isExcludedHouse(activeHouse.name) and not farmingHouse.house_id then
            -- Active house is excluded but no farming house exists
            print("No farming house available to switch to!")
            local Players = game:GetService("Players")
            Players.LocalPlayer:Kick("No house left to trade!")

        else
            -- Active house is already a valid farming house, just list it
            print("Active house is not excluded, listing it.")
            getgenv().TradeHouseID = activeHouse.house_id
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ListHouse"):InvokeServer()
        end

    end

    checkHouse()

    DataApiHook.OnClientEvent:Connect(function(...)
        local args = table.pack(...)

        -- Expect: args[1]=playerName, args[2]="trade", args[3]=table (sometimes), etc.
        if args.n < 2 then return end
        if args[2] ~= "trade" then return end

        print("[CLIENT][TRADE] DataChanged")
        print("Player:", tostring(args[1]))
        print("EventType:", tostring(args[2]))

        -- Print every argument, and fully dump any table argument
        for i = 1, args.n do
            local v = args[i]
            if typeof(v) == "table" then
                print(("Argument[%d] = {"):format(i))
                printTable(v)
                print("}")
            else
                print(("Argument[%d] = %s"):format(i, tostring(v)))
            end
        end

        -- Keep your original summary logic too (optional)
        if typeof(args[3]) == "table" then
            local tradeTable = args[3]
            local tradeId = tradeTable.trade_id
            local sender = tradeTable.sender_offer
            local recipient = tradeTable.recipient_offer

            if sender and recipient then
                print("Negotiated: ", tostring(sender.negotiated))
                print("Confirmed:", tostring(sender.confirmed))

                for _, item in pairs(sender.items or {}) do
                    local props = item.properties or {}

                    local prefix =
                        (props.mega_neon and "mega")
                        or (props.neon and "neon")
                        or "normal"

                    local suffix =
                        (props.flyable and props.rideable and "flyride")
                        or (props.flyable and "fly")
                        or (props.rideable and "ride")
                        or ""

                    print("Pet:", tostring(item.kind), prefix .. (suffix ~= "" and "_" .. suffix or ""))
                end

                if sender.negotiated and not sender.confirmed then
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
                end

                if sender.negotiated and sender.confirmed then
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
                end

                if sender.confirmed and recipient.confirmed then
                    if shouldProcessTrade(tradeId) then
                        -- run the API call once
                        -- local ok, res = pcall(function()
                        --     return takeHouse(sender.player_name, recipient.player_name)
                        -- end)

                        -- local success = ok and res == true
                        local success = true
                        markTradeDone(tradeId, success)

                        if success then
                            print("House Traded (trade_id):", tradeId)
                            task.wait(10)
                            checkHouse()
                        else
                            warn("takeHouse failed for trade_id:", tradeId)
                        end
                    end
                end
                
            end
        end
    end)


    local TradeApiHook = game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/TradeRequestReceived")
    TradeApiHook.OnClientEvent:Connect(function(player)
        print("Trade request by: ", player)
        local myUser = game.Players.LocalPlayer
        -- local allowed = checkAllow(tostring(player), tostring(myUser))
        local allowed = false
        if tostring(player) == "bubblegumh" or tostring(player) == "AceCode7722" or tostring(player) == "bubblerice1" then
            allowed = true
        end

        if allowed then

            -- Accept Trade
            local args = {
                game:GetService("Players"):WaitForChild(tostring(player)),
                true
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(unpack(args))
            game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.Visible = false

        else
            -- Decline Trade
            local args = {
                game:GetService("Players"):WaitForChild(tostring(player)),
                false
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(unpack(args))
            game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.Visible = false

        end
    end)


    task.spawn(function()
        while true do
            task.wait(10)
            checkHouse()
            task.wait(600)
        end
    end)
end
