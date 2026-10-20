_pvpAuraEnabled = false
_pvpAuraAltPart = false
_pvpAuraMaxDist = 100

islandNames = {}
for _, isle in pairs(islandList) do table.insert(islandNames, isle.name) end

Window = Library:CreateWindow({
    Title = "FRUIT THINGY",
    Columns = 2,
    Divider = true,
    ConfigFile = "myth4c_bloxfruits.json",
    BuiltInIndicatorToggle = false,
    Width = 760,
    Height = 560,
    Theme = { Colors = { Accent = Color3.fromRGB(255,111,0) } }
})

local mainTab=Window:AddTab("Main")
local miscTab=Window:AddTab("Misc")
local misc2Tab=Window:AddTab("Misc2")
local otherTab=Window:AddTab("Other")
local pvpTab=Window:AddTab("PvP")
local automationTab=Window:AddTab("Automation")
Window:InitializeSettings()

do
    local MagnetSettings={
        enabled=false,
        targetPlayers=true,
        autoFarm=false,
        autoFarmNearest=false,
        farmMode=nil,
        selectedPlayerName="",
        range=100,
        attackNumber=1,
        m1Delay=0.10
    }

    local MAGNET_FARM_X_OFFSET=10
    local MAGNET_FARM_TWEEN_SPEED=350
    local MAGNET_NEAREST_ATTACK_TIME=1
    local MagnetNearestFarm={
        target=nil,
        attacking=false,
        attackEnds=0,
        holdPosition=nil,
        visited={}
    }

    local function magnetResetNearestFarm()
        MagnetNearestFarm.target=nil
        MagnetNearestFarm.attacking=false
        MagnetNearestFarm.attackEnds=0
        MagnetNearestFarm.holdPosition=nil
        MagnetNearestFarm.visited={}
    end

    local function magnetGetPlayerNames()
        local names={}
        for _,player in pairs(Players:GetChildren()) do
            if player~=LocalPlayer then table.insert(names,player.Name) end
        end
        if #names==0 then table.insert(names,"No players") end
        return names
    end

    local function magnetFindPlayerByName(name)
        if type(name)~="string" or name=="" then return nil end
        for _,player in pairs(Players:GetChildren()) do
            if player~=LocalPlayer and player.Name==name then return player end
        end
        return nil
    end

    misc2Tab:AddSection("Magnet M1 Aura",{Column=1})
    misc2Tab:AddToggle("magnet_m1_aura",{
        Text="Magnet M1 Aura",
        Description="Aims Magnet M1 at the closest enemy or enabled player target",
        Default=false,
        Keybind=true,
        Column=1,
        Callback=function(value)
            MagnetSettings.enabled=value
            notify(value and "Magnet M1 Aura ON!" or "Magnet M1 Aura OFF!","laced.club",2)
        end
    })

    misc2Tab:AddToggle("magnet_target_players",{
        Text="Target Players",
        Description="Allow Magnet M1 Aura to target other players",
        Default=true,
        Column=1,
        Callback=function(value) MagnetSettings.targetPlayers=value end
    })

    misc2Tab:AddSlider("magnet_target_range",{
        Text="Target Range",
        Description="Maximum aura targeting distance in studs",
        Min=10,Max=2000,Step=10,Integer=true,Default=100,Column=1,
        Color=Color3.fromRGB(210,70,255),
        Callback=function(value)
            MagnetSettings.range=math.max(10,tonumber(value) or 100)
        end
    })

    misc2Tab:AddSlider("magnet_m1_delay",{
        Text="Wait Between M1s",
        Description="Seconds to wait between Magnet remote calls",
        Min=0.01,Max=2,Step=0.01,Integer=false,Default=0.10,Column=1,
        Color=Color3.fromRGB(0,220,255),
        Callback=function(value)
            MagnetSettings.m1Delay=math.max(0.01,tonumber(value) or 0.10)
        end
    })

    misc2Tab:AddSlider("magnet_attack_number",{
        Text="Attack Number",
        Description="Selects Magnet M1 attack 1 through 5",
        Min=1,Max=5,Step=1,Integer=true,Default=1,Column=1,
        Color=Color3.fromRGB(255,80,150),
        Callback=function(value)
            MagnetSettings.attackNumber=math.max(1,math.min(5,math.floor(tonumber(value) or 1)))
        end
    })

    misc2Tab:AddSection("Magnet Auto Farm",{Column=2})
    misc2Tab:AddToggle("magnet_auto_farm",{
        Text="Auto Farm Player",
        Description="Tweens 10 studs along X from the selected player and spams Magnet M1",
        Default=false,Keybind=true,Column=2,
        Callback=function(value)
            MagnetSettings.autoFarm=value
            if value then
                MagnetSettings.farmMode="player"
                MagnetSettings.autoFarmNearest=false
                magnetResetNearestFarm()
                pcall(function() Window:Set("magnet_auto_farm_nearest",false) end)
            elseif MagnetSettings.farmMode=="player" then
                MagnetSettings.farmMode=nil
            end
            notify(value and "Magnet Auto Farm Player ON!" or "Magnet Auto Farm Player OFF!","laced.club",2)
        end
    })

    misc2Tab:AddToggle("magnet_auto_farm_nearest",{
        Text="Auto Farm Nearest Enemy",
        Description="Tweens to each nearest enemy, holds still for 1 second, then switches",
        Default=false,Column=2,
        Callback=function(value)
            MagnetSettings.autoFarmNearest=value
            magnetResetNearestFarm()
            if value then
                MagnetSettings.farmMode="enemy"
                MagnetSettings.autoFarm=false
                pcall(function() Window:Set("magnet_auto_farm",false) end)
            elseif MagnetSettings.farmMode=="enemy" then
                MagnetSettings.farmMode=nil
            end
            notify(value and "Magnet Auto Farm Nearest ON!" or "Magnet Auto Farm Nearest OFF!","laced.club",2)
        end
    })

    local initialMagnetPlayerNames=magnetGetPlayerNames()
    if initialMagnetPlayerNames[1]~="No players" then
        MagnetSettings.selectedPlayerName=initialMagnetPlayerNames[1]
    end

    local magnetPlayerDropdown=misc2Tab:AddDropdown("magnet_target_player",{
        Text="Target Player",
        Description="Select the player Magnet Auto Farm follows",
        Options=initialMagnetPlayerNames,
        Default=initialMagnetPlayerNames[1],
        MaxVisible=8,
        Column=2,
        Callback=function(selected)
            if type(selected)=="string" and selected~="No players" then
                MagnetSettings.selectedPlayerName=selected
            end
        end
    })

    misc2Tab:AddButton("magnet_rescan_players",{
        Text="Rescan Players",
        Description="Refreshes the Magnet target player list",
        Column=2,
        Callback=function()
            local names=magnetGetPlayerNames()
            local keptSelection=false
            for _,name in pairs(names) do
                if name==MagnetSettings.selectedPlayerName then keptSelection=true end
            end

            local refreshed=false
            if magnetPlayerDropdown then
                refreshed=pcall(function() magnetPlayerDropdown:SetValues(names) end)
                if not refreshed then
                    refreshed=pcall(function() magnetPlayerDropdown:SetOptions(names) end)
                end
            end

            if not keptSelection then
                MagnetSettings.selectedPlayerName=names[1]~="No players" and names[1] or ""
                if MagnetSettings.selectedPlayerName~="" then
                    pcall(function() magnetPlayerDropdown:SetValue(MagnetSettings.selectedPlayerName) end)
                end
            end
            notify(refreshed and "Player list refreshed" or "Player list refresh failed","laced.club",2)
        end
    })

    local function magnetGetRoot(model)
        if not model then return nil end
        return model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
            or model:FindFirstChildWhichIsA("BasePart")
    end

    local function magnetIsAlive(model)
        if not model or not model.Parent then return false end
        local humanoid=model:FindFirstChildOfClass("Humanoid")
        return not humanoid or humanoid.Health>0
    end

    local function magnetDistanceSquared(a,b)
        local dx=a.X-b.X
        local dy=a.Y-b.Y
        local dz=a.Z-b.Z
        return dx*dx+dy*dy+dz*dz
    end

    local function magnetConsiderTarget(origin,model,bestModel,bestRoot,bestDistanceSquared)
        if model and model~=LocalPlayer.Character and magnetIsAlive(model) then
            local root=magnetGetRoot(model)
            if root then
                local currentDistanceSquared=magnetDistanceSquared(origin,root.Position)
                if currentDistanceSquared<bestDistanceSquared then
                    return model,root,currentDistanceSquared
                end
            end
        end
        return bestModel,bestRoot,bestDistanceSquared
    end

    local function magnetFindClosestTarget(playerRoot)
        local bestModel=nil
        local bestRoot=nil
        local bestDistanceSquared=MagnetSettings.range*MagnetSettings.range
        local origin=playerRoot.Position
        local enemies=game.Workspace:FindFirstChild("Enemies")

        if enemies then
            for _,enemy in pairs(enemies:GetChildren()) do
                bestModel,bestRoot,bestDistanceSquared=magnetConsiderTarget(
                    origin,enemy,bestModel,bestRoot,bestDistanceSquared
                )
            end
        end

        if MagnetSettings.targetPlayers then
            for _,player in pairs(Players:GetChildren()) do
                if player~=LocalPlayer then
                    bestModel,bestRoot,bestDistanceSquared=magnetConsiderTarget(
                        origin,player.Character,bestModel,bestRoot,bestDistanceSquared
                    )
                end
            end
        end
        return bestModel,bestRoot
    end

    local function magnetFindClosestEnemy(playerRoot,excluded)
        local enemies=game.Workspace:FindFirstChild("Enemies")
        if not enemies then return nil,nil end
        local bestModel=nil
        local bestRoot=nil
        local bestDistanceSquared=MagnetSettings.range*MagnetSettings.range
        local origin=playerRoot.Position

        for _,enemy in pairs(enemies:GetChildren()) do
            if not excluded or not excluded[enemy] then
                bestModel,bestRoot,bestDistanceSquared=magnetConsiderTarget(
                    origin,enemy,bestModel,bestRoot,bestDistanceSquared
                )
            end
        end
        return bestModel,bestRoot
    end

    local function magnetGetRemote()
        local characters=game.Workspace:FindFirstChild("Characters")
        local character=characters and characters:FindFirstChild(LocalPlayer.Name)
        if not character then character=LocalPlayer.Character end
        local magnet=character and character:FindFirstChild("Magnet-Magnet")
        return magnet and magnet:FindFirstChild("LeftClickRemote")
    end

    local function magnetDirectionTo(origin,target)
        local dx=target.X-origin.X
        local dy=target.Y-origin.Y
        local dz=target.Z-origin.Z
        local length=math.sqrt(dx*dx+dy*dy+dz*dz)
        if length<0.001 then return Vector3.new(0,0,-1) end
        return Vector3.new(dx/length,dy/length,dz/length)
    end

    local function magnetGetSelectedPlayerTarget()
        local player=magnetFindPlayerByName(MagnetSettings.selectedPlayerName)
        local character=player and player.Character
        if not magnetIsAlive(character) then return nil,nil end
        return character,magnetGetRoot(character)
    end

    task.spawn(function()
        local lastStep=os.clock()
        while true do
            local now=os.clock()
            local deltaTime=now-lastStep
            lastStep=now

            if MagnetSettings.farmMode=="player" or MagnetSettings.farmMode=="enemy" then
                local character=LocalPlayer.Character
                local playerRoot=magnetGetRoot(character)
                local targetModel,targetRoot=nil,nil

                if MagnetSettings.farmMode=="enemy" and playerRoot then
                    if MagnetNearestFarm.attacking then
                        targetModel=MagnetNearestFarm.target
                    elseif MagnetNearestFarm.target and not magnetIsAlive(MagnetNearestFarm.target) then
                        MagnetNearestFarm.visited[MagnetNearestFarm.target]=true
                        MagnetNearestFarm.target=nil
                        MagnetNearestFarm.attacking=false
                        MagnetNearestFarm.attackEnds=0
                        MagnetNearestFarm.holdPosition=nil
                    end

                    if not MagnetNearestFarm.attacking and not MagnetNearestFarm.target then
                        targetModel,targetRoot=magnetFindClosestEnemy(playerRoot,MagnetNearestFarm.visited)
                        if not targetModel then
                            MagnetNearestFarm.visited={}
                            targetModel,targetRoot=magnetFindClosestEnemy(playerRoot,MagnetNearestFarm.visited)
                        end
                        MagnetNearestFarm.target=targetModel
                    elseif not MagnetNearestFarm.attacking then
                        targetModel=MagnetNearestFarm.target
                        targetRoot=magnetGetRoot(targetModel)
                    end
                else
                    targetModel,targetRoot=magnetGetSelectedPlayerTarget()
                end

                if MagnetSettings.farmMode=="enemy" and not MagnetNearestFarm.attacking
                    and targetModel and not targetRoot then
                    MagnetNearestFarm.visited[targetModel]=true
                    MagnetNearestFarm.target=nil
                end

                if playerRoot and MagnetSettings.farmMode=="enemy" and MagnetNearestFarm.attacking then
                    if MagnetNearestFarm.holdPosition then
                        playerRoot.Position=MagnetNearestFarm.holdPosition
                    end
                    playerRoot.Velocity=Vector3.new(0,0,0)
                    playerRoot.AssemblyLinearVelocity=Vector3.new(0,0,0)

                    if now>=MagnetNearestFarm.attackEnds then
                        if MagnetNearestFarm.target then
                            MagnetNearestFarm.visited[MagnetNearestFarm.target]=true
                        end
                        MagnetNearestFarm.target=nil
                        MagnetNearestFarm.attacking=false
                        MagnetNearestFarm.attackEnds=0
                        MagnetNearestFarm.holdPosition=nil
                    end
                elseif playerRoot and targetModel and targetRoot then
                    local currentPosition=playerRoot.Position
                    local targetPosition=Vector3.new(
                        targetRoot.Position.X+MAGNET_FARM_X_OFFSET,
                        targetRoot.Position.Y,
                        targetRoot.Position.Z
                    )
                    local dx=targetPosition.X-currentPosition.X
                    local dy=targetPosition.Y-currentPosition.Y
                    local dz=targetPosition.Z-currentPosition.Z
                    local distance=math.sqrt(dx*dx+dy*dy+dz*dz)

                    if distance>0.01 then
                        local maxStep=MAGNET_FARM_TWEEN_SPEED*math.min(deltaTime,0.1)
                        local alpha=math.min(maxStep/distance,1)
                        playerRoot.Position=Vector3.new(
                            currentPosition.X+dx*alpha,
                            currentPosition.Y+dy*alpha,
                            currentPosition.Z+dz*alpha
                        )
                    end

                    if MagnetSettings.farmMode=="enemy" and MagnetNearestFarm.target==targetModel
                        and not MagnetNearestFarm.attacking and distance<=1.5 then
                        playerRoot.Position=targetPosition
                        MagnetNearestFarm.attacking=true
                        MagnetNearestFarm.attackEnds=now+MAGNET_NEAREST_ATTACK_TIME
                        MagnetNearestFarm.holdPosition=targetPosition
                    end
                    playerRoot.Velocity=Vector3.new(0,0,0)
                    playerRoot.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end
            end
            task.wait()
        end
    end)

    task.spawn(function()
        local lastM1=0
        while true do
            if MagnetSettings.enabled or MagnetSettings.farmMode~=nil then
                local character=LocalPlayer.Character
                local playerRoot=magnetGetRoot(character)
                local now=os.clock()

                if playerRoot and now-lastM1>=MagnetSettings.m1Delay then
                    local targetModel,targetRoot=nil,nil
                    if MagnetSettings.farmMode=="enemy" then
                        if MagnetNearestFarm.attacking and magnetIsAlive(MagnetNearestFarm.target) then
                            targetModel=MagnetNearestFarm.target
                            targetRoot=magnetGetRoot(targetModel)
                        end
                    elseif MagnetSettings.farmMode=="player" then
                        targetModel,targetRoot=magnetGetSelectedPlayerTarget()
                    else
                        targetModel,targetRoot=magnetFindClosestTarget(playerRoot)
                    end

                    local remote=magnetGetRemote()
                    if targetModel and targetRoot and remote then
                        local direction=magnetDirectionTo(playerRoot.Position,targetRoot.Position)
                        local ok,err=pcall(function()
                            remote:FireServer(direction,MagnetSettings.attackNumber)
                        end)
                        if not ok then warn("Magnet M1 failed: "..tostring(err)) end
                        lastM1=now
                    end
                end
            end
            task.wait()
        end
    end)
