-- INS UI compatibility layer for the existing FRUIT-THINGY controls.
do
    Library = nil
    local ok, err = pcall(function()
        local environment = (type(getgenv) == "function" and getgenv()) or _G
        local baseUrl = environment.FRUIT_THINGY_BASE_URL or _G.FRUIT_THINGY_BASE_URL
        assert(type(baseUrl) == "string", "Missing FRUIT-THINGY revision URL")
        local source = game:HttpGet(baseUrl .. "lib/ins-ui.lua")
        local chunk, compileError = loadstring(source, "@FRUIT-THINGY/ins-ui.lua")
        assert(type(chunk) == "function", compileError or "INS UI compile failed")
        local previous = _G.INSUI
        if previous and type(previous.Destroy) == "function" then pcall(function() previous:Destroy() end) end
        local returned = chunk()
        local INS = type(returned) == "table" and returned or _G.INSUI or environment.INSUI
        assert(type(INS) == "table", "INS UI did not initialize")

        local controls = {}
        local Adapter = {Raw = INS, Controls = controls, Windows = {}}
        local function copy(values)
            local result = {}
            for key, value in pairs(values or {}) do result[key] = value end
            return result
        end
        local function decode(kind, multi, value)
            if kind ~= "Dropdown" then return value end
            if not multi then return type(value) == "table" and value[1] or nil end
            local result = {}
            for _, item in ipairs(value or {}) do result[item] = true end
            return result
        end
        local function encode(kind, multi, value)
            if kind == "KeyPicker" then return string.lower(tostring(value or "none")) end
            if kind ~= "Dropdown" then return value end
            if not multi then return value == nil and {} or {value} end
            local result = {}
            for key, selected in pairs(value or {}) do
                if type(key) == "number" then result[#result + 1] = selected
                elseif selected then result[#result + 1] = key end
            end
            return result
        end
        local function wrap(id, row, kind, info)
            local multi = info.Multi == true
            local control = {Raw = row, Type = kind, Multi = multi, Callback = info.Callback}
            function control:SetValue(value)
                value = encode(kind, multi, value)
                if kind == "KeyPicker" then row.Value = value
                else row:Set(value) end
                return self
            end
            control.Set, control.SetState = control.SetValue, control.SetValue
            function control:GetValue() return self.Value end
            function control:SetValues(values) row:UpdateChoices(copy(values)); return self end
            control.SetOptions = control.SetValues
            function control:SetText(value) row:SetText(value); return self end
            function control:SetVisible(value) row:SetVisible(value); return self end
            setmetatable(control, {
                __index = function(_, key)
                    if key == "Value" then return decode(kind, multi, row.Value) end
                    return nil
                end,
                __newindex = function(self, key, value)
                    if key == "Value" then row.Value = encode(kind, multi, value)
                    else rawset(self, key, value) end
                end,
            })
            controls[id] = control
            return control
        end

        local function makeTab(rawTab)
            local tab = {Raw = rawTab, Groups = {}}
            local function column(info) return tonumber(info and info.Column) == 2 and 2 or 1 end
            local function group(self, info)
                local side = column(info)
                if not self.Groups[side] then
                    self.Groups[side] = self.Raw:Section("General", side == 2 and "Right" or "Left")
                end
                return self.Groups[side]
            end
            function tab:AddSection(name, info)
                local side = column(info)
                local section = self.Raw:Section(name, side == 2 and "Right" or "Left")
                self.Groups[side] = section
                return section
            end
            function tab:AddToggle(id, info)
                info = info or {}
                local row = group(self, info):Toggle(info.Text or id, info.Default == true, info.Callback, info.Description)
                if info.Risky then row:SetRisk(true) end
                local control = wrap(id, row, "Toggle", info)
                if info.Keybind then
                    row:AddKeybind("none", "Toggle")
                    local picker = wrap(id .. "_keybind", row.Bind, "KeyPicker", {})
                    picker.Mode = "Toggle"
                end
                return control
            end
            function tab:AddSlider(id, info)
                info = info or {}
                local step, minimum, maximum = tonumber(info.Step) or 1, tonumber(info.Min) or 0, tonumber(info.Max) or 100
                local row
                local function changed(value)
                    local snapped = minimum + math.floor((value - minimum) / step + 0.5) * step
                    snapped = math.max(minimum, math.min(maximum, snapped))
                    if row then row.Value = snapped end
                    if info.Callback then info.Callback(snapped) end
                end
                row = group(self, info):Slider(info.Text or id, info.Default or minimum, step, minimum, maximum, info.Suffix or "", changed, info.Description)
                return wrap(id, row, "Slider", info)
            end
            function tab:AddDropdown(id, info)
                info = info or {}
                local multi = info.Multi == true
                local row = group(self, info):Dropdown(info.Text or id,
                    encode("Dropdown", multi, info.Default), info.Options or info.Values or {}, multi,
                    function(value) if info.Callback then info.Callback(decode("Dropdown", multi, value)) end end,
                    info.Description, true)
                row.ShowAllOptions = info.ShowAllOptions == true
                return wrap(id, row, "Dropdown", info)
            end
            function tab:AddButton(id, info)
                info = info or {}
                local row = group(self, info):Button(info.Text or id, info.Callback, info.Description)
                return wrap(id, row, "Button", info)
            end
            function tab:AddPriorityList(id, info)
                info = info or {}
                local options, selected, pickers = info.Options or {}, copy(info.Default or info.Options or {}), {}
                local changing = false
                local function emit() if info.Callback then info.Callback(copy(selected)) end end
                for index = 1, #options do
                    local slot = index
                    pickers[slot] = self:AddDropdown(id .. "_" .. slot, {
                        Text = (info.Text or id) .. " " .. slot, Options = options, Default = selected[slot],
                        Column = info.Column, Description = info.Description,
                        Callback = function(value)
                            if changing then return end
                            local previous, duplicate = selected[slot], nil
                            for other = 1, #selected do
                                if other ~= slot and selected[other] == value then duplicate = other; break end
                            end
                            selected[slot] = value
                            if duplicate then selected[duplicate] = previous; pickers[duplicate].Value = previous end
                            emit()
                        end,
                    })
                end
                local list = {Pickers = pickers, Value = selected}
                function list:SetValue(order)
                    if type(order) ~= "table" then return self end
                    changing = true
                    for index = 1, math.min(#order, #pickers) do
                        selected[index] = order[index]
                        pickers[index].Value = order[index]
                    end
                    changing = false; emit(); return self
                end
                function list:SetValues(values)
                    for _, picker in ipairs(pickers) do picker:SetValues(values) end
                    return self
                end
                list.SetOptions = list.SetValues
                controls[id] = list
                return list
            end
            return tab
        end

        function Adapter:CreateWindow(info)
            info = info or {}
            local raw = INS:CreateWindow({
                title = info.Title or "FRUIT THINGY", subtitle = "Blox Fruits",
                size = Vector2.new(760, 560), menuKey = "end", theme = "Waifu",
                opacity = 1, rounding = 1, rowLines = true, checkboxStyle = false,
                keybindOverlay = true, smartFps = true, gameInput = true, spotlight = true,
                autoSave = false, startOpen = true, configFolder = "fruit_thingy_ui",
            })
            INS:SetBackgroundImage(
                "https://raw.githubusercontent.com/voidlinksbuisness-sudo/scripts/748e48118250bda21774d36a941578a2eba08eb3/assets/fftm-ui-background.png",
                0.14, 2, 1)
            local window = {Raw = raw, Tabs = {}, Indicator = {SetVisible = function() end}, Config = {}}
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
                local wasVisible = INS:IsOpen()
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
                INS:SetOpen(wasVisible)
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
                local icons = {Main="house", Misc="eye", Misc2="grid", Other="three-sliders-horizontal", PvP="swords", Automation="lightning-bolt"}
                local tab = makeTab(raw:Tab(name, icons[name] or "gear"))
                self.Tabs[name] = tab
                return tab
            end
            function window:Set(id, value)
                local control = controls[id]
                if control and control.SetValue then control:SetValue(value) end
                return self
            end
            function window:CreatePopup(popupInfo)
                -- INS has one native window. Auxiliary settings use a dedicated page.
                local page = makeTab(raw:Tab(popupInfo.Title or "Settings", "gear"))
                page.Raw.Hidden = true
                local previousTab
                function page:Show()
                    if INS:GetSelectedTab() ~= self.Raw then previousTab = INS:GetSelectedTab() end
                    self.Raw.Hidden = false
                    INS:SelectTab(self.Raw)
                    INS:SetOpen(true)
                    return self
                end
                function page:Hide()
                    self.Raw.Hidden = true
                    if INS:GetSelectedTab() == self.Raw and previousTab then INS:SelectTab(previousTab) end
                    return self
                end
                function page:Set(id, value) window:Set(id, value); return self end
                return page
            end
            function window:InitializeSettings()
                if self._settingsReady then return end
                self._settingsReady = true
                raw:AddSettingsTab("gear")
                local tab = raw:Tab("Profiles", "folder")
                local section = tab:Section("Feature Profiles", "Full", "Save and load existing FRUIT-THINGY feature settings.")
                local name = section:Textbox("Profile name", "default", function(value) selectedConfig = safeConfigName(value) end)
                local picker = section:Dropdown("Saved profiles", {}, listConfigNames(), false, function(values)
                    if values[1] then selectedConfig = values[1]; name.Value = selectedConfig end
                end, "Existing feature profiles remain compatible.", true)
                section:Button("Save profile", function()
                    saveFeatureConfig(name.Value)
                    picker:UpdateChoices(listConfigNames())
                end)
                section:Button("Load profile", function() loadFeatureConfig(selectedConfig ~= "" and selectedConfig or name.Value) end)
                section:Button("Refresh profiles", function() picker:UpdateChoices(listConfigNames()) end)
            end
            function window:Show() INS:SetOpen(true); return self end
            function window:Hide() INS:SetOpen(false); return self end
            function window:SetVisible(value) INS:SetOpen(value); return self end
            function window:Step() return self end
            table.insert(self.Windows, window)
            return window
        end
        Library = Adapter
    end)
    if not ok or not Library then
        warn("Failed to load FRUIT-THINGY INS UI: " .. tostring(err))
        return
    end
end

