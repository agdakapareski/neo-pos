# Agents Guide

## Working Principles
- Work on **one task at a time**.
- Use `kanban.md` as the source of truth for task status and scope.
- Before implementing a task, understand its scope and affected files.
- Keep changes focused on the current task.
- **Do not over-engineer.**
- Do not introduce abstractions, architecture, dependencies, or features not required by the current task.
- Prefer the simplest implementation that fits the existing project structure.
- Reuse existing models, providers, repositories, widgets, and utilities when practical.
- Avoid speculative future-proofing and unrelated refactoring.
- Keep the app functional before improving polish.

## UI Direction
- UI should be **simple and modern**.
- Use a **white and green** visual direction.
- Material components may be used where convenient, but Material Design is not the final visual identity.
- A stronger visual-design iteration can come later.
- For the current iteration, **functionality comes first**.
- Avoid animations, elaborate design systems, decorative components, and visual refinements unless the active task requires them.

## Task Workflow
1. Read the task in `kanban.md`.
2. Confirm the scope and files involved.
3. Implement only that task.
4. Test or verify the affected functionality as practical.
5. Update the task status in `kanban.md`.
6. Record meaningful changes in `CHANGELOG.md` if used.
7. Move to the next task only after the current task is complete.

## Running the App
Do not run `flutter run` automatically. The user runs it manually:

```bash
flutter run -d <device-id>
# or
flutter run -d chrome
```
