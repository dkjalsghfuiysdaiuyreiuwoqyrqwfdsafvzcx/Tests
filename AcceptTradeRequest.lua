
-- TIG ACCEPT
-- Rename hashed remotes
local router
for i, v in next, getgc(true) do
    if type(v) == 'table' and rawget(v, 'get_remote_from_cache') then
        router = v
        break
    end
end

local function rename(remotename, hashedremote)
    hashedremote.Name = remotename
end
for name, remote in pairs(debug.getupvalue(router.get_remote_from_cache, 1)) do
    rename(name, remote)
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local TextChatService = game:GetService("TextChatService")
local chatChannel = TextChatService.TextChannels.RBXGeneral
local UI = require(game.ReplicatedStorage:WaitForChild("Fsys")).load("UIManager")

while true do
    local textLabel = LocalPlayer:FindFirstChild("PlayerGui")
        and LocalPlayer.PlayerGui:FindFirstChild("DialogApp")
        and LocalPlayer.PlayerGui.DialogApp.Dialog.NormalDialog.Info.TextLabel

    if textLabel then
        local text = textLabel.Text
        UI.set_app_visibility("DialogApp", false)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                print("Attempting trade with:", player.Name)

                local success, err = pcall(function()
                    local args = {
                        [1] = player,
                        [2] = true
                    }

                    ReplicatedStorage:WaitForChild("API"):WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest"):InvokeServer(unpack(args))
                    task.wait(3)

                    ReplicatedStorage:WaitForChild("API"):WaitForChild("TradeAPI/AcceptNegotiation"):FireServer()
                    task.wait(1)

                    ReplicatedStorage:WaitForChild("API"):WaitForChild("TradeAPI/ConfirmTrade"):FireServer()
                    task.wait(1)
                end)

                if not success then
                    warn("Trade with " .. player.Name .. " failed: " .. tostring(err))
                end

                UI.set_app_visibility("DialogApp", true)
                task.wait(1) -- Short pause before next player
            end
        end
    end

    task.wait(1) -- Repeat after a short delay
end
