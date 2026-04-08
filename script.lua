local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local RightClickHeld = false
local Smoothness = 0.08

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

-- Check if cursor on enemy
local function isAimingAtEnemy()
    local target = Mouse.Target
    
    if target then
        for i = 1, 10 do
            if target and target:FindFirstChildOfClass("Humanoid") then
                return true
            end
            if target then
                target = target.Parent
            end
        end
    end
    
    return false
end

-- Wall Check
local function canSeeTarget(targetPos)
    local origin = Camera.CFrame.Position
    local direction = (targetPos - origin).Unit * 1000
    local ray = Ray.new(origin, direction)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character}, true, false)
    
    if hit then
        local hitModel = hit.Parent
        for i = 1, 5 do
            if hitModel and hitModel:FindFirstChildOfClass("Humanoid") then
                return true
            end
            if hitModel then
                hitModel = hitModel.Parent
            end
        end
        return false
    end
    
    return true
end

-- Get target part
local function getTargetPart()
    local target = Mouse.Target
    
    if target then
        for i = 1, 10 do
            if target and target:FindFirstChildOfClass("Humanoid") then
                local head = target:FindFirstChild("Head")
                local torso = target:FindFirstChild("Torso") or target:FindFirstChild("HumanoidRootPart")
                
                if target == head then
                    return head
                elseif target.Name == "Torso" or target.Name == "HumanoidRootPart" then
                    return torso
                end
            end
            if target then
                target = target.Parent
            end
        end
    end
    
    return nil
end

-- Find closest enemy
local function getClosestEnemy()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team ~= LocalPlayer.Team then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = getTargetPart()
                if part and part:IsDescendantOf(character) then
                    local targetPos = part.Position
                    
                    if not canSeeTarget(targetPos) then
                        continue
                    end
                    
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPos).Magnitude
                    
                    local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen then
                        if distance < shortestDistance then
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

-- Soft Aim Assist (Only when holding scope)
RunService.RenderStepped:Connect(function()
    if RightClickHeld and isAimingAtEnemy() then
        local targetPos = getClosestEnemy()
        if targetPos then
            local TargetCF = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(TargetCF, Smoothness)
        end
    end
end)

print("=================================")
print("Soft Aim Assist Loaded!")
print("Hold RIGHT CLICK (scope) to activate")
print("- Smooth follow")
print("- Wall check")
print("- No teammates")
print("=================================")
