# Agent Guidelines

This repository is building a PureBasic JSON-RPC 2.0 library. Every agent or contributor must treat `GUIDELINE.md` and `PROJECT REQUEST.md` as the project source of truth.

## First Principles

- Use PureBasic `6.40` only.
- Build for both ARM64 and x64 where practical.
- Keep JSON-RPC protocol behavior aligned with the official JSON-RPC 2.0 specification.
- Use Microsoft's `vscode-jsonrpc` as an architectural reference, not as a parity checklist.
- Prefer correctness, memory safety, diagnostics, and testability before performance tuning.
- Keep the base JSON-RPC layer transport-agnostic and do not mix Language Server Protocol behavior into the core library.
- Treat future MCP server development in PureBasic as the primary target implementation context, while keeping the library useful for general JSON-RPC 2.0 applications.

## Milestone Workflow

Every feature milestone must follow this cycle:

1. Create or use a dedicated branch named `feature/NNN-short-slug`.
2. Write a short senior-architect plan with pros, cons, risks, alternatives, and tests.
3. Design one concrete scenario application for the feature.
4. Add PureUnit tests before or alongside implementation.
5. Keep library code and tests close to the relevant source area.
6. Create a sequential example folder under `examples/NNN-short-slug/`.
7. Review security, memory lifecycle, and readability before closing the milestone.
8. Update Markdown API documentation under `API/`.
9. Run `./tools/check.sh`.
10. Summarize verification results and any remaining risk.

## Local Harness

Use the repository scripts instead of hard-coding local paths in feature work:

```sh
./tools/discover-purebasic.sh
./tools/test.sh
./tools/build.sh
./tools/check.sh
```

The discovery script creates ignored project-local homes under `.local/` and records the detected PureBasic and PureUnit paths. Generated files under `.local/`, `.build/`, and `.reports/` must not be committed.

## PureBasic Rules

- Use `EnableExplicit` in new PureBasic files.
- Use compiler constants to guard platform-specific code.
- Treat console applications, GUI applications, and shared libraries as separate build targets.
- For library modules, prefer include files (`.pbi`) and small testable procedures.
- Every `ParseJSON()` or `CreateJSON()` ownership path must have a matching `FreeJSON()` when a handle is no longer needed.
- Use bounded buffers for stream framing and document maximum sizes.
- Avoid forced thread termination; cancellation must be cooperative.

## PureUnit Rules

- PureUnit tests live under `tests/unit/` unless a feature needs a more specific nearby test folder.
- Test files must contain at least one `ProcedureUnit`.
- Use `Assert()` or `AssertString()` with clear failure messages.
- Avoid interactive tests.
- Include malformed-input tests for protocol features, not just happy paths.
- Generate reports through `./tools/test.sh`; report output belongs in `.reports/`.

## Documentation Rules

- Public API documentation belongs in `API/` as Markdown.
- Each milestone must update API docs, even if the update says no public API was added.
- Documentation should be suitable for later Read the Docs compilation through the `docs/` entrypoint.
- Document method names, parameter shape, return shape, error behavior, ownership rules, and examples when API is added.

## Quality Gates

Before a milestone is considered complete:

- PureBasic 6.40 is detected.
- PureUnit tests pass.
- Scenario app builds.
- The scenario app runs without interactive input.
- Memory ownership has been reviewed.
- Security and malformed-input behavior have been reviewed where relevant.
- API docs are updated.
