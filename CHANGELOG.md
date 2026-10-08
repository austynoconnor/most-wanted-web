# Changelog

## Unreleased

- 2026-10-08 11:34 CDT — GPT-6 (Codex): Restored normal documentation
  paragraph spacing after a Windows newline conversion and clarified that
  the lower-overhead gameplay probe refused insufficient launch headroom.

- 2026-10-08 11:30 CDT — GPT-6 (Codex): Added opt-in streamed browser assets. Startup
  verifies and caches only the executable, then constructs a read-only FetchFS
  directory catalogue on the guest worker; profiles remain in OPFS and existing
  fully imported games keep their local read path. Hosted asset routes support
  sized HEAD responses and exact HTTP byte ranges, suffix reads, EOF clipping
  and 416 failures. Added a FetchFS bridge with a shared 64 MiB LRU and at most
  1 MiB per request instead of retaining every read chunk indefinitely. Range,
  startup-only imports, cache reuse, cross-chunk reads, eviction and incomplete
  responses are covered by tests. The release web engine built and an empty
  OPFS profile reached the actual title using range requests; its OPFS held
  only the 6,029,312-byte executable, catalogue and import metadata. Long default
  browser probes were stopped by the external resource watchdog near 4 GiB or
  below 2 GiB system headroom. Career, saved alias round trips and race completion
  remain unverified for this path. Streamed ranges are session memory, not a
  persistent offline installation. No public asset hosting was deployed.

- 2026-10-08 10:58 CDT — GPT-6 (Codex): Fixed duplicate typed characters
  by retaining host key-message provenance and preventing TranslateMessage
  from generating text already queued by the input gate. SDL text now preserves
  Shift/Caps Lock. Completed the browser rebuild and visually verified James
  in the real alias dialog, clearing the default NAME text, typing once, then
  using Backspace and retyping s. Added adaptive keyboard/controller hints below
  the canvas with Xbox, PlayStation, Nintendo and generic labels, last-used
  device switching and disconnect fallback. 53 relevant checks passed; added
  a native nested-message/text regression (not run as a native test suite on
  this host). Fixed stale hosted-manifest retries with no-store fetches. Updated
  verification limits and initial asset-size findings for progressive loading.
  Source changes only; game assets, captures and builds remain private.

- 2026-10-08 10:29 CDT — GPT-6 (Codex): Replaced the local NFS folder-import
  requirement with direct browser play. Start automatically downloads missing
  files from the validated installation, streams them into browser storage with
  progress and reuses the cache on later visits. Stop/session guards remain.
  Added incomplete-download detection and retry/resume coverage; source failures
  now close their OPFS writer. 52 relevant tests passed. A fresh Chrome profile
  automatically fetched 1,393 files (2,970,739,983 bytes); the corrected follow-up
  probe reached title/menu from that cache and stopped successfully, with a
  3,600 MiB peak and no watchdog intervention. Documented the initial probe's
  instrumentation error, local-only hosting and remaining desktop/race risks.
  No game assets or generated engine binaries are published in GitHub.

- 2026-10-08 10:15 CDT — GPT-6 (Codex): Pinned the browser startup stability
  changes in the kit fork after the user's PC froze while loading. The player
  waits for Start game, blocks duplicate sessions and removes its runtime on
  Stop. Rendering is bounded to 1280×720 without high-DPI multiplication;
  prewarmed workers fall from 24 to eight and the initial growable Wasm heap
  from 1 GiB to 512 MiB. Completed the full relocated Windows/Emscripten build
  (136,609,535-byte Wasm) and 49 relevant tests. Monitored headless Chrome
  reached the title and animated career menu at 200% scaling with a 1280×720
  backing canvas, 512 MiB heap and six active/two idle workers. Stop succeeded;
  the external watchdog did not trip. Peak private memory was 3,758 MiB,
  falling to 1,339 MiB five seconds after Stop under a test-only compiler-task
  limit. Documented that this does not prove ordinary desktop startup or the
  reported freeze is fixed. A follow-up headless run with default Chrome Wasm
  compiler settings also reached the menus and stopped without watchdog
  intervention (3,685 MiB peak, 1,357 MiB about four seconds after Stop).
  No game assets, private logs or builds published.

- 2026-10-08 09:33 CDT — GPT-6 (Codex): Organized the workspace by game.
  Most Wanted's complete repository, tools, analysis, generated builds and
  browser profiles now live in NFS Most Wanted/most-wanted-web; its ISO and
  earlier extraction inputs are in the same game folder. Bully, Metal Gear
  Solid 2 and Resident Evil 4 each have their own downloads folder. Verified
  the project move's file count/byte total, repaired Python entry points again,
  validated CMake and original game setup, and updated workspace guidance.
  Shared download tooling/metadata now lives in _tools and targets per-game
  folders. The game remains stopped; no rebuild or browser launch was run.

