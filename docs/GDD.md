# Iron Chain: Factory Sandbox (Game Design Document)

**Engine:** Godot 4.7.2, GDScript only · **Targets:** Windows + Android (portrait, 720x1280 design size) · **Players:** single, 100% offline · **Languages:** فارسی / English · **Version:** 0.8.0

## Pitch
Build a steel factory chain by hand. The mine makes ore; sell it, buy the next factory, then drag lines to move goods from one building to another. Each line starts at 1 item/s and speeds up with the source factory's speed option. Each factory has four options: speed ×1.5, price +50%, space +2 and AUTO. The first three can be leveled up to **5**; AUTO is a one-time switch to automatic production. Build 100 cars to unlock the **Global Lab**, then ascend for permanent blue-star upgrades.

## Core loop
1. Factories start **manual**: tap a factory's main area to run one production cycle.
2. Drag from a factory to the **Market** to sell its product, or to a **compatible factory** to use it as input.
3. A line appears and goods travel along it as moving dots. Tap a line to cut it.
4. Tap a locked factory to buy it with cash.
5. Spend money on the factory's options. `×1.5`, `+50%` and `+2` have levels 0-5; `AUTO` is one-time.
6. Every product can be sold; higher-tier products are worth more.
7. At **100 cars built**, open the blue-star **Global Lab** and ascend: the run resets, but you keep blue stars and permanent global upgrades.

## Start and progression
- **Owned at start:** Mine, Market. Cash: $0.
- **Buy with cash:** Smelter $150, Mill $300, Tool Shop $500, Car Plant $1250, Appliance Plant $900.
- Buying a factory does **not** connect it; the player drags the next line manually.
- Every bought factory starts manual with all three numeric options at level 0.

## Buildings and recipes
| Building | Input | Output | Base cycle | Buy |
|---|---|---|---|---|
| Mine | - | Ore | 1.0 s | owned |
| Smelter | 2 ore | 1 iron | 1.5 s | $150 |
| Mill | 1 iron | 1 steel sheet | 1.0 s | $300 |
| Tool Shop | 1 steel | 1 tool | 1.0 s | $500 |
| Car Plant | 4 steel | 1 car | 4.0 s | $1250 |
| Appliance Plant | 2 steel | 1 appliance | 2.0 s | $900 |
| Market | any sellable product | cash | on arrival | owned |

Base input/output buffers are 8. The **space** option adds capacity per level.

## The four factory options
Every production factory has four option buttons. The three numeric options go from **level 0 to level 5**; AUTO is a one-time purchase. The Market has no options because speed, space and AUTO do not apply to a shop.

| Option | Effect per level | Level 5 total |
|---|---|---|
| `×1.5` | Speed multiplier increases by +0.5 per level | production ×3.5; line rate 3.5/s before global upgrades |
| `+50%` | Sale price increases by +50 percentage points per level | +250% (×3.5; stacks with the global sale multiplier) |
| `+2` | Both buffers increase by +2 per level | buffers 18 before the global capacity multiplier |
| `AUTO` | one-time: production runs without taps | automatic |

### Cost of leveling
The first point of each numeric option costs **30% of the factory buy price**; every next level costs ×1.5 more. AUTO costs **2× the base option cost** (60% of the factory buy price).

| Factory | First point | Level costs (1→5) | AUTO |
|---|---|---|---|
| Mine | $60 | $60, $90, $135, $203, $304 | $120 |
| Smelter | $45 | $45, $68, $101, $152, $228 | $90 |
| Mill | $90 | $90, $135, $203, $304, $456 | $180 |
| Tool Shop | $150 | $150, $225, $338, $506, $759 | $300 |
| Car Plant | $375 | $375, $563, $844, $1266, $1898 | $750 |
| Appliance Plant | $270 | $270, $405, $608, $911, $1367 | $540 |

