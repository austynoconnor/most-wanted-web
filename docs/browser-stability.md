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

## Save persistence and delivery (2026-10-11)

The streamed build created the alias James, displayed Save complete and wrote
a 63,596-byte profile file. A separate launch with the same isolated test profile
displayed Load complete. These checks establish a saved-alias round trip; they
do not establish completion of a career race. Both used headless Chrome with
two Wasm compiler tasks and display scale 1, rather than a default visible browser.
The save run stopped cleanly at a 4,020 MiB peak. The subsequent load run reached
4,172 MiB and its external watchdog closed the test browser.

Controller help now derives actions from NFS's configured native bindings:
the top face button confirms menus, Start/Menu/Options backs out or pauses,
the right trigger accelerates, the left trigger brakes and the left stick steers.
Keyboard help includes Enter, Esc, arrows and Space. This corrects the old
generic bottom-button confirmation hint. Physical controller driving is pending.

The launcher generates gzip sidecars for its compiled engine and companion
startup data, and serves them when accepted with the original MIME type and
Vary: Accept-Encoding. Original game files retain uncompressed byte ranges.
The current 136,622,245-byte Wasm transfers as 15,321,738 bytes; the
8,535,904-byte data package transfers as 461,803 bytes. Browser streaming
instantiation and byte-for-byte decompressed integrity were checked. This
reduces network transfer, not the compiled engine's memory requirements.

Truncated or malformed import journals now recover by revalidating inputs.
Valid journal entries remain reusable; the separate profile directory survives.
Node and real browser OPFS tests exercise recovery and saved-file preservation.
The relevant Python/browser suite passes 58 checks; the direct Node importer
and FetchFS suites pass ten tests. No native implementation changed in this pass.

Release remains blocked on reliable career/race completion, sustained memory
use in a default visible browser, audio verification, physical controller driving
and production hosting validation. In particular, the earlier PC freeze has
not been proven fixed. Do not describe the current build as release ready.
The next guarded career probe refused to launch after five minutes without
5.5 GiB of available system memory. At the end of that preflight, only 4.05 GiB
was available. It created no game browser; unrelated applications were left running.

## Requested low-headroom attempt (2026-10-12)

At the user's request, a test bypassed the 5.5 GiB initial launch requirement
while retaining runtime resource monitoring. Available memory at launch was
only 0.98 GiB. The game reached the title with its 512 MiB Wasm heap, but system
headroom fell to 0.64 GiB and the test was manually stopped. The monitor had
incorrectly exited when its first low-memory sample preceded Chrome startup;
its zero-byte private-memory peak is invalid and provides no stability evidence.

The local diagnostic probes were corrected to continue waiting for the owned
Chrome process, normalize profile-path separators and keep monitoring after a
trip to catch late-starting child processes. A second attempt without the launch
precheck was automatically stopped during loading: eight owned Chrome processes,
261 MiB aggregate private memory, 1.45 GiB system memory available. These figures
describe early startup only. No other applications were closed. Full career and
race validation remain pending; neither attempt establishes desktop stability.

## Post-restart career driving (2026-10-12)

The saved James alias loaded again and Resume Career streamed the opening
intro and race. Keyboard acceleration reached 78 mph; steering, reverse,
pause and resume responded. No race-result screen was reached during this
probe, so it does not establish race completion or later career progression.

The complete rebuilt engine includes WebGPU fitted-depth handle ownership
and retirement on guest-resource replacement/drop or drawable rescale.
Before scheduling texture destruction through queue completion, the renderer
submits an outstanding encoder using that texture. Loading text also avoids
comparing decoded startup bytes to gzip Content-Length. The normal Windows
build wrapper uses a separate SDK configuration with canonical paths, avoiding
compiler cache resets caused by long versus 8.3 path aliases. The build passed
with four jobs and its build resource guard did not trip. All 58 relevant
Python/browser checks pass.

An instrumented headless Chrome run lasted 486.5 seconds, with display scale 1
and two Wasm compiler tasks. Its peak aggregate private memory was 4.24 GiB;
the NVIDIA Blackwell GPU process peaked at 2.46 GiB, and minimum available
system memory was 2.61 GiB. The Wasm heap grew from 512 to 608 MiB. It stopped
cleanly without tripping the diagnostic guard (6 GiB owned-browser private,
2.5 GiB minimum available system memory). An earlier 4.5 GiB guard had stopped
track loading with roughly 3.69 GiB still available. The revised private cap
allowed further diagnosis while retaining the system-headroom guard.

