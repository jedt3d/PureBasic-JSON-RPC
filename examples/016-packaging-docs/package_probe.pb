EnableExplicit

XIncludeFile "../../src/jsonrpc/jsonrpc.pbi"

Define dispatcher.JSONRPC_Dispatcher
Define registry.MCP_ToolRegistry

JSONRPC_Dispatcher_Init(@dispatcher)
MCP_ToolRegistry_Init(@registry)

If MCP_RegisterTool(@registry, "echo", "Echo", "Echo text", ~"{\"type\":\"object\"}") = #False
  PrintN("consolidated include failed")
  End 1
EndIf

PrintN("packaging docs scenario: OK")
