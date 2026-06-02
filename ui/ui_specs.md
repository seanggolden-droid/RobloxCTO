# UI Specifications: Monster Mash Simulator

## Overview
This document provides detailed Roblox ScreenGui specifications for all game screens. All UI is built using ScreenGui → Frame → UIListLayout/UICorner/UIPadding → TextLabel/ImageButton hierarchy. Dimensions use UDim2 (Scale, Offset).

---

## Color Palette & Theme

### Primary Palette
| Role       | Color Name     | Color3 RGB            | Hex       | Usage                        |
|------------|----------------|-----------------------|-----------|------------------------------|
| Primary    | Monster Green  | Color3(0.20, 0.78, 0.30) | #33C84D  | Buttons, headers, accents    |
| Secondary  | Sky Blue       | Color3(0.20, 0.55, 1.00) | #338CFF  | Info panels, secondary BTNs  |
| Accent     | Energy Orange  | Color3(1.00, 0.55, 0.10) | #FF8C1A  | Click area, special elements  |
| Danger     | Battle Red     | Color3(1.00, 0.20, 0.20) | #FF3333  | Health bars, warnings         |
| Background | Deep Navy      | Color3(0.06, 0.06, 0.12) | #0F0F1F  | Main screen backgrounds       |
| Panel      | Dark Slate     | Color3(0.12, 0.12, 0.22) | #1E1E38  | Menu panels, frames           |
| Text       | Pure White     | Color3(1.00, 1.00, 1.00) | #FFFFFF  | Primary text                  |
| Text Dim   | Soft Grey      | Color3(0.70, 0.70, 0.80) | #B3B3CC  | Secondary text, hints         |

### Rarity Colors (For Monster Border/Glow)
| Rarity    | Color3                        | Hex       |
|-----------|-------------------------------|-----------|
| Common    | Color3(0.60, 0.60, 0.60)     | #999999   |
| Rare      | Color3(0.20, 0.40, 1.00)     | #3366FF   |
| Epic      | Color3(0.60, 0.20, 0.90)     | #9933E6   |
| Legendary | Color3(1.00, 0.80, 0.10)     | #FFCC1A   |
| Mythical  | Color3(1.00, 0.10, 0.30)     | #FF1A4D   |

### Font System
- **Headers:** `GothamBold` — Title text, section headers
- **Body:** `GothamSemibold` — Buttons, labels, stat values
- **Small/Detail:** `Gotham` — Descriptions, tooltips
- **Monster Names:** `GothamBold` with rarity-colored text

### Corner Radii
- **Buttons:** `UICorner` with `CornerRadius = UDim.new(0, 8)`
- **Panels/Menus:** `UICorner` with `CornerRadius = UDim.new(0, 12)`
- **Monster Cards:** `UICorner` with `CornerRadius = UDim.new(0, 10)`
- **Progress Bars:** `UICorner` with `CornerRadius = UDim.new(0, 4)`

---

## 1. Main HUD (ScreenGui: "MainHUD")

This is the primary gameplay screen visible at all times. Contains stats, navigation, and the click-to-collect area.

### 1.1 Top Bar (Frame "TopBar")
```
Position: UDim2(0, 0, 0, 0)
Size:     UDim2(1, 0, 0, 60)
BackgroundColor3: Color3(0.08, 0.08, 0.16)  — slightly lighter than main BG
BackgroundTransparency: 0.15
```

**Energy Counter** (Frame "EnergyCounter")
```
Position: UDim2(0.02, 0, 0, 10)
Size:     UDim2(0, 200, 0, 40)
BackgroundColor3: Color3(0, 0, 0)
BackgroundTransparency: 0.5
UICorner: CornerRadius = UDim.new(0, 8)
```
- **Children:**
  - `ImageLabel` — Energy icon (Lightning bolt icon). Size: UDim2(0, 32, 0, 32). Position: UDim2(0, 6, 0.5, -16).
  - `TextLabel` — "ENERGY" label. Font: GothamSemibold, TextSize: 11, TextColor3: Soft Grey. Position: UDim2(0, 44, 0, 4).
  - `TextLabel` — Dynamic energy value (e.g., "1,250"). Font: GothamBold, TextSize: 18, TextColor3: Energy Orange. Position: UDim2(0, 44, 0, 18).

**Essence Counter** (Frame "EssenceCounter")
```
Position: UDim2(0.02, 210, 0, 10)
Size:     UDim2(0, 200, 0, 40)
BackgroundColor3: Color3(0, 0, 0)
BackgroundTransparency: 0.5
UICorner: CornerRadius = UDim.new(0, 8)
```
- **Children:**
  - `ImageLabel` — Essence icon (Crystal/Sparkle icon). Size: UDim2(0, 32, 0, 32). Position: UDim2(0, 6, 0.5, -16).
  - `TextLabel` — "ESSENCE" label. Font: GothamSemibold, TextSize: 11, TextColor3: Soft Grey. Position: UDim2(0, 44, 0, 4).
  - `TextLabel` — Dynamic essence value (e.g., "8,500"). Font: GothamBold, TextSize: 18, TextColor3: Monster Green. Position: UDim2(0, 44, 0, 18).

**VIP Indicator** (Frame "VIPIndicator")
```
Position: UDim2(0.98, -290, 0, 10)
Size:     UDim2(0, 140, 0, 40)
BackgroundColor3: Color3(0, 0, 0)
BackgroundTransparency: 0.5
UICorner: CornerRadius = UDim.new(0, 8)
BorderSizePixel: 2
BorderColor3: Legendary Gold
```
- **Two visual states (mutually exclusive):**
  - **Owns VIP:** Shows crown icon + "VIP" label + "1.5x Essence" subtitle. Border is Legendary Gold.
  - **Does NOT own VIP:** Shows "👑 GET VIP" text button. On click: opens ShopGUI and scrolls to VIP card.
