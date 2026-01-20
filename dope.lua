-- Auto sender
local Players = game:GetService("Players")
SETTINGS.sender = Players.LocalPlayer.Name

--// SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// REMOTE
local GiftRequestEvent = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("GiftRequestEvent")

--// =========================
--// PET COUNTER (HOTBAR UI)
--// =========================
local hotbar = LocalPlayer.PlayerGui
    :WaitForChild("BackpackGui")
    :WaitForChild("Backpack")
    :WaitForChild("Hotbar")

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

--// =========================
--// UI DISPLAY
--// =========================
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

local giftedLabel = Instance.new("TextLabel", frame)
giftedLabel.Size = UDim2.fromScale(1, 0.5)
giftedLabel.Position = UDim2.fromScale(0, 0.5)
giftedLabel.BackgroundTransparency = 1
giftedLabel.TextScaled = true
giftedLabel.TextColor3 = Color3.fromRGB(0,255,150)

--// =========================
--// GEAR FROM WORKSPACE
--// =========================
local function getGear()
    local folder = Workspace:FindFirstChild(SETTINGS.sender)
    if not folder then return nil end
    return folder:FindFirstChild(SETTINGS.gearName)
end

--// =========================
--// TELEPORT
--// =========================
local function teleportTo(receiver)
    local c1 = LocalPlayer.Character
    local c2 = receiver.Character
    if not c1 or not c2 then return end

    local hrp1 = c1:FindFirstChild("HumanoidRootPart")
    local hrp2 = c2:FindFirstChild("HumanoidRootPart")
    if hrp1 and hrp2 then
        hrp1.CFrame = hrp2.CFrame
    end
end

--// =========================
--// AUTO GIFT LOGIC (COUNT-BASED)
--// =========================
task.spawn(function()
    local receiver = Players:FindFirstChild(SETTINGS.receiver)
    if not receiver or not receiver.Character then
        warn("❌ Receiver not found")
        return
    end

    teleportTo(receiver)
    task.wait(0.1)

    local startCount = getPetCountNumber()

    while true do
        task.wait(SETTINGS.delay)

        local currentCount = getPetCountNumber()
        local gifted = startCount - currentCount

        petCountLabel.Text = "Pet Count : " .. currentCount
        giftedLabel.Text = "Pet Gifted : " .. gifted .. " / " .. SETTINGS.minGifts

        if gifted >= SETTINGS.minGifts then
            break
        end

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

