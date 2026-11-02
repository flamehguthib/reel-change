# Reel Change - System Architecture & Visual Component Diagram

**Generated:** Thu Oct 01 2026  
**Engine:** Godot Engine 4 (GDScript, GL Compatibility)

---

## 🏗️ High-Level Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           REEL CHANGE                                    │
│                    2D Cozy Fishing Survival Game                         │
└─────────────────────────────────────────────────────────────────────────┘

ARCHITECTURE PATTERN: Data-Driven State Management
├── Single Source of Truth: GameState (Autoload)
├── Decoupled Systems via Global Singletons
└── Pull/Poll Model for UI Updates
```

---

## 🎯 Core Systems Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                         AUTOLAOAD LAYER                               │
│                      (Global Singletons)                              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │
│  │   GameState     │  │  SoundManager    │  │ TransitionLayer  │   │
│  │   (State)       │  │   (Audio)        │  │   (Scenes)       │   │
│  ├─────────────────┤  ├──────────────────┤  ├──────────────────┤   │
│  │ • Day/Time      │  │ • SFX Dictionary │  │ • Fade Animations│   │
│  │ • Money/Economy │  │ • Music Control  │  │ • Scene Switching│   │
│  │ • Energy/Gas    │  │ • Preloaded Audio│  │                  │   │
│  │ • Fish Inventory│  │                  │  │                  │   │
│  │ • Weather       │  │                  │  │                  │   │
│  │ • Contracts     │  │                  │  │                  │   │
│  │ • Bait/Upgrades │  │                  │  │                  │   │
│  └─────────────────┘  └──────────────────┘  └──────────────────┘   │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Read/Write
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         GAMEPLAY LAYER                                │
│                      (Scene Instances)                                │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────────┐          ┌──────────────────────┐         │
│  │   MAIN SCENE         │          │    OPEN SEA          │         │
│  │   (Town/Aplaya)      │          │    (Fishing Zone)    │         │
│  ├──────────────────────┤          ├──────────────────────┤         │
│  │ • SleepZone          │          │ • Boat               │         │
│  │ • Talipapa Shop      │◄────────►│ • Fisherman          │         │
│  │ • Fuel Station       │  Travel  │ • Fishing Mechanic   │         │
│  │ • SeaBorder          │          │ • Fish Spawns        │         │
│  └──────────────────────┘          └──────────────────────┘         │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Update
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│                           UI LAYER                                    │
│                      (Canvas Overlay)                                 │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                         HUD                                  │    │
│  ├─────────────────────────────────────────────────────────────┤    │
│  │ • Money Panel     (Reads: current_money, money_goal)        │    │
│  │ • Energy Bar      (Reads: current_energy, max_energy)       │    │
│  │ • Gas Bar         (Reads: current_gas, max_gas)             │    │
│  │ • Bait Hotbar     (Reads: active_bait, bait_counts)         │    │
│  │ • Time Cycle      (Reads: current_time_index)               │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐   │
│  │  Talipapa Shop   │  │  Pause Menu      │  │  Victory/Defeat │   │
│  │  (Trading UI)    │  │  (Game Control)  │  │  (End Screens)  │   │
│  └──────────────────┘  └──────────────────┘  └─────────────────┘   │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Core Game Loop Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    DAILY LOOP (7 Days)                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌────────────────────────────────────────┐
        │         MORNING → AFTERNOON → NIGHT     │
        │              (Time Periods)             │
        └────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ┌─────────┐          ┌─────────┐          ┌─────────┐
   │  TOWN   │          │  SEA    │          │  SLEEP  │
   │ (Aplaya)│          │ (Fishing)│          │  (Rest) │
   └─────────┘          └─────────┘          └─────────┘
        │                     │                     │
        │                     │                     │
        ├─ Shop/Sell          ├─ Sail (Gas Cost)    ├─ Advance Day
        ├─ Refuel             ├─ Fish (Energy Cost) ├─ Restore Energy
        ├─ Buy Bait           ├─ Catch Fish         └─ Check Win/Lose
        └─ Upgrade            └─ Return (Free)              
                              │
                              │
                    ┌─────────┴─────────┐
                    │                   │
                    ▼                   ▼
              ┌──────────┐        ┌──────────┐
              │  SUCCESS │        │  FAILURE │
              │ (Earn ₱) │        │ (Lose ₱) │
              └──────────┘        └──────────┘
```

---

## 🎣 Fishing System Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                    FISHING MECHANIC SYSTEM                        │
└──────────────────────────────────────────────────────────────────┘

┌─────────────────┐
│  PREPARATION    │
│  (Fisherman)    │
├─────────────────┤
│ • Select Bait   │
│ • Cast Line     │
│ • Wait for Bite │
└─────────────────┘
        │
        │ Uses: active_bait
        ▼
