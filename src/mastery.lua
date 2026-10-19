local MASTERY_WAYPOINTS={
    {pos=Vector3.new(109.6,47.5,-12520.8)},
    {pos=Vector3.new(15.1,47.5,-12567.3)},
    {pos=Vector3.new(61.2,47.5,-12670.0)},
    {pos=Vector3.new(-150.7,47.5,-12666.5)},
    {pos=Vector3.new(86.2,47.5,-12849.6)},
    {pos=Vector3.new(233.5,47.5,-12952.1)},
    {pos=Vector3.new(129.1,47.5,-13049.1)},
    {pos=Vector3.new(-31.2,47.5,-12939.9)},
    {pos=Vector3.new(33.5,47.5,-12790.5),waitTime=5},
    {pos=Vector3.new(59.7,47.5,-12874.7),waitTime=3.2},
    {pos=Vector3.new(-108.3,47.5,-12285.8),look=Vector3.new(-0.980,0,-0.197)},
    {pos=Vector3.new(5.9,47.5,-12249.4)},
    {pos=Vector3.new(114.2,47.5,-12225.0)},
    {pos=Vector3.new(-7.4,47.5,-12257.7),waitTime=5},
    {pos=Vector3.new(594.8,47.5,-12426.1),look=Vector3.new(0.591,0,-0.807)},
    {pos=Vector3.new(617.6,47.5,-12557.3)},
    {pos=Vector3.new(707.3,47.5,-12570.6)},
    {pos=Vector3.new(714.0,47.5,-12708.4)},
    {pos=Vector3.new(820.5,47.5,-12679.7)},
    {pos=Vector3.new(803.9,47.5,-12763.1)},
    {pos=Vector3.new(698.0,47.5,-12605.4),waitTime=4},
    {pos=Vector3.new(676.5,47.5,-12570.8),waitTime=10,forceWait=true},
}
local masteryWaypoint=1
local masteryLastRemoteFired=0
local masteryLookVector=Vector3.new(0.040,0,-0.999)

function masteryTweenTo(hrp,targetPos,lookVector,checkFn)
    if not hrp or not targetPos then return end
    if lookVector then masteryLookVector=lookVector end
    local okStart,startPos=pcall(function() return hrp.Position end)
    if not okStart or not startPos then return end
    local dx=targetPos.X-startPos.X
    local dy=targetPos.Y-startPos.Y
    local dz=targetPos.Z-startPos.Z
    local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
    local duration=distance/S.MASTERY_TWEEN_SPEED
    local startTime=os.clock()
    local facingCF=nil
    pcall(function() facingCF=CFrame.lookAt(Vector3.new(0,0,0),masteryLookVector) end)
    while true do
        if checkFn and not checkFn() then return end
        local alpha=distance<0.1 and 1 or math.min((os.clock()-startTime)/duration,1)
        local newX=startPos.X+dx*alpha
        local newY=startPos.Y+dy*alpha
        local newZ=startPos.Z+dz*alpha
        local okMove=pcall(function()
            local positionCF=CFrame.new(newX,newY,newZ)
            hrp.CFrame=facingCF and (positionCF*facingCF) or positionCF
        end)
        if not okMove or alpha>=1 then return end
        task.wait(0.01)
    end
end

function masteryGetTargets(hrp)
    local targets={}
    if not hrp then return targets end
    local okMyPos,myPos=pcall(function() return hrp.Position end)
    local enemies=game.Workspace:FindFirstChild("Enemies")
    if not okMyPos or not myPos or not enemies then return targets end
    local okChildren,children=pcall(function() return enemies:GetChildren() end)
    if not okChildren or not children then return targets end
    for _,enemy in pairs(children) do
        local hum=enemy and enemy:FindFirstChildOfClass("Humanoid") or nil
        if hum and hum.Health and hum.Health>0 then
            local part=enemy:FindFirstChild("LeftLowerLeg") or enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildOfClass("BasePart")
            local okPos,pos=pcall(function() return part and part.Position end)
            if okPos and pos then
                local dx=pos.X-myPos.X
                local dy=pos.Y-myPos.Y
                local dz=pos.Z-myPos.Z
                local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
                if distance>=1 and distance<=120 then table.insert(targets,{enemy,part}) end
            end
        end
    end
    return targets
end

function masteryAttackTargets(targets)
    if not targets or #targets==0 or not ensureRemotes() then return end
    local hitTable={}
    local primary=nil
    for _,entry in pairs(targets) do
        local enemy=entry[1]
        local part=entry[2]
        local okEnemy,enemyParent=pcall(function() return enemy and enemy.Parent end)
        local okPart,partParent=pcall(function() return part and part.Parent end)
        if okEnemy and enemyParent and okPart and partParent then
            table.insert(hitTable,{enemy,part})
            if not primary then primary=part end
        end
    end
    if #hitTable==0 or not primary then return end
    pcall(function() _remoteRegAtk:FireServer(0.5) end)
    task.wait()
    pcall(function() _remoteRegHit:FireServer(primary,hitTable,nil,REMOTE_SESSION_ID) end)
    masteryLastRemoteFired=os.clock()
end

task.spawn(function()
    while true do
        if S.autoMastery and not farmPriorityBlocked() then
            local char=LocalPlayer and LocalPlayer.Character or nil
            local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
            local waypoint=MASTERY_WAYPOINTS[masteryWaypoint]
            if hrp and waypoint then
                masteryTweenTo(hrp,waypoint.pos,waypoint.look,function()
                    return S.autoMastery and not farmPriorityBlocked()
                end)
                if S.autoMastery and waypoint.waitTime then
                    local deadline=os.clock()+waypoint.waitTime
                    masteryLastRemoteFired=os.clock()
                    while S.autoMastery and not farmPriorityBlocked() and os.clock()<deadline do
                        if not waypoint.forceWait and os.clock()-masteryLastRemoteFired>=1.5 then break end
                        task.wait(0.1)
                    end
                end
                if S.autoMastery and not farmPriorityBlocked() then
                    masteryWaypoint=(masteryWaypoint%#MASTERY_WAYPOINTS)+1
                end
            else
                task.wait(0.1)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoMastery and not farmPriorityBlocked() then
            local char=LocalPlayer and LocalPlayer.Character or nil
            local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
            masteryAttackTargets(masteryGetTargets(hrp))
            task.wait(0.05)
        else
            task.wait(0.1)
        end
    end
end)