- The three numeric buttons show the current effect and `Lv n/5` with the cost of the next level; when maxed they show `Lv 5/5 MAX`.
- `AUTO` is the full-width row **below** the three buttons.
- Bought levels turn the button green and cannot be skipped; the effect stacks with every level.
- The price option affects the sale value of **that factory's output** only.
- There is **no factory level system**; only these three option tracks have levels.

## Product prices (Market)
| Product | Base price |
|---|---|
| Ore | $3 |
| Iron | $7 |
| Steel | $15 |
| Tools | $35 |
| Cars | $160 |
| Appliances | $70 |

Prices are fixed base prices; the source factory's price levels and the Global Lab's sale multiplier adjust the actual revenue. Selling happens automatically when an item reaches the Market.

## Links (the main interaction)
- Press and drag from a factory to a target, then release.
- **Factory to Market:** sells the product.
- **Factory to factory:** allowed only if that factory's input matches the product (ore to Smelter, iron to Mill, steel to Tool Shop / Car Plant / Appliance Plant). Otherwise the line is not created.
- A factory can have multiple outgoing lines; output is shared round-robin between targets that can accept it.
- A factory or the Market can receive multiple incoming lines.
- Lines are routed in side lanes so they do not run through other building cards. The final path is drawn under the cards.
- **Line throughput:** each line moves at most `(1.0 + 0.5 × source speed level) × global speed multiplier` items per second. With no global upgrades, base is **1 item/s** and speed level 5 is **3.5 items/s**.
- Throughput is upgraded by the **source factory's speed option** (the same option that shortens its cycle); its button shows the current rate. The Global Lab's speed multiplier raises it for every line as well.
- As the rate rises, the line becomes wider (5 → 7.5 px) and its colour shifts progressively toward gold.
- Because the Mine's speed multiplier matches its line rate, one line can always keep up with a fully upgraded Mine; additional outgoing lines share the same output.
- Tap a line to cut it.
- Two identical links are rejected. A building cannot connect to itself. The Market cannot be a source.

## Global Lab & Ascension (0.8.0)
- **Unlock:** build **100 cars** in the current run. The blue-star button in the top command bar is always available; the Ascension button inside the lab unlocks at 100 cars.
- **Blue stars:** premium currency, separate from cash. Each ascension awards **50** stars.
- **Ascension (prestige):** resets money, unlocked factories, per-factory option levels, links and the current-run car counter. **Blue stars, global upgrade levels and the ascension count are kept.** The button asks for a second tap to confirm.
- **Tracks:** each has levels 0–5; the cost to buy the next level is the same for all tracks: **10, 25, 60, 150, 400 stars**.
  | Track | Effect | Multipliers (Lv 0 → 5) |
  |---|---|---|
  | Sale price | all product sale values | ×1, ×2, ×5, ×10, ×25, ×50 |
  | Speed | all factory cycles and line throughput | ×1, ×1.25, ×1.5, ×2, ×3, ×5 |
  | Storage | all input/output buffers | ×1, ×1.25, ×1.5, ×2, ×3, ×4 |
- Global multipliers stack with per-factory options:
  - Sale = base price × global sale multiplier × `(1 + 0.5 × price level)`.
  - Cycle = base cycle ÷ `((1 + 0.5 × speed level) × global speed multiplier)`.
  - Buffer = `ceil((8 + 2 × space level) × global capacity multiplier)`.
- The lab screen has a blue-star balance and ascension count, a gold Ascension card with car progress/reward and locked/ready state, three accent-coded upgrade cards (name, description, current/next multiplier, five level pips, cost and buy button), and a help panel.
- Buying an upgrade applies immediately to the current run and to every later run.
- The car counter counts **produced cars** (not sales) and is saved with the run.

## Layout
- Two columns of wide cards (330x215 design pixels): production on the left, Market and final factories on the right.
- More spacing between rows and a larger desktop test window (540x960) so the option buttons, level text and artwork are comfortable.
- The Market sits opposite the Mine, so the first drag is a short horizontal line.

