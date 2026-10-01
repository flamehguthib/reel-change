# Reel Change - Development & HUD Asset Session Notes

**Date:** Thu Oct 01 2026  
**Engine:** Godot Engine 4 (GDScript, GL Compatibility)  
**File Note:** This document is listed in `.gitignore` (`SESSION_NOTES.md`) and will **NOT** be committed or pushed to any remote repository.

---

## 📋 Session Summary & Codebase Context

### 1. Game Overview
- **Title:** Reel Change
- **Genre:** 2D Cozy Fishing Survival (Filipino Coastal Community / Aplaya & Talipapa)
- **Goal:** Earn ₱2,500 over 7 days to afford a daughter's graduation gift and settle family debts.
- **Core Loop:** Boat navigation, fuel management, energy/stamina management, custom fishing tension minigame, daily Carinderia orders, market selling at Talipapa.

---

## 🌤️ Weather System Mechanics (`game_state.gd`)

| Weather Type | Icon Emoji | Bite Rate Multiplier | Market Sell Multiplier | Day Roll Probability |
| :--- | :---: | :---: | :---: | :---: |
| **Sunny** | ☀️ | 1.0x | 1.0x | 37.5% (3/8) |
| **Cloudy** | ⛅ | 1.1x | 1.1x | 25.0% (2/8) |
| **Rain** | 🌧️ | 1.25x | 1.25x | 25.0% (2/8) |
| **Storm** | 🌩️ | 1.5x | 1.5x | 12.5% (1/8) |

---

## ⛽ Gas System (Updated Oct 01 2026)

### New 3-Canister Gas Model
- **Max Gas:** `3` (displayed as `3 / 3`)
- **Starting Gas:** `3` (full tank)
- **Gas Consumption:** ONLY when traveling from Aplaya to Open Sea (via `sea_border.gd`)
- **Driving Gas Drain:** REMOVED (boat no longer consumes gas over time while sailing)
- **Return to Port:** FREE (0 gas cost)
- **Refuel Cost:** ₱45 per 1 gas canister at Talipapa or Fuel Station
- **Boat Upgrade Bonus:** +1 max gas per boat upgrade

### Gas UI Implementation
- **Location:** Top-left HUD, below Energy Panel
- **Visual:** Amber/orange bar with gold border, displayed as `3 / 3`
- **Critical State:** Text turns red when `0 / 3`

---

## 🎨 Game State HUD Asset Checklist

### 1. Vitals & Resource Bars

#### ✅ Energy Bar (Lakas) - IMPLEMENTED
- **Icon:** `energyicon.png` (48×48 px)
- **Panel:** `box.png` (NinePatchRect with wooden frame styling)
- **Bar:** Green fill (`#33D966`) with gold border, dark background
- **Label:** `"100 / 100"` overlay with text shadow
- **Critical Warning:** Text turns red when energy < 20%

#### ✅ Gas Bar (Krudo) - IMPLEMENTED
- **Icon:** ⛽ emoji (Label)
- **Panel:** `box.png` (NinePatchRect matching Energy)
- **Bar:** Amber/orange fill (`#F78C26`) with gold border
- **Label:** `"3 / 3"` overlay
- **Critical Warning:** Text turns red when gas = 0

### 2. Money & Goal Counter

#### ✅ Money Panel - IMPLEMENTED
- **Icon:** `Peso_coin.png` (64×64 px Philippine Peso coin)
- **Panel:** `Coin_panel.png` (TextureRect stretched)
- **Label:** `"₱0 / ₱2,500"` in 44pt pixel font
- **Color:** Warm gold (`#FFE64D`) when below goal, green when goal reached

### 3. Weather & Time Icons
- [x] `weather_sunny.png`
- [x] `weather_cloudy.png`
- [x] `weather_rain.png`
- [x] `weather_storm.png`
- [x] `time_morning.png`
- [x] `time_afternoon.png`
- [x] `time_night.png`

### 4. Bait & Inventory System

#### ✅ Bait Hotbar - IMPLEMENTED
- **Location:** Bottom-left corner, anchored to screen
- **Layout:** 3 horizontal slots (`130×96 px` each)
- **Slot 1 - Kawil (Basic Hook):**
  - Icon: `hook_icon.png`
  - Badge: `"[1]"` (18pt gold)
  - Count: `"∞"` (infinite uses)
