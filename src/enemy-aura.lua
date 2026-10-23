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
        lastControl   = -math.huge,
        controlEnabled = false,
    }

    local function aura_controlTool()
        local characters=game.Workspace:FindFirstChild("Characters")
        local character=characters and characters:FindFirstChild(LocalPlayer.Name)
        if not character then character=LocalPlayer.Character end
        return character and character:FindFirstChild("Control-Control")
    end

    local function aura_controlAttack(list,tool)
        if not aura.enabled or not aura.controlEnabled or not tool or #list==0 then return end
        if os.clock()-aura.lastControl<0.15 then return end
        local char=LocalPlayer.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local leftClick=tool:FindFirstChild("LeftClickRemote")
        local remote=tool:FindFirstChild("RemoteEvent")
        -- Never send the standalone true call that blocked manual M1.
        if not hrp or not leftClick or not remote then return end
        local nearest,best=nil,math.huge
        for _,entry in ipairs(list) do
            local hum=entry.enemy and entry.enemy:FindFirstChildOfClass("Humanoid")
            if entry.enemy and entry.enemy.Parent and hum and hum.Health>0
                and entry.part and entry.part.Parent then
                local pos=entry.part.Position
                local dx,dy,dz=pos.X-hrp.Position.X,pos.Y-hrp.Position.Y,pos.Z-hrp.Position.Z
                local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
                if distance>=aura.minDist and distance<=aura.maxDist and distance<best then
                    nearest,best=Vector3.new(dx/distance,dy/distance,dz/distance),distance
                end
            end
        end
        if not nearest then return end
        aura.lastControl=os.clock()
        local ok=pcall(function() leftClick:FireServer(nearest,1,true) end)
        if ok and aura.enabled and aura.controlEnabled then
            pcall(function() remote:FireServer(true) end)
        end
    end

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
        if not aura.enabled or #list == 0 then return end
        local tool=aura.controlEnabled and aura_controlTool()
        if tool then aura_controlAttack(list,tool); return end
        if not aura_ensureRemotes() then return end
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
        if not aura.enabled then return end
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
    mainTab:AddToggle("npc_aura_control", {
        Text="Control M1 Support", Description="Uses the Control remote sequence toward the nearest NPC while NPC Aura is on",
        Default=false,Column=1,
        Callback=function(v) aura.controlEnabled=v; aura.lastControl=-math.huge end
    })
    mainTab:AddSlider("npc_aura_range", {
        Text="Aura Range", Description="Max distance to hit NPCs (studs)",
        Min=10, Max=300, Default=100, Integer=true, Column=1,
        Callback=function(v) aura.maxDist = v end
    })

    task.spawn(function()
        while true do
            if aura.enabled then
                do
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

