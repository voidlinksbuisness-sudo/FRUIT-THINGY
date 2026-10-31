-- Scoped to preserve the combined runtime's local register budget.
do
    local pumpkins,jacks={},{}
    local nextScan=0
    local nextEquip=0
    local warnedAt=-math.huge
    local function position(object)
        local part=resolveFruitPart(object)
        local pos=getSafeFruitPosition(part)
        if pos then return pos end
        local ok,pivot=pcall(function() return object:GetPivot() end)
        if ok and pivot then return pivot.Position end
        return nil
    end
    local function belongs(object,folder)
        local ok,parent=pcall(function() return object.Parent end)
        return ok and parent and folder and trackedInstanceKey(parent)==trackedInstanceKey(folder)
    end
    local function refresh()
        if os.clock()<nextScan then return end
        nextScan=os.clock()+0.25
        pumpkins,jacks={},{}
        local folder=game.Workspace:FindFirstChild("PumpkinHunt")
        for _,object in pairs(folder and folder:GetChildren() or {}) do
            if object.Name=="Pumpkin" then pumpkins[#pumpkins+1]=object end
        end
        local enemies=game.Workspace:FindFirstChild("Enemies")
        for _,enemy in pairs(enemies and enemies:GetChildren() or {}) do
            if enemy.Name=="Jack o' Lantern" then jacks[#jacks+1]=enemy end
        end
    end
    local function nearest(objects,hrp,isEnemy)
        local folder=game.Workspace:FindFirstChild(isEnemy and "Enemies" or "PumpkinHunt")
        local best,bestPos,bestDistance=nil,nil,math.huge
        for _,object in pairs(objects) do
            local ok,pos=pcall(function()
                if not belongs(object,folder) then return nil end
                if isEnemy then
                    local hum=object:FindFirstChildOfClass("Humanoid")
                    if not hum or hum.Health<=0 then return nil end
                end
                return position(object)
            end)
            if ok and pos then
                local p=hrp.Position
                local dx,dy,dz=pos.X-p.X,pos.Y-p.Y,pos.Z-p.Z
                local distance=dx*dx+dy*dy+dz*dz
                if distance<bestDistance and (not isEnemy or distance<=1000000) then
                    best,bestPos,bestDistance=object,pos,distance
                end
            end
        end
        return best,bestPos
    end
    local function active(hrp)
        local char=LocalPlayer.Character
        return S.autoPumpkins and not farmPriorityBlocked(true,true,true)
            and char and hrp and hrp.Parent and trackedInstanceKey(hrp.Parent)==trackedInstanceKey(char)
    end
    local function aimAt(pos)
        local screen,onScreen=WorldToScreen(pos)
        if not onScreen then
            local camera=game.Workspace.CurrentCamera
            if not camera then return false end
            camera.CFrame=CFrame.lookAt(camera.CFrame.Position,pos)
            screen,onScreen=WorldToScreen(pos)
        end
        if not onScreen or not screen then return false end
        mousemoveabs(math.floor(screen.X),math.floor(screen.Y))
        return true
    end
    local function equip()
        if getCurrentlyHeldTool() then return true end
        if os.clock()>=nextEquip then
            nextEquip=os.clock()+1
            pressWeaponSlot(S.weaponSlot)
        end
        return getCurrentlyHeldTool()~=nil
    end
    local function step()
        local char=LocalPlayer.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if not active(hrp) then return end
        refresh()
        if not equip() or not active(hrp) then return end
        local jack=nearest(jacks,hrp,true)
        if jack then
            -- Reuse the ordinary nearest combat movement and selected weapon.
            farmAttack(hrp,function() return active(hrp) end,"Jack o' Lantern",true,1000,function(enemy,part)
                if not active(hrp) or not isAlive(enemy) then return end
                local pos=getSafeFruitPosition(part)
                if pos and aimAt(pos) then
                    setrobloxinput(true)
                    mouse1click()
                end
            end,0.1,{syncAttack=true})
            return
        end
        local pumpkin,pos=nearest(pumpkins,hrp,false)
        if not pumpkin then return end
        local folder=game.Workspace:FindFirstChild("PumpkinHunt")
        local function canFarm()
            if not active(hrp) or not belongs(pumpkin,folder) then return false end
            refresh()
            return nearest(jacks,hrp,true)==nil
        end
        -- Pumpkins need close M1 range rather than the NPC farming height.
        tweenTo(hrp,Vector3.new(pos.X,pos.Y+3,pos.Z+4),S.FARM_SPEED,canFarm)
        while canFarm() do
            local current=position(pumpkin)
            if not current then return end
            hardLockNpcCFrame(hrp,Vector3.new(current.X,current.Y+3,current.Z+4))
            if equip() and canFarm() and aimAt(current) then
                setrobloxinput(true)
                mouse1click()
            end
            task.wait(0.1)
        end
    end
    task.spawn(function()
        while true do
            if S.autoPumpkins then
                local ok,err=pcall(step)
                if not ok and os.clock()-warnedAt>=5 then
                    warnedAt=os.clock()
                    warn("Auto Pumpkin Farm: "..tostring(err))
                end
            else
                pumpkins,jacks={},{}
                nextScan=0
            end
            task.wait(0.1)
        end
    end)
end

