function hardLockNpcCFrame(hrp,targetPos)
    if not hrp or not targetPos then return end
    pcall(function()

        local currentCFrame=hrp.CFrame
        local rx,ry,rz=currentCFrame:ToEulerAnglesXYZ()
        hrp.CFrame=CFrame.new(targetPos.X,targetPos.Y,targetPos.Z)*CFrame.Angles(rx,ry,rz)
    end)

    pcall(function()
        local velocity=hrp.Velocity
        if velocity and velocity.X and velocity.Z then
            hrp.Velocity=Vector3.new(velocity.X,0,velocity.Z)
        end
    end)
    pcall(function()
        local assemblyVelocity=hrp.AssemblyLinearVelocity
        if assemblyVelocity and assemblyVelocity.X and assemblyVelocity.Z then
            hrp.AssemblyLinearVelocity=Vector3.new(assemblyVelocity.X,0,assemblyVelocity.Z)
        end
    end)
end

function getNormalFarmOffsets()
    local sanguine=false
    local backpack=LocalPlayer:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild("Sanguine Art") then sanguine=true end
    local char=LocalPlayer.Character
    if char and char:FindFirstChild("Sanguine Art") then sanguine=true end
    if S.customOffset then
        return tonumber(S.customOffsetX) or 0,
               tonumber(S.customOffsetY) or 23,
               tonumber(S.customOffsetZ) or 0
    end
    if sanguine then return 0,23,10 end
    return 0,23,0
end

function isAlive(model)
    if not model or not model.Parent then return false end
    local hum=model:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health<=0 then return false end
    return true
end

function farmAttack(hrp, checkFn, enemyName, useTween, maxDistance, attackFn, attackDelay, options)
    local attackRange=maxDistance or 500
    local folder=game.Workspace:FindFirstChild("Enemies")
    if not folder then return end
    local nearest, bestDist=nil, math.huge
    for _, model in pairs(folder:GetChildren()) do
        if model:IsA("Model") and isAlive(model) then
            if not enemyName or model.Name==enemyName then
                local root=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildOfClass("BasePart")
                if root then
                    local dx=root.Position.X-hrp.Position.X
                    local dy=root.Position.Y-hrp.Position.Y
                    local dz=root.Position.Z-hrp.Position.Z
                    local d=math.sqrt(dx*dx+dy*dy+dz*dz)
                    if d<bestDist and d<=attackRange then bestDist=d; nearest=model end
                end
            end
        end
    end
    if not nearest then return end
    task.spawn(function()
        local expandedHead=nearest:FindFirstChild("Head")
        local originalSize=nil
        local originalCanCollide=nil
        if expandedHead then
            pcall(function()
                originalSize=expandedHead.Size
                originalCanCollide=expandedHead.CanCollide
            end)
        end
        while checkFn() and isAlive(nearest) do
            if not S.remoteMode then
                local size=S.bigHitbox and 200 or 50
                expandedHead=nearest:FindFirstChild("Head") or expandedHead
                if expandedHead then
                    expandedHead.Size=Vector3.new(size,size,size)
                    expandedHead.CanCollide=false
                end
            end
            task.wait()
        end
        if expandedHead and expandedHead.Parent and originalSize then
            pcall(function()
                expandedHead.Size=originalSize
                if originalCanCollide~=nil then expandedHead.CanCollide=originalCanCollide end
            end)
        end
    end)
    local lastClick=0
    local hitDelay=attackDelay or 0.06
    local reachedNpc=false
    while checkFn() and isAlive(nearest) do
        local tr=nearest:FindFirstChild("HumanoidRootPart") or nearest:FindFirstChildOfClass("BasePart")
        if tr then
            local ox,oy,oz=getNormalFarmOffsets()
            local targetPos=Vector3.new(tr.Position.X+ox, tr.Position.Y+oy, tr.Position.Z+oz)
            if useTween and not reachedNpc then
                tweenTo(hrp,targetPos,(options and options.speed) or S.FARM_SPEED,function() return checkFn() and isAlive(nearest) end)
                reachedNpc=true
            else
                hardLockNpcCFrame(hrp,targetPos)
            end
        end
        if not checkFn() or not isAlive(nearest) then break end
        local now=os.clock()
        if now-lastClick>=hitDelay then
            lastClick=now
            if attackFn then

                if options and options.syncAttack then attackFn(nearest,tr)
                else task.spawn(attackFn,nearest,tr) end
            else
                mouse1click()
            end
        end
        task.wait()
    end
end

local REMOTE_SESSION_ID = "32501259"
local REMOTE_MAX_DIST   = 60
local _remoteNet        = nil
local _remoteRegAtk     = nil
local _remoteRegHit     = nil
local _lastRemoteFire   = 0

local function ensureRemotes()
    if _remoteRegAtk and _remoteRegHit then return true end
    local net = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
    if net then net = net:FindFirstChild("Net") end
    if not net then return false end
    _remoteNet    = net
    _remoteRegAtk = net:FindFirstChild("RE/RegisterAttack")
    _remoteRegHit = net:FindFirstChild("RE/RegisterHit")
    return _remoteRegAtk ~= nil and _remoteRegHit ~= nil
end

function remoteAttack()
    if not ensureRemotes() then return end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myPos  = hrp.Position
    local folder = game.Workspace:FindFirstChild("Enemies")
    if not folder then return end

    local hitTable   = {}
    local primaryPart = nil
    for _, enemy in ipairs(folder:GetChildren()) do
        if enemy and enemy.Parent then
            local hum  = enemy:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health and hum.Health > 0 then

                local part = enemy:FindFirstChild("LeftLowerLeg")
                          or enemy:FindFirstChild("Head")
                          or enemy:FindFirstChild("HumanoidRootPart")
                if not part then
                    for _, c in ipairs(enemy:GetChildren()) do
                        if c:IsA("BasePart") then part = c; break end
                    end
                end
                if part and part.Parent then
                    local ok, pos = pcall(function() return part.Position end)
                    if ok and pos then
                        local dx = pos.X - myPos.X
                        local dy = pos.Y - myPos.Y
                        local dz = pos.Z - myPos.Z
                        local d  = math.sqrt(dx*dx + dy*dy + dz*dz)
                        if d <= REMOTE_MAX_DIST then
                            table.insert(hitTable, {enemy, part})
                            if not primaryPart then primaryPart = part end
                        end
                    end
                end
            end
        end
    end

    if #hitTable == 0 then return end
    pcall(function() _remoteRegAtk:FireServer(0.5) end)
    task.wait()
    pcall(function() _remoteRegHit:FireServer(primaryPart, hitTable, nil, REMOTE_SESSION_ID) end)
    _lastRemoteFire = os.clock()
end

