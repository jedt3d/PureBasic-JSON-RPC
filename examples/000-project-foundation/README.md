# 000 Project Foundation Scenario

This scenario verifies that the local PureBasic 6.40 compiler can build and run a console application for this repository.

It does not exercise JSON-RPC behavior yet. That is intentional: milestone `000-project-foundation` exists to prove the project harness before protocol code is added.

Run:

```sh
./tools/build.sh
./.build/examples/000-project-foundation/console_probe
```

