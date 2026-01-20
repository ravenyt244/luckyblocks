-- dope.lua (GitHub - hidden gifting logic)

--==============================
-- Ensure SETTINGS exists
--==============================
if not SETTINGS then
    SETTINGS = {
        receiver = "DefaultReceiver",
        gearName = "DefaultGear",
        delay = 0,
        minGifts = 100
    }
end

--==============================
-- SERVICES
--==============================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Set sender safely
SETTINGS.sender = LocalPlayer and LocalPlayer.Name or "UnknownSender"

--==============================
-- REMOTE
--==============================
local GiftRequestEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GiftRequestEvent")

--==============================
-- WAIT FOR PLAYER AND UI
--==============================
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local backpackGui = playerGui:WaitForChild("BackpackGui")
local backpack = backpackGui:WaitForChild("Backpack")
local hotbar = backpack:WaitForChild("Hotbar")

--==============================
-- PET COUNTER FUNCTION
--==============================
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

--==============================
-- GUI SETUP
--==============================
local gui = Instance.new("ScreenGui")
gui.Name = "PetGiftUI"
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.25, 0.12)
frame.Position = UDim2.fromScale(0.02, 0.78)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Parent = gui

local petCountLabel = Instance.new("TextLabel")
petCountLabel.Size = UDim2.fromScale(1, 0.5)
petCountLabel.BackgroundTransparency = 1
petCountLabel.TextScaled = true
petCountLabel.TextColor3 = Color3.new(1,1,1)
petCountLabel.Text = "Pet Count : 0"
petCountLabel.Parent = frame

local giftedLabel = Instance.new("TextLabel")
giftedLabel.Size = UDim2.fromScale(1, 0.5)
giftedLabel.Position = UDim2.fromScale(0, 0.5)
giftedLabel.BackgroundTransparency = 1
giftedLabel.TextScaled = true
giftedLabel.TextColor3 = Color3.fromRGB(0,255,150)
giftedLabel.Text = "Pet Gifted : 0 / " .. SETTINGS.minGifts
giftedLabel.Parent = frame

--==============================
-- GEAR FUNCTION
--==============================
local function getGear()
    local folder = Workspace:FindFirstChild(SETTINGS.sender)
    if not folder then return nil end
    return folder:FindFirstChild(SETTINGS.gearName)
end

--==============================
-- TELEPORT FUNCTION
--==============================
local function teleportTo(receiver)
    local c1 = LocalPlayer.Character
    local c2 = receiver.Character
    if not c1 or not c2 then return end

    -- Wait for HumanoidRootParts to exist
    local hrp1, hrp2
    repeat
        hrp1 = c1:FindFirstChild("HumanoidRootPart")
        hrp2 = c2:FindFirstChild("HumanoidRootPart")
        task.wait(0.1)
    until hrp1 and hrp2

    hrp1.CFrame = hrp2.CFrame
end

--==============================
-- AUTO GIFT LOGIC
--==============================
task.spawn(function()
    -- Wait for receiver to exist
    local receiver
    repeat
        receiver = Players:FindFirstChild(SETTINGS.receiver)
        task.wait(0.5)
    until receiver and receiver.Character

    teleportTo(receiver)
    task.wait(0.2) -- give a tiny delay before starting

    local startCount = getPetCountNumber()

    while true do
        task.wait(SETTINGS.delay)

        local currentCount = getPetCountNumber()
        local gifted = startCount - currentCount

        petCountLabel.Text = "Pet Count : " .. currentCount
        giftedLabel.Text = "Pet Gifted : " .. gifted .. " / " .. SETTINGS.minGifts

        if gifted >= SETTINGS.minGifts then break end

        local gear = getGear()
        if not gear then
            warn("❌ No gear found")
            break
        end

        GiftRequestEvent:FireServer(receiver, gear)
    end

    giftedLabel.Text = "✅ Done : " .. SETTINGS.minGifts .. " / " .. SETTINGS.minGifts
    print("🎉 Gifted exactly " .. SETTINGS.minGifts .. " pets. Please rejoin.")
end)

print("✅ AUTO GIFT + PET COUNTER LOADED")
