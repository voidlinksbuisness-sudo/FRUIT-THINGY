local boatSeatOptions={"No boats found"}
local boatSeatByLabel={}
local lastBoatSeatSignature=""

local function findBoatVehicleSeat(boat)
    if not boat then return nil end
    local okDirect,directSeat=pcall(function() return boat:FindFirstChildOfClass("VehicleSeat") end)
    if okDirect and directSeat then return directSeat end
    local okDescendants,descendants=pcall(function() return boat:GetDescendants() end)
    if okDescendants and descendants then
        for _,object in pairs(descendants) do
            local okClass,className=pcall(function() return object.ClassName end)
            if okClass and className=="VehicleSeat" then return object end
        end
    end
    return nil
end

local function refreshBoatSeatList()
    local entries={}
    local boats=game.Workspace:FindFirstChild("Boats")
    local okChildren,children=pcall(function() return boats and boats:GetChildren() end)
    if okChildren and children then
        for _,boat in pairs(children) do
            local seat=findBoatVehicleSeat(boat)
            if seat then
                local okName,name=pcall(function() return boat.Name end)
                name=(okName and type(name)=="string" and name~="") and name or "Boat"
                local okAddress,address=pcall(function() return seat.Address end)
                local key=(okAddress and address and address~=0) and tostring(address) or tostring(seat)
                table.insert(entries,{name=name,seat=seat,key=key})
            end
        end
    end

    table.sort(entries,function(a,b)
        if a.name==b.name then return a.key<b.key end
        return a.name<b.name
    end)

    local totals={}
    for _,entry in ipairs(entries) do totals[entry.name]=(totals[entry.name] or 0)+1 end
    local used={}
    local nextLabels={}
    local nextMap={}
    local selectedLabel=nil
    for _,entry in ipairs(entries) do
        used[entry.name]=(used[entry.name] or 0)+1
        local label=entry.name
        if totals[entry.name]>1 then label=label.." #"..tostring(used[entry.name]) end
        table.insert(nextLabels,label)
        nextMap[label]=entry.seat
        if entry.seat==S.selectedBoatSeat then selectedLabel=label end
    end

    if #nextLabels==0 then
        nextLabels={"No boats found"}
        nextMap={}
    end

    boatSeatByLabel=nextMap
    local signature=table.concat(nextLabels,"|")
    if signature~=lastBoatSeatSignature then
        for index=#boatSeatOptions,1,-1 do boatSeatOptions[index]=nil end
        for _,label in ipairs(nextLabels) do table.insert(boatSeatOptions,label) end
        lastBoatSeatSignature=signature
    end

    if not selectedLabel and S.selectedBoatSeatLabel and nextMap[S.selectedBoatSeatLabel] then
        selectedLabel=S.selectedBoatSeatLabel
    end
    if not selectedLabel then selectedLabel=nextLabels[1] end
    local selectedSeat=nextMap[selectedLabel]
    if selectedLabel~=S.selectedBoatSeatLabel or selectedSeat~=S.selectedBoatSeat then
        Window:Set("boat_seat_target",selectedLabel)
    end
end

miscTab:AddDropdown("boat_seat_target", {
    Text="Boat Seat", Description="Select a spawned boat seat to travel to",
    Options=boatSeatOptions, Default=boatSeatOptions[1], MaxVisible=8, Column=2,
    Callback=function(value)
        S.selectedBoatSeatLabel=value
        S.selectedBoatSeat=boatSeatByLabel[value]
    end
})

miscTab:AddToggle("auto_boat_seat", {
    Text="Auto Go To Seat", Description="Teleports to the selected seat until you are sitting in it",
    Default=false, Column=2,
    Callback=function(v)
        S.autoBoatSeat=v
        if v then refreshBoatSeatList() end
        notify(v and "Auto Boat Seat ON!" or "Auto Boat Seat OFF!","laced.club",2)
    end
})

miscTab:AddButton("refresh_boat_seats", {
    Text="Refresh Boat Seats", Description="Rescan Workspace.Boats now", Column=2,
    Callback=function() refreshBoatSeatList() end
})

miscTab:AddToggle("boat_fly", {
    Text="Boat Fly", Description="Fly your boat with WASD, Space, Shift",
    Default=false, Keybind=true, Column=2,
    Callback=function(v)
        S.boatFlyEnabled=v
        if not v then S.boatTweening=false end
        notify(v and "Boat Fly ON!" or "Boat Fly OFF!","laced.club",2)
    end
})

miscTab:AddSlider("boat_fly_speed", {
    Text="Fly Speed", Description="Speed of boat fly (default 5)",
    Min=1, Max=20, Step=1, Default=5, Integer=true, Column=2,
    Callback=function(v) S.boatFlySpeed=v end
})

miscTab:AddDropdown("danger_level", {
    Text="Danger Level", Description="Fly boat to selected danger level",
    Options=dangerLevelNames, Default=dangerLevelNames[1], MaxVisible=6, Column=2,
    Callback=function(v)
        for _, d in pairs(dangerLevels) do
            if d.name==v then
                S.boatTweening=false; task.wait(0.05)
                notify("Going to "..d.name.."...","laced.club",2)
                task.spawn(function() boatTweenTo(d.pos) end)
                break
            end
        end
    end
})

miscTab:AddButton("stop_boat", {
    Text="Stop", Description="Stop current boat tween", Column=2,
    Callback=function() S.boatTweening=false; notify("Stopped!","laced.club",2) end
})