## Visual design
- **Background:** procedural night-time industrial city with layered skyline, factory windows, chimneys, animated smoke and a warm moon glow.
- **Top command bar:** chain name, Persian/English subtitle, gold coin + CASH balance, a blue-star balance button that opens the Global Lab, and a dedicated pause button.
- **Factory cards:** 330x215, category accent (mine orange, processing orange, steel mill steel-blue, production cyan), custom art, soft inner light, shadow, PWR badge, resource icons for input/output, progress bar and the option controls.
- **Global Lab:** full-screen deep-blue panel with a starfield glow, blue-star balance and ascension count, a gold Ascension card with a car progress bar, three accent-coded upgrade cards (gold sale price, cyan speed, green storage) with five level pips and buy buttons, and a help panel. The top-bar star button glows when ascension is available.
- **Art:** one unique SVG illustration per building in `assets/sprites/factories/` and one icon per resource in `assets/sprites/resources/`; transparent, drawn with gradients and industrial detail.
- **Market:** warm orange glowing frame, its own art, OPEN status, six sellable product icons with base prices and a drop hint.
- **Economy dashboard:** panel at the bottom with a chip per product (icon, name, base price, current stock), plus control hints.
- **Lines:** product-coloured glow, animated flow pulse, moving item dots, endpoint markers and arrows; routed in lanes behind the cards. Base 1 item/s, upgraded by the source speed option and the Global Lab speed multiplier; colour moves toward gold and the line widens as the rate grows.
- **Motion:** card hover lift + border glow, working-card pulse, progress glow, cash pop, button feedback, background smoke and window flicker.
- All displayed numbers are read from the real station buffers, links and Economy data; UI-only additions (PWR badge) never change gameplay.
- PWR is a visual summary of the three option levels + AUTO, not a separate gameplay level.

## Languages
- **Persian (default) and English.** Switch language in Settings → زبان / Language.
- Bundled Vazirmatn font (SIL OFL) supports Persian shaping; the license is in `assets/fonts/OFL.txt`.
- Persian labels use RTL text direction; numbers/currency use LTR where needed.
- The choice is saved (`settings.language`) and the current scene reloads in the new language.

## Controls
| Intent | Touch / Mouse | Keyboard |
|---|---|---|
| Produce one cycle | Tap the factory's main area | Click |
| Level an option | Tap ×1.5 / +50% / +2 | Click |
| Buy AUTO | Tap the AUTO row | Click |
| Connect buildings | Drag factory to target | Mouse drag |
| Buy a locked factory | Tap it | Click it |
| Cut a line | Tap the line | Click the line |
| Pause | Top-right II / Android Back | Esc or P |
| Restart from save | Pause menu | R |
| Open the Global Lab | Tap the blue-star button in the top bar | Click |
| Ascend or buy a global upgrade | Tap the lab buttons | Click |
| Close the lab | X / Android Back | Esc |

## Rules
- No countdown, no quota, no contract. The game is an endless sandbox with an optional ascension loop.
- Money is earned only by selling goods at the Market; an ascension resets cash and run progress.
- Blue stars are earned by ascending and are never spent on normal cash purchases.
- Save file: `user://save.json`, format version 5: money, unlocked ids, per-option levels, links, settings (including language), blue stars, global levels, current-run cars built and ascension count.
- The Market and the Mine are always unlocked.
- Fully offline; no ads, IAP, accounts, leaderboards or UGC.

## Out of scope
Timers, contracts, quotas, market price swings, factory level upgrades, offline earnings, cloud save, leaderboards, accounts, ads, IAP, UGC, third-party plugins, tutorial video, controller support, tablet-specific layouts.

