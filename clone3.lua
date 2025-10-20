------------------------------------------------------------------------------------------------------
-- Third do this 

-- Loader: Load from local file
local HttpService = game:GetService("HttpService")

-- === Decode helpers ===
local function decodeValue(v)
    if typeof(v) == "table" and v.__t == "CFrame" then
        return CFrame.new(unpack(v.c))
    elseif typeof(v) == "table" and v.__t == "Color3" then
        return Color3.new(v.r, v.g, v.b)
    elseif typeof(v) == "table" then
        local out = {}
        for k, vv in pairs(v) do
            out[k] = decodeValue(vv)
        end
        return out
    else
        return v
    end
end

local function fromJSON(json)
    local raw = HttpService:JSONDecode(json)
    return decodeValue(raw)
end

-- === Read & restore ===
local saved = readfile("furniture.json")
local ok, data = pcall(fromJSON, saved)
if not ok then
    error("Failed to decode JSON: " .. tostring(data))
end

_G = _G or {}
_G.HouseData = _G.HouseData or {}
_G.HouseData.FurnitureArgs = data.FurnitureArgs
_G.HouseData.TextureData   = data.TextureData

print("[Loader] Restored FurnitureArgs (count):", #(_G.HouseData.FurnitureArgs[1] or {}))
print("[Loader] TextureData:", _G.HouseData.TextureData and "OK" or "nil")

task.wait(5)

print("doing last phase")
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