JavaScript GPU counters show repeated texture allocation/retirement, with
varying live estimates rather than proof of monotonic growth. These counters
are estimates and do not include driver allocations. The different runs are
not a controlled before/after memory comparison. The earlier desktop freeze
and full-game release gates remain unresolved. Test profiles and diagnostic
logs stay private under ignored build directories.

## Additional modes, audio signal and asset audit (2026-10-12)

A subsequent launch without GPU counters or D3D9 statistics opened custom
Drag mode, selected Bayshore & Boardwalk with a stock Lexus IS 300, loaded
the race and reached standings. The first attempt reported Blown Engine
because the test held throttle without timely gear changes. Restarting
returned to the countdown, and Shift advanced the car through fifth gear.
This confirms race termination, restart and manual shifting; no winning or
valid timed finish was established. Another resource-guard stop interrupted
the follow-up run. Peak owned private memory was 3.85 GiB; available system
memory dropped to 2.10 GiB. This still prevents a desktop-stability claim.

In a separate menu measurement, SDL's browser AudioContext was running at
48 kHz. All 819 observed output blocks contained nonzero game PCM, with
peak amplitude 0.1858 and RMS 0.0447 across 3,354,624 channel samples.
The measurement wrapped the existing audio callback and sampled its output,
without recording other applications. Nonzero output establishes that audio
reaches Web Audio, not its subjective quality or later-game consistency.

The local hosted-asset audit passed all 1,393 manifest files: sized HEAD
responses and first/middle/last byte ranges matched the original files.
Requested ranges remained uncompressed even with Accept-Encoding: gzip,
and Content-Range matched each request. It sampled 124,568 bytes in 13.42
seconds. This verifies delivery availability for the manifest, not every
asset's original-game semantics or a production host.

## Explicit WebGPU storage retirement (2026-10-12)

Ordinary owned texture destruction now waits until all open generic command
encoders have been submitted, then calls WebGPU texture destruction after
queue completion. Uniquely owned compositor uploads whose command completion
has already been observed use a completed-texture path. Both paths release
views and texture handles; imported external textures retain their original
renderer ownership. This addresses repeated presenter composites and UI uploads
whose storage previously depended on JavaScript handle garbage collection.
Other backends retain their existing destruction behavior.

The complete Windows Wasm build passed. An isolated instrumented headless
NVIDIA run lasted 840 seconds without a diagnostic guard trip, loaded James,
opened/closed host settings three times, streamed career loading, and drove,
steered and paused/resumed the opening race. Peak owned-browser private memory
was 2.30 GiB and peak GPU-process private memory was 0.52 GiB; minimum available
system memory was 2.95 GiB. Menu GPU-process private memory was about 0.34 GiB.
The Wasm heap grew from 512 to 704 MiB. Captured GPU validation errors were empty.
The run used display scale 1 and two Wasm compiler tasks, with GPU counters and
D3D9 statistics enabled. These are measured limits, not default-browser proof.

The earlier 486.5-second probe peaked at 4.24 GiB owned private and 2.46 GiB GPU
private. The new probe shows substantially lower observed memory, but its scene
sequence and duration differ, so this is not a controlled percentage reduction.
No valid race finish was reached. The earlier PC freeze, normal visible-browser
launch and later career progression still need verification.

## Visible Chrome with normal Wasm compilation (2026-10-12)

An owned visible Chrome window, without the compiler-task override, ran for
414.9 seconds and loaded the saved James alias, career intro and opening race.
Acceleration, braking, steering and pause/resume responded. Peak owned private
memory was 2.25 GiB, GPU-process private 0.57 GiB, and minimum available system
memory 4.12 GiB. Wasm reached 608 MiB. No captured GPU validation errors or
resource-guard trip occurred; the test stopped cleanly. This run used display
scale 1 and diagnostic GPU counters/D3D9 statistics. It establishes a successful
visible launch and brief career play on this machine, not sustained play in
all browsers or a valid race finish. The earlier desktop freeze has not recurred
in this probe, but longer ordinary-browser play remains necessary.

The browser's game-specific hints now include the verified manual shift-up
binding: Shift on keyboard and the mapped R1/RB/R shoulder on PlayStation,
Xbox and Nintendo controllers. Generic pads use shoulder-position names.
Physical controller driving remains unverified.

## Ordinary visible run and remaining HUD checks (2026-10-12)