end

misc2Tab:AddSection("Ship Repair",{Column=1})
misc2Tab:AddToggle("auto_ship_repair",{
    Text="Auto Repair",
    Description="Automatically holds and releases the ship repair mini-game in its green zone",
    Default=false,
    Keybind=true,
    Column=1,
    Callback=function(value)
        S.autoRepair=value
        if value then pcall(function() Window:Set("auto_fish",false) end) end
        if not value then pcall(mouse1release) end
        notify(value and "Auto Repair ON!" or "Auto Repair OFF!","laced.club",2)
    end
})

mainTab:AddSection("Dungeon",{Column=2})
mainTab:AddToggle("dungeon_enabled",{
    Text="Enable Dungeon",
    Description="Master switch for the Second Sea dungeon automation",
    Default=false,Keybind=true,Column=2,
    Callback=function(value)
        S.dungeonEnabled=value
        notify(value and "Dungeon Farm ON!" or "Dungeon Farm OFF!","laced.club",2)
    end
})
mainTab:AddToggle("dungeon_auto_door",{
    Text="Smart Door Path",
    Description="Moves to the exit teleporter when the current island is clear",
    Default=true,Column=2,
    Callback=function(value) S.dungeonAutoDoor=value end
})
mainTab:AddToggle("dungeon_destroy_vents",{
    Text="Destroy Vents First",
    Description="Prioritizes vents, shrines, rocks, and dungeon props",
    Default=true,Column=2,
    Callback=function(value) S.dungeonDestroyObj=value end
})
mainTab:AddToggle("dungeon_vent_skills",{
    Text="Skills on Vents Z/X/C/V",
    Description="Uses equipped-tool skills against dungeon objectives",
    Default=true,Column=2,
    Callback=function(value) S.dungeonUseMoves=value end
})

