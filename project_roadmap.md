# DNF-DS MVP Project Roadmap

This document outlines the high-level tasks required to complete the Minimum Viable Product (MVP) for the DNF-DS game.

### Task 1: Project Setup & Core Framework (Completed)
- [x] Create a new Roblox place and set up the Rojo project structure.
- [x] Implement a basic lobby system with "Play as Survivor" and "Play as Killer" GUI buttons.
- [x] Write a central `GameManager` module script to handle player role selection, game state (`PreGame`, `InGame`, `PostGame`), and win conditions.

### Task 2: Build the MVP Map
- [ ] Design a simple, small map with a flat baseplate.
- [ ] Add several simple wall structures and obstacles to create loops and hiding spots.
- [ ] Place pre-defined spawn locations for 5 generators, 2 exit gates, and at least 6 sacrificial hooks.
- [ ] Add a few vaultable windows and droppable pallets to the environment.

### Task 3: Code the Survivor Mechanics
- [ ] Create a `SurvivorController` script to handle standard movement (walk, run, crouch) and a health state system (Healthy -> Injured -> Downed).
- [ ] Create an `InteractionController` script to detect when the player is near an interactable object (Generator, Exit Gate, Hooked Teammate).
- [ ] Implement a channeled action system (e.g., holding 'E').
- [ ] Implement the skill-check minigame UI and logic: a circular ring with a rotating needle, triggered by 'Spacebar'. Failure should cause an explosion, regress progress, and alert the Killer.

### Task 4: Code the Killer Mechanics
- [ ] Create a `KillerController` script with movement speed slightly faster than a survivor's run speed.
- [ ] Implement a primary melee attack (LeftMouseClick) that damages survivors.
- [ ] Implement the ability to pick up downed survivors ('E' key) and carry them to a hook.
- [ ] Code the hook interaction, which starts a sacrifice timer.
- [ ] Implement a basic secondary ability: a short-duration speed boost on a cooldown (e.g., on LeftShift).

### Task 5: Implement Objectives & Win Conditions
- [ ] Script the `Generator` object to require a 60-second channeled interaction (composed of multiple skill checks) to complete.
- [ ] Update the `GameManager` when a generator is finished.
- [ ] Script the `ExitGate` object to only become interactable after 5 generators are complete. It should require a 10-second uninterruptible channel to open.
- [ ] In the `GameManager`, write the functions to continuously check for win conditions (all survivors sacrificed or at least one escapes).

### Task 6: Polish & Meta-Features
- [ ] Implement a scoring system (e.g., points for repairs, unhooks, sacrifices).
- [ ] Create a simple end-game GUI screen that displays the winner and each player's score.
- [ ] Ensure all core mechanics are properly replicated for a multiplayer environment.

### Final Deliverable
- [ ] A functional Roblox place file.
- [ ] A summary of implemented features and any known limitations or bugs in the MVP.
