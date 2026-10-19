function WindowMethods:_handleDropdownClick(mousePosition)
    local control = self.OpenDropdown
    if not control then return false end
    for index, rect in ipairs(control._itemRects or {}) do
        if inside(mousePosition, rect) then
            local value = control.Values[index]
            if control.Multi then
                control.Value[value] = not (control.Value[value] == true)
            else
                control.Value = value
                self.OpenDropdown = nil
            end
            self._visibilityDirty = true
            safeCallback(control.Callback, control.Value)
            safeCallback(control.Changed, control.Value)
            return true
        end
    end
    if not inside(mousePosition, control._listRect) and not inside(mousePosition, control._boxRect) then
        self.OpenDropdown = nil
        self._visibilityDirty = true
    end
    return false
end

