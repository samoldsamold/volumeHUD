# Glass Foreground Contrast Spec

## Goal

Fix HUD value-bar contrast in Liquid Glass mode so filled bars render with the same foreground treatment as the icon or brightness symbol.

## Root Cause

The Liquid Glass branch applies `.glassEffect(.regular, in:)` directly to `hudContent`. Apple's `glassEffect(_:in:)` modifier renders Liquid Glass for a view and applies Liquid Glass foreground effects to that view, so HUD foreground elements inside the modified view can be visually altered by the glass treatment. Small rectangular value bars lose more apparent contrast than the large SF Symbol.

## Design

- Render the Liquid Glass surface as its own shaped layer.
- Place `hudContent` above that glass layer, outside the view receiving `.glassEffect`.
- Keep the classic material branch unchanged.
- Keep the shared HUD foreground opacity tokens from `HUDVisualStyle`.

## Acceptance Criteria

- AC1: Liquid Glass mode renders a shaped glass surface behind HUD content.
- AC2: Liquid Glass mode no longer applies `.glassEffect` directly to `hudContent`.
- AC3: HUD icon and bars continue to use shared `HUDVisualStyle` foreground tokens.
- AC4: Classic material mode remains available when glass is disabled.
- AC5: Automated checks cover the glass/content layering and existing foreground token usage.
