# 014 MCP Tools Registry

Milestone `014-mcp-tools-registry` adds MCP tool metadata registration and `tools/list`.

## Include

```purebasic
XIncludeFile "src/jsonrpc/mcp_tools.pbi"
```

## Public Structures

```purebasic
Structure MCP_ToolRegistry
  Map tools.MCP_Tool()
  listChanged.i
EndStructure
```

## Public Procedures

```purebasic
MCP_ToolRegistry_Init(*registry)
MCP_RegisterTool(*registry, name.s, title.s, description.s, inputSchemaJson.s)
MCP_RegisterToolsList(*dispatcher, *registry)
MCP_Tools_BuildListResult(*registry)
MCP_Tools_BuildListChangedNotification()
```

## Behavior

- Tool names are validated against the MCP recommended ASCII name characters.
- `inputSchemaJson` must be a JSON object or array; object schemas are the intended MCP use.
- `tools/list` returns `{ "tools": [...] }`.
- `notifications/tools/list_changed` can be built as a compact JSON-RPC notification.
- This milestone stores metadata only; tool execution is added later.
