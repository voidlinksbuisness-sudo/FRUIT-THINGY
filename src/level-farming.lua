function afl_loadQuestData()
    AFL.questData={}
    if AFL.currentSea==1 then
        AFL.questData.Sea1First={enemy="Trainee",questButton=1,ammountToKill=5}
        AFL.questData.Jungle1={enemy="Monkey",questButton=1,ammountToKill=6}
        AFL.questData.Jungle2={enemy="Gorilla",questButton=2,ammountToKill=8}
        AFL.questData.PirateVillage1={enemy="Pirate",questButton=1,ammountToKill=8}
        AFL.questData.PirateVillage2={enemy="Brute",questButton=2,ammountToKill=8}
        AFL.questData.DesertIsland1={enemy="Desert Bandit",questButton=1,ammountToKill=8}
        AFL.questData.DesertIsland2={enemy="Desert Officer",questButton=2,ammountToKill=6}
        AFL.questData.WinterIsland1={enemy="Snow Bandit",questButton=1,ammountToKill=7}
        AFL.questData.WinterIsland2={enemy="Snowman",questButton=2,ammountToKill=8}
        AFL.questData.MarineFortress={enemy="Chief Petty Officer",questButton=1,ammountToKill=8}
        AFL.questData.SkyIsland1={enemy="Sky Bandit",questButton=1,ammountToKill=7}
        AFL.questData.SkyIsland2={enemy="Dark Master",questButton=2,ammountToKill=8}
        AFL.questData.PrisonIsland1={enemy="Prisoner",questButton=1,ammountToKill=8}
        AFL.questData.PrisonIsland2={enemy="Dangerous Prisoner",questButton=2,ammountToKill=8}
        AFL.questData.ColosseumIsland1={enemy="Toga Warrior",questButton=1,ammountToKill=7}
        AFL.questData.ColosseumIsland2={enemy="Gladiator",questButton=2,ammountToKill=8}
        AFL.questData.MagmaIsland1={enemy="Military Soldier",questButton=1,ammountToKill=7}
        AFL.questData.MagmaIsland2={enemy="Military Spy",questButton=2,ammountToKill=8}
        AFL.questData.UnderWaterIsland1={enemy="Fishman Warrior",questButton=1,ammountToKill=8}
        AFL.questData.UnderWaterIsland2={enemy="Fishman Commando",questButton=2,ammountToKill=7}
        AFL.questData.SkyIsland3={enemy="God's Guard",questButton=1,ammountToKill=7}
        AFL.questData.SkyIsland4={enemy="Shanda",questButton=2,ammountToKill=9}
        AFL.questData.SkyIsland5={enemy="Royal Squad",questButton=1,ammountToKill=8}
        AFL.questData.SkyIsland6={enemy="Royal Soldier",questButton=2,ammountToKill=8}
        AFL.questData.FountainIsland1={enemy="Galley Pirate",questButton=1,ammountToKill=8}
        AFL.questData.FountainIsland2={enemy="Galley Captain",questButton=2,ammountToKill=9}
    elseif AFL.currentSea==2 then
        AFL.questData.RoseKingdom1={enemy="Raider",questButton=1,ammountToKill=8}
        AFL.questData.RoseKingdom2={enemy="Mercenary",questButton=2,ammountToKill=8}
        AFL.questData.Factory1={enemy="Swan Pirate",questButton=1,ammountToKill=8}
        AFL.questData.Factory2={enemy="Factory Staff",questButton=2,ammountToKill=8}
        AFL.questData.GreenZone1={enemy="Marine Lieutenant",questButton=1,ammountToKill=8}
        AFL.questData.GreenZone2={enemy="Marine Captain",questButton=2,ammountToKill=9}
        AFL.questData.Graveyard1={enemy="Zombie",questButton=1,ammountToKill=8}
        AFL.questData.Graveyard2={enemy="Vampire",questButton=2,ammountToKill=8}
        AFL.questData.Snow1={enemy="Snow Trooper",questButton=1,ammountToKill=8}
        AFL.questData.Snow2={enemy="Winter Warrior",questButton=2,ammountToKill=9}
        AFL.questData.ColdSide1={enemy="Lab Subordinate",questButton=1,ammountToKill=8}
        AFL.questData.ColdSide2={enemy="Horned Warrior",questButton=2,ammountToKill=9}
        AFL.questData.HotSide1={enemy="Magma Ninja",questButton=1,ammountToKill=8}
        AFL.questData.HotSide2={enemy="Lava Pirate",questButton=2,ammountToKill=8}
        AFL.questData.HauntedShip1={enemy="Ship Deckhand",questButton=1,ammountToKill=8}
        AFL.questData.HauntedShip2={enemy="Ship Engineer",questButton=2,ammountToKill=8}
        AFL.questData.HauntedShip3={enemy="Ship Steward",questButton=1,ammountToKill=8}
        AFL.questData.HauntedShip4={enemy="Ship Officer",questButton=2,ammountToKill=8}
        AFL.questData.WinterCastle1={enemy="Arctic Warrior",questButton=1,ammountToKill=8}
        AFL.questData.WinterCastle2={enemy="Snow Lurker",questButton=2,ammountToKill=8}
        AFL.questData.Wano1={enemy="Sea Soldier",questButton=1,ammountToKill=8}
        AFL.questData.Wano2={enemy="Water Fighter",questButton=2,ammountToKill=8}
    elseif AFL.currentSea==3 then
        AFL.questData.Port1={enemy="Pirate Millionaire",questButton=1,ammountToKill=8}
        AFL.questData.Port2={enemy="Pistol Billionaire",questButton=2,ammountToKill=8}
        AFL.questData.Hydra1={enemy="Dragon Crew Warrior",questButton=1,ammountToKill=8}
        AFL.questData.Hydra2={enemy="Dragon Crew Archer",questButton=2,ammountToKill=8}
        AFL.questData.Hydra3={enemy="Hydra Enforcer",questButton=1,ammountToKill=8}
        AFL.questData.Hydra4={enemy="Venomous Assailant",questButton=2,ammountToKill=8}
        AFL.questData.GreatTree1={enemy="Marine Commodore",questButton=1,ammountToKill=8}
        AFL.questData.GreatTree2={enemy="Marine Rear Admiral",questButton=2,ammountToKill=8}
        AFL.questData.TurtleEntrance1={enemy="Fishman Raider",questButton=1,ammountToKill=8}
        AFL.questData.TurtleEntrance2={enemy="Fishman Captain",questButton=2,ammountToKill=8}
        AFL.questData.Mansion1={enemy="Forest Pirate",questButton=1,ammountToKill=8}
        AFL.questData.Mansion2={enemy="Mythological Pirate",questButton=2,ammountToKill=8}
        AFL.questData.TurtleCenter1={enemy="Jungle Pirate",questButton=1,ammountToKill=8}
        AFL.questData.TurtleCenter2={enemy="Musketeer Pirate",questButton=2,ammountToKill=8}
        AFL.questData.HauntedCastle1={enemy="Reborn Skeleton",questButton=1,ammountToKill=8}
        AFL.questData.HauntedCastle2={enemy="Living Zombie",questButton=2,ammountToKill=8}
        AFL.questData.HauntedCastle3={enemy="Demonic Soul",questButton=1,ammountToKill=8}
        AFL.questData.HauntedCastle4={enemy="Posessed Mummy",questButton=2,ammountToKill=8}
        AFL.questData.Peanut1={enemy="Peanut Scout",questButton=1,ammountToKill=8}
        AFL.questData.Peanut2={enemy="Peanut President",questButton=2,ammountToKill=8}
        AFL.questData.IceCream1={enemy="Ice Cream Chef",questButton=1,ammountToKill=8}
        AFL.questData.IceCream2={enemy="Ice Cream Commander",questButton=2,ammountToKill=8}
        AFL.questData.CakeLand1={enemy="Cookie Crafter",questButton=1,ammountToKill=8}
        AFL.questData.CakeLand2={enemy="Cake Guard",questButton=2,ammountToKill=8}
        AFL.questData.CakeLand3={enemy="Baking Staff",questButton=1,ammountToKill=8}
        AFL.questData.CakeLand4={enemy="Head Baker",questButton=2,ammountToKill=8}
        AFL.questData.Chocolate1={enemy="Cocoa Warrior",questButton=1,ammountToKill=8}
        AFL.questData.Chocolate2={enemy="Chocolate Bar Battler",questButton=2,ammountToKill=8}
        AFL.questData.Chocolate3={enemy="Sweet Thief",questButton=1,ammountToKill=8}
        AFL.questData.Chocolate4={enemy="Candy Rebel",questButton=2,ammountToKill=8}
        AFL.questData.NorthPole1={enemy="Candy Pirate",questButton=1,ammountToKill=8}
        AFL.questData.NorthPole2={enemy="Snow Demon",questButton=2,ammountToKill=8}
        AFL.questData.Tiki1Quest1={enemy="Isle Outlaw",questButton=1,ammountToKill=8}
        AFL.questData.Tiki1Quest2={enemy="Island Boy",questButton=2,ammountToKill=8}
        AFL.questData.Tiki2Quest1={enemy="Sun-kissed Warrior",questButton=1,ammountToKill=8}
        AFL.questData.Tiki2Quest2={enemy="Isle Champion",questButton=2,ammountToKill=8}
        AFL.questData.Tiki3Quest1={enemy="Serpent Hunter",questButton=1,ammountToKill=8}
        AFL.questData.Tiki3Quest2={enemy="Skull Slayer",questButton=2,ammountToKill=8}
    end
