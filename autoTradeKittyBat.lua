getgenv().PlayerToTrade = "ghiaxis28"
-- TIG SEND

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
        if pet.id == "halloween_2025_bat_cat" then
            table.insert(saruUniques, pet.unique)
        end
    end
    
    -- Only feed 16 or less depending on available pets and potions
    local targetCount = 18
    local maxRuns = math.min(targetCount, #saruUniques, math.floor(#potions / 7))
    
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
    
        -- Get 6 potions
        local potionChunk = {}
        for j = 1, 7 do
            table.insert(potionChunk, table.remove(potions, 1))
        end
        local uniqueIdPotion = table.remove(potions, 1)

        if #potionChunk < 7 or not uniqueIdPotion then
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
        local pets = ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.pets
        local availableBoxes = {}
    
        for _, pet in pairs(pets) do
            if pet.kind == "halloween_2025_bat_cat" then
                table.insert(availableBoxes, pet.unique)
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

