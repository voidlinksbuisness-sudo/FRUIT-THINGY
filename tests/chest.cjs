const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const {lua, lauxlib, lualib, to_luastring, to_jsstring} = require("fengari");
const root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root, p), "utf8");
const world = read("src/world-esp.lua");
const chest = world.slice(world.indexOf("-- Chest discovery"), world.indexOf("local function getBoatEspKey"));
const esp = read("src/fruit-and-berry-esp.lua");
const clear = esp.slice(esp.indexOf("function clearChestEspLabels()"), esp.indexOf("function clearBerryEspLabels()"));
const updates = read("src/esp-updates.lua");
const loop = updates.slice(updates.indexOf("if S.chestEsp then"), updates.indexOf("if S.berryEsp then"));
assert(loop.includes("task.wait(0.1)"));
assert(!updates.includes('trackedFolderChanged("chests"'));
const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
lua.lua_pushstring(L, to_luastring(chest + "\n" + clear));
lua.lua_setglobal(L, to_luastring("chestSource"));
if (lauxlib.luaL_dostring(L, to_luastring(read("tests/chest-cases.lua"))) !== lua.LUA_OK) {
    throw new Error(to_jsstring(lua.lua_tostring(L, -1)));
}
console.log("PASS: 2,000-chest stress test, bounded drawings/projection batches, pooling across respawns, invalid parts, respawn, cleanup, and toggle cancellation.");
