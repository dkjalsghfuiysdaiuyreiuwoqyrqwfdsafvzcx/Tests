--REVAMP
--sick task 3/17/25 6:16
getgenv().PetFarm = true

if not _G.ScriptRunning then
    _G.ScriptRunning = true

    -- Added time to load

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

    
    --print("FarmPet Now running!")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local CoreGui = game:GetService("CoreGui")
    local PlayerGui = Player:FindFirstChildOfClass("PlayerGui") or CoreGui
    local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
    
    local playButton = game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.EnclosingFrame.MainFrame.Buttons.PlayButton
    local babyButton = game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RoleChooserDialog.Baby
    local rbxProductButton = game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RobuxProductDialog.Buttons.ButtonTemplate
    local claimButton = game:GetService("Players").LocalPlayer.PlayerGui.DailyLoginApp.Frame.Body.Buttons.ClaimButton
    
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
    
    --print("After dehash")
    
    
    
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
    local debounceNewsApp = false
    local debounceRoleChooser = false
    local debounceRobuxDialog = false
    local debounceLoginApp = false
    
    RunService.Heartbeat:Connect(function()
        -- Handle NewsApp
        if game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.Enabled and not debounceNewsApp then
            debounceNewsApp = true
            FireSig(game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.EnclosingFrame.MainFrame.Buttons.PlayButton)
            task.wait(1)
        elseif not game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.Enabled then
            debounceNewsApp = false
        end
        
        -- Handle RoleChooser dialog
        if game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RoleChooserDialog.Visible and not debounceRoleChooser then
            debounceRoleChooser = true
            FireSig(game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RoleChooserDialog.Baby)
            task.wait(1)
        elseif not game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RoleChooserDialog.Visible then
            debounceRoleChooser = false
        end
        
        -- Handle RobuxProduct dialog
        if game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RobuxProductDialog.Visible and not debounceRobuxDialog then
            debounceRobuxDialog = true
            game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RobuxProductDialog.Visible = false
            task.wait(1)
        elseif not game:GetService("Players").LocalPlayer.PlayerGui.DialogApp.Dialog.RobuxProductDialog.Visible then
            debounceRobuxDialog = false
        end
        
        -- Handle DailyLoginApp
        if game:GetService("Players").LocalPlayer.PlayerGui.DailyLoginApp.Enabled and not debounceLoginApp then
            debounceLoginApp = true
            FireSig(game:GetService("Players").LocalPlayer.PlayerGui.DailyLoginApp.Frame.Body.Buttons.ClaimButton)
            task.wait(1)
        elseif not game:GetService("Players").LocalPlayer.PlayerGui.DailyLoginApp.Enabled then
            debounceLoginApp = false
        end
    end)
    --print("After runservice")
    
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
    
    
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SettingsAPI/SetSetting"):FireServer("theme_color", "red")
            local args = {
                [1] = "theme_color",
                [2] = "red"
            }
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SettingsAPI/SetSetting"):FireServer(unpack(args))
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/ChooseTeam"):InvokeServer("Parents", {
                ["source_for_logging"] = "intro_sequence",
                ["dont_enter_location"] = true
            })
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Tutorial Started")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Editor Opened")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AvatarAPI/SubmitAvatarAnalyticsEvent"):FireServer("opened")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AvatarAPI/SetGender"):FireServer("male")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Editor Closed")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Housing Tutorial Started")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Housing Editor Opened")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/SendHousingOnePointOneLog"):FireServer("edit_state_entered", {
                ["house_type"] = "mine"
            })
            task.wait(0.1)
            local args = { [1] = {} }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/PushFurnitureChanges"):FireServer(unpack(args))
            task.wait(0.1)
            local args = { [1] = "edit_state_exited", [2] = {} }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/SendHousingOnePointOneLog"):FireServer(unpack(args))
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("House Exited")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("DailyLoginAPI/ClaimDailyReward"):InvokeServer()
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Nursery Tutorial Started")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Nursery Entered")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/EquipTutorialEgg"):FireServer()
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Started Egg Received")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TutorialAPI/AddTutorialQuest"):FireServer()
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Tutorial Ailment Spawned")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/AddHungryAilmentToTutorialEgg"):FireServer()
            task.wait(0.1)
            local args = { [1] = workspace:WaitForChild("Pets"):WaitForChild("Starter Egg") }
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/FocusPet"):FireServer(unpack(args))
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/MarkTutorialCompleted"):FireServer()
            task.wait(0.1)
        end)
        if not success then
            warn("Error in first task: " .. tostring(err))
        end
        
        local success, err = pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local API = ReplicatedStorage:WaitForChild("API")
            
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("npc_interaction")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ChoosePet"):FireServer("dog")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(2, { chosen_pet = "dog" })
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(3, { named_pet = false })
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(4)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(5)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/SpawnPetTreat"):FireServer()
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet_2")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(6)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(7)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/AddTutorialQuest"):FireServer()
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("opened_taskboard")
            task.wait(0.1)
            API:WaitForChild("QuestAPI/MarkQuestsViewed"):FireServer()
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet_3")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("started_playground_nav")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("reached_playground")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("opened_taskboard_2")
            task.wait(0.1)
            API:WaitForChild("QuestAPI/ClaimQuest"):InvokeServer("{6d6b008a-650e-4bea-b65c-20357e85f71c}")
            task.wait(0.1)
            API:WaitForChild("QuestAPI/MarkQuestsViewed"):FireServer()
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(10)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet_4")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("started_home_nav")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(11)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(12)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("cured_dirty_ailment")
            task.wait(0.1)
            API:WaitForChild("DailyLoginAPI/ClaimDailyReward"):InvokeServer()
            task.wait(0.1)
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
    
    task.spawn(function()
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SettingsAPI/SetSetting"):FireServer("theme_color", "red")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/ChooseTeam"):InvokeServer("Parents", {
                ["source_for_logging"] = "intro_sequence",
                ["dont_enter_location"] = true
            })
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Tutorial Started")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Editor Opened")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AvatarAPI/SubmitAvatarAnalyticsEvent"):FireServer("opened")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AvatarAPI/SetGender"):FireServer("male")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Avatar Editor Closed")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Housing Tutorial Started")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Housing Editor Opened")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/SendHousingOnePointOneLog"):FireServer("edit_state_entered", {
                ["house_type"] = "mine"
            })
            local args = { [1] = {} }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/PushFurnitureChanges"):FireServer(unpack(args))
            task.wait(0.1)
            local args = { [1] = "edit_state_exited", [2] = {} }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/SendHousingOnePointOneLog"):FireServer(unpack(args))
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("House Exited")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("DailyLoginAPI/ClaimDailyReward"):InvokeServer()
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Nursery Tutorial Started")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Nursery Entered")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/EquipTutorialEgg"):FireServer()
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Started Egg Received")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TutorialAPI/AddTutorialQuest"):FireServer()
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/StashTutorialStatus"):FireServer("Tutorial Ailment Spawned")
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/AddHungryAilmentToTutorialEgg"):FireServer()
            task.wait(0.1)
            local args = { [1] = workspace:WaitForChild("Pets"):WaitForChild("Starter Egg") }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AdoptAPI/FocusPet"):FireServer(unpack(args))
            task.wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LegacyTutorialAPI/MarkTutorialCompleted"):FireServer()
            task.wait(0.1)
        end)
        if not success then
            warn("Error in first task: " .. tostring(err))
        end
    end)
    
    task.spawn(function()
        local success, err = pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local API = ReplicatedStorage:WaitForChild("API")
            
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("npc_interaction")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ChoosePet"):FireServer("dog")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(2, { chosen_pet = "dog" })
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(3, { named_pet = false })
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(4)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(5)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/SpawnPetTreat"):FireServer()
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet_2")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(6)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(7)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/AddTutorialQuest"):FireServer()
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("opened_taskboard")
            task.wait(0.1)
            API:WaitForChild("QuestAPI/MarkQuestsViewed"):FireServer()
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet_3")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("started_playground_nav")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("reached_playground")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("opened_taskboard_2")
            task.wait(0.1)
            API:WaitForChild("QuestAPI/ClaimQuest"):InvokeServer("{6d6b008a-650e-4bea-b65c-20357e85f71c}")
            task.wait(0.1)
            API:WaitForChild("QuestAPI/MarkQuestsViewed"):FireServer()
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(10)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("focused_pet_4")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("started_home_nav")
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(11)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportStepCompleted"):FireServer(12)
            task.wait(0.1)
            API:WaitForChild("TutorialAPI/ReportDiscreteStep"):FireServer("cured_dirty_ailment")
            task.wait(0.1)
            API:WaitForChild("DailyLoginAPI/ClaimDailyReward"):InvokeServer()
            task.wait(0.1)
        end)
        if not success then
            warn("Error in second task: " .. tostring(err))
        end
    end)
    
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
    
    getgenv().userSetPetFarm = getgenv().PetFarm
    
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
    
    --print("After get furniture")
    -- ########################################################################################################################################################################
    
    
    local highestLegendaryLevel = 0
    local highestOtherLevel = 0
    local levelOfPet = 0
    getgenv().petToEquip = nil
    local checkedPets = {} -- Store checked pet kinds

    -- Get player pets
    getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    
    for _, v in pairs(fsys.get("inventory").pets) do
        local petLevel = v.properties.age -- Get pet level
    
        if v.kind ~= "practice_dog" then -- Ignore practice_dog
            if v.kind then
                -- Prioritize the highest-level legendary pet
                if petLevel > highestLegendaryLevel then
                    highestLegendaryLevel = petLevel
                    petToEquip = v.unique
                end
            else
                -- Store highest level non-legendary pet as backup
                if petLevel > highestOtherLevel then
                    highestOtherLevel = petLevel
                    if not petToEquip then -- Only set if no legendary was found
                        petToEquip = v.unique
                    end
                end
            end
        end
    end
    
    --print("Pet to equip:", petToEquip) -- Output the selected pet
    
    
    local petInv = fsys.get("equip_manager").pets[1] or nil
    
    if petToEquip == nil then
        local args = {
            [1] = "pets",
            [2] = "cracked_egg",
            [3] = {
                ["buy_count"] = 1
            }
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("ShopAPI/BuyItem"):InvokeServer(unpack(args))
    end
    
    -- Initialize globals that will be accessible from other scripts
    getgenv().petToEquip = nil
    getgenv().petToEquipSecond = nil
    getgenv().namePetToEquip = nil      -- Making these global too for better access
    getgenv().namePetToEquipSecond = nil
    
    -- Function to find and equip best pets
    getgenv().equipPet = function()
        local highestLegendaryLevel = -1
        local highestLegendaryLevelSecond = -1
        local highestOtherLevel = -1
        local highestOtherLevelSecond = -1
        
        -- Ensure we have access to the game data
        getgenv().fsys = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
        
        -- First pass: Find legendary pets
        for _, v in pairs(fsys.get("inventory").pets) do
            local petLevel = v.properties.age   -- Get pet level
            
            if v.kind ~= "practice_dog" then  -- Ignore practice_dog
                if v.kind then
                    if petLevel > highestLegendaryLevel then
                        -- Move current best to second best if better one found
                        if getgenv().petToEquip then
                            highestLegendaryLevelSecond = highestLegendaryLevel
                            getgenv().petToEquipSecond = getgenv().petToEquip
                            getgenv().namePetToEquipSecond = getgenv().namePetToEquip
                        end
                        
                        -- Set new best
                        highestLegendaryLevel = petLevel
                        getgenv().petToEquip = v.unique
                        getgenv().namePetToEquip = v.kind
                    elseif petLevel > highestLegendaryLevelSecond then
                        -- Update second best if better found
                        highestLegendaryLevelSecond = petLevel
                        getgenv().petToEquipSecond = v.unique
                        getgenv().namePetToEquipSecond = v.kind
                    end
                end
            end
        end
        
        -- If no legendary pets found, look for other pets
        if not getgenv().petToEquip then
            for _, v in pairs(fsys.get("inventory").pets) do
                local petLevel = v.properties.age
                
                if v.kind ~= "practice_dog" then
                    if petLevel > highestOtherLevel then
                        -- Move current best to second best if better one found
                        if getgenv().petToEquip then
                            highestOtherLevelSecond = highestOtherLevel
                            getgenv().petToEquipSecond = getgenv().petToEquip
                            getgenv().namePetToEquipSecond = getgenv().namePetToEquip
                        end
                        
                        -- Set new best
                        highestOtherLevel = petLevel
                        getgenv().petToEquip = v.unique
                        getgenv().namePetToEquip = v.kind
                    elseif petLevel > highestOtherLevelSecond then
                        -- Update second best if better found
                        highestOtherLevelSecond = petLevel
                        getgenv().petToEquipSecond = v.unique
                        getgenv().namePetToEquipSecond = v.kind
                    end
                end
            end
        end
        
        -- Check if we found pets to equip
        if getgenv().petToEquip then
            -- Equip first pet
            game:GetService("ReplicatedStorage"):WaitForChild("API")
                :WaitForChild("ToolAPI/Equip")
                :InvokeServer(getgenv().petToEquip, {["use_sound_delay"] = true, ["equip_as_last"] = false})
            
            --print("First pet equipped:", getgenv().namePetToEquip)
            --print("First Pet unique ID:", getgenv().petToEquip)
            
            -- Equip second pet if DoublePet is true and we have a second pet
            if getgenv().DoublePet and getgenv().petToEquipSecond then
                task.wait(1)
                
                game:GetService("ReplicatedStorage"):WaitForChild("API")
                    :WaitForChild("ToolAPI/Equip")
                    :InvokeServer(getgenv().petToEquipSecond, {["use_sound_delay"] = true, ["equip_as_last"] = true})
                
                --print("Second pet equipped:", getgenv().namePetToEquipSecond)
                --print("Second Pet unique ID:", getgenv().petToEquipSecond)
            end
            
            -- Confirm the process is completed
            --print("Pet equipment process completed successfully!")
            return true
        else
            --print("No suitable pets found to equip")
            return false
        end
    end
    
    -- Automatically run the function when this script loads
    local success, result = pcall(getgenv().equipPet)
    if not success then
        print("Error in equipPet function:", result)
    end
    
    -- Function to check the current equipped pets from another script
    getgenv().checkEquippedPets = function()
        --print("Currently equipped pets:")
        --print("First pet:", getgenv().namePetToEquip, "(ID:", getgenv().petToEquip, ")")
        if getgenv().DoublePet then
            --print("Second pet:", getgenv().namePetToEquipSecond, "(ID:", getgenv().petToEquipSecond, ")")
        end
    end
    
    --print("After equip unequip")
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
    
    --print("After teleports")
    
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
    
    -- Helper function to remove an item from a table by its value
    local function removeItemByValue(tbl, value)
        for i = 1, #tbl do
            if tbl[i] == value then
                table.remove(tbl, i)
                break
            end
        end
    end
    --print("After buy")
    
    -- ########################################################################################################################################################################
    
    -- Define the new path
    -- local ailments_list = Player.PlayerGui:WaitForChild("ailments_list")
    
    task.wait(1)
    local function get_mystery_task(petUnique)
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
                            local actions = {"hungry", "thirsty", "sleepy", "toilet", "bored", "dirty", "play", "school", "salon", "pizza_party", "sick", "camping", "beach_party", "walk", "ride", "pet_me"}
                            
                            for _, action in ipairs(actions) do
                                if not PetAilmentsData[ailmentId] or not PetAilmentsData[ailmentId][taskId] then
                                    --print("Mystery task not found anymore.")
                                    foundMystery = true
                                    break
                                end
    
                                wait(0.5)
                                local args = {
                                    [1] = petUnique,
                                    [2] = "mystery",
                                    [3] = i,
                                    [4] = action
                                }
    
                                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("AilmentsAPI/ChooseMysteryAilment"):FireServer(unpack(args))
                            end
                        end)
                    end
                end
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
    --print("After get ailments")
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
    
    -- Check if a specific ailment exists in a pet's ailments.
    -- If no pet is provided, the function checks both petToEquip and petToEquipSecond.
    local function hasTargetAilment(targetKind, pet)
        local ailments = ClientData.get_data()[game.Players.LocalPlayer.Name].ailments_manager.ailments
        
        -- If a specific pet is provided, check only that pet's ailments.
        if pet then
            local petAilments = ailments[pet]
            if petAilments then
                for _, ailment in pairs(petAilments) do
                    if ailment.kind == targetKind then
                        return true
                    end
                end
            end
        else
            -- Otherwise, check both pets
            local petAilments = ailments[petToEquip]
            if petAilments then
                for _, ailment in pairs(petAilments) do
                    if ailment.kind == targetKind then
                        return true
                    end
                end
            end
            
            petAilments = ailments[petToEquipSecond]
            if petAilments then
                for _, ailment in pairs(petAilments) do
                    if ailment.kind == targetKind then
                        return true
                    end
                end
            end
        end
        
        return false
    end
    
    
    task.wait(1)
    -- ########################################################################################################################################################################
    local taskName = "none"
    local function EatDrink(isEquippedPet)
        if isEquippedPet then
            
        end
        task.wait(1)
        if table.find(FirstTableArray, "hungry") or table.find(SecondTableArray, "hungry") then
            taskName = "🍔"
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
    
    
    
    
    -- ########################################################################################################################################################################
    for _, pet in ipairs(workspace.Pets:GetChildren()) do
        --print(pet.Name)
        petName = pet.Name
    end
    
    _G.FarmTypeRunning = "none"
    print("After taas startpetfarm")
    local function startPetFarm()
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/ChooseTeam"):InvokeServer("Babies",{["dont_send_back_home"] = true, ["source_for_logging"] = "avatar_editor"})
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()
        task.wait(5)
        buyItems()
        task.wait(2)
        local LiveOpsMapSwap = require(game:GetService("ReplicatedStorage").SharedModules.Game.LiveOpsMapSwap)
        game:GetService("ReplicatedStorage").API:FindFirstChild("LocationAPI/SetLocation"):FireServer("MainMap",
        game:GetService("Players").LocalPlayer, "Snow")
        teleportPlayerNeeds(0,350,0)
        createPlatform()
        task.wait(3)
        equipPet()
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
        
    
        -- ######################################### EVENT
        -- NO EVENT RIGHT NOW
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
    
        while getgenv().PetFarm do
            _G.FarmTypeRunning = "Pet/Baby"
            print("inside petfarm")
            repeat task.wait(5)
                task.wait(1)
                
                print("inside repeat oten")
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
        
    end
    --print("After startpetfarm")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    getgenv().fsysCore = require(game:GetService("ReplicatedStorage").ClientModules.Core.InteriorsM.InteriorsM)
    
    local RunService = game:GetService("RunService")
    local currentText
    
    
    
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
    titleLabel.Text = "HIRA X\ngg/xVPfRPmv"
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
    -- print("After tracker")
    task.wait(10)
    task.spawn(startPetFarm)
    task.wait(1)
    task.spawn(startUIUpdate)
    task.wait(1)
    task.spawn(function()
        RGBCycle(titleLabel)
    end)
else
    print("Script already Running")
end