local BOSS_OPTIONS={"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral","Greybeard","Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order","Stone","Hydra Leader","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies"}
local MATERIAL_OPTIONS={"Leather + Scrap Metal","Angel Wings","Magma Ore","Fish Tail","Radioactive Material","Ectoplasm","Mystic Droplet","Vampire Fang","Demonic Wisp","Conjured Cocoa","Dragon Scale","Gunpowder","Mini Tusk"}
local SEA_EVENT_OPTIONS={"Shark","Terrorshark","Piranha","Fish Crew Member","Haunted Crew Member"}

automationTab:AddSection("Boss and Materials",{Column=1})
automationTab:AddDropdown("boss_target",{
    Text="Boss",Options=BOSS_OPTIONS,Default=BOSS_OPTIONS[1],MaxVisible=8,Column=1,
    Callback=function(v) if type(v)=="string" then S.selectedBoss=v end end
})
automationTab:AddToggle("auto_boss_farm",{
    Text="Auto Farm Boss",Description="Tweens to and farms the selected spawned boss",Default=false,Column=1,
    Callback=function(v)
        S.autoBossFarm=v
        if v then Window:Set("auto_material_farm",false) end
    end
})
automationTab:AddDropdown("material_target",{
    Text="Material",Options=MATERIAL_OPTIONS,Default=MATERIAL_OPTIONS[1],ShowAllOptions=true,Column=1,
    Callback=function(v) if type(v)=="string" then S.selectedMaterial=v end end
})
automationTab:AddToggle("auto_material_farm",{
    Text="Auto Farm Material",Description="Farms enemies that drop the selected material",Default=false,Column=1,
    Callback=function(v)
        S.autoMaterialFarm=v
        if v then Window:Set("auto_boss_farm",false) end
    end
})

