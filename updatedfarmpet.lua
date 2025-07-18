
-- TIG SEND
getgenv().PlayerToTrade = "ghiaxis28"
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
    local playerName = game.Players.LocalPlayer.Name
    local playerData = ClientData.get_data()[playerName]

    local coins = 0
    if playerData and playerData.cranky_coins_2025 then
        coins = tonumber(playerData.cranky_coins_2025) or 0
        coins = coins / 13000
    else
        warn("Missing or invalid cranky_coins_2025 for player:", playerName)
        return
    end

    local maxPerBuy = 99
    local remainingBoxes = math.floor(coins) -- ✅ Correct: no overbuying

    while remainingBoxes > 0 do
        local buyAmount = math.min(remainingBoxes, maxPerBuy)

        local args = {
            "gifts",
            "summerfest_2025_kelp_raider_box",
            {
                buy_count = buyAmount
            }
        }

        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ShopAPI/BuyItem"):InvokeServer(unpack(args))

        remainingBoxes = remainingBoxes - buyAmount

        task.wait(0.2) -- Small wait to avoid possible rate limiting
    end

    print("All kelp raider boxes bought.")

    --get box id
    local giftData = ClientData.get_data()[playerName].inventory.gifts

    for x, y in pairs(giftData) do
        if y.id == "summerfest_2025_kelp_raider_box" then
            local args = {
                "summerfest_2025_kelp_raider_box",
                x
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LootBoxAPI/ExchangeItemForReward"):InvokeServer(unpack(args))

        end
        task.wait(.1)
    end


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
    
    -- Collect potions
    local food = ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.food
    local potions = {}
    for _, item in pairs(food) do
        if item.id == "pet_age_potion" then
            table.insert(potions, item.unique)
        end
    end
    
    -- Collect Super Sarus
    local petsdata = ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.pets
    local saruUniques = {}
    for _, pet in pairs(petsdata) do
        if pet.id == "summerfest_2025_kelp_captain" and pet.properties.age < 6 then
            table.insert(saruUniques, pet.unique)
        end
    end
    
    -- Only feed 16 or less depending on available pets and potions
    local targetCount = 3
    local maxRuns = math.min(targetCount, #saruUniques, math.floor(#potions / 10))
    
    print("⚙️ Feeding " .. maxRuns .. " Super Sarus with 10 potions each")
    
    for i = 1, maxRuns do
        local petUnique = saruUniques[i]
    
        -- Equip Saru
        local equipArgs = {
            [1] = petUnique,
            [2] = { use_sound_delay = true, equip_as_last = false }
        }
    
        local equipped = pcall(function()
            return EquipPet:InvokeServer(unpack(equipArgs))
        end)
    
        if equipped then
            print("✅ Equipped Super Saru #" .. i .. ": " .. petUnique)
        else
            warn("❌ Failed to equip Super Saru #" .. i)
            continue
        end
    
        task.wait(3)
    
        -- Get 10 potions
        local potionChunk = {}
        for j = 1, 9 do
            table.insert(potionChunk, table.remove(potions, 1))
        end
        local uniqueIdPotion = table.remove(potions, 1)
    
        if #potionChunk < 9 or not uniqueIdPotion then
            warn("❌ Not enough potions for Super Saru #" .. i)
            break
        end
    
        -- Feeding Args
        local args = {
            [1] = "__Enum_PetObjectCreatorType_2",
            [2] = {
                additional_consume_uniques = potionChunk,
                pet_unique = petUnique,
                unique_id = uniqueIdPotion
            }
        }
    
        local success, result = pcall(function()
            return CreatePetObject:InvokeServer(unpack(args))
        end)
    
        if success then
            print("🎉 Success: Fed Super Saru #" .. i)
        else
            warn("❌ Failed to feed Super Saru #" .. i, result)
        end
    
        task.wait(10)
    end
    
    print("🏁 Feeding process complete!")

    task.wait(20)
    
    -- 🔁 Infinite trade loop
    while true do
        local gifts = ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.pets
        local availableBoxes = {}
    
        for _, gift in pairs(gifts) do
            if gift.kind == "summerfest_2025_kelp_captain" then
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






-- TIG ACCEPT
if not getgenv().AutoGet then
    getgenv().AutoGet = true
    -- Rename hashed remotes
    local router
    for i, v in next, getgc(true) do
        if type(v) == 'table' and rawget(v, 'get_remote_from_cache') then
            router = v
            break
        end
    end

    local function rename(remotename, hashedremote)
        hashedremote.Name = remotename
    end
    for name, remote in pairs(debug.getupvalue(router.get_remote_from_cache, 1)) do
        rename(name, remote)
    end

    -- Services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    local TextChatService = game:GetService("TextChatService")
    local chatChannel = TextChatService.TextChannels.RBXGeneral
    local UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")

    while true do
        local textLabel = LocalPlayer:FindFirstChild("PlayerGui")
            and LocalPlayer.PlayerGui:FindFirstChild("DialogApp")
            and LocalPlayer.PlayerGui.DialogApp.Dialog.NormalDialog.Info.TextLabel

        if textLabel then
            local text = textLabel.Text
            UI.set_app_visibility("DialogApp", false)

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    print("Attempting trade with:", player.Name)

                    local success, err = pcall(function()
                        local args = {
                            [1] = player,
                            [2] = true
                        }

                        ReplicatedStorage:WaitForChild("API"):WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(unpack(args))
                        task.wait(3)

                        ReplicatedStorage:WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
                        task.wait(1)

                        ReplicatedStorage:WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
                        task.wait(1)
                    end)

                    if not success then
                        warn("Trade with " .. player.Name .. " failed: " .. tostring(err))
                    end

                    UI.set_app_visibility("DialogApp", true)
                    task.wait(1) -- Short pause before next player
                end
            end
        end

        task.wait(1) -- Repeat after a short delay
    end

end
