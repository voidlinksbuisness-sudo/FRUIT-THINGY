const fs = require("node:fs");
const path = require("node:path");
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = require("fengari");
const root = path.resolve(__dirname, "..");
const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
for (const [key, file] of [["mainSource", "main.lua"], ["loaderSource", "loader.lua"]]) {
    lua.lua_pushstring(L, to_luastring(fs.readFileSync(path.join(root, file), "utf8")));
    lua.lua_setglobal(L, to_luastring(key));
}
const paths = JSON.parse(fs.readFileSync(path.join(root, "source-map.json"), "utf8")).modules.map(m => m.path);
lua.lua_pushstring(L, to_luastring(Buffer.concat(paths.map(p => fs.readFileSync(path.join(root, p)))).toString("utf8")));
lua.lua_setglobal(L, to_luastring("originalSource"));
const tests = fs.readFileSync(path.join(__dirname, "loader-cases.lua"), "utf8");
if (lauxlib.luaL_dostring(L, to_luastring(tests)) !== lua.LUA_OK) {
    throw new Error(to_jsstring(lua.lua_tostring(L, -1)));
}
console.log("PASS: loader/main assembly, shared locals, closures, early return, revision pinning, discarded chunk returns, shared exports, and failure handling.");
