# Energy Crystal Design Specification

## 1. Core Structure
Energy Crystals are interactive objects that players click to collect energy. They use a consistent shard-like shape but vary by zone.

- **Base Part:** MeshPart or Union.
- **Shape:** 3-5 intersecting shards of varying sizes.
- **Size Variations:**
    - Small: 2x2x2 studs
    - Medium: 4x4x4 studs
    - Large: 8x8x8 studs

## 2. Zone Variations

### A. Forest Crystals (Starter)
- **Color:** Bright Green (Neon).
- **Material:** Neon / SmoothPlastic.
- **VFX:** Gentle green sparkles.

### B. Desert Crystals (Fire)
- **Color:** Bright Orange/Red (Neon).
- **Material:** Neon / Cracked Lava texture.
- **VFX:** Small flame/smoke particles at the base.

### C. Cyber Crystals (Digital)
- **Color:** Cyan / Magenta (Neon).
- **Material:** Neon / Glass.
- **Shape:** Perfect cubes or octahedrons with "glitch" particles.
- **VFX:** Blue digital "trailing" particles.

## 3. Interaction Design
- **Selection Box:** A thin glowing outline appears when the player hovers their cursor over a crystal.
- **Collection Effect:** When clicked, the crystal shrinks and a "floating text" effect shows +Energy.
