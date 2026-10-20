const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const crypto = require("node:crypto");
const {lua, lauxlib, lualib, to_luastring, to_jsstring} = require("fengari");
const root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root, p), "utf8");
const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
for (const [name, file] of Object.entries({
    libSource:"lib/ins-ui.lua", adapterSource:"src/ui-adapter.lua",
    stateSource:"src/state.lua", controlsSource:"src/ui-controls.lua",
    popupsSource:"src/settings-popups.lua",
})) {
    lua.lua_pushstring(L, to_luastring(read(file)));
    lua.lua_setglobal(L, to_luastring(name));
}
if (lauxlib.luaL_dostring(L, to_luastring(read("tests/gui-cases.lua"))) !== lua.LUA_OK) {
    throw new Error(to_jsstring(lua.lua_tostring(L, -1)));
}
const provenance = JSON.parse(read("lib/ins-ui.source.json"));
const bytes = Buffer.from(read("lib/ins-ui.lua"));
const sha = crypto.createHash("sha1").update(Buffer.from("blob " + bytes.length + "\0")).update(bytes).digest("hex");
assert.equal(sha, provenance.localBlobSha);
console.log("PASS: actual INS library and FRUIT controls construct together; callbacks, keybinds, dropdowns, priority, profiles, settings pages, and discarded chunk returns.");