end
afl_loadQuestData()

function afl_jitterClick(x, y)

    local okMouse, mouse=pcall(function() return LocalPlayer:GetMouse() end)
    if not okMouse or not mouse then return false end

    mousemoveabs(x,y)
    wait(0.05)
    for i=1,12 do
        local okPos,mx,my=pcall(function() return mouse.X,mouse.Y end)
        if not okPos or not mx or not my then return false end
        local dx=x-mx; local dy=y-my
        if math.abs(dx)<=2 and math.abs(dy)<=2 then break end
        mousemoverel(dx,dy)
        wait(0.03)
    end

    mousemoverel(3,0); wait(0.03)
    mousemoverel(-3,3); wait(0.03)
    mousemoverel(0,-3); wait(0.03)

    local okFinal,mx,my=pcall(function() return mouse.X,mouse.Y end)
    if okFinal and mx and my then mousemoverel(x-mx,y-my) end
    wait(0.1)
    return true
end

function afl_getCharacter()
    local char=LocalPlayer.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if char and hrp then return char,hrp end
end

function afl_setCanCollide(on)
    local char=afl_getCharacter()
    if not char then return end
    for _,c in pairs(char:GetChildren()) do
        if c:IsA("BasePart") then c.CanCollide=not on end
    end
end

function afl_teleportTo(position)
    local char,hrp=afl_getCharacter()
    if not char then return end
    afl_setCanCollide(false)
    tweenTo(hrp,position,AFL.tweenSpeed,function()
        return char.Parent and not farmPriorityBlocked()
    end)
    afl_setCanCollide(true)
