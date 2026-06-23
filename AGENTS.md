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

## Target Implementation Context

This project is not only a generic JSON-RPC exercise. The main intended use is to make future MCP server development practical in PureBasic.

Agents and contributors should use that context when making product and engineering decisions:

- Prefer APIs that make MCP server request/response, notification, stdio, and long-running tool-process workflows straightforward.
- Keep the core JSON-RPC layer independent from MCP-specific method names or schemas unless a later milestone explicitly adds an MCP adapter layer.
- Choose examples that can naturally grow toward MCP server scenarios, while still proving general JSON-RPC correctness.
- Document behavior in a way that a future PureBasic MCP server author can follow without reverse-engineering transport, framing, cancellation, or memory ownership rules.
- Do not narrow the library so much that it cannot support other JSON-RPC 2.0 applications; MCP is the primary context, not the only allowed use.

## Milestone Workflow

Every feature milestone must follow this cycle:

1. Create or use a dedicated branch named `feature/NNN-short-slug`.
2. Write a short senior-architect plan with pros, cons, risks, alternatives, and tests.
3. Design one concrete scenario application for the feature.
4. Add PureUnit tests before or alongside implementation.
5. Keep library code and tests close to the relevant source area.
6. Create a sequential example folder under `examples/NNN-short-slug/`.
7. Add or update the folder's `.pbp` project file so target type, input file, output path, thread mode, and CPU target are explicit.
8. Review security, memory lifecycle, and readability before closing the milestone.
9. Update Markdown API documentation under `API/`.
10. Run `./tools/check.sh`.
11. Summarize verification results and any remaining risk.

## Local Harness

Use the repository scripts instead of hard-coding local paths in feature work:

```sh
./tools/discover-purebasic.sh
./tools/verify-projects.sh
./tools/test.sh
./tools/build.sh
./tools/build-docs.sh
./tools/check.sh
```

The discovery script creates ignored project-local homes under `.local/` and records the detected PureBasic and PureUnit paths. Generated files under `.local/`, `.build/`, and `.reports/` must not be committed.

Write project-local paths relative to the repository root in documentation, source constants, probe data, and example configuration. System dependency paths, such as a developer's PureBasic installation, should be discovered through the harness or provided through environment variables instead of committed as workstation-specific paths.

PureBasic project files (`.pbp`) are committed source-of-truth build metadata for the root library project, scenario applications, and MCP example applications. The harness builds project targets through the PureBasic IDE command-line builder (`PureBasic --build ... --target ...`) so Console, GUI executable, and shared-library target types are controlled in one place. Do not replace `.pbp` project targets with ad hoc compiler flags in `tools/build.sh`.

## PureBasic Rules

- Use `EnableExplicit` in new PureBasic files.
- Use compiler constants to guard platform-specific code.
- Treat console applications, GUI applications, and shared libraries as separate `.pbp` build targets.
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
- Long-form narrative documentation belongs in `docs/`; keep `docs/mcp-for-purebasic.md` and `docs/tutorial-building-with-purebasic-jsonrpc.md` as the beginner-to-practitioner path.
- Each milestone must update API docs, even if the update says no public API was added.
- Documentation should be suitable for later Read the Docs compilation through the `docs/` entrypoint.
- Generated documentation PDFs belong under `.build/` or release artifacts; do not commit PDF binaries.
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