- **Children:**
  - `ImageLabel` — Crown icon. Size: UDim2(0, 28, 0, 28). Position: UDim2(0, 6, 0.5, -14).
  - `TextLabel` — "VIP" (or "GET VIP"). Font: GothamBold, TextSize: 14, TextColor3: Legendary Gold. Position: UDim2(0, 38, 0, 4).
  - `TextLabel` — "1.5x Essence" (hidden for non-VIP). Font: Gotham, TextSize: 10, TextColor3: Soft Grey. Position: UDim2(0, 38, 0, 22).

**Player Rank** (Frame "PlayerRank")
```
Position: UDim2(0.98, -140, 0, 10)
Size:     UDim2(0, 140, 0, 40)
BackgroundColor3: Color3(0, 0, 0)
BackgroundTransparency: 0.5
UICorner: CornerRadius = UDim.new(0, 8)
```
- **Children:**
  - `TextLabel` — "RANK" label. Font: GothamSemibold, TextSize: 11, TextColor3: Soft Grey. Position: UDim2(0, 10, 0, 4).
  - `TextLabel` — Rank number (e.g., "★ 3"). Font: GothamBold, TextSize: 18, TextColor3: Gold (Legendary color). Position: UDim2(0, 10, 0, 18).

**Rebirth Button** (TextButton "RebirthButton")
```
Position: UDim2(0.98, -140, 0, 55)
Size:     UDim2(0, 140, 0, 28)
BackgroundColor3: Color3(0.80, 0.10, 0.90)
UICorner: CornerRadius = UDim.new(0, 6)
Text: "⭐ REBIRTH"
Font: GothamBold, TextSize: 13, TextColor3: White
```

### 1.2 Navigation Buttons (Left Side)
```
Position: UDim2(0.01, 0, 0.25, 0)
Size:     UDim2(0, 180, 0, 398)
```
Vertical layout with 7 navigation buttons, each 50px tall, 8px gap:

**Shop Button** (ImageButton "BtnShop")
```
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Primary (Monster Green)
UICorner: CornerRadius = UDim.new(0, 8)
Text: "🛒 SHOP"
Font: GothamBold, TextSize: 16, TextColor3: White
```

**Inventory Button** (ImageButton "BtnInventory")
```
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Secondary (Sky Blue)
UICorner: CornerRadius = UDim.new(0, 8)
Text: "📦 MONSTERS"
Font: GothamBold, TextSize: 16, TextColor3: White
```

**Incubator Button** (ImageButton "BtnIncubator")
```
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Color3(0.90, 0.30, 0.70)  — Hot Pink
UICorner: CornerRadius = UDim.new(0, 8)
Text: "🥚 HATCH"
Font: GothamBold, TextSize: 16, TextColor3: White
```

**Battle Button** (ImageButton "BtnBattle")
```
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Danger (Battle Red)
UICorner: CornerRadius = UDim.new(0, 8)
Text: "⚔️ BATTLE"
Font: GothamBold, TextSize: 16, TextColor3: White
```

**Worlds Button** (ImageButton "BtnWorlds")
```
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Color3(0.30, 0.15, 0.50)  — Deep Purple
UICorner: CornerRadius = UDim.new(0, 8)
Text: "🌍 WORLDS"
Font: GothamBold, TextSize: 16, TextColor3: White
```

**Quests Button** (ImageButton "BtnQuests")
```
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Color3(0.90, 0.55, 0.10)  — Warm Orange
UICorner: CornerRadius = UDim.new(0, 8)
Text: "📋 QUESTS"
Font: GothamBold, TextSize: 16, TextColor3: White
```
- On click: Opens `QuestsGUI` (see monetization_ui_specs.md §2)

**Daily Rewards Button** (ImageButton "BtnDailyRewards")
```
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Color3(0.60, 0.20, 0.80)  — Purple
UICorner: CornerRadius = UDim.new(0, 8)
Text: "🎁 DAILY"
Font: GothamBold, TextSize: 16, TextColor3: White
```
- On click: Opens `DailyRewardsGUI` (see monetization_ui_specs.md §1)

### 1.3 Settings & Misc (Top Right)
**Settings Button** (ImageButton "BtnSettings")
```
Position: UDim2(0.98, -45, 0.02, 0)
Size: UDim2(0, 40, 0, 40)
BackgroundColor3: Color3(0.15, 0.15, 0.25)
BackgroundTransparency: 0.3
UICorner: CornerRadius = UDim.new(0, 8)
Text: "⚙️"
Font: Gotham, TextSize: 20
```

**Codes Button** (ImageButton "BtnCodes")
```
Position: UDim2(0.98, -45, 0.02, 48)
Size: UDim2(0, 40, 0, 40)
BackgroundColor3: Color3(0.15, 0.15, 0.25)
BackgroundTransparency: 0.3
UICorner: CornerRadius = UDim.new(0, 8)
Text: "🎁"
Font: Gotham, TextSize: 20
```

**Ad Button** (ImageButton "BtnAd")
```
Position: UDim2(0.98, -45, 0.02, 96)
Size: UDim2(0, 40, 0, 40)
BackgroundColor3: Color3(0.15, 0.15, 0.25)
BackgroundTransparency: 0.3
UICorner: CornerRadius = UDim.new(0, 8)
Text: "📺"
Font: Gotham, TextSize: 20
```
- On click: Triggers rewarded video ad via RemoteEvent `RequestRewardAd`. On completion, grants bonus Energy.
- Shows cooldown indicator when recently used (faint overlay + remaining time).

### 1.4 Equipped Monsters Bar (Bottom Center)
**Equipped Slots Frame** (Frame "EquippedBar")
```
Position: UDim2(0.5, -200, 1, -75)
Size: UDim2(0, 400, 0, 65)
BackgroundColor3: Color3(0.08, 0.08, 0.16)
BackgroundTransparency: 0.3
UICorner: CornerRadius = UDim.new(0, 10)
```
Contains 3 monster slots arranged horizontally (UIListLayout, FillDirection=Horizontal, Padding=10px):

