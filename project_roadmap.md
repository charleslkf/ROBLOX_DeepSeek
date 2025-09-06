# DNF-DS Project Roadmap (Revised)

This document outlines the phased development plan for the DNF-DS game, focusing on delivering a stable core experience before introducing advanced features.

---

## Phase 1: Core MVP (1 vs. 4)

The immediate goal is to build a complete and balanced 1-Killer-vs-4-Survivors game loop. All survivors are functionally identical in this phase.

### Task 1: Project Setup & Core Framework (Completed)
- [x] Initial project and Rojo setup.
- [x] Basic `GameManager` and lobby system.

### Task 2: Refactor for Core MVP (Completed)
- [x] **Player Management:** Refactor `GameManager` for 1v4 matches with random Killer selection. Remove multi-role selection GUI and logic.
- [x] **Map Layout:** Create a simple map with a baseplate, walls, and spawn locations for a 1v4 match. (Partially complete). Add vaultable windows and pallets.
- [x] **Interaction System:** Ensure interaction controllers are simplified for a single "Skill Check" machine type.

### Task 3: Survivor Mechanics
- [x] Implement `SurvivorController` for movement (walk, run, crouch) and health states (Healthy, Injured, Downed).
- [ ] Implement interactions for repairing generators (with skill checks) and escaping.

### Task 4: Killer Mechanics
- [ ] Implement `KillerController` with appropriate speed for a 1v4 match.
- [ ] Implement melee attack, carrying, and hooking mechanics.

### Task 5: Win Conditions & Gameplay Loop
- [ ] Script `Generator` objects (5 total) to be repairable via skill checks.
- [ ] Script `ExitGate` objects (2 total) to be openable after all generators are repaired.
- [ ] Implement win/loss checks in the `GameManager`.

### Task 6: MVP Polish
- [ ] Implement a basic scoring system.
- [ ] Create a simple end-game GUI.
- [ ] Ensure all systems are secure and replicate correctly for multiplayer.

---

## Phase 2: The Full Vision (Post-MVP)

After the core 1v4 game is stable and fun, these advanced features will be added incrementally.

- **Expanded Player Count:** Increase server size to 10 players (1 vs. 9).
- **Specialized Roles:** Implement the Stunner, Helper, and Survivor roles with a lobby selection system.
- **Character Abilities:** Add the Flashbang (Stunner) and Healing Aura (Helper) abilities.
- **Item System:** Introduce MedKits and EnergyDrinks with a two-slot inventory.
- **Diverse Minigames:** Add the Pipe Puzzle and Memory Game machine types.
- **Meta-Progression:** Implement the "Killer Chance" bar with data persistence.
- **Leaderboards:** Add leaderboards for fastest escape times.
