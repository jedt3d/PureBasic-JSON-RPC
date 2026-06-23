# 029 Negative Tests

Milestone `029-negative-tests` expands malformed-input and edge-case coverage for
the generic JSON-RPC library.

## Public API Change

No new public procedures are added.

The protocol validator is hardened so invalid `id` values such as objects,
arrays, and booleans produce `-32600 Invalid Request` instead of being treated as
notifications.

## Covered Negative Cases

- invalid object or array `id`
- invalid id not reaching method dispatch
- invalid batch items
- oversized Content-Length frames
- oversized stdio messages
- orphan response rejection
- repeated malformed dispatch without pending-state leakage

## Scenario

```text
examples/029-negative-tests/negative_probe.pb
```

The scenario runs a compact set of malformed-input probes and exits nonzero if a
case is accepted incorrectly.

## Verification

```sh
./tools/test.sh
./tools/check.sh
```