**Each Monster Slot** (Frame "MonsterSlot1/2/3")
```
Size: UDim2(0, 55, 0, 55)
BackgroundColor3: Color3(0.15, 0.15, 0.25)
BackgroundTransparency: 0.4
UICorner: CornerRadius = UDim.new(0, 8)
```
- **Children:**
  - `ImageLabel` — Monster icon (Face of monster). Size: UDim2(0, 40, 0, 40). Position: UDim2(0.5, -20, 0.5, -22).
  - `TextLabel` — Level indicator (e.g., "Lv.5"). Font: GothamSemibold, TextSize: 9. Position: UDim2(0.5, -15, 1, -14).
  - `Frame` — Rarity border glow (thin border matching rarity color). Size: UDim2(1, 0, 1, 0). BackgroundTransparency: 1. BorderSizePixel: 2.

### 1.5 Main Click Area (Bottom Right)
**Click Button** (ImageButton "ClickButton")
```
Position: UDim2(0.85, -65, 0.85, -65)
Size: UDim2(0, 130, 0, 130)
BackgroundColor3: Energy Orange
BackgroundTransparency: 0.1
UICorner: CornerRadius = UDim.new(0, 65)  — Perfect circle
Text: "⚡"
Font: Gotham, TextSize: 50
```
- **Visual Effects (via TweenService on click):**
  - Scale pulse: 1.0 → 0.90 → 1.05 → 1.0 (0.2s total)
  - BackgroundTransparency: 0.1 → 0.3 → 0.1
  - ParticleEmitter on click position

---

## 2. Incubator / Hatching Screen (ScreenGui: "IncubatorGUI")

Full-screen overlay when player opens the Incubator. Contains egg selection, purchase, and hatch animation.

### 2.1 Background Overlay
```
Position: UDim2(0, 0, 0, 0)
Size: UDim2(1, 0, 1, 0)
BackgroundColor3: Color3(0, 0, 0)
BackgroundTransparency: 0.4
```
- On click: closes the Incubator GUI (if not currently animating)

### 2.2 Main Panel (Frame "IncubatorPanel")
```
Position: UDim2(0.5, -350, 0.5, -300)
Size: UDim2(0, 700, 0, 600)
BackgroundColor3: Panel (Dark Slate)
UICorner: CornerRadius = UDim.new(0, 16)
```

**Title Bar** (Frame "TitleBar")
```
Position: UDim2(0, 0, 0, 0)
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Color3(0.08, 0.08, 0.18)
UICorner: CornerRadius = UDim.new(16, 16)
```
- **Children:**
  - `TextLabel` — "🥚 INCUBATOR". Font: GothamBold, TextSize: 22, TextColor3: White. Position: UDim2(0.5, -80, 0.5, -11).
  - `TextButton` — "✕" close button. Font: GothamBold, TextSize: 20, TextColor3: Soft Grey. Position: UDim2(1, -40, 0.5, -15). Size: UDim2(0, 30, 0, 30).

### 2.3 Egg Display Area (Frame "EggDisplay")
```
Position: UDim2(0.5, -100, 0.15, 0)
Size: UDim2(0, 200, 0, 200)
BackgroundTransparency: 1
```
- **Children:**
  - `ImageLabel` — Current egg image (placeholder: simple egg shape). Size: UDim2(0, 160, 0, 160). Position: UDim2(0.5, -80, 0.5, -80).
  - `Frame` — Glow effect behind egg. Size: UDim2(0, 180, 0, 180). Position: UDim2(0.5, -90, 0.5, -90). BackgroundColor3: White. BackgroundTransparency: 0.85.

### 2.4 Egg Selection Row (Frame "EggSelection")
```
Position: UDim2(0, 20, 0.45, 0)
Size: UDim2(1, -40, 0, 120)
BackgroundTransparency: 1
```
Three egg types in horizontal UIListLayout:

**Common Egg Card** (Frame "EggCommon")
```
Size: UDim2(0.3, -10, 1, 0)
BackgroundColor3: Color3(0.15, 0.15, 0.25)
UICorner: CornerRadius = UDim.new(0, 10)
```
- `ImageLabel` — Green egg icon. Size: UDim2(0, 80, 0, 80). Position: UDim2(0.5, -40, 0.1, 0).
- `TextLabel` — "COMMON EGG". Font: GothamBold, TextSize: 14, TextColor3: White.
- `TextLabel` — "100 Energy". Font: Gotham, TextSize: 13, TextColor3: Energy Orange.
- `TextLabel` — "60% Common • 25% Rare". Font: Gotham, TextSize: 10, TextColor3: Soft Grey.
- `TextButton` — "HATCH". BackgroundColor3: Primary. UICorner: 6px. Font: GothamBold, TextSize: 14. Position: UDim2(0.1, 0, 0.78, 0). Size: UDim2(0.8, 0, 0, 30).

**Rare Egg Card** (Frame "EggRare")
```
Size: UDim2(0.3, -10, 1, 0)
BackgroundColor3: Color3(0.15, 0.15, 0.30)
UICorner: CornerRadius = UDim.new(0, 10)
BorderSizePixel: 2
BorderColor3: Rare Blue
```
- `ImageLabel` — Blue egg icon. Size: UDim2(0, 80, 0, 80). Position: UDim2(0.5, -40, 0.1, 0).
- `TextLabel` — "RARE EGG". Font: GothamBold, TextSize: 14, TextColor3: Rare Blue.
- `TextLabel` — "500 Energy". Font: Gotham, TextSize: 13, TextColor3: Energy Orange.
- `TextLabel` — "60% Rare • 20% Epic". Font: Gotham, TextSize: 10, TextColor3: Soft Grey.
- `TextButton` — "HATCH". BackgroundColor3: Rare Blue. UICorner: 6px. Font: GothamBold, TextSize: 14.

