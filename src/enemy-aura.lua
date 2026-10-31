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
        lastNotice    = -math.huge,
    }

    local function aura_ensureRemotes()
        -- Resolve fresh handles each tick; respawns/updates can replace Net.
        aura.regAtk,aura.regHit=nil,nil
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
        local folder = game.Workspace:FindFirstChild("Enemies")
        if not folder then return {} end
        local results = {}
        for _, enemy in ipairs(folder:GetChildren()) do
            pcall(function()
            if enemy and enemy.Parent then
                local hum = enemy:FindFirstChildOfClass("Humanoid")
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
            end)
        end
        return results
    end

    local function aura_attack(list)
        if not aura.enabled or #list == 0 then return true end
        local hitTable = {}
        local primary = nil
        for _, entry in ipairs(list) do
            pcall(function()
                local hum=entry.enemy and entry.enemy:FindFirstChildOfClass("Humanoid")
                if entry.enemy and entry.enemy.Parent and hum and hum.Health>0 and entry.part and entry.part.Parent then
                    table.insert(hitTable, {entry.enemy, entry.part})
                    if not primary then primary = entry.part end
                end
            end)
        end
        if #hitTable == 0 then return true end
        local ok,err=pcall(function() aura.regAtk:FireServer(0.5) end)
        if not ok then return false,err end
        task.wait()
        if not aura.enabled then return true end
        -- NPCs may despawn while RegisterAttack yields.
        local survivors={}
        for _,entry in ipairs(hitTable) do
            pcall(function()
                local hum=entry[1]:FindFirstChildOfClass("Humanoid")
                if entry[1].Parent and entry[2].Parent and hum and hum.Health>0 then
                    survivors[#survivors+1]=entry
                end
            end)
        end
        if #survivors==0 then return true end
        return pcall(function() aura.regHit:FireServer(survivors[1][2], survivors, nil, aura.sessionId) end)
    end

    mainTab:AddSection("NPC Aura", { Column = 1 })
    mainTab:AddToggle("npc_aura", {
        Text="NPC Aura", Description="Fires RegisterHit on all NPCs within range. MATCHA PRO ONLY!",
        Default=false, Keybind=true, Column=1,
        Callback=function(v)
            aura.enabled = v
            aura.lastNotice=-math.huge
            notify(v and "NPC Aura ON!" or "NPC Aura OFF!", "laced.club", 2)
        end
    })
    mainTab:AddSlider("npc_aura_range", {
        Text="Aura Range", Description="Max distance to hit NPCs (studs)",
        Min=10, Max=300, Default=100, Integer=true, Column=1,
        Callback=function(v) aura.maxDist = v end
    })

    local function aura_notice(message)
        if os.clock()-aura.lastNotice<5 then return end
        aura.lastNotice=os.clock()
        warn("NPC Aura: "..tostring(message))
        notify(tostring(message),"NPC Aura",3)
    end
    local function aura_tick()
        if not aura.enabled then return end
        if not aura_ensureRemotes() then
            aura_notice("Combat remotes not found. Waiting for the game to load.")
            return
        end
        local enemies=aura_getEnemies()
        aura.targetCount=#enemies
        if #enemies==0 then
            aura.firstName="None"
            aura_notice("No living NPCs in aura range.")
            return
        end
        table.sort(enemies,function(a,b) return a.dist<b.dist end)
        aura.firstName=enemies[1].enemy.Name or "Unknown"
        local ok,err=aura_attack(enemies)
        if not ok then
            aura.regAtk,aura.regHit=nil,nil
            aura_notice("Attack failed (requires Matcha Pro): "..tostring(err))
        end
    end
    task.spawn(function()
        while true do
            local ok,err=pcall(aura_tick)
            if not ok then
                aura.regAtk,aura.regHit=nil,nil
                pcall(aura_notice,"Recovering after error: "..tostring(err))
            end
            task.wait(aura.enabled and 0.05 or 0.1)
        end
    end)
end

