-- Scoped locals preserve the concatenated runtime's register budget.
do
    local function matches(tool,kind)
        local ok,value=pcall(function()
            return tool and tool:IsA("Tool") and tool.ToolTip
        end)
        return ok and type(value)=="string" and string.lower(value)==string.lower(kind)
    end
    local function equip(kind,check)
        local held=getCurrentlyHeldTool()
        if matches(held,kind) then return held end
        local char=LocalPlayer.Character
        local backpack=LocalPlayer:FindFirstChild("Backpack")
        if not char or not backpack then return nil end
        for _,tool in pairs(backpack:GetChildren()) do
            if matches(tool,kind) then
                local hum=char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(tool) end) end
                if not matches(getCurrentlyHeldTool(),kind) then
                    pcall(function() tool.Parent=char end)
                end
                if check() and matches(getCurrentlyHeldTool(),kind) then
                    return getCurrentlyHeldTool()
                end
                return nil
            end
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
                local function active()
                    return S.autoMastery and S.masteryWeapon==kind
                        and not farmPriorityBlocked(false,true)
                        and LocalPlayer.Character==char and hrp and hrp.Parent
                end
                if not active() then return end
                if not equip(kind,active) then
                    if os.clock()-lastWarning>5 then
                        lastWarning=os.clock()
                        notify("Equip a "..kind.." weapon in your backpack for Auto Mastery","laced.club",3)
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

