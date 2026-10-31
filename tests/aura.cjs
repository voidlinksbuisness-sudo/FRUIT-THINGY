const fs=require('node:fs');
const {lua,lauxlib,lualib,to_luastring,to_jsstring}=require('fengari');
const L=lauxlib.luaL_newstate();lualib.luaL_openlibs(L);
const source=fs.readFileSync('src/enemy-aura.lua','utf8').replace('    task.spawn(function()', '    _TEST={state=aura,tick=aura_tick}\n    task.spawn(function()');
lua.lua_pushstring(L,to_luastring(source));lua.lua_setglobal(L,to_luastring('source'));
if(lauxlib.luaL_dostring(L,to_luastring(fs.readFileSync('tests/aura-cases.lua','utf8')))!==lua.LUA_OK)throw Error(to_jsstring(lua.lua_tostring(L,-1)));
console.log('PASS: NPC aura fresh remotes, class-based Humanoids, malformed/despawning NPCs, toggle cancellation, failure recovery, and retry after missing remotes.');
