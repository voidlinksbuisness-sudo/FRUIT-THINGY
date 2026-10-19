function clearEspLabels()
    for _, entry in pairs(S.espLabels) do entry.label.Visible=false end
    S.espLabels={}
end

function clearChestEspLabels()
    for _,entry in pairs(S.chestEspLabels) do
        if entry and entry.label then entry.label.Visible=false end
    end
    S.chestEspLabels={}
end

function clearBerryEspLabels()
    for _,entry in pairs(S.berryEspLabels) do
        if entry and entry.label then entry.label.Visible=false end
    end
    S.berryEspLabels={}
end

function clearBoatEsp()
    for _,entry in pairs(S.boatEspEntries) do
        if entry and entry.label then entry.label.Visible=false end
        if entry and entry.lines then
            for _,line in pairs(entry.lines) do line.Visible=false end
        end
    end
    S.boatEspEntries={}
end

function clearFlowerEsp()
    for _,entry in pairs(S.flowerEspEntries) do
        if entry and entry.label then entry.label.Visible=false end
        if entry and entry.lines then
            for _,line in pairs(entry.lines) do line.Visible=false end
        end
    end
    S.flowerEspEntries={}
end

function clearChamBoxes()
    for _, entry in pairs(S.chamBoxes) do
        for _, line in pairs(entry.lines) do line.Visible=false end
    end
    S.chamBoxes={}
end

local BERRIES={
    {name="Green Toad Berry",   sphere="Sphere.011"},
    {name="Yellow Star Berry",  sphere="Sphere.022"},
    {name="Orange Berry",       sphere="Sphere.007"},
    {name="Red Cherry Berry",   sphere="Sphere.005"},
    {name="Purple Jelly Berry", sphere="Sphere.004"},
    {name="Pink Pig Berry",     sphere="Sphere.008"},
    {name="Blue Icicle Berry",  sphere="Sphere.018"},
    {name="White Cloud Berry",  sphere="Sphere.035"},
}

local BERRY_SPHERE_NAMES={}
for _,berry in pairs(BERRIES) do
    BERRY_SPHERE_NAMES[berry.sphere]=berry.name
end

function getSafeFruitPosition(candidate)
    if not candidate then return nil end
    local okParent, parent=pcall(function() return candidate.Parent end)
    if not okParent or not parent then return nil end
    local okPos, pos=pcall(function() return candidate.Position end)
    if okPos and pos and pos.X and pos.Y and pos.Z then return pos end
    return nil
end

function resolveFruitPart(root)
    if not root then return nil end

    local okClass, className=pcall(function() return root.ClassName end)
    if okClass and className=="Tool" then
        local okHandle, handle=pcall(function() return root:FindFirstChild("Handle") end)
        if okHandle and handle and getSafeFruitPosition(handle) then return handle end
        local okBasePart, basePart=pcall(function() return root:FindFirstChildOfClass("BasePart") end)
        if okBasePart and basePart and getSafeFruitPosition(basePart) then return basePart end
    end

    if getSafeFruitPosition(root) then return root end
    for _, childName in pairs({"Handle", "Fruit"}) do
        local okChild, child=pcall(function() return root:FindFirstChild(childName) end)
        if okChild and child then
            if getSafeFruitPosition(child) then return child end
            local okInner, inner=pcall(function() return child:FindFirstChild("Fruit") end)
            if okInner and inner and getSafeFruitPosition(inner) then return inner end
        end
    end
    local okDesc, descendants=pcall(function() return root:GetDescendants() end)
    if okDesc and descendants then
        for _, descendant in pairs(descendants) do
            if getSafeFruitPosition(descendant) then return descendant end
        end
    end
    return nil
end

function getFruitInstanceKey(part)
    local okAddress, address=pcall(function() return part.Address end)
    if okAddress and address and address~=0 then return "addr:"..tostring(address) end

    local pos=getSafeFruitPosition(part)
    if pos then
        return tostring(part)..":"..tostring(pos.X)..":"..tostring(pos.Y)..":"..tostring(pos.Z)
    end
    return tostring(part)
end

