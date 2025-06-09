-- TIG SEND
getgenv().PlayerToTrade = "GHITTOYAH"
if not getgenv().AutoGet then
    getgenv().AutoGet = true

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
    
    local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    local SocialStones = ClientData.get_data()[game.Players.LocalPlayer.Name].social_stones_2025
    local StonesToBuy = math.floor(SocialStones / 25)

    if StonesToBuy > 0 then
        local args = {
            "food",
            "butterfly_2025_snapdragon_flower",
            StonesToBuy
        }
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SocialStonesAPI/AttemptExchange"):FireServer(unpack(args))
    end

    task.wait(1)
    local FoodData = ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.food
    task.wait(3)

    for x, y in pairs(FoodData) do
        if y.id == "butterfly_2025_snapdragon_flower" then
            local args = {
                "butterfly_2025_snapdragon_flower",
                y.unique
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LootBoxAPI/ExchangeItemForReward"):InvokeServer(unpack(args))
            task.wait(1)
        end
    end

    task.wait(2)
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()
    
    -- Trade License
    task.wait(1)
    fsys = require(game.ReplicatedStorage:WaitForChild("Fsys")).load
    fsys("RouterClient").get("SettingsAPI/SetBooleanFlag"):FireServer("has_talked_to_trade_quest_npc", true)
    task.wait()
    fsys("RouterClient").get("TradeAPI/BeginQuiz"):FireServer()
    task.wait(1)

    for i, v in pairs(fsys('ClientData').get("trade_license_quiz_manager")["quiz"]) do
        fsys("RouterClient").get("TradeAPI/AnswerQuizQuestion"):FireServer(v["answer"])
        task.wait()
    end

    local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local CreatePetObject = ReplicatedStorage:WaitForChild("API"):WaitForChild("PetObjectAPI/CreatePetObject")
    local EquipPet = ReplicatedStorage:WaitForChild("API"):WaitForChild("ToolAPI/Equip")
    
    -- 🔁 Infinite trade loop
    while true do
        local gifts = ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.pets
        local availableBoxes = {}
    
        for _, gift in pairs(gifts) do
            if gift.kind == "butterfly_2025_prismatic_butterfly" or gift.kind == "butterfly_2025_amber_butterfly" or gift.kind == "butterfly_2025_blue_butterfly" or gift.kind == "butterfly_2025_seafoam_butterfly" then
                table.insert(availableBoxes, gift.unique)
            end
        end
    
        if #availableBoxes == 0 then
            print("No kaijunior boxes found, retrying...")
            task.wait(10)
            continue
        end
    
        -- 🔄 One trade session (up to 18 boxes)
        local args = {
            [1] = game:GetService("Players"):WaitForChild(getgenv().PlayerToTrade)
        }
    
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/SendTradeRequest"):FireServer(unpack(args))
        task.wait(5)
    
        local toTradeCount = math.min(18, #availableBoxes)
        for i = 1, toTradeCount do
            local args = {
                [1] = availableBoxes[i]
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AddItemToOffer"):FireServer(unpack(args))
            task.wait(0.1)
        end
    
        -- Accept and confirm trade
        task.wait(5)
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
        task.wait(5)
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
    
        print("Traded", toTradeCount, "kaijunior boxes.")
        task.wait(5) -- wait before starting a new trade session
    end    

end
