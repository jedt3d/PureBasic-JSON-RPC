# Milestones

## 000-project-foundation

Branch: `feature/000-project-foundation`

Purpose:

- Establish AI/contributor guidance in `AGENTS.md`.
- Discover PureBasic 6.40 and SDK PureUnit.
- Create project-local generated homes under `.local/`.
- Add build, test, and check scripts.
- Add the first PureUnit smoke test.
- Add the first scenario console application.
- Add API and Read the Docs scaffolding.

Acceptance criteria:

- `./tools/discover-purebasic.sh` detects PureBasic 6.40 and PureUnit.
- `./tools/test.sh` runs the PureUnit smoke test.
- `./tools/build.sh` builds `examples/000-project-foundation/console_probe.pb`.
- `./tools/check.sh` performs discovery, tests, build, and runs the example.

## Planned Build Order

1. Framed message reader and writer.
2. Connection lifecycle.
3. JSON parsing, validation, and standard errors.
4. Request and notification registration.
5. Inbound dispatch and response writing.
6. Outbound request ids and pending-response tracking.
7. Timeout housekeeping.
8. Batch handling.
9. Cooperative `$/cancelRequest` support.
10. Diagnostics counters.
11. Stress tests and memory lifecycle tests.

