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
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local PlayerGui = Player:FindFirstChildOfClass("PlayerGui") or CoreGui
local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)

local function createPlatform()
    local Player = game.Players.LocalPlayer
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local existingPlatforms = 0
    for _, object in pairs(workspace:GetChildren()) do
        if object.Name == "CustomPlatform" then
            existingPlatforms += 1
        end
    end
    if existingPlatforms >= 5 then
        --print("Maximum number of platforms reached, skipping creation.")
        return
    end

    -- Create the platform part
    local platform = Instance.new("Part")
    platform.Name = "CustomPlatform" -- Unique name to identify the platform
    platform.Size = Vector3.new(1100, 1, 1100) -- Size of the platform
    platform.Anchored = true -- Make sure the platform doesn't fall
    platform.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -5, 0) -- Place 5 studs below the player

    -- Set part properties
    platform.BrickColor = BrickColor.new("Bright yellow") -- You can change the color
    platform.Parent = workspace -- Parent to the workspace so it's visible
end


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

local function teleportPlayerNeeds(x, y, z)
    local Player = game.Players.LocalPlayer
    if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z) 
    else
        --print("Player or character not found!")
    end
end

local function BabyJump()
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/ExitSeatStates"):FireServer()
end

local function GetFurniture(furnitureName)
    local furnitureFolder = workspace.HouseInteriors.furniture

    if furnitureFolder then
        for _, child in pairs(furnitureFolder:GetChildren()) do
            if child:IsA("Folder") then
                for _, grandchild in pairs(child:GetChildren()) do
                    if grandchild:IsA("Model") then
                        if grandchild.Name == furnitureName then
                            local furnitureUniqueValue = grandchild:GetAttribute("furniture_unique")
                            --print("Grandchild Model:", grandchild.Name)
                            --print("furniture_unique:", furnitureUniqueValue)
                            return furnitureUniqueValue
                        end
                    end
                end
            end
        end
    end
end

local function getCurrentMoney()
    local currentMoneyText = Player.PlayerGui.BucksIndicatorApp.CurrencyIndicator.Container.Amount.Text
    local sanitizedMoneyText = currentMoneyText:gsub(",", ""):gsub("%s+", "")
    local currentMoney = tonumber(sanitizedMoneyText)
    if currentMoney == nil then
        return 0
    end
    return currentMoney
end
getgenv().BedID = GetFurniture("EggCrib")
getgenv().ShowerID = GetFurniture("StylishShower")
getgenv().PianoID = GetFurniture("Piano")
getgenv().WaterID = GetFurniture("PetWaterBowl")
getgenv().FoodID = GetFurniture("PetFoodBowl")
getgenv().ToiletID = GetFurniture("Toilet")
getgenv().LureID = GetFurniture("Lures2023NormalLure")