automationTab:AddSection("Automatic Stats",{Column=2})
automationTab:AddSlider("stat_amount",{
    Text="Points Per Upgrade",Min=1,Max=1000,Step=1,Default=10,Integer=true,Column=2,
    Callback=function(v) S.statAmount=math.max(1,math.floor(tonumber(v) or 10)) end
})
for _,entry in ipairs({{"stat_melee","Melee","autoStatMelee"},{"stat_defense","Defense","autoStatDefense"},{"stat_sword","Sword","autoStatSword"},{"stat_gun","Gun","autoStatGun"},{"stat_fruit","Blox Fruit","autoStatFruit"}}) do
    local controlId=entry[1]
    local label=entry[2]
    local stateKey=entry[3]
    automationTab:AddToggle(controlId,{
        Text="Auto "..label,Default=false,Column=2,
        Callback=function(v) S[stateKey]=v end
    })
end

automationTab:AddSection("Sea Events",{Column=1})
automationTab:AddDropdown("sea_event_target",{
    Text="Sea Target",Options=SEA_EVENT_OPTIONS,Default=SEA_EVENT_OPTIONS[1],MaxVisible=5,Column=1,
    Callback=function(v) if type(v)=="string" then S.selectedSeaEvent=v end end
})
automationTab:AddToggle("auto_sea_event",{
    Text="Auto Farm Sea Target",Description="Tweens to and attacks the selected spawned sea enemy",Default=false,Column=1,
    Callback=function(v) S.autoSeaEvent=v end
})

