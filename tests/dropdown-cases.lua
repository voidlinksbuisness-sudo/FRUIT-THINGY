Vector2 = {new = function(x, y) return {X = x, Y = y} end}
workspace = {CurrentCamera = {ViewportSize = Vector2.new(1920, 1080)}}
local install = assert(load(helperSource))()
local values = assert(load(materialSource))()
local ui = {FontSize = 13, BackgroundColor = "background", OutlineColor = "outline",
    FontColor = "font", MainColor = "selected", AccentColor = "accent"}
local WindowMethods = {}
local function inside(point, rect)
    return rect and point.X >= rect.x and point.X <= rect.x + rect.w
        and point.Y >= rect.y and point.Y <= rect.y + rect.h
end
local function safeCallback(callback, ...)
    if callback then callback(...) end
end
-- This is the actual upstream click handler used by the UI dependency.
local handler = assert(load("return function(WindowMethods, inside, safeCallback)\n" .. clickSource ..
    "\nreturn WindowMethods._handleDropdownClick end"))()(WindowMethods, inside, safeCallback)
local cases = {
    {1920, 1080, 400, 200},
    {800, 600, 650, 560},
    {800, 600, 400, 200},
    {320, 180, 180, 140},
}
for _, screen in ipairs(cases) do
    workspace.CurrentCamera.ViewportSize = Vector2.new(screen[1], screen[2])
    local delegated = 0
    local window = {
        _renderDropdownOverlay = function() delegated = delegated + 1 end,
        _draw = function(_, _, properties) return properties end,
    }
    install(window, ui)
    window:_renderDropdownOverlay({ShowAllOptions = false})
    assert(delegated == 1)
    local callbackValue, changedValue
    local control = {
        ShowAllOptions = true, Values = values, Value = values[1],
        _boxRect = {x = screen[3], y = screen[4], w = 180, h = 20},
        Callback = function(value) callbackValue = value end,
        Changed = function(value) changedValue = value end,
    }
    window:_renderDropdownOverlay(control)
    assert(#control._itemRects == 13 and #control._listPack.Items == 13)
    local bounds = control._listRect
    assert(bounds.x >= 0 and bounds.y >= 0)
    assert(bounds.x + bounds.w <= screen[1] and bounds.y + bounds.h <= screen[2])
    for index, rect in ipairs(control._itemRects) do
        local text = control._listPack.Items[index].Text
        assert(text.Visible and text.Text:find(values[index], 1, true))
        assert(rect.x >= bounds.x and rect.y >= bounds.y)
        assert(rect.x + rect.w <= bounds.x + bounds.w + 0.001)
        assert(rect.y + rect.h <= bounds.y + bounds.h + 0.001)
        for previous = 1, index - 1 do
            local other = control._itemRects[previous]
            assert(rect.x + rect.w <= other.x + 0.001 or other.x + other.w <= rect.x + 0.001
                or rect.y + rect.h <= other.y + 0.001 or other.y + other.h <= rect.y + 0.001)
        end
        window.OpenDropdown = control
        assert(handler(window, Vector2.new(rect.x + rect.w / 2, rect.y + rect.h / 2)))
        assert(control.Value == values[index] and callbackValue == values[index] and changedValue == values[index])
        assert(window.OpenDropdown == nil)
    end
    if screen[2] == 180 then
        assert(control._itemRects[13].x > control._itemRects[1].x, "Small viewport needs multiple columns")
    end
    local oldItems = control._listPack.Items
    control.Values = {values[1], values[2]}
    window:_renderDropdownOverlay(control)
    assert(#control._itemRects == 2)
    for i = 3, 13 do assert(not oldItems[i].Text.Visible and not oldItems[i].Background.Visible) end
end