function getWorkspaceFruits()
    local fruits, seen={}, {}
    local okChildren, children=pcall(function() return game.Workspace:GetChildren() end)
    if not okChildren or not children then return fruits end
    local function addFruit(root, displayName)
        local part=resolveFruitPart(root)
        if not part then return end
        local partPos=getSafeFruitPosition(part)
        if not partPos then return end
        local key=getFruitInstanceKey(part)
        if seen[key] then return end

        for _, existing in pairs(fruits) do
            local existingPos=existing.position or getSafeFruitPosition(existing.part)
            if existingPos then
                local dx=partPos.X-existingPos.X
                local dy=partPos.Y-existingPos.Y
                local dz=partPos.Z-existingPos.Z
                if dx*dx+dy*dy+dz*dz<=9 then return end
            end
        end

        seen[key]=true
        table.insert(fruits, {part=part, position=partPos, name=displayName or "Spawned Fruit"})
    end
    for _, obj in pairs(children) do
        local okName, objName=pcall(function() return obj.Name end)
        objName=okName and objName or ""
        local lowerName=string.lower(objName)
        if string.match(lowerName, "fruit") then
            addFruit(obj, objName)
        end

        local okFolder, fruitFolder=pcall(function() return obj:FindFirstChild("Fruit") end)
        if okFolder and fruitFolder then
            local fruitName=(objName~="" and objName~="Fruit" and objName) or "Spawned Fruit"
            addFruit(fruitFolder, fruitName)
        end
    end
    return fruits
end

function buildChamBoxes()
    for _, entry in pairs(S.chamBoxCache) do
        for _, line in pairs(entry.lines) do line.Visible=false end
    end
    S.chamBoxes={}
    for _, fruit in pairs(getWorkspaceFruits()) do
        local fruitPart=fruit.part
        local key=getFruitInstanceKey(fruitPart)
        if not S.chamBoxCache[key] then
            local lines={}
            for i=1,4 do
                local l=Drawing.new("Line")
                l.Color=Color3.new(1,0.4,0); l.Thickness=2; l.Visible=false; l.ZIndex=9
                table.insert(lines,l)
            end
            S.chamBoxCache[key]={lines=lines, part=fruitPart}
        else
            S.chamBoxCache[key].part=fruitPart
        end
        table.insert(S.chamBoxes, S.chamBoxCache[key])
    end
end

function getFruitIslandName(position)
    if not position or type(islandList)~="table" then return "Unknown" end
    local closestName="Unknown"
    local closestDistanceSq=math.huge
    for _,island in pairs(islandList) do
        local islandPosition=island and island.pos or nil
        if islandPosition then
            local dx=position.X-islandPosition.X
            local dz=position.Z-islandPosition.Z
            local distanceSq=dx*dx+dz*dz
            if distanceSq<closestDistanceSq then
                closestDistanceSq=distanceSq
                closestName=island.name or "Unknown"
            end
        end
    end
    if closestDistanceSq>625000000 then return "Sea" end
    return closestName
end

function buildEspLabels()
    for _, entry in pairs(S.espLabelCache) do entry.label.Visible=false end
    S.espLabels={}
    for _, fruit in pairs(getWorkspaceFruits()) do
        local fruitPart, fruitName=fruit.part, fruit.name
        local fruitPosition=fruit.position or getSafeFruitPosition(fruitPart)
        local displayText=fruitName.." ["..getFruitIslandName(fruitPosition).."]"
        local key=getFruitInstanceKey(fruitPart)
        if not S.espLabelCache[key] then
            local label=Drawing.new("Text")
            label.Text=displayText; label.Position=Vector2.new(0,0)
            label.Color=Color3.new(0,1,0); label.Size=14; label.Outline=true
            label.Visible=false; label.ZIndex=10; label.Font=Drawing.Fonts.Monospace; label.Center=true
            S.espLabelCache[key]={label=label, part=fruitPart}
        else
            S.espLabelCache[key].label.Text=displayText
            S.espLabelCache[key].part=fruitPart
        end
        table.insert(S.espLabels, S.espLabelCache[key])
    end
end