miscTab:AddSection("Mirage",{Column=2})
miscTab:AddToggle("mirage_esp",{
    Text="Mirage ESP",Description="Shows the Mirage Island location",Default=false,Column=2,
    Callback=function(v) S.mirageEsp=v; if not v then clearMirageEsp() end end
})
miscTab:AddToggle("auto_mirage_tween",{
    Text="Tween to Mirage",Description="Tweens above Mirage Island when it exists",Default=false,Column=2,
    Callback=function(v) S.autoMirageTween=v end
})
miscTab:AddToggle("auto_mirage_gear",{
    Text="Collect Mirage Gear",Description="Finds and tweens to the visible Mirage gear",Default=false,Column=2,
    Callback=function(v) S.autoMirageGear=v end
})

miscTab:AddSection("World Status",{Column=2})
miscTab:AddButton("check_events",{Text="Check Event Islands",Column=2,Callback=function() showEventStatus() end})
miscTab:AddButton("check_bosses",{Text="Check Important Bosses",Column=2,Callback=function() showBossStatus() end})
miscTab:AddButton("check_swords",{Text="Check Legendary Sword Dealer",Column=2,Callback=function() showLegendarySwordStatus() end})

task.spawn(function()
    task.wait(0.2)
    Window.Indicator:SetVisible(false)
    Window.Config.IndicatorEnabled = false
end)

