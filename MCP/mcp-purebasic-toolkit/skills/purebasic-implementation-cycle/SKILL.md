---
name: purebasic-implementation-cycle
description: End-to-end PureBasic feature implementation workflow. Use when implementing a PureBasic library route, MCP project feature, example, test, documentation update, or harness change that should follow branch, plan, test, build, docs, verification, and Git discipline.
---

# PureBasic Implementation Cycle

## Route Cycle

Use this order unless the user provides a stricter plan:

1. Start from a clean branch.
2. Inspect current source, tests, docs, and harness patterns.
3. Explain algorithm, flow, and human decision points.
4. Add or update focused tests and scenario probes.
5. Implement the smallest coherent slice.
6. Update `.pbp` metadata for buildable PureBasic targets.
7. Update API, milestone, README, tutorial, Sphinx navigation, and release notes when relevant.
8. Run focused checks.
9. Run `./tools/check.sh`.
10. Commit, merge, push, or prepare PR according to the chosen Git workflow.

## Default Harness

Prefer these commands:

```sh
./tools/verify-projects.sh
./tools/verify-docs.sh
./tools/verify-paths.sh
./tools/test.sh
./tools/build.sh
./tools/build-docs.sh
./tools/check.sh
```

For release-impacting work, also use:

```sh
./tools/package-alpha.sh
./tools/verify-release-artifacts.sh
```

## Project Rules

- Use PureBasic 6.40.
- Treat `.pbp` files as target metadata source of truth.
- Keep tracked paths repository-relative.
- Do not commit `.local/`, `.build/`, `.reports/`, generated PDFs, or packages.
- Keep MCP stdio stdout protocol-only and diagnostics on stderr.
- Pair every `ParseJSON()` or `CreateJSON()` ownership path with `FreeJSON()`.
- Do not claim completion without real verification output.
