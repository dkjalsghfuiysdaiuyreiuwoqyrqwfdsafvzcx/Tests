-- Farm 8/12/25 10:20 AM
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

local args = {
	"show_spawn_location_dialog",
	false
}
game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SettingsAPI/SetSetting"):FireServer(unpack(args))


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

    local playButton = game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.EnclosingFrame.MainFrame.Buttons.PlayButton
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
    
    local NewsApp = game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.Enabled

    local sound = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("SoundPlayer")
    local UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")

    sound.FX:play("BambooButton")
    UI.set_app_visibility("NewsApp", false)

    while NewsApp do
        NewsApp = game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.Enabled
        sound = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("SoundPlayer")
        UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")
    
        sound.FX:play("BambooButton")
        UI.set_app_visibility("NewsApp", false)
        task.wait(3)
    end

    task.wait(5)
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("DailyLoginAPI/ClaimDailyReward"):InvokeServer()
    sound.FX:play("BambooButton")
    UI.set_app_visibility("DailyLoginApp", false)

    -- local RunService = game:GetService("RunService")
    -- local DoneAutoPlay = false
    -- -- Connect to Heartbeat
    -- RunService.Heartbeat:Connect(function()
    --     if game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.Enabled then
    --         FireSig(game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.EnclosingFrame.MainFrame.Buttons.PlayButton)
    --         task.wait(1)
    --         if game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RoleChooserDialog.Visible then
    --             FireSig(game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RoleChooserDialog.Baby)
    --             task.wait(1)
    --         end
            
    --         if game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RobuxProductDialog.Visible then
    --             game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RobuxProductDialog.Visible = false
    --             task.wait(1)
    --         end

    --         if game:GetService("Players").LocalPlayer.PlayerGui.DailyLoginApp.Enabled then
    --             task.wait(5)
    --             FireSig(game:GetService("Players").LocalPlayer.PlayerGui.DailyLoginApp.Frame.Body.Buttons.ClaimButton)
    --             task.wait(1)
    --             FireSig(game:GetService("Players").LocalPlayer.PlayerGui.DailyLoginApp.Frame.Body.Buttons.ClaimButton)
    --             task.wait(1)
    --         end
    --         local DoneAutoPlay = true
    --     end

    -- end)


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

    if Cash <= 10000 and not HasTradeLic then
        print("New account")
        print("Inside new account")
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SettingsAPI/SetSetting"):FireServer("theme_color", "red")
            local args = {
                [1] = "theme_color",
                [2] = "red"
            }
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SettingsAPI/SetSetting"):FireServer(unpack(args))
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/ChooseTeam"):InvokeServer("Parents", {
                ["source_for_logging"] = "intro_sequence",
                ["dont_enter_location"] = true
            })
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Tutorial Started")
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Editor Opened")
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AvatarAPI/SubmitAvatarAnalyticsEvent"):FireServer("opened")
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AvatarAPI/SetGender"):FireServer("male")
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Editor Closed")
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Housing Tutorial Started")
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Housing Editor Opened")
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/SendHousingOnePointOneLog"):FireServer("edit_state_entered", {
                ["house_type"] = "mine"
            })
            task.wait(2)
            local args = { [1] = {} }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/PushFurnitureChanges"):FireServer(unpack(args))
            task.wait(2)
            local args = { [1] = "edit_state_exited", [2] = {} }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/SendHousingOnePointOneLog"):FireServer(unpack(args))
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("House Exited")
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("DailyLoginAPI/ClaimDailyReward"):InvokeServer()
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Nursery Tutorial Started")
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Nursery Entered")
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/EquipTutorialEgg"):FireServer()
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Started Egg Received")
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TutorialAPI/AddTutorialQuest"):FireServer()
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Tutorial Ailment Spawned")
            task.wait(2)
            local args = { [1] = workspace:WaitForChild("Pets"):WaitForChild("Starter Egg") }
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/FocusPet"):FireServer(unpack(args))
            task.wait(2)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/MarkTutorialCompleted"):FireServer()
            task.wait(2)
        end)
        if not success then
            warn("Error in first task: " .. tostring(err))
        end
        
        local success, err = pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local API = ReplicatedStorage:WaitForChild("API")
            
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("npc_interaction")
            task.wait(2)
            API:WaitForChild("TutorialAPI/ChoosePet"):FireServer("dog")
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(2, { chosen_pet = "dog" })
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(3, { named_pet = false })
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet")
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet")
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(4)
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(5)
            task.wait(2)
            API:WaitForChild("TutorialAPI/SpawnPetTreat"):FireServer()
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet_2")
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(6)
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(7)
            task.wait(2)
            API:WaitForChild("TutorialAPI/AddTutorialQuest"):FireServer()
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("opened_taskboard")
            task.wait(2)
            API:WaitForChild("QuestAPI/MarkQuestsViewed"):FireServer()
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet_3")
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("started_playground_nav")
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("reached_playground")
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("opened_taskboard_2")
            task.wait(2)
            API:WaitForChild("QuestAPI/ClaimQuest"):InvokeServer("{6d6b008a-650e-4bea-b65c-20357e85f71c}")
            task.wait(2)
            API:WaitForChild("QuestAPI/MarkQuestsViewed"):FireServer()
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(10)
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet_4")
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("started_home_nav")
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(11)
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(12)
            task.wait(2)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("cured_dirty_ailment")
            task.wait(2)
            API:WaitForChild("DailyLoginAPI/ClaimDailyReward"):InvokeServer()
            task.wait(2)
        end)
        if not success then
            warn("Error in second task: " .. tostring(err))
        end
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
    task.wait(5)
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()
    task.wait(1)
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("PayAPI/DisablePopups"):FireServer()
    task.wait(5)
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

    task.spawn(function()
        while true do
            task.wait(1200) -- every 20 minutes 
            game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            print("Anti-AFK jump")
        end
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

    local PetAilmentsArray = {}
    local BabyAilmentsArray = {}
    local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    local PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
    local BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments

    local function getAilments(tbl)
        task.wait(.3)
        local equipManager = fsys.get("equip_manager")
        local equipManagerPets = equipManager and equipManager.pets
        PetAilmentsArray = {}
        for key, value in pairs(tbl) do
            if key == equipManagerPets[1].unique then
                for subKey, subValue in pairs(value) do
                    table.insert(PetAilmentsArray, subValue.kind)
                    --print("ailment added: ", subValue.kind)
                end
            end
        end
    end
    local function getBabyAilments(tbl)
        BabyAilmentsArray = {}
        for key, value in pairs(tbl) do
            table.insert(BabyAilmentsArray, key)
            --print("Baby ailment: ", key)
        end
    end
    
    local function checkHouse()
        print("=============Checking House================")

        local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
        local Data = ClientData.get_data()[game.Players.LocalPlayer.Name].house_manager

        local activeHouse = { name = nil, active = false }
        local activeIsPudding = false

        local farmingHouse = { name = nil, house_id = nil }

        for _, house in pairs(Data) do
            -- Track the active house (if any)
            if house.active then
                activeHouse.name = house.name
                activeHouse.active = true
                activeIsPudding = (house.name:lower() == "my christmas pudding house")
            end

            -- Cache the first non-pudding house to switch to
            if not farmingHouse.house_id and house.name:lower() ~= "my christmas pudding house" then
                farmingHouse.name = house.name
                farmingHouse.house_id = house.house_id or house.id  -- use whatever key your data uses
            end
        end

        -- Only switch if the active house is the pudding house AND we found an alternative
        if activeHouse.active and activeIsPudding and farmingHouse.house_id then
            print("Changing house to", farmingHouse.name)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/SpawnHouse"):FireServer(farmingHouse.house_id)
            task.wait(10)
            print("Respawning")
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()
        else
            -- Optional logging to understand why no switch happened
            if not activeHouse.active then
                print("No active house; nothing to change.")
            elseif not activeIsPudding then
                print("Active house is not the pudding house; no change needed.")
            elseif not farmingHouse.house_id then
                print("No alternative non-pudding house found to switch to.")
            end
        end

    end

    
    local function equipPet()
        checkHouse()    
        -- Attempt to require ClientData module
        checkHouse()    
        local success, fsys = pcall(function()
            return require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
        end)
        
        if not success or not fsys then
            warn("Failed to require fsys")
            return
        end
        
        local equipManager = fsys.get("equip_manager")
        local equipManagerPets = equipManager and equipManager.pets or {}
        local inventory = fsys.get("inventory")
        local inventoryPets = inventory and inventory.pets or {}
        
        
        local currentPet = equipManagerPets[1]
        local shouldEquipNewPet = not currentPet or not petToEquip or (currentPet.unique ~= petToEquip)
        
        if shouldEquipNewPet then
            for _, pet in pairs(inventoryPets) do
                if pet.kind ~= "practice_dog" then
                    if pet.properties.age == 6 then
                        petToEquip = pet.unique
                        break
                    end
                    petToEquip = pet.unique
                end
            end
    
            petToEquip = petToEquip or getHighestLevelPet()
            
            -- Equip the selected pet
            if petToEquip then
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ToolAPI/Unequip"):InvokeServer(petToEquip, {use_sound_delay = true, equip_as_last = false})
                task.wait(0.3)
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ToolAPI/Equip"):InvokeServer(petToEquip, {use_sound_delay = true, equip_as_last = false})
            end
        end
        
        -- Handle pet ailments
        task.wait(0.3)
        PetAilmentsArray = {}
        task.wait(0.3)
        local playerData = ClientData.get_data()[game.Players.LocalPlayer.Name]
        getAilments(playerData.ailments_manager.ailments)
        task.wait(0.3)
        getBabyAilments(playerData.ailments_manager.baby_ailments)
        task.wait(0.3)
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

        if x == 0 and y == 350 and z == 0 then
            x = math.random(10, 20)
        end
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
                            local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                            local actions = {
                                "hungry", "thirsty", "sleepy", "toilet", "bored", "dirty",
                                "play", "school", "salon", "pizza_party", "sick",
                                "camping", "beachparty", "walk", "ride", "moon"
                            }
                            
                            for i = 1, 3 do
                                -- loop through all actions
                                for _ , action in ipairs(actions) do
                                    local args = {
                                        ClientData.get_data()[game.Players.LocalPlayer.Name].equip_manager.pets[1].unique,
                                        "mystery",
                                        1,
                                        action
                                    }
                                    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AilmentsAPI/ChooseMysteryAilment"):FireServer(unpack(args))
                                    print(ClientData.get_data()[game.Players.LocalPlayer.Name].equip_manager.pets[1].unique, i, action)
                                end
                            end
                        end)
                    end
                end
            end
        end
    end

    -- delete after event
