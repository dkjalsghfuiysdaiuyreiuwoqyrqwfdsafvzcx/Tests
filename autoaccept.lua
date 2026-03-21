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

task.wait(5)

--// DataAPI Trade Hook (prints all args + dumps any tables safely)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataApiHook = ReplicatedStorage:WaitForChild("API"):WaitForChild("DataAPI/DataChanged")
local processedTradeIds = {}   -- [tradeId] = true
local inFlightTradeIds = {}    -- [tradeId] = true
local TRADE_TTL = 180          -- seconds (optional cleanup)
local tradeSeenAt = {}         -- [tradeId] = os.clock()

DataApiHook.OnClientEvent:Connect(function(...)
    local args = table.pack(...)

    -- Expect: args[1]=playerName, args[2]="trade", args[3]=table (sometimes), etc.
    if args.n < 2 then return end
    if args[2] ~= "trade" then return end


    -- Keep your original summary logic too (optional)
    if typeof(args[3]) == "table" then
        local tradeTable = args[3]
        local tradeId = tradeTable.trade_id
        local sender = tradeTable.sender_offer
        local recipient = tradeTable.recipient_offer

        if sender and recipient then
            print("Negotiated: ", tostring(sender.negotiated))
            print("Confirmed:", tostring(sender.confirmed))

            if sender.negotiated and not sender.confirmed then
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
            end
            if sender.negotiated and sender.confirmed then
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
            end
            
        end
    end
end)


local TradeApiHook = game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/TradeRequestReceived")
TradeApiHook.OnClientEvent:Connect(function(player)
    print("Trade request by: ", player)
    local myUser = game.Players.LocalPlayer
    -- local allowed = checkAllow(tostring(player), tostring(myUser))
    local allowed = true


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
