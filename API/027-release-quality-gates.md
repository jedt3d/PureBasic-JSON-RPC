# 027 Release Quality Gates

Milestone `027-release-quality-gates` defines the measurable quality bar for
future alpha, beta, and production-candidate releases.

## Scope

This milestone does not add a new JSON-RPC wire feature. It hardens the project
process around the generic library:

- release readiness criteria
- documentation freshness
- route metadata verification
- path hygiene expectations
- repeatable verification commands

## Public API

No new `JSONRPC_*` procedures are added in this milestone.

The public artifact is the release-quality document:

```text
docs/release-quality-gates.md
```

## Harness Behavior

The normal project check includes:

```sh
./tools/verify-docs.sh
./tools/check.sh
```

`verify-docs.sh` confirms that numbered route folders, API pages, milestone
sections, and documentation indexes agree.

## Scenario

The scenario probe confirms that the quality-gate document exists and contains
the expected release levels:

```text
examples/027-release-quality-gates/release_quality_probe.pb
```

## Verification

Required commands:

```sh
./tools/verify-docs.sh
./tools/build-docs.sh
./tools/check.sh
```
