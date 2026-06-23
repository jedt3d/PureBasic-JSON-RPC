# Development Harness

The local harness standardizes PureBasic discovery, PureUnit execution, scenario builds, and generated output locations.

## Commands

```sh
./tools/discover-purebasic.sh
./tools/test.sh
./tools/build.sh
./tools/check.sh
```

## Generated Folders

- `.local/` - project-local toolchain homes and summaries.
- `.build/` - compiled example outputs.
- `.reports/` - PureUnit reports.

These folders are ignored by Git.

## Toolchain Contract

- PureBasic version must be `6.40`.
- PureUnit must come from the PureBasic SDK.
- Console, GUI application, and shared library targets must be treated as distinct build outputs in future milestones.

