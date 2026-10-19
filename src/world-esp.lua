local espFolderSnapshots={}

local function trackedInstanceKey(instance)
    local okAddress,address=pcall(function() return instance.Address end)
    if okAddress and address and address~=0 then return tostring(address) end
    return tostring(instance)
end

local function trackedSetChanged(snapshotName,current)
    local previous=espFolderSnapshots[snapshotName]
    espFolderSnapshots[snapshotName]=current
    if not previous then return true end
    for key in pairs(current) do
        if not previous[key] then return true end
    end
    for key in pairs(previous) do
        if not current[key] then return true end
    end
    return false
end

local function trackedFolderChanged(snapshotName,folder)
    local current={}
    if folder then
        current["folder:"..trackedInstanceKey(folder)]=true
        local okChildren,children=pcall(function() return folder:GetChildren() end)
        if okChildren and children then
            for _,child in pairs(children) do
                current["child:"..trackedInstanceKey(child)]=true
            end
        end
    end
    return trackedSetChanged(snapshotName,current)
end

local function trackedFlowersChanged()
    local current={}
    for _,name in ipairs({"Flower1","Flower2"}) do
        local flower=game.Workspace:FindFirstChild(name)
        if flower then current[name..":"..trackedInstanceKey(flower)]=true end
    end
    return trackedSetChanged("flowers",current)
end

-- Chest discovery holds metadata only; drawings are a bounded reusable pool.
local CHEST_SCAN_BATCH = 32
local CHEST_LABEL_LIMIT = 128
local CHEST_DISTANCE_SQ = 100000000

