# 027 Release Quality Gates

This scenario verifies that the release hardening track has a concrete quality
gate document instead of relying on chat history or assumptions.

Build through the committed project file:

```sh
./tools/build.sh
```

Run the probe:

```sh
./.build/examples/027-release-quality-gates/release_quality_probe
```

The probe checks `docs/release-quality-gates.md` for the alpha, beta, production
candidate, documentation freshness, and path hygiene gates.
