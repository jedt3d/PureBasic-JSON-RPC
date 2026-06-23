# Development Harness

The local harness standardizes PureBasic discovery, PureUnit execution, `.pbp` project verification, scenario builds, and generated output locations.

## Commands

```sh
./tools/discover-purebasic.sh
./tools/verify-projects.sh
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
