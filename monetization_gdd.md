# Monetization Enhancement Design: Monster Mash Simulator

## 1. Daily Reward System
- **Objective:** Drive daily active users (DAU) through a rewarding streak mechanic.
- **Cycle:** 7-day recurring cycle. Missing a day resets the streak.
- **Reset Timing:** Rewards reset at 00:00 UTC daily.
- **Rewards:**
    - **Day 1:** 500 Energy
    - **Day 2:** 1,000 Essence
    - **Day 3:** 1x Lucky Egg Boost (5 minutes)
    - **Day 4:** 2,500 Energy
    - **Day 5:** 5,000 Essence
    - **Day 6:** 1x Rare Egg (Free hatch)
    - **Day 7:** Exclusive "Daily Griffin" Monster (Epic rarity)
- **UI Progress:** A dedicated "Daily Rewards" button on the HUD. The UI shows a 7-day progress bar/grid with checkmarks for claimed days and a "Claim" button for the current day.

## 2. Quest System
- **Objective:** Increase session length and provide clear goals.
- **Daily Quests (Reset every 24h):**
    - "Clicker": Collect 1,000 Energy. (Reward: 500 Essence)
    - "Hatcher": Hatch 5 Eggs. (Reward: 1,000 Essence)
    - "Fighter": Win 3 Battles in the Arena. (Reward: 1,500 Essence)
    - "Gatherer": Earn 5,000 Essence. (Reward: 1x Speed Boost - 5 mins)
- **Weekly Quests (Reset every 7 days):**
    - "Monster Master": Hatch 50 Eggs. (Reward: 10,000 Essence + 1x Rare Egg)
    - "World Traveler": Collect 100,000 Energy. (Reward: 20,000 Essence + "Super Lucky" Boost)
- **Progression:** A "Quests" menu tracking progress with live progress bars (e.g., 250/1000).

## 3. VIP Perks
- **Price:** 500 Robux (One-time purchase).
- **VIP Players vs Free Players:**
    | Feature | Free Player | VIP Player |
    | :--- | :--- | :--- |
    | **Essence Multiplier** | 1x | 1.5x (Permanent) |
    | **Equipped Slots** | 3 Slots | 5 Slots (+2 Permanent) |
    | **Chat Tag** | Standard | Gold `[VIP]` Tag |
    | **Name Tag** | Standard | Gold Overhead Name Tag |
    | **Exclusive Area** | No Access | Access to VIP Lounge & Gold Crystal |
    | **Exclusive Monster** | None | 1x VIP Slime (Legendary stats) |
    | **Daily Rewards** | Standard | +25% Currency from Rewards |

## 4. Battle Pass (Season 1)
- **Structure:** 10 Tiers of rewards for Season 1.
- **Progression:** Earn "Pass XP" by earning Essence (1 XP per 100 Essence) and completing Quests.
- **Rewards Table:**
    | Tier | Free Reward | Premium Reward (400 Robux) |
    | :--- | :--- | :--- |
    | 1 | 500 Energy | "Neon Shadow Cat" (Epic) |
    | 2 | 100 Essence | 5-min Lucky Boost |
    | 3 | 1,000 Energy | 2x Essence Boost (10 mins) |
    | 4 | 250 Essence | 1x Basic Egg |
    | 5 | 1x Speed Boost | "Cybernetic Wings" (Relic) |
    | 6 | 2,000 Energy | 5,000 Essence |
    | 7 | 500 Essence | 1x Rare Egg |
    | 8 | 5,000 Energy | 10-min Super Luck Boost |
    | 9 | 1x Lucky Boost | "Void Fire Dragon" (Legendary) |
    | 10 | 1,000 Essence | "Omega Mech-Beast" (Mythical) |

## 5. Ad Integration (Rewarded Videos)
- **Objective:** Monetize non-paying players.
- **Placement 1: Energy Boost Kiosk**
    - Located near Spawn.
    - **Action:** Watch ad for 2x Energy collection for 10 minutes.
- **Placement 2: Reward Doubler**
    - Appears after winning a Battle Arena wave.
    - **Action:** Watch ad to double the Essence/Relics earned from that battle.
- **Placement 3: Free Egg Hatch**
    - Located at the Incubator.
    - **Action:** Watch ad for 1x Free "Basic Egg" hatch.
    - **Cooldown:** 15-minute cooldown between ad-based hatches.

## 6. Technical Notes
- **Server Authority:** All time-based resets (Daily/Weekly) and ad-reward validation must be handled on the server using `os.time()`.
- **MarketplaceService:** Used to check for VIP game pass ownership and Premium Battle Pass purchase.
