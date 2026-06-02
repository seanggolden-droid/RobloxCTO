# Monster Mash Simulator

A Roblox collection/evolution simulator built by **Automata Studios**.

## 🎮 Game Features
- **Collect Energy** — Click crystals and passive generation
- **Hatch Monsters** — Gacha system with 5 rarities (Common → Mythical)
- **Evolve** — Combine 5 same monsters into a Shiny (2x stats)
- **Battle** — 10-wave NPC arena combat
- **Explore** — 3 themed zones (Forest, Desert, Cyber)
- **Rebirth** — Prestige system with permanent multipliers

## 💰 Monetization
- **4 Game Passes**: Double Energy, Auto-Hatch, Extra Equip, VIP
- **7 Dev Products**: Energy packs, Lucky Boost, Rare Eggs
- **Daily Rewards**: 7-day login cycle
- **Rewarded Ads**: 2x boosts, free eggs, instant energy
- **Quests**: Daily, Weekly, and Lifetime milestones

## 🛠️ How to Use

### Requirements
- [Rojo](https://rojo.space/) (v7+)
- Roblox Studio with Rojo plugin

### Setup
```bash
rojo serve
```
Then in Roblox Studio: Rojo tab → Connect.

All code syncs automatically. Build the 3D world per specs in `/builds/` and create UI per specs in `/ui/`.

## 📁 Structure
```
├── src/                          # Lua source (Rojo format)
│   ├── ReplicatedStorage/        # Shared modules + remote events
│   ├── ServerScriptService/      # Server systems
│   └── StarterPlayer/            # Client scripts
├── builds/                       # Environment build specs
│   ├── specifications/           # Zone docs with stud dimensions
│   ├── concepts/                 # Concept art (PNG)
│   └── monetization/             # VIP lounge, shop, billboards
├── ui/                           # UI specs + mockups
├── default.project.json          # Rojo config
└── monetization_gdd.md           # Monetization design doc
```
