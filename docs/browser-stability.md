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
