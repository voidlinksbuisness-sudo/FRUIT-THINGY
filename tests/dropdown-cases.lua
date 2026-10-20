local construct = assert(load([[
return function(openSource, selectSource, layoutSource)
    local Layout = assert(load(layoutSource))()
    local State = {}
    local Camera = {ViewportSize = {X=1280,Y=720}}
    local function CopyList(source)
        local out = {}
        for i,v in ipairs(source) do out[i]=v end
        return out
    end
    local function ResetDropdownScroll() State.Dropdown.Offset = 0 end
]] .. selectSource .. openSource .. [[
    return OpenDropdown, SetDropdownValue, State, Camera, Layout
end]]))()
local open, select, state, camera, layout = construct(openSource, selectSource, layoutSource)
local choices = {}
for i=1,13 do choices[i]="Material "..i end
local selected
local row = {Choices=choices,Value={},ShowAllOptions=true,Searchable=true,Callback=function(v) selected=v[1] end}
for _, height in ipairs({1080,720,180}) do
    camera.ViewportSize.Y = height
    open(row, 100, height-50, 180)
    local popup = state.Dropdown
    assert(#popup.Choices==13 and popup.Choices[13]=="Material 13")
    assert(popup.Y>=layout.ListMargin and popup.Y+popup.H<=height-layout.ListMargin)
    local rows = math.floor((popup.H-layout.ListPad-layout.ListHeader)/layout.ListRow)
    if height>=720 then assert(rows>=13) else assert(rows<13) end
    assert(popup.Searchable and state.Focus==popup.Search)
end
for i=1,13 do select(row,{choices[i]}); assert(selected==choices[i] and row.Value[1]==choices[i]) end
