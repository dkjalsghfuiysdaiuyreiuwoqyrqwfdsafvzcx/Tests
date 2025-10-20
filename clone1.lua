------------------------------------------------------------------------------------------------------
-- First Copy it
-- copy the house
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

-- List of IDs to skip
local skipIDs = {
    racehouse_2023_square_tree = true,
    racehouse_2023_wizard_tree = true,
    racehouse_2023_simple_tree = true
}

for _, item in pairs(FurnitureData) do
    -- Skip any furniture with "_tutorial" in its ID or matching the 3 specific IDs
    if not string.find(item.id, "_tutorial") and not skipIDs[item.id] then
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
            if typeof(colorValue) ~= "Color3" and typeof(colorValue) == "table" then
                furnitureArgs[1][i].properties.colors[colorIndex] = Color3.new(unpack(colorValue))
            else
                furnitureArgs[1][i].properties.colors[colorIndex] = colorValue
            end
        end

        i = i + 1
    end
end

print("done copying")
_G.HouseData.FurnitureArgs = furnitureArgs
