local function getChestType(chest)
    local okName,name=pcall(function() return chest and chest.Name end)
    if not okName or type(name)~="string" then return "Other" end
    local lowerName=string.lower(name)
    if string.match(lowerName,"diamond") then return "Diamond" end
    if string.match(lowerName,"gold") then return "Gold" end
    if string.match(lowerName,"silver") then return "Silver" end
    return "Other"
end

local function getChestPriorityRank(chestType)
    for rank,name in ipairs(S.chestPriority) do
        if name==chestType then return rank end
    end
    return #S.chestPriority+1
end

local function getPriorityChest(children,hrp)
    if not children or not hrp then return nil,nil,nil end
    local okPlayer,playerPos=pcall(function() return hrp.Position end)
    if not okPlayer or not playerPos then return nil,nil,nil end

    local activeKeys={}
    for _,chest in pairs(children) do
        activeKeys[trackedInstanceKey(chest)]=true
    end
    for key in pairs(S.handledChests) do
        if not activeKeys[key] then S.handledChests[key]=nil end
    end

    local bestChest,bestPart,bestType=nil,nil,nil
    local bestRank,bestDistance=math.huge,math.huge
    for _,chest in pairs(children) do
        local chestKey=trackedInstanceKey(chest)
        local part=chest and (chest:FindFirstChild("RootPart") or chest:FindFirstChildOfClass("BasePart")) or nil
        local okParent,parent=pcall(function() return chest and chest.Parent end)
        local okPos,pos=pcall(function() return part and part.Position end)
        if not S.handledChests[chestKey] and okParent and parent and okPos and pos then
            local chestType=getChestType(chest)
            local rank=getChestPriorityRank(chestType)
            local dx=pos.X-playerPos.X
            local dy=pos.Y-playerPos.Y
            local dz=pos.Z-playerPos.Z
            local distanceSq=dx*dx+dy*dy+dz*dz
            if rank<bestRank or (rank==bestRank and distanceSq<bestDistance) then
                bestChest,bestPart,bestType=chest,part,chestType
                bestRank,bestDistance=rank,distanceSq
            end
        end
    end
    return bestChest,bestPart,bestType
end

task.spawn(function()
    while true do
        if S.autoFarming and not farmPriorityBlocked() then
            local reachedChest=false
            local ChestModels=game.Workspace:FindFirstChild("ChestModels")
            if ChestModels then
                local okChildren,children=pcall(function() return ChestModels:GetChildren() end)
                local char=LocalPlayer.Character
                local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
                if okChildren and children and hrp then
                    local chest,part,chestType=getPriorityChest(children,hrp)
                    local okPos,pos=pcall(function() return part and part.Position end)
                    if chest and part and okPos and pos then
                        notify("Going to "..chestType.." chest","laced.club",2)
                        local destination=Vector3.new(pos.X,pos.Y+3,pos.Z)
                        tweenTo(hrp,destination,S.CHEST_SPEED,function()
                            local okChest,chestParent=pcall(function() return chest.Parent end)
                            local okPart,partParent=pcall(function() return part.Parent end)
                            return S.autoFarming and not farmPriorityBlocked()
                                and okChest and chestParent~=nil and okPart and partParent~=nil
                        end)
                        local okArrival,currentPos=pcall(function() return hrp.Position end)
                        if okArrival and currentPos then
                            local dx=currentPos.X-destination.X
                            local dy=currentPos.Y-destination.Y
                            local dz=currentPos.Z-destination.Z
                            if dx*dx+dy*dy+dz*dz<=4 then
                                S.handledChests[trackedInstanceKey(chest)]=true
                                reachedChest=true
                            end
                        end
                    end
                end
            end
            if reachedChest then task.wait() else task.wait(0.25) end
        else task.wait(0.1) end
    end
end)

function getCurrentlyHeldTool()
    local char=LocalPlayer.Character
    if not char then return nil end
    for _,child in pairs(char:GetChildren()) do
        local okClass, className=pcall(function() return child.ClassName end)
        if okClass and className=="Tool" then
            return child
        end
    end
    return nil
end

