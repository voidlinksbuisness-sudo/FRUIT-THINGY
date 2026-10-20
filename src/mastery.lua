-- Scoped locals preserve the concatenated runtime's register budget.
do
    local function matches(tool,kind)
        local ok,value=pcall(function()
            return tool and tool:IsA("Tool") and tool.ToolTip
        end)
        return ok and type(value)=="string" and string.lower(value)==string.lower(kind)
    end
    local equippedKey,equippedKind,equippedSlot=nil,nil,nil
    local function equip(kind,check)
        local slot=S.masterySlots[kind]
        local held=getCurrentlyHeldTool()
        if held and (matches(held,kind) or (equippedKind==kind and equippedSlot==slot
            and equippedKey==trackedInstanceKey(held))) then return held end
        -- Matcha supports keyboard input; ToolTip, EquipTool and Parent writes
        -- are deliberately not required. The configured hotbar slot is authoritative.
        for attempt=1,2 do
            if not check() then return nil end
            local key=0x30+slot
            setrobloxinput(true)
            keyrelease(key)
            keypress(key)
            task.wait(0.08)
            keyrelease(key)
            local started=os.clock()
            repeat
                if not check() then return nil end
                held=getCurrentlyHeldTool()
                if held then
                    local ok,tip=pcall(function() return held.ToolTip end)
                    if not ok or type(tip)~="string" or tip=="" or matches(held,kind) then
                        equippedKey,equippedKind,equippedSlot=trackedInstanceKey(held),kind,slot
                        return held
                    end
                end
                task.wait(0.05)
            until os.clock()-started>=0.4
        end
        return nil
    end
    local function aim(part)
        local pos=getSafeFruitPosition(part)
        if not pos then return false end
        local screen,onScreen=WorldToScreen(pos)
        if not screen or not onScreen then
            local camera=game.Workspace.CurrentCamera
            if not camera then return false end
            camera.CFrame=CFrame.lookAt(camera.CFrame.Position,pos)
            screen,onScreen=WorldToScreen(pos)
        end
        if not screen or not onScreen then return false end
        mousemoveabs(math.floor(screen.X),math.floor(screen.Y))
        return true
    end
    task.spawn(function()
        local lastWarning=-math.huge
        while true do
            local ok,err=pcall(function()
                local char=LocalPlayer.Character
                local hrp=char and char:FindFirstChild("HumanoidRootPart")
                local kind=S.masteryWeapon
                local slot=S.masterySlots[kind]
                local function active()
                    return S.autoMastery and S.masteryWeapon==kind and S.masterySlots[kind]==slot
                        and not farmPriorityBlocked(false,true)
                        and LocalPlayer.Character and trackedInstanceKey(LocalPlayer.Character)==trackedInstanceKey(char) and hrp and hrp.Parent
                end
                if not active() then
                    if S.autoMastery and os.clock()-lastWarning>5 then
                        lastWarning=os.clock()
                        notify("Auto Mastery paused: another priority farm is enabled or character is loading","laced.club",3)
                    end
                    return
                end
                local enemies=game.Workspace:FindFirstChild("Enemies")
                local nearby=false
                for _,enemy in pairs(enemies and enemies:GetChildren() or {}) do
                    local root=enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildOfClass("BasePart")
                    local pos=getSafeFruitPosition(root)
                    if pos and isAlive(enemy) then
                        local dx,dy,dz=pos.X-hrp.Position.X,pos.Y-hrp.Position.Y,pos.Z-hrp.Position.Z
                        if dx*dx+dy*dy+dz*dz<=1000000 then nearby=true; break end
                    end
                end
                if not nearby then
                    if os.clock()-lastWarning>5 then
                        lastWarning=os.clock()
                        notify("Auto Mastery: no loaded NPC within 1000 studs. Move near enemies first.","laced.club",3)
                    end
                    return
                end
                if not equip(kind,active) then
                    if os.clock()-lastWarning>5 then
                        lastWarning=os.clock()
                        notify("Auto Mastery: put your "..kind.." in hotbar slot "..slot.." or change Mastery Hotbar Slot","laced.club",3)
                    end
                    return
                end
                farmAttack(hrp,active,nil,true,1000,function(enemy,part)
                    if not active() or not isAlive(enemy) then return end
                    if not equip(kind,active) then return end
                    setrobloxinput(true)
                    if kind=="Gun" then
                        local target=enemy:FindFirstChild("Head") or part
                        if not aim(target) then return end
                        task.wait(0.02)
                        if not active() or not isAlive(enemy) then return end
                    end
                    mouse1click()
                end,kind=="Gun" and 0.15 or 0.06,{syncAttack=true,speed=S.MASTERY_TWEEN_SPEED})
            end)
            if not ok and os.clock()-lastWarning>5 then
                lastWarning=os.clock()
                warn("Auto Mastery: "..tostring(err))
            end
            task.wait(0.1)
        end
    end)
end

