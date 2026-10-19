do
    local ok, err = pcall(function()
        local ueSource = game:HttpGet("https://raw.githubusercontent.com/hauntedscripts/Scripts2/refs/heads/main/matcha%20ue")
        local ueChunk, ueError = loadstring(ueSource, "laced.club UE")
        if not ueChunk then error(ueError or "UE compile failed") end
        ueChunk()

        local UE = (_G and (_G.UELibrary or _G.Library)) or UELibrary
        if type(UE) ~= "table" then error("UE did not expose UELibrary") end

        local controls = {}

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