**Legendary Egg Card** (Frame "EggLegendary")
```
Size: UDim2(0.3, -10, 1, 0)
BackgroundColor3: Color3(0.20, 0.15, 0.05)
UICorner: CornerRadius = UDim.new(0, 10)
BorderSizePixel: 2
BorderColor3: Legendary Gold
```
- `ImageLabel` — Golden egg icon. Size: UDim2(0, 80, 0, 80). Position: UDim2(0.5, -40, 0.1, 0).
- `TextLabel` — "LEGENDARY EGG". Font: GothamBold, TextSize: 14, TextColor3: Legendary Gold.
- `TextLabel` — "2,500 Energy / 50 R$". Font: Gotham, TextSize: 13, TextColor3: Energy Orange.
- `TextLabel` — "50% Epic • 30% Legendary". Font: Gotham, TextSize: 10, TextColor3: Soft Grey.
- `TextButton` — "HATCH". BackgroundColor3: Legendary Gold. TextColor3: Black. UICorner: 6px. Font: GothamBold, TextSize: 14.

### 2.5 Animation Overlay (Frame "HatchAnimation")
*Hidden by default. Shown when hatching starts.*
```
Position: UDim2(0, 0, 0, 0)
Size: UDim2(1, 0, 1, 0)
BackgroundColor3: Color3(0, 0, 0)
BackgroundTransparency: 0.6
```
- **Children:**
  - `ImageLabel` — Egg in center, scaled to 250x250. Position: UDim2(0.5, -125, 0.5, -125).
  - `ImageLabel` — Glow ring behind egg. Size: UDim2(0, 400, 0, 400). Position: UDim2(0.5, -200, 0.5, -200).
  - **Animation Sequence (TweenService):**
    1. Egg shakes (Rotation: -5° to 5° over 0.5s, 3 repeats)
    2. Egg scales up rapidly (1 → 1.2 over 0.3s)
    3. Glow ring brightens (BackgroundTransparency: 0.9 → 0.3)
    4. Egg fades out / particle burst
    5. Monster reveal image appears with rarity-colored border and text announcement

### 2.6 Monster Reveal (Frame "MonsterReveal")
*Shown after hatch animation.*
```
Position: UDim2(0, 0, 0, 0)
Size: UDim2(1, 0, 1, 0)
BackgroundColor3: Color3(0, 0, 0)
BackgroundTransparency: 0.5
```
- **Children:**
  - `ImageLabel` — Monster portrait. Size: UDim2(0, 200, 0, 200). Position: UDim2(0.5, -100, 0.35, -100).
  - `TextLabel` — Monster name (e.g., "🔥 IGNIS THE DRAGON"). Font: GothamBold, TextSize: 30, TextColor3: [rarity color].
  - `TextLabel` — Rarity label (e.g., "✦ LEGENDARY ✦"). Font: GothamBold, TextSize: 22. TextColor3: Legendary Gold.
  - `TextLabel` — Stats: "EPS: 25 | LVL: 1". Font: GothamSemibold, TextSize: 16. TextColor3: Soft Grey.
  - `TextButton` — "COLLECT!". Position: UDim2(0.5, -80, 0.75, 0). Size: UDim2(0, 160, 0, 45). BackgroundColor3: Monster Green.
    UICorner: 10px. Font: GothamBold, TextSize: 18.
  - Particle effects around the monster based on rarity.

---

## 3. Monster Inventory / Equip Screen (ScreenGui: "InventoryGUI")

Full-screen overlay for viewing, equipping, and evolving monsters.

### 3.1 Background Overlay & Main Panel
Same structure as Incubator: semi-transparent black overlay + centered panel.

**Inventory Panel** (Frame "InventoryPanel")
```
Position: UDim2(0.5, -425, 0.5, -320)
Size: UDim2(0, 850, 0, 640)
BackgroundColor3: Panel (Dark Slate)
UICorner: CornerRadius = UDim.new(0, 16)
```

**Title Bar** (Frame "TitleBar")
```
Position: UDim2(0, 0, 0, 0)
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Color3(0.08, 0.08, 0.18)
UICorner: CornerRadius = UDim.new(16, 16)
```
- `TextLabel` — "📦 MY MONSTERS". Font: GothamBold, TextSize: 22. Position: UDim2(0.5, -80, 0.5, -11).
- `TextButton` — "✕" close button.

### 3.2 Summary Bar (Frame "SummaryBar")
```
Position: UDim2(0, 20, 0.075, 0)
Size: UDim2(1, -40, 0, 40)
BackgroundColor3: Color3(0.10, 0.10, 0.20)
UICorner: CornerRadius = UDim.new(0, 8)
```
- Children arranged horizontally:
  - `TextLabel` — "Monsters: 12/50". Font: GothamSemibold, TextSize: 14.
  - `TextLabel` — "Equipped: 2/3". Font: GothamSemibold, TextSize: 14.
  - `TextLabel` — "Total EPS: 45/s". Font: GothamSemibold, TextSize: 14, TextColor3: Monster Green.

### 3.3 Tab Buttons (Frame "TabBar")
```
Position: UDim2(0, 20, 0.13, 0)
Size: UDim2(1, -40, 0, 35)
BackgroundTransparency: 1
```
- **"MONSTERS" Tab** (TextButton). Size: UDim2(0.5, -4, 1, 0). BackgroundColor3: Monster Green (active). Font: GothamBold.
- **"ITEMS" Tab** (TextButton). Size: UDim2(0.5, -4, 1, 0). Position: UDim2(0.5, 4, 0, 0). BackgroundColor3: Color3(0.2, 0.2, 0.3) (inactive).

### 3.4 Monster Grid (ScrollingFrame "MonsterGrid")
```
Position: UDim2(0, 20, 0.19, 0)
Size: UDim2(1, -40, 0.68, 0)
BackgroundTransparency: 1
ScrollBarThickness: 4
CanvasSize: UDim2(0, 0, 2, 0)  — Dynamically sized
```
- Uses `UIGridLayout` with:
  - CellSize: UDim2(0, 120, 0, 150)
  - CellPadding: UDim2(0, 10, 0, 10)
  - FillDirection: Horizontal
  - SortOrder: LayoutOrder (rarity-sorted: Mythical first)