- 2026-10-08 09:29 CDT — GPT-6 (Codex): Moved all game downloads and the
  complete source/tools/analysis/build/profile workspace to
  C:\AI Work\Giggity Games. Verified identical file counts and byte totals
  across the move (31,258,145,629 bytes total). Preserved old CMake caches
  separately, repaired relocated Python activation/console entry points and
  verified Python dependencies, CMake, Ninja, game-input setup and Emscripten.
  Updated workspace guidance and recorded the user's visible-Chrome PC freeze;
  stopped the server/tunnel and performed no game launch or full rebuild.

- 2026-10-08 03:23 CDT — GPT-6 (Codex): Verified browser gameplay in a
  Century Square circuit with the Fiat Punto: acceleration to 63 mph,
  left/right steering, reverse to 26 mph and the pause menu. Recorded the
  actual Chrome/NVIDIA checks, remaining diagnostics and unverified features
  in docs/local-setup.md; added the current browser milestone to README.md.
  Relevant Python tests: 45 passed. Verified the temporary external launcher
  and its isolation headers. Full-career, audio, saves and repeated loading
  reliability remain open; no private captures or game assets are published
  in source control.

- 2026-10-08 03:15 CDT — GPT-6 (Codex): Completed the original executable's
  translation and full Emscripten browser build. Verified the actual title
  screen and animated 3D main menu in Chrome using local NVIDIA WebGPU.
  Pinned the kit fork's release-link optimization, reducing shipped Wasm from
  561,984,703 to 136,609,730 bytes, and documented browser import and launch.
  No game files or generated binaries are committed. Race and full-career
  verification remain outstanding.

- 2026-10-08 02:58 CDT — GPT-6 (Codex): Started the Windows-to-browser
  build pipeline using the verified original game files. Fixed Ghidra's
  Windows launcher selection and headless heap configuration; added
  tools/build-web.ps1 and tools/serve-web.ps1 for validated input preparation,
  analysis, translation, Emscripten compilation and isolated local serving.
  Recorded the tool versions, 25,768 exported functions, successful runtime-only
  browser compilation and Chrome import/WebGPU checks in docs/local-setup.md.
  Web/build tests: 41 passed. The broader tooling suite has four environment
  failures (symlink privileges/native C compiler), recorded without claiming
  them as passes. Full gameplay verification remains outstanding.

- 2026-10-08 02:38 CDT — GPT-6 (Codex): Prepared local Windows inputs for
  browser-port work. Verified the PC Black Edition image against its source
  checksum, extracted 1,406 game entries into ignored original/retail, and
  confirmed the included patched executable matches game.toml. Installed the
  pinned Python dependencies using Python 3.12 after a Python 3.13 NumPy
  incompatibility; all four game configuration tests pass and setup accepts
  the inputs. Added docs/local-setup.md with reproducible input identifiers,
  checksums and remaining build requirements. No browser gameplay is verified.

- Fix stick knobs not moving independently when dragging the touch gamepad.
  Their visual positions now update while bases and touch zones stay put
  during the drag.

- Fix iPad touch and mouse targeting when the GPU renders above the game's
  resolution; the cursor now uses the logical game frame rather than the
  supersampled texture's size.

- Give the touch gamepad a racing preset: cross accelerates, square brakes,
  the left stick steers, circle applies the handbrake, triangle confirms
  menus, and Start pauses/goes back. Vertical stick movement no longer
  presses the throttle or brake.

- Correct touch clicks displaced by the virtual window's desktop position,
  including mouse messages processed after the original touch event.

- Restore 25 routines reached during menu and race setup. Remove 34 false
  translation entries inside instructions that blocked recovery, causing
  indirect-jump crashes and stack corruption from skipped calls.

- Preserve visible gamepad sticks and buttons when switching from a
  collapsed keyboard.

- Expose the Controls rows in the F10 settings page.

- Keep tablet KEYS tabs and keyboard halves inside the system safe area.

- Correct the red/blue swap in displayed GPU frames, restoring the original
  green and warm tones in game graphics and movies.

- Hide the on-screen keyboard HIDE/KEYS tabs when a hardware keyboard or
  controller auto-hides the controls; retain the layout switch and saved visibility.

