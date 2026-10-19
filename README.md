# FRUIT THINGY

The imported Blox Fruits script is split into 26 feature source files.

## Start

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/voidlinksbuisness-sudo/FRUIT-THINGY/main/loader.lua"))()
```

The original `blox fruits` URL also remains an entry point and runs the same loader.

## How the files work together

- `loader.lua` resolves the current main commit, downloads `main.lua`, and passes its revision URL to the main runner.
- `main.lua` lists and downloads the feature files under `src/` in their original order. Every file is fetched from that same commit. Download or compilation errors stop startup with the failing file identified.
- The source files are concatenated and compiled together. This deliberately keeps original local variables, captured callbacks, early returns, and initialization order intact. They are source modules, not independent `require` modules.
- `blox fruits` is a compatibility copy of the loader; it no longer contains feature code.
- `source-map.json` records each feature file's original line range and the original Git blob hash.

Features are grouped into state/quest/navigation data, UI adapter and controls, boat seats and movement, collectibles, settings, fruit/berry/world ESP, combat, dungeons, collection/farming, level farming, ESP updates, pull loops, PvP/enemy auras, fishing, repair, mastery, velocity/keybinds, world automation, and keepalive.

No feature code was removed or rewritten. Concatenating the files in the main manifest reproduces the imported source byte for byte, including its external UI dependency and existing behavior. This does not bundle the separate external UI library referenced by the original script. The original runtime requirements (`game:HttpGet`, `loadstring`, drawing/input APIs, and the Blox Fruits environment) still apply. The loader additionally uses `HttpService:JSONDecode` to resolve a consistent revision.

## Validation

With Node.js installed:

```sh
npm install
npm test
```

The integrity check verifies the exact original Git blob, manifest order, and compatibility loader. Mocked Lua tests cover source assembly, shared locals and closures, early returns, revision pinning, and failed downloads/compilation without executing the game code.

Live gameplay has not been tested. Existing game compatibility, timing behavior, and upstream UI availability are unchanged by the source split. When changing feature code intentionally, update the baseline hash and source map as appropriate.
