getgenv().PlayerToTrade = "ghiaxis28"


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

local sound = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("SoundPlayer")
local UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")
task.wait(2)
sound.FX:play("BambooButton")
UI.set_app_visibility("NewsApp", false)

task.wait(5)

getgenv().fsysCore = require(game:GetService("ReplicatedStorage").ClientModules.Core.InteriorsM.InteriorsM)
local function teleportToMainmap()
	local targetCFrame = CFrame.new(-275.9091491699219, 25.812084197998047, -1548.145751953125, -0.9798217415809631, 0.0000227206928684609, 0.19986890256404877, -0.000003862579433189239, 1, -0.00013261348067317158, -0.19986890256404877, -0.00013070966815575957, -0.9798217415809631)
	local OrigThreadID = getthreadidentity()
	task.wait(1)
	setidentity(2)
	task.wait(1)
	fsysCore.enter_smooth("MainMap", "MainDoor", {
		["spawn_cframe"] = targetCFrame * CFrame.Angles(0, 0, 0)
	})
	setidentity(OrigThreadID)
end
teleportToMainmap()

task.wait(2)

-- TIG SEND
if not getgenv().AutoGet then
    getgenv().AutoGet = true

    local jewelsCount = 0

    local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    local playerName = game.Players.LocalPlayer.Name
    local toysData = ClientData.get_data()[playerName].inventory.toys

    for _, item in pairs(toysData) do
        if item.id == 'summerfest_2025_priceless_jewel' then
            jewelsCount = jewelsCount + 1
        end
    end

    local pricelessCount = math.floor(jewelsCount / 5)
    print(pricelessCount)

    local args = {
        "pets",
        "summer_2025_emperor_shrimp",
        {
            buy_count = pricelessCount
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ShopAPI/BuyItem"):InvokeServer(unpack(args))


    --convert jewels and shrimp to priceless shrimp

    local furniture = workspace.HouseInteriors.furniture
    local targetId = nil

    for _, item in ipairs(furniture:GetChildren()) do
        if item:FindFirstChild("summer_2025_priceless_shrimp") then
            -- Now get the last part of the Name, like "f-41"
            local fullName = item.Name
            targetId = string.match(fullName, "([^/]+)$")
            break
        end
    end


    if targetId then
        for i = 1, pricelessCount do
            local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
            local playerName = game.Players.LocalPlayer.Name
            local data = ClientData.get_data()[playerName]
            -- Get emperor shrimp unique
            local emperorShrimp
            for _, item in pairs(data.inventory.pets) do
                if item.id == 'summer_2025_emperor_shrimp' then
                    emperorShrimp = item.unique
                    break
                end
            end

            -- Get 5 jewel uniques
            local jewels = {}
            local jewelCounter = 0
            for _, item in pairs(data.inventory.toys) do
                if item.id == 'summerfest_2025_priceless_jewel' then
                    table.insert(jewels, item.unique)
                    jewelCounter += 1
                    if jewelCounter >= 5 then
                        break
                    end
                end
            end

            -- Make sure we have what we need
            if emperorShrimp and #jewels >= 5 then
                local args = {
                    targetId,
                    "UseBlock",
                    {
                        r_1 = emperorShrimp,
                        r_2 = jewels[1],
                        r_3 = jewels[2],
                        r_4 = jewels[3],
                        r_5 = jewels[4],
                        r_6 = jewels[5],
                    },
                    game:GetService("Players").LocalPlayer.Character
                }

                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ActivateInteriorFurniture"):InvokeServer(unpack(args))
                task.wait(0.1)
            else
                warn("Not enough shrimp or jewels at iteration", i)
                break
            end
        end

    else
        warn("❌ Could not find summer_2025_priceless_shrimp in furniture.")
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
        if pet.id == "summer_2025_priceless_shrimp" and pet.properties.age < 6 then
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
            if gift.kind == "summer_2025_priceless_shrimp" then
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