**Each Monster Card** (Frame "MonsterCard")
```
Size: UDim2(0, 120, 0, 150)
BackgroundColor3: Color3(0.15, 0.15, 0.25)
UICorner: CornerRadius = UDim.new(0, 10)
```
- `Frame` — Rarity border (thin frame, BackgroundTransparency: 1, BorderSizePixel: 2, BorderColor3: [rarity color]).
- `ImageLabel` — Monster icon. Size: UDim2(0, 80, 0, 80). Position: UDim2(0.5, -40, 0, 8).
- `TextLabel` — Monster name. Font: GothamBold, TextSize: 11. TextColor3: White. Position: UDim2(0, 5, 0, 92). Size: UDim2(1, -10, 0, 16). TextTruncate: AtEnd.
- `TextLabel` — "Lv. 3". Font: GothamSemibold, TextSize: 10. TextColor3: Soft Grey. Position: UDim2(0, 5, 0, 108).
- `TextLabel` — "EPS: 12/s". Font: Gotham, TextSize: 10. TextColor3: Monster Green. Position: UDim2(0, 5, 0, 122).
- `TextButton` — "EQUIP" (if unequipped) or "UNEQUIP" (if equipped). Size: UDim2(1, -8, 0, 22). Position: UDim2(0, 4, 1, -26).
  - "EQUIP": BackgroundColor3: Secondary (Sky Blue). UICorner: 6px.
  - "UNEQUIP": BackgroundColor3: Color3(0.3, 0.3, 0.3). UICorner: 6px. TextColor3: Soft Grey.
- If maximum equipped (3) and monster not equipped, show a faint lock overlay + tooltip "Max equipped"

### 3.5 Evolution Section (Frame "EvolutionSection")
```
Position: UDim2(0, 20, 0.9, -60)
Size: UDim2(1, -40, 0, 50)
BackgroundColor3: Color3(0.10, 0.10, 0.20)
UICorner: CornerRadius = UDim.new(0, 10)
```
- `TextLabel` — "Evolve 5 identical monsters into a ⭐SHINY version (2x stats!)". Font: Gotham, TextSize: 13. TextColor3: Soft Grey. Position: UDim2(0, 10, 0.5, -10).
- `TextButton` — "EVOLVE". Position: UDim2(1, -100, 0.5, -16). Size: UDim2(0, 90, 0, 32). BackgroundColor3: Color3(0.80, 0.20, 0.70) — Magenta. UICorner: 8px. Font: GothamBold, TextSize: 14.

---

## 4. Shop Screen (ScreenGui: "ShopGUI")

Full-screen overlay for purchasing game passes, currency, and boosts.

### 4.1 Main Panel
```
Position: UDim2(0.5, -425, 0.5, -320)
Size: UDim2(0, 850, 0, 640)
BackgroundColor3: Panel (Dark Slate)
UICorner: CornerRadius = UDim.new(0, 16)
```

**Title Bar**: "🛒 SHOP". Font: GothamBold, TextSize: 22.

### 4.2 Category Tabs (Frame "CategoryTabs")
```
Position: UDim2(0, 20, 0.09, 0)
Size: UDim2(1, -40, 0, 35)
BackgroundTransparency: 1
```
Three tabs horizontally (UIListLayout, FillDirection=Horizontal):

- **"GAME PASSES"** — Active by default. BackgroundColor3: Monster Green.
- **"CURRENCY"** — Inactive: Dark grey.
- **"BOOSTS"** — Inactive: Dark grey.

### 4.3 Items Grid (ScrollingFrame "ShopGrid")
```
Position: UDim2(0, 20, 0.16, 0)
Size: UDim2(1, -40, 0.78, 0)
BackgroundTransparency: 1
ScrollBarThickness: 4
UIGridLayout: CellSize = UDim2(0, 260, 0, 180), CellPadding = UDim2(0, 12, 0, 12)
```

#### Game Passes Section Items:

**"Double Energy" Pass Card**
```
BackgroundColor3: Color3(0.15, 0.15, 0.25)
UICorner: 12px
BorderSizePixel: 2
BorderColor3: Energy Orange
```
- `ImageLabel` — Lightning bolt ×2 icon. Size: UDim2(0, 60, 0, 60). Center-top.
- `TextLabel` — "⚡ DOUBLE ENERGY". Font: GothamBold, TextSize: 16. TextColor3: Energy Orange.
- `TextLabel` — "Collect 2x Energy from all sources!". Font: Gotham, TextSize: 11. TextColor3: Soft Grey.
- `TextLabel` — "400 Robux". Font: GothamBold, TextSize: 15. TextColor3: Gold.
- `TextButton` — "BUY". BackgroundColor3: Monster Green. Size: UDim2(0.8, 0, 0, 32). Font: GothamBold. UICorner: 8px.

**"Auto-Hatch" Pass Card**
- BorderColor3: Sky Blue
- Icon: Robot arm holding egg.
- `TextLabel` — "🤖 AUTO-HATCH". Font: GothamBold, TextSize: 16. TextColor3: Sky Blue.
- `TextLabel` — "Automatically hatches eggs without clicking!". Font: Gotham, TextSize: 11. TextColor3: Soft Grey.
- `TextLabel` — "250 Robux". Font: GothamBold, TextSize: 15. TextColor3: Gold.
- `TextButton` — "BUY". Green.

**"Extra Equip" Pass Card**
- BorderColor3: Purple
- Icon: Three monster slots.
- `TextLabel` — "🎒 EXTRA EQUIP". Font: GothamBold, TextSize: 16. TextColor3: Color3(0.7, 0.3, 1.0).
- `TextLabel` — "Equip 2 more monsters (up to 5 total)". Font: Gotham, TextSize: 11.
- `TextLabel` — "350 Robux". Font: GothamBold, TextSize: 15. TextColor3: Gold.
- `TextButton` — "BUY". Green.