- Re-pin the kit to `main` 30fb57d. The merge that landed this game's kit
  work on main had dropped 27 kernel32 import declarations; an import with no
  table entry has an unknown argument count, so every call to one leaked its
  arguments and a thread polling a timer walked the guest stack ten megabytes
  below itself into `.bss`, where it overwrote a callback table with its own
  return addresses and died four subsystems away in SEH. Restored. Recovery
  now arbitrates on evidence rather than on which guess resolved first
  (36,566 to 36,717 functions, against 36,718 for the translator this port
  was built on), `__initterm` is matched by its shape rather than by one
  register allocation, and `RECOMP_NULL_FAULTS` can make the never-mapped
  first 64 KB fault the way Windows does (a build option, off by default,
  because the guest reaches those reads with pointers Windows would have
  filled in). `SystemTimeToFileTime` was declared and empty; implemented.
- 836 CRT static initializers had never run. This executable's `__initterm`
  keeps its cursor on the stack and calls through `EDX`, and the kit knew
  only the `ESI`/`CALL EAX` spelling, so the CRT walked its table, called
  each constructor through the address table, and the address table had never
  heard of them: every one of those globals reached the game with a null
  vtable and null members. One owns a bitset whose base stayed null, so the
  guest set bits at guest `0x138` and read them back from the same place.
- `game.toml` names eight entry points a run proved, where recovery does not
  reach them: `0x006db6c0` is a thread start routine, so the thread it
  belongs to returned immediately and did nothing; `0x007cd5e4` is an SEH
  handler, and without it a fault the game handles itself reached the
  dispatcher as `ExceptionContinueExecution` and stopped the run. The last
  three were each reachable only once the one before it could be delivered. A
  quick-race run now reports no undeliverable calls at all, where every run
  before it named at least one.
- The game renders its front end and career menus, reaches track select and
  drives a race, and one or two runs in five play `smoke/quick-race.script`
  to the end with `guest exit code 0`. The rest hang entering race loading:
  the main thread spins in a translated function rather than deadlocking, so
  the watchdog reports it as the guest no longer calling into the runtime.
  Measured at 0 to 2 in 5 across three kit configurations, none
  distinguishable from another at that sample size, so nothing in this
  re-pin is a regression and five runs cannot settle the question either way.
  Recorded in `docs/analysis.md` with the instruments that move it and the
  one that does not.

- The translation compiles and the game boots as far as its first Direct3D 9
  call. `game.toml` names two CRT helper entry points the Ghidra listing
  lacks; everything else was kit work (see the kit's changelog): MMX/SSE2
  traps, `XADD`, `CMPXCHG`, `LAHF`, the x87 constants and environment ops,
  `INT3` as a block terminator, `GetModuleHandleA` for served modules, 19
  kernel32 shims and stdcall pop counts for the unshimmed imports. Recorded
  in `docs/analysis.md`. The window path works too: `RegisterClassExA`,
  `AdjustWindowRect` and `GlobalMemoryStatusEx` landed in the kit, and the
  guest stack no longer drifts. With the kit's new Direct3D 9 and D3DX 9
  modules the game now boots, creates its device, streams its audio and runs
  its own render loop without crashing. It draws nothing yet: device
  resources and shader translation are the remaining work. With the kit's
  vtable pop counts corrected the game now runs without crashing at all, and
  it draws: seven DrawPrimitiveUP calls inside seven effect passes, with
  every guest call resolved. Nothing is rasterized yet.
- Re-pin the kit to `main` 4574a35, the commit the other game repositories
  pin; `game.toml` gains the `entry_points` key and CI takes the current
  three-platform shape. On this kit the translator clears discovery and
  emits code for all but 40 of the 25,768 functions; the 40 need MMX, SSE2,
  `STMXCSR`, two x87 constants, `FNSTENV` and `LAHF` in the kit's
  translator. Recorded in `docs/analysis.md`.
- New game repository for Need for Speed: Most Wanted (PC Black Edition,
  `speed.exe` SHA-256 `80774c2e…d253c`) in the shape of populous-recomp: the
  kit as the submodule `kit/`, `game.toml` and `globals.toml`, thin
  `tools/*.py` wrappers, config tests and CI.
- `game.toml` carries the measured identity of the executable (image base
  `0x00400000`, entry point `0x007c4040`, guest root, required data
  directories, iOS bundle exclusions). The Populous-shaped hooks and globals
  the kit compiles against are sentinels in the executable's unused section
  padding until the bring-up identifies them; `tests/test_game_config.py`
  enforces that.
- `tools/analyze.py`: listing export with Ghidra's own analyzers, because the
  kit's setup expects a curated annotation set this game does not have.
- First pipeline run recorded in `docs/analysis.md`: Ghidra exports 25,768
  functions; the kit's translator parses them all and stops at its discovery
  gates (638 dispatch targets outside any listing, mostly fall-throughs after
  calls Ghidra marks non-returning). No translation compiles yet.
- `docs/analysis.md`: the executable's import surface, graphics path and the
  kit work each needs. The blocking item is shader-model Direct3D 9 through
  D3DX effects, outside the kit's supported envelope today.
