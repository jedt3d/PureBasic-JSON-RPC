# 000 Project Foundation

Milestone `000-project-foundation` adds the project harness and does not expose JSON-RPC library APIs yet.

## Public API Status

No public JSON-RPC API is available in this milestone.

## Tooling Interfaces

The milestone introduces these repository-level commands:

```sh
./tools/discover-purebasic.sh
./tools/test.sh
./tools/build.sh
./tools/check.sh
./tools/clean.sh
```

## Acceptance

- PureBasic 6.40 is detected.
- SDK PureUnit is detected.
- The PureUnit smoke test runs.
- The foundation console scenario builds and runs.