mainTab:AddSection("Farming", { Column = 1 })

mainTab:AddToggle("auto_fire_flowers", {
    Text="Auto Farm Fire Flowers", Description="Kills nearest NPCs and collects spawned FireFlowers with E",
    Default=false, Column=1, Callback=function(v) S.autoFireFlowers=v end
})
miscTab:AddToggle("fire_flower_esp", {
    Text="Fire Flower ESP", Description="Labels spawned FireFlowers with distance",
    Default=false, Column=1, Callback=function(v) S.fireFlowerEsp=v end
})

mainTab:AddToggle("auto_farm_nearest", {
    Text="Auto Farm Nearest", Description="Farms the nearest enemy (load chests/enemies first!)",
    Default=false, Keybind=true, Column=1,
    Callback=function(v) S.autoFarmNearest=v; notify(v and "Auto Farm Nearest ON!" or "Auto Farm Nearest OFF!","laced.club",2) end
})

mainTab:AddToggle("remote_mode", {
    Text="remotemode(crashable)", Description="Instead of teleporting and clicking, fires RegisterAttack + RegisterHit on all enemies within 60 studs. ONLY WORKS ON MATCHA PRO.",
    Default=false, Column=1,
    Callback=function(v)
        S.remoteMode=v
        notify(v and "Remote Mode ON! (RegisterHit aura)" or "Remote Mode OFF! (back to click farm)","laced.club",2)
    end
})

mainTab:AddToggle("auto_farm_chest", {
    Text="Auto Farm Chest", Description="Automatically farms chests (load them in first!)",
    Default=false, Column=1,
    Callback=function(v) S.autoFarming=v; S.handledChests={}; if v then S.chestIndex=1 end; notify(v and "Auto Farm Chest ON!" or "Auto Farm Chest OFF!","laced.club",2) end
})

otherTab:AddPriorityList("chest_priority", {
    Text="Chest Priority",
    Description="Reorder chest types from highest to lowest priority",
    Options={"Diamond","Gold","Silver"},
    Default={"Diamond","Gold","Silver"},
    MaxVisible=3,
    Column=1,
    Callback=function(order)
        if type(order)~="table" then return end
        local nextOrder={}
        for _,chestType in ipairs(order) do
            if chestType=="Diamond" or chestType=="Gold" or chestType=="Silver" then
                table.insert(nextOrder,chestType)
            end
        end
        if #nextOrder==3 then S.chestPriority=nextOrder end
    end
})

mainTab:AddToggle("auto_farm_fruits", {
    Text="Auto Farm Fruits", Description="Tweens to the nearest fruit and farms it",
    Default=false, Column=1,
    Callback=function(v)
        S.autoFruits=v
        if not v then S.fruitPriorityActive=false end
        notify(v and "Auto Farm Fruits ON! (interrupts only when fruit is found)" or "Auto Farm Fruits OFF!","laced.club",2)
    end
})

mainTab:AddToggle("auto_dino_bone", {
    Text="Auto DinoBone", Description="Teleports to every Workspace.DinoBone until it disappears",
    Default=false, Column=1,
    Callback=function(v)
        S.autoDinoBone=v
        notify(v and "Auto DinoBone ON!" or "Auto DinoBone OFF!","laced.club",2)
    end
})

mainTab:AddToggle("auto_race_ability",{
    Text="Auto Race Ability",Description="Keeps sending the race ability activation remote",Default=false,Column=1,
    Callback=function(v) S.autoRaceAbility=v end
})

mainTab:AddToggle("auto_v4",{
    Text="Auto V4",Description="Presses Y every 5 seconds while enabled",Default=false,Column=1,
    Callback=function(v)
        S.autoV4=v
        S.autoV4NextPress=v and (os.clock()+5) or 0
    end
})

mainTab:AddSection("NPC Farm", { Column = 1 })

