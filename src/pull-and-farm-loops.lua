local function doPullLoop(flag, getPoint)
    task.spawn(function()
        while true do
            if flag() then
                local char=LocalPlayer.Character
                local myHrp=char and char:FindFirstChild("HumanoidRootPart")
                if myHrp then
                    local pullPoint=getPoint(myHrp)
                    local folder=game.Workspace:FindFirstChild("Enemies")
                    if folder then
                        for _, model in pairs(folder:GetChildren()) do
                            if model:IsA("Model") then
                                task.spawn(function()
                                    local hrp=model:FindFirstChild("HumanoidRootPart")
                                    if hrp then hrp.CanCollide=false; hrp.Position=pullPoint end
                                end)
                            end
                        end
                    end
                end
            end
            task.wait(0.001)
        end
    end)
end

doPullLoop(function() return S.pullEnemies end,  function(h) return Vector3.new(h.Position.X, h.Position.Y-10, h.Position.Z) end)
doPullLoop(function() return S.buddhaPull end,   function(h) return Vector3.new(h.Position.X+37, h.Position.Y-3, h.Position.Z) end)
doPullLoop(function() return S.customPull end,   function(h) return Vector3.new(h.Position.X+S.customPullX, h.Position.Y+S.customPullY, h.Position.Z+S.customPullZ) end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if S.autoKen then
            if not LocalPlayer:GetAttribute("KenActive") then
                keypress(0x45); task.wait(0.1); keyrelease(0x45)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        if S.autoHaki then
            local char=LocalPlayer.Character
            if char and not char:FindFirstChild("HasBuso") then
                pcall(function()
                    setrobloxinput(true)
                    keypress(0x4A)
                    task.wait(0.1)
                    keyrelease(0x4A)
                end)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if S.freezePos and S.freezePosition then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Position=S.freezePosition
                hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if S.freezeEnemies then
            local folder=game.Workspace:FindFirstChild("Enemies")
            if folder then
                for _, model in pairs(folder:GetChildren()) do
                    if model:IsA("Model") and not S.frozenEnemies[model] then
                        local hrp=model:FindFirstChild("HumanoidRootPart")
                        if hrp then S.frozenEnemies[model]=hrp.Position end
                    end
                end
            end
            for model, frozenPos in pairs(S.frozenEnemies) do
                if model and model.Parent then
                    local hrp=model:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Position=frozenPos
                        hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                    end
                else S.frozenEnemies[model]=nil end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if S.tweenEmber then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local currentPos=hrp.Position
                local closestModel=nil
                local closestPart=nil
                local closestDistance=math.huge
                for _, obj in pairs(game.Workspace:GetChildren()) do
                    if obj.Name=="EmberTemplate" and obj:IsA("Model") then
                        local part=obj:FindFirstChild("Part") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                        if part and part:IsA("BasePart") then
                            local emberPos=part.Position
                            local dx=emberPos.X-currentPos.X
                            local dy=emberPos.Y-currentPos.Y
                            local dz=emberPos.Z-currentPos.Z
                            local distance=dx*dx+dy*dy+dz*dz
                            if distance<closestDistance then
                                closestDistance=distance
                                closestModel=obj
                                closestPart=part
                            end
                        end
                    end
                end
                if closestModel and closestPart then
                    local emberPos=closestPart.Position
                    local targetPos=Vector3.new(emberPos.X,emberPos.Y+3,emberPos.Z)
                    tweenTo(hrp,targetPos,1200,function()
                        return S.tweenEmber and closestModel.Parent and closestPart.Parent
                    end)
                    hrp.Velocity=Vector3.new(0,0,0)
                    hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                    task.wait(0.08)
                else
                    task.wait(0.2)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if S.tweenEmber then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if S.teleportEmber and not S.tweenEmber then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _,obj in pairs(game.Workspace:GetChildren()) do
                    if obj.Name=="EmberTemplate" and obj:IsA("Model") then
                        local part=obj:FindFirstChild("Part")
                        if part and part:IsA("BasePart") then
                            hrp.Position=Vector3.new(part.Position.X,part.Position.Y+3,part.Position.Z)
                            hrp.Velocity=Vector3.new(0,0,0)
                            hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if S.teleportEmber and not S.tweenEmber then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity=Vector3.new(0,1,0)
                hrp.AssemblyLinearVelocity=Vector3.new(0,1,0)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if S.teleportKitsune then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local map=game.Workspace:FindFirstChild("Map")
                if map then
                    local kitsune=map:FindFirstChild("KitsuneIsland")
                    if kitsune then
                        local lampPost=kitsune:FindFirstChild("LampPost")
                        if lampPost then
                            local part=lampPost:FindFirstChild("Part")
                            if part and part:IsA("BasePart") then
                                local startPos=hrp.Position
                                local endPos=Vector3.new(part.Position.X, part.Position.Y+3, part.Position.Z)
                                local duration=2; local startTime=os.clock()
                                while S.teleportKitsune and os.clock()-startTime<duration do
                                    local progress=(os.clock()-startTime)/duration
                                    hrp.Position=Vector3.new(
                                        startPos.X+(endPos.X-startPos.X)*progress,
                                        startPos.Y+(endPos.Y-startPos.Y)*progress,
                                        startPos.Z+(endPos.Z-startPos.Z)*progress
                                    )
                                    task.wait(0.05)
                                end
                                if S.teleportKitsune then
                                    hrp.Position=endPos
                                    hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if S.teleportKitsune then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if not S.autoRaid or S.autoBossFarm or S.autoMaterialFarm or S.autoSeaEvent or S.autoMirageTween or S.autoMirageGear or S.fruitPriorityActive then
            S.raidDetected=false
            S.raidTweenActive=false
            S.raidLastIslandNum=0
            S.raidLastIslandKey=nil
            S.raidMapKey=nil
        else
            local map=game.Workspace:FindFirstChild("Map")
            local raidMap=map and map:FindFirstChild("RaidMap")
            local origin=game.Workspace:FindFirstChild("_WorldOrigin")
            local locations=origin and origin:FindFirstChild("Locations")
            local raidContainer=raidMap
            if not raidContainer and locations then
                for index=1,5 do
                    if locations:FindFirstChild("Island "..tostring(index)) then raidContainer=locations; break end
                end
            end
            if not raidContainer then
                S.raidDetected=false
                if S.raidMapKey~=nil or S.raidTweenActive then
                    S.raidMoveGeneration=S.raidMoveGeneration+1
                end
                S.raidTweenActive=false
                S.raidLastIslandNum=0
                S.raidLastIslandKey=nil
                S.raidMapKey=nil
            else
                S.raidDetected=true
                local currentMapKey=trackedInstanceKey(raidContainer)
                if S.raidMapKey~=currentMapKey then
                    if S.raidMapKey~=nil or S.raidTweenActive then
                        S.raidMoveGeneration=S.raidMoveGeneration+1
                    end
                    S.raidTweenActive=false
                    S.raidMapKey=currentMapKey
                    S.raidLastIslandNum=0
                    S.raidLastIslandKey=nil
                end

                local highestIsland=0
                local highestIslandModel=nil
                for _,child in pairs(raidContainer:GetChildren()) do
                    local name=child.Name
                    local num=nil
                    if type(name)=="string" and string.sub(name,1,10)=="RaidIsland" then
                        num=tonumber(string.sub(name,11))
                    elseif type(name)=="string" and string.sub(name,1,7)=="Island " then
                        num=tonumber(string.sub(name,8))
                    end
                    if num and num>highestIsland then
                        highestIsland=num
                        highestIslandModel=child
                    end
                end

                if not highestIslandModel then
                    if S.raidLastIslandKey~=nil or S.raidTweenActive then
                        S.raidMoveGeneration=S.raidMoveGeneration+1
                    end
                    S.raidTweenActive=false
                    S.raidLastIslandNum=0
                    S.raidLastIslandKey=nil
                else
                    local islandKey=trackedInstanceKey(highestIslandModel)
                    if islandKey~=S.raidLastIslandKey then
                        S.raidLastIslandNum=highestIsland
                        S.raidLastIslandKey=islandKey
                        S.raidMoveGeneration=S.raidMoveGeneration+1
                        local moveGeneration=S.raidMoveGeneration
                        S.raidTweenActive=true
                        notify("Raid Island "..highestIsland.." - Going there!","laced.club",2)
                        task.spawn(function()
                            local cpos=nil
                            for _=1,10 do
                                local okParent,islandParent=pcall(function() return highestIslandModel.Parent end)
                                if not okParent or not islandParent then break end
                                local candidates={}
                                local okSelf,isSelfPart=pcall(function() return highestIslandModel:IsA("BasePart") end)
                                if okSelf and isSelfPart then table.insert(candidates,highestIslandModel) end
                                local okPrimary,primaryPart=pcall(function() return highestIslandModel.PrimaryPart end)
                                if okPrimary and primaryPart then table.insert(candidates,primaryPart) end
                                local okParts,parts=pcall(function() return highestIslandModel:GetDescendants() end)
                                if okParts and parts then
                                    for _,part in pairs(parts) do
                                        if part:IsA("BasePart") then table.insert(candidates,part) end
                                    end
                                end
                                for _,part in pairs(candidates) do
                                    local okPos,pos=pcall(function() return part.Position end)
                                    if okPos and pos and pos.X then cpos=pos; break end
                                end
                                if cpos then break end
                                task.wait(0.3)
                            end

                            local myHrp=nil
                            if cpos then
                                for _=1,30 do
                                    local character=LocalPlayer.Character
                                    myHrp=character and character:FindFirstChild("HumanoidRootPart")
                                    if myHrp then break end
                                    task.wait(0.2)
                                end
                            end

                            if cpos and myHrp and S.autoRaid and S.raidMoveGeneration==moveGeneration then
                                local target=Vector3.new(cpos.X,cpos.Y+100,cpos.Z)
                                local startPos=myHrp.Position
                                local dx=target.X-startPos.X
                                local dy=target.Y-startPos.Y
                                local dz=target.Z-startPos.Z
                                local dist=math.sqrt(dx*dx+dy*dy+dz*dz)
                                local speed=math.max(tonumber(S.RAID_TWEEN_SPEED) or 320,1)
                                local duration=math.max(dist/speed,0.01)
                                local startedAt=os.clock()
                                while S.autoRaid and S.raidMoveGeneration==moveGeneration do
                                    local character=LocalPlayer.Character
                                    local hrp=character and character:FindFirstChild("HumanoidRootPart")
                                    if not hrp then task.wait(0.1); continue end
                                    local alpha=math.min((os.clock()-startedAt)/duration,1)
                                    pcall(function()
                                        hrp.CFrame=CFrame.new(
                                            startPos.X+dx*alpha,
                                            startPos.Y+dy*alpha,
                                            startPos.Z+dz*alpha
                                        )
                                        hrp.Velocity=Vector3.new(0,0,0)
                                        hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                                    end)
                                    if alpha>=1 then notify("Arrived!","laced.club",2); break end
                                    task.wait(0.01)
                                end
                            end

                            if S.raidMoveGeneration==moveGeneration then S.raidTweenActive=false end
                        end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoRaid and S.raidDetected and not S.raidTweenActive and not farmPriorityBlocked() then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local useRemote=S.remoteMode
                farmAttack(
                    hrp,
                    function()
                        return S.autoRaid and S.raidDetected and not S.raidTweenActive and not farmPriorityBlocked() and S.remoteMode==useRemote
                    end,
                    nil,
                    true,
                    1000,
                    useRemote and remoteAttack or nil,
                    useRemote and 0.05 or 0.06
                )
            end
            task.wait(0.1)
        else task.wait(0.1) end
    end
end)

task.spawn(function()
    while true do
        if S.voidPull then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Position=Vector3.new(hrp.Position.X,100000,hrp.Position.Z); hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) end
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if S.skyPull then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Position=Vector3.new(hrp.Position.X,1000,hrp.Position.Z); hrp.Velocity=Vector3.new(0,0,0); hrp.AssemblyLinearVelocity=Vector3.new(0,0,0) end
        end
        task.wait()
    end
end)

