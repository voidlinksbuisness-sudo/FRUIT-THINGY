const fs=require('node:fs');
const {lua,lauxlib,lualib,to_luastring,to_jsstring}=require('fengari');
const L=lauxlib.luaL_newstate();lualib.luaL_openlibs(L);
const source=fs.readFileSync('src/pumpkin-farming.lua','utf8').replace('    task.spawn(function()', '    _TEST={step=step}\n    task.spawn(function()');
lua.lua_pushstring(L,to_luastring(source));lua.lua_setglobal(L,to_luastring('source'));
if(lauxlib.luaL_dostring(L,to_luastring(fs.readFileSync('tests/pumpkin-cases.lua','utf8')))!==lua.LUA_OK)throw Error(to_jsstring(lua.lua_tostring(L,-1)));
console.log('PASS: nearest pumpkin, duplicate names, repeated M1 until removal, Jack priority/interruption, selected slot equip, missing folders, and toggle cancellation.');
