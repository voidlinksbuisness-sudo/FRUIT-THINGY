task.spawn(function()
    while true do
        if S.autoFarmLevel and not farmPriorityBlocked() and not AFL.farmLoopRunning then
            AFL.farmLoopRunning=true
            local ok=pcall(afl_farmNpcs)
            AFL.farmLoopRunning=false
            AFL.selectedNpc=nil
            AFL.nextNpcCache=nil
            if not ok then wait(0.5) end
        end
        wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if S.fruitEsp then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            for _, entry in pairs(S.espLabels) do
                if entry and entry.label and entry.part and hrp then
                    local screenPos, onScreen=WorldToScreen(entry.part.Position)
                    entry.label.Visible=onScreen
                    if onScreen then entry.label.Position=Vector2.new(screenPos.X,screenPos.Y-20) end
                end
            end
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if S.chestEsp then
            -- Discovery and projection yield in small batches; never run every frame.
            local ok = pcall(updateChestEspLabels)
            if not ok then clearChestEspLabels() end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if S.berryEsp then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
            local okPlayer,playerPos=pcall(function() return hrp and hrp.Position end)
            for _,entry in pairs(S.berryEspLabels) do
                local label=entry and entry.label or nil
                local part=entry and entry.part or nil
                local okParent,parent=pcall(function() return part and part.Parent end)
                local okPos,pos=pcall(function() return part and part.Position end)
                local visible=false

                if okPlayer and playerPos and okParent and parent and okPos and pos then
                    local dx=pos.X-playerPos.X
                    local dy=pos.Y-playerPos.Y
                    local dz=pos.Z-playerPos.Z
                    local distanceSq=dx*dx+dy*dy+dz*dz
                    if distanceSq<=BERRY_DRAW_DISTANCE_SQ then
                        local okScreen,screenPos,onScreen=pcall(function() return WorldToScreen(pos) end)
                        visible=okScreen and onScreen and screenPos~=nil
                        if visible then
                            if label then label.Position=Vector2.new(screenPos.X,screenPos.Y-18) end
                        end
                    end
                end

                if label then label.Visible=visible end
            end
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if S.boatEsp then
            for _,entry in pairs(S.boatEspEntries) do
                updateWorldBoxEntry(entry)
            end
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if S.flowerEsp then
            for _,entry in pairs(S.flowerEspEntries) do
                updateWorldBoxEntry(entry)
            end
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if S.berryEsp then buildBerryEspLabels() end
        if S.flowerEsp and trackedFlowersChanged() then buildFlowerEsp() end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if S.fruitEsp then buildEspLabels(); buildChamBoxes() end
        if S.chestEsp then
            buildChestEspLabels()
        end
        if S.boatEsp then
            local boats=game.Workspace:FindFirstChild("Boats")
            if trackedFolderChanged("boats",boats) then buildBoatEsp() end
        end
    end
end)

task.spawn(function()
    while true do
        if S.chamEsp then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            for _, entry in pairs(S.chamBoxes) do
                if entry and entry.part and hrp then
                    local pos=entry.part.Position; local sz=entry.part.Size*0.5
                    local corners={
                        Vector3.new(pos.X-sz.X,pos.Y-sz.Y,pos.Z-sz.Z), Vector3.new(pos.X+sz.X,pos.Y-sz.Y,pos.Z-sz.Z),
                        Vector3.new(pos.X-sz.X,pos.Y+sz.Y,pos.Z-sz.Z), Vector3.new(pos.X+sz.X,pos.Y+sz.Y,pos.Z-sz.Z),
                        Vector3.new(pos.X-sz.X,pos.Y-sz.Y,pos.Z+sz.Z), Vector3.new(pos.X+sz.X,pos.Y-sz.Y,pos.Z+sz.Z),
                        Vector3.new(pos.X-sz.X,pos.Y+sz.Y,pos.Z+sz.Z), Vector3.new(pos.X+sz.X,pos.Y+sz.Y,pos.Z+sz.Z),
                    }
                    local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
                    local anyOn=false
                    for _, c in pairs(corners) do
                        local sp,on=WorldToScreen(c)
                        if on then anyOn=true end
                        if sp.X<minX then minX=sp.X end; if sp.Y<minY then minY=sp.Y end
                        if sp.X>maxX then maxX=sp.X end; if sp.Y>maxY then maxY=sp.Y end
                    end
                    if anyOn then
                        entry.lines[1].From=Vector2.new(minX,minY); entry.lines[1].To=Vector2.new(maxX,minY)
                        entry.lines[2].From=Vector2.new(minX,maxY); entry.lines[2].To=Vector2.new(maxX,maxY)
                        entry.lines[3].From=Vector2.new(minX,minY); entry.lines[3].To=Vector2.new(minX,maxY)
                        entry.lines[4].From=Vector2.new(maxX,minY); entry.lines[4].To=Vector2.new(maxX,maxY)
                        for _,l in pairs(entry.lines) do l.Visible=true end
                    else for _,l in pairs(entry.lines) do l.Visible=false end end
                end
            end
        end
        task.wait()
    end
end)

