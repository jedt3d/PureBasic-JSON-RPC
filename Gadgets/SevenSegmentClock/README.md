# Seven Segment Clock Gadget

`SevenSegmentClock` is the first tracked gadget implementation target produced
through the MCP toolkit plus PureBasic skills workflow.

The current source-of-truth seed is:

- `PRD SevenSegmentClock Gadget.md`

That PRD defines a custom PureBasic gadget that renders the local machine time
as `HH:MM:SS` with a seven-segment font on a `CanvasGadget()`. The planned
implementation will start from a minimal working gadget, then add bundled DSEG
font support, layout controls, click-to-invert interaction, blinking seconds
colon behavior, font variants, and a hardened example application.

## Status

Milestone `00.07` is seeded, not complete. This folder is tracked now so the PRD
can be reviewed and evolved in Git before implementation starts.

Expected future tracked files include:

- `src/` for reusable gadget source
- `examples/` for a standalone demo app
- `tests/` or repository PureUnit coverage for layout/state helpers where
  practical
- a `.pbp` file with explicit application targets
- bundled font files only after license and attribution are reviewed
- API and usage documentation for external reviewers

## Why This Exists

The gadget is intentionally not an MCP server. It is a sample implementation
that lets the toolkit practice the full development loop:

1. interview the human and clarify requirements
2. explain rendering and event-flow decisions before coding
3. produce implementation artifacts with Git-visible review history
4. keep docs, milestones, and harness checks aligned
5. preserve lessons learned such as repository-relative paths and explicit
   `.pbp` target metadata
