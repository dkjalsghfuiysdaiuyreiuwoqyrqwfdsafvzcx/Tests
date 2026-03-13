if not getgenv().ScriptConsole then
    getgenv().ScriptConsole = true

    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DevConsoleToggleGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Toggle button
    local button = Instance.new("TextButton")
    button.Name = "ToggleConsoleButton"
    button.Size = UDim2.new(0, 180, 0, 50)
    button.Position = UDim2.new(0, 20, 1, -70)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = "Show Console"
    button.TextSize = 18
    button.Font = Enum.Font.GothamBold
    button.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(90, 140, 255)
    stroke.Parent = button

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 120, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 80, 255))
    })
    gradient.Rotation = 20
    gradient.Parent = button

    local consoleVisible = false

    local function setConsoleVisible(visible)
        consoleVisible = visible

        -- retry because SetCore can fail if called too early
        for i = 1, 10 do
            local ok = pcall(function()
                StarterGui:SetCore("DevConsoleVisible", visible)
            end)

            if ok then
                break
            end

            task.wait(0.2)
        end

        button.Text = visible and "Hide Console" or "Show Console"
    end

    button.MouseButton1Click:Connect(function()
        setConsoleVisible(not consoleVisible)
    end)

end
