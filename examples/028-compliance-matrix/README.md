# 028 Compliance Matrix

This scenario runs the expanded reusable JSON-RPC compliance suite and confirms
that the matrix document is represented by executable checks.

Build through the committed project file:

```sh
./tools/build.sh
```

Run the probe:

```sh
./.build/examples/028-compliance-matrix/compliance_matrix_probe
```

The matrix itself is in `docs/jsonrpc-compliance-matrix.md`.
