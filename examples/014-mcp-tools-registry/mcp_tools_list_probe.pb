EnableExplicit

XIncludeFile "../../src/jsonrpc/mcp_tools.pbi"

Define dispatcher.JSONRPC_Dispatcher
Define registry.MCP_ToolRegistry
Define response.s

JSONRPC_Dispatcher_Init(@dispatcher)
MCP_ToolRegistry_Init(@registry)

If MCP_RegisterTool(@registry, "echo", "Echo", "Echo text", ~"{\"type\":\"object\",\"properties\":{\"text\":{\"type\":\"string\"}}}") = #False
  PrintN("tool registration failed")
  End 1
EndIf

If MCP_RegisterToolsList(@dispatcher, @registry) = #False
  PrintN("tools/list registration failed")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":1}")
If FindString(response, ~"\"name\":\"echo\"", 1) = 0
  PrintN("tools/list response mismatch")
  End 1
EndIf

If MCP_Tools_BuildListChangedNotification() <> ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/tools/list_changed\"}"
  PrintN("list changed notification mismatch")
  End 1
EndIf

PrintN("mcp tools registry scenario: OK")
