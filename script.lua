local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local ToggleEnabled = false
local RightClickHeld = false
local Smoothness = 0.15
local FOV = 15

-- T Key Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.T then
        ToggleEnabled = not ToggleEnabled
        print("Aimbot:", ToggleEnabled and "ON" or "OFF")
    end
end)

-- Right Click Detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = false
    end
end)

-- Wall Check
local function hasLineOfSight(targetPosition)
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin, (targetPosition - origin).Unit * 1000)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character}, false, true)
    
    if hit then
        local distToHit = (pos - origin).Magnitude
        local distToTarget = (targetPosition - origin).Magnitude
        return distToHit >= distToTarget
    end
    
    return true
end

-- Get whatever part player is aiming at
local function getAimedPart()
    local target = Mouse.Target
    
    if target then
        for i = 1, 10 do
            if target and target:FindFirstChildOfClass("Humanoid") then
                return target
            end
            if target then
                target = target.Parent
            end
        end
    end
    
    return nil
end

-- Find closest player with aimed part
local function getClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local aimedPart = getAimedPart()
                if aimedPart and aimedPart:IsDescendantOf(character) then
                    local targetPos = aimedPart.Position
                    
                    -- Wall check
                    if not hasLineOfSight(targetPos) then
                        continue
                    end
                    
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPos).Magnitude

                    local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen then
                        local toTarget = (targetPos - Camera.CFrame.Position).unit
                        local cameraForward = Camera.CFrame.LookVector
                        local angle = math.acos(cameraForward:Dot(toTarget)) * (180 / math.pi)

                        if angle <= FOV and distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = targetPos
                        end
                    end
                end
            end
        end
    end
    
    return closestTarget
end

-- Soft Aimbot
local function aimAtTarget()
    local targetPos = getClosestTarget()
    if targetPos then
        local TargetCF = CFrame.new(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(TargetCF, Smoothness)
    end
end

-- Run Aimbot
RunService.RenderStepped:Connect(function()
    if ToggleEnabled and RightClickHeld then
        aimAtTarget()
    end
end)

print("Soft Aimbot Loaded!")
print("Press T to toggle")
print("Hold RIGHT CLICK to aim")
print("- Wall check added")