end

function afl_teleportToWait(questKey)
    local position=nil
    if afl_getNextNpc then
        local target=afl_getNextNpc()
        local targetRoot=target and target:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local p=targetRoot.Position
            position=Vector3.new(p.X,p.Y+23,p.Z)
        end
    end
    local route=AFL.waitRoutes and AFL.waitRoutes[questKey] or nil
    if not position and route and #route>0 then
        local index=(AFL.waitRouteIndices[questKey] or 0)+1
        if index>#route then index=1 end
        AFL.waitRouteIndices[questKey]=index
        position=route[index]
    elseif not position then
        position=AFL.waitPositions and AFL.waitPositions[questKey] or nil
    end
    if position then afl_teleportTo(position) end
end

function afl_readLevel()

    local okData,dataLevel=pcall(function() return LocalPlayer.Data.Level.Value end)
    if okData and type(dataLevel)=="number" and dataLevel>0 then return dataLevel end

    local okGui,levelText=pcall(function() return LocalPlayer.PlayerGui.Main.Level.Text end)
    if okGui and type(levelText)=="string" then
        local parsed=tonumber(string.match(levelText,"%d+"))
        if parsed and parsed>0 then return parsed end
    end
    return nil
end

function afl_getLevels()
    if not AFL.autofarmByLevel then return end
    local level=afl_readLevel()
    if not level then return end

    if level>=2800 then
        AFL.currentSea=3
        afl_loadQuestData()
        AFL.npcToFarm="Tiki3Quest2"
        AFL.islandPositions.Tiki3Quest2=Vector3.new(-16665.98,105.31,1576.49)
        AFL.waitPositions.Tiki3Quest2=Vector3.new(-16847.48,122.17,1727.21)
        return
    end
    local seaTable=AFL.levelFarmTable[AFL.currentSea]
    if not seaTable then return end
    for _,data in ipairs(seaTable) do
        if level>=data[1] and level<data[2] and AFL.questData[data[3]] then
            AFL.npcToFarm=data[3]; return
        end
    end
    for i=#seaTable,1,-1 do
        if AFL.questData[seaTable[i][3]] then AFL.npcToFarm=seaTable[i][3]; return end
    end