**"VIP" Pass Card**
```
BorderColor3: Legendary Gold
```
- `ImageLabel` — Crown icon.
- `TextLabel` — "👑 VIP". Font: GothamBold, TextSize: 16. TextColor3: Legendary Gold.
- `TextLabel` — "VIP tag, 1.5x Essence, +Exclusive VIP Slime!". Font: Gotham, TextSize: 11.
- `TextLabel` — "500 Robux". Font: GothamBold, TextSize: 15. TextColor3: Gold.
- `TextButton` — "BUY". BackgroundColor3: Legendary Gold. TextColor3: Black.

#### Currency Section Items:

**Instant Energy Packs** (Small/Med/Large cards):
- Small: "⚡ 1,000 Energy • 25 Robux"
- Medium: "⚡⚡ 5,000 Energy • 100 Robux"  
- Large: "⚡⚡⚡ 25,000 Energy • 400 Robux"

**Lucky Egg Boost** — "🍀 2x Luck • 15 min • 50 Robux". Purple border.

**Rare Eggs** — "🥚 Rare Egg x3 • 75 Robux". Blue border.

---

## 5. Battle Arena HUD (ScreenGui: "BattleGUI")

Shown when player enters a battle arena. Overlays the main screen.

### 5.1 Battle Background (Frame "BattleBg")
```
Position: UDim2(0, 0, 0, 0)
Size: UDim2(1, 0, 1, 0)
BackgroundColor3: Color3(0.02, 0.02, 0.06)
BackgroundTransparency: 0.3
```

### 5.2 Wave Indicator (Frame "WaveInfo")
```
Position: UDim2(0.5, -100, 0.02, 0)
Size: UDim2(0, 200, 0, 30)
BackgroundColor3: Color3(0.12, 0.12, 0.22)
UICorner: CornerRadius = UDim.new(0, 8)
```
- `TextLabel` — "🌊 WAVE 3 / 10". Font: GothamBold, TextSize: 16. TextColor3: White.

### 5.3 Enemy Display (Frame "EnemyDisplay")
```
Position: UDim2(0.5, -100, 0.3, -50)
Size: UDim2(0, 200, 0, 200)
BackgroundTransparency: 1
```
- `ImageLabel` — Enemy monster image. Size: UDim2(0, 160, 0, 160). Center.
- **Enemy Health Bar** (Frame "EnemyHP")
  ```
  Position: UDim2(0.5, -75, 1, -5)
  Size: UDim2(0, 150, 0, 16)
  BackgroundColor3: Color3(0.3, 0.3, 0.3)
  UICorner: CornerRadius = UDim.new(0, 4)
  ```
  - `Frame` — HP fill. BackgroundColor3: Battle Red. Size: UDim2(1, 0, 1, 0). (Dynamically adjusted via Tween).
  - `TextLabel` — "75 / 100". Font: GothamBold, TextSize: 11. TextColor3: White. Overlay center.

### 5.4 Player Monsters (Bottom)
**Player Monster Frame** (Frame "PlayerMonster")
```
Position: UDim2(0.5, -80, 0.65, 0)
Size: UDim2(0, 160, 0, 140)
BackgroundTransparency: 1
```
- `ImageLabel` — First equipped monster image. Size: UDim2(0, 120, 0, 120). Center.
- `TextLabel` — Monster name + level. Font: GothamSemibold, TextSize: 11. Bottom center.

### 5.5 Damage Numbers (Overlay)
Dynamic `TextLabel` objects spawned on hit:
- Position near enemy center
- Font: GothamBold, TextSize: 30
- TextColor3: Battle Red or White
- Text: "25!" (damage amount)
- Animation: Float upward + fade out over 1s

### 5.6 Battle Controls (Bottom Bar "BattleControls")
```
Position: UDim2(0, 0, 1, -80)
Size: UDim2(1, 0, 0, 80)
BackgroundColor3: Color3(0.08, 0.08, 0.16)
BackgroundTransparency: 0.2
```

**Attack Button** (ImageButton "BtnAttack")
```
Position: UDim2(0.5, -60, 0.5, -30)
Size: UDim2(0, 120, 0, 60)
BackgroundColor3: Battle Red
UICorner: CornerRadius = UDim.new(0, 12)
Text: "⚔️ ATTACK"
Font: GothamBold, TextSize: 18
```
- On click: Deal damage to enemy, play attack animation on player monster.

**Auto-Attack Toggle** (TextButton "BtnAutoAttack")
```
Position: UDim2(0.2, -45, 0.5, -20)
Size: UDim2(0, 90, 0, 40)
BackgroundColor3: Color3(0.20, 0.20, 0.30)
UICorner: CornerRadius = UDim.new(0, 8)
Text: "AUTO"
Font: GothamSemibold, TextSize: 14
```
- Toggle state: When active, BackgroundColor3 switches to Monster Green.
- When auto-attack enabled, player attacks automatically every 1s.

**Leave Button** (TextButton "BtnLeaveBattle")
```
Position: UDim2(0.8, -45, 0.5, -20)
Size: UDim2(0, 90, 0, 40)
BackgroundColor3: Color3(0.30, 0.10, 0.10)
UICorner: CornerRadius = UDim.new(0, 8)
Text: "🚪 LEAVE"
Font: GothamSemibold, TextSize: 14, TextColor3: Soft Grey
```

### 5.7 Victory / Defeat Screen (Frame "BattleResult")
*Shown when all enemies defeated OR player fails.*