## Art / audio
Factory and resource art are custom SVGs in `assets/sprites/`; cards use `StyleBoxFlat` shadows, inner light and vector art, and the background is drawn procedurally. `UiKit` builds all control styles in code (no theme file). Vazirmatn is the UI/rendered font. SFX and music are generated procedurally in `autoload/audio_manager.gd`; audio buses are created in code.

## Performance rules
No per-item nodes in the simulation: buffers are integer counters, items in transit are floats on a link, and decorations are simple drawn dots. `CPUParticles2D` is pooled (max 8 bursts x 12 particles). No custom shaders. Target 60 FPS on a mid-range Android phone.

## Milestones
- M0: design, tree, project.godot. **Done**
- M1: first playable chain. **Done**
- M2: menus, HUD, pause, save/load, settings. **Done**
- M3: content, feel, procedural SFX/music. **Done**
- M4: export presets, icon, versioning, release checklist. **Done for Windows and an Android debug APK. Release signing still needs your own release keystore.**
- 0.2.0: sandbox redesign. **Done**
- 0.3.0: six-level building upgrades. Replaced.
- 0.4.0: four factory options, wider layout, bilingual UI. **Done**
- 0.5.0: first three options level up to 5; level effects and escalating costs. **Done**
- 0.6.0: full industrial UI redesign (background, cards/art, lines, market, dashboard, animations). **Done**
- 0.7.0: factory buy prices ×5, option costs ×3, line throughput limited to 1 item/s and upgraded by the source speed option with gold-shifting colours. **Done**
- 0.8.0: blue-star Global Lab, 100-car ascension, permanent sale/speed/storage upgrades, top-bar star balance. **Done**

## Implementation notes
- `resources/theme/main_theme.tres` sets Vazirmatn as the default theme font; the font is `assets/fonts/Vazirmatn.ttf` (OFL).
- Save data: `user://save.json`, format version 5 (option levels stored as ints; old boolean values load as level 1; old v4 saves are reset).
- Windows release build: `build/windows/IronChain.exe`.
- Android debug build: `build/android/IronChain-0.8.0-debug.apk` (arm64-v8a, package `com.jasb.ironchain`, target SDK 36, min SDK 24), signed with the local debug keystore.
- Android toolchain is local: JDK 17 in `D:\ghaffari\Android\jdk17`, SDK in `D:\ghaffari\Android\Sdk` (build-tools 36.0.0, platform android-36, platform-tools 37.0.1), debug keystore in `D:\ghaffari\Android\keystore\debug.keystore`.
- Android export preset is ready in `export_presets.cfg`; the package name `com.jasb.ironchain` is a placeholder and must be changed before publishing. Release builds must be signed with your own release keystore.
- Links are routed with orthogonal side lanes chosen to avoid building cards; the lane rotates per link so parallel lines stay visible.
- `Link.throughput()` returns `(1.0 + 0.5 × from.speed_level) × SaveManager.global_speed()` and is enforced by a per-link pull accumulator; `Link._refresh_strength()` updates width and the product-to-gold colour blend.
- `scripts/game/boot.gd` fits the desktop window to the monitor's usable area at startup (preserving 9:16) so the title bar cannot open above the screen; Android is untouched.
- `scripts/ui/industrial_background.gd` draws the animated city; `scripts/common/art.gd` maps SVG art; `Hud` draws the command bar, star button and economy dashboard.
- Global meta data and purchase rules live in `scripts/economy/global_upgrades.gd` and `autoload/save_manager.gd`; the page is `scripts/ui/global_lab.gd` with `LevelPips` and `LabBackdrop` helpers.
- Version: 0.8.0 (`project.godot`, menu footer, CHANGELOG).

## Screenshots (0.8.0)
- `docs/screenshots/menu.png`
- `docs/screenshots/settings.png`
- `docs/screenshots/start.png`
- `docs/screenshots/progress.png`
- `docs/screenshots/pause.png`
- `docs/screenshots/global_locked.png`
- `docs/screenshots/global_lab.png`
- `docs/screenshots/prestige.png`