task.spawn(function()
    -- Simple repeating loop (every 10 minutes)
    -- Change DELAY_BETWEEN if you hit throttling
    local INTERIOR_NAME = "MainMap!Christmas"
    local DELAY_BETWEEN = 0.15 -- seconds between each FireServer
    local COOLDOWN_BETWEEN_RUNS = 600 -- 10 minutes
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remoteSKATE = ReplicatedStorage
        :WaitForChild("adoptme_new_net")
        :WaitForChild("adoptme_legacy_shared.ContentPacks.Winter2025.Game.IceSkating.IceSkatingNet:7")
    
    -- Paste your gingerbread IDs here:
    local IDS = {
        "{8F6C3881-F732-42C9-936A-5852D3A194B4}",
        "{F72BD7C6-B22D-4E5C-AA9C-C0FE8F034E43}",
        "{AE2F9B5B-589F-4A12-B4A5-0912FFE8C463}",
        "{3DE5F28B-8893-4BD0-B742-6096E9DDEDB6}",
        "{21119F02-5EB6-4308-B15A-AE086F9605EC}",
        "{40D33237-E99B-4BA3-A0BE-7AEE3AD7B607}",
        "{CBE7FE13-7C12-4469-8F0E-B32E7B224B20}",
        "{5A651C27-4680-40DB-968C-71B89B56F3D0}",
        "{B6510D79-459E-40A7-88A1-06EECF7DFEDD}",
        "{11496169-8138-4EB2-9883-9F0453297D84}",
        "{6DAB765F-B559-4BB5-B70B-C868947D1C56}",
        "{316F5213-D48B-4F4B-8AFB-D18E44ACDDCB}",
        "{5F3EECB5-14F4-4481-BA0D-86EED34D4597}",
        "{6F890B4D-2BB8-446F-A492-21C61EC7D36D}",
        "{4F764D10-CC2B-447E-9876-DC9259316804}",
        "{54E9E593-8C0E-4120-9637-83B0BA891573}",
        "{FD974ABC-023F-4238-BB26-EA963179D61F}",
        "{E774C005-3B66-4736-8E35-421710DB25FB}",
        "{301B6795-D383-41BC-AB6C-6A4C4CAA8EDF}",
        "{60E33537-47D5-4212-958D-307C17501331}",
        "{EB9C2171-5D89-43AB-BA09-2F6439BF805D}",
        "{B6709EA9-0B13-47F5-9022-524426FC2B20}",
        "{20619AAB-74D9-4F8D-AB89-62DB4130C6A9}",
        "{D0A52723-FF4A-40E5-A6B7-16FC57BF9B9E}",
        "{DD2C92B9-881C-4128-B11D-A92E8873472E}",
        "{069AFA82-D910-45A2-AF24-7F33E0237182}",
        "{381C38F4-4B07-4F2E-A12E-AF6328F96A54}",
        "{93F23433-BA8C-49CF-B1A8-D8FDA736623A}",
        "{33430CD2-A47B-4987-ACEA-5EA4ABF9AAE0}",
        "{A2CBBB92-06FB-4CB3-A81F-6926203BD34E}",
        "{AB788250-8C62-45AF-BE63-6493F5363116}",
        "{F0B27251-FFE7-4A70-9077-80D73E10BD1E}",
        "{04A431CF-78AD-4200-9B3E-8DA02A6DA347}",
        "{53C81678-DDD1-410F-9476-0A1AFD17B22D}",
        "{537FCB8D-0868-463D-B2A1-A85E3F9507A3}",
        "{ED15A0DF-DEA5-4EE5-91D4-568CF3D13D20}",
        "{D5EBC9DB-8E7A-45AD-BF8F-F93703B61F20}",
        "{57CF0C2B-CB8F-430A-AE09-6A271E46447D}",
        "{E8749084-B9C2-4C1C-8DCA-8DD601B57E99}",
        "{DEB255CE-6405-43A3-81AD-DCAA8A0A707C}",
        "{081D2B7B-79A6-4330-93EC-C36DF19BBC93}",
        "{45E5C75E-DB43-4196-9B2A-6A3C044C6095}",
        "{F6D9E4BE-9433-4563-A10A-9E3684407E20}",
        "{7A2585D3-0477-40CD-B6FF-BD781A3B5777}",
        "{27AE43F6-30C5-477C-BD53-2511CD23C5CA}",
        "{4A3B540E-FC78-4095-AFDA-F560F263AD13}",
        "{6147E9F3-8FDA-45AF-AF7B-96245CA32096}",
        "{8743B7A9-257B-48DF-8DB0-0F4FD057A4B0}",
        "{600EB06A-F13D-411D-BEB3-E04E93ED4276}",
        "{084B9A25-9B24-461B-8FEB-1A071D2800FB}",
        "{177D7587-F672-49D5-85D1-090AA2AAAB29}",
        "{449145AC-B3DC-4FDD-9C9F-5FFF5F2FA183}",
        "{6C05E92C-38EB-4033-B610-4503E5262FDF}",
        "{50BC1E72-EE91-4332-B707-B24E1622A214}",
        "{C4194D7B-54B5-4B35-B262-1B700143DB56}",
        "{48BB1D7E-0B33-4171-A423-A911FE9A4972}",
        "{0F4D8710-8B26-4D9C-92EC-FFAB5CFEDA15}",
        "{A5D4CB92-D091-41DF-A0F5-968778175398}",
        "{51E924AC-12DF-46F8-A77C-C2756C38AD3B}",
        "{65EF0557-0D8E-4B74-AFD8-FC5DB243EDB8}",
        "{569DD3EB-30D5-4CDD-85B6-5AA6C886D51C}",
        "{E8AD7C9A-C60C-4DE2-A111-A3E8AD26B1D0}",
        "{B484E83E-396E-4ACA-828E-0E1121708E88}",
        "{5926D161-4B98-4901-8A66-6178F21B616C}",
        "{B097C8D5-6034-42F2-ABE1-4CEFE35E76FB}",
        "{4FE802B6-9D8D-4CAA-B07A-775154792D1A}",
        "{8BEADFD7-FB96-4F3D-A2A3-32FC758A60CE}",
        "{832B63F3-FBA5-4380-99DB-78CFB9F87D6F}",
        "{0FBAF510-CE97-44B5-B5EE-43B31B642530}",
        "{374FCE6C-D73A-4E68-AA7F-8954D47A913E}",
        "{505165ED-12ED-4FC3-8E0B-DE786471F388}",
        "{677BBA18-0BDA-4A19-92F9-8C8DF6A11E30}",
        "{154F7871-BCA0-4691-9210-AD6D76103119}",
        "{FE0C85D8-2E11-46BA-BE97-9EC67E96ABB8}",
        "{0DBD86AB-EDAD-4C5F-B64A-E879935418FD}",
        "{9A475EE6-2AA9-407F-96B8-AFD73C904E9C}",
        "{2FA1E614-9B22-495E-8543-A28A449662C0}",
        "{D85AC2E0-131F-4316-B8CF-0CD0BFAC639D}",
        "{DD193776-16EC-4550-B696-19E19CE313D4}",
        "{93479D49-84B0-4410-B39D-D2553FFFFCF0}",
        "{0447C188-1620-4CE4-897D-E34CDBE3F30D}",
        "{AFFECD3D-9FCD-4822-BDF8-1B7F589620DD}",
        "{058EE9BE-D9A9-4660-9729-60E2FF891783}",
        "{1479F2D4-D712-4B53-8B24-546270239BE7}",
        "{0836BB00-2107-49A6-8544-72FC3EECC742}",
        "{439925AF-0A96-40F3-8707-D5A65AA605AF}",
        "{B0390D1A-AAFF-45F9-823E-9DBF1EE671DF}",
        "{30189A3D-F6CE-4B86-A19C-C71E64541796}",
        "{A33B95DC-4636-4FB9-81E1-098C819359A8}",
        "{08D592C6-8F94-435E-98CD-D038E23CF236}",
        "{14F3C7DB-D67E-4288-9D94-AB33653FD928}",
        "{2FAC02AF-1E80-4890-BC34-C5D8F22F12F2}",
        "{71CB1A2A-6433-496F-A75D-79B57EA2020D}",
        "{6DEDCEB2-62B4-4259-BDFF-A3FA56DF71A7}",
        "{A76214EC-C75E-4E91-B515-32CF008CA73F}",
        "{45912694-2CF8-4B46-9222-B4E052EC74FC}",
        "{9E8B22FE-410D-4005-8610-B5BEE9058A01}",
        "{2883E3B9-AEB4-4577-A1E6-D75BD7D00042}",
        "{F11CFC7D-3222-4856-AB81-532ADB118D34}",
        "{CC47FF49-48FD-444E-8F70-BFB36EB4E1DE}",
        "{1B7E9043-B129-4341-BDB9-FA83CE503F5C}",
        "{82B7AF91-D7FD-48D5-BEA1-A7048595647E}",
        "{A6C07949-FE1D-4C8A-9234-782981398813}",
        "{29580925-384D-4CF6-810A-5B2FBEBE14EF}",
        "{487EE748-30B2-40A5-AEAC-2724E29C6C6D}",
        "{C8380520-D52C-46F1-A257-ADA9BC410E79}",
        "{51F28E59-3CEC-46F4-84C3-5D6FD3FBCCF1}",
        "{8B70133A-0EDA-439B-B41D-26B9EE5B824D}",
        "{F0F44CAC-FF90-4B94-A996-5094CECF1531}",
        "{C61B5F35-B5E6-4DDE-B9CA-8C5CDE82D3F5}",
        "{0217C4CB-EBE3-4EAD-BAA8-801D1DD0BD8F}",
        "{4B0E202F-743E-46C3-A538-CAAABE3D6A76}",
        "{3C929F9E-9C60-4844-B6A6-C5AB16B89030}",
        "{1CA3C55C-E6FF-4632-B023-4AFABBD3175F}",
        "{FB967ED2-445C-4B78-8576-5D99AB7AA4B9}",
        "{FC8810F5-8C12-46AC-9260-12E9276199B2}",
        "{E58BFD84-62BE-4A62-A2C8-5D088FB0E6BF}",
        "{25DA2E1D-7191-4B7F-AB26-5EFECB267307}",
        "{87A78497-E137-47E5-AE8A-5E4C0F30D90A}",
        "{69372C32-4F4E-4786-B973-36405115DC84}",
        "{5FD5BDBD-5847-4EFD-9DF1-0AB7B94A3548}",
        "{D194622B-F101-47D3-8974-7610FB3830AE}",
        "{8897445D-6138-4BD6-8DA1-1F02ECFE5898}",
        "{808A9B20-FA50-412A-9A5D-D728B1D355A9}",
        "{5C9A79E8-A97B-4DD9-8B8B-7DAD80B541E0}",
        "{1A218809-DBE4-4542-80B2-2B585D33CEC6}",
        "{63E116B6-1955-4B06-B28F-3113E0760583}",
        "{85A9AEA7-5427-4144-AFC1-12DCE9D5ECB7}",
        "{FD6318F0-8A5F-41CF-9B91-64EBBBCB3E98}",
        "{24236D55-6152-4783-B736-9CAA56F6F655}",
        "{94D2643C-32DC-4D5F-9350-BA5BD54BCA23}",
        "{FCE711AB-1097-47DF-AFD5-E3D8BA0B4BA5}",
        "{1E4A9A9E-F945-4A6A-A777-EA765AC9892D}",
        "{1F104AAC-B4CF-4B9E-8ACA-C72F3B7601D7}",
        "{39592C2B-0CC3-4BDD-9E64-00846F06C629}",
        "{2EEF9B08-10D5-40A6-B563-94FF012868D9}",
        "{28F6FD49-55C2-4E45-88F3-E62344AEE010}",
        "{96EB009D-84A2-464B-925E-41E269B5D7E4}",
        "{437F2FA1-230F-498F-9276-DE0EF87C3AE1}",
        "{1F5105D1-7F27-4C3F-88F8-DAB5AC6F80A7}",
        "{81E888FB-BEF4-4F79-AE22-C5F438EF0E4E}",
        "{9989159C-CF88-4D53-A30D-037A337969D3}",
        "{4112DDAB-4A73-4C16-A75C-DD260D6D0155}",
        "{82062F93-CB93-48AF-9DEB-AB5385F67173}",
        "{D07D63E3-184C-41E1-9664-4DD8E26237C6}",
        "{D1B20364-78F5-4CCC-A510-E40A8D625D16}",
        "{248879AA-6B47-4BCF-AFC0-161C2EBFF6AD}",
        "{F8FAEF3D-A8EC-4FC6-B6DA-9900D9F01089}",
        "{2BEB302F-EB22-4403-B2E7-F4239A306A9C}",
        "{65E06DD8-CCCB-4DFC-ADED-EC29B7890D53}",
        "{40475233-9A85-4BE4-B20F-4C7A2C04C67E}",
        "{A6482191-3E6B-45E0-B1F6-5BE8600C0D46}",
        "{80612A9C-FDE0-4CEE-B5F8-8B7DE2E9DC39}",
        "{850FA732-1759-41FD-8D11-A966F663DC54}",
        "{5E5EAA7A-C7C4-4AB0-AB22-DBFD967098BF}",
        "{CF994B67-FA40-453E-ADEA-859E4B2C48A3}",
    }
    
    while true do
        for _, id in ipairs(IDS) do
            local args = { { interior_name = INTERIOR_NAME, gingerbread_id = id } }
            pcall(function()
                remoteSKATE:FireServer(unpack(args))
            end)
            task.wait(DELAY_BETWEEN)
        end
        task.wait(10)
        game:GetService("ReplicatedStorage"):WaitForChild("adoptme_new_net"):WaitForChild("adoptme_legacy_shared.ContentPacks.Winter2025.Game.IceSkating.IceSkatingNet:16"):FireServer()
        task.wait(COOLDOWN_BETWEEN_RUNS) -- wait 10 minutes
    end
end)




