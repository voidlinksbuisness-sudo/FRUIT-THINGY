local clock=0
os.clock=function() return clock end
local waitHook=nil
task={spawn=function() end,wait=function(dt) clock=clock+dt;if waitHook then waitHook() end end}
Vector3={new=function(x,y,z) return {X=x,Y=y,Z=z} end}
local pumpkinFolder={Address=1}
local enemyFolder={Address=2}
local pumpkinChildren,enemyChildren={},{}
pumpkinFolder.GetChildren=function() return pumpkinChildren end
enemyFolder.GetChildren=function() return enemyChildren end
local character={Address=3}
local root={Parent=character,Position={X=0,Y=0,Z=0}}
character.FindFirstChild=function(_,name) if name=='HumanoidRootPart' then return root end end
LocalPlayer={Character=character}
game={Workspace={FindFirstChild=function(_,name) if name=='PumpkinHunt' then return pumpkinFolder elseif name=='Enemies' then return enemyFolder end end}}
S={autoPumpkins=true,FARM_SPEED=320,weaponSlot=3}
local blocked=false
farmPriorityBlocked=function(a,b,c) assert(a and b and c);return blocked end
trackedInstanceKey=function(o) return tostring(o.Address) end
resolveFruitPart=function(o) return o end
getSafeFruitPosition=function(o) return o and o.Position end
local held=nil
getCurrentlyHeldTool=function() return held end
local equipped=nil
pressWeaponSlot=function(slot) equipped=slot;held={} end
WorldToScreen=function(p) return {X=p.X,Y=p.Z},true end
mousemoveabs=function() end
setrobloxinput=function() end
local destination=nil
local cancelTween=false
tweenTo=function(_,p,_,check)
 destination=p
 if cancelTween then S.autoPumpkins=false end
 if check() then root.Position=p end
end
hardLockNpcCFrame=function(_,p) root.Position=p end
isAlive=function(enemy) return enemy.Parent and enemy.Health>0 end
local fought=nil
farmAttack=function(_,check,name,_,range,attack,_,options)
 assert(check() and name=="Jack o' Lantern" and range==1000 and options.syncAttack)
 fought=enemyChildren[1]
 attack(fought,fought)
 fought.Health=0;fought.Parent=nil
end
local clicks=0
mouse1click=function() clicks=clicks+1 end
assert(load(source))()
local function pumpkin(x)
 return {Name='Pumpkin',Parent=pumpkinFolder,Position={X=x,Y=0,Z=0}}
end
local near,far=pumpkin(5),pumpkin(100)
pumpkinChildren={far,near}
waitHook=function() if clicks>=2 then near.Parent=nil end end
_TEST.step()
assert(equipped==3 and clicks==2 and destination.X==5,'Must break closest pumpkin first')
-- Live spawned enemy interrupts the active pumpkin and fights before resuming.
clock=2;clicks=0;near=pumpkin(5);pumpkinChildren={near};enemyChildren={}
local jack={Name="Jack o' Lantern",Parent=enemyFolder,Health=100,Position={X=6,Y=0,Z=0}}
jack.FindFirstChildOfClass=function() return {Health=jack.Health} end
waitHook=function() clock=clock+0.3;if clicks==1 then enemyChildren={jack} end end
_TEST.step();assert(clicks==1 and jack.Health==100)
_TEST.step();assert(fought==jack and jack.Health==0 and clicks==2)
clock=4;waitHook=function() near.Parent=nil end
_TEST.step();assert(clicks==3,'Must resume pumpkins after Jack dies')
-- Disabled or blocked farms send no clicks, including canceled travel.
clock=6;near=pumpkin(5);pumpkinChildren={near};enemyChildren={};cancelTween=true
local before=clicks
_TEST.step();assert(clicks==before)
S.autoPumpkins=true;blocked=true;_TEST.step();assert(clicks==before)
blocked=false;cancelTween=false;clock=8;pumpkinFolder=nil;enemyFolder=nil
_TEST.step();assert(clicks==before)