local function isUsingSelectedBoatSeat(seat,char,humanoid,hrp)
    local okOccupant,occupant=pcall(function() return seat.Occupant end)
    if okOccupant and occupant then
        if occupant==humanoid then return true end
        local okParent,parent=pcall(function() return occupant.Parent end)
        return okParent and parent==char
    end

    local okSeatPart,seatPart=pcall(function() return humanoid and humanoid.SeatPart end)
    if okSeatPart and seatPart then return seatPart==seat end
    if okOccupant or okSeatPart then return false end

    local okPositions,seatPos,playerPos=pcall(function() return seat.Position,hrp.Position end)
    if not okPositions or not seatPos or not playerPos then return false end
    local dx=seatPos.X-playerPos.X
    local dy=seatPos.Y-playerPos.Y
    local dz=seatPos.Z-playerPos.Z
    return dx*dx+dy*dy+dz*dz<=25
end

task.spawn(function()
    refreshBoatSeatList()
    while true do
        task.wait(1)
        refreshBoatSeatList()
    end
end)

local dinoBoneTarget=nil

local function getDinoBonePart(object)
    if not object or not object.Parent then return nil end
    if object:IsA("BasePart") then return object end
    local part=object:FindFirstChild("HumanoidRootPart")
    if not part and object:IsA("Model") then part=object.PrimaryPart end
    return part or object:FindFirstChildWhichIsA("BasePart")
end

local function findNearestDinoBone(playerRoot)
    local nearest=nil
    local nearestDistance=math.huge
    local playerPos=playerRoot.Position
    for _,object in pairs(game.Workspace:GetChildren()) do
        if object.Name=="DinoBone" then
            local part=getDinoBonePart(object)
            if part then
                local partPos=part.Position
                local dx=partPos.X-playerPos.X
                local dy=partPos.Y-playerPos.Y
                local dz=partPos.Z-playerPos.Z
                local distanceSquared=dx*dx+dy*dy+dz*dz
                if distanceSquared<nearestDistance then
                    nearestDistance=distanceSquared
                    nearest=object
                end
            end
        end
    end
    return nearest
end

task.spawn(function()
    while true do
        task.wait()
        if S.autoDinoBone then
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bonePart=getDinoBonePart(dinoBoneTarget)
                if not bonePart then
                    dinoBoneTarget=findNearestDinoBone(hrp)
                    bonePart=getDinoBonePart(dinoBoneTarget)
                end
                if bonePart then
                    local bonePos=bonePart.Position
                    hrp.Position=Vector3.new(bonePos.X,bonePos.Y,bonePos.Z)
                    hrp.Velocity=Vector3.new(0,0,0)
                    hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end
            end
        else
            dinoBoneTarget=nil
        end
    end
end)

task.spawn(function()
    while true do
        if S.autoBoatSeat then
            local seat=S.selectedBoatSeat
            local char=LocalPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
            local humanoid=char and char:FindFirstChildOfClass("Humanoid") or nil
            local okSeat,seatParent,seatPos=pcall(function()
                return seat and seat.Parent,seat and seat.Position
            end)
            if seat and char and hrp and humanoid and okSeat and seatParent and seatPos
                and not isUsingSelectedBoatSeat(seat,char,humanoid,hrp) then
                pcall(function()
                    hrp.Position=Vector3.new(seatPos.X,seatPos.Y+2,seatPos.Z)
                    hrp.Velocity=Vector3.new(0,0,0)
                    hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                end)
            end
        end
        task.wait()
    end
end)

mainTab:AddSection("Games", { Column = 2 })

mainTab:AddToggle("auto_raid", {
    Text="Auto Raid", Description="Tracks each raid island, travels 100 studs above it, then farms its enemies",
    Default=false, Keybind=true, Column=2,
    Callback=function(v)
        S.autoRaid=v
        S.raidTweenActive=false
        S.raidDetected=false
        S.raidLastIslandNum=0
        S.raidLastIslandKey=nil
        S.raidMapKey=nil
        S.raidMoveGeneration=S.raidMoveGeneration+1
        notify(v and "Auto Raid ON!" or "Auto Raid OFF!","laced.club",2)
    end
})

mainTab:AddToggle("auto_mastery", {
    Text="Auto Mastery", Description="Goto ChocolateIsland And use buddha transformation",
    Default=false, Keybind=true, Column=2,
    Callback=function(v)
        S.autoMastery=v
        notify(v and "Auto Mastery ON!" or "Auto Mastery OFF!","laced.club",2)
    end
})

otherTab:AddSection("Custom Pull", { Column = 1 })

otherTab:AddToggle("custom_pull", {
    Text="Custom Pull", Description="Pulls all enemies to a custom XYZ offset relative to you",
    Default=false, Column=1,
    Callback=function(v) S.customPull=v; notify(v and "Custom Pull ON!" or "Custom Pull OFF!","laced.club",2) end
})

otherTab:AddSlider("custom_pull_x", {
    Text="Pull X Offset", Description="X offset from your position",
    Min=-100, Max=100, Step=1, Default=0, Integer=true, Column=1,
    Callback=function(v) S.customPullX=v end
})

otherTab:AddSlider("custom_pull_y", {
    Text="Pull Y Offset", Description="Y offset from your position",
    Min=-100, Max=100, Step=1, Default=-10, Integer=true, Column=1,
    Callback=function(v) S.customPullY=v end
})

otherTab:AddSlider("custom_pull_z", {
    Text="Pull Z Offset", Description="Z offset from your position",
    Min=-100, Max=100, Step=1, Default=0, Integer=true, Column=1,
    Callback=function(v) S.customPullZ=v end
})

otherTab:AddSection("Tween Settings", { Column = 1 })

