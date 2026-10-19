# FRUIT THINGY

The imported Blox Fruits script is split into 26 feature source files.

## Start

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/voidlinksbuisness-sudo/FRUIT-THINGY/main/loader.lua"))()
```

The original `blox fruits` URL also remains an entry point and runs the same loader.

## How the files work together

- `loader.lua` resolves the current main commit, downloads `main.lua`, and passes its revision URL to the main runner.
- Matcha compatibility: main also exports its runner through the shared environment when loaded-chunk return values are discarded. The loader clears that temporary export after handoff.
- `main.lua` lists and downloads the feature files under `src/` in their original order. Every file is fetched from that same commit. Download or compilation errors stop startup with the failing file identified.
- The source files are concatenated and compiled together. This deliberately keeps original local variables, captured callbacks, early returns, and initialization order intact. They are source modules, not independent `require` modules.
- `blox fruits` is a compatibility copy of the loader; it no longer contains feature code.
- `source-map.json` records each feature file's original line range and the original Git blob hash.

Features are grouped into state/quest/navigation data, UI adapter and controls, boat seats and movement, collectibles, settings, fruit/berry/world ESP, combat, dungeons, collection/farming, level farming, ESP updates, pull loops, PvP/enemy auras, fishing, repair, mastery, velocity/keybinds, world automation, and keepalive.

The initial split preserved the import byte for byte. The material dropdown now overrides the upstream eight-item cap to show every material, moves above the control when needed, and uses columns on short screens. Other dropdowns use their existing renderer. The assembled-source baseline tracks this intentional fix. This does not bundle the separate external UI library referenced by the original script. The original runtime requirements (`game:HttpGet`, `loadstring`, drawing/input APIs, and the Blox Fruits environment) still apply. The loader additionally uses `HttpService:JSONDecode` to resolve a consistent revision.

## Validation

With Node.js installed:

```sh
npm install
npm test
```

The integrity check verifies the current assembled-source baseline, manifest order, and compatibility loader. The original import hash remains recorded in the source map. Mocked Lua tests cover source assembly, shared locals and closures, early returns, revision pinning, discarded chunk returns, stale exports, and failed downloads/compilation without executing the game code. Dropdown tests render all thirteen materials against mocked drawing objects and select each using the upstream click handler at desktop and small viewport sizes.

Live gameplay has not been tested. Existing game compatibility, timing behavior, and upstream UI availability are unchanged by the source split. When changing feature code intentionally, update the baseline hash and source map as appropriate.
