task={spawn=function() end,wait=function() end}
local held=nil
local melee={ToolTip='Melee',IsA=function() return true end}
local sword={ToolTip='Sword',IsA=function() return true end}
local gun={ToolTip='Gun',IsA=function() return true end}
local backpack={GetChildren=function() return {melee,sword,gun} end}
local humanoid={EquipTool=function(_,tool) held=tool end}
local char={FindFirstChildOfClass=function() return humanoid end}
LocalPlayer={Character=char,FindFirstChild=function() return backpack end}
function getCurrentlyHeldTool() return held end
function getSafeFruitPosition(p) return p and p.Position end
local moved,turned=false,false
local onscreen=true
function WorldToScreen() return {X=41.8,Y=52.9},onscreen or turned end
function mousemoveabs(x,y) assert(x==41 and y==52);moved=true end
CFrame={lookAt=function() turned=true;return {} end}
game={Workspace={CurrentCamera={CFrame={Position={}}}}}
assert(load(source))()
for _,kind in ipairs({'Melee','Sword','Gun'}) do
 held=nil
 local tool=_TEST.equip(kind,function() return true end)
 assert(_TEST.matches(tool,kind))
end
held=melee
assert(not _TEST.matches(held,'Gun'))
backpack.GetChildren=function() return {melee} end
assert(_TEST.equip('Gun',function() return true end)==nil)
assert(_TEST.aim({Position={}}) and moved)
onscreen=false;moved=false
assert(_TEST.aim({Position={}}) and turned and moved)
assert(not _TEST.aim(nil))
-- Run the shared nearest selector, using two NPCs and cancel during travel.
local function enemy(x)
 local root={Position={X=x,Y=0,Z=0}}
 local hum={Health=100}
 return {Parent=true,IsA=function() return true end,
 FindFirstChild=function(_,name) if name=='HumanoidRootPart' then return root end end,
 FindFirstChildOfClass=function(_,name) if name=='Humanoid' then return hum end end}
end
local far,near=enemy(90),enemy(10)
game.Workspace.FindFirstChild=function() return {GetChildren=function() return {far,near} end} end
S={FARM_SPEED=320,remoteMode=false,bigHitbox=false}
Vector3={new=function(x,y,z) return {X=x,Y=y,Z=z} end}
local running=true
local attacks=0
function tweenTo(_,pos,speed) assert(pos.X==10 and speed==555);running=false end
function mouse1click() attacks=attacks+1 end
assert(load(combatSource))()
getNormalFarmOffsets=function() return 0,0,0 end
farmAttack({Position={X=0,Y=0,Z=0}},function() return running end,nil,true,1000,function() attacks=attacks+1 end,0.06,{syncAttack=true,speed=555})
assert(attacks==0,'Canceled farm fired an attack')
running=true
function tweenTo() end
farmAttack({Position={X=0,Y=0,Z=0}},function() return running end,nil,true,1000,function(target,part)
 assert(target==near and part.Position.X==10)
 attacks=attacks+1;running=false
end,0,{syncAttack=true})
assert(attacks==1,'Synchronous callback did not receive nearest NPC')
