# Global World Specification: Monster Mash Simulator

## 1. Map Architecture
The game world is a linear progression of themed zones separated by "Progression Gates".

- **Total Dimensions:** 2000 x 500 studs.
- **Zone Size:** Each zone is approximately 500 x 500 studs.
- **Layout:** Zone 1 (Spawn) -> Gate 1 -> Zone 2 -> Gate 2 -> Zone 3.

## 2. Progression Gates
- **Design:** Large semi-transparent neon barriers (50x100x10 studs).
- **Function:** Display unlock cost via BillboardGui.
- **Placement:** Centered between zones.

## 3. Universal Elements
- **Energy Crystals:** 
    - Small (2x2x2 studs)
    - Medium (4x4x4 studs)
    - Large (8x8x8 studs)
    - Shape: Randomly rotated crystalline meshes or unioned parts.
- **Paths:** 15-stud wide paths connecting the Spawn, Incubator, and the next Gate.
- **Boundary:** Invisible walls or natural barriers (mountains, water, deep pits) to keep players within the map.

## 4. Lighting & Atmosphere (Global)
- **ClockTime:** 14 (Default mid-day)
- **Brightness:** 2
- **OutdoorAmbient:** 128, 128, 128
- **GlobalShadows:** On
