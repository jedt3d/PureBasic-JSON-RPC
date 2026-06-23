# 000 Project Foundation

Milestone `000-project-foundation` adds the project harness and does not expose JSON-RPC library APIs yet.

## Public API Status

No public JSON-RPC API is available in this milestone.

## Tooling Interfaces

The milestone introduces these repository-level commands:

```sh
./tools/discover-purebasic.sh
./tools/verify-projects.sh
./tools/test.sh
./tools/build.sh
./tools/check.sh
./tools/clean.sh
```

Buildable scenario applications are represented by committed `.pbp` project files. The project file records target type and output path; the harness verifies this metadata before building.

## Acceptance

- PureBasic 6.40 is detected.
- SDK PureUnit is detected.
- PureBasic project metadata is verified.
- The PureUnit smoke test runs.
- The foundation console scenario builds and runs.
