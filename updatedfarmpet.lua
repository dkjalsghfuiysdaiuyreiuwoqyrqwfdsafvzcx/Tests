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

    local function FireSig(button)
        pcall(function()
            for _, connection in pairs(getconnections(button.MouseButton1Down)) do
                connection:Fire()
            end
            task.wait(0.1)
            for _, connection in pairs(getconnections(button.MouseButton1Up)) do
                connection:Fire()
            end
            task.wait(0.1)
            for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                connection:Fire()
                -- print(button.Name.." clicked!")
            end
        end)
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

teleportPlayerNeeds(-589.408, 35.7978, -1669.11828)

for i = 1, 12 do
	local args = {
		{
			cannon_key = tostring(i)
		}
	}
	game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SummerfestEventAPI/CrowsNestHit"):FireServer(unpack(args))
    task.wait(.1)
end

-- Spawn loop in a background thread
task.spawn(function()
    while true do
        -- Buy keys
        for i = 1, 12 do
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SummerfestEventAPI/RequestBuyTreasureKey"):InvokeServer()
            task.wait(0.1)
        end

        -- Open chests 1 to 6
        for i = 1, 12 do
            local args = {
                i
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("SummerfestEventAPI/RequestOpenTideChest"):InvokeServer(unpack(args))
            task.wait(0.1)
        end

        task.wait(0.1)
    end
end)

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

task.wait(2)

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local Interiors = workspace:WaitForChild("Interiors")
local targetPosition = Vector3.new(-5970.07373046875, 9905.8984375, 8980.234375)

-- Function to simulate clicking the center of the screen
local function clickCenter()
    local screenCenter = workspace.CurrentCamera.ViewportSize / 2
    VirtualInputManager:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, false, game, 0)
end


local radius = 3

local function checkDistance()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local distance = (hrp.Position - targetPosition).Magnitude
        
        if distance <= radius then
            print("You are within 10 studs of the target location!")
            -- you can add more logic here, like triggering an event
        else
            print("You are outside the detection radius.")
			teleportPlayerNeeds(-5970.07373046875, 9905.8984375, 8980.234375)
        end
    end
end

-- Main loop
while true do
    local targetInterior = nil

    -- Find the dynamic CoconutBonkInterior
    for _, interior in ipairs(Interiors:GetChildren()) do
        if interior.Name:match("^CoconutBonkInterior::") then
            targetInterior = interior
            break
        end
    end

    if targetInterior then
		task.wait(10)
        print("Entered:", targetInterior.Name)
        local minigameId

        for _, child in pairs(workspace.StaticMap:GetChildren()) do
            if child:IsA("Folder") and string.match(child.Name, "^coconut_bonk::.+_minigame_state$") then
                -- Remove the `_minigame_state` part to get the ID
                minigameId = string.gsub(child.Name, "_minigame_state$", "")
                break
            end
        end

        if minigameId then
            local args = {
                minigameId,
                "release_parrot"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("MinigameAPI/MessageServer"):FireServer(unpack(args))
        end
        task.wait(.1)
        -- Teleport to target position
        teleportPlayerNeeds(-5970.07373046875, 9905.8984375, 8980.234375)
		checkDistance()
        -- Keep clicking while still inside
        while targetInterior.Parent == Interiors do
			

			while true do
				local success, err = pcall(function()
					local buttonFire = game:GetService("Players").LocalPlayer.PlayerGui.MinigameHotbarApp.Hotbar.SwordButton.Button
					FireSig(buttonFire)
				end)
				if success then
					break
				else
					warn("FireSig failed, retrying... Error:", err)
					task.wait(0.2)  -- wait a bit before retrying to avoid spamming too hard
				end
			end
            task.wait(0.3)
        end

        print("Exited:", targetInterior.Name)
    end

    task.wait(1)
end
