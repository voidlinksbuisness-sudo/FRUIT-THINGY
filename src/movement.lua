local TWEEN_STEP_TIME=0.01

function tweenTo(hrp, targetPos, speed, checkFn)
    if not hrp or not targetPos then return end
    local okStart,startPos=pcall(function() return hrp.Position end)
    if not okStart or not startPos then return end
    local rotationCF=nil
    pcall(function()
        local rx,ry,rz=hrp.CFrame:ToEulerAnglesXYZ()
        rotationCF=CFrame.Angles(rx,ry,rz)
    end)
    local dx=targetPos.X-startPos.X; local dy=targetPos.Y-startPos.Y; local dz=targetPos.Z-startPos.Z
    local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
    if distance<=1 then

        pcall(function()
            local positionCF=CFrame.new(targetPos.X,targetPos.Y,targetPos.Z)
            hrp.CFrame=rotationCF and (positionCF*rotationCF) or positionCF
        end)
        return
    end
    local moveSpeed=tonumber(speed) or 320
    if moveSpeed<=0 then moveSpeed=320 end
    local duration=distance/moveSpeed; local startTime=os.clock()
    while true do
        if checkFn and not checkFn() then return end
        local okParent,parent=pcall(function() return hrp.Parent end)
        if not okParent or not parent then return end
        local alpha=math.min((os.clock()-startTime)/duration,1)
        local newX=startPos.X+dx*alpha
        local newY=startPos.Y+dy*alpha
        local newZ=startPos.Z+dz*alpha
        local okMove=pcall(function()
            local positionCF=CFrame.new(newX,newY,newZ)
            hrp.CFrame=rotationCF and (positionCF*rotationCF) or positionCF
        end)
        if not okMove then return end
        if alpha>=1 then break end
        task.wait(TWEEN_STEP_TIME)
    end
end