function pressWeaponSlot(slot)
    local selectedKey=(slot==3) and 0x33 or 0x31
    pcall(function()

        setrobloxinput(true)
        keyrelease(selectedKey)
        task.wait(0.02)
        keypress(selectedKey)
        task.wait(0.1)
        keyrelease(selectedKey)
    end)

    if getCurrentlyHeldTool() then return true end

    local char=LocalPlayer and LocalPlayer.Character or nil
    local backpack=LocalPlayer and LocalPlayer:FindFirstChild("Backpack") or nil
    local hum=char and char:FindFirstChildOfClass("Humanoid") or nil
    if not char or not backpack then return false end

    local tools={}
    local okChildren, children=pcall(function() return backpack:GetChildren() end)
    if okChildren and children then
        for _,candidate in pairs(children) do
            local okTool, className=pcall(function() return candidate.ClassName end)
            if okTool and className=="Tool" then table.insert(tools,candidate) end
        end
    end

    local tool=tools[slot]
    if not tool then return false end

    local equipped=false
    if hum then
        local okEquip=pcall(function() hum:EquipTool(tool) end)
        if okEquip then
            local okParent, parent=pcall(function() return tool.Parent end)
            equipped=okParent and parent==char
        end
    end
    if not equipped then
        pcall(function() tool.Parent=char end)
        local okParent, parent=pcall(function() return tool.Parent end)
        equipped=okParent and parent==char
    end
    return equipped
end

function restoreHeldTool(rememberedTool, toolName)

    local char=LocalPlayer and LocalPlayer.Character or nil
    local backpack=LocalPlayer and LocalPlayer:FindFirstChild("Backpack") or nil
    local hum=char and char:FindFirstChildOfClass("Humanoid") or nil
    local tool=nil

    if rememberedTool then
        local okTool, isTool=pcall(function() return rememberedTool:IsA("Tool") end)
        local okParent, parent=pcall(function() return rememberedTool.Parent end)
        if okTool and isTool and okParent and parent and (parent==char or parent==backpack) then
            tool=rememberedTool
        end
    end

    if not tool and toolName then
        local charTool=char and char:FindFirstChild(toolName) or nil
        local backpackTool=backpack and backpack:FindFirstChild(toolName) or nil
        if charTool and charTool:IsA("Tool") then
            tool=charTool
        elseif backpackTool and backpackTool:IsA("Tool") then
            tool=backpackTool
        end
    end

    if tool and char then
        local equipped=false
        if hum then
            local okEquip=pcall(function() hum:EquipTool(tool) end)
            if okEquip then
                local okParent, parent=pcall(function() return tool.Parent end)
                equipped=okParent and parent==char
            end
        end

        if not equipped then
            pcall(function() tool.Parent=char end)
        end
    end

end

task.spawn(function()
    while true do
        if S.autoFruits then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bestPart, bestDist=nil, math.huge
                local okHrp, hrpPos=pcall(function() return hrp.Position end)
                if okHrp and hrpPos and hrpPos.X and hrpPos.Y and hrpPos.Z then
                    for _, fruit in pairs(getWorkspaceFruits()) do
                        local fp, fpPos=fruit.part, getSafeFruitPosition(fruit.part)
                        if fp and fpPos then
                            local dx=fpPos.X-hrpPos.X
                            local dy=fpPos.Y-hrpPos.Y
                            local dz=fpPos.Z-hrpPos.Z
                            local dist=math.sqrt(dx*dx+dy*dy+dz*dz)
                            if dist<bestDist then bestDist=dist; bestPart=fp end
                        end
                    end
                end
                if bestPart then

                    S.fruitPriorityActive=true

                    notify("Farming fruit...","laced.club",1)
                    local okTarget, fruitPos=pcall(function() return bestPart.Position end)
                    local arrived=false
                    if okTarget and fruitPos and fruitPos.X and fruitPos.Y and fruitPos.Z then
                        tweenTo(hrp, Vector3.new(fruitPos.X,fruitPos.Y+3,fruitPos.Z), S.FRUIT_SPEED, function()
                            return S.autoFruits and bestPart and bestPart.Parent
                        end)
                        arrived=true
                    end

                    if arrived and S.autoFruits then
                        task.wait(1)
                        pressWeaponSlot(S.weaponSlot)
                    end

                    local fruitWaitStart=os.clock()
                    while S.autoFruits and bestPart and bestPart.Parent and os.clock()-fruitWaitStart<3 do
                        task.wait(0.05)
                    end

                    S.fruitPriorityActive=false
                else
                    S.fruitPriorityActive=false
                end
            end
            task.wait(0.1)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        local farming=S.autoFireFlowers or S.autoFarmNearest or S.autoNpcFarm or S.autoFarmLevel or S.autoRaid or S.autoBossFarm or S.autoMaterialFarm or S.autoSeaEvent
        if farming and not getCurrentlyHeldTool() then
            local selectedSlot=S.weaponSlot
            task.spawn(function() pressWeaponSlot(selectedSlot) end)
        end
        task.wait(0.25)
    end
end)

