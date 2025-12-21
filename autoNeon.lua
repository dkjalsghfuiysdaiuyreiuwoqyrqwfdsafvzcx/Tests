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

-- Optimized Neon + Mega auto-fuser
-- Neon: 4 x same-kind, age==6, neon ~= true
-- Mega: 4 x same-kind, age==6, neon == true
-- Remote lives at API["PetAPI/DoNeonFusion"] (name includes a slash)

local RS = game:GetService("ReplicatedStorage")
local API = RS:WaitForChild("API", 10)
assert(API, "[Fusion] API folder not found")

local DoNeonFusion = API:WaitForChild("PetAPI/DoNeonFusion", 10)
assert(DoNeonFusion, "[Fusion] PetAPI/DoNeonFusion remote not found")

local ClientData = require(RS.ClientModules.Core.ClientData)
local playerName = game.Players.LocalPlayer.Name

local function inv()
    return ClientData.get_data()[playerName].inventory.pets
end

-- Build a set of UIDs that are currently in-use/equipped
local function getActiveUids()
    local set = {}
    local act = ClientData.get_data()[playerName].idle_progression_manager
    local ap = act and act.active_pets
    if ap then
        for _, slot in pairs(ap) do
            local ii = slot and slot.item_info
            if ii then
                local u = ii.unique or ii.id or ii.uid
                if u then set[u] = true end
                for _, v in pairs(ii) do
                    if type(v) == "table" then
                        local uu = v.unique or v.id or v.uid
                        if uu then set[uu] = true end
                    end
                end
            end
        end
    end
    return set
end

-- Robust extractor; tolerates flat or item_info schemas
local function extract(p, key)
    local uid = p.unique or p.id or p.uid or key
    local kind = p.kind or (p.item_info and (p.item_info.kind or p.item_info.Kind))
    local props = p.properties or (p.item_info and p.item_info.properties) or {}
    local age = tonumber(props.age or props.Age)
    local neon = (props.neon == true) or (props.neon == "true")
    local locked = props.locked or props.Locked or props.favorite or props.Favorite
    return uid, kind, age, neon, locked
end

-- Fast bucket builder (no intermediate tables beyond two maps)
local function buildBuckets(activeSet)
    local neonBuckets, megaBuckets = {}, {}
    for k, p in pairs(inv() or {}) do
        local uid, kind, age, neon, locked = extract(p, k)
        if uid and kind and age == 6 and not activeSet[uid] and not locked then
            local bucket = neon and megaBuckets or neonBuckets
            local arr = bucket[kind]
            if arr then
                arr[#arr + 1] = uid
            else
                bucket[kind] = { uid }
            end
        end
    end
    return neonBuckets, megaBuckets
end

-- Single call shape first (array), with lightweight fallback to 4 args
local function fuse4(a, b, c, d)
    local ok = pcall(function() DoNeonFusion:InvokeServer({a, b, c, d}) end)
    if ok then return true end
    ok = pcall(function() DoNeonFusion:InvokeServer(a, b, c, d) end)
    return ok
end

-- Fuse all full groups of 4 from each kind bucket (index stepping; no removes)
local function fuseBuckets(buckets, label)
    local groups = 0
    for kind, arr in pairs(buckets) do
        local n = #arr - (#arr % 4) -- max multiple of 4
        for i = 1, n, 4 do
            local a, b, c, d = arr[i], arr[i+1], arr[i+2], arr[i+3]
            -- Minimal logging to reduce overhead; expand if debugging
            -- print(("[%s] %s -> %s,%s,%s,%s"):format(label, kind, a, b, c, d))
            local ok = fuse4(a, b, c, d)
            if ok then
                groups = groups + 1
            else
                warn(("[Fusion] %s failed for kind=%s on ids=%s,%s,%s,%s")
                    :format(label, tostring(kind), tostring(a), tostring(b), tostring(c), tostring(d)))
                break -- avoid hammering if server rejects this kind right now
            end
            task.wait(1.0) -- gentle throttle
        end
    end
    return groups
end

-- Main loop
while true do
    local active = getActiveUids()
    local neonBuckets, megaBuckets = buildBuckets(active)

    -- Quick counts without extra loops
    local function count(arrs) local c=0 for _,v in pairs(arrs) do c=c+#v end return c end
    -- print(("[Neon ready] %d | [Mega ready] %d"):format(count(neonBuckets), count(megaBuckets)))

    local neonFused = fuseBuckets(neonBuckets, "Neon")
    local megaFused = fuseBuckets(megaBuckets, "Mega")
    print(("[Fusion] Neon groups: %d | Mega groups: %d"):format(neonFused, megaFused))

    task.wait(450) -- run every 7.5 minutes
end
