do
    local ok, err = pcall(function()
        local ueSource = game:HttpGet("https://raw.githubusercontent.com/hauntedscripts/Scripts2/refs/heads/main/matcha%20ue")
        local ueChunk, ueError = loadstring(ueSource, "laced.club UE")
        if not ueChunk then error(ueError or "UE compile failed") end
        ueChunk()

        local UE = (_G and (_G.UELibrary or _G.Library)) or UELibrary
        if type(UE) ~= "table" then error("UE did not expose UELibrary") end

        local controls = {}

        -- Material lists must not inherit the upstream eight-item display cap.
        local function enableFullDropdowns(window, uiLibrary)
            local renderDefault = window._renderDropdownOverlay
            function window:_renderDropdownOverlay(control)
                if not control or not control.ShowAllOptions then
                    return renderDefault(self, control)
                end
                if not control._boxRect then return end
                local count = #control.Values
                if count == 0 then return end
                local viewportWidth, viewportHeight = 1920, 1080
                pcall(function()
                    local viewport = workspace.CurrentCamera.ViewportSize
                    viewportWidth, viewportHeight = viewport.X, viewport.Y
                end)
                local margin = 4
                local fontSize = uiLibrary.FontSize or 13
                local itemHeight = math.max(20, fontSize + 8)
                local rows = math.min(count, math.max(1, math.floor((viewportHeight - 2 * margin - 2) / itemHeight)))
                local columns = math.ceil(count / rows)
                local longest = 0
                for _, value in ipairs(control.Values) do
                    local text = tostring(value)
                    longest = math.max(longest, #text + 4)
                end
                local columnWidth = math.max(control._boxRect.w, math.ceil(longest * fontSize * 0.55) + 12)
                columnWidth = math.min(columnWidth, (viewportWidth - 2 * margin - 2) / columns)
                local width, height = columnWidth * columns + 2, rows * itemHeight + 2
                local x = math.max(margin, math.min(control._boxRect.x, viewportWidth - margin - width))
                local below = control._boxRect.y + control._boxRect.h + 1
                local above = control._boxRect.y - height - 1
                local y = below
                if below + height > viewportHeight - margin then
                    y = above >= margin and above or math.max(margin, viewportHeight - margin - height)
                end
                local textSize = math.max(1, math.min(fontSize, math.floor((columnWidth - 12) / (longest * 0.55))))
                if not control._listPack then
                    control._listPack = {
                        Background = self:_draw("Square", {Filled = true, Color = uiLibrary.BackgroundColor, ZIndex = 30}),
                        Border = self:_draw("Square", {Filled = false, Thickness = 1, Color = uiLibrary.OutlineColor, ZIndex = 31}),
                        Items = {},
                    }
                end
                local pack = control._listPack
                control._listRect = {x = x, y = y, w = width, h = height}
                control._itemRects = {}
                pack.Background.Position, pack.Background.Size = Vector2.new(x, y), Vector2.new(width, height)
                pack.Border.Position, pack.Border.Size = Vector2.new(x, y), Vector2.new(width, height)
                pack.Background.Visible, pack.Border.Visible = true, true
                for index = 1, count do
                    local column = math.floor((index - 1) / rows)
                    local row = (index - 1) % rows
                    local itemX, itemY = x + 1 + column * columnWidth, y + 1 + row * itemHeight
                    if not pack.Items[index] then
                        pack.Items[index] = {
                            Background = self:_draw("Square", {Filled = true, Color = uiLibrary.BackgroundColor, ZIndex = 32}),
                            Text = self:_draw("Text", {Color = uiLibrary.FontColor, Outline = true, ZIndex = 33}),
                        }
                    end
                    local item, value = pack.Items[index], control.Values[index]
                    local selected = control.Multi and control.Value[value] == true or (not control.Multi and control.Value == value)
                    -- Preserve value indices for the existing click handler and callbacks.
                    control._itemRects[index] = {x = itemX, y = itemY, w = columnWidth, h = itemHeight}
                    item.Background.Position, item.Background.Size = Vector2.new(itemX, itemY), Vector2.new(columnWidth, itemHeight)
                    item.Background.Color = selected and uiLibrary.MainColor or uiLibrary.BackgroundColor
                    item.Background.Visible = true
                    item.Text.Text = (selected and "[x] " or "") .. tostring(value)
                    item.Text.Size = textSize
                    item.Text.Color = selected and uiLibrary.AccentColor or uiLibrary.FontColor
                    item.Text.Position = Vector2.new(itemX + 6, itemY + math.floor((itemHeight - textSize) / 2))
                    item.Text.Visible = true
                end
                for index = count + 1, #pack.Items do
                    pack.Items[index].Background.Visible = false
                    pack.Items[index].Text.Visible = false
                end
            end
        end

        local function roundingFor(step, explicit)
            if tonumber(explicit) then return math.max(0, math.floor(tonumber(explicit))) end
            step = tonumber(step) or 1
            if step >= 1 then return 0 end
            local decimals = tostring(step):match("%.(%d+)")
            return decimals and #decimals or 0
        end

        local function enhanceControl(id, control)
            if not control then return control end
            controls[id] = control
            control.Set = control.SetValue
            control.SetOptions = control.SetValues
            return control
        end

        local function makeTab(rawTab)
            local tab = { Raw = rawTab, Groups = {} }

            local function columnOf(info)
                local column = tonumber(info and info.Column) or 1
                return column == 2 and 2 or 1
            end

            local function groupFor(self, info)
                local column = columnOf(info)
                local group = self.Groups[column]
                if not group then
                    if column == 2 then group = self.Raw:AddRightGroupbox("General")
                    else group = self.Raw:AddLeftGroupbox("General") end
                    self.Groups[column] = group
                end
                return group
            end

            function tab:AddSection(name, info)
                local column = columnOf(info)
                local group
                if column == 2 then group = self.Raw:AddRightGroupbox(name)
                else group = self.Raw:AddLeftGroupbox(name) end
                self.Groups[column] = group
                return group
            end

            function tab:AddToggle(id, info)
                info = info or {}
                local group = groupFor(self, info)
                local toggle = group:AddToggle(id, {
                    Text = info.Text or id,
                    Default = info.Default == true,
                    Callback = info.Callback,
                    Tooltip = info.Description,
                    Risky = info.Risky == true,
                })
                enhanceControl(id, toggle)
                if info.Keybind == true then
                    local picker = toggle:AddKeyPicker(id .. "_keybind", {
                        Text = (info.Text or id) .. " key",
                        Default = "None",
                        Mode = "Toggle",
                        SyncToggleState = true,
                    })
                    enhanceControl(id .. "_keybind", picker)
                end
                return toggle
            end

            function tab:AddSlider(id, info)
                info = info or {}
                local step = tonumber(info.Step) or 1
                local minimum = tonumber(info.Min) or 0
                local maximum = tonumber(info.Max) or 100
                local callback = info.Callback
                local slider
                local function changed(value)
                    local snapped = minimum + math.floor(((value - minimum) / step) + 0.5) * step
                    if snapped < minimum then snapped = minimum end
                    if snapped > maximum then snapped = maximum end
                    if slider then slider.Value = snapped end
                    if callback then callback(snapped) end
                end
                slider = groupFor(self, info):AddSlider(id, {
                    Text = info.Text or id,
                    Default = info.Default,
                    Min = minimum,
                    Max = maximum,
                    Rounding = roundingFor(step, info.Decimals),
                    Suffix = info.Suffix or "",
                    Callback = changed,
                    Tooltip = info.Description,
                })
                return enhanceControl(id, slider)
            end

            function tab:AddDropdown(id, info)
                info = info or {}
                local dropdown = groupFor(self, info):AddDropdown(id, {
                    Text = info.Text or id,
                    Default = info.Default,
                    Values = info.Options or info.Values or {},
                    Multi = info.Multi == true,
                    AllowNull = info.AllowNull == true,
                    Callback = info.Callback,
                    Tooltip = info.Description,
                })
                dropdown.ShowAllOptions = info.ShowAllOptions == true
                return enhanceControl(id, dropdown)
            end

            function tab:AddButton(id, info)
                info = info or {}
                local button = groupFor(self, info):AddButton({
                    Text = info.Text or id,
                    Func = info.Callback,
                    Tooltip = info.Description,
                    DoubleClick = info.DoubleClick == true,
                })
                return enhanceControl(id, button)
            end

            function tab:AddPriorityList(id, info)
                info = info or {}
                local group = groupFor(self, info)
                local options = info.Options or {}
                local selected = {}
                for index, value in ipairs(info.Default or options) do selected[index] = value end
                local pickers = {}
                local changing = false

                local function emit()
                    if info.Callback then
                        local order = {}
                        for index = 1, #options do order[index] = selected[index] end
                        info.Callback(order)
                    end
                end

                for index = 1, #options do
                    local slot = index
                    local oldValue = selected[slot]
                    local picker
                    picker = group:AddDropdown(id .. "_" .. tostring(slot), {
                        Text = (info.Text or id) .. " " .. tostring(slot),
                        Default = selected[slot],
                        Values = options,
                        Callback = function(value)
                            if changing then return end
                            local previous = selected[slot]
                            local duplicate = nil
                            for other = 1, #selected do
                                if other ~= slot and selected[other] == value then duplicate = other break end
                            end
                            selected[slot] = value
                            if duplicate then
                                selected[duplicate] = previous
                                if pickers[duplicate] then pickers[duplicate].Value = previous end
                            end
                            oldValue = value
                            emit()
                        end,
                        Tooltip = info.Description,
                    })
                    pickers[slot] = picker
                    enhanceControl(id .. "_" .. tostring(slot), picker)
                end

                local list = { Pickers = pickers, Value = selected }
                function list:SetValue(order)
                    if type(order) ~= "table" then return self end
                    changing = true
                    for index = 1, math.min(#order, #pickers) do
                        selected[index] = order[index]
                        pickers[index].Value = order[index]
                    end
                    changing = false
                    emit()
                    return self
                end
                function list:SetValues(values)
                    for _, picker in ipairs(pickers) do picker:SetValues(values or {}) end
                    return self
                end
                list.SetOptions = list.SetValues
                controls[id] = list
                return list
            end

            return tab
        end

        local Adapter = { Raw = UE, Controls = controls, Windows = {} }

        local function makePopup(adapter, info)
            info = info or {}
            local raw = adapter.Raw:CreateWindow({
                Title = info.Title or "Settings",
                Width = info.Width or 520,
                Height = info.Height or 500,
                AutoShow = false,
                Center = true,
            })
            enableFullDropdowns(raw, adapter.Raw)
            adapter.Raw.Toggled = true
            local page = makeTab(raw:AddTab(info.Title or "Settings"))
            local popup = { Raw = raw }
            function popup:AddSection(...) return page:AddSection(...) end
            function popup:AddToggle(...) return page:AddToggle(...) end
            function popup:AddSlider(...) return page:AddSlider(...) end
            function popup:AddDropdown(...) return page:AddDropdown(...) end
            function popup:AddButton(...) return page:AddButton(...) end
            function popup:AddPriorityList(...) return page:AddPriorityList(...) end
            function popup:Show() raw:Show() return self end
            function popup:Hide() raw:Hide() return self end
            function popup:Set(id, value)
                local control = controls[id]
                if control and control.SetValue then control:SetValue(value)
                elseif control and control.Set then control:Set(value) end
                return self
            end
            return popup
        end

        function Adapter:CreateWindow(info)
            info = info or {}
            local accent = info.Theme and info.Theme.Colors and info.Theme.Colors.Accent
            if accent then self.Raw.AccentColor = accent end
            if info.ConfigFile or info.SettingsFile then
                self.Raw.SettingsFile = (info.ConfigFile or info.SettingsFile) .. ".ui.json"
            end
            local raw = self.Raw:CreateWindow({
                Title = info.Title or "laced.club",
                Width = info.Width or 540,
                Height = info.Height or 430,
                AutoShow = true,
                Center = true,
            })
            enableFullDropdowns(raw, self.Raw)
            local window = {
                Raw = raw,
                Tabs = {},
                Indicator = { SetVisible = function() end },
                Config = { IndicatorEnabled = false },
                _lastMenuDown = false,
            }

            local configFolder = tostring(info.ConfigFolder or "laced_club_configs")
            local selectedConfig = ""
            local function safeConfigName(name)
                name = tostring(name or ""):gsub("[^%w%._%- ]", "_"):gsub("^%s+", ""):gsub("%s+$", "")
                if name == "" then name = "default" end
                return name:sub(1, 64)
            end
            local function ensureConfigFolder()
                pcall(function()
                    if not isfolder(configFolder) then makefolder(configFolder) end
                end)
            end
            local function configPathFor(name)
                return configFolder .. "/" .. safeConfigName(name) .. ".json"
            end
            local function listConfigNames()
                ensureConfigFolder()
                local names = {}
                local ok, files = pcall(listfiles, configFolder)
                if ok and type(files) == "table" then
                    for _, path in ipairs(files) do
                        local fileName = tostring(path):match("([^/\\]+)%.json$")
                        if fileName then table.insert(names, fileName) end
                    end
                end
                table.sort(names)
                return names
            end
            local configPath = configPathFor("default")
            local function configValue(control)
                if not control then return nil end
                local kind = control.Type
                if kind == "Toggle" then return control.Value == true end
                if kind == "Slider" then return tonumber(control.Value) end
                if kind == "KeyPicker" then
                    return type(control.Value) == "string" and control.Value or "None"
                end
                if kind == "Dropdown" then
                    if control.Multi then
                        local out = {}
                        for key, value in pairs(control.Value or {}) do
                            if type(key) == "string" then out[key] = value == true end
                        end
                        return out
                    end
                    return type(control.Value) == "string" and control.Value or nil
                end
                return nil
            end
            local function saveFeatureConfig(name)
                name = safeConfigName(name or selectedConfig)
                ensureConfigFolder()
                local path = configPathFor(name)
                local data = { version = 4, controls = {}, name = name }
                local saved = 0
                for id, control in pairs(controls) do
                    local value = configValue(control)
                    if value ~= nil then data.controls[id] = value; saved = saved + 1 end
                end
                local ok, err = pcall(function()
                    local http = game:GetService("HttpService")
                    writefile(path, http:JSONEncode(data))
                end)
                if ok then
                    selectedConfig = name
                    configPath = path
                    window.Config.File = path
                end
                return ok
            end
            local function loadFeatureConfig(name)
                name = safeConfigName(name or selectedConfig)
                local path = configPathFor(name)
                local wasVisible = raw.Visible
                local wasToggled = self.Raw.Toggled
                local ok, data = pcall(function()
                    local http = game:GetService("HttpService")
                    return http:JSONDecode(readfile(path))
                end)
                if not ok or type(data) ~= "table" or data.version ~= 4 or type(data.controls) ~= "table" then
                    return false
                end
                local loaded = 0
                local toggleStates = {}
                for id, value in pairs(data.controls) do
                    local control = controls[id]
                    if control and control.Type == "Toggle" and type(value) == "boolean" then
                        toggleStates[id] = value
                    elseif control and control.SetValue then
                        local applied = pcall(function() control:SetValue(value) end)
                        if applied then loaded = loaded + 1 end
                    end
                end
                local previous = {}
                for id, value in pairs(toggleStates) do
                    local control = controls[id]
                    if control then
                        previous[id] = control.Value == true
                        control.Value = value
                    end
                end
                for id, value in pairs(toggleStates) do
                    local control = controls[id]
                    if control and previous[id] ~= value then
                        pcall(function() if control.Callback then control.Callback(value) end end)
                        pcall(function() if control.Changed then control.Changed(value) end end)
                    end
                end
                for id, value in pairs(toggleStates) do
                    local control = controls[id]
                    if control then control.Value = value end
                    loaded = loaded + 1
                end
                raw.Visible = wasVisible
                self.Raw.Toggled = wasToggled
                raw._visibilityDirty = true
                selectedConfig = name
                configPath = path
                window.Config.File = path
                return true
            end
            local function refreshConfigList(dropdown)
                local names = listConfigNames()
                if dropdown and dropdown.SetValues then
                    pcall(function() dropdown:SetValues(names) end)
                end
                if selectedConfig == "" and names[1] then selectedConfig = names[1] end
                return names
            end
            window.Config = {
                IndicatorEnabled = false,
                File = configPath,
                Folder = configFolder,
                Save = function(name) return saveFeatureConfig(name) end,
                Load = function(name) return loadFeatureConfig(name) end,
            }

            function window:AddTab(name)
                local tab = makeTab(raw:AddTab(name))
                self.Tabs[name] = tab
                return tab
            end

            function window:Set(id, value)
                local control = controls[id]
                if control and control.SetValue then control:SetValue(value)
                elseif control and control.Set then control:Set(value) end
                return self
            end

            function window:CreatePopup(popupInfo)
                return makePopup(Adapter, popupInfo)
            end

            function window:Show() raw:Show() return self end
            function window:Hide() raw:Hide() return self end
            function window:SetVisible(value) if value then raw:Show() else raw:Hide() end return self end

            function window:Step()
                return self
            end

            table.insert(Adapter.Windows, window)

            if self.Raw.Configs then
                window.Config.Folder = self.Raw.Configs.Folder
                window.Config.Save = self.Raw.Configs.Save
                window.Config.Load = self.Raw.Configs.Load
            end
            return window
        end

        Library = Adapter
    end)
    if not ok or not Library then
        warn("Failed to load UE UI: " .. tostring(err))
        return
    end
end