end

function afl_findDialogueOption(optionNumber)
    local wanted="option"..tostring(optionNumber)
    local okGui,dialogueGui=pcall(function() return LocalPlayer.PlayerGui:FindFirstChild("DialogueGui") end)
    if okGui and dialogueGui then
        local okDesc,descendants=pcall(function() return dialogueGui:GetDescendants() end)
        if okDesc and descendants then
            local function safeName(object)
                local okName,name=pcall(function() return object.Name end)
                return okName and type(name)=="string" and string.lower(name) or ""
            end
            local function ancestorContains(object,fragment)
                local current=object
                for _=1,16 do
                    if not current or current==dialogueGui then break end
                    if string.find(safeName(current),fragment,1,true) then return true end
                    local okParent,parent=pcall(function() return current.Parent end)
                    if not okParent then break end
                    current=parent
                end
                return false
            end
            local fallback=nil
            for _,object in pairs(descendants) do
                local name=safeName(object)
                if name=="textlabel" and ancestorContains(object,"button")
                    and ancestorContains(object,wanted) and ancestorContains(object,"optionslist") then
                    local okBounds,p,s=pcall(function() return object.AbsolutePosition,object.AbsoluteSize end)
                    if okBounds and p and s and type(p.X)=="number" and type(p.Y)=="number"
                        and type(s.X)=="number" and type(s.Y)=="number" and s.X>0 and s.Y>0 then
                        return object,Vector2.new(p.X+s.X/2,p.Y+s.Y/2)
                    end
                elseif name=="fill" and ancestorContains(object,"word1") and ancestorContains(object,"button")
                    and ancestorContains(object,wanted) and ancestorContains(object,"optionslist") then
                    local okBounds,p,s=pcall(function() return object.AbsolutePosition,object.AbsoluteSize end)
                    if okBounds and p and s and type(p.X)=="number" and type(p.Y)=="number"
                        and type(s.X)=="number" and type(s.Y)=="number" and s.X>0 and s.Y>0 then
                        return object,Vector2.new(p.X+s.X/2,p.Y+s.Y/2)
                    end
                elseif not fallback and name=="button" and ancestorContains(object,wanted) then
                    fallback=object
                end
            end
            if fallback then
                local okBounds,p,s=pcall(function() return fallback.AbsolutePosition,fallback.AbsoluteSize end)
                if okBounds and p and s and p.X and p.Y and s.X and s.Y then
                    return fallback,Vector2.new(p.X+s.X/2,p.Y+s.Y/2)
                end
            end
        end
    end

    local okOld,oldDialogue=pcall(function() return LocalPlayer.PlayerGui.Main.Dialogue end)
    local oldButton=okOld and oldDialogue and oldDialogue:FindFirstChild("Option"..tostring(optionNumber)) or nil
    if oldButton then
        local okBounds,p,s=pcall(function() return oldButton.AbsolutePosition,oldButton.AbsoluteSize end)
        if okBounds and p and s and p.X and p.Y and s.X and s.Y then
            return oldButton,Vector2.new(p.X+s.X/2,p.Y+s.Y/2)
        end
    end
    return nil,nil
end

function afl_waitDialogueOption(optionNumber,timeout,notAddress)
    local started=os.clock()
    local lastObject,lastCenter=nil,nil
    while os.clock()-started<(timeout or 3) do
        local object,center=afl_findDialogueOption(optionNumber)
        if object and center then
            lastObject,lastCenter=object,center
            local address=nil
            pcall(function() address=object.Address end)
            if not notAddress or not address or address~=notAddress then return object,center end
        end
        wait(0.05)
    end
    return lastObject,lastCenter
end

local AFL_QUEST_OFFSET_X=70
local AFL_QUEST_OFFSET_Y=50

function afl_clickDialogueOption(optionNumber,timeout,notAddress)
    local object,center=afl_waitDialogueOption(optionNumber,timeout,notAddress)
    if not object or not center then return false,nil end
    if not afl_jitterClick(center.X+AFL_QUEST_OFFSET_X,center.Y+AFL_QUEST_OFFSET_Y) then return false,nil end
    mouse1press(); wait(0.1); mouse1release()
    local address=nil
    pcall(function() address=object.Address end)
    return true,address
end

