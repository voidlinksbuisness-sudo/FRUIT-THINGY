const fs=require('node:fs');
const {lua,lauxlib,lualib,to_luastring,to_jsstring}=require('fengari');
const L=lauxlib.luaL_newstate();lualib.luaL_openlibs(L);
let source=fs.readFileSync('src/mastery.lua','utf8').replace('    task.spawn(function()', '    _TEST={matches=matches,equip=equip,aim=aim}\n    task.spawn(function()');
lua.lua_pushstring(L,to_luastring(source));lua.lua_setglobal(L,to_luastring('source'));
lua.lua_pushstring(L,to_luastring(fs.readFileSync('src/combat.lua','utf8').split('local REMOTE_SESSION_ID')[0]));lua.lua_setglobal(L,to_luastring('combatSource'));
if(lauxlib.luaL_dostring(L,to_luastring(fs.readFileSync('tests/mastery-cases.lua','utf8')))!==lua.LUA_OK)throw Error(to_jsstring(lua.lua_tostring(L,-1)));
console.log('PASS: mastery weapon selection, wrong-weapon rejection, gun projection, off-screen aiming, and nearest-farm cancellation.');