mainTab:AddToggle("auto_npc_farm", {
    Text="Auto NPC Farm", Description="Farms NPCs on the selected island",
    Default=false, Column=1,
    Callback=function(v) S.autoNpcFarm=v; notify(v and "Auto NPC Farm ON!" or "Auto NPC Farm OFF!","laced.club",2) end
})

mainTab:AddDropdown("npc_island", {
    Text="NPC Island", Description="Select which island to farm NPCs on",
    Options=islandNames, Default=islandNames[1], MaxVisible=6, Column=1,
    Callback=function(v)
        for i, isle in pairs(islandList) do
            if isle.name == v then S.selectedIsland=i; break end
        end
        notify("Island: "..v,"laced.club",1)
    end
})

mainTab:AddToggle("auto_farm_level", {
    Text="Auto Farm Level", Description="Farms mobs based on your current level (quest giver must be loaded!)",
    Default=false, Column=1,
    Callback=function(v)
        S.autoFarmLevel=v
        if v then pcall(function() AFL.lastLevel=afl_readLevel() or 0 end) end
        notify(v and "Auto Farm Level ON!" or "Auto Farm Level OFF!","laced.club",2)
    end
})

otherTab:AddSection("Custom NPC Offset", { Column = 2 })

otherTab:AddToggle("custom_offset", {
    Text="Custom NPC Offset", Description="Use custom XYZ offset when positioning on NPCs",
    Default=false, Column=2,
    Callback=function(v)
        S.customOffset=v
        notify(v and "Custom Offset ON!" or "Custom Offset OFF!","laced.club",2)
    end
})

otherTab:AddSlider("offset_x", {
    Text="Offset X", Description="X offset from enemy position",
    Min=-100, Max=100, Default=0, Decimals=1, Column=2,
    Callback=function(v) S.customOffsetX=v end
})

otherTab:AddSlider("offset_y", {
    Text="Offset Y", Description="Y offset from enemy position",
    Min=-100, Max=100, Default=23, Decimals=1, Column=2,
    Callback=function(v) S.customOffsetY=v end
})

otherTab:AddSlider("offset_z", {
    Text="Offset Z", Description="Z offset from enemy position",
    Min=-100, Max=100, Default=0, Decimals=1, Column=2,
    Callback=function(v) S.customOffsetZ=v end
})

mainTab:AddSection("Weapon Selection", { Column = 2 })

local meleeWeaponToggle=nil
local swordWeaponToggle=nil

meleeWeaponToggle=mainTab:AddToggle("weapon_melee", {
    Text="Melee", Description="Use inventory slot 1 for farming",
    Default=true, Column=2,
    Callback=function(v)
        if v then
            S.weaponSlot=1
            if swordWeaponToggle then
                pcall(function() swordWeaponToggle:SetValue(false) end)
            end
        end
    end
})

swordWeaponToggle=mainTab:AddToggle("weapon_sword", {
    Text="Sword", Description="Use inventory slot 3 for farming",
    Default=false, Column=2,
    Callback=function(v)
        if v then
            S.weaponSlot=3
            if meleeWeaponToggle then
                pcall(function() meleeWeaponToggle:SetValue(false) end)
            end
        end
    end
})

miscTab:AddSection("ESP", { Column = 1 })

miscTab:AddToggle("fruit_esp", {
    Text="Fruit ESP", Description="Shows drawing ESP with the fruit name and nearest island",
    Default=false, Column=1,
    Callback=function(v)
        S.fruitEsp=v; S.chamEsp=v
        if v then buildEspLabels(); buildChamBoxes() else clearEspLabels(); clearChamBoxes() end
        notify(v and "Fruit ESP On!" or "Fruit ESP Off!","laced.club",2)
    end
})

miscTab:AddToggle("chest_esp", {
    Text="Chest ESP", Description="Shows the nearest 128 on-screen chests with batched updates",
    Default=false, Column=1,
    Callback=function(v)
        S.chestEsp=v
        if v then buildChestEspLabels() else clearChestEspLabels() end
        notify(v and "Chest ESP On!" or "Chest ESP Off!","laced.club",2)
    end
})

miscTab:AddToggle("berry_esp", {
    Text="Berry Esp", Description="Shows map berries at 60 Hz with an optimized one-second rescan",
    Default=false, Column=1,
    Callback=function(v)
        S.berryEsp=v
        if v then buildBerryEspLabels() else clearBerryEspLabels() end
        notify(v and "Berry Esp On!" or "Berry Esp Off!","laced.club",2)
    end
})

