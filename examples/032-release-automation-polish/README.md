# 032 Release Automation Polish

This scenario verifies that release automation is wired into the normal harness.
It does not publish anything. It checks the local scripts and checklist that
make packaging auditable.

Build and run through the project harness:

```sh
./tools/build.sh
./.build/examples/032-release-automation-polish/release_automation_probe
```

The full release artifact check is performed by:

```sh
./tools/check.sh
```

That command runs `./tools/package-alpha.sh` and then
`./tools/verify-release-artifacts.sh`.
