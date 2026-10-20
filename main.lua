-- These source modules deliberately share ONE lexical scope.
-- Do not loadstring/require them separately: that would change local bindings,
-- callbacks, early returns, and startup order from the original script.
local modules = {
    "src/state.lua",
    "src/quest-data.lua",
    "src/navigation-data.lua",
    "src/ui-adapter.lua",
    "src/ui-controls.lua",
    "src/boat-seats-and-collectibles.lua",
    "src/settings-popups.lua",
    "src/boat-movement.lua",
    "src/fruit-and-berry-esp.lua",
    "src/movement.lua",
    "src/world-esp.lua",
    "src/combat.lua",
    "src/dungeon.lua",
    "src/fire-flowers.lua",
    "src/collection-and-farming.lua",
    "src/level-farming.lua",
    "src/esp-updates.lua",
    "src/pull-and-farm-loops.lua",
    "src/pvp-farming.lua",
    "src/enemy-aura.lua",
    "src/pvp-aura.lua",
    "src/fishing.lua",
    "src/repair.lua",
    "src/mastery.lua",
    "src/velocity-and-keybinds.lua",
    "src/world-and-automation.lua",
    "src/keepalive.lua",
}

local function run(baseUrl)
    assert(type(baseUrl) == "string" and baseUrl:sub(-1) == "/", "FRUIT-THINGY needs a revision base URL")
    local sources = {}
    -- Download every module before starting any feature.
    for index, path in ipairs(modules) do
        local ok, source = pcall(function() return game:HttpGet(baseUrl .. path) end)
        if not ok or type(source) ~= "string" or source == "" then
            error("FRUIT-THINGY module download failed (" .. path .. "): " .. tostring(source), 0)
        end
        sources[index] = source
    end
    -- Each file retains its original newlines; insert no wrappers or separators.
    local runtime, compileError = loadstring(table.concat(sources), "@FRUIT-THINGY/runtime")
    if not runtime then error("FRUIT-THINGY runtime compile failed: " .. tostring(compileError), 0) end
    -- The UI library is fetched from this same immutable revision by the adapter.
    _G.FRUIT_THINGY_BASE_URL = baseUrl
    local shared = (type(getgenv) == "function" and getgenv()) or _G
    if type(shared) == "table" then shared.FRUIT_THINGY_BASE_URL = baseUrl end
    return runtime()
end

-- Matcha can discard return values from loadstring chunks. Publish the same
-- runner through the shared environment as well as returning it.
local environment = (type(getgenv) == "function" and getgenv()) or _G
if type(environment) == "table" then environment.FRUIT_THINGY_MAIN = run end
return run
