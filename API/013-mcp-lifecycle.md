# 013 MCP Lifecycle Adapter

Milestone `013-mcp-lifecycle` starts the MCP adapter layer.

## Include

```purebasic
XIncludeFile "src/jsonrpc/mcp_lifecycle.pbi"
```

## Public Structures

```purebasic
Structure MCP_ServerInfo
  name.s
  title.s
  version.s
  instructions.s
  toolsListChanged.i
  initialized.i
EndStructure
```

## Public Procedures

```purebasic
MCP_ServerInfo_Init(*server, name.s, version.s, title.s = "", instructions.s = "")
MCP_RegisterLifecycle(*dispatcher, *server)
MCP_BuildInitializeResult(*server)
```

## Behavior

- Registers `initialize` and `notifications/initialized` handlers.
- Responds with MCP protocol version `2025-11-25`.
- Emits server info, server capabilities, and optional instructions.
- `notifications/initialized` marks the server info as initialized and emits no response.
