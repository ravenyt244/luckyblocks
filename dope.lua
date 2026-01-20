-- Add this at the top of dope.lua, before any logic
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Wait for the local player to fully load (optional, but helps in slow-loading games)
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- Optional: Wait a bit more for the game to settle
task.wait(1)  -- Adjust as needed; this gives 1 second for UI/remotes to load-- Add this at the top of dope.lua, before any logic
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Wait for the local player to fully load (optional, but helps in slow-loading games)
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- Optional: Wait a bit more for the game to settle
task.wait(1)  -- Adjust as needed; this gives 1 second for UI/remotes to load

if not SETTINGS then
    SETTINGS = {
        receiver = "DefaultReceiver",
        gearName = "DefaultGear",
        delay = 0,
        minGifts = 100
    }
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Safe sender
SETTINGS.sender = LocalPlayer.Name

-- Remote
local GiftRequestEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GiftRequestEvent")

-- Wait for Hotbar UI
local hotbar = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("BackpackGui"):WaitForChild("Backpack"):WaitForChild("Hotbar")

-- Function to count pets
local function getPetCountNumber()
    for _, slot in ipairs(hotbar:GetChildren()) do
        local toolName = slot:FindFirstChild("ToolName", true)
        local countLabel = slot:FindFirstChild("CountLabel", true)

        if toolName and countLabel and toolName:IsA("TextLabel") then
            if toolName.Text == SETTINGS.gearName then
                local n = countLabel.Text:match("x(%d+)")
                return tonumber(n) or 0
            end
        end
    end
    return 0
end

-- UI
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.Name = "PetGiftUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25, 0.12)
frame.Position = UDim2.fromScale(0.02, 0.78)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local petCountLabel = Instance.new("TextLabel", frame)
petCountLabel.Size = UDim2.fromScale(1, 0.5)
petCountLabel.BackgroundTransparency = 1
petCountLabel.TextScaled = true
petCountLabel.TextColor3 = Color3.new(1,1,1)
petCountLabel.Text = "Initializing..."

local giftedLabel = Instance.new("TextLabel", frame)
giftedLabel.Size = UDim2.fromScale(1, 0.5)
giftedLabel.Position = UDim2.fromScale(0, 0.5)
giftedLabel.BackgroundTransparency = 1
giftedLabel.TextScaled = true
giftedLabel.TextColor3 = Color3.fromRGB(0,255,150)
giftedLabel.Text = "Loading..."

-- Get gear from workspace
local function getGear()
    local folder = Workspace:FindFirstChild(SETTINGS.sender)
    if not folder then return nil end
    return folder:FindFirstChild(SETTINGS.gearName)
end

-- Teleport to receiver
local function teleportTo(receiver)
    local c1 = LocalPlayer.Character
    local c2 = receiver.Character
    if not c1 or not c2 then return end
    local hrp1 = c1:FindFirstChild("HumanoidRootPart")
    local hrp2 = c2:FindFirstChild("HumanoidRootPart")
    if hrp1 and hrp2 then
        hrp1.CFrame = hrp2.CFrame
        print("✅ Teleported to receiver")
    else
        warn("❌ Failed to teleport - missing HumanoidRootPart")
    end
end

-- Auto-gift
task.spawn(function()
    print("🎁 Starting pet gifting script for receiver: " .. SETTINGS.receiver)

    local receiver = Players:FindFirstChild(SETTINGS.receiver)
    if not receiver then
        warn("❌ Receiver '" .. SETTINGS.receiver .. "' not found in the game. Make sure they are online and spelled correctly.")
        petCountLabel.Text = "❌ Receiver not found"
        giftedLabel.Text = "Check SETTINGS.receiver"
        return
    end
    if not receiver.Character then
        warn("❌ Receiver has no character loaded. Waiting...")
        receiver.CharacterAdded:Wait()
    end

    teleportTo(receiver)
    task.wait(0.1)

    local gear = getGear()
    if not gear then
        warn("❌ Gear '" .. SETTINGS.gearName .. "' not found in Workspace." .. SETTINGS.sender)
        petCountLabel.Text = "❌ Gear not found"
        giftedLabel.Text = "Check SETTINGS.gearName"
        return
    end

    local startCount = getPetCountNumber()
    print("✅ Initial pet count: " .. startCount)

    while true do
        task.wait(SETTINGS.delay)

        local currentCount = getPetCountNumber()
        local gifted = startCount - currentCount

        petCountLabel.Text = "Pet Count : " .. currentCount
        giftedLabel.Text = "Pet Gifted : " .. gifted .. " / " .. SETTINGS.minGifts

        if gifted >= SETTINGS.minGifts then break end

        GiftRequestEvent:FireServer(receiver, gear)
        print("🎁 Fired gift request. Total gifted so far: " .. gifted)
    end

    giftedLabel.Text = "✅ Done : " .. SETTINGS.minGifts .. " / " .. SETTINGS.minGifts
    print("🎉 Gifted exactly " .. SETTINGS.minGifts .. " pets. Please rejoin.")
end)
