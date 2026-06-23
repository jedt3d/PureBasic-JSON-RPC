# 031 Security Robustness

Milestone `031-security-robustness` documents and tests the generic JSON-RPC
library's robustness boundaries.

## Public API Change

No new `JSONRPC_*` procedures are added.

The harness gains:

```sh
./tools/verify-paths.sh
```

`./tools/check.sh` runs this script before tests and builds. The script scans
tracked files for workstation-specific absolute paths.

## Covered Boundaries

- Trace payloads remain hidden unless explicitly enabled.
- Malformed JSON does not prevent the next valid request from succeeding.
- Failed writes drop queued bodies and allow later writes to recover.
- Framing and stdio message size limits reject oversized input before dispatch.
- Generic JSON-RPC does not own application policy such as filesystem, SQL,
  command execution, authentication, or host approval.

## Documentation

```text
docs/security-robustness.md
```

## Scenario

```text
examples/031-security-robustness/security_probe.pb
```
