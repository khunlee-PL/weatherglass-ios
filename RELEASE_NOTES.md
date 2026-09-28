# Weatherglass — release notes

Paste the "What to test" block into TestFlight (Test Information → What to Test) and, at App Store
submission, into "What's New in This Version".

## 1.0.0 (build 8) — 2026-09-28

App content: `www/index.html` build `2026-09-28-08fd6c6f` (corpus v68). New native plugin:
`@capacitor/preferences` (added to package.json; `cap sync` picks it up).

### What to test
- First launch after this update: a language picker (English / ไทย / Filipino) appears first, then the
  disclaimer in that language. The choice sticks across launches.
- Status bar: the logo, Home/Location/Search and Globe|Map/+/− now sit below the clock and battery
  icons; the bottom card clears the home indicator.
- Home pins, settings, language, OWM key and the disclaimer acceptance are now also stored natively
  (UserDefaults). Pin a home, force-quit, relaunch — it must still be there. It should also survive
  the next update.
- Globe view: an **N↑** button under − levels the globe (axis vertical) with a short animation; hidden
  on the flat map.
- Hourly tab now shows the same current-conditions line as Daily (larger type, source and time on a
  second line).

## 1.0.0 (build 7) — 2026-09-28

App content: `www/index.html` build `2026-09-28-cf81b361` (corpus v67).

### What to test
- Language: 💬 button (bottom-right, above News) → English / ไทย / Filipino. Every label, tab,
  table, chart title, toast and the About page should switch; the choice is remembered.
- Disclaimer: shown on first launch and once after every update; "I understand and accept" clears it.
  Settings → ⚠ Disclaimer re-opens it.
- Phone layout: nothing wider than the screen; the globe stays put while the card scrolls; the settings
  sheet is a single column with green iOS switches (OWM key first, then HD tiles, Fahrenheit, Stations,
  Borders, Graticule, Pressure fill, Contact us).
- Fahrenheit: every temperature (cards, tables, charts, home pins, legend) flips; the chart freezing line
  moves to 32°.
- Layout: Home / Location / Search stacked under the logo; Globe|Map, +, − top-right; News and Settings
  bottom-right above the layer row; colour legend bottom-left with ticks every 10 °C / 20 °F.
- Toasts: "fetching live grid…", "live grid unavailable", location errors appear in the middle of the
  screen and vanish on the next tap. The "Get a free OWM key" pill also hides on any tap elsewhere.
- Live fetch failures state the cause (request limit / HTTP code / bad response / no connection).
- Coordinates read LAT · LONG (· ALT when known).

### Changes since build 6
- Fixed: page could be panned wider than an iPhone Max screen (settings sheet wrapped into a second
  column; document now pinned to the viewport).
- New: language switch (EN / TH / FIL) with all UI strings in `corpus/i18n/ui.json`.
- New: disclaimer gate, keyed to the build id.
- New: Fahrenheit option; Contact us line; Disclaimer button.
- Changed: settings order and iOS-style switches; button clusters re-arranged; legend moved and
  re-ticked; toasts centred and tap-to-dismiss; fetch-failure reasons; LAT/LONG/ALT coordinates;
  logo +20 %.
- CI: `submit_to_testflight: false` — Codemagic uploads only; internal group *Friends* receives the
  build automatically, the external group *Family* needs the build added in App Store Connect.

## 1.0.0 (build 6) — 2026-09-27
- New "weather in a glass" app icon (storm-glass vial with sun and cloud).

## 1.0.0 (build 5) — 2026-09-27
- First build to reach App Store Connect (manual signing: `weatherglass_appstore` + `kaleido-1`).
