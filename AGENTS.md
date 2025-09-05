# Agent Guidelines for DNF-DS Project

This document contains a set of rules and guidelines to follow during the development of the DNF-DS Roblox project. These are based on previous interactions and are meant to prevent repeated mistakes.

## 1. Rojo Configuration (`default.project.json`)

- **Filename:** The project file **must** be named `default.project.json`. Do not use `rojo.json`.
- **Ignoring Instances:** To prevent Rojo from deleting instances in the Studio (like `Terrain`), do not use the `$ignore` property. Instead, use the more compatible `"$ignoreUnknownInstances": true` property on the relevant node (e.g., `Workspace`).
- **Map Generation:** Due to unstable Rojo syncing for models, all map elements (Baseplate, walls, interactables, etc.) **must** be created programmatically. The authoritative script for this is `ServerScriptService/MapBuilder.server.lua`. Do not use `.model.json` files for map parts.

## 2. Versioning

- **`version.md`:** A `version.md` file exists in the root directory.
- **Increment on Submit:** For **every** submission (`submit` tool call), the version number in this file **must** be incremented. For example, from `1.0.3` to `1.0.4`.

## 3. Communication

- **Acknowledge User Input:** Always acknowledge user requests and feedback with the `message_user` tool before proceeding with a new plan. This is especially important when the user is providing feedback or reporting an error.
- **Testing Instructions:** When asking the user to test something, provide clear, step-by-step instructions. Differentiate between client-side and server-side checks (e.g., checking the Client vs. Server logs in the Output window).

## 4. General Workflow

- **Verify Changes:** After creating or modifying a file, always use a read-only tool like `read_file` or `ls` to verify that the change was applied correctly before marking a plan step as complete.
- **Diagnose Before Acting:** When an error is reported, take time to diagnose the root cause. Review logs, check file contents, and consult documentation (`google_search`) before proposing and implementing a fix.

## 5. Project Context

- **Game Manual (`game_manual.md`):** For questions about game rules, mechanics, and objectives, refer to this file first.
- **Project Roadmap (`project_roadmap.md`):** For questions about the development plan, task sequence, and MVP features, refer to this file first.

## 6. Strategic Pivots

- **Directive is King:** The user's most recent directive or strategic pivot always supersedes all previous plans and documentation.
- **Docs First:** When a major pivot occurs, the first priority is to update all relevant documentation (`game_manual.md`, `project_roadmap.md`, `AGENTS.md`) to reflect the new strategy. Code implementation must wait until the documentation is aligned.