- **Slot 2 - Paong Hipon (Shrimp):**
  - Icon: `shirmp.png`
  - Badge: `"[2]"`
  - Count: Dynamic stock display (26pt)
- **Slot 3 - Paong Tahong (Mussels):**
  - Icon: `mussels.png`
  - Badge: `"[3]"`
  - Count: Dynamic stock display (26pt)
- **Active Selection:** Gold border highlight (`4px` thickness)
- **Input:** Keyboard hotkeys `[1]`, `[2]`, `[3]` OR click/tap on slots

---

## 🖼️ HUD Layout Overview

```
┌─────────────────────────────────────────────┐
│ TOP LEFT:                                   │
│ ┌─────────────────────────────────────────┐ │
│ │ 🪙 MONEY PANEL                          │ │
│ │    ₱0 / ₱2,500                          │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ ⚡ ENERGY PANEL                          │ │
│ │    [======== 100 / 100 ========]        │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ ⛽ GAS PANEL                             │ │
│ │    [========   3 / 3   ========]        │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ TOP RIGHT:                                  │
│ ┌──────────────────┐                        │
│ │ ☀️ TIME CYCLE     │                        │
│ └──────────────────┘                        │
│                                             │
│ BOTTOM LEFT:                                │
│ ┌────────────┬────────────┬────────────┐   │
│ │ [1] 🪝     │ [2] 🦐     │ [3] 🦪     │   │
│ │      ∞     │      x0    │      x0    │   │
│ └────────────┴────────────┴────────────┘   │
└─────────────────────────────────────────────┘
```

---

## ⚙️ Technical Implementation Guidelines (Godot 4)

### 1. TextureProgressBar Setup
- **Node:** `ProgressBar` with `StyleBoxFlat` for background and fill
- **Fill Mode:** `Left to Right` (Godot automatically crops fill based on `value` vs `max_value`)

### 2. Dynamic Color Tinting in GDScript (`script/hud.gd`)
```gdscript
if energy_label != null:
    energy_label.text = "%d / %d" % [GameState.current_energy, GameState.max_energy]
    if GameState.current_energy < 20:
        energy_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
    else:
        energy_label.add_theme_color_override("font_color", Color.WHITE)
```

### 3. NinePatchRect for Panel Frames
- **Texture:** `box.png` with 12px margins on all sides
- **Allows:** Scalable wooden panel frames that maintain corner integrity

### 4. Pixel Font
- **Font:** `fishing_game_assets/ari-w9500-condensed-bold.ttf`
- **Used for:** All HUD labels, counts, and badges

---

## 🐛 Bugs Fixed (Oct 01 2026)

1. **Gas Initialization Bug:**
   - **Issue:** `current_gas` was hardcoded to `13` in `_ready()` instead of `max_gas`
   - **Fix:** Changed to `current_gas = max_gas` in `game_state.gd`

2. **Gas Drain While Driving:**
   - **Issue:** Boat consumed gas over time while sailing in Open Sea
   - **Fix:** Removed time-based gas drain from `boat.gd`; gas now ONLY consumed when crossing sea border to Open Sea

3. **Reset Game Gas Value:**
   - **Issue:** `reset_game()` set `max_gas = 25` and `current_gas = 13`
   - **Fix:** Updated to `max_gas = 3` and `current_gas = max_gas`

4. **Tow Rescue Gas Values:**
   - **Issue:** Tow rescue gave `+5` or `+3` gas (exceeding new max of 3)
   - **Fix:** Updated to give `max_gas` (full tank) for paid tow, `+1` for emergency tow

---

## 📁 Asset Files Used

### UI Icons (`assets/ui/`)
- `Peso_coin.png` - Philippine Peso coin icon
- `Coin_panel.png` - Money panel background
- `energyicon.png` - Energy/lightning icon
- `box.png` - Wooden panel frame (NinePatch)
- `hook_icon.png` - Kawil (basic hook) bait icon
- `shirmp.png` - Paong Hipon (shrimp) bait icon
- `mussels.png` - Paong Tahong (mussel) bait icon
- `timecycle.png` - Time of day sprite sheet (128×128 frames)

### Font
- `fishing_game_assets/ari-w9500-condensed-bold.ttf` - Pixel font for HUD

---

*Local File Only - Added to `.gitignore`*
