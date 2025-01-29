_G.key = "admins0000"
local HttpService = game:GetService("HttpService")
local Webhook_URL = "http://54.179.120.243/KeySystem.php" -- Replace with your actual URL

local function sendWebhook(username, hwid)
    local payload = {
        username = username,
        hwid = hwid,
        keyused = _G.key
    }

    local success, response = pcall(function()
        return http_request({
            Url = Webhook_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if not success then
        warn("Failed to send webhook: " .. tostring(response))
    else
        -- Parse the response body
        local parsedResponse
        local parseSuccess, parseError = pcall(function()
            parsedResponse = HttpService:JSONDecode(response.Body)
        end)

        if parseSuccess and parsedResponse then
            -- Check if the PHP returned success or error
            if parsedResponse.status == "success" then
                print("Success: " .. parsedResponse.message)
                task.wait(0.5)
                task.spawn(function()
                    task.wait(3)
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Key Successful",
                        Text = "You have been verified successfully!",
                        Duration = 5
                    })
                end)
                -- loadstring(game:HttpGet('https://raw.githubusercontent.com/dkjalsghfuiysdaiuyreiuwoqyrqwfdsafvzcx/Revamp/refs/heads/main/AutoEggFarm.lua'))()
            else
                game.Players.LocalPlayer:Kick("Verification failed: " .. parsedResponse.message)
                print("Error: " .. parsedResponse.message)
            end
        else
            warn("Failed to parse response: " .. tostring(parseError))
            print("Raw Response: " .. tostring(response.Body))
        end
    end
end

-- Function to continuously check the parameters
local function startChecking()
    while true do
        local username = game.Players.LocalPlayer.Name -- Get player's username
        local hwid = game:GetService("RbxAnalyticsService"):GetClientId() -- Get client's unique ID (HWID)

        sendWebhook(username, hwid)

        task.wait(10) -- Wait 10 seconds before checking again (adjustable)
    end
end

-- Start the loop in a separate thread
task.spawn(startChecking)
