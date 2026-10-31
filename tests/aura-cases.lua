local clock=10
os.clock=function() return clock end
local controls={}
mainTab={AddSection=function() end,AddToggle=function(_,id,opt) controls[id]=opt end,AddSlider=function() end}
notify=function() end
warn=function() end
local onWait=nil
local loop=nil
task={spawn=function(fn) loop=fn end,wait=function() if onWait then onWait() end end}
local root={Position={X=0,Y=0,Z=0}}
LocalPlayer={Character={FindFirstChild=function() return root end}}
local health=100
local part={Parent=true,Position={X=10,Y=0,Z=0},IsA=function() return true end}
local enemy={Name='Jack o\' Lantern',Parent=true,
 FindFirstChildOfClass=function(_,class) assert(class=='Humanoid');return {Health=health} end,
 FindFirstChild=function(_,name) if name=='LeftLowerLeg' then return part end end}
local bad=setmetatable({},{__index=function() error('despawned') end})
local enemies={GetChildren=function() return {bad,enemy} end}
local attacks,hits=0,0
local fail=false
local attack={FireServer=function(_,n) assert(n==0.5);if fail then error('temporary failure') end;attacks=attacks+1 end}
local hit={FireServer=function(_,primary,list) assert(primary==part and #list==1 and list[1][1]==enemy);hits=hits+1 end}
local net={FindFirstChild=function(_,name) if name=='RE/RegisterAttack' then return attack else return hit end end}
local modules={FindFirstChild=function() return net end}
game={Workspace={FindFirstChild=function(_,name) assert(name=='Enemies');return enemies end},GetService=function() return {FindFirstChild=function() return modules end} end}
workspace=nil
assert(load(source))()
controls.npc_aura.Callback(true)
_TEST.tick();assert(attacks==1 and hits==1)
local newHits=0
hit={FireServer=function() newHits=newHits+1 end}
_TEST.tick();assert(newHits==1 and hits==1,'Must refresh replaced remotes')
onWait=function() controls.npc_aura.Callback(false) end
_TEST.tick();assert(newHits==1,'Disabled during attack yield must cancel hit')
onWait=nil;controls.npc_aura.Callback(true)
fail=true;_TEST.tick();assert(newHits==1)
fail=false;_TEST.tick();assert(newHits==2,'Must retry failed attacks')
net=nil;_TEST.tick();assert(newHits==2)
net={FindFirstChild=function(_,name) if name=='RE/RegisterAttack' then return attack else return hit end end}
_TEST.tick();assert(newHits==3,'Must recover missing remotes')
onWait=function() enemy.Parent=nil;part.Parent=nil end
_TEST.tick();assert(newHits==3,'Despawn during yield must cancel hit')
onWait=nil;enemy.Parent=true;part.Parent=true
-- Recover an exception in the outer loop rather than losing the worker.
local originalService=game.GetService
local first=true
game.GetService=function() if first then first=false;error('transient lookup') end;return originalService() end
local co=coroutine.create(loop)
task.wait=function() coroutine.yield() end
assert(coroutine.resume(co));assert(coroutine.status(co)=='suspended')
assert(coroutine.resume(co));assert(coroutine.resume(co));assert(newHits>=4)