**Victory:**
```
Position: UDim2(0.5, -200, 0.5, -150)
Size: UDim2(0, 400, 0, 300)
BackgroundColor3: Panel (Dark Slate)
UICorner: CornerRadius = UDim.new(0, 16)
```
- `TextLabel` — "🎉 VICTORY!". Font: GothamBold, TextSize: 36. TextColor3: Legendary Gold.
- `TextLabel` — "Rewards: +250 Essence, Relic Shard x1". Font: GothamSemibold, TextSize: 16.
- `TextButton` — "NEXT WAVE". Size: UDim2(0, 160, 0, 45). BackgroundColor3: Monster Green.
- `TextButton` — "LEAVE ARENA". Size: UDim2(0, 160, 0, 45). BackgroundColor3: Color3(0.3, 0.3, 0.3).

**Defeat:**
- `TextLabel` — "💀 DEFEATED". Font: GothamBold, TextSize: 36. TextColor3: Battle Red.
- `TextLabel` — "You earned 50 Essence for trying!". Font: GothamSemibold, TextSize: 16.
- `TextButton` — "RETRY". BackgroundColor3: Monster Green.
- `TextButton` — "LEAVE". BackgroundColor3: Dark grey.

---

## 6. World Select Map (ScreenGui: "WorldSelectGUI")

Full-screen overlay for viewing and teleporting to zones.

### 6.1 Main Panel
```
Position: UDim2(0.5, -400, 0.5, -300)
Size: UDim2(0, 800, 0, 600)
BackgroundColor3: Panel (Dark Slate)
UICorner: CornerRadius = UDim.new(0, 16)
```

**Title Bar**: "🌍 WORLD MAP". Font: GothamBold, TextSize: 22.

### 6.2 World Cards Area (ScrollingFrame "WorldGrid")
```
Position: UDim2(0, 20, 0.1, 0)
Size: UDim2(1, -40, 0.84, 0)
BackgroundTransparency: 1
ScrollBarThickness: 4
```
- Uses UIGridLayout: CellSize = UDim2(0, 240, 0, 280), CellPadding = UDim2(0, 15, 0, 15)

#### Zone 1: Forest Village (Always Unlocked)
```
BackgroundColor3: Color3(0.10, 0.20, 0.10) — Dark green tint
UICorner: 12px
BorderSizePixel: 2
BorderColor3: Monster Green
```
- `ImageLabel` — Forest landscape icon (green hills, trees). Size: UDim2(1, 0, 0, 140).
- `TextLabel` — "🌲 FOREST VILLAGE". Font: GothamBold, TextSize: 16.
- `TextLabel` — "★ Starting Zone". Font: Gotham, TextSize: 12. TextColor3: Soft Grey.
- `TextLabel` — "Energy Multiplier: 1.0x". Font: Gotham, TextSize: 11. TextColor3: Energy Orange.
- `TextLabel` — "Unlocked ✓". Font: GothamSemibold, TextSize: 13. TextColor3: Monster Green.
- `TextButton` — "TELEPORT". BackgroundColor3: Monster Green. UICorner: 8px.

#### Zone 2: Scorched Desert (Locked: 5,000 Essence)
```
BackgroundColor3: Color3(0.20, 0.12, 0.05) — Desert brown tint
UICorner: 12px
BorderSizePixel: 1
BorderColor3: Color3(0.3, 0.3, 0.3)
```
- `ImageLabel` — Desert landscape icon (sand dunes, ruins).
- `TextLabel` — "🏜️ SCORCHED DESERT". Font: GothamBold, TextSize: 16.
- `TextLabel` — "Requires: 5,000 Essence". Font: Gotham, TextSize: 12. TextColor3: Soft Grey.
- `TextLabel` — "Energy Multiplier: 2.5x". Font: Gotham, TextSize: 11. TextColor3: Energy Orange.
- **Lock Overlay** (Frame): Semi-transparent dark overlay with a lock icon (🔒) centered.
- `TextButton` — "UNLOCK (5,000 Ess)". If player has enough Essence, it's clickable (BackgroundColor3: Secondary Blue). Otherwise greyed out.

#### Zone 3: Cyber City (Locked: 50,000 Essence)
```
BackgroundColor3: Color3(0.05, 0.05, 0.20) — Dark blue cyber tint
UICorner: 12px
BorderSizePixel: 1
BorderColor3: Color3(0.3, 0.3, 0.3)
```
- `ImageLabel` — Cyber city landscape icon (neon towers).
- `TextLabel` — "🏙️ CYBER CITY". Font: GothamBold, TextSize: 16.
- `TextLabel` — "Requires: 50,000 Essence". Font: Gotham, TextSize: 12.
- `TextLabel` — "Energy Multiplier: 5.0x". Font: Gotham, TextSize: 11. TextColor3: Energy Orange.
- Lock overlay + unlock button.

---

## 7. Rank-Up / Rebirth Screen (ScreenGui: "RebirthGUI")

Modal overlay shown when player clicks the "⭐ REBIRTH" button.

### 7.1 Rebirth Panel
```
Position: UDim2(0.5, -300, 0.5, -250)
Size: UDim2(0, 600, 0, 500)
BackgroundColor3: Color3(0.12, 0.08, 0.20) — Dark purple
UICorner: CornerRadius = UDim.new(0, 16)
BorderSizePixel: 2
BorderColor3: Color3(0.80, 0.10, 0.90)  — Purple glow
```

**Title Section:**
- `TextLabel` — "⭐ REBIRTH". Font: GothamBold, TextSize: 28. TextColor3: Color3(0.90, 0.30, 1.0) — Bright purple.
- `TextLabel` — "Prestige to earn permanent multipliers and exclusive rewards!". Font: Gotham, TextSize: 14. TextColor3: Soft Grey.

### 7.2 Current Stats (Frame "CurrentStats")
```
Position: UDim2(0, 30, 0.12, 0)
Size: UDim2(1, -60, 0, 100)
BackgroundColor3: Color3(0.08, 0.08, 0.18)
UICorner: CornerRadius = UDim.new(0, 10)
```
- `TextLabel` — "Current Rank: ★ 3". Font: GothamBold, TextSize: 18. TextColor3: White.
- `TextLabel` — "Essence: 250,000 / 100,000 (can rebirth!)". Font: GothamSemibold, TextSize: 14. TextColor3: (Green if enough, Red if not).
- `TextLabel` — "Current Multiplier: 8x". Font: GothamSemibold, TextSize: 14. TextColor3: Energy Orange.

