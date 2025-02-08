-- Egg Farm hotdogs v4.5
-- Baby jump fixed
if not hookmetamethod then
    return notify('Incompatible Exploit', 'Your exploit does not support `hookmetamethod`')
end

local TeleportService = game:GetService("TeleportService")
local oldIndex
local oldNamecall

-- Hook __index to intercept TeleportService method calls
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if self == TeleportService and (key:lower() == "teleport" or key == "TeleportToPlaceInstance") then
        return function()
            error("Teleportation blocked by anti-teleport script.", 2)
        end
    end
    return oldIndex(self, key)
end)

-- Hook __namecall to intercept method calls like TeleportService:Teleport(...)
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if self == TeleportService and (method:lower() == "teleport" or method == "TeleportToPlaceInstance") then
        return
    end
    return oldNamecall(self, ...)
end)

print('Anti-Rejoin', 'Teleportation prevention is now active.')


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
local PetData = ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.pets

getgenv().PetFarmGuiStarter = true
local petOptions = {}
local petToEquip

-- Replaced version (https://github.com/Hiraeth127/WorkingVersions.lua/blob/main/FarmPet105c.lua)
-- Currrent version FarmPet105d.lua
    
if not _G.ScriptRunning then
    _G.ScriptRunning = true
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local CoreGui = game:GetService("CoreGui")
    local PlayerGui = Player:FindFirstChildOfClass("PlayerGui") or CoreGui
    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)

    local playButton = game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.EnclosingFrame.MainFrame.Contents.PlayButton
    local babyButton = game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RoleChooserDialog.Baby
    local rbxProductButton = game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RobuxProductDialog.Buttons.ButtonTemplate
    local claimButton = game:GetService("Players").LocalPlayer.PlayerGui.DailyLoginApp.Frame.Body.Buttons.ClaimButton

    task.wait(1)
    local xc = 0
    local NewAcc = false
    local HasTradeLic = false
    local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    local Cash = ClientData.get_data()[game.Players.LocalPlayer.Name].money
    

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
    
    
    local RunService = game:GetService("RunService")
    local DoneAutoPlay = false
    -- Connect to Heartbeat
    RunService.Heartbeat:Connect(function()
        if game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.Enabled then
            FireSig(game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.EnclosingFrame.MainFrame.Contents.PlayButton)
            task.wait(1)
            if game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RoleChooserDialog.Visible then
                FireSig(game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RoleChooserDialog.Baby)
                task.wait(1)
            end
            
            if game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RobuxProductDialog.Visible then
                game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RobuxProductDialog.Visible = false
                task.wait(1)
            end

            if game:GetService("Players").LocalPlayer.PlayerGui.DailyLoginApp.Enabled then
                task.wait(5)
                FireSig(game:GetService("Players").LocalPlayer.PlayerGui.DailyLoginApp.Frame.Body.Buttons.ClaimButton)
                task.wait(1)
                FireSig(game:GetService("Players").LocalPlayer.PlayerGui.DailyLoginApp.Frame.Body.Buttons.ClaimButton)
                task.wait(1)
            end
            local DoneAutoPlay = true
        end

    end)


    


    local NewAcc = false
    local HasTradeLic = false
    if ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.toys then 
        for i, v in pairs(ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.toys) do
            if v.id == "trade_license" then
                print("has trade lic")
                HasTradeLic = true
            end
        end
    end

    if Cash <= 125 and not HasTradeLic then
        print("New account")
        print("Inside new account")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SettingsAPI/SetSetting"):FireServer("theme_color", "red")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/ChooseTeam"):InvokeServer("Parents", {["source_for_logging"] = "intro_sequence", ["dont_enter_location"] = true})
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Tutorial Started")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Editor Opened")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AvatarAPI/SubmitAvatarAnalyticsEvent"):FireServer("opened")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AvatarAPI/SetGender"):FireServer("male")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Editor Closed")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Housing Tutorial Started")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Housing Editor Opened")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/SendHousingOnePointOneLog"):FireServer("edit_state_entered", {["house_type"] = "mine"})
        local args = {
            [1] = {}
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/PushFurnitureChanges"):FireServer(unpack(args))
        local args = {
            [1] = "edit_state_exited",
            [2] = {}
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/SendHousingOnePointOneLog"):FireServer(unpack(args))
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("House Exited")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("DailyLoginAPI/ClaimDailyReward"):InvokeServer()
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Nursery Tutorial Started")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Nursery Entered")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/EquipTutorialEgg"):FireServer()
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Started Egg Received")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TutorialAPI/AddTutorialQuest"):FireServer()
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Tutorial Ailment Spawned")
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/AddHungryAilmentToTutorialEgg"):FireServer()
        local args = {
            [1] = workspace:WaitForChild("Pets"):WaitForChild("Starter Egg")
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/FocusPet"):FireServer(unpack(args))
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/MarkTutorialCompleted"):FireServer()
        while not HasTradeLic do
            print("no trade lic")
            if ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.toys then 
                fsys = require(game.ReplicatedStorage:WaitForChild("Fsys")).load
                local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                fsys("RouterClient").get("SettingsAPI/SetBooleanFlag"):FireServer("has_talked_to_trade_quest_npc", true)
                task.wait()
                fsys("RouterClient").get("TradeAPI/BeginQuiz"):FireServer()
                task.wait(1)
                for i, v in pairs(fsys('ClientData').get("trade_license_quiz_manager")["quiz"]) do
                        fsys("RouterClient").get("TradeAPI/AnswerQuizQuestion"):FireServer(v["answer"])
                    task.wait()
                end
                for i, v in pairs(ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.toys) do
                    if v.id == "trade_license" then
                        print("have trade lic")
                        HasTradeLic = true
                    end
                end
            end
            task.wait(0.4)
        end
        Player:Kick("Tutorial completed please restart game!")
    end
    
    

    -- Function to get current money value
    local function getCurrentMoney()
        local currentMoneyText = Player.PlayerGui.BucksIndicatorApp.CurrencyIndicator.Container.Amount.Text
        local sanitizedMoneyText = currentMoneyText:gsub(",", ""):gsub("%s+", "")
        local currentMoney = tonumber(sanitizedMoneyText)
        if currentMoney == nil then
            return 0
        end
        return currentMoney
    end

    local checkedPets = {} -- Store checked pet kinds

    local function CheckRarity(petname)
        -- Skip if we've already checked this pet
        if checkedPets[petname] then
            return checkedPets[petname] -- Return cached result
        end

        for _, z in pairs(game:GetService("ReplicatedStorage").SharedModules.ContentPacks:GetChildren()) do 
            if z:IsA("Folder") and z:FindFirstChild("InventorySubDB") and z.InventorySubDB:FindFirstChild("Pets") then 
                for _, Pet in pairs(require(z.InventorySubDB.Pets)) do 
                    for _, b in pairs(Pet) do
                        if tostring(b) == petname then
                            checkedPets[petname] = Pet.rarity or "Unknown" -- Cache the result
                            return checkedPets[petname]
                        end
                    end
                end
            end
        end

        checkedPets[petname] = "Not Found" -- Cache missing pets too
        return "Not Found"
    end

    task.wait(1)
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local focusPetApp = Player.PlayerGui.FocusPetApp.Frame
    local ailments = focusPetApp.Ailments
    local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)

    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)


    local virtualUser = game:GetService("VirtualUser")

    Player.Idled:Connect(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end)

    -- ###########################################################################################################


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

    getgenv().fsysCore = require(game:GetService("ReplicatedStorage").ClientModules.Core.InteriorsM.InteriorsM)


    -- ########################################################################################################################################################################

    

    local levelOfPet = 0
    local petToEquip
    local function  getHighestLevelPet()
        -- check for cash 750
        for i, v in pairs(fsys.get("inventory").pets) do
            if levelOfPet < v.properties.age and v.kind ~= "practice_dog" then
                levelOfPet = v.properties.age
                petToEquip = v.unique
                if levelOfPet >= 6 then
                    return petToEquip
                end
            end
        end
        return petToEquip
    end

    local function equipPet()
        local success, fsys = pcall(function()
            return require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
        end)
        
        if not success or not fsys then
            warn("Failed to require fsys")
            return
        end
        
            local equipManager = fsys.get("equip_manager")
            local equipManagerPets = equipManager and equipManager.pets
            local inventory = fsys.get("inventory")
            local inventoryPets = inventory and inventory.pets
        
            if equipManagerPets and equipManagerPets[1] and equipManagerPets[1].kind then
                local currentPetKind = equipManagerPets[1].kind
                local currentPetUnique = equipManagerPets[1].unique
                local currentPetAge = equipManagerPets[1].properties.age
                local eggToFarmExist = false

                for x, y in pairs(inventoryPets) do
                    if y.kind == getgenv().eggToFarm then
                        eggToFarmExist = true
                        petToEquip = y.unique
                        currentPetKind = equipManagerPets[1].kind
                        currentPetUnique = equipManagerPets[1].unique
                        currentPetAge = equipManagerPets[1].properties.age
                        break
                    else
                        eggToFarmExist = false
                    end
                end

                -- Check if we need to set petToEquip

                if petToEquip == nil or (currentPetUnique ~= petToEquip) or (eggToFarmExist and getgenv().eggToFarm ~= currentPetKind) or (not currentPetKind:lower():match("egg$") and Cash > 750 and getgenv().AutoBuyEggs) or (CheckRarity(currentPetKind) ~= "legendary") or (CheckRarity(currentPetKind) == "legendary" and currentPetAge == 6) then
                    local foundPet = false
                    for _, pet in pairs(inventoryPets or {}) do
                        if pet.kind == getgenv().eggToFarm then
                            petToEquip = pet.unique
                            foundPet = true
                            break
                        end
                    end
                end    
                --     if not foundPet then
                --         if Cash > 750 and getgenv().AutoBuyEggs then
                --             local args = {
                --                 [1] = "pets",
                --                 [2] = getgenv().eggToFarm,
                --                 [3] = {
                --                     ["buy_count"] = 1
                --                 }
                --             }
                            
                --             game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ShopAPI/BuyItem"):InvokeServer(unpack(args))
                --             petToEquip = currentPetUnique
                --             foundPet = true
                --             break
                --         else
                --             petToEquip = getHighestLevelPet() -- Fallback to highest level pet
                --         end
                --     end      

                --     PetAilmentsArray = {}  
                -- elseif (CheckRarity(currentPetKind) == "legendary" and currentPetAge < 6) then
                --     petToEquip = currentPetUnique
                -- end
            else
                warn("equip_manager or equip_manager.pets[1] is nil")
                -- for _, pet in pairs(inventoryPets or {}) do
                --     if pet.kind == getgenv().eggToFarm then
                --         petToEquip = pet.unique
                --         foundPet = true
                --         break
                --     end
                -- end
                
                -- if not foundPet then
                --     if Cash > 750 and getgenv().AutoBuyEggs then
                --         local args = {
                --             [1] = "pets",
                --             [2] = getgenv().eggToFarm,
                --             [3] = {
                --                 ["buy_count"] = 1
                --             }
                --         }
                        
                --         game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ShopAPI/BuyItem"):InvokeServer(unpack(args))
                --         local equipManager = fsys.get("equip_manager")
                --         local equipManagerPets = equipManager and equipManager.pets
                --         local inventory = fsys.get("inventory")
                --         local inventoryPets = inventory and inventory.pets
                --         local currentPetKind = equipManagerPets[1].kind
                --         local currentPetUnique = equipManagerPets[1].unique
                --         local currentPetAge = equipManagerPets[1].properties.age
                --         petToEquip = currentPetUnique
                --         foundPet = true
                --         break
                --     else
                --         petToEquip = getHighestLevelPet() -- Fallback to highest level pet
                --     end
                -- end
            end
        

        if petToEquip then
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ToolAPI/Unequip"):InvokeServer(petToEquip, {["use_sound_delay"] = true, ["equip_as_last"] = false})
            task.wait(.3)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ToolAPI/Equip"):InvokeServer(petToEquip, {["use_sound_delay"] = true, ["equip_as_last"] = false})
        end
        PetAilmentsArray = {}
        --print(petToEquip)
    end


    local function createPlatformForce()
        
            local Player = game.Players.LocalPlayer
            local character = Player.Character or Player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

            -- Count existing platforms in the workspace
            local existingPlatforms = 0
            for _, object in pairs(workspace:GetChildren()) do
                if object.Name == "CustomPlatformForce" then
                    existingPlatforms += 1
                end
            end

            local platform = Instance.new("Part")
            platform.Name = "CustomPlatform" -- Unique name to identify the platform
            platform.Size = Vector3.new(1100, 1, 1100) -- Size of the platform
            platform.Anchored = true -- Make sure the platform doesn't fall
            platform.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -5, 0) -- Place 5 studs below the player

            -- Set part properties
            platform.BrickColor = BrickColor.new("Bright yellow") -- You can change the color
            platform.Parent = workspace -- Parent to the workspace so it's visible
            equipPet()
    end



    -- ########################################################################################################################################################################

    local function createPlatform()
            local Player = game.Players.LocalPlayer
            local character = Player.Character or Player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

            -- Count existing platforms in the workspace
            local existingPlatforms = 0
            for _, object in pairs(workspace:GetChildren()) do
                if object.Name == "CustomPlatform" then
                    existingPlatforms += 1
                end
            end

            -- Check if the number of platforms exceeds 5
            if existingPlatforms >= 5 then
                --print("Maximum number of platforms reached, skipping creation.")
                return
            end

            -- Debug message
            --print("Teleport successful, creating platform...")

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



    getgenv().BedID = GetFurniture("EggCrib")
    getgenv().ShowerID = GetFurniture("StylishShower")
    getgenv().PianoID = GetFurniture("Piano")
    getgenv().WaterID = GetFurniture("PetWaterBowl")
    getgenv().FoodID = GetFurniture("PetFoodBowl")
    getgenv().ToiletID = GetFurniture("Toilet")

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
    end

    local function removeItemByValue(tbl, value)
        for i = 1, #tbl do
            if tbl[i] == value then
                table.remove(tbl, i)
                break
            end
        end
    end


    -- ########################################################################################################################################################################

    -- Define the new path
    -- local ailments_list = Player.PlayerGui:WaitForChild("ailments_list")

    local function get_mystery_task()
        local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
        local PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments

        for ailmentId, ailment in pairs(PetAilmentsData) do
            for taskId, task in pairs(ailment) do
                if task.kind == "mystery" and task.components and task.components.mystery then
                    local ailmentKey = task.components.mystery.ailment_key
                    local foundMystery = false

                    for i = 1, 3 do
                        if foundMystery then break end

                        wait(0.5)
                        pcall(function()
                            local actions = {"hungry", "thirsty", "sleepy", "toilet", "bored", "dirty", "play", "school", "salon", "pizza_party", "sick", "camping", "beach_party", "walk", "ride"}
                            
                            for _, action in ipairs(actions) do
                                if not PetAilmentsData[ailmentId] or not PetAilmentsData[ailmentId][taskId] then
                                    --print("Mystery task not found anymore.")
                                    foundMystery = true
                                    break
                                end

                                wait(0.5)
                                local args = {
                                    [1] = ailmentKey,
                                    [2] = i,
                                    [3] = action
                                }

                                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AilmentsAPI/ChooseMysteryAilment"):FireServer(unpack(args))
                            end
                        end)
                    end
                end
            end
        end
    end

    local PetAilmentsArray = {}
    local BabyAilmentsArray = {}
    local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    local PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
    local BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments

    local function getAilments(tbl)
        PetAilmentsArray = {}
        for key, value in pairs(tbl) do
            if key == petToEquip then
                for subKey, subValue in pairs(value) do
                    table.insert(PetAilmentsArray, subValue.kind)
                    --print("ailment added: ", subValue.kind)
                end
            end
        end
    end

    Player.PlayerGui.TransitionsApp.Whiteout:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
        if Player.PlayerGui.TransitionsApp.Whiteout.BackgroundTransparency == 0 then
            Player.PlayerGui.TransitionsApp.Whiteout.BackgroundTransparency = 1
        end
    end)

    local function getBabyAilments(tbl)
        BabyAilmentsArray = {}
        for key, value in pairs(tbl) do
            table.insert(BabyAilmentsArray, key)
            --print("Baby ailment: ", key)
        end
    end

    -- Function to buy an item
    local function buyItem(itemName)
        local args = {
            [1] = "food",
            [2] = itemName,
            [3] = { ["buy_count"] = 1 }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ShopAPI/BuyItem"):InvokeServer(unpack(args))
    end

    -- Function to get the ID of a specific food item
    local function getFoodID(itemName)
        local ailmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].inventory.food
        for key, value in pairs(ailmentsData) do
            if value.id == itemName then
                return key
            end
        end
        return nil
    end

    -- Function to use an item multiple times
    local function useItem(itemID, useCount)
        for i = 1, useCount do
            local args = {
                [1] = itemID,
                [2] = "END"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ToolAPI/ServerUseTool"):FireServer(unpack(args))
            task.wait(0.1)
        end
    end

    local function hasTargetAilment(targetKind)
        local ailments = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
        for _, ailment in pairs(ailments) do
            if ailment.kind == targetKind then
                return true
            end
        end
        return false
    end



    task.wait(1)
    -- ########################################################################################################################################################################
    local taskName = "none"
    local function EatDrink(isEquippedPet)
        if isEquippedPet then
            equipPet()
        end
        task.wait(1)
        if table.find(PetAilmentsArray, "hungry") then
            --print("doing hungry")
            taskName = "🍔"
            getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
            if getgenv().FoodID then
                game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(game:GetService("Players").LocalPlayer,getgenv().FoodID,"UseBlock",{['cframe'] = CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, .5, 0))},fsys.get("pet_char_wrappers")[1]["char"])
                repeat task.wait(1)
                until not hasTargetAilment("hungry")
            else
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
            removeItemByValue(PetAilmentsArray, "hungry")
            PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
            getAilments(PetAilmentsData)
            taskName = "none"
            equipPet()
            --print("done hungry")
        end
        if table.find(PetAilmentsArray, "thirsty") then
            --print("doing thristy")
            taskName = "🥛"
            getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
            if getgenv().WaterID then
                game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(game:GetService("Players").LocalPlayer,getgenv().WaterID,"UseBlock",{['cframe'] = CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, .5, 0))},fsys.get("pet_char_wrappers")[1]["char"])
                repeat task.wait(1)
                until not hasTargetAilment("thirsty")
            else
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
            removeItemByValue(PetAilmentsArray, "thirsty")
            PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
            getAilments(PetAilmentsData)
            taskName = "none"
            equipPet()
            --print("done thristy")
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




    -- ########################################################################################################################################################################
    for _, pet in ipairs(workspace.Pets:GetChildren()) do
        --print(pet.Name)
        petName = pet.Name
    end

    _G.FarmTypeRunning = "none"


    
    local function startPetFarm()
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/ChooseTeam"):InvokeServer("Babies",{["dont_send_back_home"] = true, ["source_for_logging"] = "avatar_editor"})
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()
        task.wait(1)
        buyItems()
        local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
        game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
        game:GetService("Players").LocalPlayer, "Snow")
        teleportPlayerNeeds(0,350,0)
        createPlatform()
        equipPet()
        task.wait(1)

        local apiPath = game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("MoonAPI/ShootingStarCollected")

        task.spawn(function()
            for run = 1, 20 do -- Repeat 20 times
                -- EVENT for MainMap #############################################
                for i = 1, 499 do
                    local args1 = {
                        [1] = "MainMap",
                        [2] = tostring(i) -- Convert the number to a string
                    }
        
                    -- Fire the server with the arguments
                    apiPath:FireServer(unpack(args1))
        
                    -- Optional: Add a small delay to prevent overwhelming the server
                    wait(0.1)
        
                    local args2 = {
                        [1] = "MainMap",
                        [2] = tostring(i), -- Convert the number to a string
                        [3] = true
                    }
        
                    -- Fire the server with the arguments
                    apiPath:FireServer(unpack(args2))
        
                    -- Optional: Add a small delay to prevent overwhelming the server
                    wait(0.1)
                end
            end
            -- ##################################################
        end)
        
        task.spawn(function()
            for run = 1, 20 do -- Repeat 20 times
                -- EVENT for MoonInterior #############################################
                for i = 1, 499 do
                    local args1 = {
                        [1] = "MoonInterior",
                        [2] = tostring(i) -- Convert the number to a string
                    }
        
                    -- Fire the server with the arguments
                    apiPath:FireServer(unpack(args1))
        
                    -- Optional: Add a small delay to prevent overwhelming the server
                    wait(0.1)
        
                    local args2 = {
                        [1] = "MoonInterior",
                        [2] = tostring(i), -- Convert the number to a string
                        [3] = true
                    }
        
                    -- Fire the server with the arguments
                    apiPath:FireServer(unpack(args2))
        
                    -- Optional: Add a small delay to prevent overwhelming the server
                    wait(0.1)
                end
            end
            -- ##################################################
        end)
        

        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
        -- Restore the character to its normal state
        local bodyVelocity = rootPart:FindFirstChildOfClass("BodyVelocity")
        if bodyVelocity then
            bodyVelocity:Destroy() -- Remove BodyVelocity to restore gravity
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false -- Allow normal movement and physics
        end   


        while true do
            while getgenv().PetFarmGuiStarter do
                _G.FarmTypeRunning = "Pet/Baby"
                --print("inside petfarm")
                repeat task.wait(5)
                    task.wait(1)
                    equipPet()
                    --print("inside repeat oten")
                    PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                    BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                    getAilments(PetAilmentsData)
                    getBabyAilments(BabyAilmentsData)
                    if table.find(PetAilmentsArray, "hungry") or table.find(PetAilmentsArray, "thirsty") then
                        EatDrinkSafeCall(true)
                    end
                    -- print("lapas sa hungry")
    
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
                        if not getgenv().PetFarmGuiStarter then
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
                        equipPet()
                        --print("done sick")
                    end
    
                    -- Check if 'school' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "school") or table.find(BabyAilmentsArray, "school") then
                        --print("going school")
                        taskName = "📚"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("School")
                        teleportPlayerNeeds(0, 350, 0)
                        createPlatform()
                        equipPet()
                        repeat task.wait(1)
                        until not hasTargetAilment("school") and not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["school"]
                        task.wait(2)
                        removeItemByValue(PetAilmentsArray, "school")
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
                        equipPet()
                        --print("done school")
                    end
    
                    -- Check if 'salon' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "salon") or table.find(BabyAilmentsArray, "salon") then
                        --print("going salon")
                        taskName = "✂️"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("Salon")
                        teleportPlayerNeeds(0, 350, 0)
                        createPlatform()
                        equipPet()
                        repeat task.wait(1)
                        until not hasTargetAilment("salon") and not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["salon"]
                        task.wait(2)
                        removeItemByValue(PetAilmentsArray, "salon")
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
                        equipPet()
                        --print("done salon")
                    end
                    -- Check if 'pizza_party' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "pizza_party") or table.find(BabyAilmentsArray, "pizza_party") then
                        --print("going pizza")
                        taskName = "🍕"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("PizzaShop")
                        teleportPlayerNeeds(0, 350, 0)
                        createPlatform()
                        equipPet()
                        repeat task.wait(1)
                        until not hasTargetAilment("pizza_party") and not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["pizza_party"]
                        task.wait(2)
                        removeItemByValue(PetAilmentsArray, "pizza_party")
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
                        equipPet()
                        --print("done pizza")
                    end
                    -- Check if 'bored' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "bored") then
                        --print("doing bored")
                        taskName = "🥱"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        equipPet()
                        task.wait(3)
                        if getgenv().PianoID then
                            game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(game:GetService("Players").LocalPlayer,getgenv().PianoID,"Seat1",{['cframe'] = CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, .5, 0))},fsys.get("pet_char_wrappers")[1]["char"])
                            repeat task.wait(1)
                            until not hasTargetAilment("bored")
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
                        removeItemByValue(PetAilmentsArray, "bored")
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        getAilments(PetAilmentsData)
                        taskName = "none"
                        equipPet()
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
                    -- Check if 'beach_party' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "beach_party") or table.find(BabyAilmentsArray, "beach_party") then
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
                        equipPet()
                        repeat task.wait(1)
                        until not hasTargetAilment("beach_party") and not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["beach_party"]
                        task.wait(2)
                        removeItemByValue(PetAilmentsArray, "beach_party")
                        removeItemByValue(BabyAilmentsArray, "beach_party")
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                        getBabyAilments(BabyAilmentsData)
                        getAilments(PetAilmentsData)
                        -- Check if petfarm is true
                        if not getgenv().PetFarmGuiStarter then
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
                        equipPet()
                        --print("done beach part")
                    end
                    -- Check if 'camping' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "camping") or table.find(BabyAilmentsArray, "camping") then
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
                        equipPet()
                        repeat task.wait(1)
                        until not hasTargetAilment("camping") and not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["camping"]
                        task.wait(2)
                        removeItemByValue(PetAilmentsArray, "camping")
                        removeItemByValue(BabyAilmentsArray, "camping")
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                        getAilments(PetAilmentsData)
                        getBabyAilments(BabyAilmentsData)
                        -- Check if petfarm is true
                        if not getgenv().PetFarmGuiStarter then
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
                        equipPet()
                        --print("done camping")
                    end      
                    -- Check if 'dirty' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "dirty") then
                        --print("doing dirty")
                        taskName = "🚿"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        equipPet()
                        task.wait(3)
                        if getgenv().ShowerID then
                            game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(game:GetService("Players").LocalPlayer,getgenv().ShowerID,"UseBlock",{['cframe'] = CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, .5, 0))},fsys.get("pet_char_wrappers")[1]["char"])
                            repeat task.wait(1)
                            until not hasTargetAilment("dirty")
                            removeItemByValue(PetAilmentsArray, "dirty")
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
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        getAilments(PetAilmentsData)
                        taskName = "none"
                        equipPet()
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
                    -- Check if 'sleepy' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "sleepy") then
                        --print("doing sleepy")
                        taskName = "😴"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        equipPet()
                        task.wait(3)
                        if getgenv().BedID then
                            game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(game:GetService("Players").LocalPlayer, getgenv().BedID, "UseBlock", {['cframe']=CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0,.5,0))}, fsys.get("pet_char_wrappers")[1]["char"])
                            repeat task.wait(1)
                            until not hasTargetAilment("sleepy") 
                            removeItemByValue(PetAilmentsArray, "sleepy")
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
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        getAilments(PetAilmentsData)
                        taskName = "none"
                        equipPet()
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
                    -- Check if 'Potty' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "toilet") then
                        --print("going toilet")
                        taskName = "🧻"
                        equipPet()
                        task.wait(3)
                        
                        -- potty
                        if getgenv().ToiletID then
                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ActivateFurniture"):InvokeServer(game:GetService("Players").LocalPlayer,getgenv().ToiletID,"Seat1",{['cframe']=CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0,.5,0))},fsys.get("pet_char_wrappers")[1]["char"])
    
                            repeat task.wait(1)
                            until not hasTargetAilment("toilet")
                            removeItemByValue(PetAilmentsArray, "toilet")
                        else
                            startingMoney = getCurrentMoney()
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
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        getAilments(PetAilmentsData)
                        taskName = "none"
                        equipPet()
                        --print("done potty")
                    end  
                    -- Check if 'mysteryTask' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "mystery") then
                        --print("going mysteryTask")
                        taskName = "❓"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        equipPet()
                        task.wait(3)
                        -- mystery task
                        get_mystery_task()
                        repeat task.wait(1)
                        until not hasTargetAilment("mystery")
                        removeItemByValue(PetAilmentsArray, "mystery")
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        getAilments(PetAilmentsData)
                        taskName = "none"
                        equipPet()
                        --print("done mysteryTask")
                    end 

                    -- Check if 'pet me' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "pet_me") then
                        --print("going pet me")
                        taskName = "👋"
                        equipPet()
                        task.wait(3)
                        -- pet me task
                        -- Loop through all `ailments_list` in PlayerGui
                        local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                        for _, ailmentsList in pairs(playerGui:GetChildren()) do
                            if ailmentsList.Name == "ailments_list" and ailmentsList:FindFirstChild("SurfaceGui") then
                                local container = ailmentsList.SurfaceGui:FindFirstChild("Container")
                                if container and container ~= "UIListLayout" then
                                    for _, button in pairs(container:GetChildren()) do
                                        FireSig(button) -- Click each ailment button
                                        task.wait(3) -- Optional delay between clicks
                                        if game:GetService("Players").LocalPlayer.PlayerGui.FocusPetApp.BackButton.Visible then
                                            -- Handle the API call after interacting with all ailments
                                            print("inside focus")
                                            local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)

                                            local args = {
                                                [1] = ClientData.get("pet_char_wrappers")[1].pet_unique
                                            }
                                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AilmentsAPI/ProgressPetMeAilment"):FireServer(unpack(args))

                                            task.wait(1) -- Optional delay between clicks
                                            -- Click the back button
                                            local backButton = playerGui.FocusPetApp.BackButton
                                            FireSig(backButton)
                                            break
                                        else
                                            print("no back button found")
                                        end
                                    end
                                end
                            end
                        end
                        repeat task.wait(1)
                        until not hasTargetAilment("pet_me")
                        removeItemByValue(PetAilmentsArray, "pet_me")
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        getAilments(PetAilmentsData)
                        taskName = "none"
                        equipPet()
                        --print("done mysteryTask")
                    end

                    -- Check if 'catch' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "play") then
                        --print("going catch")
                        taskName = "🦴"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        equipPet()
                        task.wait(3)
                        for i = 1, 3 do -- Loop 3 times
                        -- Check if petfarm is true
                            if not getgenv().PetFarmGuiStarter then
                                return -- Exit the function or stop the process if petfarm is false
                            end
                            for i, v in pairs(fsys.get("inventory").toys) do
                                if v.id == "squeaky_bone_default" then
                                    ToyToThrow = v.unique
                                end
                            end
                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("PetObjectAPI/CreatePetObject"):InvokeServer("__Enum_PetObjectCreatorType_1", {["reaction_name"] = "ThrowToyReaction", ["unique_id"] = ToyToThrow})
                            wait(4) -- Wait 4 seconds before next iteration
                        end
                        repeat task.wait(1)
                        until not hasTargetAilment("play")
                        removeItemByValue(PetAilmentsArray, "play")
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        getAilments(PetAilmentsData)
                        taskName = "none"
                        equipPet()
                        --print("done catch")
                    end  
                    -- Check if 'sick' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "sick") then
                        --print("going sick")
                        taskName = "🤒"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        -- pet
                        game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("Hospital")
                        task.wait(0.3)
                        teleportPlayerNeeds(0, 350, 0)
                        task.wait(0.3)
                        createPlatform()
                        task.wait(0.3)
                        getgenv().HospitalBedID = GetFurniture("HospitalRefresh2023Bed")
                        task.wait(2)
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ActivateInteriorFurniture"):InvokeServer(getgenv().HospitalBedID, "Seat1", {['cframe']=CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0,.5,0))}, fsys.get("pet_char_wrappers")[1]["char"])
                        task.wait(15)
                        removeItemByValue(PetAilmentsArray, "sick")
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        getAilments(PetAilmentsData)
                        -- Check if petfarm is true
                        if not getgenv().PetFarmGuiStarter then
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
                        equipPet()
                        --print("done sick")
                    end
                    -- Check if 'walk' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "walk") then
                        -- Check if petfarm is true
                        if not getgenv().PetFarmGuiStarter then
                            return -- Exit the function or stop the process if petfarm is false
                        end
                        --print("going walk")
                        taskName = "🚶"
                        equipPet()
                        task.wait(3)
                        -- Get the player's character and HumanoidRootPart
                        local Player = game.Players.LocalPlayer
                        local Character = Player.Character or Player.CharacterAdded:Wait()
                        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                        local Humanoid = Character:WaitForChild("Humanoid") -- Get the humanoid
    
                        -- Set the distance and duration for the walk
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
                            -- Check if petfarm is true
                            if not getgenv().PetFarmGuiStarter then
                                return -- Exit the function or stop the process if petfarm is false
                            end
                            Humanoid:MoveTo(forwardPosition)
                            Humanoid.MoveToFinished:Wait() -- Wait until the humanoid reaches the target
                            task.wait(1) -- Optional pause after reaching the position
                            -- Check if petfarm is true
                            if not getgenv().PetFarmGuiStarter then
                                return -- Exit the function or stop the process if petfarm is false
                            end
                            Humanoid:MoveTo(initialPosition)
                            Humanoid.MoveToFinished:Wait() -- Wait until the humanoid returns to the initial position
                            task.wait(1) -- Optional pause after returning
                        end
                        repeat
                            -- Check if petfarm is true
                            if not getgenv().PetFarmGuiStarter then
                                return -- Exit the function or stop the process if petfarm is false
                            end
                            task.wait(1)
                        until not hasTargetAilment("walk") 
                        -- Reset to default walk speed
                        Humanoid.WalkSpeed = 16
                        removeItemByValue(PetAilmentsArray, "walk")
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        getAilments(PetAilmentsData)
                        taskName = "none"
                        equipPet()
                        --print("done walk")
                    end  
                    -- Check if 'ride' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "ride") then
                        -- Check if petfarm is true
                        if not getgenv().PetFarmGuiStarter then
                            return -- Exit the function or stop the process if petfarm is false
                        end
                        --print("going ride")
                        taskName = "🏎️"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        equipPet()
                        task.wait(3)
                        for i,v in pairs(fsys.get("inventory").strollers) do
                            if v.id == 'stroller-default' then
                                strollerUnique = v.unique
                            end   
                        end
                        
                        
                        local args = {
                            [1] = strollerUnique,
                            [2] = {
                                ["use_sound_delay"] = true,
                                ["equip_as_last"] = false
                            }
                        }
                        
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ToolAPI/Equip"):InvokeServer(unpack(args))         
                        
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/UseStroller"):InvokeServer(fsys.get("pet_char_wrappers")[1]["char"], game:GetService("Players").LocalPlayer.Character.StrollerTool.ModelHandle.TouchToSits.TouchToSit)
                        
                        
                        -- Get the player's character and HumanoidRootPart
                        local Player = game.Players.LocalPlayer
                        local Character = Player.Character or Player.CharacterAdded:Wait()
                        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                        local Humanoid = Character:WaitForChild("Humanoid") -- Get the humanoid
    
                        -- Set the distance and duration for the walk
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
                            -- Check if petfarm is true
                            if not getgenv().PetFarmGuiStarter then
                                return -- Exit the function or stop the process if petfarm is false
                            end
                            Humanoid:MoveTo(forwardPosition)
                            Humanoid.MoveToFinished:Wait() -- Wait until the humanoid reaches the target
                            task.wait(1) -- Optional pause after reaching the position
                            -- Check if petfarm is true
                            if not getgenv().PetFarmGuiStarter then
                                return -- Exit the function or stop the process if petfarm is false
                            end
                            Humanoid:MoveTo(initialPosition)
                            Humanoid.MoveToFinished:Wait() -- Wait until the humanoid returns to the initial position
                            task.wait(1) -- Optional pause after returning
                        end
                        repeat
                            -- Check if petfarm is true
                            if not getgenv().PetFarmGuiStarter then
                                return -- Exit the function or stop the process if petfarm is false
                            end
                            task.wait(1)
                        until not hasTargetAilment("ride")
                        -- Reset to default walk speed
                        Humanoid.WalkSpeed = 16
                        removeItemByValue(PetAilmentsArray, "ride")
                        task.wait(0.3)
                        
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/EjectBaby"):FireServer(fsys.get("pet_char_wrappers")[1]["char"])  
                        task.wait(0.3)              
                        PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                        getAilments(PetAilmentsData)
                        taskName = "none"
                        equipPet()
                        --print("done ride")
                    end            
                    
                until not getgenv().PetFarmGuiStarter
            end
            task.wait(1)
            --print("Petfarm is false")
        end
        
        
    end

    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    getgenv().fsysCore = require(game:GetService("ReplicatedStorage").ClientModules.Core.InteriorsM.InteriorsM)

    local RunService = game:GetService("RunService")
    local currentText

    task.wait(3)
    task.spawn(startPetFarm)
else
    print("Script already running")
end
    
    
    
