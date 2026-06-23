# 032 Release Automation Polish

Milestone `032-release-automation-polish` makes release creation repeatable and
auditable from the current source tree.

## Public API Change

No new `JSONRPC_*` procedures are added.

The harness gains:

```sh
./tools/verify-release-artifacts.sh
```

`./tools/check.sh` runs this script after `./tools/package-alpha.sh`. The
verifier checks the generated alpha package, dist manifest, PDF artifacts, and
SHA-256 checksum files.

## Release Checklist

The release procedure is documented in:

```text
docs/release-checklist.md
```

The checklist covers project metadata, documentation freshness, path hygiene,
package contents, checksum verification, and final audit evidence.

## Scenario

```text
examples/032-release-automation-polish/release_automation_probe.pb
```

The scenario checks that the full harness wires package generation to release
artifact verification and that the checklist remains present.

## Verification

Required commands:

```sh
./tools/verify-docs.sh
./tools/build-docs.sh
./tools/check.sh
```
