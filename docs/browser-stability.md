# Browser stability investigation — 2026-10-08

The user reported that the visible Chrome launch froze the PC while loading.
The earlier successful headless race did not establish interactive startup
stability. The exact cause of that desktop freeze has not been reproduced.

## Confirmed startup behavior and changes

The previous player automatically loaded the engine when its URL was opened.
Restored browser tabs could therefore start a game without a new user action,
and there was no guard against another tab starting the same game. The
compiled runtime preloaded 24 pthread workers and started with a 1 GiB Wasm
heap. The canvas filled the browser window with high pixel density enabled.

The updated player opens an idle start screen. Start game acquires an
exclusive Web Lock for that game before creating a separate runtime document.
Another tab reports that the game is already running. Stop game removes the
runtime document before releasing ownership; imported files and committed
saves remain in OPFS. Reloading the player returns to the idle screen.

The viewport is bounded to 1280×720 CSS pixels, with automatic high-DPI
multiplication disabled in the web host. Diagnostics retain the most recent
1,000 lines rather than continuously accumulating them and browser console
entries. The runtime rebuild prewarms eight workers and starts its growable
heap at 512 MiB; the existing maximum and thread stacks are unchanged.

## Verification

- 49 relevant Python/browser checks pass, including four new Chrome lifecycle
  regressions. The fixture tests idle/reloaded pages, duplicate sessions,
  viewport bounds, lock release on closing a tab, worker teardown on Stop and
  rejection of direct runtime-page launches.
- The new player shell with the previous compiled runtime reached the actual
  title screen at 1280×720. Stop removed its runtime document successfully.
- That monitored baseline peaked at 3,896 MiB of aggregate private memory
  across the test Chrome process tree. Five seconds after Stop, approximately
  1,776 MiB remained, including browser/graphics/compiler caches. Stop does not
  imply that Chrome immediately returns all reserved memory to Windows.
- The baseline used headless Chrome on the NVIDIA GPU, a 1920×1080 browser
  viewport and `--wasm-num-compilation-tasks=2`. This limits compiler bursts
  during testing and is not a setting applied to ordinary user browsers.
- Desktop and narrow-screen start layouts were visually inspected. No visible
  game window was launched during this investigation.

The full Windows/Emscripten rebuild succeeded. The new Wasm is 136,609,535
bytes. A monitored run reached the title screen and animated 3D career menu:
512 MiB heap, six running workers and two idle workers. At 200% display scaling,
the canvas backing size stayed at 1280×720. Stop removed the runtime; the
external test watchdog did not trip. Chrome peaked at 3,758 MiB of aggregate
private memory, with 1,339 MiB remaining five seconds after Stop. This longer
menu run and the shorter baseline are not comparable performance benchmarks.
Both used the test-only compiler-task limit above.

A further headless run with Chrome's default Wasm compiler settings also reached
the title and animated menu, retained the 512 MiB heap/eight-worker pool and
1280×720 backing canvas at 200% scaling, and stopped successfully. Its process
tree peaked at 3,685 MiB private memory; the last sample before browser closure,
about four seconds after Stop, was 1,357 MiB. The watchdog did not trip. This
removes the compiler-task limit from that verification, but still does not
reproduce the user's visible-browser environment or establish race stability.

These changes address observed startup risks; they are not proof that the
reported desktop freeze is fixed. Race-loading reliability,
audio, saves and full career compatibility also remain open.

## Direct-play update — 2026-10-08 10:29 CDT

The user requested a click-to-play flow like vel.gg/bo1z, without a folder picker.
The local server now provides an explicit asset manifest for the pinned game
installation. The player checks its validated OPFS cache, automatically streams
missing files through the existing importer on a worker, and only then starts
the engine. Downloads remain sequential; incomplete transfers are rejected and
can resume on another Start. Stops/session ownership retain the earlier controls.

A fresh Chrome test profile fetched all 1,393 files (2,970,739,983 bytes) in about
54 seconds over localhost. That first probe was interrupted because its test
wait condition referenced an Emscripten property this build does not expose;
this was a test instrumentation error. A corrected follow-up probe reused the
automatically populated cache and reached the title and animated menu without
any file picker. At 200% scaling, the canvas was 1280×720, heap 512 MiB and worker
pool six active/two idle. Stop succeeded and the resource watchdog did not trip;
the process tree peaked at 3,600 MiB private memory. No compiler-task limit was
applied. This remains a headless check, not proof the visible desktop freeze is
fixed or that races load reliably.

