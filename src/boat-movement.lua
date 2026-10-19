function getBoat()
    local char=LocalPlayer.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local boatsFolder=game.Workspace:FindFirstChild("Boats")
    if not boatsFolder then return nil end
    for _, b in pairs(boatsFolder:GetChildren()) do
        if b:IsA("Model") then
            local seat=b:FindFirstChildOfClass("VehicleSeat")
            if seat then
                local dx=seat.Position.X-hrp.Position.X
                local dy=seat.Position.Y-hrp.Position.Y
                local dz=seat.Position.Z-hrp.Position.Z
                if math.sqrt(dx*dx+dy*dy+dz*dz)<20 then return b end
            end
        end
    end
    return nil
end

function getBoatCameraVectors()
    local char=LocalPlayer.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return Vector3.new(0,0,-1), Vector3.new(1,0,0) end
    local cp=game.Workspace.CurrentCamera.Position
    local hp=hrp.Position
    local fx=hp.X-cp.X; local fz=hp.Z-cp.Z
    local fl=math.sqrt(fx*fx+fz*fz)
    if fl>0.001 then fx=fx/fl; fz=fz/fl else fx=0; fz=-1 end
    return Vector3.new(fx,0,fz), Vector3.new(-fz,0,fx)
end

function boatTweenTo(targetPos)
    S.currentBoat = getBoat()
    if not S.currentBoat then notify("No boat found!","Boat Fly",2); return end
    local primary=S.currentBoat.PrimaryPart
    if not primary then return end
    S.boatTweening=true
    primary.Position=Vector3.new(primary.Position.X, primary.Position.Y+50, primary.Position.Z)
    wait(0.1)
    local fixedY=primary.Position.Y
    local startX=primary.Position.X; local startZ=primary.Position.Z
    local dx=targetPos.X-startX; local dz=targetPos.Z-startZ
    local dist=math.sqrt(dx*dx+dz*dz)
    local duration=dist/S.BOAT_TWEEN_SPEED
    local t0=os.clock()
    while S.boatTweening do
        local alpha=math.min((os.clock()-t0)/duration,1)
        primary.Position=Vector3.new(startX+dx*alpha, fixedY, startZ+dz*alpha)
        primary.Velocity=Vector3.new(0,0,0)
        primary.AssemblyLinearVelocity=Vector3.new(0,0,0)
        if alpha>=1 then break end
        wait(0.01)
    end
    S.boatTweening=false; S.currentBoat=nil; S.boatTween=nil
    notify("Arrived!","Boat Fly",2)
end

task.spawn(function()
    while true do
        task.wait()
        if not S.boatFlyEnabled or S.boatTweening then continue end
        local boat=getBoat(); if not boat then continue end
        local primary=boat.PrimaryPart; if not primary then continue end
        local fwd, right=getBoatCameraVectors()
        local mx, my, mz=0,0,0
        if iskeypressed(0x57,0) then mx=mx+fwd.X*S.boatFlySpeed;   mz=mz+fwd.Z*S.boatFlySpeed   end
        if iskeypressed(0x53,0) then mx=mx-fwd.X*S.boatFlySpeed;   mz=mz-fwd.Z*S.boatFlySpeed   end
        if iskeypressed(0x44,0) then mx=mx+right.X*S.boatFlySpeed; mz=mz+right.Z*S.boatFlySpeed end
        if iskeypressed(0x41,0) then mx=mx-right.X*S.boatFlySpeed; mz=mz-right.Z*S.boatFlySpeed end
        if iskeypressed(0x58,0) then my=my+S.boatFlySpeed end
        if iskeypressed(0x10,0) then my=my-S.boatFlySpeed end
        primary.Velocity=Vector3.new(0,0,0)
        primary.AssemblyLinearVelocity=Vector3.new(0,0,0)
        primary.Position=Vector3.new(primary.Position.X+mx, primary.Position.Y+my, primary.Position.Z+mz)
    end
end)

