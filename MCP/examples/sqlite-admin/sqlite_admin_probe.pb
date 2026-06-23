EnableExplicit

XIncludeFile "../../../src/jsonrpc/version.pbi"
XIncludeFile "sqlite_admin_tool.pbi"

Define dispatcher.JSONRPC_Dispatcher
Define registry.MCP_ToolRegistry
Define server.MCP_ServerInfo
Define response.s
Define allowedRoot.s

OpenConsole()

allowedRoot = GetCurrentDirectory() + ".local/sqlite-admin/"
MCP_SQLiteAdmin_SetConfig(allowedRoot)

JSONRPC_Dispatcher_Init(@dispatcher)
MCP_ToolRegistry_Init(@registry)
MCP_ServerInfo_Init(@server, "sqlite-admin-probe", JSONRPC_LibraryVersion(), "SQLite Admin Probe", "Probe the SQLite admin MCP dispatcher.")
server\toolsListChanged = #True

MCP_RegisterLifecycle(@dispatcher, @server)
MCP_SQLiteAdmin_Register(@dispatcher, @registry)

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"sqlite/bootstrap\",\"arguments\":{\"dbPath\":\"probe.sqlite\",\"overwrite\":true}},\"id\":1}")
If FindString(response, ~"\"isError\":false", 1) = 0
  PrintN("sqlite/bootstrap probe failed")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"sqlite/query\",\"arguments\":{\"dbPath\":\"probe.sqlite\",\"sql\":\"SELECT title FROM admin_notes WHERE locale = 'th'\",\"maxRows\":5}},\"id\":2}")
If FindString(response, MCP_SQLiteAdmin_ThaiHello(), 1) = 0
  PrintN("sqlite/query i18n probe failed")
  End 1
EndIf

response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"sqlite/recipe/run\",\"arguments\":{\"dbPath\":\"probe.sqlite\",\"name\":\"notes-by-locale\",\"parameters\":{\"locale\":\"ja\"}}},\"id\":3}")
If FindString(response, MCP_SQLiteAdmin_JapaneseHello(), 1) = 0
  PrintN("sqlite/recipe/run probe failed")
  End 1
EndIf

PrintN("sqlite admin scenario: OK")
