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

local NewsApp = game:GetService("Players").LocalPlayer.PlayerGui.NewsApp.Enabled
local sound = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("SoundPlayer")
local UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")

sound.FX:play("BambooButton")
UI.set_app_visibility("NewsApp", false)

task.wait(10)

getgenv().fsysCore = require(game:GetService("ReplicatedStorage").ClientModules.Core.InteriorsM.InteriorsM)
local targetCFrame = CFrame.new(-275.9091491699219, 25.812084197998047, -1548.145751953125, -0.9798217415809631, 0.0000227206928684609, 0.19986890256404877, -0.000003862579433189239, 1, -0.00013261348067317158, -0.19986890256404877, -0.00013070966815575957, -0.9798217415809631)
local OrigThreadID = getthreadidentity()
task.wait(1)
setidentity(2)
task.wait(1)
fsysCore.enter_smooth("MainMap", "MainDoor", {
    ["spawn_cframe"] = targetCFrame * CFrame.Angles(0, 0, 0)
})
setidentity(OrigThreadID)

task.wait(10)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
local me = Players.LocalPlayer
local character = me.Character or me.CharacterAdded:Wait()

local data = ClientData.get_data()
local pets = data and data[me.Name] and data[me.Name].inventory and data[me.Name].inventory.pets

if not pets then
	warn("Pets not loaded")
	return
end

local uniques = {}
local count = 0

for uniqueId, pet in pairs(pets) do
	if pet and pet.kind then
		local kind = string.lower(pet.kind)

		-- get last word after underscore
		local lastWord = kind:match("([^_]+)$")
		local isStarter = kind:sub(1, 7) == "starter"

		if kind ~= "dog"
			and kind ~= "practice_dog"
			and kind ~= "2d_kitty"
			and lastWord ~= "egg"
			and not isStarter
		then
			uniques[uniqueId] = true
			count += 1
		else
			-- print(lastWord)
		end
	end
end

print("Prepared uniques count:", count)

if count == 0 then
	warn("No pets passed the filter.")
	return
end

-- ✅ Find the correct furniture id (f-?) by locating PetRecyclerWithoutTom
local function findPetRecyclerFurnitureId()
	local houseInteriors = workspace:FindFirstChild("HouseInteriors")
	if not houseInteriors then return nil end

	local furnitureRoot = houseInteriors:FindFirstChild("furniture")
	if not furnitureRoot then return nil end

	-- Scan each furniture container under furnitureRoot
	for _, container in ipairs(furnitureRoot:GetChildren()) do
		-- Look for PetRecyclerWithoutTom anywhere inside this container
		local recycler = container:FindFirstChild("PetRecyclerWithoutTom", true)
		if recycler then
			-- container.Name example: "nil/nil/MainMap!EggTeaser2026/false/f-40"
			-- We want the last f-##
			local fid = container.Name:match("(f%-%d+)$") or container.Name:match("(f%-%d+)")
			if fid then
				return fid, container, recycler
			end
		end
	end

	return nil
end

local furnitureId, containerFound, recyclerFound = findPetRecyclerFurnitureId()
if not furnitureId then
	warn("Could not find PetRecyclerWithoutTom or extract f-? from its container name.")
	return
end

print("Detected PetRecyclerWithoutTom at:", containerFound:GetFullName())
print("Using furniture id:", furnitureId)

local remote = ReplicatedStorage:WaitForChild("API")
	:WaitForChild("HousingAPI/ActivateInteriorFurniture")

local args = {
	furnitureId,          -- ✅ dynamic "f-?"
	"UseBlock",
	{ uniques = uniques },
	character
}

local ok, res = pcall(function()
	return remote:InvokeServer(unpack(args))
end)

print("Invoke ok?", ok, "response:", res)



task.wait(1)
game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("PetRecyclerAPI/TicketsCollected"):InvokeServer()
task.wait(1)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)

local playerName = game.Players.LocalPlayer.Name
local tickets = ClientData.get_data()[playerName].pet_recycler_tickets_2026
local quantity = math.floor(tickets / 3000)

local buyEvent = ReplicatedStorage:WaitForChild("API"):WaitForChild("ShopAPI/BuyItem")

while quantity > 0 do
	local buyAmount = math.min(99, quantity)

	buyEvent:InvokeServer(
		"pets",
		"egg_teaser_2026_dire_wolf",
		{ buy_count = buyAmount }
	)

	quantity -= buyAmount
	task.wait(0.2) -- small delay to avoid spam
end
