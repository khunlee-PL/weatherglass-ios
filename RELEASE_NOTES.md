# Weatherglass — release notes

Paste the "What to test" block into TestFlight (Test Information → What to Test) and, at App Store
submission, into "What's New in This Version".

## 1.0.0 (build 10) — 2026-09-28 — the App Store submission build

iPhone ONLY (`TARGETED_DEVICE_FAMILY=1`, `UIDeviceFamily=[1]`): 1.0 ships without iPad so no iPad
screenshots are needed; widen later. Content = v74 (build 9 + tour: only the current news stop
breathes). Everything else as build 9.

## 1.0.0 (build 9) — 2026-09-28

App content: lean build (English inline; `LANG_PACKS_ODR = true`) + On-Demand Resources
`lang-th` (73 KB) and `lang-fil` (12 KB). New native plugin `WeatherglassLang` (in-app, registered
by `MyViewController`); `scripts/add_odr.rb` wires the packs; `CFBundleLocalizations` = en, fil, th.

### What to test
- First launch: pick ไทย → a "Downloading ไทย…" toast, then the disclaimer and the whole UI in Thai
  (the pack comes from the App Store, ~73 KB). Force-quit and relaunch: still Thai, instantly.
- Airplane mode, then pick Filipino for the first time → "Couldn't download Filipino…" and the UI
  stays as it was. Back online, pick it again → works.
- Thai UI: station cards titled in Thai (เชียงใหม่), home pins and search results in Thai, and the
  search box accepts Thai script ("เชียง").
- App Store product page should list Languages: English, Filipino, Thai.
- National warnings: outside Thailand the button says no feed is whitelisted for that country
  (PAGASA for the Philippines is listed but fail-closed until the author flips `verified`).
- News dots breathe; the GDACS toast sits above the layer row and hides on a tap elsewhere.

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

## v78 — 105-language Claude-translated set (2026-09-28)

- The UI, first-run disclaimer, and About page are now translated into **105 languages** (106 editions incl.
  English), the Claude-translated set mirroring 1History. English is the source and inline; every other
  edition is BETA-badged until a native hand vouches.
- **Regional language picker** (copied from 1History): the first-run overlay and the language button both
  show languages grouped by region (Europe, Americas, East Asia, …, Oceania) with endonyms, a search box,
  a BETA tag, and RTL layout (dir=rtl) for Arabic, Hebrew, Persian, Urdu, Pashto, Sorani Kurdish, Uyghur.
- **Delivery.** iOS: one On-Demand Resource tag per language (105). Android: languages GROUPED into 23
  stable Play Asset Delivery packs by script/region (lang-groups.json), under Play's 50-pack cap; the
  native plugin resolves a code → its group pack and verifies each language's sha256 against
  lang-manifest.json. English stays inline in the base app.
- Roster (endonym · region · rtl) in corpus/i18n/roster.json; per-language packs in corpus/i18n/lang/.