function buildChestEspLabels()
    if not S.chestEsp or S.chestEspScanRunning then return end
    S.chestEspGeneration = S.chestEspGeneration or 0
    local generation = S.chestEspGeneration
    S.chestEspScanRunning = true
    task.spawn(function()
        local ok = pcall(function()
            local chestModels = game.Workspace:FindFirstChild("ChestModels")
            local children = chestModels and chestModels:GetChildren() or {}
            local entries = {}
            for index, chest in ipairs(children) do
                if not S.chestEsp or S.chestEspGeneration ~= generation then return end
                local valid, part, chestName = pcall(function()
                    return chest:FindFirstChild("RootPart") or chest:FindFirstChildOfClass("BasePart"), chest.Name
                end)
                if valid and part then
                    chestName = type(chestName) == "string" and chestName ~= "" and chestName or "Chest"
                    local color = Color3.fromRGB(235,235,235)
                    if chestName == "SilverChest" then color = Color3.fromRGB(165,165,165)
                    elseif chestName == "GoldChest" then color = Color3.fromRGB(255,215,55)
                    elseif chestName == "DiamondChest" then color = Color3.fromRGB(85,205,255) end
                    entries[#entries + 1] = {part = part, name = chestName, color = color}
                end
                if index % CHEST_SCAN_BATCH == 0 then task.wait(0.01) end
            end
            if S.chestEsp and S.chestEspGeneration == generation then S.chestEspLabels = entries end
        end)
        if S.chestEspGeneration == generation then
            S.chestEspScanRunning = false
            if not ok then S.chestEspLabels = {} end
        end
    end)
end

function updateChestEspLabels()
    if not S.chestEsp then return end
    local generation = S.chestEspGeneration or 0
    local character = LocalPlayer and LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local okPlayer, playerPosition = pcall(function() return root and root.Position end)
    local candidates = {}
    if okPlayer and playerPosition then
        local entries = S.chestEspLabels
        for index, entry in ipairs(entries) do
            if not S.chestEsp or (S.chestEspGeneration or 0) ~= generation then return end
            local valid, position = pcall(function()
                if entry.part and entry.part.Parent then return entry.part.Position end
            end)
            if valid and position then
                local dx, dy, dz = position.X-playerPosition.X, position.Y-playerPosition.Y, position.Z-playerPosition.Z
                local distance = dx*dx + dy*dy + dz*dz
                if distance <= CHEST_DISTANCE_SQ then
                    local okScreen, screen, onScreen = pcall(function() return WorldToScreen(position) end)
                    if okScreen and screen and onScreen then
                        candidates[#candidates + 1] = {entry = entry, distance = distance, screen = screen}
                    end
                end
            end
            if index % CHEST_SCAN_BATCH == 0 then task.wait(0.01) end
        end
    end
    if not S.chestEsp or (S.chestEspGeneration or 0) ~= generation then return end
    table.sort(candidates, function(a,b) return a.distance < b.distance end)
    local count = math.min(CHEST_LABEL_LIMIT, #candidates)
    for index = 1, count do
        if not S.chestEsp or (S.chestEspGeneration or 0) ~= generation then return end
        local candidate = candidates[index]
        local cached = S.chestEspLabelCache[index]
        if not cached then
            local label = Drawing.new("Text")
            label.Size, label.Outline, label.ZIndex = 14, true, 10
            label.Font, label.Center, label.Visible = Drawing.Fonts.Monospace, true, false
            cached = {label = label}
            S.chestEspLabelCache[index] = cached
        end
        local label, entry = cached.label, candidate.entry
        if cached.name ~= entry.name then label.Text = entry.name; cached.name = entry.name end
        if cached.color ~= entry.color then label.Color = entry.color; cached.color = entry.color end
        label.Position = Vector2.new(candidate.screen.X, candidate.screen.Y - 20)
        if not cached.visible then label.Visible = true; cached.visible = true end
        if index % 16 == 0 then task.wait(0.01) end
    end
    for index = count + 1, #S.chestEspLabelCache do
        local cached = S.chestEspLabelCache[index]
        if cached.visible then cached.label.Visible = false; cached.visible = false end
    end
end

local function getBoatEspKey(boat)
    local okAddress,address=pcall(function() return boat.Address end)
    if okAddress and address and address~=0 then return "boat:"..tostring(address) end
    return "boat:"..tostring(boat)
end

local function getBoatEspParts(boat)
    local parts={}
    local okBase,isBase=pcall(function() return boat:IsA("BasePart") end)
    if okBase and isBase==true then table.insert(parts,boat) end
    local okDescendants,descendants=pcall(function() return boat:GetDescendants() end)
    if okDescendants and descendants then
        for _,object in pairs(descendants) do
            local okPart,isPart=pcall(function() return object:IsA("BasePart") end)
            if okPart and isPart==true then table.insert(parts,object) end
        end
    end
    return parts
end

local function getBoatEspBounds(parts)
    local minX,minY,minZ=math.huge,math.huge,math.huge
    local maxX,maxY,maxZ=-math.huge,-math.huge,-math.huge
    local found=false
    for _,part in pairs(parts or {}) do
        local okParent,parent=pcall(function() return part.Parent end)
        local okData,pos,size=pcall(function() return part.Position,part.Size end)
        if okParent and parent and okData and pos and size then
            local halfX,halfY,halfZ=size.X/2,size.Y/2,size.Z/2
            if pos.X-halfX<minX then minX=pos.X-halfX end
            if pos.Y-halfY<minY then minY=pos.Y-halfY end
            if pos.Z-halfZ<minZ then minZ=pos.Z-halfZ end
            if pos.X+halfX>maxX then maxX=pos.X+halfX end
            if pos.Y+halfY>maxY then maxY=pos.Y+halfY end
            if pos.Z+halfZ>maxZ then maxZ=pos.Z+halfZ end
            found=true
        end
    end
    if not found then return nil end
    return minX,minY,minZ,maxX,maxY,maxZ
end

function buildBoatEsp()
    for _,entry in pairs(S.boatEspCache) do
        if entry.label then entry.label.Visible=false end
        for _,line in pairs(entry.lines or {}) do line.Visible=false end
    end
    S.boatEspEntries={}

    local boats=game.Workspace:FindFirstChild("Boats")
    if not boats then return end
    local okChildren,children=pcall(function() return boats:GetChildren() end)
    if not okChildren or not children then return end

    for _,boat in pairs(children) do
        local parts=getBoatEspParts(boat)
        if #parts>0 then
            local anchor=nil
            pcall(function() anchor=boat.PrimaryPart end)
            if not anchor then
                for _,part in pairs(parts) do
                    local okClass,className=pcall(function() return part.ClassName end)
                    if okClass and className=="VehicleSeat" then anchor=part; break end
                end
            end
            if not anchor then anchor=parts[1] end

            local minX,minY,minZ,maxX,maxY,maxZ=getBoatEspBounds(parts)
            local okAnchor,anchorPos=pcall(function() return anchor and anchor.Position end)
            if anchor and minX and okAnchor and anchorPos then
            local bounds={
                minX=minX-anchorPos.X,minY=minY-anchorPos.Y,minZ=minZ-anchorPos.Z,
                maxX=maxX-anchorPos.X,maxY=maxY-anchorPos.Y,maxZ=maxZ-anchorPos.Z,
            }
            local key=getBoatEspKey(boat)
            local okName,boatName=pcall(function() return boat.Name end)
            boatName=(okName and type(boatName)=="string" and boatName~="") and boatName or "Boat"
            local entry=S.boatEspCache[key]
            if not entry then
                local lines={}
                for _=1,12 do
                    local line=Drawing.new("Line")
                    line.Color=Color3.fromRGB(40,190,255)
                    line.Thickness=2
                    line.Visible=false
                    line.ZIndex=10
                    table.insert(lines,line)
                end
                local label=Drawing.new("Text")
                label.Text=boatName
                label.Position=Vector2.new(0,0)
                label.Color=Color3.fromRGB(90,215,255)
                label.Size=18
                label.Outline=true
                label.Center=true
                label.Font=Drawing.Fonts.Monospace
                label.Visible=false
                label.ZIndex=11
                entry={boat=boat,anchor=anchor,bounds=bounds,name=boatName,lines=lines,label=label}
                S.boatEspCache[key]=entry
            else
                entry.boat=boat
                entry.anchor=anchor
                entry.bounds=bounds
                entry.name=boatName
                entry.label.Text=boatName
            end
            table.insert(S.boatEspEntries,entry)
            end
        end
    end
end

local FLOWER_ESP_TARGETS={
    {workspaceName="Flower1",label="Blue Flower",color=Color3.fromRGB(55,145,255)},
    {workspaceName="Flower2",label="Red Flower",color=Color3.fromRGB(255,65,65)},
}

local function getFlowerEspKey(flowerName,flower)
    local okAddress,address=pcall(function() return flower.Address end)
    if okAddress and address and address~=0 then
        return "flower:"..flowerName..":"..tostring(address)
    end
    return "flower:"..flowerName..":"..tostring(flower)
end

function buildFlowerEsp()
    for _,entry in pairs(S.flowerEspCache) do
        if entry.label then entry.label.Visible=false end
        for _,line in pairs(entry.lines or {}) do line.Visible=false end
    end
    S.flowerEspEntries={}

    for _,target in ipairs(FLOWER_ESP_TARGETS) do
        local flower=game.Workspace:FindFirstChild(target.workspaceName)
        if flower then
            local parts=getBoatEspParts(flower)
            if #parts>0 then
                local anchor=nil
                local okPrimary,primary=pcall(function() return flower.PrimaryPart end)
                if okPrimary and primary then anchor=primary end
                if not anchor then anchor=parts[1] end

                local minX,minY,minZ,maxX,maxY,maxZ=getBoatEspBounds(parts)
                local okAnchor,anchorPos=pcall(function() return anchor and anchor.Position end)
                if anchor and minX and okAnchor and anchorPos then
                    local bounds={
                        minX=minX-anchorPos.X,minY=minY-anchorPos.Y,minZ=minZ-anchorPos.Z,
                        maxX=maxX-anchorPos.X,maxY=maxY-anchorPos.Y,maxZ=maxZ-anchorPos.Z,
                    }
                    local key=getFlowerEspKey(target.workspaceName,flower)
                    local entry=S.flowerEspCache[key]
                    if not entry then
                        local lines={}
                        for _=1,12 do
                            local line=Drawing.new("Line")
                            line.Color=target.color
                            line.Thickness=2
                            line.Visible=false
                            line.ZIndex=10
                            table.insert(lines,line)
                        end
                        local label=Drawing.new("Text")
                        label.Text=target.label
                        label.Position=Vector2.new(0,0)
                        label.Color=target.color
                        label.Size=18
                        label.Outline=true
                        label.Center=true
                        label.Font=Drawing.Fonts.Monospace
                        label.Visible=false
                        label.ZIndex=11
                        entry={flower=flower,anchor=anchor,bounds=bounds,name=target.label,lines=lines,label=label}
                        S.flowerEspCache[key]=entry
                    else
                        entry.flower=flower
                        entry.anchor=anchor
                        entry.bounds=bounds
                        entry.name=target.label
                        entry.label.Text=target.label
                        entry.label.Color=target.color
                        for _,line in pairs(entry.lines) do line.Color=target.color end
                    end
                    table.insert(S.flowerEspEntries,entry)
                end
            end
        end
    end
end

local ESP_BOX_EDGES={
    {1,2},{2,4},{4,3},{3,1},
    {5,6},{6,8},{8,7},{7,5},
    {1,5},{2,6},{3,7},{4,8},
}

local function updateWorldBoxEntry(entry)
    local visible=false
    local okAnchor,anchorParent,anchorPos=pcall(function()
        return entry.anchor and entry.anchor.Parent,entry.anchor and entry.anchor.Position
    end)
    local bounds=entry.bounds
    if okAnchor and anchorParent and anchorPos and bounds then
        local minX=anchorPos.X+bounds.minX
        local minY=anchorPos.Y+bounds.minY
        local minZ=anchorPos.Z+bounds.minZ
        local maxX=anchorPos.X+bounds.maxX
        local maxY=anchorPos.Y+bounds.maxY
        local maxZ=anchorPos.Z+bounds.maxZ
        local corners=entry.worldCorners or {}
        entry.worldCorners=corners
        corners[1]=Vector3.new(minX,minY,minZ)
        corners[2]=Vector3.new(maxX,minY,minZ)
        corners[3]=Vector3.new(minX,maxY,minZ)
        corners[4]=Vector3.new(maxX,maxY,minZ)
        corners[5]=Vector3.new(minX,minY,maxZ)
        corners[6]=Vector3.new(maxX,minY,maxZ)
        corners[7]=Vector3.new(minX,maxY,maxZ)
        corners[8]=Vector3.new(maxX,maxY,maxZ)

        local screenPoints=entry.screenPoints or {}
        entry.screenPoints=screenPoints
        local screenMinX,screenMinY=math.huge,math.huge
        local screenMaxX=-math.huge
        local projectedCount=0
        for index=1,8 do
            local okScreen,screenPos,onScreen=pcall(function() return WorldToScreen(corners[index]) end)
            if okScreen and screenPos and onScreen==true then
                screenPoints[index]=screenPos
                projectedCount=projectedCount+1
                if screenPos.X<screenMinX then screenMinX=screenPos.X end
                if screenPos.Y<screenMinY then screenMinY=screenPos.Y end
                if screenPos.X>screenMaxX then screenMaxX=screenPos.X end
            else
                break
            end
        end

        if projectedCount==8 then
            for index,edge in ipairs(ESP_BOX_EDGES) do
                entry.lines[index].From=screenPoints[edge[1]]
                entry.lines[index].To=screenPoints[edge[2]]
            end
            entry.label.Position=Vector2.new((screenMinX+screenMaxX)/2,screenMinY-20)
            visible=true
        end
    end

    for _,line in pairs(entry.lines) do line.Visible=visible end
    entry.label.Visible=visible
end

