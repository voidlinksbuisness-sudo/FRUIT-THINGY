const fs=require('node:fs');
const {lua,lauxlib,lualib,to_luastring,to_jsstring}=require('fengari');
const L=lauxlib.luaL_newstate();lualib.luaL_openlibs(L);
const source=fs.readFileSync('src/enemy-aura.lua','utf8').replace('    mainTab:AddSection("NPC Aura"','    _TEST={state=aura,attack=aura_attack}\n    mainTab:AddSection("NPC Aura"');
lua.lua_pushstring(L,to_luastring(source));lua.lua_setglobal(L,to_luastring('source'));
if(lauxlib.luaL_dostring(L,to_luastring(fs.readFileSync('tests/control-aura-cases.lua','utf8')))!==lua.LUA_OK)throw Error(to_jsstring(lua.lua_tostring(L,-1)));
console.log('PASS: Control remote sequence, normalized nearest-NPC aim, cooldown, toggle gates, missing remotes, failure isolation, and respawn.');
