local router

for i, v in next, getgc(true) do
    if type(v) == 'table' and rawget(v, 'get_remote_from_cache') then
        router = v
    end
end

local function rename(remotename, hashedremote)
    hashedremote.Name = remotename
end
-- Apply renaming to upvalues of the RouterClient.init function
table.foreach(debug.getupvalue(router.get_remote_from_cache, 1), rename)

local sound = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("SoundPlayer")
local UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")

sound.FX:play("BambooButton")
UI.set_app_visibility("NewsApp", false)

if not getgenv().ScriptRunning then
    getgenv().ScriptRunning = true
    print("Script running")

    local TIMEOUT = 120 -- 10 minutes (600 seconds)
    local lastActivity = os.clock()

    -- Call this whenever "something happens"
    local function markActivity()
        lastActivity = os.clock()
    end


    function teleportToHouse()
        task.wait(2)
        local Players = game:GetService("Players")

        for _, player in ipairs(Players:GetPlayers()) do
            if tostring(player.Name) ~= "PixelW0lf8_55Ne0n541" and tostring(player.Name) ~= "bubblegumh" and tostring(player.Name) ~= "bubblerice1" and tostring(player.Name) ~= "GHITTOYAH" and tostring(player.Name) ~= "ghiaxis28" then
            -- if player.Name == "bubblegumh" then
                getgenv().fsysCore = require(game:GetService("ReplicatedStorage").ClientModules.Core.InteriorsM.InteriorsM)
                local targetCFrame = CFrame.new(-275.9091491699219, 25.812084197998047, -1548.145751953125, -0.9798217415809631, 0.0000227206928684609, 0.19986890256404877, -0.000003862579433189239, 1, -0.00013261348067317158, -0.19986890256404877, -0.00013070966815575957, -0.9798217415809631)
                local OrigThreadID = getthreadidentity()
                task.wait(1)
                setidentity(2)
                task.wait(1)
                fsysCore.enter_smooth("housing", "MainDoor", {
                    house_owner = game:GetService("Players"):WaitForChild(tostring(player.Name))
                })
                setidentity(OrigThreadID)

                task.wait(1)

                print("Sending house trade")
                local args = {
                    game:GetService("Players"):WaitForChild(tostring(player.Name)),
                    "house_trade"
                }
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/SendTradeRequest"):FireServer(unpack(args))
                markActivity()
                break
                -- print(player.Name)
            end
            
        end
    end
    teleportToHouse()


    task.spawn(function()
        task.wait(2)
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
    end)

    --// DataAPI Trade Hook (prints all args + dumps any tables safely)

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local DataApiHook = ReplicatedStorage:WaitForChild("API"):WaitForChild("DataAPI/DataChanged")
    local processedTradeIds = {}   -- [tradeId] = true
    local inFlightTradeIds = {}    -- [tradeId] = true
    local TRADE_TTL = 180          -- seconds (optional cleanup)
    local tradeSeenAt = {}         -- [tradeId] = os.clock()

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



    -- This runs in background watching inactivity
    task.spawn(function()
        while true do
            task.wait(5) -- check every 5 seconds (cheap)

            if os.clock() - lastActivity >= TIMEOUT then
                print("⚠️ Nothing happened for 2 minutes!")
                teleportToHouse()
                -- DO YOUR ACTION HERE
                -- Example:
                -- kick player
                -- restart loop
                -- teleport
                -- reconnect

                break -- remove if you want it to keep watching
            end
        end
    end)


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

            task.wait(5)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()

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

                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()

                if recipient.negotiated then
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
                end

                if recipient.negotiated and recipient.confirmed then
                    if shouldProcessTrade(tradeId) then
                        task.wait(1)
                        --RENAME HOUSE
                        local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        local Data = ClientData.get_data()[game.Players.LocalPlayer.Name].house_manager

                        for _, house in pairs(Data) do
                            -- Track the active house (if any)
                            if house.active then
                                print("ACTIVE:", house.house_id)
                                local args = {
                                    house.house_id,
                                    getgenv().HouseName
                                }
                                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/RenameHouse"):FireServer(unpack(args))
                            end
                        end
                        print("Teleporting to another house")
                        task.wait(1)
                        teleportToHouse()
                    end
                end
            end
        end
    end)

end
