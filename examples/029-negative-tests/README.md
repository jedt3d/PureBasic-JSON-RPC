# 029 Negative Tests

This scenario exercises a small set of malformed JSON-RPC inputs. It exists to
prove that the negative-test milestone has an executable probe, not only a unit
test file.

Build through the committed project file:

```sh
./tools/build.sh
```

Run the probe:

```sh
./.build/examples/029-negative-tests/negative_probe
```
