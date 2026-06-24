# PureBasic Gadgets

This directory tracks sample implementations that are created by using the
PureBasic MCP toolkit together with the bundled Codex skills.

These projects are not part of the core JSON-RPC library and are not MCP server
examples. They are dogfood implementation targets: practical PureBasic programs
or components that let the toolkit prove it can help plan, review, implement,
test, document, and package real PureBasic work.

## Current Projects

- `SevenSegmentClock/` starts milestone `00.07` for a custom PureBasic
  seven-segment clock gadget. The first tracked artifact is the human-reviewed
  PRD. Source code, `.pbp` targets, tests, bundled fonts, license attribution,
  and example apps will be added in the implementation route.

## Route Rules

Gadget projects follow the same discipline as the main repository:

- use PureBasic `6.40`
- use `.pbp` files as committed build target metadata
- keep generated files under `.build/`, `.local/`, or `.reports/`
- avoid workstation-specific absolute paths in tracked files
- document external assets and licenses before bundling them
- update the relevant toolkit milestone when a route starts or completes
- verify through the repository harness before merging tracked changes
