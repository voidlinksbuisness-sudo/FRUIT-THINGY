local MATERIAL_ENEMIES={
    ["Leather + Scrap Metal"]={"Pirate","Brute","Gladiator","Mercenary","Swan Pirate","Marine Captain","Jungle Pirate","Forest Pirate"},
    ["Angel Wings"]={"God's Guard","Shanda","Royal Squad","Royal Soldier"},
    ["Magma Ore"]={"Military Soldier","Military Spy","Magma Ninja","Lava Pirate"},
    ["Fish Tail"]={"Fishman Warrior","Fishman Commando","Fishman Raider","Fishman Captain"},
    ["Radioactive Material"]={"Factory Staff"},
    ["Ectoplasm"]={"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Cursed Captain"},
    ["Mystic Droplet"]={"Sea Soldier","Water Fighter"},
    ["Vampire Fang"]={"Vampire"},
    ["Demonic Wisp"]={"Demonic Soul"},
    ["Conjured Cocoa"]={"Cocoa Warrior","Chocolate Bar Battler","Sweet Thief","Candy Rebel"},
    ["Dragon Scale"]={"Dragon Crew Warrior","Dragon Crew Archer"},
    ["Gunpowder"]={"Pistol Billionaire"},
    ["Mini Tusk"]={"Mythological Pirate"}
}

local function materialWaitPosition(material)
    local sea=AFL.currentSea
    if material=="Angel Wings" then return AFL.waitPositions.SkyIsland3 end
    if material=="Radioactive Material" then return AFL.waitPositions.Factory2 end
    if material=="Ectoplasm" then return AFL.waitPositions.HauntedShip2 end
    if material=="Mystic Droplet" then return AFL.waitPositions.Wano2 end
    if material=="Vampire Fang" then return AFL.waitPositions.Graveyard2 end
    if material=="Demonic Wisp" then return AFL.waitPositions.HauntedCastle2 end
    if material=="Conjured Cocoa" then return AFL.waitPositions.Chocolate2 end
    if material=="Dragon Scale" then return AFL.waitPositions.Hydra2 end
    if material=="Gunpowder" then return AFL.waitPositions.Port2 end
    if material=="Mini Tusk" then return AFL.waitPositions.TurtleCenter1 end
    if material=="Magma Ore" then return sea==1 and AFL.waitPositions.MagmaIsland2 or AFL.waitPositions.HotSide2 end
    if material=="Fish Tail" then return sea==1 and AFL.waitPositions.UnderWaterIsland2 or AFL.waitPositions.Tiki2Quest1 end
    if material=="Leather + Scrap Metal" then
        if sea==1 then return AFL.waitPositions.PirateVillage2 end
        if sea==2 then return AFL.waitPositions.RoseKingdom2 end
        return AFL.waitPositions.TurtleEntrance2
    end
    return nil
end

local enhancedComm=nil
local function getEnhancedComm()
    if enhancedComm then
        local okParent,parent=pcall(function() return enhancedComm.Parent end)
        if okParent and parent then return enhancedComm end
        enhancedComm=nil
    end
    local storage=game:GetService("ReplicatedStorage")
    local remotes=storage and storage:FindFirstChild("Remotes")
    enhancedComm=remotes and remotes:FindFirstChild("CommF_") or nil
    if not enhancedComm and storage then
        local okDescendants,descendants=pcall(function() return storage:GetDescendants() end)
        if okDescendants and descendants then
            for _,object in pairs(descendants) do
                local okName,name=pcall(function() return object.Name end)
                if okName and name=="CommF_" then enhancedComm=object; break end
            end
        end
    end
    return enhancedComm
end

local function invokeEnhancedComm(first,second,third,fourth)
    local remote=getEnhancedComm()
    if not remote then return false,nil,"CommF_ not found" end
    local ok,result=pcall(function()
        if fourth~=nil then return remote:InvokeServer(first,second,third,fourth) end
        if third~=nil then return remote:InvokeServer(first,second,third) end
        if second~=nil then return remote:InvokeServer(first,second) end
        if first~=nil then return remote:InvokeServer(first) end
        return remote:InvokeServer()
    end)
    if not ok then
        enhancedComm=nil
        warn("[Automation] CommF_ failed: "..tostring(result))
        return false,nil,tostring(result)
    end
    return true,result,nil
