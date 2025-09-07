# Handoff Document for DNF-DS Project

Hello! I am Jules, the previous agent who worked on this project. The user has asked me to prepare this document to ensure a smooth transition for you. Please read this carefully to understand the project's status, our workflow, and the next steps.

---

## 1. Project Overview

*   **Project Name:** DNF-DS (Do Not Fear - Dark Survival)
*   **Goal:** A 1-vs-4 asymmetric horror game inspired by *Dead by Daylight*.
*   **Core Loop:** 4 Survivors must repair 5 generators to power two exit gates and escape. 1 Killer must hunt and sacrifice the survivors.
*   **Engine:** Roblox (using Rojo for local development).

---

## 2. Current Status & Work Done

We have successfully implemented the **core combat loop**. This was a long and difficult task with many bugs, but it is now fully functional and verified by the user.

**Completed Features:**
*   **Lobby System:** Players can join a lobby, ready up, and the game will start when 5 players are ready.
*   **Role Assignment:** The `GameManager` correctly assigns 1 player as Killer and 4 as Survivors.
*   **Killer Mechanics (Partial):**
    *   The Killer is 20% faster than survivors.
    *   The Killer has a fully functional melee attack.
    *   The attack correctly damages survivors in two stages: **Healthy -> Injured** (50% speed reduction) and **Injured -> Downed** (movement disabled).
*   **Survivor Mechanics (Partial):**
    *   Survivors have a 3-stage health system that is correctly updated by the Killer's attack.
    *   The `SurvivorController` script has been rewritten to be robust against startup timing issues.
*   **Sound:** The attack now has a server-side "hit" sound that only plays on a successful hit. The client-side sound spam has been fixed.

**We are currently in the middle of implementing the next major feature from the roadmap.**

---

## 3. Immediate Next Steps (Work-in-Progress)

We just started **Task 4: Killer Mechanics - Carrying and Hooking**.

I have already created a detailed 6-step plan, which the user has approved. We are **currently on Step 1**.

**The Plan:**
1.  **Create New Events:** Create `CarryRequestEvent` and `HookRequestEvent` in `ReplicatedStorage/Events`. (I was in the middle of this when the handoff was requested).
2.  **Update Map with Hooks:** Edit the `MapBuilder` to add hook models to the map.
3.  **Implement Killer Pickup Interaction:** Update the Killer's client script to detect downed survivors and fire the `CarryRequestEvent`.
4.  **Implement Server-Side Carrying Logic:** Use a `WeldConstraint` to attach the survivor to the Killer.
5.  **Implement Server-Side Hooking Logic:** Detach the survivor from the Killer and attach them to a hook.
6.  **Review and Test:** Final verification of the new mechanic.

Your first action should be to **complete Step 1** by creating the `HookRequestEvent.model.json` file, as I had only created the `CarryRequestEvent` file.

---

## 4. Collaboration Method (Very Important!)

The user has a strict and clear workflow that you **must** follow. Failure to do so will cause friction.

1.  **Set the Plan:** Before starting any new task, present a clear, step-by-step plan to the user.
2.  **Wait for Approval:** **DO NOT** start working on Step 1 of the plan until the user explicitly says "ok", "proceed", or gives you the green light.
3.  **Complete One Step at a Time:** Execute only one step of your plan.
4.  **Verify Your Work:** After every action that changes the code, you **must** use a read-only tool (like `read_file` or `ls`) to verify that your change was applied correctly.
5.  **Mark Step Complete:** Once a step is complete and verified, use `plan_step_complete`.
6.  **Wait for Instructions:** After completing a step, **WAIT** for the user to tell you to proceed to the next one. Do not continue automatically.
7.  **Version Numbers:** The user wants the `version.md` file to be incremented with every new feature that is submitted for testing. Remember to include this as a step in your plans.

---

## 5. Development & Deployment Workflow

This is how we get code from your environment into the user's Roblox Studio to test:
1.  You make changes to the files locally in your environment.
2.  When a feature or fix is ready for testing, you use the `submit` tool to commit the changes to a new branch on GitHub.
3.  The user's Visual Studio Code is synced with this GitHub repository.
4.  The user uses the **Rojo** plugin in VS Code to sync the file changes into their Roblox Studio place file.
5.  The user then runs a multi-client test server inside Roblox Studio to test the changes and provides you with the results and logs.

Good luck!
