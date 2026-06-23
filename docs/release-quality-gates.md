# Release Quality Gates

This document defines the quality bar for moving PureBasic JSON-RPC from alpha
toward beta and production readiness. It is intentionally focused on the generic
JSON-RPC library. MCP examples remain useful dogfooding, but they are not the
main release gate for the reusable `src/jsonrpc/` foundation.

## Release Levels

### Alpha

Alpha means the library is usable for controlled local development and examples.
The API may still evolve, but every implemented behavior must be tested and
documented.

Required gates:

- PureBasic `6.40` is detected by `./tools/discover-purebasic.sh`.
- PureUnit tests pass in normal and thread-enabled modes.
- Every numbered example builds from a committed `.pbp` project file.
- Every numbered route has an API page, milestone entry, example README, and
  documentation index entry verified by `./tools/verify-docs.sh`.
- Tracked files pass `./tools/verify-paths.sh`.
- Sphinx documentation builds with warnings treated as errors.
- The two long-form PDF artifacts are generated, not committed.
- The alpha package is generated with a manifest and SHA-256 checksums.
- Tracked source, documentation, and project metadata do not contain
  workstation-specific absolute paths.

### Beta

Beta means the generic JSON-RPC behavior is expected to remain stable unless a
documented defect requires a compatibility-preserving fix.

Additional required gates:

- JSON-RPC 2.0 compliance matrix rows are mapped to tests or documented gaps.
- Negative tests cover malformed JSON, invalid ids, invalid params, invalid
  batches, oversized payloads, orphan responses, and write failures.
- Stress and lifecycle tests cover repeated parse, dispatch, batch, timeout,
  cancellation, trace, write, and close cleanup cycles.
- Public procedure names are reviewed and either marked stable or experimental.
- Release notes describe behavior changes, compatibility risk, and known gaps.

### Production Candidate

Production candidate means the library can be evaluated for real application
use with clear operational boundaries.

Additional required gates:

- No known JSON-RPC 2.0 compliance gaps remain undocumented.
- Message size limits, trace payload behavior, error text boundaries, and
  cleanup behavior are documented and tested.
- Release packaging is repeatable from a clean checkout.
- The release checklist has been followed and recorded.
- Security and robustness notes clearly separate generic JSON-RPC guarantees
  from application-level policy such as filesystems, SQL, command execution, or
  host approval.

## Standard Verification

Every completed route must run:

```sh
./tools/verify-docs.sh
./tools/build-docs.sh
./tools/check.sh
```

For code-heavy rounds, run focused commands first:

```sh
./tools/test.sh
./tools/build.sh
```

The final status report must include the branch name, changed areas, commands
run, test result, documentation status, and remaining risk.

## Documentation Freshness Gate

Documentation is part of the product. A route is incomplete if source behavior
changes but the route documents do not.

Each numbered route must update:

- `docs/milestones.md`
- `API/NNN-slug.md`
- `API/index.md`
- `docs/api.md`
- example README
- release notes when behavior, harness, packaging, or policy changes
- Sphinx toctree in `docs/index.md` for new major docs

`./tools/verify-docs.sh` enforces the mechanical parts of this rule.

## Absolute Path Gate

Tracked project files must not contain workstation-specific absolute paths.

Allowed:

- relative project paths such as `.local/...`, `.build/...`, `docs/...`, and
  `examples/...`
- discovered dependency paths printed at runtime by local scripts
- generated files under ignored folders

Not allowed:

- committed local home paths
- committed PureBasic installation paths
- committed placeholder absolute paths

This rule exists because earlier work exposed that path hygiene must be verified
instead of assumed.

The required command is:

```sh
./tools/verify-paths.sh
```
