local clock=0
os.clock=function() return clock end
task={spawn=function() end,wait=function(dt) clock=clock+(dt or 0.01) end}
local held=nil
local melee={ToolTip='Melee',IsA=function() return true end}
local sword={ToolTip='Sword',IsA=function() return true end}
local gun={ToolTip='Gun',IsA=function() return true end}
local backpack={GetChildren=function() return {melee,sword,gun} end}
local humanoid={EquipTool=function(_,tool) held=tool end}
local char={FindFirstChildOfClass=function() return humanoid end}
LocalPlayer={Character=char,FindFirstChild=function() return backpack end}
function getCurrentlyHeldTool() return held end
function trackedInstanceKey(object) return tostring(object.Address or object) end
S={masterySlots={Melee=1,Sword=3,Gun=4}}
local slots={[1]=melee,[3]=sword,[4]=gun}
local presses=0
function setrobloxinput() end
function keyrelease() end
function keypress(key)
 presses=presses+1
 local tool=slots[key-0x30]
 held=held==tool and nil or tool
end
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
slots[4]=melee
assert(_TEST.equip('Gun',function() return true end)==nil)
-- External Matcha instances can throw on ToolTip and lack EquipTool.
local external=setmetatable({Address=42,IsA=function() return true end},{__index=function(_,key)
 if key=='ToolTip' then error('unsupported property') end
end})
slots[4]=external;held=nil
assert(_TEST.equip('Gun',function() return true end)==external)
local before=presses
assert(_TEST.equip('Gun',function() return true end)==external and presses==before)
S.masterySlots.Gun=5;slots[5]=gun
assert(_TEST.equip('Gun',function() return true end)==gun and presses>before)
held=nil;before=presses
assert(_TEST.equip('Gun',function() return false end)==nil and presses==before)

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

-- Only Gun mastery weakens enemies with melee, switching at exactly 20%.
local stats={Health=100,MaxHealth=100}
local target={FindFirstChildOfClass=function() return stats end}
assert(_TEST.attackWeapon("Gun",target)=="Melee")
stats.Health=20.01
assert(_TEST.attackWeapon("Gun",target)=="Melee")
stats.Health=20
assert(_TEST.attackWeapon("Gun",target)=="Gun")
stats.Health=5
assert(_TEST.attackWeapon("Gun",target)=="Gun")
for _,kind in ipairs({"Sword","Melee"}) do
 stats.Health=100;assert(_TEST.attackWeapon(kind,target)==kind)
 stats.Health=10;assert(_TEST.attackWeapon(kind,target)==kind)
end
stats.MaxHealth=0;assert(_TEST.attackWeapon("Gun",target)=="Gun")
stats.MaxHealth=nil;assert(_TEST.attackWeapon("Gun",target)=="Gun")
assert(_TEST.attackWeapon("Gun",{FindFirstChildOfClass=function() error("unsupported") end})=="Gun")

-- Fruit has an independent, adjustable weakening threshold.
S.fruitMasteryPercent=35
stats.MaxHealth=200;stats.Health=71
assert(_TEST.attackWeapon("Blox Fruit",target)=="Melee")
stats.Health=70;assert(_TEST.attackWeapon("Blox Fruit",target)=="Blox Fruit")
stats.Health=60;assert(_TEST.attackWeapon("Gun",target)=="Melee")
S.fruitMasteryPercent=100;stats.Health=200
assert(_TEST.attackWeapon("Blox Fruit",target)=="Blox Fruit")
S.fruitMasteryMoves={Z=false,X=true,C=false,V=false,F=true}
local movePresses,moveReleases={},{}
keypress=function(code) movePresses[#movePresses+1]=code end
keyrelease=function(code) moveReleases[#moveReleases+1]=code end
local alive=true
isAlive=function() return alive end
local part={Position={X=3,Y=0,Z=4}}
local fruitTarget={FindFirstChild=function() return part end}
clock=10
assert(_TEST.castFruitMove(fruitTarget,part,function() return true end))
assert(movePresses[1]==string.byte('X') and moveReleases[1]==movePresses[1])
assert(_TEST.castFruitMove(fruitTarget,part,function() return true end))
assert(movePresses[2]==string.byte('F') and moveReleases[2]==movePresses[2])
assert(not _TEST.castFruitMove(fruitTarget,part,function() return true end))
S.fruitMasteryMoves={Z=false,X=false,C=false,V=false,F=false}
clock=20
assert(not _TEST.castFruitMove(fruitTarget,part,function() return true end) and #movePresses==2)
S.fruitMasteryMoves.Z=true
local active=true
keypress=function(code) movePresses[#movePresses+1]=code;active=false end
assert(_TEST.castFruitMove(fruitTarget,part,function() return active end))
assert(moveReleases[3]==string.byte('Z'),'Disabling mastery must release its move key')
clock=30;active=true
keypress=function(code) movePresses[#movePresses+1]=code end
task.wait=function() error('injected cast failure') end
warn=function() end
assert(not _TEST.castFruitMove(fruitTarget,part,function() return active end))
assert(moveReleases[4]==string.byte('Z'),'Cast errors must release the key')