### 7.3 Rank Rewards Preview (Frame "RankRewards")
```
Position: UDim2(0, 30, 0.35, 0)
Size: UDim2(1, -60, 0, 140)
BackgroundTransparency: 1
```
- `TextLabel` — "Next Rank Rewards:". Font: GothamBold, TextSize: 16. TextColor3: White.
- Reward list (TextLabels, left-aligned):
  ``` 
  ✓ Permanent 2x Essence Multiplier
  ✓ ⭐ Rank ★ 4 Badge
  ✓ Exclusive: "Reborn Slime" Monster
  ✓ +1 Extra Equip Slot
  ```

### 7.4 Rebirth Button
```
Position: UDim2(0.5, -120, 0.78, 0)
Size: UDim2(0, 240, 0, 55)
BackgroundColor3: Color3(0.80, 0.10, 0.90) — Purple
UICorner: CornerRadius = UDim.new(0, 12)
Text: "⭐ REBIRTH NOW"
Font: GothamBold, TextSize: 20
```
- Pulsing animation (BackgroundTransparency tweens: 0 → 0.15 → 0 over 2s loop)
- If player doesn't have enough Essence: greyed out with "Need 100,000 Essence"

### 7.5 Cancel Button
```
Position: UDim2(0.5, -60, 0.9, 0)
Size: UDim2(0, 120, 0, 35)
BackgroundColor3: Color3(0.25, 0.25, 0.35)
UICorner: CornerRadius = UDim.new(0, 8)
Text: "CANCEL"
Font: GothamSemibold, TextSize: 14
```

---

## 8. Interaction Flow Summary

### 8.1 Screen Navigation Flow
```
Main HUD
  ├── Click "SHOP" → ShopGUI (overlay)
  ├── Click "MONSTERS" → InventoryGUI (overlay)
  ├── Click "HATCH" → IncubatorGUI (overlay)
  ├── Click "BATTLE" → BattleGUI (overlay, replaces HUD)
  ├── Click "WORLDS" → WorldSelectGUI (overlay)
  ├── Click "QUESTS" → QuestsGUI (overlay)
  ├── Click "DAILY" → DailyRewardsGUI (overlay)
  ├── Click "⭐ REBIRTH" → RebirthGUI (overlay)
  ├── Click "⚙️" → SettingsGUI (small modal)
  ├── Click "🎁" → CodesGUI (small modal)
  ├── Click "📺" → RewardAd (triggers ad, no overlay)
  └── Click "👑 GET VIP" → ShopGUI → VIP card focus
```

### 8.2 Open/Close Patterns
- **Open menu:** Set menu's `ScreenGui.Enabled = true`. Pause passive interactions behind it (click area disabled).
- **Close menu:** Click "✕" button OR click the transparent overlay background. Set `ScreenGui.Enabled = false`.
- **Multiple menus:** Only one overlay at a time. Closing current returns to HUD.

### 8.3 HUD Update Events
These UI elements update via BindToClose / RemoteEvent callbacks:
| UI Element              | Trigger                   | Update                        |
|-------------------------|---------------------------|-------------------------------|
| EnergyCounter TextLabel | CollectEnergy response    | Instant update                |
| EssenceCounter TextLabel | Passive EPS tick (1s)    | Tween to new value (0.3s)    |
| EquippedBar             | EquipMonster event        | Refresh slot display          |
| PlayerRank TextLabel    | Rebirth complete          | Update rank number            |
| WaveInfo TextLabel      | Battle wave change        | Update wave count             |

---

## 9. Recommended UI Scripts (For Engineer)

### 9.1 Modules
- `UIController.lua` — Manages open/close state of all GUIs, prevents overlapping menus
- `HUDUpdater.lua` — Listens to RemoteEvents and updates stat displays with tweens
- `IncubatorController.lua` — Handles egg selection, hatch animation sequence, reveal
- `ShopController.lua` — Processes purchase requests via RemoteFunction, shows confirmation modals
- `BattleUIController.lua` — Manages wave timing, damage numbers, HP bars, victory/defeat screens
- `WorldSelectController.lua` — Handles zone unlock checks and teleport requests
- `DailyRewardsController.lua` — Manages daily reward state, claim logic, calendar UI updates
- `QuestsController.lua` — Manages quest progress tracking, claim/redeem flows
- `VIPController.lua` — Handles VIP badge visibility, BillboardGui name tag, multiplier activation
- `AdController.lua` — Handles reward ad requests, cooldown timers, reward distribution
- `PurchaseController.lua` — Handles purchase confirmation flow, MarketplaceService interaction

### 9.2 Animation Utilities
- `TweenService:Create()` for all UI transitions (buttons, panels, health bars, hatch sequences)
- Debounce on all action buttons (minimum 0.5s between clicks to prevent spam)
- All animations < 0.5s for snappy feel (except hatch animation: ~2.5s for drama)

---

## 10. Accessibility & UX Notes
- **Text Size Minimum:** 11px for body text (Roblox TextSize). Headers 16-36px.
- **Touch Targets:** All buttons minimum 40x40px (Roblox recommends 44x44 for mobile).
- **Mobile Support:** All positions use UDim2 Scale + Offset. Buttons placed for thumb-zone access (bottom half of screen).
- **Color Blindness:** Rarity is communicated by both color AND symbol (★ Common, ◆ Rare, ● Epic, ▲ Legendary, ✦ Mythical). Energy ≠ Essence via distinct icons.
- **Loading States:** "..." text shown on buttons while RemoteFunction awaits server response.

---

*End of UI Specifications. All dimensions use Roblox UDim2 format for direct implementation.*
