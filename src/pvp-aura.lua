do
    local sessionId = "325bb15e"
    local minDist   = 1
    local regAtk, regHit = nil, nil

    local function pvp_ensureRemotes()
        if regAtk and regHit then return true end
        local net = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
        if net then net = net:FindFirstChild("Net") end
        if not net then return false end
        regAtk = net:FindFirstChild("RE/RegisterAttack")
        regHit = net:FindFirstChild("RE/RegisterHit")
        return regAtk ~= nil and regHit ~= nil
    end

    local function pvp_getTarget()
        local char = LocalPlayer.Character
        if not char then return nil, nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, nil end
        local myPos = hrp.Position
        local closest, closestDist = nil, _pvpAuraMaxDist + 1
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local c = player.Character
            if c then
                local root = c:FindFirstChild("HumanoidRootPart")
                if root then
                    local rootPos=root.Position
                    local dx=rootPos.X-myPos.X
                    local dy=rootPos.Y-myPos.Y
                    local dz=rootPos.Z-myPos.Z
                    local d=math.sqrt(dx*dx+dy*dy+dz*dz)
                    if d < closestDist and d >= minDist then
                        closestDist = d; closest = player
                    end
                end
            end
        end
        if not closest then return nil, nil end
        local tc = closest.Character
        if not tc then return nil, nil end
        local partName = _pvpAuraAltPart and "ModelHitbox" or "Head"
        local part = tc:FindFirstChild(partName) or tc:FindFirstChild("Head")
        if not part or part:IsDescendantOf(LocalPlayer.Character) then return nil, nil end
        return closest, part
    end

    local function pvp_attack(part)
        if not part then return end
        pcall(function() regAtk:FireServer(0.5) end)
        task.wait()
        pcall(function() regHit:FireServer(part, {}, nil, sessionId) end)
    end

    task.spawn(function()
        while true do
            if _pvpAuraEnabled then
                if pvp_ensureRemotes() then
                    local player, part = pvp_getTarget()
                    pvp_attack(part)
                end
                task.wait(0.05)
            else
                task.wait(0.1)
            end
        end
    end)
end

