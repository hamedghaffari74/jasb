# Release checklist (Iron Chain)

## Before building
- [ ] Bump `config/version` in project.godot and `version/name` + `version/code` (+1) in the Android preset
- [ ] Update docs/CHANGELOG.md
- [ ] Output panel clean on F5 (no errors/warnings), all scenes run with F6
- [ ] Reset progress in Settings, start a fresh sandbox
- [ ] Confirm the night city background, full-width top command bar and staggered card layout render on Windows and Android
- [ ] Confirm the top command bar is flush to the top edge and the bottom economy dashboard is gone
- [ ] Confirm the desktop game window fits the monitor with a visible title bar (test 1080p and a 768p/scaled display)
- [ ] Confirm every factory has its own art and that locked cards are visually dimmed
- [ ] Confirm Persian is the default language; switch to English and back from Settings
- [ ] Confirm Persian text is shaped correctly and the Vazirmatn font renders every label
- [ ] Confirm the new slider fills, language selector, pause panel and menu panel look correct
- [ ] Confirm card hover glow, working pulse, cash pop, line flow and background smoke animate
- [ ] Confirm the market card prices and each factory card's input/output counts are correct
- [ ] Confirm locked prices are $150 / $300 / $500 / $1250 / $900 on the cards
- [ ] Confirm option base costs are $60 / $45 / $90 / $150 / $375 / $270 and AUTO is 2× the base
- [ ] Confirm a new Mine -> Market line moves exactly 1 item/s (with no global speed)
- [ ] Upgrade the source speed to 5 and confirm the line reaches 3.5 items/s (with no global speed)
- [ ] Confirm the speed button reads 1.0/s → 3.5/s and the line gets wider + more gold
- [ ] Confirm multiple outgoing lines each respect their own base rate/time
- [ ] Open the blue-star lab from the top bar; confirm the balance, ascension progress and three upgrade cards render
- [ ] Before 100 cars: confirm Ascension is locked, the progress bar is correct and upgrade buttons are disabled at 0 stars
- [ ] Build 100 cars: confirm the star button pulses and the Ascension button unlocks
- [ ] Ascend: confirm money/factories/options/links reset, the car counter is 0, +50 stars are granted and the ascension count increases
- [ ] Confirm blue stars, global levels and ascensions survive Ascension and reload
- [ ] Buy sale/speed/storage levels; confirm the multipliers apply to sale prices, cycles/line rates and buffer caps
- [ ] Confirm global multipliers stack with per-factory speed/price/space levels
- [ ] Confirm Settings "Reset progress" is a full wipe (including stars and global upgrades)
- [ ] Confirm the lab fits in Persian and English, with all text on screen
- [ ] Tap the Mine's main area: one production cycle per tap
- [ ] Level each of ×1.5, +50% and +2 from 0 to 5; confirm level text, costs, green state and MAX
- [ ] Confirm speed level 5 = production ×3.5 and line rate 3.5/s, price level 5 = +250%, space level 5 = 18
- [ ] Confirm AUTO is one-time and keeps production running without taps
- [ ] Confirm the price levels affect only that factory's product revenue
- [ ] Buy the Smelter, connect Mine -> Smelter, level its options, connect to Market/Mill
- [ ] Cut a line and reconnect it; try an incompatible drop (ore onto the Mill)
- [ ] Close and relaunch: money, buildings, option levels, links, language, stars, global levels and car progress are restored
- [ ] Old v4 save starts a fresh v5 run
- [ ] Test Esc / P pause, R restart, Android Back at menu, board, pause, settings
- [ ] Alt-tab / app switch auto-pauses the board

## Performance (mid-range Android)
- [ ] Deploy to a real phone (Remote Debug), open Debugger > Monitors
- [ ] FPS holds 60 with every option maxed and many links active
- [ ] No spikes when several links sell at the same time
- [ ] Phone stays cool after 10 minutes

## Android
- [ ] Debug build installs and runs (`adb install -r build/android/IronChain-0.8.1-debug.apk`)
- [ ] Portrait only, no rotation
- [ ] Tall (20:9) and short (16:9) screens both show all cards and option levels
- [ ] Release build signed with your own keystore (never commit it)
- [ ] Change `package/unique_name` from the placeholder before publishing

## Windows
- [ ] build/windows/IronChain.exe starts without the editor
- [ ] Window is portrait-sized and resizable without UI breaking

## Final
- [ ] Tag the commit `v0.8.1`
- [ ] Archive the keystore and passwords somewhere safe