function afl_setQuest()
    if not AFL.enableGetQuest then return false end
    local quest=AFL.questData and AFL.questData[AFL.npcToFarm]
    if not quest then return false end

    wait(0.5)
    mouse1press(); wait(0.08); mouse1release()
    wait(1)

    local originalOption1=nil
    local initialOption1=afl_waitDialogueOption(1,3)
    if initialOption1 then pcall(function() originalOption1=initialOption1.Address end) end

    local selected=afl_clickDialogueOption(quest.questButton,3)
    if not selected then return false end
    wait(0.35)

    local accepted=afl_clickDialogueOption(1,3,originalOption1)
    if not accepted then
        wait(0.4)
        accepted=afl_clickDialogueOption(1,1)
    end
    return accepted==true
end

function afl_getNextNpc()
    local quest=AFL.questData[AFL.npcToFarm]; if not quest then return end
    local _,root=afl_getCharacter(); if not root then return end
    local cur=root.Position; local best,bestD=nil,math.huge
    local wanted=string.lower(quest.enemy)
    local now=os.clock()
    if AFL.nextNpcCache and now-(AFL.nextNpcCacheTime or 0)<0.12 then
        local cached=AFL.nextNpcCache
        local okCached,aliveCached=pcall(function()
            return cached and cached.Parent and cached:FindFirstChildOfClass("Humanoid")
                and cached:FindFirstChildOfClass("Humanoid").Health>0
                and string.find(string.lower(cached.Name),wanted,1,true)
        end)
        if okCached and aliveCached then return cached end
        AFL.nextNpcCache=nil
    end
    local folder=workspace:FindFirstChild("Enemies")
    if not folder then return end
    local ok,enemies=pcall(function() return folder:GetChildren() end)
    if not ok or not enemies then return end
    for _,enemy in pairs(enemies) do
        if enemy and enemy.Parent and enemy:IsA("Model") then
            local hrp=enemy:FindFirstChild("HumanoidRootPart")
            local hum=enemy:FindFirstChildOfClass("Humanoid")
            local enemyName=""
            pcall(function() enemyName=string.lower(enemy.Name) end)
            if hrp and hum and hum.Health>0 and string.find(enemyName,wanted,1,true) then
                local dx=hrp.Position.X-cur.X; local dy=hrp.Position.Y-cur.Y; local dz=hrp.Position.Z-cur.Z
                local d=dx*dx+dy*dy+dz*dz
                if d<bestD then bestD=d; best=enemy end
            end
        end
    end
    AFL.nextNpcCache=best
    AFL.nextNpcCacheTime=now
    return best
end