-- Get current money
local startingMoney = getCurrentMoney()
local function buyItems()
    if BedID == nil then 
        if startingMoney > 100 then
            --print("Buying required crib")
            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(33.5, 0, -30) * CFrame.Angles(-0, -1.57, 0)},["kind"] = "egg_crib"}})
            task.wait(1)
            getgenv().BedID = GetFurniture("EggCrib")
            startingMoney = getCurrentMoney()
        else 
            print("Not Enough money to buy bed.")
        end
    end 
    if ShowerID == nil then
        if startingMoney > 13 then
            --print("Buying Required Shower")
            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(34.5, 0, -8.5) * CFrame.Angles(0, 1.57, 0)},["kind"] = "stylishshower"}})
            task.wait(1)
            getgenv().ShowerID = GetFurniture("StylishShower")
            startingMoney = getCurrentMoney()
        else
            print("Not Enough money to buy shower")
        end
    end 
    if PianoID == nil then
        if startingMoney > 100 then
            --print("Buying Required Piano")
            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(7.5, 7.5, -5.5) * CFrame.Angles(-1.57, 0, -0)},["kind"] = "piano"}})
            task.wait(1)
            getgenv().PianoID = GetFurniture("Piano")
            startingMoney = getCurrentMoney()
        else
            print("Not Enough money to buy piano")
        end
    end 
    if WaterID == nil then 
        if startingMoney > 80 then
            --print("Buying required crib")
            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(30.5, 0, -20) * CFrame.Angles(-0, -1.57, 0)},["kind"] = "pet_water_bowl"}})
            task.wait(1)
            getgenv().WaterID = GetFurniture("PetWaterBowl")
            startingMoney = getCurrentMoney()
        else
            print("Not Enough money to buy water")
        end
    end
    if FoodID == nil then 
        if startingMoney > 80 then
            --print("Buying required crib")
            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(30.5, 0, -20) * CFrame.Angles(-0, -1.57, 0)},["kind"] = "pet_food_bowl"}})
            task.wait(1)
            getgenv().FoodID = GetFurniture("PetFoodBowl")
            startingMoney = getCurrentMoney()
        else
            print("Not Enough money to buy food")
        end
    end
    if ToiletID == nil then 
        if startingMoney > 9 then
            --print("Buying required crib")
            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(30.5, 0, -20) * CFrame.Angles(-0, -1.57, 0)},["kind"] = "toilet"}})
            task.wait(1)
            getgenv().ToiletID = GetFurniture("Toilet")
            startingMoney = getCurrentMoney()
        else
            print("Not Enough money to buy toilet")
        end
    end
    if LureID == nil then
        local args = {
            [1] = {
                [1] = {
                    ["kind"] = "lures_2023_normal_lure",
                    ["properties"] = {
                        ["cframe"] = CFrame.new(14.699951171875, 0, -24.599609375, 1, -3.82137093032941e-15, 8.742277657347586e-08, 3.82137093032941e-15, 1, 0, -8.742277657347586e-08, 0, 1)
                    }
                }
            }
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/BuyFurnitures"):InvokeServer(unpack(args))   
        getgenv().LureID = GetFurniture("Lures2023NormalLure")
    end 
end

-- Helper function to remove an item from a table by its value
local function removeItemByValue(tbl, value)
    for i = 1, #tbl do
        if tbl[i] == value then
            table.remove(tbl, i)
            break
        end
    end
end

local PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
local BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
local FirstTableArray = {}
local SecondTableArray = {}
local BabyAilmentsArray = {}

local function getAilments(tbl)
    
    task.wait(1)

    FirstTableArray = {}
    SecondTableArray = {}

    -- Directly access the table for petToEquip
    local firstPetAilments = tbl[petToEquip]
    if firstPetAilments then
        for _, subValue in pairs(firstPetAilments) do
            if subValue.kind == "mystery" or subValue.kind == "pet_me" then
                print("")
            else
                table.insert(FirstTableArray, subValue.kind)
            end
            
            --print("First table ailment added: ", subValue.kind)
        end
    else
        --print("No ailments found for", petToEquip)
    end

    -- Directly access the table for petToEquipSecond
    if getgenv().DoublePet then
        local secondPetAilments = tbl[petToEquipSecond]
        if secondPetAilments then
            for _, subValue in pairs(secondPetAilments) do
                if subValue.kind == "mystery" or subValue.kind == "pet_me" then
                    print("")
                else
                    table.insert(SecondTableArray, subValue.kind)
                end
                --print("Second table ailment added: ", subValue.kind)
            end
        else
            print("No ailments found for", petToEquipSecond)
        end
    end

    -- Print summary
    print("First table has", #FirstTableArray, "ailments")
    if getgenv().DoublePet then
        --print("Second table has", #SecondTableArray, "ailments")
    end
end


local function EatDrink(isEquippedPet)
    if isEquippedPet then
        
    end
    task.wait(1)
    if table.find(FirstTableArray, "hungry") or table.find(SecondTableArray, "hungry") then
        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
        
        task.wait(1)
        
        if getgenv().FoodID then
            -- Handle first pet hunger
            if table.find(FirstTableArray, "hungry") then     
                local attempts = 0
                local success = false
                repeat
                    attempts = attempts + 1
                    local petChar = fsys.get("pet_char_wrappers")[1]["char"]
                    local callSuccess, callResult = pcall(function()
                        if not petChar then
                            error("petChar is nil")
                        end
                        return game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(
                            game:GetService("Players").LocalPlayer,
                            getgenv().FoodID,
                            "UseBlock",
                            {['cframe'] = CFrame.new(
                                game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0)
                            )},
                            petChar
                        )
                    end)
                    if callSuccess then
                        success = true
                    else
                        print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                        task.wait(0.3)
                    end
                until success or attempts >= 5
            
                if not success then
                    warn("Failed to activate furniture after " .. attempts .. " attempts.")
                end
            
                local t = 0
                repeat 
                    task.wait(1)
                    t = t + 1
                until not hasTargetAilment("hungry", petToEquip) or t == 60  -- Check only first table
                
                removeItemByValue(FirstTableArray, "hungry")
            end
            
            
            -- Handle second pet hunger
            if table.find(SecondTableArray, "hungry") then             
                
                local attempts = 0
                local success = false
                repeat
                    attempts = attempts + 1
                    local petChar = fsys.get("pet_char_wrappers")[2]["char"]
                    local callSuccess, callResult = pcall(function()
                        if not petChar then
                            error("petChar is nil")
                        end
                        return game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(
                            game:GetService("Players").LocalPlayer,
                            getgenv().FoodID,
                            "UseBlock",
                            {['cframe'] = CFrame.new(
                                game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0)
                            )},
                            petChar
                        )
                    end)
                    if callSuccess then
                        success = true
                    else
                        print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                        task.wait(0.3)
                    end
                until success or attempts >= 5
            
                if not success then
                    warn("Failed to activate furniture after " .. attempts .. " attempts.")
                end
            
                local t = 0
                repeat 
                    task.wait(1)
                    t = t + 1
                until not hasTargetAilment("hungry", petToEquipSecond) or t == 60  -- Check only second pet's ailments
                removeItemByValue(SecondTableArray, "hungry")
            end
            
        else
            if startingMoney > 80 then
                --print("Buying required food bowl")
                game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({
                    [1] = {
                        ["properties"] = {
                            ["cframe"] = CFrame.new(30.5, 0, -20) * CFrame.Angles(-0, -1.57, 0)
                        },
                        ["kind"] = "pet_food_bowl"
                    }
                })
                task.wait(1)
                getgenv().FoodID = GetFurniture("PetFoodBowl")
                startingMoney = getCurrentMoney()
            else
                print("Not Enough money to buy food")
            end
        end
        
        -- Update ailments data
        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
        getAilments(PetAilmentsData)
        taskName = "none"
        
        --print("done hungry")
    end
    if table.find(FirstTableArray, "thirsty") or table.find(SecondTableArray, "thirsty") then
        --print("doing thirsty")
        taskName = "🥛"
        
        task.wait(1)
        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
        
        if getgenv().WaterID then
            -- Handle first pet thirst
            if table.find(FirstTableArray, "thirsty") then
                
                local attempts = 0
                local success = false
                repeat
                    attempts = attempts + 1
                    local petChar = fsys.get("pet_char_wrappers")[1]["char"]
                    local callSuccess, callResult = pcall(function()
                        if not petChar then
                            error("petChar is nil")
                        end
                        return game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(
                            game:GetService("Players").LocalPlayer,
                            getgenv().WaterID,
                            "UseBlock",
                            {['cframe'] = CFrame.new(
                                game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0)
                            )},
                            petChar
                        )
                    end)
                    if callSuccess then
                        success = true
                    else
                        print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                        task.wait(0.3)
                    end
                until success or attempts >= 5
        
                if not success then
                    warn("Failed to activate furniture after " .. attempts .. " attempts.")
                end
                
                local t = 0
                repeat 
                    task.wait(1)
                    t = t + 1
                until not hasTargetAilment("thirsty", petToEquip) or t == 60  -- Check only first pet's ailments
                removeItemByValue(FirstTableArray, "thirsty")
            end
            
            -- Handle second pet thirst
            if table.find(SecondTableArray, "thirsty") then
                
                local attempts = 0
                local success = false
                repeat
                    attempts = attempts + 1
                    local petChar = fsys.get("pet_char_wrappers")[2]["char"]
                    local callSuccess, callResult = pcall(function()
                        if not petChar then
                            error("petChar is nil")
                        end
                        return game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(
                            game:GetService("Players").LocalPlayer,
                            getgenv().WaterID,
                            "UseBlock",
                            {['cframe'] = CFrame.new(
                                game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0)
                            )},
                            petChar
                        )
                    end)
                    if callSuccess then
                        success = true
                    else
                        print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                        task.wait(0.3)
                    end
                until success or attempts >= 5
        
                if not success then
                    warn("Failed to activate furniture after " .. attempts .. " attempts.")
                end
        
                local t = 0
                repeat 
                    task.wait(1)
                    t = t + 1
                until not hasTargetAilment("thirsty", petToEquipSecond) or t == 60  -- Check only second pet's ailments
                removeItemByValue(SecondTableArray, "thirsty")
            end
        else
            if startingMoney > 80 then
                -- Buying required water bowl
                game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({
                    [1] = {
                        ["properties"] = {
                            ["cframe"] = CFrame.new(30.5, 0, -20) * CFrame.Angles(0, -1.57, 0)
                        },
                        ["kind"] = "pet_water_bowl"
                    }
                })
                task.wait(1)
                getgenv().WaterID = GetFurniture("PetWaterBowl")
                startingMoney = getCurrentMoney()
            else
                print("Not Enough money to buy water")
            end
        end
        
        
        -- Update ailments data
        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
        getAilments(PetAilmentsData)
        taskName = "none"
        
        --print("done thirsty")
    end
end


local function EatDrinkSafeCall(isEquippedPet)
    local success = false

    while not success do
        success, err = pcall(function()
            EatDrink(isEquippedPet)
        end)

        if not success then
            warn("Error occurred: ", err)
            task.wait(1) -- wait for a second before retrying
        end
    end

    --print("EatDrink executed successfully without errors.")
end


local function getLureBait()
    local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    local FoodData = ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.food
    
    for x,y in pairs(FoodData) do
        for i,j in pairs(y) do
            if y.id == "ice_dimension_2025_ice_soup_bait" then
                return y.unique
            end
        end
    end
end

