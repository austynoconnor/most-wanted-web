# Local Windows preparation — 2026-10-08

Prepared by GPT-6 (Codex) on 2026-10-08, America/Chicago.

## Current workspace and interactive stability

The main workspace is now `C:\AI Work\Giggity Games`; this checkout is
`C:\AI Work\Giggity Games\NFS Most Wanted\most-wanted-web`. Most Wanted's
download is in the sibling `downloads` folder; earlier executable/install
extractions are under `NFS Most Wanted\inputs`. Bully, Metal Gear Solid 2 and
Resident Evil 4 each have their own game folder and `downloads` subfolder.
Shared download utilities are in the workspace's `_tools` folder. The previous dated Codex location is
retired. Downloads, source, submodule, analysis, tools, generated code, built
artifacts and browser profiles were moved together. File counts and total
bytes matched before and after the move: 11 download/input files totaling
14,871,169,710 bytes and 95,664 project files totaling 16,386,975,919 bytes,
before subsequent relocation repairs and documentation changes.

The user reported that the visible Chrome launch froze the PC and required
closing it while loading. Startup controls and a reduced worker/heap build
have now been verified through the menus under monitored headless Chrome.
The desktop freeze remains unverified, and memory use remains substantial.
See [browser stability](browser-stability.md) for measurements and limitations.
The game and previous public tunnel remain stopped.

The old absolute-path CMake caches are preserved in ignored
`build/cmake-before-move`; the working `build/cmake` was repaired to use the
new paths and subsequently completed a full browser rebuild.
Python activation paths and console entry points were repaired for the new
location. Python imports, CMake, Ninja, game-input validation and the relocated
Emscripten compiler were checked without launching the game or recompiling it.

- Internet Archive item: `need-for-speed-most-wanted-black-edition_202604`.
- Download: `../downloads/MostWanted-2005-BlackEdition.iso` (2,302,769,152 bytes).
- The image's SHA-1 matches Archive metadata: `f92404d39f7499206e6e4a73d5d5369939471de2`.
- Extracted 1,406 entries from the image's two ZIP archives into ignored `original/retail/`, without running its installer.
- Used the image's `PATCH/SPEED.EXE`, whose SHA-256 matches `game.toml`: `80774c2e5d619b4f120b48d4462896fd504c263399d203a238769cffde1d253c`.
- `tools/setup.py --install original/retail --link-only` accepted the inputs.
- Python 3.12 environment: `.venv312/` (excluded through `.git/info/exclude`); all pinned development dependencies installed.
- `python -m pytest -q tests`: four configuration tests passed.
- The initial Python 3.13 environment could not install the pinned NumPy wheel; use Python 3.12 for this checkout.

## Browser build preparation

- Installed Ghidra 12.1.3, Temurin JDK 25.0.4.1+1 and Emscripten 6.0.11 locally under ignored `.tools/`.
- Fixed `tools/analyze.py` to select `analyzeHeadless.bat` on Windows and pass the supported `GHIDRA_HEADLESS_MAXMEM` environment variable.
- The default Ghidra settings cache failed during Felix framework startup. A separate `.tools/ghidra-settings` directory allowed analysis to proceed.
- Ghidra exported all 25,768 discovered functions, with zero failed pseudocode exports. This is analysis coverage, not proof of complete or accurate game behavior.
- The runtime-only web build compiled successfully on Windows.
- Chrome's actual browser import stored 1,393 files (about 2.8 GB), reached Ready, obtained a WebGPU device and initialized the WebGPU renderer. Its log correctly reported that the runtime-only build contains no generated game code.
- The 41 web-launcher and build-tool tests passed. The broad portable suite reported 338 passed, 76 skipped and four failures: three tests require Windows symlink privileges; one requires a native C compiler. Those failures remain recorded and are not counted as passes.

## Rebuild on this Windows checkout

The local tools are intentionally untracked. A fresh checkout needs a Python 3.12 `.venv312` with `kit/requirements-dev.txt`, Ghidra 12.1.3 at `.tools/ghidra_12.1.3_PUBLIC`, JDK 25.0.4.1+1 at `.tools/jdk-25.0.4.1+1`, and Emscripten 6.0.11 installed and activated at `.tools/emsdk`.

```powershell
# Validates game files, analyzes if needed, translates and compiles the game.
./tools/build-web.ps1 -Jobs 8

# Re-run translation after changing its inputs.
./tools/build-web.ps1 -Regenerate -Jobs 8

# Re-run executable analysis as well.
./tools/build-web.ps1 -Analyze -Jobs 8

# Build only the runtime, without game code.
./tools/build-web.ps1 -Stub -Jobs 8

# Serve the game build with the required isolation headers.
./tools/serve-web.ps1 -Port 8000
```

## Full game browser build verification

The full translation and Emscripten build completed on 2026-10-08. The translator
emitted 36,690 functions and 42,544 entry points, with no unmodelled operations or
undecoded jump-table sites in its report. Eight guessed blocks were withdrawn;
these counts do not establish complete game compatibility.

The release kit now runs Emscripten link optimization and strips DWARF in
non-Debug builds. `SpeedRecomp.wasm` fell from 561,984,703 to 136,609,730 bytes.
The kit submodule points to the maintained fork containing this change.

Actual Chrome on the local NVIDIA GPU imported the game files, booted the
translated executable, displayed the title screen and rendered the animated 3D
main menu. The optimized build repeated this successfully.

A subsequent screen-guided Chrome check loaded the Century Square circuit in a
Fiat Punto. Up accelerated from 0 to 63 mph; Left and Right changed the car's
heading; Down reversed away from a wall at 26 mph; Escape displayed the pause
menu. Local screenshots and runtime logs are retained under ignored
`build/check-*.png` and `build/check-*.json`. The HUD showed roughly 39–51 fps
during these captures; this is a short headless run, not a performance benchmark.
No fatal/missing-block diagnostic was captured, but unsupported guest-thunk,
SetFVF and audio-starvation warnings remain. Braking from speed, audio
correctness, saves, loading reliability and full career completion still need
verification. This is a working gameplay prototype, not a complete game claim.

The relevant game configuration, launcher/build and browser player checks pass
(52 total), including hosted-download and cache recovery regressions.

Start `tools/serve-web.ps1 -Port 8025`, open
`http://127.0.0.1:8025/nfsmw/` and choose Start game. No folder selection is
needed: the local server exposes the validated installation through an explicit
asset manifest. The player downloads missing files into OPFS one at a time,
shows progress and then boots the browser engine. Its first load contains
1,393 files totaling 2,970,739,983 bytes; later visits use the validated cache.
Opening or restoring the player alone stays idle. Stop removes the runtime
and download worker, leaving cached files and saves available. An interrupted
first load can resume on the next Start.

This direct-play flow is currently served from localhost. A public URL requires
deploying the browser build and game assets to a suitable host; the GitHub source
push does not deploy them. The generic kit launcher still supports manual imports
for configurations that do not provide a hosted asset source.

A temporary Cloudflare tunnel was also checked in Chrome: the launcher rendered,
`crossOriginIsolated` was true, and the optimized Wasm endpoint served the correct
136,609,730-byte build. The tunnel depends on this computer and the running
server; it is not a permanent deployment. Game data is imported locally per
browser origin and is not hosted with the launcher.

Game inputs, extracted executables, generated code and downloaded installers must remain outside published source changes.
