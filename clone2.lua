------------------------------------------------------------------------------------------------------
-- Second Do this 
-- Exporter: Save to local file
-- Make sure your executor supports writefile/readfile!

local HttpService = game:GetService("HttpService")

-- === Encode helpers (preserve CFrame/Color3) ===
local function encodeValue(v)
    local t = typeof(v)
    if t == "CFrame" then
        return { __t = "CFrame", c = { v:GetComponents() } }
    elseif t == "Color3" then
        return { __t = "Color3", r = v.R, g = v.G, b = v.B }
    elseif t == "table" then
        local out = {}
        for k, vv in pairs(v) do
            out[k] = encodeValue(vv)
        end
        return out
    else
        return v
    end
end

local function toJSON(tbl)
    return HttpService:JSONEncode(encodeValue(tbl))
end

-- === Gather data ===
_G = _G or {}
local toSave = {
    FurnitureArgs = _G.HouseData and _G.HouseData.FurnitureArgs or nil,
    TextureData   = _G.HouseData and _G.HouseData.TextureData or nil,
    saved_at      = os.time(),
}

if not toSave.FurnitureArgs then
    warn("No _G.HouseData.FurnitureArgs found. Run your collector first!")
    return
end

-- === Write file ===
local json = toJSON(toSave)
writefile("furniture.json", json)

print("[Exporter] Saved FurnitureArgs + TextureData to furniture.json")
