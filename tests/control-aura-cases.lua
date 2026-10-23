local clock=0
os.clock=function() return clock end
local controls={}
mainTab={AddSection=function() end,AddToggle=function(_,id,opt) controls[id]=opt end,AddSlider=function() end}
local onWait=nil
task={spawn=function() end,wait=function() if onWait then onWait() end end}
notify=function() end
local calls=0
local remote={FireServer=function(_,arg) assert(arg==true);calls=calls+1 end}
local control={FindFirstChild=function(_,name) assert(name=='RemoteEvent');return remote end}
local char={FindFirstChild=function(_,name) if name=='Control-Control' then return control end end}
local current=char
LocalPlayer={Name='ActualPlayer',Character=char}
local folder={FindFirstChild=function(_,name) assert(name=='ActualPlayer');return current end}
local net=nil
game={Workspace={FindFirstChild=function(_,name) if name=='Characters' then return folder end end},GetService=function() return {FindFirstChild=function() return {FindFirstChild=function() return net end} end} end}
assert(load(source))()
local targets={{enemy={Parent=true},part={Parent=true}}}
controls.npc_aura.Callback(true)
_TEST.attack({});assert(calls==0)
_TEST.attack(targets);assert(calls==1)
_TEST.attack(targets);assert(calls==1)
clock=0.16;_TEST.attack(targets);assert(calls==2)
controls.npc_aura.Callback(false)
clock=1;_TEST.attack(targets);assert(calls==2)
controls.npc_aura.Callback(true)
-- A respawn resolves a fresh remote instead of using the old one.
local respawnCalls=0
remote={FireServer=function(_,arg) assert(arg==true);respawnCalls=respawnCalls+1 end}
_TEST.attack(targets);assert(respawnCalls==1 and calls==2)
-- Missing equipped fruit leaves generic attacks usable.
current={FindFirstChild=function() return nil end}
local attacks,hits=0,0
local attack={FireServer=function() attacks=attacks+1 end}
local hit={FireServer=function() hits=hits+1 end}
net={FindFirstChild=function(_,name) if name=='RE/RegisterAttack' then return attack else return hit end end}
_TEST.attack(targets);assert(attacks==1 and hits==1 and respawnCalls==1)
onWait=function() controls.npc_aura.Callback(false) end
_TEST.attack(targets);assert(attacks==2 and hits==1)
-- When Characters lookup is absent, use LocalPlayer.Character only.
current=nil;onWait=nil
controls.npc_aura.Callback(true)
assert(_TEST.remote()==remote)
