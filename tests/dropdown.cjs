const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const {lua, lauxlib, lualib, to_luastring, to_jsstring} = require("fengari");
const root = path.resolve(__dirname, "..");
const adapter = fs.readFileSync(path.join(root, "src/ui-adapter.lua"), "utf8");
const helper = adapter.slice(adapter.indexOf("        local function enableFullDropdowns("), adapter.indexOf("        local function roundingFor("));
assert(helper.includes("function enableFullDropdowns"));
assert(adapter.includes("dropdown.ShowAllOptions = info.ShowAllOptions == true"));
assert(adapter.includes("enableFullDropdowns(raw, adapter.Raw)"));
assert(adapter.includes("enableFullDropdowns(raw, self.Raw)"));
const controls = fs.readFileSync(path.join(root, "src/ui-controls.lua"), "utf8");
assert.match(controls, /Text="Material"[^\n]+ShowAllOptions=true/);
const materials = controls.match(/local MATERIAL_OPTIONS=\{([^\n]+)\}/)[1];
const values = [...materials.matchAll(/"([^"]+)"/g)].map(m => m[1]);
assert.equal(values.length, 13);
const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
for (const [key, value] of Object.entries({
    helperSource: helper + "\nreturn enableFullDropdowns",
    clickSource: fs.readFileSync(path.join(__dirname, "fixtures/upstream-dropdown-click.lua"), "utf8"),
    materialSource: "return {" + values.map(v => JSON.stringify(v)).join(",") + "}",
})) {
    lua.lua_pushstring(L, to_luastring(value));
    lua.lua_setglobal(L, to_luastring(key));
}
const code = fs.readFileSync(path.join(__dirname, "dropdown-cases.lua"), "utf8");
if (lauxlib.luaL_dostring(L, to_luastring(code)) !== lua.LUA_OK) {
    throw new Error(to_jsstring(lua.lua_tostring(L, -1)));
}
console.log("PASS: all 13 materials render and select; viewport bounds, multi-column layout, shrinking lists, and ordinary dropdown fallback.");
