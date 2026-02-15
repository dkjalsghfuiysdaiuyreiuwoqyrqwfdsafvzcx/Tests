if not getgenv().AutoHarvest then 
    getgenv().AutoHarvest = true
    local ClientData = require(game:GetService("ReplicatedStorage").ClientModules.Core.ClientData)
    local playerName = game.Players.LocalPlayer.Name
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
    local saved = readfile(getgenv().FileName)
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




    task.wait(10)

    -- respawn

    game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()

    local bucks = ClientData.get_data()[game.Players.LocalPlayer.Name].money
    local loopCount = math.floor(bucks / 37500)

    for i = 1, loopCount do    
        -- your loop logic here
        task.wait(60)
        
        -- buy home

        local args = {
            "micro_2023",
            {},
            Color3.new(0.7012181878089905, 0.3500000238418579, 1)
        }
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("HousingAPI/BuyHouseWithAddons"):InvokeServer(unpack(args))

        task.wait(60)
        
        -- respawn again
        
        game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("TeamAPI/Spawn"):InvokeServer()

        task.wait(60)
        
        for batch = 1, 10 do
            task.wait(1)
            local startVal = batch
            local endVal = batch * 10

            -- Build the furniture list for this batch
            local furnitureList = {}
            for i = startVal, endVal do
                table.insert(furnitureList, "f-" .. i)
            end

            -- Send once for the whole batch
            local args = {
                false,
                furnitureList,
                "sell"
            }

            game:GetService("ReplicatedStorage")
                :WaitForChild("API")
                :WaitForChild("HousingAPI/SellFurniture")
                :FireServer(unpack(args))
        end
        
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
end
