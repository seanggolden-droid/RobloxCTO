# Zone Gate Polish & Unlock Specification

## 1. Structure
- **Base Part:** 50 x 100 x 10 studs.
- **Material:** Semi-transparent Neon (Transparency: 0.5).

## 2. Essence Cost Display
- **UI:** BillboardGui attached to the top-center of the gate.
- **Dimensions:** 20 x 8 studs.
- **Text:** Displays "Unlock for [COST] Essence" in white bold text with a black outline.

## 3. Zone-Specific Effects
Each gate uses particles and colors based on the destination zone:
- **To Forest:** Green Neon, Leaf particles.
- **To Desert:** Orange Neon, Sand/Dust particles.
- **To Cyber:** Cyan Neon, Digital/Glitch particles.

## 4. Unlock Animation Spec
When the player spends Essence to unlock:
1. **Particle Burst:** Massive burst of 50-100 particles matching the gate color.
2. **Text Update:** BillboardGui text changes to "UNLOCKED!" in glowing green for 1 second.
3. **Fade Out:** Gate part transparency tweens from 0.5 to 1.0 over 1.5 seconds.
4. **Collision Disable:** CanCollide set to false immediately upon purchase.