┌─────────────────┐
│  BITE DETECTION │
│  (fish_detect)  │
├─────────────────┤
│ • Timer Loop    │
│ • Weather Check │
│ • Bait Bonus    │
│ • Random Roll   │
└─────────────────┘
        │
        │ Triggers: Bite Event
        ▼
┌─────────────────┐
│  MINIGAME       │
│  (fish_bar)     │
├─────────────────┤
│ • Moving Target │
│ • Difficulty    │
│ • Timing Check  │
│ • Success/Fail  │
└─────────────────┘
        │
        │ Success → Add to Inventory
        ▼
┌─────────────────┐
│  REWARD         │
│  (GameState)    │
├─────────────────┤
│ • Add Fish      │
│ • Consume Bait  │
│ • Spend Energy  │
└─────────────────┘
```

---

## ⛽ Gas & Economy System

```
┌──────────────────────────────────────────────────────────────────┐
│                    RESOURCE MANAGEMENT                            │
└──────────────────────────────────────────────────────────────────┘

┌─────────────────┐
│  GAS SYSTEM     │
│  (3 Canisters)  │
├─────────────────┤
│ MAX: 3          │
│ START: 3        │
│                 │
│ CONSUMPTION:    │
│ • Travel to Sea │◄── 1 Gas per trip
│ • Return: FREE  │
│                 │
│ REFUEL:         │
│ • ₱45 per unit  │
│ • Talipapa/Fuel │
│                 │
│ UPGRADE:        │
│ • +1 Max Gas    │
└─────────────────┘

┌─────────────────┐
│  ECONOMY        │
│  (Goal: ₱2,500) │
├─────────────────┤
│ INCOME:         │
│ • Sell Fish     │
│ • Contracts     │
│                 │
│ EXPENSES:       │
│ • Gas: ₱45      │
│ • Bait: ₱30     │
│ • Rod Upgrade   │
│ • Boat Upgrade  │
│                 │
│ WEATHER BONUS:  │
│ • Rain: 1.25x   │
│ • Storm: 1.5x   │
└─────────────────┘
```

---

## 🎨 UI Component Hierarchy

```
┌──────────────────────────────────────────────────────────────────┐
│                    UI SCENE TREE                                  │
└──────────────────────────────────────────────────────────────────┘

HUD (CanvasLayer)
├── MoneyPanel (TextureRect)
│   ├── CoinIcon (TextureRect)
│   └── MoneyLabel (Label)
│
├── EnergyPanel (NinePatchRect)
│   ├── EnergyIcon (TextureRect)
│   ├── EnergyBar (ProgressBar)
│   └── EnergyLabel (Label)
│
├── GasPanel (NinePatchRect)
│   ├── GasIcon (Label)
│   ├── GasBar (ProgressBar)
│   └── GasLabel (Label)
│
├── BaitHotbar (HBoxContainer)
│   ├── SlotKawil (TextureButton)
│   │   ├── Icon (TextureRect)
│   │   ├── Badge (Label) "[1]"
│   │   ├── Count (Label) "∞"
│   │   └── Highlight (ReferenceRect)
│   ├── SlotHipon (TextureButton)
│   │   ├── Icon (TextureRect)
│   │   ├── Badge (Label) "[2]"
│   │   ├── Count (Label) "0"
│   │   └── Highlight (ReferenceRect)
│   └── SlotTahong (TextureButton)
│       ├── Icon (TextureRect)
│       ├── Badge (Label) "[3]"
│       ├── Count (Label) "0"
│       └── Highlight (ReferenceRect)
│
└── TimeVBox (VBoxContainer)
    ├── TimeCycleIcon (TextureRect)
    └── TimeCycleLabel (Label)
```

---

## 🔌 Script Dependency Graph

```
┌──────────────────────────────────────────────────────────────────┐
│                    SCRIPT RELATIONSHIPS                           │
└──────────────────────────────────────────────────────────────────┘

                    ┌─────────────────┐
                    │   game_state.gd │
                    │   (Autoload)    │
                    └─────────────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
            ▼                ▼                ▼
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │   hud.gd     │  │  boat.gd     │  │ fisherman.gd │
    │   (UI)       │  │  (Vehicle)   │  │ (Player)     │
    └──────────────┘  └──────────────┘  └──────────────┘
            │                │                │
            │                │                │
            ▼                ▼                ▼
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │ • MoneyPanel │  │ • Gas Check  │  │ • Energy Use │
    │ • EnergyBar  │  │ • Movement   │  │ • Bait Select│
    │ • GasBar     │  │ • Mount/Ride │  │ • Fish Detect│
    │ • BaitHotbar │  │ • Tow Rescue │  │ • Inventory  │
    └──────────────┘  └──────────────┘  └──────────────┘

                    ┌─────────────────┐
                    │ sound_manager.gd│
                    │   (Autoload)    │
                    └─────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  All Gameplay   │
                    │  Scripts        │
                    │  (SFX Calls)    │
                    └─────────────────┘