end

local function nearestMatchingEnemy(hrp,names)
    local folder=game.Workspace:FindFirstChild("Enemies")
    if not folder or not hrp or not names then return nil end
    local allowed={}
    for _,name in ipairs(names) do allowed[name]=true end
    local okPlayer,playerPos=pcall(function() return hrp.Position end)
    if not okPlayer or not playerPos then return nil end
    local best,bestDistance=nil,math.huge
    for _,enemy in pairs(folder:GetChildren()) do
        local okName,name=pcall(function() return enemy.Name end)
        if okName and allowed[name] and isAlive(enemy) then
            local root=enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildOfClass("BasePart")
            local okPos,pos=pcall(function() return root and root.Position end)
            if okPos and pos then
                local dx=pos.X-playerPos.X
                local dy=pos.Y-playerPos.Y
                local dz=pos.Z-playerPos.Z
                local distance=dx*dx+dy*dy+dz*dz
                if distance<bestDistance then best,bestDistance=name,distance end
            end
        end
    end
    return best
end

function showEventStatus()
    local locations=nil
    pcall(function()
        local origin=game.Workspace:FindFirstChild("_WorldOrigin")
        locations=origin and origin:FindFirstChild("Locations") or nil
    end)
    local map=game.Workspace:FindFirstChild("Map")
    local mirage=locations and locations:FindFirstChild("Mirage Island")
    local prehistoric=locations and locations:FindFirstChild("Prehistoric Island")
    local frozen=locations and locations:FindFirstChild("Frozen Dimension")
    local kitsune=map and map:FindFirstChild("KitsuneIsland")
    local message="Mirage: "..(mirage and "YES" or "NO").." | Kitsune: "..(kitsune and "YES" or "NO").." | Prehistoric: "..(prehistoric and "YES" or "NO").." | Frozen: "..(frozen and "YES" or "NO")
    print("[World Status] "..message)
    notify(message,"World Status",8)
end

function showBossStatus()
    local storage=game:GetService("ReplicatedStorage")
    local enemies=game.Workspace:FindFirstChild("Enemies")
    local function present(name,alternate)
        return (enemies and (enemies:FindFirstChild(name) or (alternate and enemies:FindFirstChild(alternate)))) or storage:FindFirstChild(name) or (alternate and storage:FindFirstChild(alternate))
    end
    local message="Rip Indra: "..(present("rip_indra True Form","rip_indra") and "YES" or "NO").." | Dough King: "..(present("Dough King") and "YES" or "NO").." | Cake Prince: "..(present("Cake Prince") and "YES" or "NO")
    print("[Boss Status] "..message)
    notify(message,"Boss Status",8)
end

function showLegendarySwordStatus()
    local found={}
    for index,name in ipairs({"Shisui","Wando","Saddi"}) do
        local ok,result=invokeEnhancedComm("LegendarySwordDealer",tostring(index))
        if ok and result then table.insert(found,name) end
        task.wait(0.15)
    end
    local message=#found>0 and table.concat(found,", ") or "Not found"
    notify(message,"Legendary Sword Dealer",6)
end

local function safeObjectPosition(object)
    if not object then return nil end
    local okPosition,position=pcall(function() return object.Position end)
    if okPosition and position and position.X and position.Y and position.Z then return position end
    local okPrimary,primary=pcall(function() return object.PrimaryPart end)
    if okPrimary and primary then
        local okPrimaryPosition,primaryPosition=pcall(function() return primary.Position end)
        if okPrimaryPosition and primaryPosition then return primaryPosition end
    end
    local okChildren,children=pcall(function() return object:GetDescendants() end)
    if okChildren and children then
        for _,child in pairs(children) do
            local okClass,className=pcall(function() return child.ClassName end)
            if okClass and (className=="Part" or className=="MeshPart" or className=="VehicleSeat") then
                local okChildPosition,childPosition=pcall(function() return child.Position end)
                if okChildPosition and childPosition then return childPosition end
            end
        end
    end
    return nil
end

