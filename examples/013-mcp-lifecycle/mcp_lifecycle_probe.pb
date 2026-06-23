EnableExplicit

XIncludeFile "../../src/jsonrpc/mcp_lifecycle.pbi"

Define dispatcher.JSONRPC_Dispatcher
Define server.MCP_ServerInfo
Define response.s

JSONRPC_Dispatcher_Init(@dispatcher)
MCP_ServerInfo_Init(@server, "pb-jsonrpc", "0.1.0", "PureBasic JSON-RPC", "")
server\toolsListChanged = #True

If MCP_RegisterLifecycle(@dispatcher, @server) = #False
  PrintN("lifecycle registration failed")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-11-25\",\"capabilities\":{},\"clientInfo\":{\"name\":\"probe\",\"version\":\"1\"}},\"id\":1}")
If FindString(response, ~"\"protocolVersion\":\"2025-11-25\"", 1) = 0
  PrintN("initialize response mismatch")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}")
If response <> "" Or server\initialized = #False
  PrintN("initialized notification failed")
  End 1
EndIf

PrintN("mcp lifecycle scenario: OK")
