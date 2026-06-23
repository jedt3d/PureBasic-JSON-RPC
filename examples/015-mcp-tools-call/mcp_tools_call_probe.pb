EnableExplicit

XIncludeFile "../../src/jsonrpc/mcp_tools.pbi"

Procedure.i ScenarioEcho(argumentsValue, *context.JSONRPC_RequestContext, *result.JSONRPC_HandlerResult)
  *result\ok = #True
  *result\resultJson = MCP_Tools_TextResult("hello")
  ProcedureReturn #True
EndProcedure

Define dispatcher.JSONRPC_Dispatcher
Define registry.MCP_ToolRegistry
Define response.s

JSONRPC_Dispatcher_Init(@dispatcher)
MCP_ToolRegistry_Init(@registry)
MCP_RegisterTool(@registry, "echo", "Echo", "Echo text", ~"{\"type\":\"object\"}")
MCP_RegisterToolHandler(@registry, "echo", @ScenarioEcho())
MCP_RegisterToolsCall(@dispatcher, @registry)

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"echo\",\"arguments\":{}},\"id\":1}")
If FindString(response, ~"\"text\":\"hello\"", 1) = 0
  PrintN("tools/call response mismatch")
  End 1
EndIf

PrintN("mcp tools call scenario: OK")
