-- Test only the loader with mocked HTTP. The game/feature code is never executed.
local nativeLoad = load
local paths = {}
for path in mainSource:gmatch('"(src/[^"]+%.lua)"') do paths[#paths + 1] = path end
assert(#paths == 26)

local revision = string.rep("a", 40)
local base = "https://raw.githubusercontent.com/voidlinksbuisness-sudo/FRUIT-THINGY/" .. revision .. "/"
local api = "https://api.github.com/repos/voidlinksbuisness-sudo/FRUIT-THINGY/commits/main"
local responses, requests, started, assembled, mode, badRevision

local function reset()
    responses, requests = {}, {}
    started, assembled, mode, badRevision = false, nil, "capture", nil
    responses[api] = "metadata"
    responses[base .. "main.lua"] = mainSource
    for _, path in ipairs(paths) do responses[base .. path] = "-- fixture\n" end
end

game = {}
function game:HttpGet(url)
    requests[#requests + 1] = url
    local response = responses[url]
    if response == nil then error("missing fixture: " .. url) end
    return response
end
function game:GetService(name)
    assert(name == "HttpService")
    return {
        JSONDecode = function(_, text)
            assert(text == "metadata", "invalid metadata")
            return {sha = badRevision or revision}
        end,
    }
end
function loadstring(source, name)
    if name == "@FRUIT-THINGY/runtime" then
        assembled = source
        if mode == "capture" then
            return function() started = true; return "feature-runtime" end
        elseif mode == "compile-failure" then
            return nil, "fixture syntax error"
        end
    end
    return nativeLoad(source, name)
end

local function runMain()
    return assert(nativeLoad(mainSource, "main.lua"))()(base)
end
local function runLoader()
    return assert(nativeLoad(loaderSource, "loader.lua"))()
end

reset()
assert(runMain() == "feature-runtime")
assert(assembled == string.rep("-- fixture\n", #paths))
assert(started and #requests == #paths)
for i, path in ipairs(paths) do assert(requests[i] == base .. path) end

-- Across files, locals and closures must keep one shared lexical scope.
reset()
mode = "native"
responses[base .. paths[1]] = "local count = 1\nlocal function readCount() return count end\n"
for i = 2, #paths - 1 do responses[base .. paths[i]] = "count = count + 1\n" end
responses[base .. paths[#paths]] = "return count, readCount()\n"
local first, second = runMain()
assert(first == #paths - 1 and second == first)

-- Early returns still stop the entire script, as in the UI adapter.
reset()
mode = "native"
responses[base .. paths[1]] = 'do return "stopped" end\n'
responses[base .. paths[2]] = 'error("must not run")\n'
assert(runMain() == "stopped")

-- A missing/empty module at ANY position prevents all feature execution.
for _, path in ipairs(paths) do
    for _, value in ipairs({false, ""}) do
        reset()
        if value == false then responses[base .. path] = nil
        else responses[base .. path] = value end
        local ok, err = pcall(runMain)
        assert(not ok and tostring(err):find(path, 1, true))
        assert(not started and assembled == nil)
    end
end

reset()
mode = "compile-failure"
local ok, err = pcall(runMain)
assert(not ok and tostring(err):find("runtime compile failed", 1, true) and not started)

-- Loader resolves one revision and fetches main and all source at that SHA.
reset()
assert(runLoader() == "feature-runtime")
assert(requests[1] == api and requests[2] == base .. "main.lua")
assert(#requests == #paths + 2)
for i, path in ipairs(paths) do assert(requests[i + 2] == base .. path) end

for _, revisionValue in ipairs({"main", string.rep("z", 40), string.rep("a", 39)}) do
    reset()
    badRevision = revisionValue
    local success, message = pcall(runLoader)
    assert(not success and tostring(message):find("resolve the main branch revision", 1, true))
    assert(not started and #requests == 1)
end

for _, url in ipairs({api, base .. "main.lua", base .. paths[1]}) do
    reset()
    responses[url] = nil
    assert(not pcall(runLoader))
    assert(not started)
end

reset()
responses[api] = "not JSON"
assert(not pcall(runLoader) and not started)

reset()
responses[base .. "main.lua"] = "this is not valid Lua"
assert(not pcall(runLoader) and not started)

reset()
responses[base .. "main.lua"] = "return 42"
assert(not pcall(runLoader) and not started)

-- Feed the full original code to the assembly hook; do not execute it.
reset()
local offset = 1
for i, path in ipairs(paths) do
    local remaining = #originalSource - offset + 1
    local length = i == #paths and remaining or math.floor(#originalSource / #paths)
    responses[base .. path] = originalSource:sub(offset, offset + length - 1)
    offset = offset + length
end
assert(runLoader() == "feature-runtime")
assert(assembled == originalSource and offset == #originalSource + 1)
