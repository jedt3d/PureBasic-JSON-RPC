# Development Harness

The local harness standardizes PureBasic discovery, PureUnit execution, `.pbp` project verification, scenario builds, and generated output locations.

## Commands

```sh
./tools/discover-purebasic.sh
./tools/verify-projects.sh
./tools/verify-docs.sh
./tools/verify-paths.sh
./tools/verify-release-artifacts.sh
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
- at least one matching `tests/unit/NNN_*.pb` unit test file

It also checks that the main Sphinx toctree includes required project documents
and that planned hardening rounds `027` through `032` remain visible in
`docs/milestones.md`.

Run this script whenever a route adds, moves, renames, completes, or plans a
numbered milestone. `tools/check.sh` runs it automatically before tests and
builds.

## Path Verification

`tools/verify-paths.sh` scans tracked files for workstation-specific absolute
paths. Generated folders such as `.local/`, `.build/`, and `.reports/` may
contain real local paths, but tracked source, docs, project metadata, examples,
and probes must use repository-relative paths.

`tools/check.sh` runs the path scan automatically before tests and builds.

## Execution Ordering

Run harness scripts that discover or prepare the PureBasic toolchain
sequentially. `tools/discover-purebasic.sh`, `tools/test.sh`, `tools/build.sh`,
`tools/build-docs.sh`, and `tools/check.sh` share generated state under
`.local/`; running them in parallel can race while creating project-local
compiler and PureUnit homes. Prefer `tools/check.sh` as the single orchestrator
for full verification.

## Release Artifact Verification

`tools/verify-release-artifacts.sh` checks generated files under `.build/dist/`
after `tools/package-alpha.sh` runs. It verifies that the source tarball,
manifest, overview PDF, tutorial PDF, and SHA-256 checksum files exist and that
the checksums validate.

The verifier also checks that the dist manifest includes current hardening docs,
API pages, examples, tests, and release harness scripts. `tools/check.sh` runs
the verifier after packaging.

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
- `tools/test.sh` runs every `tests/unit/*.pb` file by default so new tests are
  not silently skipped. In multi-file mode it runs PureUnit one test file at a
  time and writes a summary report at `.reports/pureunit/index.html`.
- `tools/test.sh` treats each PureUnit HTML report as completion evidence when
  it says all tests completed with zero failures. If PureUnit leaves a standby
  compiler process running after that successful report, the script cleans up
  the stalled process so `tools/check.sh` can continue.
- `tools/test.sh` also guards pre-report PureUnit hangs with
  `PUREUNIT_TIMEOUT_SECONDS` and `PUREUNIT_RETRY_LIMIT`. The defaults are
  60 seconds per attempt and three attempts, which keeps `tools/check.sh` from
  waiting forever while still retrying transient standby compiler stalls.
- `tools/verify-paths.sh` must pass so tracked files do not commit workstation-specific absolute paths.
- `tools/verify-release-artifacts.sh` must pass after packaging so release
  artifacts and dist manifests match the current tree.
- Console, GUI application, and shared library targets must be treated as distinct `.pbp` build targets.
- Long-form Markdown docs must build through Sphinx and produce exactly two PDFs through `tools/build-docs.sh`.
- Numbered routes must keep API pages, milestone sections, documentation indexes, and Sphinx navigation synchronized through `tools/verify-docs.sh`.
