do
    local Dungeon={
        target=nil,
        targetingObjective=false,
        doorWaypoint=nil,
    }

    local function dungeonDistance(a,b)
        local dx=a.X-b.X
        local dy=a.Y-b.Y
        local dz=a.Z-b.Z
        return math.sqrt(dx*dx+dy*dy+dz*dz)
    end

    local function dungeonRoot(object)
        if not object then return nil end
        return object:FindFirstChild("HumanoidRootPart")
            or object:FindFirstChild("UpperTorso")
            or object:FindFirstChild("Head")
            or object:FindFirstChildWhichIsA("BasePart")
    end

    local function dungeonIsSummon(object)
        if not object then return true end
        if object:FindFirstChild("Summoner") or object:FindFirstChild("Creator") or object:FindFirstChild("Owner") then return true end
        local name=string.lower(object.Name or "")
        return string.find(name,"shadow",1,true)~=nil
            or string.find(name,"buddy",1,true)~=nil
            or string.find(name,"blank",1,true)~=nil
            or string.find(name,"clone",1,true)~=nil
            or string.find(name,"summon",1,true)~=nil
            or string.find(name,"decoy",1,true)~=nil
            or string.find(name,"dummy",1,true)~=nil
    end

    local function dungeonIsAlive(object)
        if not object or not object.Parent or dungeonIsSummon(object) then return false end
        local humanoid=object:FindFirstChildOfClass("Humanoid")
        return humanoid~=nil and humanoid.Health>0 and dungeonRoot(object)~=nil
    end

    local function dungeonIsObjective(object)
        if not dungeonIsAlive(object) then return false end
        local name=string.lower(object.Name or "")
        local objective=name=="prophitboxplaceholder"
            or string.find(name,"placeholder",1,true)~=nil
            or string.find(name,"gasvent",1,true)~=nil
            or string.find(name,"vent",1,true)~=nil
            or string.find(name,"shrine",1,true)~=nil
            or string.find(name,"rock",1,true)~=nil
            or string.find(name,"totem",1,true)~=nil
            or (string.find(name,"prop",1,true)~=nil and string.find(name,"knight",1,true)==nil and string.find(name,"boss",1,true)==nil)
        if not objective then return false end
        local humanoid=object:FindFirstChildOfClass("Humanoid")
        return humanoid and humanoid.MaxHealth<50000
    end

    local function dungeonNearestIsland(position)
        local map=game.Workspace:FindFirstChild("Map")
        local dungeon=map and map:FindFirstChild("Dungeon") or nil
        if not dungeon then return nil end
        local best=nil
        local bestDistance=math.huge
        for _,island in pairs(dungeon:GetChildren()) do
            local root=island:FindFirstChild("Root") or island:FindFirstChildWhichIsA("BasePart")
            if root then
                local dx=position.X-root.Position.X
                local dz=position.Z-root.Position.Z
                local distance=math.sqrt(dx*dx+dz*dz)
                if distance<bestDistance then
                    bestDistance=distance
                    best=island
                end
            end
        end
        return best
    end

    local function dungeonDoorWaypoint(position)
        local island=dungeonNearestIsland(position)
        local exit=island and island:FindFirstChild("ExitTeleporter") or nil
        local door=exit and (exit:FindFirstChild("Root") or exit:FindFirstChildWhichIsA("BasePart")) or nil
        if not door then return nil end
        local doorPosition=door.Position
        local dx=doorPosition.X-position.X
        local dz=doorPosition.Z-position.Z
        local distanceXZ=math.sqrt(dx*dx+dz*dz)
        if distanceXZ>30 then
            local islandRoot=island:FindFirstChild("Root") or island:FindFirstChildWhichIsA("BasePart")
            local islandY=islandRoot and islandRoot.Position.Y or 200
            return Vector3.new(doorPosition.X,math.max(position.Y,doorPosition.Y,islandY)+35,doorPosition.Z)
        end
        return Vector3.new(doorPosition.X,doorPosition.Y+3,doorPosition.Z)
    end

    local function dungeonFindTarget(playerPosition)
        local folder=game.Workspace:FindFirstChild("Enemies")
        if not folder then return nil,false end
        local bestObjective=nil
        local bestObjectiveDistance=math.huge
        local bestEnemy=nil
        local bestEnemyDistance=S.dungeonLocalRadius or 800

        for _,enemy in pairs(folder:GetChildren()) do
            if dungeonIsAlive(enemy) then
                local root=dungeonRoot(enemy)
                if root then
                    local distance=dungeonDistance(playerPosition,root.Position)
                    if S.dungeonDestroyObj and dungeonIsObjective(enemy) then
                        if distance<bestObjectiveDistance then
                            bestObjectiveDistance=distance
                            bestObjective=enemy
                        end
                    elseif distance<bestEnemyDistance then
                        bestEnemyDistance=distance
                        bestEnemy=enemy
                    end
                end
            end
        end
        if bestObjective then return bestObjective,true end
        return bestEnemy,false
    end

    task.spawn(function()
        while true do
            if S.dungeonEnabled then
                local character=LocalPlayer.Character
                local root=character and character:FindFirstChild("HumanoidRootPart") or nil
                local humanoid=character and character:FindFirstChildOfClass("Humanoid") or nil
                if root and humanoid and humanoid.Health>0 then
                    local target,isObjective=dungeonFindTarget(root.Position)
                    Dungeon.target=target
                    Dungeon.targetingObjective=isObjective
                    Dungeon.doorWaypoint=nil
                    local targetRoot=dungeonRoot(target)
                    if targetRoot then
                        local useRemote=S.remoteMode
                        local expandedHead=not useRemote and target:FindFirstChild("Head") or nil
                        local originalHeadSize=nil
                        local originalHeadCanCollide=nil
                        if expandedHead then
                            pcall(function()
                                originalHeadSize=expandedHead.Size
                                originalHeadCanCollide=expandedHead.CanCollide
                            end)
                        end
                        local p=targetRoot.Position
                        local ox,oy,oz=getNormalFarmOffsets()
                        local targetPosition=Vector3.new(p.X+ox,p.Y+oy,p.Z+oz)
                        tweenTo(root,targetPosition,S.FARM_SPEED,function()
                            return S.dungeonEnabled and S.remoteMode==useRemote
                                and Dungeon.target==target and dungeonIsAlive(target)
                        end)

                        local lastAttack=0
                        while S.dungeonEnabled and S.remoteMode==useRemote
                            and Dungeon.target==target and dungeonIsAlive(target) do
                            targetRoot=dungeonRoot(target)
                            if not targetRoot then break end
                            p=targetRoot.Position
                            ox,oy,oz=getNormalFarmOffsets()
                            targetPosition=Vector3.new(p.X+ox,p.Y+oy,p.Z+oz)
                            hardLockNpcCFrame(root,targetPosition)
                            if expandedHead then
                                local size=S.bigHitbox and 200 or 50
                                pcall(function()
                                    expandedHead.Size=Vector3.new(size,size,size)
                                    expandedHead.CanCollide=false
                                end)
                            end

                            local now=os.clock()
                            local attackDelay=useRemote and 0.05 or 0.06
                            if now-lastAttack>=attackDelay then
                                lastAttack=now
                                if useRemote then task.spawn(remoteAttack)
                                else pcall(mouse1click) end
                            end
                            task.wait()
                        end
                        if expandedHead and expandedHead.Parent and originalHeadSize then
                            pcall(function()
                                expandedHead.Size=originalHeadSize
                                if originalHeadCanCollide~=nil then expandedHead.CanCollide=originalHeadCanCollide end
                            end)
                        end
                    elseif S.dungeonAutoDoor then
                        Dungeon.doorWaypoint=dungeonDoorWaypoint(root.Position)
                        if Dungeon.doorWaypoint then
                            tweenTo(root,Dungeon.doorWaypoint,S.FARM_SPEED,function()
                                return S.dungeonEnabled and S.dungeonAutoDoor
                            end)
                        end
                    end
                end
            else
                Dungeon.target=nil
                Dungeon.targetingObjective=false
                Dungeon.doorWaypoint=nil
            end
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        local skillKeys={0x5A,0x58,0x43,0x56}
        while true do
            if S.dungeonEnabled and S.dungeonUseMoves
                and Dungeon.targetingObjective and dungeonIsAlive(Dungeon.target) then
                for _,keyCode in pairs(skillKeys) do
                    if not S.dungeonEnabled or not dungeonIsAlive(Dungeon.target) then break end
                    pcall(function()
                        keypress(keyCode)
                        task.wait(0.04)
                        keyrelease(keyCode)
                    end)
                    task.wait(0.16)
                end
            end
            task.wait(0.3)
        end
    end)

end

