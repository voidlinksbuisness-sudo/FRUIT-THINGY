local clock=0
os.clock=function() return clock end
local controls={}
mainTab={AddSection=function() end,AddToggle=function(_,id,opt) controls[id]=opt end,AddSlider=function() end}
task={spawn=function() end,wait=function() end}
notify=function() end
Vector3={new=function(x,y,z) return {X=x,Y=y,Z=z} end}
local calls={}
local fail=false
local left={FireServer=function(_,dir,index,pressed)
 if fail then error('failed left click') end
 assert(math.abs(dir.X-0.6)<0.0001 and dir.Y==0 and math.abs(dir.Z-0.8)<0.0001)
 assert(index==1 and pressed==true)
 calls[#calls+1]='left'
end}
local finish={FireServer=function(_,pressed) assert(pressed==true);calls[#calls+1]='finish' end}
local tool={FindFirstChild=function(_,name) if name=='LeftClickRemote' then return left elseif name=='RemoteEvent' then return finish end end}
local hrp={Position={X=0,Y=0,Z=0}}
local character={FindFirstChild=function(_,name) if name=='Control-Control' then return tool elseif name=='HumanoidRootPart' then return hrp end end}
LocalPlayer={Name='DynamicName',Character=character}
local characters={FindFirstChild=function(_,name) assert(name=='DynamicName');return character end}
game={Workspace={FindFirstChild=function(_,name) if name=='Characters' then return characters end end},GetService=function() return {FindFirstChild=function() end} end}
assert(load(source))()
local function target(x,z,health)
 return {enemy={Parent=true,FindFirstChildOfClass=function() return {Health=health} end},part={Parent=true,Position={X=x,Y=0,Z=z}}}
end
local list={target(30,40,100),target(3,4,100),target(1,0,0),target(400,0,100)}
controls.npc_aura.Callback(true)
_TEST.attack(list);assert(#calls==0,'Control must be opt-in')
controls.npc_aura_control.Callback(true)
_TEST.attack({});assert(#calls==0)
_TEST.attack(list);assert(#calls==2 and calls[1]=='left' and calls[2]=='finish')
_TEST.attack(list);assert(#calls==2)
clock=0.2;_TEST.attack(list);assert(#calls==4)
controls.npc_aura.Callback(false);clock=1;_TEST.attack(list);assert(#calls==4)
controls.npc_aura.Callback(true)
left=nil;_TEST.attack(list);assert(#calls==4,'Never send true without LeftClickRemote')
left={FireServer=function() error('failed') end}
clock=2;_TEST.attack(list);assert(#calls==4,'Do not finish a failed press')
left={FireServer=function() calls[#calls+1]='new left' end}
clock=3;_TEST.attack(list);assert(#calls==6 and calls[5]=='new left' and calls[6]=='finish')
clock=4;_TEST.attack({target(0,0,100),target(500,0,100),target(3,4,0)})
assert(#calls==6,'Zero distance, out-of-range, and dead targets cannot fire')
