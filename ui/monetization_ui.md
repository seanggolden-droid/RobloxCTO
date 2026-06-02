# Monetization UI Specifications: Monster Mash Simulator

## Overview
This document specifies all monetization-related UI screens: Daily Rewards, Quests, VIP display, enhanced Rebirth/Rank-Up, reward-ad buttons, and updated Shop purchase flows. These are additional screens/features that integrate into the existing UI specifications at `/home/team/shared/games/monster-mash/ui/ui_specs.md`.

All specs follow the same design system defined in the main specs:
- **Color Palette**: Monster Green (#33C84D), Sky Blue (#338CFF), Energy Orange (#FF8C1A), Deep Navy (#0F0F1F), Dark Slate (#1E1E38)
- **Fonts**: GothamBold (headers), GothamSemibold (body), Gotham (details)
- **Corner Radii**: Buttons 8px, Panels 12px, Progress bars 4px
- **Rarity Colors**: Common (#999999), Rare (#3366FF), Epic (#9933E6), Legendary (#FFCC1A), Mythical (#FF1A4D)

---

## 1. Daily Rewards Calendar (ScreenGui: "DailyRewardsGUI")

Full-screen overlay for claiming daily login rewards. Accessible from a new "🎁 Daily" button on the HUD (replacing or next to the Codes button).

### 1.1 Background Overlay
```
Position: UDim2(0, 0, 0, 0)
Size: UDim2(1, 0, 1, 0)
BackgroundColor3: Color3(0, 0, 0)
BackgroundTransparency: 0.45
```
- On click (if not claiming): closes the Daily Rewards GUI

### 1.2 Main Panel (Frame "DailyPanel")
```
Position: UDim2(0.5, -350, 0.5, -280)
Size: UDim2(0, 700, 0, 560)
BackgroundColor3: Panel (Dark Slate)
UICorner: CornerRadius = UDim.new(0, 16)
BorderSizePixel: 1
BorderColor3: Color3(0.20, 0.20, 0.35)
```

**Title Bar** (Frame "DailyTitleBar")
```
Position: UDim2(0, 0, 0, 0)
Size: UDim2(1, 0, 0, 55)
BackgroundColor3: Color3(0.08, 0.08, 0.18)
UICorner: CornerRadius = UDim.new(16, 16)
```
- `ImageLabel` — Gift/calendar icon (left). Size: UDim2(0, 36, 0, 36). Position: UDim2(0.02, 0, 0.5, -18).
- `TextLabel` — "🎁 DAILY REWARDS". Font: GothamBold, TextSize: 22, TextColor3: White. Position: UDim2(0.5, -100, 0.5, -11).
- `TextLabel` — "Day 3 of 7". Font: GothamSemibold, TextSize: 14, TextColor3: Energy Orange. Position: UDim2(0.5, 40, 0.5, -7).
- `TextButton` — "✕" close. Position: UDim2(1, -40, 0.5, -15). Size: UDim2(0, 30, 0, 30). TextColor3: Soft Grey.

### 1.3 Streak Counter (Frame "StreakCounter")
```
Position: UDim2(0, 30, 0.12, 0)
Size: UDim2(1, -60, 0, 40)
BackgroundColor3: Color3(0.10, 0.10, 0.20)
UICorner: CornerRadius = UDim.new(0, 8)
```
- `TextLabel` — "🔥 Current Streak: 3 days". Font: GothamSemibold, TextSize: 14. TextColor3: White. Position: UDim2(0.02, 0, 0.5, -7).
- `TextLabel` — "Don't miss a day!". Font: Gotham, TextSize: 12. TextColor3: Soft Grey. Position: UDim2(0.45, 0, 0.5, -6).

### 1.4 Calendar Grid (Frame "CalendarGrid")
```
Position: UDim2(0.5, -300, 0.22, 0)
Size: UDim2(0, 600, 0, 340)
BackgroundTransparency: 1
```
Contains 7 day cards arranged in a horizontal grid (UIListLayout, FillDirection=Horizontal, Padding=8px, Wrap=True with 4 per row). Layout: two rows of 3 cards + 1 card centered on row 3. OR simpler: single scrollable row using ScrollingFrame.

**Better layout: 7 cards in a flexible grid**
Uses UIGridLayout:
```
CellSize: UDim2(0, 130, 0, 150)
CellPadding: UDim2(0, 12, 0, 12)
FillDirection: Horizontal
StartCorner: TopLeft
```

**Each Day Card** (Frame "DayCard1" through "DayCard7")
```
Size: UDim2(0, 130, 0, 150)
BackgroundColor3: Color3(0.15, 0.15, 0.25)
UICorner: CornerRadius = UDim.new(0, 10)
```

**Day Card States (3 visual states):**

#### State A: Current Day (Available to claim)
```
BorderSizePixel: 2
BorderColor3: Monster Green
```
- `Frame` — Pulsing glow ring. Size: UDim2(1, 4, 1, 4). Position: UDim2(-2, 0, -2, 0). BackgroundTransparency: 0.8. BackgroundColor3: Monster Green.
  - **Animation:** BackgroundTransparency tweens 0.8 → 0.6 → 0.8 over 1.5s loop (TweenService)
- `Frame` — Day number badge. Position: UDim2(0.5, -16, 0.04, 0). Size: UDim2(0, 32, 0, 22). BackgroundColor3: Monster Green. UICorner: 4px.
  - `TextLabel` — "DAY 3". Font: GothamBold, TextSize: 11. TextColor3: White.
- `ImageLabel` — Reward icon (lightning bolt for Energy, crystal for Essence, egg for Egg). Size: UDim2(0, 60, 0, 60). Position: UDim2(0.5, -30, 0.25, 0).
- `TextLabel` — Reward amount (e.g., "+500 Energy"). Font: GothamSemibold, TextSize: 13. TextColor3: Energy Orange. Position: UDim2(0, 5, 0, 95). Size: UDim2(1, -10, 0, 18).
- `TextLabel` — Reward description (e.g., "Energy Boost!"). Font: Gotham, TextSize: 10. TextColor3: Soft Grey. Position: UDim2(0, 5, 0, 112).
- `TextButton` — "CLAIM". Size: UDim2(0.8, 0, 0, 28). Position: UDim2(0.1, 0, 0.82, 0). BackgroundColor3: Monster Green. UICorner: 6px. Font: GothamBold, TextSize: 12.

#### State B: Already Claimed
```
BorderSizePixel: 1
BorderColor3: Color3(0.20, 0.20, 0.30)
BackgroundTransparency: 0.3
```
- `ImageLabel` — Checkmark overlay (✓). Size: UDim2(0, 30, 0, 30). Position: UDim2(0.75, 0, 0, 5).
- `Frame` — Day number badge. BackgroundColor3: Color3(0.20, 0.20, 0.30). 
- `ImageLabel` — Reward icon. Dimmed (ImageTransparency: 0.4).
- `TextLabel` — "Claimed ✓". Font: Gotham, TextSize: 11. TextColor3: Monster Green. Position: UDim2(0, 5, 0, 112).
- `TextButton` — "CLAIMED". BackgroundColor3: Color3(0.15, 0.15, 0.25). TextTransparency: 0.5. Disabled state.

#### State C: Locked (Future day)
```
BorderSizePixel: 1
BorderColor3: Color3(0.2, 0.2, 0.3)
```
- `ImageLabel` — Lock icon (🔒). Size: UDim2(0, 20, 0, 20). Position: UDim2(0.75, 0, 0, 5).
- `Frame` — Day number badge. BackgroundColor3: Color3(0.20, 0.20, 0.30).
- `ImageLabel` — Reward icon. Dimmed (ImageTransparency: 0.5).
- `TextLabel` — "???". Font: Gotham, TextSize: 11. TextColor3: Soft Grey.

#### Day Reward Schedule (Design Reference)
| Day | Reward Type         | Amount       | Icon          |
|-----|---------------------|--------------|---------------|
| 1   | Energy              | 500          | ⚡ Lightning  |
| 2   | Essence             | 250          | 💎 Crystal    |
| 3   | Common Egg          | 1            | 🥚 Egg        |
| 4   | Energy              | 1,000        | ⚡ Lightning  |
| 5   | Essence             | 500          | 💎 Crystal    |
| 6   | Rare Egg            | 1            | 🥚 Blue Egg   |
| 7   | Legendary Egg       | 1            | 🥇 Gold Egg   |

### 1.5 Bottom Bar (Frame "DailyBottomBar")
```
Position: UDim2(0, 0, 1, -60)
Size: UDim2(1, 0, 0, 60)
BackgroundColor3: Color3(0.08, 0.08, 0.18)
UICorner: CornerRadius = UDim.new(16, 16)
```
- `TextLabel` — "🎁 Bonus: Claim all 7 days for a FREE Legendary Egg!". Font: GothamSemibold, TextSize: 13. TextColor3: Legendary Gold. Position: UDim2(0.5, -200, 0.5, -7).
- `TextButton` — "CLAIM ALL (if available)". Only visible if player hasn't claimed today and has multiple days stacked up. BackgroundColor3: Legendary Gold. TextColor3: Black. UICorner: 8px. Size: UDim2(0, 140, 0, 36).

---

## 2. Quests Panel (ScreenGui: "QuestsGUI")

Full-screen overlay for viewing and tracking active quests. Accessible from a new "📋 Quests" button on the HUD (add to left nav bar).

### 2.1 Main Panel
```
Position: UDim2(0.5, -400, 0.5, -300)
Size: UDim2(0, 800, 0, 600)
BackgroundColor3: Panel (Dark Slate)
UICorner: CornerRadius = UDim.new(0, 16)
```

**Title Bar** (Frame "QuestsTitleBar")
```
Position: UDim2(0, 0, 0, 0)
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Color3(0.08, 0.08, 0.18)
UICorner: CornerRadius = UDim.new(16, 16)
```
- `TextLabel` — "📋 QUESTS". Font: GothamBold, TextSize: 22. TextColor3: White. Position: UDim2(0.5, -60, 0.5, -11).
- `TextButton` — "✕" close button.

### 2.2 Tab Bar (Frame "QuestTabs")
```
Position: UDim2(0, 20, 0.09, 0)
Size: UDim2(1, -40, 0, 35)
BackgroundTransparency: 1
```
Two tabs side by side:

- **"DAILY"** (TextButton) — Active by default. Size: UDim2(0.5, -4, 1, 0). BackgroundColor3: Monster Green. UICorner: 8px. Font: GothamBold, TextSize: 14.
- **"WEEKLY"** (TextButton) — Inactive. Size: UDim2(0.5, 4, 1, 0). Position: UDim2(0.5, 0, 0, 0). BackgroundColor3: Color3(0.2, 0.2, 0.3). UICorner: 8px.

### 2.3 Progress Summary (Frame "QuestSummary")
```
Position: UDim2(0, 30, 0.16, 0)
Size: UDim2(1, -60, 0, 50)
BackgroundColor3: Color3(0.10, 0.10, 0.20)
UICorner: CornerRadius = UDim.new(0, 8)
```
- `TextLabel` — "Daily Progress: 2/5 completed". Font: GothamSemibold, TextSize: 14. TextColor3: White. Position: UDim2(0.02, 0, 0.2, 0).
- **Progress Bar** (Frame "QuestProgressBar")
  ```
  Position: UDim2(0.02, 0, 0.55, 0)
  Size: UDim2(0.96, 0, 0, 12)
  BackgroundColor3: Color3(0.20, 0.20, 0.30)
  UICorner: CornerRadius = UDim.new(0, 6)
  ```
  - `Frame` — Progress fill. BackgroundColor3: Monster Green. Size: UDim2(0.4, 0, 1, 0). UICorner: 6px. (Dynamically sized based on completion.)
  - `TextLabel` — "40%". Font: GothamBold, TextSize: 9. TextColor3: White. Position: UDim2(0.5, -10, 0.5, -4).

### 2.4 Quest List (ScrollingFrame "QuestList")
```
Position: UDim2(0, 30, 0.25, 0)
Size: UDim2(1, -60, 0.68, 0)
BackgroundTransparency: 1
ScrollBarThickness: 4
CanvasSize: UDim2(0, 0, 3, 0)  — Dynamically sized
```
- UIListLayout: FillDirection=Vertical, Padding=10px

**Each Quest Card** (Frame "QuestCard")
```
Size: UDim2(1, 0, 0, 90)
BackgroundColor3: Color3(0.15, 0.15, 0.25)
UICorner: CornerRadius = UDim.new(0, 10)
```

**Card elements:**
- `Frame` — Completion indicator (left strip). Size: UDim2(0, 6, 1, 0). BackgroundColor3: (Energy Orange if in-progress, Monster Green if completed, Color3(0.3,0.3,0.3) if not started). UICorner: 10px (left corners only).
- `ImageLabel` — Quest icon (custom per quest type). Size: UDim2(0, 44, 0, 44). Position: UDim2(0, 18, 0.5, -22).
- `TextLabel` — Quest title (e.g., "Energy Collector"). Font: GothamBold, TextSize: 15. TextColor3: White. Position: UDim2(0, 72, 0, 10). Size: UDim2(0.6, 0, 0, 20).
- `TextLabel` — Quest description (e.g., "Collect 1,000 Energy from crystals"). Font: Gotham, TextSize: 12. TextColor3: Soft Grey. Position: UDim2(0, 72, 0, 32). Size: UDim2(0.6, 0, 0, 18).
- **Progress Bar** (Frame "QuestProgress")
  ```
  Position: UDim2(0, 72, 0, 56)
  Size: UDim2(0.5, 0, 0, 10)
  BackgroundColor3: Color3(0.20, 0.20, 0.30)
  UICorner: CornerRadius = UDim.new(0, 5)
  ```
  - `Frame` — Fill. BackgroundColor3: (Energy Orange if in-progress, Monster Green if completed). Size: dynamic. UICorner: 5px.
  - `TextLabel` — "527 / 1,000". Font: GothamSemibold, TextSize: 9. Position: UDim2(1.02, 0, 0.5, -4). TextColor3: Soft Grey.
- `TextButton` — "CLAIM" (if completed) / "GO" (if in-progress) / "—" (locked).
  - **"CLAIM"** : BackgroundColor3: Monster Green. UICorner: 8px. Font: GothamBold, TextSize: 13. Size: UDim2(0, 80, 0, 32). Position: UDim2(1, -90, 0.5, -16). Visible only when progress >= target.
  - **"GO"** : BackgroundColor3: Secondary (Sky Blue). Same size/position. Navigates player toward quest objective.
  - **Completed with reward claimed**: BackgroundColor3: Color3(0.15,0.15,0.25). Text: "✓". Disabled.

**Quest Reward Display** (Frame within card):
```
Position: UDim2(1, -100, 0.08, 0)
Size: UDim2(0, 85, 0, 28)
BackgroundColor3: Color3(0.10, 0.10, 0.20)
UICorner: CornerRadius = UDim.new(0, 6)
```
- `ImageLabel` — Reward icon (small). Size: UDim2(0, 20, 0, 20). Position: UDim2(0, 4, 0.5, -10).
- `TextLabel` — Reward amount (e.g., "+200 Essence"). Font: GothamSemibold, TextSize: 10. TextColor3: Soft Grey. Position: UDim2(0, 28, 0.5, -5).

### 2.5 Quest Types (Design Reference)
| # | Quest Name              | Objective                        | Reward              | Type   |
|---|-------------------------|----------------------------------|---------------------|--------|
| 1 | Energy Collector        | Collect 1,000 Energy             | 200 Essence         | Daily  |
| 2 | Monster Breeder         | Hatch 3 Eggs                     | Common Egg         | Daily  |
| 3 | Battler                 | Win 3 Arena Waves                | 300 Essence        | Daily  |
| 4 | Explorer                | Visit 2 Zones                    | 150 Energy         | Daily  |
| 5 | Evolutionist           | Evolve 1 Monster                 | Rare Egg           | Daily  |
| 6 | Essence Hoarder (W)     | Earn 10,000 Essence              | 500 Energy + Egg   | Weekly |
| 7 | Arena Champion (W)      | Win 20 Waves                     | Legendary Egg      | Weekly |
| 8 | Monster Collector (W)   | Collect 10 Unique Monsters       | 1,000 Essence      | Weekly |

---

## 3. VIP Badge Display

### 3.1 VIP Indicator on Main HUD

**New element added to the Top Bar** — replaces or sits next to the PlayerRank badge.

**Option A: Separate VIP badge** (Frame "VIPBadge") — Shown only if player owns VIP pass.
```
Position: UDim2(0.98, -290, 0, 10)
Size: UDim2(0, 140, 0, 40)
BackgroundColor3: Color3(0, 0, 0)
BackgroundTransparency: 0.5
UICorner: CornerRadius = UDim.new(0, 8)
BorderSizePixel: 2
BorderColor3: Legendary Gold
```
- `ImageLabel` — Crown icon. Size: UDim2(0, 28, 0, 28). Position: UDim2(0, 6, 0.5, -14).
- `TextLabel` — "VIP". Font: GothamBold, TextSize: 14. TextColor3: Legendary Gold. Position: UDim2(0, 38, 0, 4).
- `TextLabel` — "1.5x Essence". Font: Gotham, TextSize: 10. TextColor3: Soft Grey. Position: UDim2(0, 38, 0, 22).

**Option B: Non-VIP prompt** — Shown if player does NOT own VIP.
```
Position: UDim2(0.98, -290, 0, 10)
Size: UDim2(0, 140, 0, 40)
BackgroundColor3: Color3(0, 0, 0)
BackgroundTransparency: 0.5
UICorner: CornerRadius = UDim.new(0, 8)
```
- `TextButton` — "👑 GET VIP". Font: GothamBold, TextSize: 14. TextColor3: Legendary Gold. BackgroundTransparency: 1. Size: UDim2(1, 0, 1, 0).
  - On click: Opens ShopGUI and switches to Game Passes tab, scrolls to VIP card automatically.

### 3.2 VIP Name Tag (3D BillboardGui)

Attached to player's character head. Only visible if player owns VIP pass.
```
Adornee: Player's Head
Size: UDim2(0, 6, 0, 1.5)  — Stud size
StudsOffset: Vector3.new(0, 3, 0)
```
- `Frame` — Background. BackgroundColor3: Color3(0.12, 0.08, 0.20). BackgroundTransparency: 0.2. UICorner: 4px. Size: UDim2(1, 0, 1, 0).
- `TextLabel` — "👑 [PlayerName] ★ VIP". Font: GothamBold, TextSize: 14. TextColor3: Legendary Gold. TextStrokeTransparency: 0.3. TextStrokeColor3: Color3(0, 0, 0).
- ParticleEmitter around the badge (small gold sparkles) for premium feel.

### 3.3 VIP Shop Card Highlight Enhancement

The VIP Game Pass card in the Shop should have special effects:
- Pulsing gold border (BorderTransparency: 0 → 0.5 → 0 over 2s loop)
- Small sparkle ImageLabel overlays (Image: sparkle texture, cycling)
- Badge: "BEST VALUE" ribbon in top-right corner
- Large "👑" crown icon at the top

---

## 4. Enhanced Rebirth / Rank-Up Screen Updates

The existing Rebirth screen (ui_specs.md Section 7) is extended with the following enhancements:

### 4.1 Milestone Progress Bar (Add to "CurrentStats" frame)

Replace the static Essence text with a proper progress bar:

**Progress Bar Frame** (Frame "RankProgressBar") — added below the Essence text:
```
Position: UDim2(0, 10, 0, 65)
Size: UDim2(1, -20, 0, 20)
BackgroundColor3: Color3(0.20, 0.20, 0.30)
UICorner: CornerRadius = UDim.new(0, 10)
```
- `Frame` — Progress fill. BackgroundColor3: Color3(0.80, 0.10, 0.90) — Rebirth Purple. Size: UDim2(PERCENT, 0, 1, 0). UICorner: 10px.
  - Where PERCENT = currentEssence / requiredEssence (clamped to 1.0)
  - **Tween animation** on open: fill animates from 0 to PERCENT over 0.5s
- `TextLabel` — "250,000 / 100,000". Font: GothamBold, TextSize: 12. TextColor3: White. Position: UDim2(0.5, -50, 0.5, -6).
- `Frame` — Milestone indicators (small diamond markers at 25%, 50%, 75%, 100% positions along the bar).
  ```
  Size: UDim2(0, 6, 0, 14)
  BackgroundColor3: Color3(0.80, 0.10, 0.90)
  UICorner: CornerRadius = UDim.new(0, 3)
  ```

### 4.2 Milestone Rewards (Frame "MilestoneRewards")

New section below the progress bar showing milestone rewards:
```
Position: UDim2(0, 30, 0.48, 0)
Size: UDim2(1, -60, 0, 75)
BackgroundTransparency: 1
```
- `TextLabel` — "Milestone Rewards:". Font: GothamBold, TextSize: 14. TextColor3: Soft Grey.
- Horizontal row of 3 milestone reward icons (UIListLayout, Horizontal, Padding 15px):

**Each Milestone** (Frame "Milestone1/2/3"):
```
Size: UDim2(0, 120, 0, 50)
BackgroundColor3: Color3(0.10, 0.10, 0.20)
UICorner: CornerRadius = UDim.new(0, 8)
```
- `ImageLabel` — Reward icon. Size: UDim2(0, 28, 0, 28). Position: UDim2(0, 6, 0.5, -14).
- `TextLabel` — Reward text (e.g., "5,000 Energy"). Font: GothamSemibold, TextSize: 11. TextColor3: White. Position: UDim2(0, 40, 0, 6).
- `TextLabel` — Progress (e.g., "25%"). Font: Gotham, TextSize: 10. TextColor3: Monster Green. Position: UDim2(0, 40, 0, 26).
- Completed milestones show a checkmark overlay. Locked milestones show lock icon.

### 4.3 Rank History Section (Frame "RankHistory")
```
Position: UDim2(0, 30, 0.62, 0)
Size: UDim2(1, -60, 0, 55)
BackgroundColor3: Color3(0.08, 0.08, 0.18)
UICorner: CornerRadius = UDim.new(0, 8)
```
- `TextLabel` — "Rank History:". Font: GothamBold, TextSize: 13. TextColor3: Soft Grey. Position: UDim2(0, 10, 0, 6).
- `TextLabel` — "★ 1 → ★ 2 → ★ 3 → ★ 4 (Next)". Font: GothamSemibold, TextSize: 12. TextColor3: White. Position: UDim2(0, 10, 0, 28).
  - Current rank is highlighted in Legendary Gold.
  - Next rank pulses gently.

---

## 5. Reward-Ad Buttons

Small unobtrusive buttons that trigger Roblox rewarded video ads, giving players free in-game currency/items. Multiple placements:

### 5.1 HUD Ad Button (Frame "AdButton")

New floating button on the main HUD:
```
Position: UDim2(0.85, -65, 0.03, 0)
Size: UDim2(0, 60, 0, 30)
BackgroundColor3: Color3(0.15, 0.15, 0.25)
UICorner: CornerRadius = UDim.new(0, 8)
```
- `ImageLabel` — Play icon (▶). Size: UDim2(0, 16, 0, 16). Position: UDim2(0, 6, 0.5, -8).
- `TextLabel` — "📺 AD". Font: GothamSemibold, TextSize: 11. TextColor3: Soft Grey. Position: UDim2(0, 24, 0.5, -6).
- **Tooltip** (on hover/tap): "Watch an ad to earn bonus Energy!"
- On click: Fires RemoteEvent `RequestRewardAd`. On success, shows brief reward toast.

### 5.2 Incubator Free Egg Ad Button

Add to the Incubator GUI (bottom of egg selection):
```
Position: UDim2(0, 20, 0.72, 0)
Size: UDim2(1, -40, 0, 45)
BackgroundColor3: Color3(0.10, 0.10, 0.20)
UICorner: CornerRadius = UDim.new(0, 8)
```
- `ImageButton` — "📺 Watch Ad for a Free Common Egg!". Size: UDim2(1, 0, 1, 0). BackgroundTransparency: 1.
  - Font: GothamSemibold, TextSize: 13. TextColor3: Monster Green.
  - Shows cooldown timer if recently used ("Available in 5:00" in red).

### 5.3 Battle Retry Ad Button

Add to the Battle Defeat screen (next to RETRY button):
```
Position: UDim2(0.5, -100, 0.6, 0)
Size: UDim2(0, 200, 0, 36)
BackgroundColor3: Color3(0.30, 0.15, 0.50) — Deep Purple
UICorner: CornerRadius = UDim.new(0, 8)
Text: "📺 Watch Ad → 2x Essence"
Font: GothamBold, TextSize: 13
```
- On click: Fires `RequestRewardAd`. On ad completion, doubles the Essence earned from that battle.

### 5.4 Shop Free Energy Ad Button

Add to the Currency tab in the Shop:
```
Size: UDim2(0, 260, 0, 120)
BackgroundColor3: Color3(0.12, 0.12, 0.20)
UICorner: 12px
BorderSizePixel: 1
BorderColor3: Color3(0.30, 0.30, 0.40)
```
- `ImageLabel` — Lightning bolt with play icon. Size: UDim2(0, 50, 0, 50). Centered top.
- `TextLabel` — "📺 FREE ENERGY". Font: GothamBold, TextSize: 15. TextColor3: Energy Orange.
- `TextLabel` — "Watch an ad to get 250 Energy". Font: Gotham, TextSize: 11. TextColor3: Soft Grey.
- `TextButton` — "WATCH AD". BackgroundColor3: Energy Orange. UICorner: 8px. Font: GothamBold, TextSize: 13.

### 5.5 Ad Reward Toast Notification

Brief floating notification that appears when an ad completes successfully:
```
Position: UDim2(0.5, -150, 0.5, -30)
Size: UDim2(0, 300, 0, 60)
BackgroundColor3: Color3(0.08, 0.15, 0.08)
BorderSizePixel: 2
BorderColor3: Monster Green
UICorner: CornerRadius = UDim.new(0, 10)
```
- `TextLabel` — "🎉 Reward Earned!". Font: GothamBold, TextSize: 16. TextColor3: Monster Green. Position: UDim2(0.5, -70, 0, 6).
- `TextLabel` — "+250 Energy from ad reward!". Font: GothamSemibold, TextSize: 13. TextColor3: White. Position: UDim2(0.5, -90, 0, 30).
- **Auto-dismiss** after 3 seconds via TweenService (fade out: BackgroundTransparency 0 → 1 over 0.5s)

---

## 6. Updated Shop UI with Purchase Flows

The existing Shop (Section 4 of main ui_specs.md) is enhanced with detailed purchase flows.

### 6.1 Purchase Confirmation Modal (Frame "PurchaseConfirm")

Shown when player clicks "BUY" on any shop item. Full-screen dark overlay + centered confirmation panel.

**Confirmation Panel** (Frame "ConfirmPanel")
```
Position: UDim2(0.5, -250, 0.5, -180)
Size: UDim2(0, 500, 0, 360)
BackgroundColor3: Panel (Dark Slate)
UICorner: CornerRadius = UDim.new(0, 16)
```

**Product Preview Section** (Frame "ProductPreview")
```
Position: UDim2(0, 0, 0, 0)
Size: UDim2(1, 0, 0, 140)
BackgroundColor3: Color3(0.08, 0.08, 0.18)
UICorner: CornerRadius = UDim.new(16, 16)
```
- `ImageLabel` — Large product icon. Size: UDim2(0, 80, 0, 80). Position: UDim2(0.5, -40, 0.15, 0).
- `TextLabel` — Product name (e.g., "⚡ DOUBLE ENERGY"). Font: GothamBold, TextSize: 20. TextColor3: [product's accent color]. Position: UDim2(0.5, -120, 0.62, 0).
- `TextLabel` — "Game Pass". Font: Gotham, TextSize: 12. TextColor3: Soft Grey. Position: UDim2(0.5, -35, 0.78, 0).

**Product Details Section** (Frame "ProductDetails")
```
Position: UDim2(0, 30, 0.35, 0)
Size: UDim2(1, -60, 0, 80)
BackgroundTransparency: 1
```
- `TextLabel` — Description (e.g., "Collect 2x Energy from all sources including clicking, crystals, and passive generation!"). Font: Gotham, TextSize: 13. TextColor3: White. TextWrapped: True. Size: UDim2(1, 0, 0, 40).
- `TextLabel` — "⚠️ This is a one-time purchase. Stacks with other multipliers.". Font: Gotham, TextSize: 11. TextColor3: Soft Grey. Position: UDim2(0, 0, 0.55, 0). TextWrapped: True.

**Price & Action Row** (Frame "ActionRow")
```
Position: UDim2(0, 30, 0.62, 0)
Size: UDim2(1, -60, 0, 55)
BackgroundTransparency: 1
```
- `TextLabel` — "400 Robux". Font: GothamBold, TextSize: 22. TextColor3: Gold (robux color). Position: UDim2(0, 0, 0.2, 0).
- `TextButton` — "PURCHASE". Position: UDim2(1, -140, 0.5, -22). Size: UDim2(0, 140, 0, 44). BackgroundColor3: Monster Green. UICorner: 10px. Font: GothamBold, TextSize: 16.
  - On click: Fires RemoteFunction `ProcessPurchase(productId)`.
  - While processing: Text changes to "..." and button becomes disabled (BackgroundTransparency: 0.5).
- `TextButton` — "CANCEL". Position: UDim2(1, -160, 0.5, -22). Size: UDim2(0, 90, 0, 44). BackgroundColor3: Color3(0.25, 0.25, 0.35). UICorner: 8px. Font: GothamSemibold, TextSize: 14. TextColor3: Soft Grey.

### 6.2 Purchase Success / Failure Feedback

#### Success Screen (Frame "PurchaseSuccess")
*Replaces the confirmation panel on success.*
```
Position: UDim2(0.5, -250, 0.5, -120)
Size: UDim2(0, 500, 0, 240)
BackgroundColor3: Color3(0.08, 0.15, 0.08)
UICorner: CornerRadius = UDim.new(0, 16)
BorderSizePixel: 2
BorderColor3: Monster Green
```
- `TextLabel` — "✅ PURCHASE SUCCESSFUL!". Font: GothamBold, TextSize: 24. TextColor3: Monster Green. Position: UDim2(0.5, -140, 0.15, 0).
- `TextLabel` — "Double Energy is now active!". Font: GothamSemibold, TextSize: 16. TextColor3: White. Position: UDim2(0.5, -120, 0.38, 0).
- `ImageLabel` — Checkmark animation (large ✓). Size: UDim2(0, 60, 0, 60). Position: UDim2(0.5, -30, 0.55, 0).
- `TextButton` — "AWESOME!". Position: UDim2(0.5, -70, 0.8, 0). Size: UDim2(0, 140, 0, 40). BackgroundColor3: Monster Green. UICorner: 10px. Font: GothamBold, TextSize: 16.
  - On click: Closes the confirm modal. Marks item as "Owned" in the Shop grid.

#### Failure Screen (Frame "PurchaseFailed")
*Shown if Roblox purchase fails or is cancelled.*
```
Position: UDim2(0.5, -250, 0.5, -120)
Size: UDim2(0, 500, 0, 240)
BackgroundColor3: Color3(0.15, 0.08, 0.08)
UICorner: CornerRadius = UDim.new(0, 16)
BorderSizePixel: 2
BorderColor3: Battle Red
```
- `TextLabel` — "❌ PURCHASE FAILED". Font: GothamBold, TextSize: 24. TextColor3: Battle Red. Position: UDim2(0.5, -120, 0.15, 0).
- `TextLabel` — "The transaction was cancelled or could not be completed.". Font: GothamSemibold, TextSize: 14. TextColor3: Soft Grey. Position: UDim2(0.5, -160, 0.38, 0). TextWrapped: True.
- `TextButton` — "TRY AGAIN". Position: UDim2(0.5, -160, 0.68, 0). Size: UDim2(0, 140, 0, 40). BackgroundColor3: Monster Green. UICorner: 10px.
- `TextButton` — "CANCEL". Position: UDim2(0.5, 10, 0.68, 0). Size: UDim2(0, 140, 0, 40). BackgroundColor3: Color3(0.25, 0.25, 0.35). UICorner: 10px.

### 6.3 Owned State for Shop Cards

For items the player already owns, the shop card should show:

**"OWNED" Badge** (Frame "OwnedBadge")
```
Position: UDim2(0.75, 0, 0.05, 0)
Size: UDim2(0, 65, 0, 22)
BackgroundColor3: Color3(0.10, 0.40, 0.10)
UICorner: CornerRadius = UDim.new(0, 6)
```
- `TextLabel` — "✓ OWNED". Font: GothamBold, TextSize: 10. TextColor3: Monster Green.

**BUY button replaced with:**
- `TextButton` — "✓ OWNED". BackgroundColor3: Color3(0.15, 0.15, 0.25). TextColor3: Monster Green. Disabled state. BorderSizePixel: 1. BorderColor3: Monster Green.

### 6.4 Real Purchase Flow Sequence
```
1. Player clicks "BUY" on shop card
   → Shop item card highlights briefly (scale 1→1.05→1, 0.2s)
   
2. Purchase confirmation modal appears (PurchaseConfirm)
   → Shows product name, icon, full description, price
   → "PURCHASE" button + "CANCEL" button
   
3a. Player clicks "PURCHASE"
    → Button text changes to "..."
    → Button becomes disabled (greyed out)
    → Fires RemoteFunction("ProcessPurchase", productId)
    
    → Server calls MarketplaceService:PromptPurchase(player, productId)
    → Robux purchase popup appears (Roblox native)
    
    → On success (ProcessReceipt callback returns Enum.ProductPurchaseDecision.PurchaseGranted):
      → PurchaseSuccess screen shown
      → Product added to player's owned list
      → HUD updates (e.g., Energy counter increases)
      → Server saves to DataStore
      
    → On failure/cancellation:
      → PurchaseFailed screen shown
      → Player can retry or cancel
      
3b. Player clicks "CANCEL"
    → Modal closes, returns to Shop grid
```

---

## 7. HUD Integration Plan

### 7.1 New HUD Button Additions

Add to the left navigation bar (increasing its height for the new buttons):

**Quests Button** (ImageButton "BtnQuests")
```
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Color3(0.90, 0.55, 0.10)  — Warm Orange
UICorner: CornerRadius = UDim.new(0, 8)
Text: "📋 QUESTS"
Font: GothamBold, TextSize: 16, TextColor3: White
```

**Daily Rewards Button** (ImageButton "BtnDailyRewards")
```
Size: UDim2(1, 0, 0, 50)
BackgroundColor3: Color3(0.60, 0.20, 0.80)  — Purple
UICorner: CornerRadius = UDim.new(0, 8)
Text: "🎁 DAILY"
Font: GothamBold, TextSize: 16, TextColor3: White
```

**Updated left nav bar total height:** 7 buttons × 50px + 6 gaps × 8px = 398px (was 260px for 5 buttons), requiring position adjustment:
```
Position: UDim2(0.01, 0, 0.25, 0)
Size: UDim2(0, 180, 0, 398)
```

### 7.2 VIP / Ad Button in Top Bar Area

The Top Bar gets a new section between Rank and Settings:

**Ad Button** (ImageButton "BtnAd") — Next to Codes on right side
```
Position: UDim2(0.98, -45, 0.02, 96)
Size: UDim2(0, 40, 0, 40)
BackgroundColor3: Color3(0.15, 0.15, 0.25)
BackgroundTransparency: 0.3
UICorner: CornerRadius = UDim.new(0, 8)
Text: "📺"
Font: Gotham, TextSize: 20
```

### 7.3 Redesigned Top Bar Layout (Updated)

```
Top Bar width: UDim2(1, 0, 0, 60)
Items (left to right):
[EnergyCounter] [EssenceCounter] [VIPBadge/GetVIP] [PlayerRank] [RebirthButton]
                                                          [AdBtn] [Settings] [Codes]
```

### 7.4 New Script Modules (for engineer)

Add to the recommended modules list:
- `DailyRewardsController.lua` — Manages daily reward state, claim logic, calendar UI updates
- `QuestsController.lua` — Manages quest progress tracking, claim/redeem flows
- `VIPController.lua` — Handles VIP badge visibility, BillboardGui, multipliers
- `AdController.lua` — Handles reward ad requests, cooldown timers, reward distribution
- `PurchaseController.lua` — Handles purchase confirmation flow, MarketplaceService interaction

---

## 8. UX & Monetization Notes

- **Ad Frequency**: Maximum 1 rewarded ad per 5 minutes per player. 3 ads per hour cap. Show cooldown timer on ad buttons.
- **First-Time Purchase**: Show a "🎉 First Purchase Bonus!" offer: Double the Robux value on first purchase. Special banner at top of Shop.
- **Price Display**: Always show Robux amounts in Legendary Gold text. Use "R$" abbreviation for compact display.
- **Confirmation Steps**: Every Robux purchase requires a confirmation modal (prevents accidental purchases).
- **Owned Items**: Greyed-out cards with "OWNED" badge for already-purchased items. Prevents double-spending.
- **VIP Urgency**: Non-VIP players see a small "👑 GET VIP" prompt on the HUD (replaces VIP badge) that opens the Shop to the VIP card.
- **Daily Streak Loss Warning**: If player hasn't claimed today, show a gentle reminder notification after 5 minutes of gameplay: "🔥 Don't lose your streak! Claim your daily reward!"

---

*End of Monetization UI Specifications. Integrates with the main UI spec at ui_specs.md. All dimensions use Roblox UDim2 format for direct implementation.*
