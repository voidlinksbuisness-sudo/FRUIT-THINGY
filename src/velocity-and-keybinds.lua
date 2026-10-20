function runVelocityBoost(settings,enabledFn,horizontalOnly,lockedDirection)
    if not settings then return end
    task.wait(settings.delay)
    if not enabledFn() then return end

    local char=LocalPlayer and LocalPlayer.Character or nil
    local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
    if not hrp then return end

    local direction=lockedDirection
    if not direction then
        pcall(function()
            local velocity=hrp.AssemblyLinearVelocity
            if not velocity then return end
            local dx,dy,dz=velocity.X,velocity.Y,velocity.Z
            if horizontalOnly then dy=0 end
            local magnitude=math.sqrt(dx*dx+dy*dy+dz*dz)
            if magnitude>0.1 then
                direction=Vector3.new(dx/magnitude,dy/magnitude,dz/magnitude)
            end
        end)
    end
    if not direction then return end

    local endTime=os.clock()+settings.duration
    while os.clock()<endTime and enabledFn() do
        local currentChar=LocalPlayer and LocalPlayer.Character or nil
        local currentHrp=currentChar and currentChar:FindFirstChild("HumanoidRootPart") or nil
        if not currentHrp then return end
        pcall(function()
            currentHrp.AssemblyLinearVelocity=Vector3.new(
                direction.X*settings.speed,
                horizontalOnly and 0 or direction.Y*settings.speed,
                direction.Z*settings.speed
            )
        end)
        task.wait()
    end
end

task.spawn(function()
    local wasZFire=false
    local boosting=false
    while true do
        local char=LocalPlayer and LocalPlayer.Character or nil
        local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
        local zFire=hrp and hrp:FindFirstChild("SanguineArtZFire")~=nil or false
        if S.sanguineZBoost and zFire and not wasZFire and not boosting then
            boosting=true
            task.spawn(function()
                runVelocityBoost(S.glitchSettings.sanguine,function() return S.sanguineZBoost end)
                boosting=false
            end)
        end
        wasZFire=zFire
        task.wait()
    end
end)

task.spawn(function()
    local holdingZ=false
    local boosting=false
    while true do
        local pressed=iskeypressed(0x5A)
        if S.dragonTalonZBoost and pressed and not holdingZ then
            holdingZ=true
            if not boosting then
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    if char and char:FindFirstChild("Dragon Talon") then
                        runVelocityBoost(S.glitchSettings.dragonTalon,function() return S.dragonTalonZBoost end)
                    end
                    boosting=false
                end)
            end
        elseif not pressed then
            holdingZ=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingZ=false
    local boosting=false
    while true do
        local pressed=iskeypressed(0x5A)
        if S.yamaZBoost and pressed and not holdingZ then
            holdingZ=true
            if not boosting then
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    if char and char:FindFirstChild("Yama") then
                        runVelocityBoost(S.glitchSettings.yama,function() return S.yamaZBoost end)
                    end
                    boosting=false
                end)
            end
        elseif not pressed then
            holdingZ=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingX=false
    local boosting=false
    while true do
        local pressed=iskeypressed(0x58)
        if S.tushitaXBoost and pressed and not holdingX then
            holdingX=true
            if not boosting then
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    if char and char:FindFirstChild("Tushita") then
                        runVelocityBoost(S.glitchSettings.tushita,function() return S.tushitaXBoost end)
                    end
                    boosting=false
                end)
            end
        elseif not pressed then
            holdingX=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingX=false
    local boosting=false
    while true do
        local pressed=iskeypressed(0x58)
        if S.foxLampXBoost and pressed and not holdingX then
            holdingX=true
            if not boosting then
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    if char and char:FindFirstChild("Fox Lamp") then
                        runVelocityBoost(S.glitchSettings.foxLamp,function() return S.foxLampXBoost end)
                    end
                    boosting=false
                end)
            end
        elseif not pressed then
            holdingX=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local wasQPressed=false
    local wasM1Pressed=false
    local lastQPress=nil
    local lastM1Press=nil
    local boosting=false
    while true do
        local qPressed=iskeypressed(0x51)
        local m1Pressed=ismouse1pressed()
        local now=os.clock()

        if S.soulGuitarM1Boost then
            if qPressed and not wasQPressed then lastQPress=now end
            if m1Pressed and not wasM1Pressed then lastM1Press=now end

            if not boosting and lastQPress and lastM1Press and math.abs(lastQPress-lastM1Press)<=0.5 then
                lastQPress=nil
                lastM1Press=nil
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    local hasGuitar=char and (
                        char:FindFirstChild("Skull Guitar") or
                        char:FindFirstChild("Soul Guitar")
                    )
                    if hasGuitar then
                        runVelocityBoost(S.glitchSettings.soulGuitar,function() return S.soulGuitarM1Boost end,true)
                    end
                    boosting=false
                end)
            end
        else
            lastQPress=nil
            lastM1Press=nil
        end

        wasQPressed=qPressed
        wasM1Pressed=m1Pressed
        task.wait()
    end
