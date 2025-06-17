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


-- tp to ghittoyah
local args = {
	game:GetService("Players"):WaitForChild("GHITTOYAH")
}
game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("LocationAPI/TeleToPlayer"):InvokeServer(unpack(args))

task.wait(10)

-- copy the house

-- Clear any existing global data
_G = _G or {}
_G.HouseData = {}  -- This clears past data

local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
local playerName = game.Players.LocalPlayer.Name

----------------------------------
-- Collect & Store Texture Data --
----------------------------------

local TextureData = ClientData.get_data()[playerName].house_interior.textures
_G.HouseData.TextureData = TextureData

------------------------------------
-- Collect & Store Furniture Data --
------------------------------------

local FurnitureData = ClientData.get_data()[playerName].house_interior.furniture

-- Helper function to rebuild a CFrame
local function rebuildCFrame(cf)
    local comps = {cf:GetComponents()}
    return CFrame.new(unpack(comps))
end

-- Build the furniture args table
local furnitureArgs = { [1] = {} }
local i = 1
for _, item in pairs(FurnitureData) do
    local cframeValue = rebuildCFrame(item.cframe)
    furnitureArgs[1][i] = {
        ["kind"] = item.id,
        ["properties"] = {
            ["scale"] = item.scale,
            ["cframe"] = cframeValue,
            ["colors"] = {}
        }
    }

    for colorIndex, colorValue in pairs(item.colors) do
        furnitureArgs[1][i].properties.colors[colorIndex] = colorValue
    end
    i = i + 1
end

_G.HouseData.FurnitureArgs = furnitureArgs

task.wait(10)

-- respawn

game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()

local bucks = ClientData.get_data()[game.Players.LocalPlayer.Name].money
local loopCount = math.floor(bucks / 39000)

while true do
    -- your loop logic here
    task.wait(10)
    
    -- buy home

    local args = {
        "micro_2023",
        {},
        Color3.new(0.7012181878089905, 0.3500000238418579, 1)
    }
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/BuyHouseWithAddons"):InvokeServer(unpack(args))

    task.wait(10)
    
    -- respawn again
    
    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()

    task.wait(10)
    
    --PASTE THE TEXTURE AND FURNITURE

    -- APIInvoker LocalScript

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local BuyTexture = ReplicatedStorage:WaitForChild("API"):WaitForChild("HousingAPI/BuyTexture")
    local BuyFurnitures = ReplicatedStorage:WaitForChild("API"):WaitForChild("HousingAPI/BuyFurnitures")

    -- Wait a tiny bit to ensure DataCollector has run
    -- (Or you can use a more robust check loop.)
    wait(1)

    -- Check if our global data is present
    if _G.HouseData and _G.HouseData.TextureData then
        local textureData = _G.HouseData.TextureData
        for roomName, textureInfo in pairs(textureData) do
            -- If a wall texture exists, fire the remote for walls
            if textureInfo.walls then
                BuyTexture:FireServer(roomName, "walls", textureInfo.walls)
            end

            -- If a floor texture exists, fire the remote for floors
            if textureInfo.floors then
                BuyTexture:FireServer(roomName, "floors", textureInfo.floors)
            end
        end
    end

    -- Now do the furniture call
    if _G.HouseData and _G.HouseData.FurnitureArgs then
        local furnitureArgs = _G.HouseData.FurnitureArgs
        BuyFurnitures:InvokeServer(unpack(furnitureArgs))
    end
end
