-- TIG SEND
getgenv().PlayerToTrade = "GHITTOYAH"

if not getgenv().AutoGet then
    getgenv().AutoGet = true

    -- Step 1: Discover remote router
    local router
    for _, v in next, getgc(true) do
        if type(v) == "table" and rawget(v, "get_remote_from_cache") then
            router = v
            break
        end
    end

    if not router then
        warn("Router not found. Aborting script.")
        return
    end

    -- Step 2: Rename remotes for easier access
    local function rename(remotename, hashedremote)
        hashedremote.Name = remotename
    end
    local remoteMap = debug.getupvalue(router.get_remote_from_cache, 1)
    if remoteMap then
        table.foreach(remoteMap, rename)
    end

    -- Step 3: Attempt social stones exchange
    local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    local playerData = ClientData.get_data()[game.Players.LocalPlayer.Name]
    local socialStones = playerData and playerData.social_stones_2025 or 0
    local stonesToBuy = math.floor(socialStones / 25)

    if stonesToBuy > 0 then
        local args = { "food", "butterfly_2025_snapdragon_flower", stonesToBuy }
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SocialStonesAPI/AttemptExchange"):FireServer(unpack(args))
    end

    task.wait(1)

    -- Step 4: Exchange food items
    local foodData = playerData and playerData.inventory and playerData.inventory.food or {}
    for _, item in pairs(foodData) do
        if item.id == "butterfly_2025_snapdragon_flower" then
            local args = { item.id, item.unique }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LootBoxAPI/ExchangeItemForReward"):InvokeServer(unpack(args))
            task.wait(1)
        end
    end

    task.wait(2)
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()

    -- Step 5: Begin trade license quiz
    task.wait(1)
    local fsys = require(game.ReplicatedStorage:WaitForChild("Fsys")).load
    fsys("RouterClient").get("SettingsAPI/SetBooleanFlag"):FireServer("has_talked_to_trade_quest_npc", true)
    task.wait()
    fsys("RouterClient").get("TradeAPI/BeginQuiz"):FireServer()
    task.wait(1)

    local tradeQuizManager = fsys("ClientData").get("trade_license_quiz_manager")
    if tradeQuizManager and tradeQuizManager.quiz then
        for _, question in pairs(tradeQuizManager.quiz) do
            fsys("RouterClient").get("TradeAPI/AnswerQuizQuestion"):FireServer(question.answer)
            task.wait()
        end
    else
        warn("Trade license quiz not found or failed to load.")
    end

    -- Step 6: Infinite trade loop
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CreatePetObject = ReplicatedStorage:WaitForChild("API"):WaitForChild("PetObjectAPI/CreatePetObject")
    local EquipPet = ReplicatedStorage:WaitForChild("API"):WaitForChild("ToolAPI/Equip")

    while true do
        local gifts = ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.pets or {}
        local availableBoxes = {}

        for _, gift in pairs(gifts) do
            if table.find({
                "butterfly_2025_moonbeam_butterfly",
                "butterfly_2025_amber_butterfly"
            }, gift.kind) then
                table.insert(availableBoxes, gift.unique)
            end
        end

        if #availableBoxes == 0 then
            print("No valid butterflies to trade, retrying in 10 seconds...")
            task.wait(10)
            continue
        end

        -- Begin trade session
        local playerToTrade = game:GetService("Players"):FindFirstChild(getgenv().PlayerToTrade)
        if not playerToTrade then
            warn("Target player not found. Retrying in 10 seconds...")
            task.wait(10)
            continue
        end

        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/SendTradeRequest"):FireServer(playerToTrade)
        task.wait(5)

        local toTradeCount = math.min(18, #availableBoxes)
        for i = 1, toTradeCount do
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AddItemToOffer"):FireServer(availableBoxes[i])
            task.wait(0.1)
        end

        task.wait(5)
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
        task.wait(5)
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()

        print("Traded", toTradeCount, "butterflies to", getgenv().PlayerToTrade)
        task.wait(5)
    end
end