local function findMirageObject()
    local origin=game.Workspace:FindFirstChild("_WorldOrigin")
    local locations=origin and origin:FindFirstChild("Locations")
    local location=locations and locations:FindFirstChild("Mirage Island")
    if location then return location end
    local map=game.Workspace:FindFirstChild("Map")
    return map and (map:FindFirstChild("MysticIsland") or map:FindFirstChild("Mirage Island")) or nil
end

function clearMirageEsp()
    if S.mirageEspLabel then S.mirageEspLabel.Visible=false end
end

local function updateMirageEsp()
    if not S.mirageEsp then clearMirageEsp(); return end
    if not S.mirageEspLabel then
        local label=Drawing.new("Text")
        label.Text="Mirage Island"
        label.Position=Vector2.new(0,0)
        label.Color=Color3.fromRGB(100,220,255)
        label.Size=22
        label.Center=true
        label.Outline=true
        label.Font=Drawing.Fonts.Monospace
        label.Visible=false
        label.ZIndex=20
        S.mirageEspLabel=label
    end
    local mirage=findMirageObject()
    local position=safeObjectPosition(mirage)
    if not position then clearMirageEsp(); return end
    local okScreen,screen,onScreen=pcall(function() return WorldToScreen(position) end)
    if not okScreen or not screen or onScreen~=true then clearMirageEsp(); return end
    local distanceText=""
    local character=LocalPlayer.Character
    local hrp=character and character:FindFirstChild("HumanoidRootPart")
    local okPlayer,playerPosition=pcall(function() return hrp and hrp.Position end)
    if okPlayer and playerPosition then
        local dx=position.X-playerPosition.X
        local dy=position.Y-playerPosition.Y
        local dz=position.Z-playerPosition.Z
        distanceText=" ["..tostring(math.floor(math.sqrt(dx*dx+dy*dy+dz*dz))).."]"
    end
    S.mirageEspLabel.Text="Mirage Island"..distanceText
    S.mirageEspLabel.Position=screen
    S.mirageEspLabel.Visible=true
end

local function findMirageGear()
    local map=game.Workspace:FindFirstChild("Map")
    local island=map and map:FindFirstChild("MysticIsland")
    if not island then return nil end
    local okChildren,children=pcall(function() return island:GetChildren() end)
    if not okChildren or not children then return nil end
    local character=LocalPlayer.Character
    local hrp=character and character:FindFirstChild("HumanoidRootPart")
    local okPlayer,playerPosition=pcall(function() return hrp and hrp.Position end)
    local nearest,nearestDistance=nil,math.huge
    for _,child in pairs(children) do
        local okInfo,name,className,transparency=pcall(function() return child.Name,child.ClassName,child.Transparency end)
        if okInfo and name=="Part" and className=="MeshPart" and (tonumber(transparency) or 0)<1 then
            local position=safeObjectPosition(child)
            if position then
                local distance=0
                if okPlayer and playerPosition then
                    local dx=position.X-playerPosition.X
                    local dy=position.Y-playerPosition.Y
                    local dz=position.Z-playerPosition.Z
                    distance=dx*dx+dy*dy+dz*dz
                end
                if distance<nearestDistance then nearest,nearestDistance=child,distance end
            end
        end
    end
    return nearest
end

local namedRemoteCache={}
local function findReplicatedObject(name)
    local cached=namedRemoteCache[name]
    if cached then
        local okParent,parent=pcall(function() return cached.Parent end)
        if okParent and parent then return cached end
        namedRemoteCache[name]=nil
    end
    local storage=game:GetService("ReplicatedStorage")
    local direct=storage and storage:FindFirstChild(name)
    if direct then namedRemoteCache[name]=direct; return direct end
    local okDescendants,descendants=pcall(function() return storage:GetDescendants() end)
    if okDescendants and descendants then
        for _,object in pairs(descendants) do
            local okName,objectName=pcall(function() return object.Name end)
            if okName and objectName==name then namedRemoteCache[name]=object; return object end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        updateMirageEsp()
        task.wait(0.05)
    end
end)