task.spawn(function()
    while true do
        if S.autoFarmNearest and not farmPriorityBlocked() then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then

                local useRemote=S.remoteMode
                farmAttack(
                    hrp,
                    function()
                        return S.autoFarmNearest and S.remoteMode==useRemote and not farmPriorityBlocked()
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
        if S.autoNpcFarm and not farmPriorityBlocked() then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local island=islandList[S.selectedIsland]
                local ip=island.pos
                notify("NPC Farm: going to "..island.name,"laced.club",2)
                tweenTo(hrp, Vector3.new(ip.X,ip.Y,ip.Z), S.NPC_TWEEN_SPEED, function() return S.autoNpcFarm and not farmPriorityBlocked() end)
                task.wait(0.5)
                local char2=LocalPlayer.Character
                if char2 then for _,part in pairs(char2:GetChildren()) do if part:IsA("BasePart") then part.CanCollide=false end end end
                while S.autoNpcFarm and not farmPriorityBlocked() do
                    local hrp2=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp2 then task.wait(0.1); break end

                    if S.remoteMode then

                        local folder=game.Workspace:FindFirstChild("Enemies")
                        if folder then
                            local nearest, bestDist=nil, math.huge
                            for _,model in pairs(folder:GetChildren()) do
                                if model:IsA("Model") and isAlive(model) then
                                    local root=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildOfClass("BasePart")
                                    if root then
                                        local dx=root.Position.X-hrp2.Position.X
                                        local dy=root.Position.Y-hrp2.Position.Y
                                        local dz=root.Position.Z-hrp2.Position.Z
                                        local d=math.sqrt(dx*dx+dy*dy+dz*dz)
                                        if d<bestDist and d<=1000 then bestDist=d; nearest=model end
                                    end
                                end
                            end
                            if nearest then
                                local reachedNpc=false
                                local lastRemoteAttack=0
                                while S.autoNpcFarm and S.remoteMode and not farmPriorityBlocked() and isAlive(nearest) do
                                    local tr=nearest:FindFirstChild("HumanoidRootPart") or nearest:FindFirstChildOfClass("BasePart")
                                    if not tr then break end
                                    local ox,oy,oz=getNormalFarmOffsets()
                                    local targetPos=Vector3.new(tr.Position.X+ox,tr.Position.Y+oy,tr.Position.Z+oz)
                                    if not reachedNpc then
                                        tweenTo(hrp2,targetPos,S.FARM_SPEED,function()
                                            return S.autoNpcFarm and S.remoteMode and not farmPriorityBlocked() and isAlive(nearest)
                                        end)
                                        reachedNpc=true
                                    else
                                        hardLockNpcCFrame(hrp2,targetPos)
                                    end
                                    local now=os.clock()
                                    if now-lastRemoteAttack>=0.05 then
                                        remoteAttack()
                                        lastRemoteAttack=now
                                    end
                                    task.wait()
                                end
                            end
                        end
                    else
                        farmAttack(hrp2, function()
                            return S.autoNpcFarm and not S.remoteMode and not farmPriorityBlocked()
                        end, nil, true, 1000)
                    end
                    task.wait(0.1)
                end
            end
            task.wait(0.1)
        else task.wait(0.1) end
    end
end)

