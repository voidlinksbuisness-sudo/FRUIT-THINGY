local jobs, children = {}, {}
local created, alive, maxAlive, projections = 0, 0, 0, 0
task = {}
function task.spawn(fn) jobs[#jobs + 1] = coroutine.create(fn) end
function task.wait() coroutine.yield() end
local function step()
    local thread = table.remove(jobs, 1)
    if not thread then return end
    projections = 0
    local ok, message = coroutine.resume(thread)
    assert(ok, message)
    assert(projections <= 32, "Projection work exceeded one batch")
    if coroutine.status(thread) ~= "dead" then jobs[#jobs + 1] = thread end
end
local function drain()
    local steps = 0
    while #jobs > 0 do
        step()
        steps = steps + 1
        assert(steps < 10000, "Worker did not finish")
    end
end
Drawing = {Fonts = {Monospace = 1}}
function Drawing.new(kind)
    assert(kind == "Text")
    created, alive = created + 1, alive + 1
    maxAlive = math.max(maxAlive, alive)
    assert(alive <= 128, "Drawing pool leaked or exceeded its limit")
    local label = {}
    function label:Remove()
        assert(not self.removed)
        self.removed = true
        alive = alive - 1
    end
    return label
end
Vector2 = {new = function(x,y) return {X=x,Y=y} end}
Color3 = {fromRGB = function(r,g,b) return r .. ":" .. g .. ":" .. b end}
function WorldToScreen(pos)
    projections = projections + 1
    return Vector2.new(pos.X, pos.Y), pos.Z >= 0
end
local root = {Position = {X=0,Y=0,Z=0}}
LocalPlayer = {Character = {FindFirstChild = function() return root end}}
local folder = {GetChildren = function() return children end}
game = {Workspace = {FindFirstChild = function() return folder end}}
S = {chestEsp = true, chestEspLabels = {}, chestEspLabelCache = {}}
assert(load(chestSource))()
local function populate(count, offset)
    children = {}
    for i = 1, count do
        local part = {Parent = folder, Position = {X=i+(offset or 0),Y=0,Z=1}}
        children[i] = {
            Name = i % 2 == 0 and "GoldChest" or "DiamondChest",
            FindFirstChild = function() return part end,
        }
    end
end
local function update()
    task.spawn(updateChestEspLabels)
    drain()
end
populate(2000)
buildChestEspLabels()
assert(created == 0, "Discovery should never allocate drawings")
drain()
assert(#S.chestEspLabels == 2000 and not S.chestEspScanRunning and created == 0)
update()
assert(alive == 128 and created == 128 and maxAlive == 128)
assert(S.chestEspLabelCache[1].label.Position.X == 1)
assert(S.chestEspLabelCache[128].label.Position.X == 128)
-- Entirely new chest instances must reuse slots rather than grow the old cache.
for wave = 1, 8 do
    populate(500, wave * 100)
    buildChestEspLabels()
    drain()
    update()
    assert(created == 128 and alive == 128 and #S.chestEspLabels == 500)
end
-- Removed and invalid parts must not crash the worker.
for _, entry in ipairs(S.chestEspLabels) do entry.part.Parent = nil end
S.chestEspLabels[1].part = setmetatable({}, {__index = function() error("destroyed instance") end})
update()
for _, slot in ipairs(S.chestEspLabelCache) do assert(not slot.label.Visible) end
-- Respawning player and absent chest folder are handled without stale drawings.
root = nil
update()
folder = nil
buildChestEspLabels()
drain()
assert(#S.chestEspLabels == 0)
root = {Position = {X=0,Y=0,Z=0}}
folder = {GetChildren = function() return children end}
populate(2000)
buildChestEspLabels()
step() -- Suspend discovery in the middle of a batch.
assert(S.chestEspScanRunning)
S.chestEsp = false
clearChestEspLabels()
assert(alive == 0 and #S.chestEspLabelCache == 0 and #S.chestEspLabels == 0)
S.chestEsp = true
populate(10)
buildChestEspLabels()
drain()
assert(#S.chestEspLabels == 10 and not S.chestEspScanRunning)
update()
assert(alive == 10)
-- Clear while projection is suspended; cancelled work cannot recreate labels.
populate(500)
buildChestEspLabels()
drain()
task.spawn(updateChestEspLabels)
step()
S.chestEsp = false
clearChestEspLabels()
drain()
assert(alive == 0 and #S.chestEspLabelCache == 0)
-- A fresh enable still works after cancellation.
S.chestEsp = true
populate(3)
children[2].FindFirstChild = function() return {Parent=folder, Position={X=1,Y=0,Z=-1}} end
children[3].FindFirstChild = function() return {Parent=folder, Position={X=20000,Y=0,Z=1}} end
buildChestEspLabels()
drain()
update()
assert(alive == 1, "Off-screen and out-of-range chests must not allocate drawings")
S.chestEsp = false
clearChestEspLabels()
assert(alive == 0)
