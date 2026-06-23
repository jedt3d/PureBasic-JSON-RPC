# PureBasic Check MCP Server

This example exposes a stdio MCP tool named `purebasic/check`.

The tool runs the repository verification script:

```sh
./tools/check.sh
```

Build from the project root:

```sh
./tools/build.sh
```

Open the PureBasic project file in the IDE:

```text
MCP/examples/purebasic-check/purebasic_check.pbp
```

The project target `purebasic/check stdio server` is explicitly configured as a console executable because MCP stdio servers must read stdin and write protocol messages to stdout.

Run the compiled server:

```sh
./.build/MCP/examples/purebasic-check/purebasic_check_server
```

Smoke-test initialize and `tools/list` without running the check tool:

```sh
./.build/MCP/examples/purebasic-check/purebasic_check_server < MCP/examples/purebasic-check/probe_smoke_input.ndjson
```

Run the full sample, including `tools/call`, from the repository root:

```sh
./.build/MCP/examples/purebasic-check/purebasic_check_server < MCP/examples/purebasic-check/probe_input.ndjson
```

MCP clients should register the compiled executable as a stdio server. Protocol messages are written to stdout only; diagnostics should use stderr.

The tool has no input fields:

```json
{
  "type": "object",
  "properties": {},
  "additionalProperties": false
}
```
