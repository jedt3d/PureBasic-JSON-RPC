# PureBasic Project Files

PureBasic project files (`.pbp`) are committed build metadata in this repository. The root project file is `PureBasic-JSON-RPC.pbp`.

The rule is simple: the repository root has a main library project file, and every buildable scenario application under `examples/` and every MCP example under `MCP/examples/` must have a project file in the same folder. The project file is the source of truth for:

- target type: `console`, `shared`, or `executable`
- input source file
- generated output path under `.build/`
- thread mode
- current macOS ARM64 CPU target

The harness verifies project metadata before the full check:

```sh
./tools/verify-projects.sh
```

The harness builds project targets with the PureBasic IDE command-line builder:

```sh
PureBasic --build path/to/project.pbp --target target-name --readonly --quiet
```

Do not encode target type only as raw `pbcompiler` flags. If a new root, scenario, or MCP target needs a console application, GUI executable/application, or shared library, add the target to the nearest `.pbp` file and then update `tools/pbp-projects.sh`.

Keep generated output paths project-root-relative, normally under `.build/`. Do not commit absolute workstation paths in `.pbp` metadata, examples, or documentation.
