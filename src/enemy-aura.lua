do
    local aura = {
        enabled       = false,
        maxDist       = 100,
        minDist       = 1,
        sessionId     = "32501259",
        targetCount   = 0,
        firstName     = "None",
        regAtk        = nil,
        regHit        = nil,
    }

    local function aura_ensureRemotes()
        if aura.regAtk and aura.regHit then return true end
        local net = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
        if net then net = net:FindFirstChild("Net") end
        if not net then return false end
        aura.regAtk = net:FindFirstChild("RE/RegisterAttack")
        aura.regHit = net:FindFirstChild("RE/RegisterHit")
        return aura.regAtk ~= nil and aura.regHit ~= nil
    end

    local function aura_getTargetPart(enemy)
        if not enemy or not enemy.Parent then return nil end
        local p = enemy:FindFirstChild("LeftLowerLeg")
        if p and p:IsA("BasePart") then return p end
        p = enemy:FindFirstChild("Head")
        if p and p:IsA("BasePart") then return p end
        p = enemy:FindFirstChild("HumanoidRootPart")
        if p and p:IsA("BasePart") then return p end
        for _, c in ipairs(enemy:GetChildren()) do
            if c:IsA("BasePart") then return c end
        end
        return nil
    end

    local function aura_getEnemies()
        local char = LocalPlayer.Character
        if not char then return {} end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return {} end
        local myPos = hrp.Position
        local folder = workspace:FindFirstChild("Enemies")
        if not folder then return {} end
        local results = {}
        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy and enemy.Parent then
                local hum = enemy:FindFirstChild("Humanoid")
                if hum and hum.Health and hum.Health > 0 then
                    local part = aura_getTargetPart(enemy)
                    if part and part.Parent then
                        local ok, pos = pcall(function() return part.Position end)
                        if ok and pos then
                            local dx=pos.X-myPos.X
                            local dy=pos.Y-myPos.Y
                            local dz=pos.Z-myPos.Z
                            local d=math.sqrt(dx*dx+dy*dy+dz*dz)
                            if d <= aura.maxDist and d >= aura.minDist then
                                table.insert(results, {enemy=enemy, part=part, dist=d})
                            end
                        end
                    end
                end
            end
        end
        return results
    end

    local function aura_attack(list)
        if #list == 0 then return end
        local hitTable = {}
        local primary = nil
        for _, entry in ipairs(list) do
            if entry.enemy and entry.enemy.Parent and entry.part and entry.part.Parent then
                table.insert(hitTable, {entry.enemy, entry.part})
                if not primary then primary = entry.part end
            end
        end
        if #hitTable == 0 then return end
        pcall(function() aura.regAtk:FireServer(0.5) end)
        task.wait()
        pcall(function() aura.regHit:FireServer(primary, hitTable, nil, aura.sessionId) end)
    end

    mainTab:AddSection("NPC Aura", { Column = 1 })
    mainTab:AddToggle("npc_aura", {
        Text="NPC Aura", Description="Fires RegisterHit on all NPCs within range. MATCHA PRO ONLY!",
        Default=false, Keybind=true, Column=1,
        Callback=function(v)
            aura.enabled = v
            aura_ensureRemotes()
            notify(v and "NPC Aura ON!" or "NPC Aura OFF!", "laced.club", 2)
        end
    })
    mainTab:AddSlider("npc_aura_range", {
        Text="Aura Range", Description="Max distance to hit NPCs (studs)",
        Min=10, Max=300, Default=100, Integer=true, Column=1,
        Callback=function(v) aura.maxDist = v end
    })

    task.spawn(function()
        while true do
            if aura.enabled then
                if aura_ensureRemotes() then
                    local enemies = aura_getEnemies()
                    aura.targetCount = #enemies
                    if aura.targetCount > 0 then
                        table.sort(enemies, function(a,b) return a.dist < b.dist end)
                        aura.firstName = enemies[1].enemy.Name or "Unknown"
                    else
                        aura.firstName = "None"
                    end
                    aura_attack(enemies)
                end
                task.wait(0.05)
            else
                task.wait(0.1)
            end
        end
    end)
end

