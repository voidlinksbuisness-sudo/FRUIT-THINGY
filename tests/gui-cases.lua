-- Run the actual INS library's constructors with mocked host services.
-- Render/game loops are scheduled but never executed by this test.
local tasks, files, json, serial, dropReturns = {}, {}, {}, 0, false
task = {spawn = function(fn) tasks[#tasks + 1] = fn end, wait = function() end}
wait = function() end
warn = function(message) error(message) end
setrobloxinput = function() end
local fonts = setmetatable({}, {__index = function(t,k) serial = serial + 1; rawset(t,k,serial); return serial end})
Drawing = {Fonts = fonts, new = function() return {Remove = function() end} end}
Color3 = {
    new = function(r,g,b) return {R=r,G=g,B=b} end,
    fromRGB = function(r,g,b) return {R=r/255,G=g/255,B=b/255} end,
}
Vector2 = {new = function(x,y) return {X=x,Y=y} end}
Vector3 = {new = function(x,y,z) return {X=x,Y=y,Z=z} end}
workspace = {CurrentCamera = {ViewportSize = Vector2.new(1280,720)}, GetChildren=function() return {} end, FindFirstChild=function() return nil end}
local player = {Name="Tester",DisplayName="Tester",UserId=1,GetMouse=function() return {X=0,Y=0} end}
local players = {LocalPlayer=player, GetPlayers=function() return {player} end, GetChildren=function() return {player} end}
local http = {
    JSONEncode = function(_, data) serial=serial+1; local key=tostring(serial); json[key]=data; return key end,
    JSONDecode = function(_, text) return json[text] end,
}
function isfolder() return true end
function makefolder() end
function listfiles() return {} end
function writefile(path, text) files[path]=text end
function readfile(path) assert(files[path]); return files[path] end
function isfile(path) return files[path] ~= nil end
game = {PlaceId=2753915549, Workspace=workspace}
function game:GetService(name)
    if name == "Players" then return players end
    if name == "HttpService" then return http end
    return {}
end
function game:HttpGet(url)
    assert(url == "https://revision/lib/ins-ui.lua", "Unexpected HTTP request: " .. url)
    return libSource
end
function loadstring(source, name)
    local chunk, err = load(source, name)
    if chunk and dropReturns then return function() chunk() end end
    return chunk, err
end
_G.FRUIT_THINGY_BASE_URL = "https://revision/"
local function initialize()
    Library = nil
    assert(load(adapterSource, "ui-adapter.lua"))()
    assert(Library and Library.Raw == _G.INSUI)
end
initialize()
assert(load(stateSource))()
islandList, dangerLevelNames = {}, {}
AFL={tweenSpeed=320}
-- Fixture globals accessed during construction; callbacks and game loops remain idle.
function refreshBoatSeatList() end
local configured = assert(load(controlsSource .. "\n" .. popupsSource .. "\nreturn Window", "all-ui-controls.lua"))()
assert(configured == Window and Window.Config.Save and Window.Config.Load)
local controls = Library.Controls
assert(controls.auto_v4 and controls.chest_esp and controls.material_target)
assert(controls.tween_farm_speed and controls.glitch_sanguine_speed)
controls.auto_v4:SetValue(true)
assert(S.autoV4 == true and S.autoV4NextPress > 0)
controls.auto_v4:SetValue(false)
assert(S.autoV4 == false)
controls.material_target:SetValue("Mini Tusk")
assert(S.selectedMaterial == "Mini Tusk")
assert(controls.material_target.Value == "Mini Tusk")
assert(#controls.material_target.Raw.Choices == 13 and controls.material_target.Raw.Searchable)
assert(controls.material_target.Raw.ShowAllOptions)
controls.tween_farm_speed:SetValue(750)
assert(S.FARM_SPEED == 750)
-- Direct Value assignment is silent and synchronizes the native row.
controls.material_target.Value = "Dragon Scale"
assert(controls.material_target.Raw.Value[1] == "Dragon Scale" and S.selectedMaterial == "Mini Tusk")
local sample = Window:AddTab("Adapter test")
local calls = 0
local toggle = sample:AddToggle("sample_toggle",{Default=false,Keybind=true,Callback=function(v) calls=calls+1 end})
toggle:SetValue(true)
assert(toggle.Value and toggle.Raw.Value and calls == 1)
controls.sample_toggle_keybind:SetValue("K")
assert(toggle.Raw.Bind.Value == "k")
assert(toggle.Raw.Bind.Callback == nil and toggle.Raw.Bind.Mode == "Toggle")
local selected
local multi = sample:AddDropdown("sample_multi",{Multi=true,Options={"a","b"},Default={a=true},Callback=function(v) selected=v end})
assert(multi.Value.a)
multi:SetValue({b=true})
assert(selected.b and not selected.a and multi.Raw.Value[1] == "b")
local order
local priority = sample:AddPriorityList("sample_priority",{Options={"a","b","c"},Callback=function(v) order=v end})
priority.Pickers[1]:SetValue("c")
assert(order[1]=="c" and order[3]=="a")
assert(priority.Pickers[3].Value=="a")
-- Auxiliary settings use the SAME window and restore the active page on Close.
Library.Raw:SelectTab(Window.Tabs.Main.Raw)
local page = Window:CreatePopup({Title="Test Settings"})
assert(page.Raw.Hidden)
page:Show()
assert(Library.Raw:GetSelectedTab()==page.Raw and not page.Raw.Hidden)
page:Hide()
assert(page.Raw.Hidden and Library.Raw:GetSelectedTab()==Window.Tabs.Main.Raw)
-- Save/load the existing feature profile format, including scalar dropdowns/binds.
controls.material_target:SetValue("Mini Tusk")
assert(Window.Config.Save("compatibility"))
controls.material_target:SetValue("Angel Wings")
controls.auto_v4:SetValue(false)
assert(Window.Config.Load("compatibility"))
assert(controls.material_target.Value=="Mini Tusk" and S.selectedMaterial=="Mini Tusk")
assert(controls.sample_toggle_keybind.Value=="k")
Window:Hide()
assert(not Library.Raw:IsOpen())
Window:Show()
assert(Library.Raw:IsOpen())
-- Matcha may discard library chunk returns; the INSUI export must still work.
dropReturns=true
initialize()
assert(Library.Raw == _G.INSUI)
