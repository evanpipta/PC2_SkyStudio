# SkyStudio
This mod provides a way to adjust the sun and moon direction and lighting values in PC2

See Readme.md in src/ for more info

## Park-save settings hook

When `bSaveSettingsToPark` is enabled in `Config.lua`, SkyStudio injects its
config into park metadata via `ParkLoadSaveManager.GenerateCurrentParkMetaData`.

- **With ForgeUtils (recommended for mod packs):** uses ForgeUtils' shared
  `HookManager` so other mods that also hook park metadata (e.g.
  BetterCamOffsets) compose cleanly.
- **Without ForgeUtils:** uses the original reliable clobbering wrap. SkyStudio
  park save/load still works alone, but it is not cooperative with other mods'
  hand-rolled hooks. Install ForgeUtils if you want full cross-mod save/load
  compatibility.