```

---

## 🌊 Scene Transition Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                    SCENE SWITCHING                                │
└──────────────────────────────────────────────────────────────────┘

main_scene.tscn (Town)
        │
        │ Approach SeaBorder
        │ Press [E] to Sail
        │ Check: GameState.can_travel_to_opensea()
        │ Cost: 1 Gas
        ▼
OpenSea.tscn (Fishing)
        │
        │ Approach SeaBorder
        │ Press [E] to Return
        │ Cost: FREE
        ▼
main_scene.tscn (Town)

        ┌─────────────────────┐
        │  TransitionLayer    │
        │  (Fade In/Out)      │
        │  • Animation: 0.5s  │
        │  • Screen Cover     │
        └─────────────────────┘
```

---

## 🎮 Input Action Map

```
┌──────────────────────────────────────────────────────────────────┐
│                    INPUT ACTIONS                                  │
└──────────────────────────────────────────────────────────────────┘

MOVEMENT:
├── move_up, move_down, move_left, move_right (WASD / Arrows)

INTERACTION:
├── interact (E) - Talk, Mount Boat, Open Shop
├── fish_button (Space) - Cast/Reel
├── sell (S) - Sell Fish at Talipapa
├── refuel (R) - Buy Gas at Fuel Station

SYSTEM:
├── pause (Escape) - Pause Menu
├── ui_cancel (Escape) - Close Menus

BAIT HOTKEYS:
├── Key [1] - Select Kawil (Basic Hook)
├── Key [2] - Select Hipon (Shrimp Bait)
├── Key [3] - Select Tahong (Mussel Bait)

EMERGENCY:
├── Key [T] - Tow Rescue (When Stranded at Sea)
```

---

## 📊 Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                    DATA FLOW PATTERNS                             │
└──────────────────────────────────────────────────────────────────┘

PLAYER ACTION → GameState Update → UI Refresh
     │                │                   │
     │                │                   │
     ▼                ▼                   ▼
┌─────────┐    ┌──────────┐       ┌──────────┐
│ Input   │    │ Write    │       │ Read     │
│ Event   │───►│ State    │──────►│ Display  │
│         │    │          │       │          │
└─────────┘    └──────────┘       └──────────┘

Example Flow:
1. Player presses [E] at SeaBorder
2. sea_border.gd calls GameState.travel_to_opensea()
3. GameState.current_gas -= 1
4. hud.gd reads GameState.current_gas in _process()
5. GasBar updates display: "2 / 3"
```

---

## 🔧 Key Design Patterns

### 1. Singleton Pattern (Autoloads)
- **GameState**: Single source of truth for game data
- **SoundManager**: Centralized audio control
- **TransitionLayer**: Scene transition management

### 2. Observer Pattern (Polling)
- UI components poll GameState every frame
- No event signals needed
- Simple and decoupled

### 3. State Machine
- **Fisherman**: Idle → Walking → Fishing → Casting
- **Boat**: Dismounted → Mounted → Driving

### 4. Composition over Inheritance
- Scenes composed of reusable Area2D triggers
- UI panels are modular and self-contained

---

## 📁 Project Structure

```
reel-change/
├── project.godot                  # Godot project config
├── assets/
│   ├── ui/                        # HUD icons and panels
│   ├── fish/                      # Fish sprites
│   ├── fisherman/                 # Player animations
│   ├── boat/                      # Boat sprites
│   ├── Night/                     # Night backgrounds
│   └── Afternoon/                 # Afternoon backgrounds
├── scenes/
│   ├── location/
│   │   ├── main_scene.tscn        # Town (Aplaya)
│   │   └── OpenSea.tscn           # Fishing area
│   ├── ui/
│   │   ├── hud.tscn               # Main HUD
│   │   ├── talipapa_shop.tscn     # Shop interface
│   │   ├── pause.tscn             # Pause menu
│   │   ├── victory.tscn           # Win screen
│   │   └── defeat.tscn            # Lose screen
│   └── Fisherman/
│       ├── fisherman.tscn         # Player
│       ├── boat.tscn              # Boat vehicle
│       └── fishing_mechanic.tscn  # Fishing system
├── script/
│   ├── global_script/
│   │   ├── game_state.gd          # Core state manager
│   │   ├── sound_manager.gd       # Audio manager
│   │   └── events.gd              # Event system
│   ├── ui_scripts/
│   │   ├── talipapa_shop.gd       # Shop logic
│   │   ├── pause.gd               # Pause logic
│   │   └── transition_layer.gd    # Scene transitions
│   ├── player_script/
│   │   └── area_2d.gd             # Player interactions
│   ├── hud.gd                     # HUD updates
│   ├── boat.gd                    # Boat mechanics
│   ├── fisherman.gd               # Player controller
│   └── [other scripts...]
└── fishing_game_assets/
    └── ari-w9500-condensed-bold.ttf  # Pixel font
```

---

*Architecture Diagram - Reel Change (Oct 01 2026)*
