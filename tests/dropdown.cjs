const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const {lua, lauxlib, lualib, to_luastring, to_jsstring} = require("fengari");
const root = path.resolve(__dirname, "..");
const lib = fs.readFileSync(path.join(root, "lib/ins-ui.lua"), "utf8");
const start = lib.indexOf("  local function OpenDropdown(");
const end = lib.indexOf("  function DrawDropdown(row", start);
const selectStart = lib.indexOf("  local function SetDropdownValue(");
const selectEnd = lib.indexOf("  local function ResetDropdownScroll()", selectStart);
assert(start > 0 && end > start && selectStart > 0);
const layout = {};
for (const key of ["ListHeader","ListVisible","ListRow","ListPad","ListMargin"]) {
    const value = lib.match(new RegExp("^\\s*" + key + "\\s*=\\s*([0-9.]+)", "m"));
    assert(value, key);
    layout[key] = Number(value[1]);
}
const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
for (const [key, value] of Object.entries({
    openSource:lib.slice(start, end), selectSource:lib.slice(selectStart, selectEnd),
    layoutSource:"return {" + Object.entries(layout).map(([k,v]) => k + "=" + v).join(",") + "}",
})) {
    lua.lua_pushstring(L, to_luastring(value)); lua.lua_setglobal(L, to_luastring(key));
}
const cases = fs.readFileSync(path.join(__dirname, "dropdown-cases.lua"), "utf8");
if (lauxlib.luaL_dostring(L, to_luastring(cases)) !== lua.LUA_OK) throw new Error(to_jsstring(lua.lua_tostring(L, -1)));
console.log("PASS: native INS dropdown preserves all 13 choices, renders the full list when it fits, and keeps a scrollable/searchable list on short screens.");