local function startPetFarm()
    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
    game:GetService("Players").LocalPlayer, "Snow")
    teleportPlayerNeeds(0,350,0)
    createPlatform()
    buyItems()
    task.wait(5)

    task.spawn(function()
        while true do
            -- Loop through all descendants in the workspace
            for _, obj in ipairs(workspace:GetDescendants()) do
                -- Check if the object's name matches "BucksBillboard" or "XPBillboard"
                if obj.Name == "BucksBillboard" or obj.Name == "XPBillboard" then
                    obj:Destroy() -- Remove the object from the workspace
                end
            end
            -- Wait for 0.2 seconds before running again
            task.wait(0.5)
        end
    end)
    
    local success, err = pcall(function()
        -- ########### LURE BAIT
        local LureBait = getLureBait()
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ActivateFurniture"):InvokeServer(game:GetService("Players").LocalPlayer, getgenv().LureID, "UseBlock", {["bait_unique"] = LureBait}, fsys.get("char_wrapper")["char"])
        
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ActivateFurniture"):InvokeServer(game:GetService("Players").LocalPlayer, getgenv().LureID, "UseBlock", false, fsys.get("char_wrapper")["char"])
    end)
    
    if not success then
        warn("An error occurred: " .. err)
    end

    while getgenv().PetFarm do
        while getgenv().PetFarm do
            repeat task.wait(5)
                task.wait(1)
                local UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")
                UI.set_app_visibility("DialogApp", false)

                PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                getAilments(PetAilmentsData)
                getBabyAilments(BabyAilmentsData)

                if table.find(FirstTableArray, "hungry") or table.find(FirstTableArray, "thirsty") or table.find(SecondTableArray, "hungry") or table.find(SecondTableArray, "thirsty") then
                    EatDrinkSafeCall(true)
                end
                print("lapas sa hungry")
    
                -- Baby hungry
                if table.find(BabyAilmentsArray, "hungry") then
                    -- Baby hungry
                    startingMoney = getCurrentMoney()
                    if startingMoney > 5 then
                        buyItem("apple")
                        local appleID = getFoodID("apple")
                        useItem(appleID, 3)
                        task.wait(1)
                    end
                    removeItemByValue(BabyAilmentsArray, "hungry")
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getBabyAilments(BabyAilmentsData)
                end
                
                -- Baby thirsty
                if table.find(BabyAilmentsArray, "thirsty") then
                    -- Baby thirsty
                    startingMoney = getCurrentMoney()
                    if startingMoney > 5 then
                        buyItem("tea")
                        local teaID = getFoodID("tea")
                        useItem(teaID, 6)
                        task.wait(1)
                    end
                    removeItemByValue(BabyAilmentsArray, "thirsty")
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getBabyAilments(BabyAilmentsData)
                end
    
                -- Baby sick
                if table.find(BabyAilmentsArray, "sick") then
                    -- Baby sick
                    
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("Hospital")
                    task.wait(0.3)
                    teleportPlayerNeeds(0, 350, 0)
                    task.wait(0.3)
                    createPlatform()
                    task.wait(0.3)
                    getgenv().HospitalBedID = GetFurniture("HospitalRefresh2023Bed")
                    task.wait(2)
                    task.spawn(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ActivateInteriorFurniture"):InvokeServer(getgenv().HospitalBedID, "Seat1", {["cframe"] = CFrame.new(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position)}, fsys.get("char_wrapper")["char"])
                    end)
                    task.wait(15)
                    BabyJump()
                    removeItemByValue(BabyAilmentsArray, "sick")
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getBabyAilments(BabyAilmentsData)
                    -- Check if petfarm is true
                    if not getgenv().PetFarm then
                        return -- Exit the function or stop the process if petfarm is false
                    end
                    task.wait(1)
                    task.wait(0.3)
                    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
                    game:GetService("Players").LocalPlayer, LiveOpsMapSwap.get_current_map_type())
                    task.wait(0.3)
                    teleportPlayerNeeds(0, 350, 0)
                    task.wait(0.3)
                    createPlatform()
                    task.wait(0.3)
                    
                    --print("done sick")
                end
    
                -- Check if 'school' is in the FirstTableArray
                if table.find(FirstTableArray, "school") or table.find(SecondTableArray, "school") or table.find(BabyAilmentsArray, "school") then
                    --print("going school")
                    taskName = "📚"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("School")
                    teleportPlayerNeeds(0, 350, 0)
                    createPlatform()
                    
                    repeat task.wait(1)
                    until not hasTargetAilment("school", petToEquip) and not hasTargetAilment("school", petToEquipSecond) and not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["school"]
                    task.wait(2)
                    removeItemByValue(FirstTableArray, "school")
                    removeItemByValue(SecondTableArray, "school")
                    removeItemByValue(BabyAilmentsArray, "school")
                    PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getAilments(PetAilmentsData)
                    getBabyAilments(BabyAilmentsData)
                    taskName = "none"
                    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
                    game:GetService("Players").LocalPlayer, LiveOpsMapSwap.get_current_map_type())
                    task.wait(0.3)
                    teleportPlayerNeeds(0, 350, 0)
                    task.wait(0.3)
                    createPlatform()
                    task.wait(0.3)
                    
                    --print("done school")
                end
    
                -- Check if 'salon' is in the FirstTableArray
                if table.find(FirstTableArray, "salon") or table.find(SecondTableArray, "salon") or table.find(BabyAilmentsArray, "salon") then
                    --print("going salon")
                    taskName = "✂️"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("Salon")
                    teleportPlayerNeeds(0, 350, 0)
                    createPlatform()
                    
                    repeat task.wait(1)
                    until not hasTargetAilment("salon", petToEquip) and not hasTargetAilment("salon", petToEquipSecond) and not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["salon"]
                    task.wait(2)
                    removeItemByValue(FirstTableArray, "salon")
                    removeItemByValue(SecondTableArray, "salon")
                    removeItemByValue(BabyAilmentsArray, "salon")
                    PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getAilments(PetAilmentsData)
                    getBabyAilments(BabyAilmentsData)
                    taskName = "none"
                    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
                    game:GetService("Players").LocalPlayer, LiveOpsMapSwap.get_current_map_type())
                    task.wait(0.3)
                    teleportPlayerNeeds(0, 350, 0)
                    task.wait(0.3)
                    createPlatform()
                    task.wait(0.3)
                    
                    --print("done salon")
                end
                -- Check if 'pizza_party' is in the FirstTableArray
                if table.find(FirstTableArray, "pizza_party") or table.find(SecondTableArray, "pizza_party") or table.find(BabyAilmentsArray, "pizza_party") then
                    --print("going pizza")
                    taskName = "🍕"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("PizzaShop")
                    teleportPlayerNeeds(0, 350, 0)
                    createPlatform()
                    
                    repeat task.wait(1)
                    until not hasTargetAilment("pizza_party", petToEquip) and not hasTargetAilment("pizza_party", petToEquipSecond) and not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["pizza_party"]
                    task.wait(2)
                    removeItemByValue(FirstTableArray, "pizza_party")
                    removeItemByValue(SecondTableArray, "pizza_party")
                    removeItemByValue(BabyAilmentsArray, "pizza_party")
                    PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getAilments(PetAilmentsData)
                    getBabyAilments(BabyAilmentsData)
                    taskName = "none"
                    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
                    game:GetService("Players").LocalPlayer, LiveOpsMapSwap.get_current_map_type())
                    task.wait(0.3)
                    teleportPlayerNeeds(0, 350, 0)
                    task.wait(0.3)
                    createPlatform()
                    task.wait(0.3)
                    
                    print("done pizza")
                end
                -- Check if 'bored' is in the FirstTableArray
                if table.find(FirstTableArray, "bored") or table.find(SecondTableArray, "bored") then
                    --print("doing bored")
                    taskName = "🥱"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    
                    task.wait(3)
                    
                    task.wait(1)
                    
                    if getgenv().PianoID then
                        -- Handle first pet boredom
                        if table.find(FirstTableArray, "bored") then
    
                            
                            local attempts = 0
                            local success = false
                            repeat
                                attempts = attempts + 1
                                local petChar = fsys.get("pet_char_wrappers")[1]["char"]
                                local callSuccess, callResult = pcall(function()
                                    if not petChar then
                                        error("petChar is nil")
                                    end
                                    return game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(
                                        game:GetService("Players").LocalPlayer,
                                        getgenv().PianoID,
                                        "Seat1",
                                        {['cframe'] = CFrame.new(
                                            game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0)
                                        )},
                                        petChar
                                    )
                                end)
                                if callSuccess then
                                    success = true
                                else
                                    print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                                    task.wait(0.3)
                                end
                            until success or attempts >= 5
                    
                            if not success then
                                warn("Failed to activate furniture after " .. attempts .. " attempts for first pet.")
                            end
                            
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until not hasTargetAilment("bored", petToEquip) or t == 60  -- Check only first pet's ailments
                            removeItemByValue(FirstTableArray, "bored")
                        end
                        
                        -- Handle second pet boredom
                        if table.find(SecondTableArray, "bored") then
    
                            
                            local attempts = 0
                            local success = false
                            repeat
                                attempts = attempts + 1
                                local petChar = fsys.get("pet_char_wrappers")[2]["char"]
                                local callSuccess, callResult = pcall(function()
                                    if not petChar then
                                        error("petChar is nil")
                                    end
                                    return game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(
                                        game:GetService("Players").LocalPlayer,
                                        getgenv().PianoID,
                                        "Seat1",
                                        {['cframe'] = CFrame.new(
                                            game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0)
                                        )},
                                        petChar
                                    )
                                end)
                                if callSuccess then
                                    success = true
                                else
                                    print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                                    task.wait(0.3)
                                end
                            until success or attempts >= 5
                    
                            if not success then
                                warn("Failed to activate furniture after " .. attempts .. " attempts for second pet.")
                            end
                    
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until not hasTargetAilment("bored", petToEquipSecond) or t == 60  -- Check only second pet's ailments
                            removeItemByValue(SecondTableArray, "bored")
                        end
                    else
                        startingMoney = getCurrentMoney()
                        if startingMoney > 100 then
                            -- Buy required piano
                            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({
                                [1] = {
                                    ["properties"] = {
                                        ["cframe"] = CFrame.new(7.5, 7.5, -5.5) * CFrame.Angles(-1.57, 0, 0)
                                    },
                                    ["kind"] = "piano"
                                }
                            })
                            task.wait(1)
                            getgenv().PianoID = GetFurniture("Piano")
                            startingMoney = getCurrentMoney()
                        else
                            print("Not Enough money to buy piano")
                        end
                    end
                    
                    
                    -- Update ailments data
                    PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                    getAilments(PetAilmentsData)
                    taskName = "none"
                    
                    --print("done bored")
                end
                if table.find(BabyAilmentsArray, "bored") then
                    --print("doing bored")
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    if getgenv().PianoID then
                        task.spawn(function()
                            game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(game:GetService("Players").LocalPlayer,getgenv().PianoID,"Seat1",{['cframe'] = CFrame.new(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position)},fsys.get("char_wrapper")["char"])
                        end)
                        repeat task.wait(1)
                        until not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["bored"] 
                        BabyJump()
                        removeItemByValue(BabyAilmentsArray, "bored")
                    else
                        startingMoney = getCurrentMoney()
                        if startingMoney > 100 then
                            --print("Buying Required Piano")
                            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(7.5, 7.5, -5.5) * CFrame.Angles(-1.57, 0, -0)},["kind"] = "piano"}})
                            task.wait(1)
                            getgenv().PianoID = GetFurniture("Piano")
                            startingMoney = getCurrentMoney()
                        else
                            print("Not Enough money to buy piano")
                        end
                    end
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getBabyAilments(BabyAilmentsData)
                end
                -- Check if 'beach_party' is in the FirstTableArray
                if table.find(FirstTableArray, "beach_party") or table.find(SecondTableArray, "beach_party") or table.find(BabyAilmentsArray, "beach_party") then
                    --print("going beach party")
                    taskName = "⛱️"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
                    game:GetService("Players").LocalPlayer, LiveOpsMapSwap.get_current_map_type())
                    teleportPlayerNeeds(-551, 31, -1485)
                    task.wait(0.3)
                    createPlatform()
                    task.wait(0.3)
                    
                    repeat task.wait(1)
                    until not hasTargetAilment("beach_party", petToEquip) and not hasTargetAilment("beach_party", petToEquipSecond) and not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["beach_party"]
                    task.wait(2)
                    removeItemByValue(FirstTableArray, "beach_party")
                    removeItemByValue(SecondTableArray, "beach_party")
                    removeItemByValue(BabyAilmentsArray, "beach_party")
                    PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getBabyAilments(BabyAilmentsData)
                    getAilments(PetAilmentsData)
                    -- Check if petfarm is true
                    if not getgenv().PetFarm then
                        return -- Exit the function or stop the process if petfarm is false
                    end
                    task.wait(1)
                    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
                    game:GetService("Players").LocalPlayer, LiveOpsMapSwap.get_current_map_type())
                    task.wait(0.3)
                    teleportPlayerNeeds(0, 350, 0)
                    task.wait(0.3)
                    createPlatform()
                    task.wait(0.3)
                    taskName = "none"
                    
                    --print("done beach part")
                end
                -- Check if 'camping' is in the FirstTableArray
                if table.find(FirstTableArray, "camping") or table.find(SecondTableArray, "camping") or table.find(BabyAilmentsArray, "camping") then
                    --print("going camping")
                    taskName = "🏕️"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
                    game:GetService("Players").LocalPlayer, LiveOpsMapSwap.get_current_map_type())
                    teleportPlayerNeeds(-20.9, 30.8, -1056.7)
                    task.wait(0.3)
                    createPlatform()
                    task.wait(0.3)
                    
                    repeat task.wait(1)
                    until not hasTargetAilment("camping", petToEquip) and not hasTargetAilment("camping", petToEquipSecond) and not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["camping"]
                    task.wait(2)
                    removeItemByValue(FirstTableArray, "camping")
                    removeItemByValue(SecondTableArray, "camping")
                    removeItemByValue(BabyAilmentsArray, "camping")
                    PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getAilments(PetAilmentsData)
                    getBabyAilments(BabyAilmentsData)
                    -- Check if petfarm is true
                    if not getgenv().PetFarm then
                        return -- Exit the function or stop the process if petfarm is false
                    end
                    task.wait(1)
                    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
                    game:GetService("Players").LocalPlayer, LiveOpsMapSwap.get_current_map_type())
                    task.wait(0.3)
                    teleportPlayerNeeds(0, 350, 0)
                    task.wait(0.3)
                    createPlatform()
                    task.wait(0.3)
                    taskName = "none"
                    
                    --print("done camping")
                end      
                -- Check if 'dirty' is in the FirstTableArray
                if table.find(FirstTableArray, "dirty") or table.find(SecondTableArray, "dirty") then
                    --print("doing dirty")
                    taskName = "🚿"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    
                    task.wait(3)
                    
                    task.wait(1)
                
                    if getgenv().ShowerID then
                        if table.find(FirstTableArray, "dirty") then
    
                            
                            local attempts = 0
                            local success = false
                            repeat
                                attempts = attempts + 1
                                local petChar = fsys.get("pet_char_wrappers")[1]["char"]
                                local callSuccess, callResult = pcall(function()
                                    if not petChar then
                                        error("petChar is nil")
                                    end
                                    return game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(
                                        game:GetService("Players").LocalPlayer,
                                        getgenv().ShowerID,
                                        "UseBlock",
                                        {['cframe'] = CFrame.new(
                                            game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0)
                                        )},
                                        petChar
                                    )
                                end)
                                if callSuccess then
                                    success = true
                                else
                                    print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                                    task.wait(0.3)
                                end
                            until success or attempts >= 5
                    
                            if not success then
                                warn("Failed to activate furniture after " .. attempts .. " attempts for first pet.")
                            end
                            
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until not hasTargetAilment("dirty", petToEquip) or t == 60  -- Check only first pet's ailments
                            removeItemByValue(FirstTableArray, "dirty")
                        end
                    
                        if table.find(SecondTableArray, "dirty") then
    
                            
                            local attempts = 0
                            local success = false
                            repeat
                                attempts = attempts + 1
                                local petChar = fsys.get("pet_char_wrappers")[2]["char"]
                                local callSuccess, callResult = pcall(function()
                                    if not petChar then
                                        error("petChar is nil")
                                    end
                                    return game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(
                                        game:GetService("Players").LocalPlayer,
                                        getgenv().ShowerID,
                                        "UseBlock",
                                        {['cframe'] = CFrame.new(
                                            game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0)
                                        )},
                                        petChar
                                    )
                                end)
                                if callSuccess then
                                    success = true
                                else
                                    print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                                    task.wait(0.3)
                                end
                            until success or attempts >= 5
                    
                            if not success then
                                warn("Failed to activate furniture after " .. attempts .. " attempts for second pet.")
                            end
                    
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until not hasTargetAilment("dirty", petToEquipSecond) or t == 60  -- Check only second pet's ailments
                            removeItemByValue(SecondTableArray, "dirty")
                        end
                    else
                        startingMoney = getCurrentMoney()
                        if startingMoney > 13 then
                            -- Buying Required Shower
                            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({
                                [1] = {
                                    ["properties"] = {
                                        ["cframe"] = CFrame.new(34.5, 0, -8.5) * CFrame.Angles(0, 1.57, 0)
                                    },
                                    ["kind"] = "stylishshower"
                                }
                            })
                            task.wait(1)
                            getgenv().ShowerID = GetFurniture("StylishShower")
                            startingMoney = getCurrentMoney()
                        else
                            print("Not Enough money to buy shower")
                        end
                    end
                    
                
                    PetAilmentsData = ClientData.get_data()[game:GetService("Players").LocalPlayer.Name].ailments_manager.ailments
                    getAilments(PetAilmentsData)
                    taskName = "none"
                    
                    --print("done dirty")
                end
                
                if table.find(BabyAilmentsArray, "dirty") then
                    --print("doing dirty")
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    if getgenv().ShowerID then
                        task.spawn(function()
                            game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(game:GetService("Players").LocalPlayer,getgenv().ShowerID,"UseBlock",{['cframe'] = CFrame.new(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position)},fsys.get("char_wrapper")["char"])
                        end)
                        repeat task.wait(1)
                        until not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["dirty"]
                        BabyJump()
                        removeItemByValue(BabyAilmentsArray, "dirty")
                    else
                        startingMoney = getCurrentMoney()
                        if startingMoney > 13 then
                            --print("Buying Required Shower")
                            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(34.5, 0, -8.5) * CFrame.Angles(0, 1.57, 0)},["kind"] = "stylishshower"}})
                            task.wait(1)
                            getgenv().ShowerID = GetFurniture("StylishShower")
                            startingMoney = getCurrentMoney()
                        else
                            print("Not Enough money to buy shower")
                        end
                    end
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getBabyAilments(BabyAilmentsData)
                    --print("done dirty")
                end
                -- Check if 'sleepy' is in the FirstTableArray
                if table.find(FirstTableArray, "sleepy") or table.find(SecondTableArray, "sleepy") then
                    --print("doing sleepy")
                    taskName = "😴"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    
                    task.wait(3)
                    
                    task.wait(1)
                    
                    if getgenv().BedID then
                        if table.find(FirstTableArray, "sleepy") then
    
                            
                            local attempts = 0
                            local success = false
                            repeat
                                attempts = attempts + 1
                                local petChar = fsys.get("pet_char_wrappers")[1]["char"]
                                local callSuccess, callResult = pcall(function()
                                    if not petChar then
                                        error("petChar is nil")
                                    end
                                    return game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(
                                        game:GetService("Players").LocalPlayer,
                                        getgenv().BedID,
                                        "UseBlock",
                                        {['cframe'] = CFrame.new(
                                            game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0)
                                        )},
                                        petChar
                                    )
                                end)
                                if callSuccess then
                                    success = true
                                else
                                    print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                                    task.wait(0.3)
                                end
                            until success or attempts >= 5
                    
                            if not success then
                                warn("Failed to activate furniture after " .. attempts .. " attempts for first pet.")
                            end
                            
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until not hasTargetAilment("sleepy", petToEquip) or t == 60  -- Check only first pet's ailments
                            removeItemByValue(FirstTableArray, "sleepy")
                        end
                    
                        if table.find(SecondTableArray, "sleepy") then
    
                            
                            local attempts = 0
                            local success = false
                            repeat
                                attempts = attempts + 1
                                local petChar = fsys.get("pet_char_wrappers")[2]["char"]
                                local callSuccess, callResult = pcall(function()
                                    if not petChar then
                                        error("petChar is nil")
                                    end
                                    return game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(
                                        game:GetService("Players").LocalPlayer,
                                        getgenv().BedID,
                                        "UseBlock",
                                        {['cframe'] = CFrame.new(
                                            game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0)
                                        )},
                                        petChar
                                    )
                                end)
                                if callSuccess then
                                    success = true
                                else
                                    print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                                    task.wait(0.3)
                                end
                            until success or attempts >= 5
                    
                            if not success then
                                warn("Failed to activate furniture after " .. attempts .. " attempts for second pet.")
                            end
                    
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until not hasTargetAilment("sleepy", petToEquipSecond) or t == 60  -- Check only second pet's ailments
                            removeItemByValue(SecondTableArray, "sleepy")
                        end
                    else
                        startingMoney = getCurrentMoney()
                        if startingMoney > 5 then
                            -- Buying required crib
                            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({
                                [1] = {
                                    ["properties"] = {
                                        ["cframe"] = CFrame.new(33.5, 0, -30) * CFrame.Angles(0, -1.57, 0)
                                    },
                                    ["kind"] = "basiccrib"
                                }
                            })
                            task.wait(1)
                            getgenv().BedID = GetFurniture("BasicCrib")
                            startingMoney = getCurrentMoney()
                        else
                            print("Not Enough money to buy bed.")
                        end
                    end
                    
                
                    PetAilmentsData = ClientData.get_data()[game:GetService("Players").LocalPlayer.Name].ailments_manager.ailments
                    getAilments(PetAilmentsData)
                    taskName = "none"
                    
                    --print("done pet sleepy")
                end
                 
                if table.find(BabyAilmentsArray, "sleepy") then
                    --print("doing sleepy")
                    if getgenv().BedID then
                        task.spawn(function()
                            game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(game:GetService("Players").LocalPlayer,getgenv().BedID,"UseBlock",{['cframe'] = CFrame.new(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position)},fsys.get("char_wrapper")["char"])
                        end)
                        repeat task.wait(1)
                        until not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["sleepy"]
                        BabyJump()
                        removeItemByValue(BabyAilmentsArray, "sleepy")
                    else
                        startingMoney = getCurrentMoney()
                        if startingMoney > 5 then
                            --print("Buying required crib")
                            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(33.5, 0, -30) * CFrame.Angles(-0, -1.57, 0)},["kind"] = "basiccrib"}})
                            task.wait(1)
                            getgenv().BedID = GetFurniture("BasicCrib")
                            startingMoney = getCurrentMoney()
                        else 
                            print("Not Enough money to buy bed.")
                        end
                    end
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getBabyAilments(BabyAilmentsData)
                    --print("done baby sleepy")
                end      
                -- Check if 'Potty' is in the FirstTableArray
                if table.find(FirstTableArray, "toilet") or table.find(SecondTableArray, "toilet") then
                    --print("going toilet")
                    taskName = "🧻"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    
                    task.wait(3)
                    
                    task.wait(1)
                    
                    if getgenv().ToiletID then
                        if table.find(FirstTableArray, "toilet") then
    
                            
                            local attempts = 0
                            local success = false
                            repeat
                                attempts = attempts + 1
                                local petChar = fsys.get("pet_char_wrappers")[1]["char"]
                                local callSuccess, callResult = pcall(function()
                                    if not petChar then
                                        error("petChar is nil")
                                    end
                                    return game:GetService("ReplicatedStorage")
                                        :WaitForChild("API")
                                        :WaitForChild("HousingAPI/ActivateFurniture")
                                        :InvokeServer(
                                            game:GetService("Players").LocalPlayer,
                                            getgenv().ToiletID,
                                            "Seat1",
                                            {['cframe'] = CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0))},
                                            petChar
                                        )
                                end)
                                if callSuccess then
                                    success = true
                                else
                                    print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                                    task.wait(0.3)
                                end
                            until success or attempts >= 5
                            
                            if not success then
                                warn("Failed to activate furniture after " .. attempts .. " attempts for first pet.")
                            end
                            
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until not hasTargetAilment("toilet", petToEquip) or t == 60
                            removeItemByValue(FirstTableArray, "toilet")
                        end
                    
                        if table.find(SecondTableArray, "toilet") then
    
                            
                            local attempts = 0
                            local success = false
                            repeat
                                attempts = attempts + 1
                                local petChar = fsys.get("pet_char_wrappers")[2]["char"]
                                local callSuccess, callResult = pcall(function()
                                    if not petChar then
                                        error("petChar is nil")
                                    end
                                    return game:GetService("ReplicatedStorage")
                                        :WaitForChild("API")
                                        :WaitForChild("HousingAPI/ActivateFurniture")
                                        :InvokeServer(
                                            game:GetService("Players").LocalPlayer,
                                            getgenv().ToiletID,
                                            "Seat1",
                                            {['cframe'] = CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, 0.5, 0))},
                                            petChar
                                        )
                                end)
                                if callSuccess then
                                    success = true
                                else
                                    print("ActivateFurniture attempt " .. attempts .. " failed. Retrying...")
                                    task.wait(0.3)
                                end
                            until success or attempts >= 5
                            
                            if not success then
                                warn("Failed to activate furniture after " .. attempts .. " attempts for second pet.")
                            end
                            
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until not hasTargetAilment("toilet", petToEquipSecond) or t == 60
                            removeItemByValue(SecondTableArray, "toilet")
                        end
                    else
                        startingMoney = getCurrentMoney()
                        if startingMoney > 9 then
                            -- Buying required toilet
                            game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures")
                                :InvokeServer({
                                    [1] = {
                                        ["properties"] = {
                                            ["cframe"] = CFrame.new(30.5, 0, -20) * CFrame.Angles(0, -1.57, 0)
                                        },
                                        ["kind"] = "toilet"
                                    }
                                })
                            task.wait(1)
                            getgenv().ToiletID = GetFurniture("Toilet")
                            startingMoney = getCurrentMoney()
                        else
                            print("Not Enough money to buy toilet")
                        end
                    end
                    
                
                    PetAilmentsData = ClientData.get_data()[game:GetService("Players").LocalPlayer.Name].ailments_manager.ailments
                    getAilments(PetAilmentsData)
                    taskName = "none"
                    
                    --print("done potty")
                end
                  
                -- Check if 'mysteryTask' is in the FirstTableArray
                if table.find(FirstTableArray, "mystery") or table.find(SecondTableArray, "mystery") then
                    --print("going mysteryTask")
                    taskName = "❓"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    
                    task.wait(3)
                    
                    if table.find(FirstTableArray, "mystery") then
                        for i = 1, 3 do
                            task.spawn(function()
                                get_mystery_task(petToEquip)
                            end)
                        end
                        local t = 0
                        repeat 
                            task.wait(1)
                            t = t + 1
                        until not hasTargetAilment("mystery", petToEquip) or t == 60  -- Check only first table
                        removeItemByValue(FirstTableArray, "mystery")
                    end
                
                    if table.find(SecondTableArray, "mystery") then
                        for i = 1, 3 do
                            task.spawn(function()
                                get_mystery_task(petToEquipSecond)
                            end)
                        end
                        local t = 0
                        repeat 
                            task.wait(1)
                            t = t + 1
                        until not hasTargetAilment("mystery", petToEquipSecond) or t == 60  -- Check only first table
                        removeItemByValue(SecondTableArray, "mystery")
                    end
                
                    PetAilmentsData = ClientData.get_data()[game:GetService("Players").LocalPlayer.Name].ailments_manager.ailments
                    getAilments(PetAilmentsData)
                    taskName = "none"
                    
                    --print("done mysteryTask")
                end
                
                -- Check if 'pet me' is in the FirstTableArray
                -- if (table.find(FirstTableArray, "pet_me") or table.find(SecondTableArray, "pet_me")) and not getgenv().SkipPetMe then
                --     --print("going pet me")
                --     taskName = "👋"
                    
                --     task.wait(3)
    
                --     removeItemByValue(FirstTableArray, "pet_me")
                --     removeItemByValue(SecondTableArray, "pet_me")
                    
                --     -- local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                --     -- local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    
                --     -- if table.find(FirstTableArray, "pet_me") then
                --     --     for _, ailmentsList in pairs(playerGui:GetChildren()) do
                --     --         if ailmentsList.Name == "ailments_list" and ailmentsList:FindFirstChild("SurfaceGui") then
                --     --             local container = ailmentsList.SurfaceGui:FindFirstChild("Container")
                --     --             if container and container ~= "UIListLayout" then
                --     --                 for _, button in pairs(container:GetChildren()) do
                --     --                     FireSig(button) -- Click each ailment button
                --     --                     task.wait(3) -- Optional delay between clicks
                --     --                     if playerGui.FocusPetApp.BackButton.Visible then
                --     --                         print("inside focus")
                --     --                         local args = {
                --     --                             [1] = ClientData.get("pet_char_wrappers")[1].pet_unique
                --     --                         }
                --     --                         game:GetService("ReplicatedStorage")
                --     --                             :WaitForChild("API")
                --     --                             :WaitForChild("AilmentsAPI/ProgressPetMeAilment")
                --     --                             :FireServer(unpack(args))
                --     --                         task.wait(1) -- Optional delay between clicks
                --     --                         local backButton = playerGui.FocusPetApp.BackButton
                --     --                         FireSig(backButton)
                --     --                         break
                --     --                     else
                --     --                         print("no back button found")
                --     --                     end
                --     --                 end
                --     --             end
                --     --         end
                --     --     end
                --     --     repeat task.wait(1)
                --     --     until not hasTargetAilment("pet_me", petToEquip)
                --     --     removeItemByValue(FirstTableArray, "pet_me")
                --     -- end
                
                --     -- if table.find(SecondTableArray, "pet_me") then
                --     --     for _, ailmentsList in pairs(playerGui:GetChildren()) do
                --     --         if ailmentsList.Name == "ailments_list" and ailmentsList:FindFirstChild("SurfaceGui") then
                --     --             local container = ailmentsList.SurfaceGui:FindFirstChild("Container")
                --     --             if container and container ~= "UIListLayout" then
                --     --                 for _, button in pairs(container:GetChildren()) do
                --     --                     FireSig(button) -- Click each ailment button
                --     --                     task.wait(3) -- Optional delay between clicks
                --     --                     if playerGui.FocusPetApp.BackButton.Visible then
                --     --                         print("inside focus")
                --     --                         local args = {
                --     --                             [1] = ClientData.get("pet_char_wrappers")[2].pet_unique
                --     --                         }
                --     --                         game:GetService("ReplicatedStorage")
                --     --                             :WaitForChild("API")
                --     --                             :WaitForChild("AilmentsAPI/ProgressPetMeAilment")
                --     --                             :FireServer(unpack(args))
                --     --                         task.wait(1) -- Optional delay between clicks
                --     --                         local backButton = playerGui.FocusPetApp.BackButton
                --     --                         FireSig(backButton)
                --     --                         break
                --     --                     else
                --     --                         print("no back button found")
                --     --                     end
                --     --                 end
                --     --             end
                --     --         end
                --     --     end
                --     --     repeat task.wait(1)
                --     --     until not hasTargetAilment("pet_me", petToEquipSecond)
                --     --     removeItemByValue(SecondTableArray, "pet_me")
                --     -- end
                
                --     -- PetAilmentsData = ClientData.get_data()[game:GetService("Players").LocalPlayer.Name].ailments_manager.ailments
                --     -- getAilments(PetAilmentsData)
                --     -- taskName = "none"
                --     -- 
                --     --print("done pet me")
                -- end
                
                -- Check if 'catch' is in the FirstTableArray
                if table.find(FirstTableArray, "play") or table.find(SecondTableArray, "play") then
                    --print("going catch")
                    taskName = "🦴"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    
                    task.wait(3)

                
                    if table.find(FirstTableArray, "play") then
    
                        local ToyToThrow
                        for _, v in pairs(fsys.get("inventory").toys) do
                            if v.id == "squeaky_bone_default" then
                                ToyToThrow = v.unique
                            end
                        end

                        -- repeat
                        --     game:GetService("ReplicatedStorage")
                        --     :WaitForChild("API")
                        --     :WaitForChild("PetObjectAPI/CreatePetObject")
                        --     :InvokeServer("__Enum_PetObjectCreatorType_1", {
                        --         ["reaction_name"] = "ThrowToyReaction",
                        --         ["unique_id"] = ToyToThrow
                        --     })
                        --     task.wait(4) -- Wait 4 seconds before next iteration
                        -- until not hasTargetAilment("play", petToEquip)
                        local t = 0
                        repeat
                            local args = {
                                [1] = ToyToThrow,
                                [2] = "START"
                            }
                            
                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ToolAPI/ServerUseTool"):FireServer(unpack(args))
                            task.wait(.1)
                            
                            game:GetService("ReplicatedStorage")
                            :WaitForChild("API")
                            :WaitForChild("PetObjectAPI/CreatePetObject")
                            :InvokeServer("__Enum_PetObjectCreatorType_1", {
                                ["reaction_name"] = "ThrowToyReaction",
                                ["unique_id"] = ToyToThrow
                            })
                            
                            task.wait(5)
                            t = t + 1
                        until not hasTargetAilment("play", petToEquip) or t == 60  -- Check only first table
                        removeItemByValue(FirstTableArray, "play")
                    end
                
                    if table.find(SecondTableArray, "play") then
    
                        local ToyToThrow
                        for _, v in pairs(fsys.get("inventory").toys) do
                            if v.id == "squeaky_bone_default" then
                                ToyToThrow = v.unique
                            end
                        end

                        -- repeat
                        --     game:GetService("ReplicatedStorage")
                        --     :WaitForChild("API")
                        --     :WaitForChild("PetObjectAPI/CreatePetObject")
                        --     :InvokeServer("__Enum_PetObjectCreatorType_1", {
                        --         ["reaction_name"] = "ThrowToyReaction",
                        --         ["unique_id"] = ToyToThrow
                        --     })
                        --     task.wait(4) -- Wait 4 seconds before next iteration
                        -- until not hasTargetAilment("play", petToEquipSecond)
                        local t = 0
                        repeat
                            local args = {
                                [1] = ToyToThrow,
                                [2] = "START"
                            }
                            
                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ToolAPI/ServerUseTool"):FireServer(unpack(args))
                            task.wait(.1)
                            
                            game:GetService("ReplicatedStorage")
                            :WaitForChild("API")
                            :WaitForChild("PetObjectAPI/CreatePetObject")
                            :InvokeServer("__Enum_PetObjectCreatorType_1", {
                                ["reaction_name"] = "ThrowToyReaction",
                                ["unique_id"] = ToyToThrow
                            })
                            
                            task.wait(5)
                            t = t + 1
                        until not hasTargetAilment("play", petToEquipSecond) or t == 60  -- Check only first table
                        removeItemByValue(SecondTableArray, "play")
                    end
                
                    PetAilmentsData = ClientData.get_data()[game:GetService("Players").LocalPlayer.Name].ailments_manager.ailments
                    getAilments(PetAilmentsData)
                    taskName = "none"
                    
                    print("done catch")
                end
                
                -- Check if 'sick' is in the FirstTableArray
                if table.find(FirstTableArray, "sick") or table.find(SecondTableArray, "sick") then
                    --print("going sick")
                    taskName = "🤒"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    
                    -- Send player to Hospital
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("Hospital")
                    task.wait(0.3)
                    teleportPlayerNeeds(0, 350, 0)
                    task.wait(0.3)
                    createPlatform()
                    task.wait(0.3)
                    
                    -- Get Hospital Bed ID
                    getgenv().HospitalBedID = GetFurniture("HospitalRefresh2023Bed")
                    task.wait(2)
                    
                    if table.find(FirstTableArray, "sick") then
    
                        
                        local petChar = fsys.get("pet_char_wrappers")[1]["char"]
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ActivateInteriorFurniture"):InvokeServer(getgenv().HospitalBedID, "Seat1", {['cframe']=CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0,.5,0))}, petChar)
                    
                        task.wait(20)
                        removeItemByValue(FirstTableArray, "sick")
                    end
                    
                    if table.find(SecondTableArray, "sick") then
    
                        
                        local petChar = fsys.get("pet_char_wrappers")[2]["char"]
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ActivateInteriorFurniture"):InvokeServer(getgenv().HospitalBedID, "Seat1", {['cframe']=CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0,.5,0))}, petChar)
                    
                        task.wait(20)
                        removeItemByValue(SecondTableArray, "sick")
                    end
                    
                
                    PetAilmentsData = ClientData.get_data()[game:GetService("Players").LocalPlayer.Name].ailments_manager.ailments
                    getAilments(PetAilmentsData)
                    
                    -- Check if petfarm is still enabled
                    if not getgenv().PetFarm then
                        return
                    end
                    
                    task.wait(1)
                    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
                    game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation")
                        :FireServer("MainMap", game:GetService("Players").LocalPlayer, LiveOpsMapSwap.get_current_map_type())
                    task.wait(0.3)
                    teleportPlayerNeeds(0, 350, 0)
                    task.wait(0.3)
                    createPlatform()
                    task.wait(0.3)
                    taskName = "none"
                    
                    --print("done sick")
                end
                
                -- Check if 'walk' is in the FirstTableArray
                if table.find(FirstTableArray, "walk") or table.find(SecondTableArray, "walk") then
                    -- Check if petfarm is true
                    if not getgenv().PetFarm then
                        return -- Exit if petfarm is false
                    end
                    --print("going walk")
                    taskName = "🚶"
                    
                    task.wait(3)
                    
                    task.wait(1)
                
                    local Player = game:GetService("Players").LocalPlayer
                    local Character = Player.Character or Player.CharacterAdded:Wait()
                    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                    local Humanoid = Character:WaitForChild("Humanoid") -- Get the humanoid
                
                    local walkDistance = 1000  -- Adjust the distance as needed
                    local walkDuration = 30    -- Adjust the time in seconds as needed
                
                    -- Store the initial position to walk back to it later
                    local initialPosition = HumanoidRootPart.Position
                
                    -- Define the goal position (straight ahead in the character's current direction)
                    local forwardPosition = initialPosition + (HumanoidRootPart.CFrame.LookVector * walkDistance)
                
                    -- Calculate speed to match walkDuration
                    local walkSpeed = walkDistance / walkDuration
                    Humanoid.WalkSpeed = walkSpeed -- Temporarily set the humanoid's walk speed
                
                    -- Move to the forward position and back twice
                    for i = 1, 2 do
                        if not getgenv().PetFarm then return end
                        Humanoid:MoveTo(forwardPosition)
                        Humanoid.MoveToFinished:Wait() -- Wait until the humanoid reaches the target
                        task.wait(1) -- Optional pause after reaching the position
                        if not getgenv().PetFarm then return end
                        Humanoid:MoveTo(initialPosition)
                        Humanoid.MoveToFinished:Wait() -- Wait until the humanoid returns to the initial position
                        task.wait(1) -- Optional pause after returning
                    end
                
    
                
                    -- Reset to default walk speed
                    Humanoid.WalkSpeed = 16
                
                    if table.find(FirstTableArray, "walk") then
                        removeItemByValue(FirstTableArray, "walk")
                    end
                    if table.find(SecondTableArray, "walk") then
                        removeItemByValue(SecondTableArray, "walk")
                    end
                
                    PetAilmentsData = ClientData.get_data()[game:GetService("Players").LocalPlayer.Name].ailments_manager.ailments
                    getAilments(PetAilmentsData)
                    taskName = "none"
                    
                    --print("done walk")
                end
                
                -- Check if 'ride' is in the FirstTableArray
                if table.find(FirstTableArray, "ride") or table.find(SecondTableArray, "ride") then
                    -- Check if petfarm is true
                    if not getgenv().PetFarm then
                        return -- Exit if petfarm is false
                    end
                    --print("going ride")
                    taskName = "🏎️"
                    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                    
                    task.wait(3)
                
                    local strollerUnique
                    for i, v in pairs(fsys.get("inventory").strollers) do
                        if v.id == 'stroller-default' then
                            strollerUnique = v.unique
                            break
                        end
                    end
                
                    local argsEquip = {
                        [1] = strollerUnique,
                        [2] = {
                            ["use_sound_delay"] = true,
                            ["equip_as_last"] = false
                        }
                    }
                    
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("API")
                        :WaitForChild("ToolAPI/Equip")
                        :InvokeServer(unpack(argsEquip))
                    
                    if table.find(FirstTableArray, "ride") then
    
                        
                        local attempts = 0
                        local success = false
                        repeat
                            attempts = attempts + 1
                            local petChar = fsys.get("pet_char_wrappers")[1]["char"]
                            local callSuccess, callResult = pcall(function()
                                if not petChar then
                                    error("petChar is nil")
                                end
                                return game:GetService("ReplicatedStorage")
                                    :WaitForChild("API")
                                    :WaitForChild("AdoptAPI/UseStroller")
                                    :InvokeServer(
                                        petChar,
                                        game:GetService("Players").LocalPlayer.Character.StrollerTool.ModelHandle.TouchToSits.TouchToSit
                                    )
                            end)
                            if callSuccess then
                                success = true
                            else
                                print("UseStroller attempt " .. attempts .. " failed. Retrying...")
                                task.wait(0.3)
                            end
                        until success or attempts >= 5
                    
                        if not success then
                            warn("Failed to use stroller for first pet after " .. attempts .. " attempts.")
                        end
                    end
                    
                    if table.find(SecondTableArray, "ride") then
    
                        
                        local attempts = 0
                        local success = false
                        repeat
                            attempts = attempts + 1
                            local petChar = fsys.get("pet_char_wrappers")[2]["char"]
                            local callSuccess, callResult = pcall(function()
                                if not petChar then
                                    error("petChar is nil")
                                end
                                return game:GetService("ReplicatedStorage")
                                    :WaitForChild("API")
                                    :WaitForChild("AdoptAPI/UseStroller")
                                    :InvokeServer(
                                        petChar,
                                        game:GetService("Players").LocalPlayer.Character.StrollerTool.ModelHandle.TouchToSits.TouchToSit
                                    )
                            end)
                            if callSuccess then
                                success = true
                            else
                                print("UseStroller attempt " .. attempts .. " failed. Retrying...")
                                task.wait(0.3)
                            end
                        until success or attempts >= 5
                    
                        if not success then
                            warn("Failed to use stroller for second pet after " .. attempts .. " attempts.")
                        end
                    end
                        
                
                    local Player = game:GetService("Players").LocalPlayer
                    local Character = Player.Character or Player.CharacterAdded:Wait()
                    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                    local Humanoid = Character:WaitForChild("Humanoid")
                
                    local walkDistance = 1000  -- Adjust as needed
                    local walkDuration = 30    -- Adjust as needed
                    local initialPosition = HumanoidRootPart.Position
                    local forwardPosition = initialPosition + (HumanoidRootPart.CFrame.LookVector * walkDistance)
                    local walkSpeed = walkDistance / walkDuration
                    Humanoid.WalkSpeed = walkSpeed
                
                    for i = 1, 2 do
                        if not getgenv().PetFarm then return end
                        Humanoid:MoveTo(forwardPosition)
                        Humanoid.MoveToFinished:Wait()
                        task.wait(1)
                        if not getgenv().PetFarm then return end
                        Humanoid:MoveTo(initialPosition)
                        Humanoid.MoveToFinished:Wait()
                        task.wait(1)
                    end
            
                    
                    local argsUnequip = {
                        [1] = strollerUnique,
                        [2] = {
                            ["use_sound_delay"] = true,
                            ["equip_as_last"] = false
                        }
                    }
                    
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("API")
                        :WaitForChild("ToolAPI/Unequip")
                        :InvokeServer(unpack(argsUnequip))
                    
                    Humanoid.WalkSpeed = 16
                
                    if table.find(FirstTableArray, "ride") then
                        removeItemByValue(FirstTableArray, "ride")
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("API")
                            :WaitForChild("AdoptAPI/EjectBaby")
                            :FireServer(fsys.get("pet_char_wrappers")[1]["char"])
                    end
                    if table.find(SecondTableArray, "ride") then
                        removeItemByValue(SecondTableArray, "ride")
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("API")
                            :WaitForChild("AdoptAPI/EjectBaby")
                            :FireServer(fsys.get("pet_char_wrappers")[1]["char"])
                    end
                    
                    task.wait(0.3)
                    PetAilmentsData = ClientData.get_data()[game:GetService("Players").LocalPlayer.Name].ailments_manager.ailments
                    getAilments(PetAilmentsData)
                    taskName = "none"
                    
                    --print("done ride")
                end
                           
                
            until not getgenv().PetFarm
        end
        task.wait(.1)
    end
    
    
end



local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Hira X Rey",
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = "Loading HiraXRey Script...",
    LoadingSubtitle = "Have a nice day!",
    Theme = "Bloom", -- Check https://docs.sirius.menu/rayfield/configuration/themes
 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
    ConfigurationSaving = {
       Enabled = false,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "Big Hub"
    },
 
    Discord = {
       Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
 
    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
       FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
 })


 getgenv().ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
 local petOptions = {}
 local kindToUnique = {}
 for x, y in pairs(getgenv().ClientData.get("inventory").pets) do
    table.insert(petOptions, y.kind)
    kindToUnique[y.kind] = y.unique
 end
 local FarmTab = Window:CreateTab("AutoFarm", "dollar-sign")
 local FarmSection = FarmTab:CreateSection("Section Example")


 local PetDropdown = FarmTab:CreateDropdown({
    Name = "Pet 1",
    Options = petOptions,
    CurrentOption = {petOptions[1]},
    MultipleOptions = false,
    Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Options)
        local selectedKind = Options[1] -- get the selected kind (example: "Dog")
        local selectedUnique = kindToUnique[selectedKind] -- get unique ID based on kind
    
        print("Selected kind:", selectedKind)
        print("Selected pet unique:", selectedUnique)
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ToolAPI/Equip"):InvokeServer(selectedUnique, {["use_sound_delay"] = true, ["equip_as_last"] = false})
    end,    
 })

 local Button = FarmTab:CreateButton({
    Name = "Start Farm",
    Callback = function()
        getgenv().PetFarm = true
        task.spawn(startPetFarm)
    end,
 })