task.spawn(function()
    while true do
        if S.autoSeaEvent and not S.fruitPriorityActive and not S.autoMirageTween and not S.autoMirageGear then
            local character=LocalPlayer.Character
            local hrp=character and character:FindFirstChild("HumanoidRootPart")
            local target=S.selectedSeaEvent
            local spawned=hrp and nearestMatchingEnemy(hrp,{target}) or nil
            if hrp and spawned then
                local useRemote=S.remoteMode
                farmAttack(hrp,function()
                    return S.autoSeaEvent and not S.fruitPriorityActive and not S.autoMirageTween and not S.autoMirageGear and S.selectedSeaEvent==target and S.remoteMode==useRemote
                end,target,true,1000000,useRemote and remoteAttack or nil,useRemote and 0.05 or 0.06)
            else
                task.wait(0.25)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoMirageTween and not S.fruitPriorityActive then
            local mirage=findMirageObject()
            local position=safeObjectPosition(mirage)
            local character=LocalPlayer.Character
            local hrp=character and character:FindFirstChild("HumanoidRootPart")
            if position and hrp then
                tweenTo(hrp,Vector3.new(position.X,position.Y+300,position.Z),S.FARM_SPEED,function()
                    return S.autoMirageTween and not S.fruitPriorityActive and findMirageObject()~=nil
                end)
            else
                task.wait(0.35)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoMirageGear and not S.fruitPriorityActive then
            local gear=findMirageGear()
            local position=safeObjectPosition(gear)
            local character=LocalPlayer.Character
            local hrp=character and character:FindFirstChild("HumanoidRootPart")
            if gear and position and hrp then
                tweenTo(hrp,Vector3.new(position.X,position.Y+3,position.Z),S.FARM_SPEED,function()
                    return S.autoMirageGear and not S.fruitPriorityActive and gear.Parent~=nil
                end)
                task.wait(0.2)
            else
                task.wait(0.25)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    local lastAbility=-math.huge
    while true do
        if S.autoRaceAbility and os.clock()-lastAbility>=1 then
            local remote=findReplicatedObject("CommE")
            if remote then pcall(function() remote:FireServer("ActivateAbility") end) end
            lastAbility=os.clock()
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if S.autoBossFarm and not S.fruitPriorityActive and not S.autoSeaEvent and not S.autoMirageTween and not S.autoMirageGear then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            local target=S.selectedBoss
            local spawned=hrp and nearestMatchingEnemy(hrp,{target}) or nil
            if hrp and spawned then
                local useRemote=S.remoteMode
                farmAttack(hrp,function()
                    return S.autoBossFarm and not S.fruitPriorityActive and not S.autoSeaEvent and not S.autoMirageTween and not S.autoMirageGear and S.selectedBoss==target and S.remoteMode==useRemote
                end,target,true,5000,useRemote and remoteAttack or nil,useRemote and 0.05 or 0.06)
            else
                task.wait(0.35)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoMaterialFarm and not S.autoBossFarm and not S.fruitPriorityActive and not S.autoSeaEvent and not S.autoMirageTween and not S.autoMirageGear then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            local material=S.selectedMaterial
            local names=MATERIAL_ENEMIES[material]
            local target=hrp and nearestMatchingEnemy(hrp,names) or nil
            if hrp and target then
                local useRemote=S.remoteMode
                farmAttack(hrp,function()
                    return S.autoMaterialFarm and not S.autoBossFarm and not S.fruitPriorityActive and not S.autoSeaEvent and not S.autoMirageTween and not S.autoMirageGear and S.selectedMaterial==material and S.remoteMode==useRemote
                end,target,true,5000,useRemote and remoteAttack or nil,useRemote and 0.05 or 0.06)
            elseif hrp then
                local waitPos=materialWaitPosition(material)
                if waitPos then
                    tweenTo(hrp,waitPos,S.FARM_SPEED,function()
                        return S.autoMaterialFarm and not S.autoBossFarm and not S.fruitPriorityActive and not S.autoSeaEvent and not S.autoMirageTween and not S.autoMirageGear and S.selectedMaterial==material
                    end)
                end
                task.wait(0.35)
            else
                task.wait(0.35)
            end
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    local statEntries={{"autoStatMelee","Melee"},{"autoStatDefense","Defense"},{"autoStatSword","Sword"},{"autoStatGun","Gun"},{"autoStatFruit","Demon Fruit"}}
    while true do
        for _,entry in ipairs(statEntries) do
            if S[entry[1]] then
                invokeEnhancedComm("AddPoint",entry[2],S.statAmount)
                task.wait(0.12)
            end
        end
        task.wait(0.5)
    end
end)

