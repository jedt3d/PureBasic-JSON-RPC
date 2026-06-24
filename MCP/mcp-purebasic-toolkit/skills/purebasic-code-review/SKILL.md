---
name: purebasic-code-review
description: Code-review workflow for PureBasic JSON-RPC, MCP server, harness, docs, and release changes. Use when reviewing PureBasic code for bugs, protocol regressions, JSON ownership, path hygiene, stdout/stderr discipline, missing tests, `.pbp` target mistakes, docs drift, or release risk.
---

# PureBasic Code Review

## Review Priority

Find bugs and risks first. Lead with actionable findings, ordered by severity,
with file and line references when possible.

## Checklist

Review for:

- JSON-RPC request, response, notification, batch, id, params, and error semantics
- MCP stdio discipline: stdout protocol-only, stderr for logs
- `ParseJSON()` and `CreateJSON()` ownership paired with `FreeJSON()`
- UTF-8 byte length versus character count
- bounded buffers and bounded command/tool output
- idempotent close and cleanup of pending, queued, timeout, cancellation, trace, and diagnostics state
- path containment and absence of workstation-specific absolute paths
- `.pbp` target type, input, output, thread mode, and CPU metadata
- tests for malformed input and failure paths, not only happy paths
- docs, API pages, milestones, ReadTheDocs navigation, and release notes

## Evidence

When possible, run or request:

```sh
./tools/verify-docs.sh
./tools/verify-paths.sh
./tools/test.sh
./tools/build.sh
./tools/check.sh
```

Mention any checks not run and the remaining risk.
