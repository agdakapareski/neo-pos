# UI Design Direction

## Active Direction: Stitch Monochrome (Receipt-Tape Terminal)

> Decision (2026-10-13): the four POS flow screens follow the Stitch mockups in
> `design/stitch/` — monochrome black/white/gray, system monospace font,
> uppercase terminal labels, `[ BRACKETED ]` actions, dashed receipt dividers.
> This replaces the earlier white/green direction below.
> Tokens live in `lib/core/theme/app_theme.dart`; shared pieces in
> `lib/core/widgets/` (`BracketButton`, `OutlineBracketButton`, `TerminalLabel`,
> `DashedDivider`).

## Current Iteration: Functionality First

The UI should be:
- **Simple**
- **Modern**
- **Clean**
- Easy for a cashier to understand
- Primarily **white with green as the main accent** (superseded above for the POS flow screens)

Material components can be used for practical implementation, but the app should not be treated as a generic Material Design project.

### Current Priorities
1. Correct functionality and data flow
2. Clear layouts and navigation
3. Consistent white/green visual direction
4. Basic responsive behavior
5. Visual polish only where it supports the active task

### Explicitly Avoid for Now
- Large custom design systems
- Elaborate animations
- Decorative effects
- Complex component abstractions
- Broad visual refactors unrelated to the active task

## Later Iteration
After core functionality is stable, a separate UI pass can introduce:
- Stronger brand identity
- More distinctive components
- Refined visual hierarchy
- Better interaction details
- Animation and micro-interactions
- More polished layouts
