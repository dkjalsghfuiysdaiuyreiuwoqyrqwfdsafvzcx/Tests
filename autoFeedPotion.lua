getgenv().PetToFeed = "house_pets_2025_mini_schnauzer"
-- getgenv().PetToFeed = "house_pets_2025_munchkin_cat"
getgenv().FeedPetMode = "Neon"
getgenv().FeedPotions = true
getgenv().PetRarity = 6
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
local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
local playerName = game.Players.LocalPlayer.Name
local foodData = ClientData.get_data()[playerName].inventory.food
local petsData = ClientData.get_data()[playerName].inventory.pets

-- Store the remote function reference once at the top
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CreatePetObject = ReplicatedStorage:WaitForChild("API"):WaitForChild("PetObjectAPI/CreatePetObject")
local EquipPet = ReplicatedStorage:WaitForChild("API"):WaitForChild("ToolAPI/Equip")

local kelpPets = {}
local potions = {}

-- Collect kelp hunter pets
print("start")
if FeedPetMode == "Normal" and FeedPotions then
    for _, pet in pairs(petsData) do
        if pet.kind == PetToFeed and pet.properties.age < 6 then
            table.insert(kelpPets, pet.unique)
            print("Found Normal ", PetToFeed, " Pet:", pet.unique)
        end
        task.wait(0.05)
    end
end

-- Collect kelp hunters pet (Neons)

if FeedPetMode == "Neon" and FeedPotions then
    for _, pet in pairs(petsData) do
        if pet.kind == PetToFeed and pet.properties.age < 6 and pet.properties.neon then
            table.insert(kelpPets, pet.unique)
            print("Found Neon ", PetToFeed, " Pet:", pet.unique)
        end
        task.wait(0.05)
    end
end

-- Collect potions
if FeedPotions then
    for _, potion in pairs(foodData) do
        if potion.kind == "pet_age_potion" then
            table.insert(potions, potion.unique)
            print("Found Potion:", potion.unique)
        end
        task.wait(0.05)
    end
end

-- Function to feed pet
local function feedPet(petUnique, potionList)
    -- Equip Pet
    local equipArgs = {
        [1] = petUnique,
        [2] = { use_sound_delay = true, equip_as_last = false }
    }

    local equipped = pcall(function()
        return EquipPet:InvokeServer(unpack(equipArgs))
    end)

    if equipped then
        print("✅ Equipped Pet # ", petUnique)
    else
        warn("❌ Failed to equip Pet # ", petUnique)
    end

    task.wait(3)
    local args = {
        "__Enum_PetObjectCreatorType_2",
        {
            pet_unique = petUnique,
            unique_id = potionList[1], -- Main potion
            additional_consume_uniques = { unpack(potionList, 2, PetRarity) } -- 5 additional potions
        }
    }
    
    local success, result = pcall(function()
        return CreatePetObject:InvokeServer(unpack(args))
    end)
    
    if success then
        print("✅ Fed pet:", petUnique)
    else
        warn("❌ Failed to feed pet:", petUnique, result)
    end
end

-- Feed each pet 6 potions
if FeedPotions then
    for _, petUnique in ipairs(kelpPets) do
        if #potions >= PetRarity then
            local potionBatch = {}
            for i = 1, PetRarity do
                table.insert(potionBatch, table.remove(potions, 1)) -- Take and remove from list
            end
            feedPet(petUnique, potionBatch)
            task.wait(10)
        else
            warn("Not enough potions left to feed pet:", petUnique)
        end
    end
end

-- Store the remote function reference
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DoNeonFusion = ReplicatedStorage:WaitForChild("API"):WaitForChild("PetAPI/DoNeonFusion")

-- Collect kelp hunter pets that are age 6
local petsData = ClientData.get_data()[playerName].inventory.pets
local kelpHunterAge6 = {}
if FeedPetMode == "Normal" then 
    for _, pet in pairs(petsData) do
        if pet.kind == PetToFeed and pet.properties.age == 6 then
            table.insert(kelpHunterAge6, pet.unique)
            print("Found age 6 Kelp Hunter:", pet.unique)
        end
    end
end

local petsData = ClientData.get_data()[playerName].inventory.pets
if FeedPetMode == "Neon" then
    for _, pet in pairs(petsData) do
        if pet.kind == PetToFeed and pet.properties.age == 6 and pet.properties.neon then
            table.insert(kelpHunterAge6, pet.unique)
            print("Found age 6 Kelp Hunter:", pet.unique)
        end
    end
end

print("Total age 6 Kelp Hunters found:", #kelpHunterAge6)

-- Fuse pets in batches of 4
while #kelpHunterAge6 >= 4 do
    local fusionBatch = {}
    
    -- Take 4 pets for fusion
    for i = 1, 4 do
        table.insert(fusionBatch, table.remove(kelpHunterAge6, 1))
    end
    
    print("Fusing pets:", table.concat(fusionBatch, ", "))
    
    local args = {
        fusionBatch -- This should be the array of 4 pet unique IDs
    }
    
    local success, result = pcall(function()
        return DoNeonFusion:InvokeServer(unpack(args))
    end)
    
    if success then
        print("✅ Successfully fused 4 Kelp Hunters into a Neon!")
    else
        warn("❌ Failed to fuse pets:", result)
    end
    
    task.wait(2) -- Wait between fusions
end

if #kelpHunterAge6 > 0 then
    print("Remaining Kelp Hunters (not enough for fusion):", #kelpHunterAge6)
end