end)

task.spawn(function()
    local wasM1Pressed=false
    local boosting=false
    while true do
        local m1Pressed=ismouse1pressed()
        if S.diamondM1Boost and not m1Pressed and wasM1Pressed and not boosting then
            boosting=true
            task.spawn(function()
                local char=LocalPlayer and LocalPlayer.Character or nil
                if char and char:FindFirstChild("Diamond-Diamond") then
                    runVelocityBoost(S.glitchSettings.diamond,function()
                        return S.diamondM1Boost
                    end)
                end
                boosting=false
            end)
        end
        wasM1Pressed=m1Pressed
        task.wait()
    end
end)

task.spawn(function()
    local holdingF=false
    local boosting=false
    while true do
        local pressed=iskeypressed(0x46)
        if S.flameFBoost and pressed and not holdingF then
            holdingF=true
            if not boosting then
                boosting=true
                task.spawn(function()
                    local char=LocalPlayer and LocalPlayer.Character or nil
                    if char and char:FindFirstChild("Flame-Flame") then
                        runVelocityBoost(S.glitchSettings.flame,function() return S.flameFBoost end)
                    end
                    boosting=false
                end)
            end
        elseif not pressed then
            holdingF=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingR=false
    while true do
        local rPressed=iskeypressed(0x52)
        if S.rToX and rPressed and not holdingR then
            holdingR=true
            local char=LocalPlayer and LocalPlayer.Character or nil
            local portal=char and char:FindFirstChild("Portal-Portal") or nil
            if portal then
                task.spawn(function()
                    pcall(function()
                        setrobloxinput(true)
                        keyrelease(0x58)
                        task.wait(0.02)
                        keypress(0x58)
                        task.wait(0.08)
                        keyrelease(0x58)
                    end)
                end)
            end
        elseif not rPressed then
            holdingR=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingR=false
    while true do
        local rPressed=iskeypressed(0x52)
        if S.rToXThenZ and rPressed and not holdingR then
            holdingR=true
            local char=LocalPlayer and LocalPlayer.Character or nil
            local portal=char and char:FindFirstChild("Portal-Portal") or nil
            if portal then
                task.spawn(function()
                    pcall(function()
                        setrobloxinput(true)
                        keyrelease(0x58)
                        task.wait(0.02)
                        keypress(0x58)
                        task.wait(0.08)
                        keyrelease(0x58)
                        task.wait(0.025)
                        keyrelease(0x5A)
                        task.wait(0.02)
                        keypress(0x5A)
                        task.wait(0.08)
                        keyrelease(0x5A)
                    end)
                end)
            end
        elseif not rPressed then
            holdingR=false
        end
        task.wait()
    end
end)

task.spawn(function()
    local holdingR=false
    while true do
        local rPressed=false
        local okKey, keyState=pcall(function() return iskeypressed(0x52) end)
        if okKey and keyState==true then rPressed=true end

        if S.flameRToC and rPressed and not holdingR then
            holdingR=true

            local char=nil
            local okChar, charValue=pcall(function()
                return LocalPlayer and LocalPlayer.Character or nil
            end)
            if okChar then char=charValue end

            local flame=nil
            if char then
                local okFlame, flameValue=pcall(function()
                    return char:FindFirstChild("Flame-Flame")
                end)
                if okFlame then flame=flameValue end
            end

            local isTool=false
            if flame then
                local okClass, className=pcall(function() return flame.ClassName end)
                isTool=okClass and className=="Tool"
            end

            if isTool then
                task.spawn(function()
                    pcall(function()
                        setrobloxinput(true)
                        keyrelease(0x43)
                        keypress(0x43)
                        task.wait(0.08)
                        keyrelease(0x43)
                    end)
                end)
            end
        elseif not rPressed then
            holdingR=false
        end
        task.wait()
    end
end)


-- Auto V4 uses a scheduled tap, never a held key.
task.spawn(function()
    while true do
        if S.autoV4 and os.clock() >= S.autoV4NextPress then
            S.autoV4NextPress = os.clock() + 5
            pcall(function() setrobloxinput(true) end)
            pcall(function() keypress(0x59) end)
            task.wait(0.05)
            -- Always release, including when disabled during the tap.
            pcall(function() keyrelease(0x59) end)
        end
        task.wait(0.05)
    end
end)

