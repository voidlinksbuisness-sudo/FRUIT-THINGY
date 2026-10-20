-- Keep feature locals out of the shared runtime's top-level register budget.
do
    local entries={}
    local function descendantOfClass(model,className)
        for _,object in pairs(model:GetDescendants()) do
            if object:IsA(className) then return object end
        end
        return nil
    end
    local function live(entry)
        local folder=game.Workspace:FindFirstChild("FireFlowers")
        return folder and entry.model.Parent==folder and entry.part.Parent
    end
    local function nearest(hrp)
        local best,dist=nil,math.huge
        for _,entry in pairs(entries) do
            if live(entry) and (entry.retryAfter or 0)<=os.clock() then
                local p=entry.part.Position
                local dx,dy,dz=p.X-hrp.Position.X,p.Y-hrp.Position.Y,p.Z-hrp.Position.Z
                local d=dx*dx+dy*dy+dz*dz
                if d<dist then best,dist=entry,d end
            end
        end
        return best
    end
    local function active(hrp)
        return S.autoFireFlowers and not farmPriorityBlocked(true)
            and LocalPlayer.Character and hrp.Parent==LocalPlayer.Character
    end
    task.spawn(function()
        while true do
            pcall(function()
                local seen={}
                if S.autoFireFlowers or S.fireFlowerEsp then
                    local folder=game.Workspace:FindFirstChild("FireFlowers")
                    for _,model in pairs(folder and folder:GetChildren() or {}) do
                        if model:IsA("Model") then
                            local key=trackedInstanceKey(model)
                            local part=model.PrimaryPart or descendantOfClass(model,"BasePart")
                            if part then
                                seen[key]=true
                                entries[key]=entries[key] or {}
                                entries[key].model,entries[key].part=model,part
                            end
                        end
                    end
                end
                for key,entry in pairs(entries) do
                    if not seen[key] then
                        if entry.label then entry.label:Remove() end
                        entries[key]=nil
                    end
                end
            end)
            task.wait(0.25)
        end
    end)
    task.spawn(function()
        while true do
            local pressedE=false
            pcall(function()
                local char=LocalPlayer.Character
                local hrp=char and char:FindFirstChild("HumanoidRootPart")
                if not hrp or not active(hrp) then return end
                local entry=nearest(hrp)
                if entry then
                    local p=entry.part.Position
                    tweenTo(hrp,Vector3.new(p.X,p.Y+2,p.Z),S.FRUIT_SPEED,function()
                        return active(hrp) and live(entry)
                    end)
                    local started=os.clock()
                    while active(hrp) and live(entry) and os.clock()-started<6 do
                        local p=entry.part.Position
                        local dx,dy,dz=p.X-hrp.Position.X,p.Y-hrp.Position.Y,p.Z-hrp.Position.Z
                        if dx*dx+dy*dy+dz*dz>64 then break end
                        hrp.Velocity=Vector3.new(0,0,0)
                        hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                        local hold=0.3
                        pcall(function()
                            local prompt=descendantOfClass(entry.model,"ProximityPrompt")
                            if prompt then hold=math.min(math.max(prompt.HoldDuration+0.1,0.15),5) end
                        end)
                        setrobloxinput(true)
                        pressedE=true
                        keypress(0x45)
                        local pressed=os.clock()
                        while active(hrp) and live(entry) and os.clock()-pressed<hold do task.wait(0.05) end
                        keyrelease(0x45)
                        pressedE=false
                        task.wait(0.15)
                    end
                    if live(entry) then entry.retryAfter=os.clock()+5 end
                else
                    local useRemote=S.remoteMode
                    farmAttack(hrp,function()
                        return active(hrp) and S.remoteMode==useRemote and not nearest(hrp)
                    end,nil,true,1000,useRemote and remoteAttack or nil,useRemote and 0.05 or 0.06)
                end
            end)
            if pressedE then pcall(function() keyrelease(0x45) end) end
            task.wait(0.1)
        end
    end)
    task.spawn(function()
        while true do
            for _,entry in pairs(entries) do
                pcall(function()
                    local visible=false
                    if S.fireFlowerEsp and live(entry) then
                        local char=LocalPlayer.Character
                        local hrp=char and char:FindFirstChild("HumanoidRootPart")
                        local p=entry.part.Position
                        local screen,onScreen=WorldToScreen(p)
                        if hrp and screen and onScreen then
                            if not entry.label then
                                local label=Drawing.new("Text")
                                label.Size=16; label.Center=true; label.Outline=true
                                label.Font=Drawing.Fonts.Monospace
                                label.Color=Color3.fromRGB(255,120,35)
                                entry.label=label
                            end
                            local dx,dy,dz=p.X-hrp.Position.X,p.Y-hrp.Position.Y,p.Z-hrp.Position.Z
                            entry.label.Text="Fire Flower ["..math.floor(math.sqrt(dx*dx+dy*dy+dz*dz)).." studs]"
                            entry.label.Position=Vector2.new(screen.X,screen.Y-20)
                            visible=true
                        end
                    end
                    if entry.label then entry.label.Visible=visible end
                end)
            end
            task.wait(0.05)
        end
    end)
end

