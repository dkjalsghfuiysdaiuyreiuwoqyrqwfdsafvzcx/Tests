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

local virtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

Player.Idled:Connect(function()
	virtualUser:CaptureController()
	virtualUser:ClickButton2(Vector2.new())
end)

task.wait(1)

-- tp to mainmap
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

task.wait(5)

-- get mailbox pumpkin
game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/ClaimAllDeliveries"):FireServer()
task.wait(.1)

-- tp to circle
local function teleportPlayerNeeds(x, y, z)

	if x == 0 and y == 350 and z == 0 then
		x = math.random(10, 20)
	end
	local Player = game.Players.LocalPlayer
	if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
		Player.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z) 
	else
		print("Player or character not found!")
	end
end

teleportPlayerNeeds(-408.741241, 33.896244, -1739.310913)


-- define it here so it's accessible everywhere
local hauntletId 

while true do
	-- Always claim treat bag
	game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HalloweenEventAPI/ClaimTreatBag"):InvokeServer()

    local args = {
        true
    }
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HalloweenEventAPI/ProgressTaming"):InvokeServer(unpack(args))


	-- Try to find the current hauntlet
	hauntletId = nil
	for _, obj in pairs(workspace.StaticMap:GetChildren()) do
		local key = obj.Name
		local match = string.match(key, "^(hauntlet::[%w%-]+)_minigame_state$")
		if match then
			print("Found:", match)
			hauntletId = match
			break
		end
	end

	if hauntletId then
		-- Instead of forcing 20 rooms, keep trying until no progress is made
		local currentRoom = 1
		while currentRoom <= 20 do
			-- Check if player is still inside minigame (hauntlet still exists)
			if not workspace.StaticMap:FindFirstChild(hauntletId .. "_minigame_state") then
				print("Minigame ended early at room", currentRoom)
				break
			end

			-- Pick a door

            for door = 1, 3 do
                local args = {
                    hauntletId,
                    "player_selected_door",
                    currentRoom,
                    door
                }
                game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("MinigameAPI/MessageServer"):FireServer(unpack(args))
                task.wait(1)
            end

			task.wait(7)

			-- Use items
			local args1 = { hauntletId, "player_used_item", "MonsterRepellant" }
			game:GetService("ReplicatedStorage").API["MinigameAPI/MessageServer"]:FireServer(unpack(args1))

			task.wait(.01)

			local args2 = { hauntletId, "player_used_item", "HeartPotion" }
			game:GetService("ReplicatedStorage").API["MinigameAPI/MessageServer"]:FireServer(unpack(args2))

			-- Go to next room
			currentRoom += 1
		end
	else
		warn("No hauntletId found! Retrying...")
	end

	-- Wait before next cycle
	task.wait(10)
end