function afl_farmNpcs()
    local kills=0
    afl_getLevels()
    if not AFL.npcToFarm then wait(1); return end
    local function pressNevermind()
        afl_clickDialogueOption(3,1)
    end
    if farmPriorityBlocked() then return end
    if AFL.islandPositions[AFL.npcToFarm] and AFL.waitPositions[AFL.npcToFarm] then
        if farmPriorityBlocked() then return end
        afl_teleportTo(AFL.islandPositions[AFL.npcToFarm])
        wait(0.5); afl_setQuest(); wait(0.5)
        afl_teleportToWait(AFL.npcToFarm); wait(0.5)
    end
    while S.autoFarmLevel do
        if farmPriorityBlocked() then wait(0.1); continue end
        local curLevel=afl_readLevel()
        if curLevel and curLevel~=AFL.lastLevel then
            AFL.lastLevel=curLevel; local old=AFL.npcToFarm; afl_getLevels()
            if old~=AFL.npcToFarm and AFL.npcToFarm and AFL.islandPositions[AFL.npcToFarm] then
                kills=0; afl_teleportTo(AFL.islandPositions[AFL.npcToFarm])
                wait(0.5); afl_setQuest(); wait(0.5)
                afl_teleportToWait(AFL.npcToFarm); wait(0.5)
                continue
            end
        end
        local quest=AFL.questData[AFL.npcToFarm]
        local maxKills=quest and quest.ammountToKill or 8
        if kills>=maxKills then
            kills=0
            afl_teleportTo(AFL.islandPositions[AFL.npcToFarm]); wait(0.5)
            afl_setQuest(); wait(0.5)
            afl_teleportToWait(AFL.npcToFarm); wait(0.5)
        end
        if AFL.selectedNpc and AFL.questData[AFL.npcToFarm] then
            if not string.find(AFL.selectedNpc.Name,AFL.questData[AFL.npcToFarm].enemy,1,true) then AFL.selectedNpc=nil end
        end
        if not AFL.selectedNpc or not AFL.selectedNpc.Parent then
            local attempts=0
            repeat AFL.selectedNpc=afl_getNextNpc(); attempts=attempts+1; wait(0.05) until AFL.selectedNpc or attempts>15
            if not AFL.selectedNpc then
                if AFL.waitPositions[AFL.npcToFarm] then afl_teleportToWait(AFL.npcToFarm) end
                wait(0.5); continue
            end
        end
        local hrp=AFL.selectedNpc:FindFirstChild("HumanoidRootPart")
        local hum=AFL.selectedNpc:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then AFL.selectedNpc=nil; wait(0.05); continue end
        local fightStart=os.clock()
        local lastClick=0
        local lastRemoteAttack=0
        local reachedNpc=false
        local targetHead=AFL.selectedNpc:FindFirstChild("Head")
        local originalHeadSize=nil
        local originalHeadCanCollide=nil
        if targetHead then
            pcall(function()
                originalHeadSize=targetHead.Size
                originalHeadCanCollide=targetHead.CanCollide
            end)
        end
        while hum and hum.Health>0 and AFL.selectedNpc.Parent and S.autoFarmLevel and not farmPriorityBlocked() do
            if not hrp or not hrp.Parent then break end
            if os.clock()-fightStart>50 then pressNevermind(); AFL.selectedNpc=nil; break end
            local char,playerHrp=afl_getCharacter()
            if not char or not playerHrp then break end

            local okEnemy,enemyPos=pcall(function() return hrp.Position end)
            local okPlayer,playerPos=pcall(function() return playerHrp.Position end)
            if not okEnemy or not okPlayer or not enemyPos or not playerPos then break end
            if not enemyPos.X or not enemyPos.Y or not enemyPos.Z or not playerPos.X or not playerPos.Y or not playerPos.Z then break end

            local head=AFL.selectedNpc:FindFirstChild("Head") or targetHead

            if S.remoteMode then

                local ox,oy,oz=getNormalFarmOffsets()
                local targetPos=Vector3.new(enemyPos.X+ox,enemyPos.Y+oy,enemyPos.Z+oz)
                if not reachedNpc then
                    tweenTo(playerHrp,targetPos,S.FARM_SPEED,function()
                        return S.autoFarmLevel and S.remoteMode and not farmPriorityBlocked() and isAlive(AFL.selectedNpc)
                    end)
                    reachedNpc=true
                else
                    hardLockNpcCFrame(playerHrp,targetPos)
                end
                local now=os.clock()
                if now-lastRemoteAttack>=0.05 then
                    remoteAttack()
                    lastRemoteAttack=now
                end
                wait()
            else

                if head then
                    local size=S.bigHitbox and 200 or 50
                    head.Size=Vector3.new(size,size,size)
                    head.CanCollide=false
                end
                local hasSanguine=false
                local backpack=LocalPlayer:FindFirstChild("Backpack")
                if backpack and backpack:FindFirstChild("Sanguine Art") then hasSanguine=true end
                if char:FindFirstChild("Sanguine Art") then hasSanguine=true end
                local ox,oy,oz
                if S.customOffset then
                    ox,oy,oz=S.customOffsetX,S.customOffsetY,S.customOffsetZ
                elseif hasSanguine then
                    ox,oy,oz=0,23,10
                else
                    ox,oy,oz=0,23,0
                end
                local targetPos=Vector3.new(enemyPos.X+ox,enemyPos.Y+oy,enemyPos.Z+oz)
                if not reachedNpc then
                    tweenTo(playerHrp,targetPos,S.FARM_SPEED,function()
                        return S.autoFarmLevel and not S.remoteMode and not farmPriorityBlocked() and isAlive(AFL.selectedNpc)
                    end)
                    reachedNpc=true
                else
                    hardLockNpcCFrame(playerHrp,targetPos)
                end
                local now=os.clock()
                if now-lastClick>=0.06 then mouse1click(); lastClick=now end
                wait()
            end
            hrp=AFL.selectedNpc:FindFirstChild("HumanoidRootPart")
            hum=AFL.selectedNpc:FindFirstChildOfClass("Humanoid")
        end
        if targetHead and targetHead.Parent and originalHeadSize then
            pcall(function()
                targetHead.Size=originalHeadSize
                if originalHeadCanCollide~=nil then targetHead.CanCollide=originalHeadCanCollide end
            end)
        end
        if hum and hum.Health<=0 then kills=kills+1; AFL.selectedNpc=nil end
    end
end

