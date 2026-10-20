# FRUIT THINGY

Blox Fruits features split into 26 source modules, using the INS GUI from the `voidlinksbuisness-sudo/scripts` project's `fftm_main.lua`.

## Start

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/voidlinksbuisness-sudo/FRUIT-THINGY/main/loader.lua"))()
```

The original `blox fruits` path remains a compatibility entry point. The loader resolves a main-branch commit once, so main, feature modules, and the GUI library use the same revision. Matcha's discarded chunk return values are supported through shared exports.

## Interface

The interface uses the reference script's INS sidebar, two-column cards, background image, search, keybind overlay, and native settings. Press **End** to show or hide the menu. Existing tabs and feature controls retain their callbacks and IDs, including Auto V4 and the Chest ESP performance fix.

Tween and boost settings open as auxiliary pages within the same INS window. Their Close buttons return to the previous tab. Material choices use the full list when it fits; smaller screens retain every choice through native dropdown search and scrolling.

The **Profiles** tab saves and loads the existing version-4 feature profiles from `laced_club_configs`. The native settings gear controls the GUI appearance and input preferences separately.

## Structure

- `loader.lua`: revision resolution and Matcha-compatible handoff.
- `main.lua`: downloads and assembles the ordered feature source modules in a single lexical scope.
- `src/ui-adapter.lua`: translates the existing feature controls to INS controls, including scalar dropdowns, multi-selection maps, priority lists, keybinds, configuration, and settings-page navigation.
- `lib/ins-ui.lua`: pinned copy of the same INS library referenced by the supplied GUI, with small local compatibility/layout fixes recorded in `lib/ins-ui.source.json`.
- `source-map.json`: original import line ranges and current assembled-feature baseline.

The background image remains referenced from the immutable asset URL used by the supplied GUI. Background resizing uses the cached image; it does not request a replacement image on each resize.

## Chest ESP performance

Chest discovery yields in batches of 32 and holds metadata only. Updates reuse at most 128 labels for the nearest on-screen chests within the original 10,000-stud range. Extra chests remain tracked as the player and camera move. Disabling the feature cancels pending work and removes its drawings.

## Validation

```sh
npm install
npm test
```

Tests verify the assembled-feature baseline, loader and Matcha handoff, material dropdown access/layout, Chest ESP limits/cancellation, and integration with the actual INS library's constructors under mocked host services. GUI integration checks existing controls, callback values, attached keybinds, slider updates, priority swaps, feature profile round-trips, auxiliary settings navigation, and discarded library returns.

Game and drawing/input APIs are mocked in these tests; live Matcha rendering and gameplay have not been verified here.
