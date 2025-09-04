# Agent Guidelines for DNF-DS Project

This document contains a set of rules and guidelines to follow during the development of the DNF-DS Roblox project. These are based on previous interactions and are meant to prevent repeated mistakes.

## 1. Rojo Configuration (`default.project.json`)

- **Filename:** The project file **must** be named `default.project.json`. Do not use `rojo.json`.
- **Ignoring Instances:** To prevent Rojo from deleting instances in the Studio (like `Terrain`), do not use the `$ignore` property. Instead, use the more compatible `"$ignoreUnknownInstances": true` property on the relevant node (e.g., `Workspace`).
- **Defining Core Instances:** Any essential part of the game world that should not be deleted by Rojo (e.g., the `BasePlate`) **must** be defined as a file in the `Workspace` folder, typically as a `.model.json` file.

## 2. Versioning

- **`version.md`:** A `version.md` file exists in the root directory.
- **Increment on Submit:** For **every** submission (`submit` tool call), the version number in this file **must** be incremented. For example, from `1.0.3` to `1.0.4`.

## 3. Communication

- **Acknowledge User Input:** Always acknowledge user requests and feedback with the `message_user` tool before proceeding with a new plan. This is especially important when the user is providing feedback or reporting an error.
- **Testing Instructions:** When asking the user to test something, provide clear, step-by-step instructions. Differentiate between client-side and server-side checks (e.g., checking the Client vs. Server logs in the Output window).

## 4. General Workflow

- **Verify Changes:** After creating or modifying a file, always use a read-only tool like `read_file` or `ls` to verify that the change was applied correctly before marking a plan step as complete.
- **Diagnose Before Acting:** When an error is reported, take time to diagnose the root cause. Review logs, check file contents, and consult documentation (`google_search`) before proposing and implementing a fix.
