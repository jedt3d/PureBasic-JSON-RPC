EnableExplicit

IncludePath "../../src/jsonrpc"
XIncludeFile "mcp_lifecycle.pbi"

PureUnitOptions(Thread)

ProcedureUnit InitializeReturnsServerCapabilities()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected server.MCP_ServerInfo
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  MCP_ServerInfo_Init(@server, "pb-jsonrpc", "0.1.0", "PureBasic JSON-RPC", "Ready")
  server\toolsListChanged = #True
  Assert(MCP_RegisterLifecycle(@dispatcher, @server), "Lifecycle handlers should register.")

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-11-25\",\"capabilities\":{},\"clientInfo\":{\"name\":\"test\",\"version\":\"1\"}},\"id\":1}")

  Assert(FindString(response, ~"\"protocolVersion\":\"2025-11-25\"", 1) > 0, "Initialize response should include protocol version.")
  Assert(FindString(response, ~"\"tools\":{\"listChanged\":true}", 1) > 0, "Initialize response should include tool capability.")
  Assert(FindString(response, ~"\"serverInfo\":{\"name\":\"pb-jsonrpc\"", 1) > 0, "Initialize response should include server info.")
  Assert(FindString(response, ~"\"instructions\":\"Ready\"", 1) > 0, "Initialize response should include instructions.")
EndProcedureUnit

ProcedureUnit InitializeRequiresProtocolVersion()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected server.MCP_ServerInfo
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  MCP_ServerInfo_Init(@server, "pb-jsonrpc", "0.1.0")
  MCP_RegisterLifecycle(@dispatcher, @server)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"initialize\",\"params\":{},\"id\":2}")

  Assert(FindString(response, ~"\"code\":-32602", 1) > 0, "Missing protocol version should be invalid params.")
EndProcedureUnit

ProcedureUnit InitializedNotificationMarksServer()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected server.MCP_ServerInfo
  Protected response.s

  JSONRPC_Dispatcher_Init(@dispatcher)
  MCP_ServerInfo_Init(@server, "pb-jsonrpc", "0.1.0")
  MCP_RegisterLifecycle(@dispatcher, @server)

  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}")

  AssertString(response, "", "Initialized notification should not produce a response.")
  Assert(server\initialized, "Server should be marked initialized.")
EndProcedureUnit
