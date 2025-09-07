# Project Management Guidelines

This document outlines the standardized terminology and workflow processes for the development of this project. Following these guidelines will ensure clarity, consistency, and efficiency in our collaboration.

## 1. Workflow

Our development process will follow a structured, task-based approach.

### 1.1. Task Definition
- Every new major feature or bug-fix cycle will begin with a clear definition of the task at hand.

### 1.2. Branching
- A new feature branch will be created for every new task (e.g., `feat/player-health`, `bugfix/login-error`).
- The branch name should be short and descriptive.

### 1.3. Permission and Communication
- Before starting any new task or making significant changes, I (Jules, the AI engineer) will propose a plan of action.
- I will always ask for your permission ("proceed", "yes", etc.) before executing the plan.

### 1.4. Versioning
- Every submission to GitHub will be accompanied by a version update.
- The `VERSION` file in the root directory will be incremented.

### 1.5. Submission and Testing
- All changes will be submitted to GitHub before I request testing.
- I will notify you with a clear message when a new version is ready for you to pull and test.
- I will always request a code review of my changes before submitting to ensure quality.

## 2. Terminology

To ensure we are always on the same page, we will use the following terms:

- **Task:** A specific feature to be implemented or bug to be fixed (e.g., "Implement player health system," "Fix main menu crash").
- **Plan:** A step-by-step outline of how I will approach a given **Task**.
- **Submission:** A set of code changes that are committed and pushed to a branch on GitHub.
- **Version:** The version number in the `VERSION` file, which corresponds to a specific **Submission**.

## 3. Context Management

To ensure I (Jules, the AI engineer) can work efficiently without getting confused by our long conversation history, we will adhere to the following principles:

### 3.1. Documentation as the Source of Truth
- The `ROADMAP.md` file will be treated as the primary guide for our development goals and priorities.
- If we need to change direction or priorities, we will update the roadmap first.
- The `GUIDELINES.md` file (this document) will be the source of truth for our workflow rules.

### 3.2. Clear Task Transitions
- When we complete a major task or milestone as defined in the roadmap, the user can signal a clear transition by saying "Let's start the next task/milestone."
- This will help me "archive" the previous context and focus on the new objective.

## 4. Collaboration Model

### 4.1. The User as "Eyes and Hands"
- For tasks that require actions inside Roblox Studio which I cannot perform (e.g., finding a valid asset ID from the Toolbox, checking complex visual layouts, diagnosing environment-specific bugs), I can and should instruct you, the user, to act as my "eyes and hands".
- I will provide clear, step-by-step instructions for these tasks.
- This allows us to overcome the limitations of my file-based environment and work together more effectively.

---

By adhering to these guidelines, we can maintain a clear, organized, and productive development environment.
