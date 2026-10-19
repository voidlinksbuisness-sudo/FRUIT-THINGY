function isPvpTargetDead(char)
    if not char or not char.Parent then return true end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return true end
    return false
end

task.spawn(function()
    local pvpTarget=nil
    while true do
        if S.pvpFarmLoop then
            local char=LocalPlayer.Character
            local myHrp=char and char:FindFirstChild("HumanoidRootPart")
            if myHrp then
                if isPvpTargetDead(pvpTarget) then
                    pvpTarget=nil
                    local nearest, bestDist=nil, math.huge
                    local myName=LocalPlayer.Name
                    local myTeamName=(LocalPlayer.Team and LocalPlayer.Team.Name) or ""
                    local charsFolder=game.Workspace:FindFirstChild("Characters")
                    if charsFolder then
                        for _, c in pairs(charsFolder:GetChildren()) do
                            if c:IsA("Model") and c.Name~=myName then
                                local root=c:FindFirstChild("HumanoidRootPart")
                                local hum=c:FindFirstChildOfClass("Humanoid")
                                if root and hum and hum.Health>0 then
                                    local skip=false
                                    if myTeamName=="Marines" then
                                        local tp=Players:FindFirstChild(c.Name)
                                        if tp and tp.Team and tp.Team.Name=="Marines" then skip=true end
                                    end
                                    if not skip then
                                        local dx=root.Position.X-myHrp.Position.X
                                        local dy=root.Position.Y-myHrp.Position.Y
                                        local dz=root.Position.Z-myHrp.Position.Z
                                        local d=math.sqrt(dx*dx+dy*dy+dz*dz)
                                        if d<bestDist then bestDist=d; nearest=c end
                                    end
                                end
                            end
                        end
                    end
                    if nearest then pvpTarget=nearest end
                end
                if pvpTarget and not isPvpTargetDead(pvpTarget) then
                    local enemyRoot=pvpTarget:FindFirstChild("HumanoidRootPart")
                    if enemyRoot then
                        task.spawn(function()
                            while S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) do
                                local eh=pvpTarget:FindFirstChild("HumanoidRootPart")
                                local hd=pvpTarget:FindFirstChild("Head")
                                if eh then eh.CanCollide=false end
                                if hd then hd.CanCollide=false end
                                task.wait()
                            end
                        end)
                        local startX=myHrp.Position.X; local startY=myHrp.Position.Y; local startZ=myHrp.Position.Z
                        local tx=enemyRoot.Position.X+20; local ty=enemyRoot.Position.Y; local tz=enemyRoot.Position.Z
                        local dx=tx-startX; local dy=ty-startY; local dz=tz-startZ
                        local duration=math.sqrt(dx*dx+dy*dy+dz*dz)/320; local t0=os.clock()
                        while S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) do
                            local alpha=math.min((os.clock()-t0)/duration,1)
                            myHrp.CFrame=CFrame.new(startX+dx*alpha,startY+dy*alpha,startZ+dz*alpha)
                            if alpha>=1 then break end; task.wait(0.01)
                        end
                        local lastClick=0
                        local attackStart=os.clock()
                        while os.clock()-attackStart<2 and S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) do
                            local tr=pvpTarget:FindFirstChild("HumanoidRootPart")
                            if tr then
                                myHrp.Position=Vector3.new(tr.Position.X+20, tr.Position.Y, tr.Position.Z)
                                myHrp.Velocity=Vector3.new(0,0,0); myHrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                            end
                            local now=os.clock()
                            if now-lastClick>=0.06 then mouse1click(); lastClick=now end
                            task.wait()
                        end
                        if S.pvpFarmLoop then
                            local savedX=myHrp.Position.X; local savedZ=myHrp.Position.Z
                            local upStart=os.clock()
                            while os.clock()-upStart<5 and S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) do
                                myHrp.Position=Vector3.new(savedX,10000000,savedZ)
                                myHrp.Velocity=Vector3.new(0,0,0); myHrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                                task.wait(0.1)
                            end
                            local dHrp=pvpTarget:FindFirstChild("HumanoidRootPart")
                            local groundY=dHrp and dHrp.Position and dHrp.Position.Y or 0
                            myHrp.Position=Vector3.new(savedX,groundY,savedZ)
                            myHrp.Velocity=Vector3.new(0,0,0); myHrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                            task.wait(0.2)
                            if S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) then
                                local a2=os.clock()
                                while os.clock()-a2<0.5 and S.pvpFarmLoop and not isPvpTargetDead(pvpTarget) do
                                    local tr2=pvpTarget:FindFirstChild("HumanoidRootPart")
                                    if tr2 then
                                        myHrp.Position=Vector3.new(tr2.Position.X+20,tr2.Position.Y,tr2.Position.Z)
                                        myHrp.Velocity=Vector3.new(0,0,0); myHrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                                    end
                                    local now=os.clock()
                                    if now-lastClick>=0.06 then mouse1click(); lastClick=now end
                                    task.wait()
                                end
                            end
                        end
                    end
                else task.wait(0.5) end
            else task.wait(0.5) end
        else pvpTarget=nil; task.wait(0.5) end
    end
end)