A subsequent visible Chrome probe removed injected GPU counters, the D3D9
statistics query and the Wasm compiler-task override. The native performance
overlay remained enabled. It ran 1,050.7 seconds without a diagnostic guard trip:
2.24 GiB peak owned private memory, 0.56 GiB GPU private, and 4.40 GiB minimum
available system memory. Wasm reached 608 MiB. Custom drag menus, track loading,
restart, Ctrl gear-down and Shift gear-up responded. Both driving attempts
ended in traffic-collision Totaled standings; no valid timed finish was reached.
Some drag HUD speed/time readouts were absent and still need investigation.

During driving, the running 48 kHz AudioContext delivered 257 nonzero output
blocks out of 258, RMS 0.1306 and peak 0.3966 across 1,056,768 channel samples.
A later aggregate included pauses and standings, with 5,414 nonzero blocks
out of 11,988. These samples establish audio output, not subjective quality
or uninterrupted audio across every game state. No physical gamepad was exposed
by navigator.getGamepads during the run; controller driving remains unverified.

An isolated copy of the diagnostic profile exposed a separate issue when
widescreen hooks were disabled: the 3D menu scene disappeared. The loader's
eight-byte operand-redirect copies overlap adjacent four-byte relocated camera
slots. Reproducing those copies and existing seeds from the supported image
left horizontal scale at zero and vertical scale at a tiny nonbaseline value.
The enabled widescreen hooks rewrite those values; disabled hooks expose them.
Explicit final seeds now restore the original projection and shadow constants,
verified as float32 1.0, 0.5 and 1.1 at their existing source addresses. Regenerated
metadata and the complete Windows Wasm build passed. Showroom, car selection
and streamed drag track render with widescreen disabled. Its HUD clips near
the edges and still needs layout work; this check establishes restored 3D
rendering only. A 522.0-second probe stopped cleanly with no resource-guard
trip, 2.14 GiB peak owned private memory and 4.46 GiB minimum system headroom.
The original diagnostic profile and player saves were left unchanged.

The rebuilt normal-widescreen version also loaded the saved alias, rendered
menus and streamed drag track, and responded to acceleration and shifting.
It reached traffic-collision standings, not a valid timed finish. Its
390.6-second resource sample peaked at 2.31 GiB owned private memory with
4.19 GiB minimum system headroom and no guard trip. The native performance
overlay remained enabled; no GPU-error instrumentation was injected.
Read-only guest inspection confirmed the normal HUD scale (0.00234375),
center (426.66666) and an updating timer string (32.06) in an active text
object, despite its missing on-screen readout. This does not yet distinguish
layout, visibility and rendering failures. A subsequent temporary layout
diagnostic used stale objects after restart; its visual result was discarded,
touched values were restored and the isolated browser was closed.

Regeneration preserves timestamps of byte-identical translated files before
atomic publication, with regressions for changed content and failed generation.
The Windows wrapper defaults to one Binaryen optimizer worker, respecting
explicit overrides. The camera metadata rebuild required five incremental
build tasks instead of recompiling unchanged shards. The full guarded build
passed with 5.00 GiB peak owned private memory and 1.89 GiB minimum available
system memory; this includes translation, not only optimization. All 60
relevant build-driver, game configuration and browser/launcher checks passed.

## Merged kit, first visible Chrome pass (2026-10-12 15:27 CDT, Claude Opus 5.5)

- Kit pinned at recomp-kit browser-release 1373796 (giggity-d3d8 fixes merged).
- Crash fixed: static D3D9 vertex/index buffers no longer keep a guest-heap
  copy after unlock; keeping one for every buffer exhausted the guest heap
  during race load.
- Works in visible Chrome (WebGPU): menus, Quick Race circuit and speedtrap,
  arrows and WASD, HUD (speed, gear, position, lap), AudioWorklet audio with
  0 underruns. Game fps 70-78 in menus, 46-66 in races (14-21 ms frames).
  Chrome peak private memory about 2 GB.
- Open: a simulated Gamepad API controller reaches the virtual pad
  (`RECOMP_CONTROLS_TRACE=1` shows the buttons) but the mapped binding's
  synthesized key presses do not move NFS menus; a controller present from
  boot once held a "Load complete" dialog at about 1 fps. Untested with a
  real pad. Drag-race readouts and a bright bloom flash on the intro camera
  are unverified.
- After every web build, restart the 8094 server: the build rewrites
  `build/web-site/games.json` without the streamed-asset base.
