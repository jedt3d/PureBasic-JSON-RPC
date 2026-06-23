# Development Harness

The local harness standardizes PureBasic discovery, PureUnit execution, `.pbp` project verification, scenario builds, and generated output locations.

## Commands

```sh
./tools/discover-purebasic.sh
./tools/verify-projects.sh
./tools/verify-docs.sh
./tools/test.sh
./tools/build.sh
./tools/build-docs.sh
./tools/check.sh
```

## PureBasic Project Files

The root library workspace is controlled by `PureBasic-JSON-RPC.pbp`. Buildable example applications are also controlled by committed PureBasic project files (`.pbp`). Each scenario folder under `examples/` has one project file, and MCP examples under `MCP/examples/` follow the same rule.

The project file declares:

- the source file for each target
- the target type, such as `console`, `shared`, or `executable`
- the generated output path under `.build/`
- thread mode and the current macOS ARM64 CPU target

`tools/verify-projects.sh` checks the expected project metadata. `tools/build.sh` builds each target with the PureBasic IDE command-line builder:

```sh
PureBasic --build project.pbp --target target-name --readonly --quiet
```

Raw `pbcompiler` flags should not be the source of truth for scenario target type.

## Documentation Route Verification

`tools/verify-docs.sh` checks that implemented numbered routes are represented
consistently across the repository documentation. It verifies that every
`examples/NNN-slug/` folder has:

- an example README
- a matching `API/NNN-slug.md` page
- a matching `## NNN-slug` section in `docs/milestones.md`
- an `API/index.md` entry
- a `docs/api.md` bridge entry

It also checks that the main Sphinx toctree includes required project documents
and that planned hardening rounds `027` through `032` remain visible in
`docs/milestones.md`.

Run this script whenever a route adds, moves, renames, completes, or plans a
numbered milestone. `tools/check.sh` runs it automatically before tests and
builds.

## Generated Folders

- `.local/` - project-local toolchain homes and summaries.
- `.build/` - compiled example outputs.
- `.build/docs-html/` and `.build/docs-pdf/` - generated documentation output.
- `.reports/` - PureUnit reports.

These folders are ignored by Git.

## Path Convention

Repository paths in source comments, documentation, probes, and examples should be relative to the repository root. Use `.local/...`, `.build/...`, `MCP/examples/...`, and `examples/...` instead of committing workstation-specific absolute paths.

Some tools still need real system paths at runtime. The PureBasic installation path is treated as a discovered or environment-configured dependency, not as project metadata. Use `PB_INSTALL_HOME` when the default discovery is not correct for the local machine.

## Toolchain Contract

- PureBasic version must be `6.40`.
- PureUnit must come from the PureBasic SDK.
- Console, GUI application, and shared library targets must be treated as distinct `.pbp` build targets.
- Long-form Markdown docs must build through Sphinx and produce exactly two PDFs through `tools/build-docs.sh`.
- Numbered routes must keep API pages, milestone sections, documentation indexes, and Sphinx navigation synchronized through `tools/verify-docs.sh`.
