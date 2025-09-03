
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua", true))()
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
task.spawn(function()
    while true do
        
        for i = 1, 20 do
            local args = {
                "house_pets_2025_pass_1",
                1
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                2
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                3
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                4
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                5
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                6
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                7
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                8
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                9
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                10
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                11
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                12
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                13
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                14
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                15
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                16
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                17
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                18
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                19
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
            local args = {
                "house_pets_2025_pass_1",
                20
            }
            game:GetService("ReplicatedStorage"):WaitForChild("API"):WaitForChild("BattlePassAPI/ClaimReward"):InvokeServer(unpack(args))
        end
    end
end)
