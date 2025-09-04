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
