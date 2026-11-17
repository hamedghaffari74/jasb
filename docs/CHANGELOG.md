# Changelog

## 0.8.0
- New **Global Lab** opened from the blue-star button in the top command bar.
  - Build **100 cars** in a run to unlock **Ascension**.
  - Ascending resets money, factories, per-factory options, links and the run's car counter, but keeps **blue stars**, global upgrades and the ascension count.
  - The first ascension grants **50 blue stars**. Each ascension grants 50 more.
- Three permanent global upgrade tracks (levels 0-5, cost 10 / 25 / 60 / 150 / 400 stars):
  - **Sale price:** ×1, ×2, ×5, ×10, ×25, ×50 on all product sales.
  - **Speed:** ×1, ×1.25, ×1.5, ×2, ×3, ×5 on all factory cycles and line throughput.
  - **Storage:** ×1, ×1.25, ×1.5, ×2, ×3, ×4 on all input/output buffers.
- Global multipliers stack with the per-factory speed, price and space options.
- New full-screen lab UI: star balance, ascension progress/reward card with two-tap confirmation, three accent-coded upgrade cards with level pips, costs and buy buttons, and a help panel.
- The top-bar star button shows the blue-star balance and pulses when Ascension is available.
- Car production is counted from real production cycles and saved with the run.
- Save format is now **version 5** (`blue_stars`, `global_levels`, `cars_built`, `ascensions`); old v4 saves start fresh.
- `Reset progress` in Settings remains a full wipe (including stars and global upgrades); Ascension is the run-only reset.
- Android debug APK built and signature-verified (`build/android/IronChain-0.8.0-debug.apk`, arm64-v8a, target SDK 36).

## 0.7.0
- Factory buy prices ×5: Smelter $150, Mill $300, Tool Shop $500, Car Plant $1250, Appliance Plant $900.
- Option base costs ×3: Mine $60, Smelter $45, Mill $90, Tool Shop $150, Car Plant $375, Appliance Plant $270; AUTO stays 2× the base.
- Each line now carries at most **1 item/s** at base and is upgraded by the **source factory's speed option**:
  - Speed level 0 = 1.0/s, level 5 = 3.5/s (matches the Mine's production multiplier).
  - The speed button shows the live rate (`1.0/s` → `3.5/s`).
  - Stronger lines become wider (5 → 7.5 px) and shift their colour toward gold.
- Per-link pull accumulator keeps flow smooth and prevents item bursts.
- Desktop window now auto-fits the monitor's usable area: on smaller or scaled screens it shrinks instead of opening with its top above the screen. The title bar stays visible.
- Save format, recipes, buffers, market prices and other gameplay logic are unchanged.

## 0.6.0
- Full industrial UI redesign:
  - Animated night city background with skyline, lit windows, chimneys, smoke and moon glow.
  - New top command bar with chain name, gold coin + cash, and pause.
  - Wide 330x215 factory cards with unique SVG art, category accents, inner glow, shadows, PWR badge, resource icons, progress and option controls.
  - New Market card with orange glow, art, OPEN status, sellable icons and base prices.
  - Bottom economy dashboard with product icon, name, base price and current stock.
  - Glowing production lines with flow pulse, moving item dots, endpoints and arrows.
  - Hover lift/border glow, working-card pulse, progress glow, cash pop, smoke and window animation.
  - Styled settings (sliders, language selector), pause and main menu.
- Gameplay, economy, formulas, option levels, save format and market logic are unchanged.

## 0.5.0
- The three factory options now level up to 5:
  - Speed: +0.5x per level (level 5 = x3.5).
  - Price: +50 percentage points per level (level 5 = +250%).
  - Space: +2 buffer per level (level 5 = 18).
- Option costs start at 50% of the factory price and grow x1.5 per level; AUTO remains one-time.
- Option buttons show the current effect, `Lv n/5`, the next cost, and `Lv 5/5 MAX`.
- Save format stays version 4; option levels are stored as integers (old booleans load as level 1).

## 0.4.0
- Replaced the six-level building upgrade system with four one-time options, wider layout and Persian/English UI.
- Bundled Vazirmatn (SIL OFL); language switch in Settings.

## 0.3.0
- Six-level building upgrades, manual levels 1-4, automatic levels 5-6, larger buffers and faster cycles, Market price bonus.
- Superseded by 0.4.0/0.5.0.

## 0.2.0
- Sandbox redesign: no timer, contracts, quotas or stars.
- Buy factories, drag lines to market or compatible factories, cut lines, fixed prices.

## 0.1.0
- First playable chain: 8 contracts, market swings, upgrades, routing.
- Procedural SFX and music, vibration, settings, JSON save.
- Windows and Android (arm64) export presets.
