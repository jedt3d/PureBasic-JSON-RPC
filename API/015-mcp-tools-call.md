# 015 MCP Tools Call

Milestone `015-mcp-tools-call` adds MCP `tools/call` registration and text result helpers.

## Include

```purebasic
XIncludeFile "src/jsonrpc/mcp_tools.pbi"
```

## Public Procedures

```purebasic
Prototype.i MCP_ToolCallHandler(argumentsValue, *context, *result)

MCP_RegisterToolHandler(*registry, name.s, *handler)
MCP_RegisterToolsCall(*dispatcher, *registry)
MCP_Tools_TextResult(text.s, isError.i = #False)
```

## Behavior

- `tools/call` reads `params.name` and optional object `params.arguments`.
- Unknown tools return JSON-RPC `-32602 Invalid params`.
- Handler-provided execution failures should return a tool result with `isError: true`.
- `argumentsValue` is valid only during the handler call; copy data needed later.