52 relevant tests pass, including new regressions for explicit asset routes and
exclusions, automatic first-visit downloads, cache use with an offline source,
and recovery after a truncated download. Game files and binaries remain outside
published source. A public direct-play URL has not been deployed.

## Keyboard entry and device hints — 2026-10-08 10:58 CDT

The user reported doubled characters while typing James. The input gate was
posting WM_CHAR alongside keydown, and TranslateMessage synthesized another
character for that keydown. Host provenance now marks keys with text already
posted, is retained for each delivered MSG buffer and is checked before text
translation. Nested reads do not lose that provenance; guest MSG bytes retain
their original layout. SDL character conversion now keeps Shift/Caps Lock.

The rebuilt browser engine was checked in its real new-alias dialog after the
career and autosave confirmation screens. Clearing the existing NAME default,
typing James, deleting the final character with Backspace and retyping s left
exactly James, including the capital J. This is a keyboard-entry check, not a
save/load round-trip. The completed test used default Chrome compiler settings,
1280×720 rendering at 200% scaling and the existing eight-worker/512 MiB startup.
Stop succeeded; the watchdog did not trip. Its peak private memory was 3,862 MiB.
An earlier probe began before memory monitoring had located Chrome; its reported
zero-byte peak is invalid and is not used as resource evidence. Later probes
refused insufficient launch headroom before creating Chrome and retained an
external runtime watchdog. Early navigation captures were not name-field tests.

Adaptive menu hints are displayed below the canvas. They distinguish keyboard,
Xbox, PlayStation, Nintendo and generic pad button labels, prefer the most
recently active device, ignore unchanged held input and fall back when a pad
disconnects. Controller users are told to use the keyboard for names. These are
browser hints; embedded game artwork has not been rewritten, and actual physical
controller gameplay is still unverified. The automated fixture covers active
keyboard/pad switching, held-input behavior and disconnects. 53 relevant checks
pass. A nested-message/text native regression was added but the standalone
native suite was not run on this Windows host; the real web application built.

## Progressive downloads (2026-10-08)

NFS opts into `[launcher] stream_assets = true`. A complete, validated imported
copy still runs from OPFS. On a new or partial installation the player downloads
and verifies the 6,029,312-byte executable, writes a 42,590-byte directory
catalogue and starts the engine without importing all 1,393 original files
(2,970,739,983 bytes). This is the startup executable size, not total network
traffic: the roughly 137 MB engine and game data accessed during boot also arrive.

The native guest worker mounts a read-only FetchFS view at `/stream`, with a
memory-backed executable copied from verified OPFS. Profiles retain their OPFS
location. Synchronous guest reads use a network proxy worker. The local server
supports sized HEAD responses and single HTTP ranges, EOF clipping, suffix reads
and 416 failures for explicit game-asset routes. Unlisted inputs remain private.
Production hosting needs equivalent range and isolation headers; GitHub source
pushes do not host original game data.

The stock Emscripten 6.0.11 reader retains fetched ranges for the life of a file.
The kit supplies a bounded bridge using that SDK's FetchFS interface: a shared
64 MiB LRU, requests capped at 1 MiB, exact response checks and failed-read errors.
This cache lasts for the running session. A streamed installation is not stamped
as fully imported; new visits still need the manifest and server. Persistent
range caching and offline streaming have not been implemented.

An empty browser profile reached the actual title using partial music and car
archive requests. OPFS held only the executable, `.stream-index` and
`.manifest.json`. The short probe used default Chrome compilation, 1280x720
rendering at 200% scaling, seven active workers, one idle worker and a 512 MiB
initial heap. Stop succeeded; its observed peak was 2,173 MiB. Longer probes
approached 4 GiB and the watchdog stopped their test-owned Chrome when its memory
or system-headroom guard tripped. Bounding asset data does not cap the whole
browser footprint. Concurrent build/decompilation processes reduced available
memory below the 2 GiB guard.

The release build with the bounded reader completed. 54 combined checks passed;
a Node test-path error was corrected and its one wrapper then passed separately,
including the three new cache-reader tests. Earlier full runs passed all 55
checks before that test-path change. These tests cover the importer/server/cache,
not complete gameplay. The attempted profile test did not reach a saved alias.
Full career, alias persistence, complete races, audio quality and physical
controller driving remain unverified on the streamed path. A lower-overhead
probe refused to launch after five minutes without its required 5.5 GiB initial
headroom. The prior visible desktop freeze is still unverified.
