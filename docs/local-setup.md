# Local Windows preparation — 2026-10-08

Prepared by GPT-6 (Codex) on 2026-10-08, America/Chicago.

- Internet Archive item: `need-for-speed-most-wanted-black-edition_202604`.
- Download: `../game-inputs/MostWanted-2005-BlackEdition.iso` (2,302,769,152 bytes).
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

The real game translation/build and gameplay verification are in progress. A successful runtime-only build is not a playable game.

Game inputs, extracted executables, generated code and downloaded installers must remain outside published source changes.