task.spawn(function()
    local remote_skating = game:GetService("ReplicatedStorage")
        :WaitForChild("API")
        :WaitForChild("WinterEventAPI/UseExchangeKiosk")
    
    local REPEAT_DELAY_SKATING = 3600    -- 1 hour (in seconds)
    local BETWEEN_CALLS_SKATING = 1      -- delay between each run (to avoid spam)
    
    while true do
        for i = 1, 3 do
            pcall(function()
                remote_skating:InvokeServer()
            end)
            task.wait(BETWEEN_CALLS_SKATING)
        end
        
        task.wait(REPEAT_DELAY_SKATING) -- wait 1 hour before repeating
    end
end)


    Player.PlayerGui.TransitionsApp.Whiteout:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
        if Player.PlayerGui.TransitionsApp.Whiteout.BackgroundTransparency == 0 then
            Player.PlayerGui.TransitionsApp.Whiteout.BackgroundTransparency = 1
        end
    end)

    

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
            task.wait(2)
        end
    end

    local function hasTargetAilment(targetKind)
        print(targetKind)
        local ailments = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
        for _, ailment in pairs(ailments) do
            if ailment.kind == targetKind then
                print(ailment.kind)
                return true
            end
        end
        return false
    end



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
                local t = 0
                repeat task.wait(1)
                    t = t + 1
                until not hasTargetAilment("hungry") or t > 60
                local args = {
                    [1] = getgenv().fsys.get("pet_char_wrappers")[1].pet_unique
                }
                
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/EjectBaby"):FireServer(unpack(args))
                
            else
                if startingMoney > 80 then
                    --print("Buying required crib")
                    game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(30.5, 0, -20) * CFrame.Angles(-0, -1.57, 0)},["kind"] = "pet_food_bowl"}})
                    task.wait(1)
                    getgenv().FoodID = GetFurniture("PetFoodBowl")
                    startingMoney = getCurrentMoney()
                else
                    --print("Not Enough money to buy food")
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
                local t = 0
                repeat task.wait(1)
                    t = t + 1
                until not hasTargetAilment("thirsty") or t > 60
                local args = {
                    [1] = getgenv().fsys.get("pet_char_wrappers")[1].pet_unique
                }
                
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/EjectBaby"):FireServer(unpack(args))
            else
                if startingMoney > 80 then
                    --print("Buying required crib")
                    game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(30.5, 0, -20) * CFrame.Angles(-0, -1.57, 0)},["kind"] = "pet_water_bowl"}})
                    task.wait(1)
                    getgenv().WaterID = GetFurniture("PetWaterBowl")
                    startingMoney = getCurrentMoney()
                else
                    --print("Not Enough money to buy water")
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
	task.spawn(function()
	    while true do
	        
	        local day = tonumber(os.date("%d"))
	        local admday = day - 1
	        
	        local args = {
	            admday
	        }
	        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("WinterEventAPI/AdventCalendarTryTakeReward"):InvokeServer(unpack(args))
	    
	        task.wait(3600)
	    end    
	end)
    task.spawn(function()
            
        -- === Main loop ==============================================================
        local RS = game:GetService("ReplicatedStorage")
        local API = RS:WaitForChild("API", 10)
        
        local ClientData = require(RS.ClientModules.Core.ClientData)
        local playerName = game.Players.LocalPlayer.Name
        
        -- Optimized Neon + Mega auto-fuser
        -- Neon: 4 x same-kind, age==6, neon ~= true
        -- Mega: 4 x same-kind, age==6, neon == true
        -- Remote lives at API["PetAPI/DoNeonFusion"] (name includes a slash)
        
        assert(API, "[Fusion] API folder not found")
        
        local DoNeonFusion = API:WaitForChild("PetAPI/DoNeonFusion", 10)
        assert(DoNeonFusion, "[Fusion] PetAPI/DoNeonFusion remote not found")
        
        local ClientData = require(RS.ClientModules.Core.ClientData)
        local playerName = game.Players.LocalPlayer.Name
        
        local function inv()
            return ClientData.get_data()[playerName].inventory.pets
        end
        
        -- Build a set of UIDs that are currently in-use/equipped
        local function getActiveUids()
            local set = {}
            local act = ClientData.get_data()[playerName].idle_progression_manager
            local ap = act and act.active_pets
            if ap then
                for _, slot in pairs(ap) do
                    local ii = slot and slot.item_info
                    if ii then
                        local u = ii.unique or ii.id or ii.uid
                        if u then set[u] = true end
                        for _, v in pairs(ii) do
                            if type(v) == "table" then
                                local uu = v.unique or v.id or v.uid
                                if uu then set[uu] = true end
                            end
                        end
                    end
                end
            end
            return set
        end
        
        -- Robust extractor; tolerates flat or item_info schemas
        local function extract(p, key)
            local uid = p.unique or p.id or p.uid or key
            local kind = p.kind or (p.item_info and (p.item_info.kind or p.item_info.Kind))
            local props = p.properties or (p.item_info and p.item_info.properties) or {}
            local age = tonumber(props.age or props.Age)
            local neon = (props.neon == true) or (props.neon == "true")
            local locked = props.locked or props.Locked or props.favorite or props.Favorite
            return uid, kind, age, neon, locked
        end
        
        -- Fast bucket builder (no intermediate tables beyond two maps)
        local function buildBuckets(activeSet)
            local neonBuckets, megaBuckets = {}, {}
            for k, p in pairs(inv() or {}) do
                local uid, kind, age, neon, locked = extract(p, k)
                if uid and kind and age == 6 and not activeSet[uid] and not locked then
                    local bucket = neon and megaBuckets or neonBuckets
                    local arr = bucket[kind]
                    if arr then
                        arr[#arr + 1] = uid
                    else
                        bucket[kind] = { uid }
                    end
                end
            end
            return neonBuckets, megaBuckets
        end
        
        -- Single call shape first (array), with lightweight fallback to 4 args
        local function fuse4(a, b, c, d)
            local ok = pcall(function() DoNeonFusion:InvokeServer({a, b, c, d}) end)
            if ok then return true end
            ok = pcall(function() DoNeonFusion:InvokeServer(a, b, c, d) end)
            return ok
        end
        
        -- Fuse all full groups of 4 from each kind bucket (index stepping; no removes)
        local function fuseBuckets(buckets, label)
            local groups = 0
            for kind, arr in pairs(buckets) do
                local n = #arr - (#arr % 4) -- max multiple of 4
                for i = 1, n, 4 do
                    local a, b, c, d = arr[i], arr[i+1], arr[i+2], arr[i+3]
                    -- Minimal logging to reduce overhead; expand if debugging
                    -- print(("[%s] %s -> %s,%s,%s,%s"):format(label, kind, a, b, c, d))
                    local ok = fuse4(a, b, c, d)
                    if ok then
                        groups = groups + 1
                    else
                        warn(("[Fusion] %s failed for kind=%s on ids=%s,%s,%s,%s")
                            :format(label, tostring(kind), tostring(a), tostring(b), tostring(c), tostring(d)))
                        break -- avoid hammering if server rejects this kind right now
                    end
                    task.wait(1.0) -- gentle throttle
                end
            end
            return groups
        end


        while true do
            -- Commit progression (supports either RemoteEvent or RemoteFunction)
            do
                local commit = API:FindFirstChild("IdleProgressionAPI/CommitAllProgression")
                if commit then
                    pcall(function()
                        if commit:IsA("RemoteEvent") then
                            commit:FireServer()
                        elseif commit:IsA("RemoteFunction") then
                            commit:InvokeServer()
                        else
                            -- some games pack a ModuleScript/Bindable here – safely ignore
                        end
                    end)
                end
            end
        
            -- Safe pen checker/refiller
            local data = ClientData.get_data() and ClientData.get_data()[playerName]
            if not data then
                -- Data not ready yet; try again shortly
                task.wait(5)
                continue
            end
        
            local active = (data.idle_progression_manager and data.idle_progression_manager.active_pets) or {}
            local inv    = (data.inventory and data.inventory.pets) or {}
        
            -- 1) Flatten active pen to {slotId, kind, age}
            local activeList = {}
            for slotId, slot in pairs(active) do
                local info = slot and slot.item_info
                if type(info) == "table" then
                    if info.kind then
                        table.insert(activeList, {
                            slotId = slotId,
                            kind   = info.kind,
                            age    = info.properties and info.properties.age,
                        })
                    else
                        for _, item in pairs(info) do
                            if type(item) == "table" and item.kind then
                                table.insert(activeList, {
                                    slotId = slotId,
                                    kind   = item.kind,
                                    age    = item.properties and item.properties.age,
                                })
                            end
                        end
                    end
                end
            end
        
            -- 2) Check "exactly 4" + "all same kind" + "no eggs (age==6)"
            local count = #activeList
            local allSame = count > 0
            local firstKind = (activeList[1] and activeList[1].kind) or nil
            local hasEgg = false
        
            for i = 1, count do
                local p = activeList[i]
                if p.age == 6 then hasEgg = true end
                if firstKind and p.kind ~= firstKind then allSame = false end
            end
        
            -- If already good, just wait and loop (don't 'return' which would stop the script)
            if count == 4 and allSame and not hasEgg then
                task.wait(450)
				local active = getActiveUids()
	            local neonBuckets, megaBuckets = buildBuckets(active)
	        
	            -- Quick counts without extra loops
	            local function count(arrs) local c=0 for _,v in pairs(arrs) do c=c+#v end return c end
	            -- print(("[Neon ready] %d | [Mega ready] %d"):format(count(neonBuckets), count(megaBuckets)))
	        
	            local neonFused = fuseBuckets(neonBuckets, "Neon")
	            local megaFused = fuseBuckets(megaBuckets, "Mega")
	            print(("[Fusion] Neon groups: %d | Mega groups: %d"):format(neonFused, megaFused))
                print("✅ Pen OK. Waiting 450s…")
                continue
            end
        
            -- 3) Clear the pen (avoid mutating while iterating)
            local RemovePet = API:FindFirstChild("IdleProgressionAPI/RemovePet")
            if RemovePet and RemovePet:IsA("RemoteEvent") then
                for _, p in ipairs(activeList) do
                    pcall(function() RemovePet:FireServer(p.slotId) end)
                end
            end
        
            -- 4) Build inventory by kind (ignore eggs age==6)
            local byKind = {}
            for petId, pet in pairs(inv) do
                if pet and pet.kind then
                    local age = pet.properties and pet.properties.age
                    if age ~= 6 then
                        local list = byKind[pet.kind]
                        if not list then
                            list = {}
                            byKind[pet.kind] = list
                        end
                        list[#list + 1] = petId
                    end
                end
            end
        
            -- 5) Pick any kind that has 4+
            local chosenIds
            for _, ids in pairs(byKind) do
                if #ids >= 4 then
                    chosenIds = { ids[1], ids[2], ids[3], ids[4] }
                    break
                end
            end
        
            if not chosenIds then
                warn("❌ No kind with 4 available (non-egg) in inventory.")
                task.wait(450)
                continue
            end
        
            -- 6) Add 4 pets back
            local AddPet = API:FindFirstChild("IdleProgressionAPI/AddPet")
            if AddPet and AddPet:IsA("RemoteEvent") then
                for _, petId in ipairs(chosenIds) do
                    pcall(function() AddPet:FireServer(petId) end)
                end
                print("♻️ Refilled pen with 4 of the same kind.")
            else
                warn("AddPet remote not found or wrong class.")
            end
        
            local active = getActiveUids()
            local neonBuckets, megaBuckets = buildBuckets(active)
        
            -- Quick counts without extra loops
            local function count(arrs) local c=0 for _,v in pairs(arrs) do c=c+#v end return c end
            -- print(("[Neon ready] %d | [Mega ready] %d"):format(count(neonBuckets), count(megaBuckets)))
        
            local neonFused = fuseBuckets(neonBuckets, "Neon")
            local megaFused = fuseBuckets(megaBuckets, "Mega")
            print(("[Fusion] Neon groups: %d | Mega groups: %d"):format(neonFused, megaFused))

            task.wait(450)
            print("450 seconds done")
        end
        
    end)
    
    -- ########################################################################################################################################################################
    for _, pet in ipairs(workspace.Pets:GetChildren()) do
        --print(pet.Name)
        petName = pet.Name
    end

    _G.FarmTypeRunning = "none"

    local function startPetFarm()
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/ChooseTeam"):InvokeServer("Babies",{["dont_send_back_home"] = true, ["source_for_logging"] = "avatar_editor"})
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()
        task.wait(5)
        buyItems()
        local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
        game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
        game:GetService("Players").LocalPlayer, "Snow")
        teleportPlayerNeeds(0,350,0)
        createPlatform()
        equipPet()
        task.wait(1)

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

        -- ######################################### EVENT


        


        -- #########################################
        

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
                        equipPet()
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
                        equipPet()
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
                        local t = 0
                        repeat 
                            task.wait(1)
                            t = 1 + t
                        until (not hasTargetAilment("school") and not ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments["school"]) or t > 60

                        task.wait(2)
                        removeItemByValue(PetAilmentsArray, "school")
                        removeItemByValue(BabyAilmentsArray, "school")
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
                        local t = 0
                        repeat 
                            task.wait(1)
                            t = t + 1

                            local playerData = ClientData.get_data()
                            local playerName = game.Players.LocalPlayer.Name
                            local babyAilments = playerData and playerData[playerName] and playerData[playerName].ailments_manager and playerData[playerName].ailments_manager.baby_ailments

                            local salonAilment = babyAilments and babyAilments["salon"]
                        until (not hasTargetAilment or not hasTargetAilment("salon")) and not salonAilment or t > 60

                        task.wait(2)
                        removeItemByValue(PetAilmentsArray, "salon")
                        removeItemByValue(BabyAilmentsArray, "salon")
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
                    -- Check if 'salon' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "moon") or table.find(BabyAilmentsArray, "moon") then
                        --print("going moon")
                        taskName = "🌙"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MoonInterior")
                        teleportPlayerNeeds(0, 350, 0)
                        createPlatform()
                        local t = 0
                        repeat 
                            task.wait(1)
                            t = t + 1
                        until (not hasTargetAilment or not hasTargetAilment("moon")) or t > 60

                        task.wait(2)
                        removeItemByValue(PetAilmentsArray, "moon")
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
                        --print("done moon")
                    end
                    -- Check if 'pizza_party' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "pizza_party") or table.find(BabyAilmentsArray, "pizza_party") then
                        --print("going pizza")
                        taskName = "🍕"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("PizzaShop")
                        teleportPlayerNeeds(0, 350, 0)
                        createPlatform()
                        local t = 0
                        repeat 
                            task.wait(1)
                            t = t + 1

                            local playerData = ClientData.get_data()
                            local playerName = game.Players.LocalPlayer.Name
                            local babyAilments = playerData and playerData[playerName] 
                                and playerData[playerName].ailments_manager 
                                and playerData[playerName].ailments_manager.baby_ailments

                            local pizzaAilment = babyAilments and babyAilments["pizza_party"]
                        until (not hasTargetAilment or not hasTargetAilment("pizza_party")) and not pizzaAilment or t > 60

                        task.wait(2)
                        removeItemByValue(PetAilmentsArray, "pizza_party")
                        removeItemByValue(BabyAilmentsArray, "pizza_party")
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
                        task.wait(3)
                        if getgenv().PianoID then
                            game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(game:GetService("Players").LocalPlayer,getgenv().PianoID,"Seat1",{['cframe'] = CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, .5, 0))},fsys.get("pet_char_wrappers")[1]["char"])
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until (not hasTargetAilment or not hasTargetAilment("bored")) or t > 60

                            local args = {
                                [1] = getgenv().fsys.get("pet_char_wrappers")[1].pet_unique
                            }
                            
                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/EjectBaby"):FireServer(unpack(args))
                        else
                            startingMoney = getCurrentMoney()
                            if startingMoney > 100 then
                                --print("Buying Required Piano")
                                game:GetService("ReplicatedStorage").API:FindFirstChild("HousingAPI/BuyFurnitures"):InvokeServer({[1] = {["properties"] = {["cframe"] = CFrame.new(7.5, 7.5, -5.5) * CFrame.Angles(-1.57, 0, -0)},["kind"] = "piano"}})
                                task.wait(1)
                                getgenv().PianoID = GetFurniture("Piano")
                                startingMoney = getCurrentMoney()
                            else
                                --print("Not Enough money to buy piano")
                            end
                        end
                        removeItemByValue(PetAilmentsArray, "bored")
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
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1

                                local playerData = ClientData.get_data()
                                local playerName = game.Players.LocalPlayer.Name
                                local babyAilments = playerData and playerData[playerName] 
                                    and playerData[playerName].ailments_manager 
                                    and playerData[playerName].ailments_manager.baby_ailments

                                local boredAilment = babyAilments and babyAilments["bored"]
                            until not boredAilment or t > 60

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
                                --print("Not Enough money to buy piano")
                            end
                        end
                        BabyAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.baby_ailments
                        getBabyAilments(BabyAilmentsData)
                        equipPet()
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
                        local t = 0
                        repeat 
                            task.wait(1)
                            t = t + 1

                            local playerData = ClientData.get_data()
                            local playerName = game.Players.LocalPlayer.Name
                            local babyAilments = playerData and playerData[playerName] 
                                and playerData[playerName].ailments_manager 
                                and playerData[playerName].ailments_manager.baby_ailments

                            local beachAilment = babyAilments and babyAilments["beach_party"]
                        until (not hasTargetAilment or not hasTargetAilment("beach_party")) and not beachAilment or t > 60

                        task.wait(2)
                        removeItemByValue(PetAilmentsArray, "beach_party")
                        removeItemByValue(BabyAilmentsArray, "beach_party")
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
                        local t = 0
                        repeat 
                            task.wait(1)
                            t = t + 1

                            local playerData = ClientData.get_data()
                            local playerName = game.Players.LocalPlayer.Name
                            local babyAilments = playerData and playerData[playerName] 
                                and playerData[playerName].ailments_manager 
                                and playerData[playerName].ailments_manager.baby_ailments

                            local campingAilment = babyAilments and babyAilments["camping"]
                        until (not hasTargetAilment or not hasTargetAilment("camping")) and not campingAilment or t > 60

                        task.wait(2)
                        removeItemByValue(PetAilmentsArray, "camping")
                        removeItemByValue(BabyAilmentsArray, "camping")
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
                        task.wait(3)
                        if getgenv().ShowerID then
                            game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(game:GetService("Players").LocalPlayer,getgenv().ShowerID,"UseBlock",{['cframe'] = CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0, .5, 0))},fsys.get("pet_char_wrappers")[1]["char"])
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until not hasTargetAilment("dirty") or t > 60

                            local args = {
                                [1] = getgenv().fsys.get("pet_char_wrappers")[1].pet_unique
                            }
                            
                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/EjectBaby"):FireServer(unpack(args))
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
                                --print("Not Enough money to buy shower")
                            end
                        end
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
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1

                                local playerData = ClientData.get_data()
                                local playerName = game.Players.LocalPlayer.Name
                                local babyAilments = playerData and playerData[playerName] 
                                    and playerData[playerName].ailments_manager 
                                    and playerData[playerName].ailments_manager.baby_ailments

                                local dirtyAilment = babyAilments and babyAilments["dirty"]
                            until not dirtyAilment or t > 60

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
                        equipPet()
                        --print("done dirty")
                    end
                    
                    -- Check if 'sleepy' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "sleepy") then
                        --print("doing sleepy")
                        taskName = "😴"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        task.wait(3)
                        if getgenv().BedID then
                            game:GetService("ReplicatedStorage").API["HousingAPI/ActivateFurniture"]:InvokeServer(game:GetService("Players").LocalPlayer, getgenv().BedID, "UseBlock", {['cframe']=CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0,.5,0))}, fsys.get("pet_char_wrappers")[1]["char"])
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until not hasTargetAilment("sleepy") or t > 60

                            local args = {
                                [1] = getgenv().fsys.get("pet_char_wrappers")[1].pet_unique
                            }
                            
                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/EjectBaby"):FireServer(unpack(args))
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
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1

                                local playerData = ClientData.get_data()
                                local playerName = game.Players.LocalPlayer.Name
                                local babyAilments = playerData and playerData[playerName] 
                                    and playerData[playerName].ailments_manager 
                                    and playerData[playerName].ailments_manager.baby_ailments

                                local sleepyAilment = babyAilments and babyAilments["sleepy"]
                            until not sleepyAilment or t > 60

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
                        equipPet()
                        --print("done baby sleepy")
                    end     
                    
                    -- Check if 'Potty' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "toilet") then
                        --print("going toilet")
                        taskName = "🧻"
                        task.wait(3)
                        
                        -- potty
                        if getgenv().ToiletID then
                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ActivateFurniture"):InvokeServer(game:GetService("Players").LocalPlayer,getgenv().ToiletID,"Seat1",{['cframe']=CFrame.new(game:GetService("Players").LocalPlayer.Character.Head.Position + Vector3.new(0,.5,0))},fsys.get("pet_char_wrappers")[1]["char"])
    
                            local t = 0
                            repeat 
                                task.wait(1)
                                t = t + 1
                            until not hasTargetAilment("toilet") or t > 60

                            local args = {
                                [1] = getgenv().fsys.get("pet_char_wrappers")[1].pet_unique
                            }
                            
                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/EjectBaby"):FireServer(unpack(args))
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
                        taskName = "none"
                        equipPet()
                        --print("done potty")
                    end  
                    
                    -- Check if 'mysteryTask' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "mystery") then
                        --print("going mysteryTask")
                        taskName = "❓"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                        task.wait(3)
                        -- mystery task
                        local actions = {
                            "hungry", "thirsty", "sleepy", "toilet", "bored", "dirty",
                            "play", "school", "salon", "pizza_party", "sick",
                            "camping", "beach_party", "walk", "ride", "moon"
                        }
                        
                        for _, action in ipairs(actions) do
                            local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
                            local args = {
                                ClientData.get_data()[game.Players.LocalPlayer.Name].equip_manager.pets[1].unique,
                                "mystery",
                                1,
                                action  -- pass the current string, not the whole table
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AilmentsAPI/ChooseMysteryAilment"):FireServer(unpack(args))
                            task.wait(2)
                        end
                        local t = 0
                        repeat task.wait(1)
                            t = 1 + t
                        until not hasTargetAilment("mystery") or t > 60
                        local args = {
                            [1] = getgenv().fsys.get("pet_char_wrappers")[1].pet_unique
                        }
                        
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/EjectBaby"):FireServer(unpack(args))
                        removeItemByValue(PetAilmentsArray, "mystery")
                        taskName = "none"
                        equipPet()
                        --print("done mysteryTask")
                    end 

                    -- Check if 'pet me' is in the PetAilmentsArray
                    -- if table.find(PetAilmentsArray, "pet_me") then
                    --     --print("going pet me")
                    --     taskName = "👋"
                    --     equipPet()
                    --     task.wait(3)
                    --     -- pet me task
                    --     -- Loop through all `ailments_list` in PlayerGui
                    --     local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                    --     for _, ailmentsList in pairs(playerGui:GetChildren()) do
                    --         if ailmentsList.Name == "ailments_list" and ailmentsList:FindFirstChild("SurfaceGui") then
                    --             local container = ailmentsList.SurfaceGui:FindFirstChild("Container")
                    --             if container and container ~= "UIListLayout" then
                    --                 for _, button in pairs(container:GetChildren()) do
                    --                     FireSig(button) -- Click each ailment button
                    --                     task.wait(3) -- Optional delay between clicks
                    --                     if game:GetService("Players").LocalPlayer.PlayerGui.FocusPetApp.BackButton.Visible then
                    --                         -- Handle the API call after interacting with all ailments
                    --                         print("inside focus")
                    --                         local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)

                    --                         local args = {
                    --                             [1] = ClientData.get("pet_char_wrappers")[1].pet_unique
                    --                         }
                    --                         game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AilmentsAPI/ProgressPetMeAilment"):FireServer(unpack(args))

                    --                         task.wait(1) -- Optional delay between clicks
                    --                         -- Click the back button
                    --                         local backButton = playerGui.FocusPetApp.BackButton
                    --                         FireSig(backButton)
                    --                         break
                    --                     else
                    --                         print("no back button found")
                    --                     end
                    --                 end
                    --             end
                    --         end
                    --     end
                    --     local t = 0
                    --     repeat task.wait(1)
                    --         t = 1 + t
                    --         print('doing pet me')
                    --     until not hasTargetAilment("pet_me") or t > 60
                    --     removeItemByValue(PetAilmentsArray, "pet_me")
                    --     local args = {
                    --         [1] = getgenv().fsys.get("pet_char_wrappers")[1].pet_unique
                    --     }
                        
                    --     game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/EjectBaby"):FireServer(unpack(args))
                    --     PetAilmentsData = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
                    --     getAilments(PetAilmentsData)
                    --     taskName = "none"
                    --     equipPet()
                    --     --print("done mysteryTask")
                    -- end

                    
                    -- Check if 'catch' is in the PetAilmentsArray
                    if table.find(PetAilmentsArray, "play") then
                        --print("going catch")
                        taskName = "🦴"
                        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
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
                        local t = 0
                        repeat task.wait(1)
                            t = 1 + t
                        until not hasTargetAilment("play") or t > 60
                        local args = {
                            [1] = getgenv().fsys.get("pet_char_wrappers")[1].pet_unique
                        }
                        
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/EjectBaby"):FireServer(unpack(args))
                        removeItemByValue(PetAilmentsArray, "play")
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
                        local args = {
                            [1] = getgenv().fsys.get("pet_char_wrappers")[1].pet_unique
                        }
                        
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/EjectBaby"):FireServer(unpack(args))
                        removeItemByValue(PetAilmentsArray, "sick")
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
                        local t = 0
                        repeat
                            -- Check if petfarm is true

                            if not getgenv().PetFarmGuiStarter then
                                return -- Exit the function or stop the process if petfarm is false
                            end
                            t = 1 + t
                            task.wait(1)
                        until not hasTargetAilment("walk") or t > 60
                        -- Reset to default walk speed
                        Humanoid.WalkSpeed = 16
                        removeItemByValue(PetAilmentsArray, "walk")
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


                        local args = {
                            game:GetService("Players"):WaitForChild(workspace:WaitForChild("PlayerCharacters"):GetChildren()[1].Name),
                            workspace:WaitForChild("Pets"):GetChildren()[1],
                            game:GetService("Players").LocalPlayer.Character:WaitForChild("StrollerTool"):WaitForChild("ModelHandle"):WaitForChild("TouchToSits"):WaitForChild("TouchToSit")
                        }
                        
                        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/UseStroller"):InvokeServer(unpack(args))
                        
                        
                        
                        
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
                        local t = 0
                        repeat
                            t = 1 + t
                            -- Check if petfarm is true
                            if not getgenv().PetFarmGuiStarter then
                                return -- Exit the function or stop the process if petfarm is false
                            end
                            task.wait(1)
                        until not hasTargetAilment("ride") or t > 60
                        -- Reset to default walk speed

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
                        removeItemByValue(PetAilmentsArray, "ride")
                        task.wait(0.3)
                                             
                        task.wait(0.3)              
                        taskName = "none"
                        equipPet()
                        --print("done ride")
                    end            
                    equipPet()
                until not getgenv().PetFarmGuiStarter
            end
            task.wait(1)
            --print("Petfarm is false")
        end
        
        
    end

    -- ###############################################################################################################################################
    -- TRACKER
    -- ###############################################################################################################################################
    -- Fetch required services and modules
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    -- Create a ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomGui"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.IgnoreGuiInset = true -- Ignore default GUI insets
    
    -- Main background frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0) -- Fullscreen
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.fromHex("#514FDB") -- Purple background
    frame.Parent = screenGui
    
    
    
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.1, 0) -- Occupies 10% of the screen height
    titleLabel.Position = UDim2.new(0, 0, 0.2, 0) -- Top of the screen
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "HIRA X\ngg/bNBBB8MTgr"
    titleLabel.TextColor3 = Color3.new(1, 1, 1) -- White text
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextScaled = false -- Disable scaling to set fixed TextSize
    titleLabel.TextSize = 32 -- Set text size to 32
    titleLabel.TextWrapped = false -- Disable wrapping
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center -- Center horizontally
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center -- Center vertically
    titleLabel.Parent = frame
    
    
    -- Toggle Button (Next to HIRA X Title)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.1, 0, 0.05, 0) -- Adjust size to fit nicely
    toggleButton.Position = UDim2.new(0.55, 0, 0.2, 0) -- Adjust placement next to the title
    toggleButton.Text = "🙂"
    toggleButton.BackgroundTransparency = 1
    toggleButton.TextColor3 = Color3.new(1, 1, 1) -- White text
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextScaled = true -- Scale text to fit the button
    toggleButton.Parent = screenGui
    
    -- Variable to track GUI state
    local isGuiVisible = true
    
    -- Function to toggle GUI visibility
    local function toggleGui()
        isGuiVisible = not isGuiVisible
        frame.Visible = isGuiVisible
        toggleButton.Text = isGuiVisible and "😎" or "🙂"
    end
    
    -- Connect button click to toggle function
    toggleButton.MouseButton1Click:Connect(toggleGui)
    
    -- Ensure the GUI is initially visible
    frame.Visible = isGuiVisible
    
    
    -- Stats Container
    local statsContainer = Instance.new("Frame")
    statsContainer.Size = UDim2.new(0.8, 0, 0.3, 0) -- 80% width, 60% height
    statsContainer.Position = UDim2.new(0.35, 0, 0.35, 0) -- Centered horizontally and slightly below title
    statsContainer.BackgroundTransparency = 1 -- Transparent background
    statsContainer.Parent = frame
    
    
    -- Function to smoothly transition through RGB colors
    local function RGBCycle(textLabel)
        local t = 0 -- Time variable for smooth transitions
        while true do
            -- Calculate RGB values based on sine wave functions
            local r = math.sin(t) * 127 + 128
            local g = math.sin(t + 2) * 127 + 128
            local b = math.sin(t + 4) * 127 + 128
    
            -- Set the TextColor3 property
            textLabel.TextColor3 = Color3.fromRGB(r, g, b)
    
            -- Increment the time variable for smooth transitions
            t = t + 0.05
            task.wait(0.05) -- Adjust the speed of the color cycle
        end
    end
    
    -- Function to create a stat row
    local function createStatRow(parent, labelText, order)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(0.41, 0, 0.2, 0) -- Each row is 20% of the container height
        row.Position = UDim2.new(0, 0, (order - 1) * 0.2, 0) -- Stack rows vertically
        row.BackgroundTransparency = 1
        row.Parent = parent
    
        -- Label for stat name
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 1, 0) -- Label occupies 40% of row width
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.new(1, 1, 1) -- White text
        label.Font = Enum.Font.SourceSansBold
        label.TextScaled = false -- Disable scaling to set fixed TextSize
        label.TextSize = 32 -- Correct TextSize
        label.TextWrapped = false -- Disable wrapping
        label.TextXAlignment = Enum.TextXAlignment.Left -- Align left
        label.TextYAlignment = Enum.TextYAlignment.Center -- Center vertically
        label.Parent = row
    
        -- Label for stat value
        local value = Instance.new("TextLabel")
        value.Size = UDim2.new(0.6, 0, 1, 0) -- Value occupies 60% of row width
        value.Position = UDim2.new(0.4, 0, 0, 0) -- Positioned next to the label
        value.BackgroundTransparency = 1
        value.Text = "" -- Value will be updated dynamically
        value.TextColor3 = Color3.new(1, 1, 1) -- White text
        value.Font = Enum.Font.SourceSansBold
        value.TextScaled = false -- Disable scaling to set fixed TextSize
        value.TextSize = 32 -- Correct TextSize
        value.TextWrapped = false -- Disable wrapping
        value.TextXAlignment = Enum.TextXAlignment.Right -- Align right
        value.TextYAlignment = Enum.TextYAlignment.Center -- Center vertically
        value.Parent = row
    
        return value
    end
    
    -- Create rows for stats
    local moneyValue = createStatRow(statsContainer, "MONEY:", 1)
    local potionValue = createStatRow(statsContainer, "POTION:", 2)
    local timeValue = createStatRow(statsContainer, "TIME:", 3)
    local taskValue = createStatRow(statsContainer, "TASK:", 4)
    local petValue = createStatRow(statsContainer, "PET:", 5)
    local farmType = createStatRow(statsContainer, "Farm Type:", 6)
    local petWrappers = fsys.get("pet_char_wrappers") -- Get the pet wrappers
    getgenv().petToEquipName = "Loading..."
    if petWrappers and petWrappers[1] and petWrappers[1]["char"] then
        getgenv().petToEquipName = petWrappers[1]["char"]
    end
    --print(getgenv().petToEquipName)
    
    -- Function to format elapsed time
    local function formatTime(seconds)
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local secondsLeft = seconds % 60
        return string.format("%02d:%02d:%02d", hours, minutes, secondsLeft)
    end
    
    
    
    
    -- Initialize values
    local initialMoney = getCurrentMoney()
    local initialPotion = 0
    local startTime = os.time()
    
    for _, v in pairs(fsys.get("inventory").food) do
        if v.id == "pet_age_potion" then
            initialPotion = initialPotion + 1
        end
    end
    
    -- Function to update stats dynamically
    local function updateStats()
        -- Get current money and potion counts
        local currentMoney = getCurrentMoney()
        local currentPotionCount = 0
        local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
        local rootData = ClientData.get_data()[game.Players.LocalPlayer.Name]
        for _, v in pairs(fsys.get("inventory").food) do
            if v.id == "pet_age_potion" then
                currentPotionCount = currentPotionCount + 1
            end
        end
    
        -- Calculate changes
        local moneyChange = currentMoney - initialMoney
        local potionChange = currentPotionCount - initialPotion
        local elapsedTime = os.time() - startTime
    
        -- Format elapsed time
        local formattedTime = formatTime(elapsedTime)
    
        -- Dynamic updates for stats
        moneyValue.Text = tostring(currentMoney) .. " (+" .. tostring(moneyChange) .. ")"
        potionValue.Text = tostring(currentPotionCount) .. " (+" .. tostring(potionChange) .. ")"
        timeValue.Text = formattedTime
        taskValue.Text = tostring(taskName or "None")
        petValue.Text = tostring(getgenv().petToEquipName or "None") -- Ensure `getgenv().petToEquipName` is set elsewhere in your script
        farmType.Text = _G.FarmTypeRunning
    end
    
    -- Initial update and periodic refresh
    updateStats()
    
    
    -- Function to continuously update UI
    local function startUIUpdate()
        while true do
            updateStats()
            local petWrappers = fsys.get("pet_char_wrappers") -- Get the pet wrappers
            getgenv().petToEquipName = "Loading..."
            if petWrappers and petWrappers[1] and petWrappers[1]["char"] then
                getgenv().petToEquipName = petWrappers[1]["char"]
            end
            task.wait(1) -- Adjust the wait time as needed (e.g., every 1 second)
        end
    end
    
    local UserInputService = game:GetService("UserInputService")
    
    -- Variable to track the transparency state
    local isTransparent = false
    
    -- Function to handle key press
    local function onKeyPress(input, gameProcessedEvent)
        if not gameProcessedEvent then
            if input.KeyCode == Enum.KeyCode.U then
                -- Toggle transparency
                if screenGui and frame then
                    isTransparent = not isTransparent
                    frame.BackgroundTransparency = isTransparent and 1 or 0
                    --print("Background transparency set to " .. frame.BackgroundTransparency)
                else
                    --print("CustomGui not found!")
                end
            end
        end
    end
    -- Connect the function to UserInputService
    UserInputService.InputBegan:Connect(onKeyPress)
    task.wait(5)
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    getgenv().fsysCore = require(game:GetService("ReplicatedStorage").ClientModules.Core.InteriorsM.InteriorsM)

    local RunService = game:GetService("RunService")
    local currentText

    task.wait(3)
    task.spawn(startPetFarm)
    task.wait(1)
    task.spawn(startUIUpdate)
    task.wait(1)
    task.spawn(function()
        RGBCycle(titleLabel)
    end)
    task.spawn(function()
        local lastMoney = getCurrentMoney()
        local unchangedTime = 0
    
        while true do
            task.wait(60) -- wait 1 minute
            local currentMoney = getCurrentMoney()
    
            if currentMoney ~= lastMoney then
                lastMoney = currentMoney
                unchangedTime = 0
            else
                unchangedTime += 60
            end

            if unchangedTime >= 600 then -- 10 minutes
                getgenv().PetFarmGuiStarter = false
                task.wait(30)
                getgenv().PetFarmGuiStarter = true
                task.spawn(startPetFarm)
                break
            end
    
            if unchangedTime >= 1200 then -- 20 minutes
                Player:Kick("No money earned in the last 20 minutes.")
                break
            end
        end
    end)
else
    print("Script already running")
end
