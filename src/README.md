# Monster Mash Simulator — Source Code

## Overview
This is the complete Luau source code for **Monster Mash Simulator**, a Roblox collection/evolution simulator for 8-16 year olds. Players collect energy, hatch monster eggs (gacha), evolve monsters into shiny forms, battle NPC waves, and unlock themed worlds.

## How to Use

### Prerequisites
- **Roblox Studio** with access to a place
- **Rojo** (optional, for sync workflow) — install from [rojo.space](https://rojo.space)

### Installation

#### Option A: Manual (Roblox Studio)
1. Open Roblox Studio and create a new Baseplate place.
2. Open the **Explorer** panel.
3. Create the following folders and insert scripts as ModuleScripts/LocalScripts/Script as indicated:

#### Option B: Rojo Sync
1. Install Rojo (`rojo serve` in this directory).
2. Open Roblox Studio and connect via the Rojo plugin.
3. The `default.project.json` maps the `src/` directory to the Roblox instance hierarchy.

### Directory Structure (Rojo-style)

```
src/
├── ReplicatedStorage/
│   └── MonsterMash/
│       ├── Modules/
│       │   ├── Constants.lua           # Game balance, zone defs, rarity tables
│       │   ├── RarityModule.lua        # Weighted random gacha rolling + monster generation
│       │   ├── StatCalculator.lua      # EPS, combat power, XP calculations
│       │   └── Types.lua               # Data type constructors & remote event names
│       └── RemoteEvents/
│           ├── CollectEnergy.lua       # Client → Server: click to collect
│           ├── HatchEgg.lua            # Client → Server: hatch egg (RemoteFunction)
│           ├── EquipMonster.lua        # Client → Server: toggle equip
│           ├── EvolveMonster.lua       # Client → Server: combine 5 for shiny
│           └── StartBattle.lua         # Client → Server: enter battle arena
├── ServerScriptService/
│   └── MonsterMashServer/
│       ├── MainServer.lua              # Bootstrapper — wires all server systems
│       ├── PlayerManager.lua           # DataStore persistence, leaderstats, login/logout
│       ├── MonsterManager.lua          # Gacha hatching, equipping, evolution, XP
│       ├── BattleSystem.lua            # NPC wave combat, rewards, damage
│       ├── WorldManager.lua            # Zone unlocking, teleportation, gate logic
│       └── MarketplaceHandler.lua      # Game Pass & Developer Product integration
└── StarterPlayer/
    └── StarterPlayerScripts/
        └── MonsterMashClient/
            ├── MainClient.lua          # Client bootstrapper, remote listeners
            ├── UIController.lua        # HUD, menus (Inventory, Shop, Hatching, Battle, Worlds)
            ├── ClickHandler.lua        # Click/tap energy collection with debounce
            └── EffectManager.lua       # Local visual effects (hatch, evolve, battle)
```

### Script Types
- **ModuleScript (.lua)**: Shared logic in ReplicatedStorage and server/client controllers.
- **Script**: Server-side code in ServerScriptService.
- **LocalScript**: Client-side code in StarterPlayerScripts.

### Setting Up the Place
1. Insert all scripts into the correct service locations (use Rojo, or manually create ModuleScript/Script/LocalScript instances and paste the code).
2. Ensure all child-parent relationships match the structure above.
3. Test the game: **Play** in Studio.

## Core Systems

### 1. PlayerManager (Server)
- Loads and saves player data to Roblox DataStore (key: `Player_{UserId}`)
- Tracks: Energy, Essence, Rank, Inventory (Monsters), Equipped, UnlockedZones, Settings
- Creates leaderstats for the leaderboard
- Rebirth system: resets progress but gives permanent multiplier

### 2. MonsterManager (Server)
- **Hatching**: Validates energy cost, calls RarityModule to generate a monster
- **Equipping**: Toggle equip with max slot check (4 slots, expandable via game pass)
- **Evolution**: Combines 5 same-name monsters → Shiny version with 2x stats
- **XP**: Monsters gain XP from battles, level up (+10% EPS per level)

### 3. BattleSystem (Server)
- Wave-based NPC combat (10 waves maximum)
- Player attacks via debounced clicks; damage = combat power × random(0.8, 1.2)
- NPCs attack every 2 seconds with scaling difficulty
- Rewards: Essence + Monster XP; partial rewards on defeat

### 4. WorldManager (Server)
- 3 zones: Forest Village (free), Scorched Desert (5k Essence), Cyber City (50k Essence)
- Linear progression: must unlock in order
- Teleport player to zone position on unlock or gate touch

### 5. UIController (Client)
- HUD with Energy/Essence counters, rank, action buttons
- Full-screen menus: Shop, Inventory, Hatching Incubator, Battle Arena, World Select
- Battle HUD with real-time wave/HP updates
- Visual confirmations for hatches, evolutions, unlocks, battle results

### 7. MarketplaceHandler (Server)
- **Game Passes**: `Double Energy` (2x energy), `Auto-Hatch` (auto-hatches eggs every 10s), `Extra Equip` (+2 monster slots), `VIP` (1.5x essence + VIP Slime monster)
- **Developer Products**: Instant Energy packs (Small 500/Medium 2.5k/Large 10k), Lucky Egg Boost (15 min luck boost), Rare Eggs (Rare/Epic/Legendary)
- Wired via `MarketplaceService.PromptGamePassPurchaseFinished` and `MarketplaceService.ProcessReceipt`
- Integrates with MonsterManager (dynamic max equip slots), PlayerManager (energy/essence grants), StatCalculator (passive multipliers)
- Weighted gacha: Common 60%, Rare 25%, Epic 10%, Legendary 4.5%, Mythical 0.5%
- Zone rarity boost reduces Common weight for better rolls
- 5% shiny chance on any hatch

## Game Balance (Initial values in Constants.lua)
| Setting | Value |
|---------|-------|
| Starter Monster EPS | 1 |
| Common Egg Cost | 100 Energy |
| Rare Egg Cost | 500 Energy |
| Epic Egg Cost | 2,500 Energy |
| Legendary Egg Cost | 10,000 Energy |
| Mythical Egg Cost | 50,000 Energy |
| Zone 2 Unlock | 5,000 Essence |
| Zone 3 Unlock | 50,000 Essence |
| Rebirth Multiplier | 2× per Rebirth |
| Max Equipped | 4 monsters |

## Monetization (via Shop UI)
- **Game Passes**: Double Energy, Auto-Hatch, Extra Equip, VIP
- **Developer Products**: Instant Energy packs, Lucky Egg Boost, Rare Eggs
- **Placeholders**: UI buttons exist; connect to Robux purchase flow

## Remote Events Reference
| Name | Type | Direction | Purpose |
|------|------|-----------|---------|
| CollectEnergy | Event | Client→Server | Click energy collection |
| HatchEgg | Function | Client→Server | Request egg hatch; returns monster |
| EquipMonster | Event | Client→Server | Toggle equip state |
| EvolveMonster | Event | Client→Server | Combine 5 monsters |
| StartBattle | Event | Client→Server | Enter arena |
| UpdateHUD | Event | Server→Client | Sync stats on join |
| MonsterHatched | Event | Server→Client | Notify of new monster |
| BattleUpdate | Event | Server→Client | Real-time battle state |
| BattleComplete | Event | Server→Client | Battle end + rewards |
| EvolutionComplete | Event | Server→Client | Shiny monster result |
| ZoneUnlocked | Event | Server→Client | Zone unlock notification |
| EnergyCollected | Event | Server→Client | Sync energy after click |

## Performance Notes
- All ModuleScripts are shared (single copy in memory)
- Server validates all client requests (anti-cheat)
- Client effects are local-only (no server overhead)
- Auto-save every 60 seconds
- Passive essence generation runs on a 1-second timer
- Click debounce: 0.15 seconds
- Battle attack debounce: 0.5 seconds
- NPC attack tick: every 2 seconds

## Next Steps / Follow-up
- [ ] Connect Shop/Purchase UI to actual Roblox Game Pass/Developer Product APIs
- [ ] Add remote for client requesting inventory data from server
- [ ] Implement the "Auto-Hatch" game pass logic
- [ ] Add more monster name pools for variety
- [ ] Implement zone-specific egg pools (better eggs in later zones)
- [ ] Add in-game Quests system
- [ ] Create actual 3D models/terrain per the Build Specifications