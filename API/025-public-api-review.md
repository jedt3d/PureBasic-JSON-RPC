# 025 Public API Review

Milestone `025-public-api-review` documents the first alpha API contract and adds library metadata helpers.

## Include

```purebasic
XIncludeFile "src/jsonrpc/version.pbi"
```

The consolidated include also exposes version helpers:

```purebasic
XIncludeFile "src/jsonrpc/jsonrpc.pbi"
```

## Public Procedures

```purebasic
JSONRPC_LibraryName()
JSONRPC_LibraryVersion()
JSONRPC_LibraryStatus()
```

## Alpha Version

The current alpha version is:

```text
0.1.0-alpha.1
```

## Stability Policy

Stable for the alpha line:

- `JSONRPC_Framing_*`
- `JSONRPC_Codec_Stdio*`
- `JSONRPC_Writer_*`
- `JSONRPC_Reader_*`
- `JSONRPC_Connection_*`
- `JSONRPC_Protocol_*`
- `JSONRPC_Dispatcher_*`
- `JSONRPC_Register*`
- `JSONRPC_Unregister*`
- `JSONRPC_Batch_*`
- `JSONRPC_Cancel_*`
- `JSONRPC_Diagnostics_*`
- `JSONRPC_Trace_*`
- `JSONRPC_Compliance_*`

Experimental for the alpha line:

- public structure fields
- MCP adapter symbols
- packaging script details
- example folder layout beyond sequential numbering

## Compatibility Rule

New alpha rounds should prefer additive changes. If a public procedure must change, keep a compatibility shim until a documented breaking release.
