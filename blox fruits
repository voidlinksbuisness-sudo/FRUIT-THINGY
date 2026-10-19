-- FRUIT-THINGY entry point. Resolve main once so every file comes from one revision.
local repository = "voidlinksbuisness-sudo/FRUIT-THINGY"
assert(type(loadstring) == "function", "FRUIT-THINGY requires loadstring")

local function fetch(url)
    local ok, result = pcall(function() return game:HttpGet(url) end)
    if not ok or type(result) ~= "string" or result == "" then
        error("FRUIT-THINGY could not download " .. url .. ": " .. tostring(result), 0)
    end
    return result
end

local metadata = fetch("https://api.github.com/repos/" .. repository .. "/commits/main")
local ok, commit = pcall(function()
    return game:GetService("HttpService"):JSONDecode(metadata)
end)
local revision = ok and type(commit) == "table" and commit.sha or nil
if type(revision) ~= "string" or #revision ~= 40 or revision:find("[^%da-f]") then
    error("FRUIT-THINGY could not resolve the main branch revision", 0)
end

local baseUrl = "https://raw.githubusercontent.com/" .. repository .. "/" .. revision .. "/"
local main, compileError = loadstring(fetch(baseUrl .. "main.lua"), "@FRUIT-THINGY/main.lua")
if not main then error("FRUIT-THINGY main compile failed: " .. tostring(compileError), 0) end
local run = main()
if type(run) ~= "function" then error("FRUIT-THINGY main did not return a runner", 0) end
return run(baseUrl)
