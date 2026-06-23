EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "mcp_tools.pbi"

PureUnitOptions(Thread)

ProcedureUnit ToolRegistrationValidatesNameAndSchema()
  Protected registry.MCP_ToolRegistry

  MCP_ToolRegistry_Init(@registry)

  Assert(MCP_RegisterTool(@registry, "tools.echo", "Echo", "Echo input", ~"{\"type\":\"object\"}"), "Valid tool should register.")
  Assert(MCP_RegisterTool(@registry, "bad name", "Bad", "Bad", ~"{\"type\":\"object\"}") = #False, "Invalid tool name should fail.")
  Assert(MCP_RegisterTool(@registry, "badSchema", "Bad", "Bad", ~"\"scalar\"") = #False, "Invalid schema should fail.")
EndProcedureUnit

ProcedureUnit ToolsListReturnsRegisteredTools()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  MCP_ToolRegistry_Init(@registry)
  MCP_RegisterTool(@registry, "echo", "Echo", "Echo text", ~"{\"type\":\"object\",\"properties\":{\"text\":{\"type\":\"string\"}}}")
  Assert(MCP_RegisterToolsList(@dispatcher, @registry), "Tools list should register.")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"params\":{},\"id\":1}")

  Assert(FindString(response, ~"\"tools\":[", 1) > 0, "Response should include tools array.")
  Assert(FindString(response, ~"\"name\":\"echo\"", 1) > 0, "Response should include tool name.")
  Assert(FindString(response, ~"\"inputSchema\":{\"type\":\"object\"", 1) > 0, "Response should include input schema.")
EndProcedureUnit

ProcedureUnit EmptyRegistryListsNoTools()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  MCP_ToolRegistry_Init(@registry)
  MCP_RegisterToolsList(@dispatcher, @registry)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":2}")

  Assert(FindString(response, ~"\"tools\":[]", 1) > 0, "Empty registry should return an empty tools array.")
EndProcedureUnit

ProcedureUnit ListChangedNotificationHasMcpShape()
  AssertString(MCP_Tools_BuildListChangedNotification(), ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/tools/list_changed\"}", "List changed notification should match MCP shape.")
EndProcedureUnit