local berryScanRunning=false
local BERRY_SCAN_BATCH=80
local BERRY_DRAW_DISTANCE=10000
local BERRY_DRAW_DISTANCE_SQ=BERRY_DRAW_DISTANCE*BERRY_DRAW_DISTANCE

local function isBerryWorldObject(object)
    local current=object
    for _=1,64 do
        if not current then return false end
        local okInfo,parent,className=pcall(function()
            return current.Parent,current.ClassName
        end)
        if not okInfo then return false end
        if className=="Tool" then return false end
        local okHumanoid,humanoid=pcall(function()
            return current:FindFirstChildOfClass("Humanoid")
        end)
        if okHumanoid and humanoid then return false end
        if parent==game.Workspace then return true end
        current=parent
    end
    return false
end

function buildBerryEspLabels()
    if berryScanRunning then
        return
    end

    berryScanRunning=true
    task.spawn(function()
        local activeEntries={}
        local activeKeys={}
        local publishedKeys={}
        local queue={}
        local queueIndex=1
        local processed=0

        local char=LocalPlayer and LocalPlayer.Character or nil
        local hrp=char and char:FindFirstChild("HumanoidRootPart") or nil
        local okPlayer,playerPos=pcall(function() return hrp and hrp.Position end)

        for _,published in pairs(S.berryEspLabels) do
            if published and published.key then publishedKeys[published.key]=true end
        end

        local okRoots,roots=pcall(function() return game.Workspace:GetChildren() end)
        if okRoots and roots then
            for _,root in pairs(roots) do table.insert(queue,root) end
        end

        while S.berryEsp and queueIndex<=#queue do
            local object=queue[queueIndex]
            queueIndex=queueIndex+1

            local okName,objectName=pcall(function() return object.Name end)
            local berryName=okName and BERRY_SPHERE_NAMES[objectName] or nil
            if berryName and isBerryWorldObject(object) then
                local berryPart=object
                local berryPos=getSafeFruitPosition(berryPart)
                if not berryPos then
                    local okPart,part=pcall(function()
                        return object.PrimaryPart or object:FindFirstChildOfClass("BasePart")
                    end)
                    if okPart and part then
                        berryPart=part
                        berryPos=getSafeFruitPosition(berryPart)
                    end
                end
                local inRange=berryPos~=nil
                if inRange and okPlayer and playerPos then
                    local dx=berryPos.X-playerPos.X
                    local dy=berryPos.Y-playerPos.Y
                    local dz=berryPos.Z-playerPos.Z
                    inRange=(dx*dx+dy*dy+dz*dz)<=BERRY_DRAW_DISTANCE_SQ
                end

                if inRange then
                    local key=getFruitInstanceKey(berryPart)
                    local entry=S.berryEspLabelCache[key]
                    if not entry then
                        local label=Drawing.new("Text")
                        label.Text=berryName
                        label.Position=Vector2.new(0,0)
                        label.Color=Color3.new(1,0.35,0.75)
                        label.Size=28
                        label.Outline=true
                        label.Visible=false
                        label.ZIndex=12
                        label.Font=Drawing.Fonts.Monospace
                        label.Center=true
                        entry={label=label,part=berryPart,name=berryName,key=key}
                        S.berryEspLabelCache[key]=entry
                    else
                        entry.part=berryPart
                        entry.name=berryName
                        entry.key=key
                    end
                    activeKeys[key]=true
                    table.insert(activeEntries,entry)
                    if not publishedKeys[key] then
                        publishedKeys[key]=true
                        table.insert(S.berryEspLabels,entry)
                    end
                end
            end

            local okChildren,children=pcall(function() return object:GetChildren() end)
            if okChildren and children then
                for _,child in pairs(children) do table.insert(queue,child) end
            end

            processed=processed+1
            if processed>=BERRY_SCAN_BATCH then
                processed=0
                task.wait()
            end
        end

        if S.berryEsp then
            for key,entry in pairs(S.berryEspLabelCache) do
                if not activeKeys[key] and entry.label then entry.label.Visible=false end
            end
            S.berryEspLabels=activeEntries
        else
            for _,entry in pairs(activeEntries) do
                if entry.label then entry.label.Visible=false end
            end
        end

        berryScanRunning=false
    end)
end