miscTab:AddToggle("boat_esp", {
    Text="Boat ESP", Description="Draws a full 3D box around each on-screen boat",
    Default=false, Column=1,
    Callback=function(v)
        S.boatEsp=v
        if v then buildBoatEsp() else clearBoatEsp() end
        notify(v and "Boat ESP On!" or "Boat ESP Off!","laced.club",2)
    end
})

miscTab:AddToggle("flower_esp", {
    Text="Flower Esp", Description="Shows a label and a 3d box around all flowers, 2ND SEA",
    Default=false, Column=1,
    Callback=function(v)
        S.flowerEsp=v
        if v then buildFlowerEsp() else clearFlowerEsp() end
        notify(v and "Flower Esp On!" or "Flower Esp Off!","laced.club",2)
    end
})

miscTab:AddSection("Combat", { Column = 1 })

miscTab:AddToggle("big_hitbox", {
    Text="Big Hitbox", Description="Expands enemy HumanoidRootPart size for easier hits",
    Default=false, Column=1,
    Callback=function(v) S.bigHitbox=v; notify(v and "Big Hitbox ON!" or "Big Hitbox OFF!","laced.club",2) end
})

miscTab:AddToggle("pull_enemies", {
    Text="Pull Enemies", Description="Pulls all enemies to one point under you",
    Default=false, Column=1,
    Callback=function(v) S.pullEnemies=v; notify(v and "Pull Enemies ON!" or "Pull Enemies OFF!","laced.club",2) end
})

miscTab:AddToggle("buddha_pull", {
    Text="Buddha Pull", Description="Pulls all enemies to X=40 under you",
    Default=false, Column=1,
    Callback=function(v) S.buddhaPull=v; notify(v and "Buddha Pull ON!" or "Buddha Pull OFF!","laced.club",2) end
})

miscTab:AddToggle("auto_ken", {
    Text="Auto Ken", Description="Automatically keeps Ken (Observation Haki) active",
    Default=false, Keybind=true, Column=1,
    Callback=function(v) S.autoKen=v; notify(v and "Auto Ken ON!" or "Auto Ken OFF!","laced.club",2) end
})

miscTab:AddToggle("auto_haki", {
    Text="Auto Haki", Description="Automatically keeps Armament Haki active",
    Default=false, Column=1,
    Callback=function(v) S.autoHaki=v; notify(v and "Auto Haki ON!" or "Auto Haki OFF!","laced.club",2) end
})

miscTab:AddToggle("freeze_pos", {
    Text="Freeze Position", Description="Locks your character in place",
    Default=false, Column=1,
    Callback=function(v)
        S.freezePos=v
        if v then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then S.freezePosition=hrp.Position end
        else
            S.freezePosition=nil
        end
        notify(v and "Freeze ON!" or "Freeze OFF!","laced.club",2)
    end
})

miscTab:AddToggle("freeze_enemies", {
    Text="Freeze Enemies", Description="Locks all enemies in place (auto-catches new spawns)",
    Default=false, Column=1,
    Callback=function(v)
        S.freezeEnemies=v
        S.frozenEnemies={}
        if v then
            local folder=game.Workspace:FindFirstChild("Enemies")
            if folder then
                for _, model in pairs(folder:GetChildren()) do
                    if model:IsA("Model") then
                        local hrp=model:FindFirstChild("HumanoidRootPart")
                        if hrp then S.frozenEnemies[model]=hrp.Position end
                    end
                end
            end
        end
        notify(v and "Freeze Enemies ON!" or "Freeze Enemies OFF!","laced.club",2)
    end
})

miscTab:AddToggle("tween_ember", {
    Text="Auto Tween Dragon Ember", Description="Quickly tweens to Workspace EmberTemplate objects",
    Default=false, Column=1,
    Callback=function(v) S.tweenEmber=v; notify(v and "Auto Tween Dragon Ember ON!" or "Auto Tween Dragon Ember OFF!","laced.club",2) end
})

miscTab:AddToggle("teleport_ember", {
    Text="Auto Tp Azure Embers", Description="Auto tps to azure embers",
    Default=false, Column=1,
    Callback=function(v) S.teleportEmber=v; notify(v and "Auto Tp Azure Embers ON!" or "Auto Tp Azure Embers OFF!","laced.club",2) end
})

miscTab:AddToggle("teleport_kitsune", {
    Text="Goto Kitsune Island", Description="Tweens to Kitsune Island shrine (2s scan)",
    Default=false, Column=1,
    Callback=function(v) S.teleportKitsune=v; notify(v and "Goto Kitsune Island ON!" or "Goto Kitsune Island OFF!","laced.club",2) end
})

miscTab:AddSection("Sea", { Column = 2 })

