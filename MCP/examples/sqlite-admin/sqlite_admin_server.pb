EnableExplicit

XIncludeFile "../../../src/jsonrpc/version.pbi"
XIncludeFile "sqlite_admin_tool.pbi"

Procedure.s ServerAllowedRoot()
  ProcedureReturn MCP_SQLiteAdmin_DefaultAllowedRoot()
EndProcedure

Procedure ServerWriteProtocol(response.s)
  If response <> ""
    Print(JSONRPC_Codec_StdioBuildMessage(response))
  EndIf
EndProcedure

Define dispatcher.JSONRPC_Dispatcher
Define registry.MCP_ToolRegistry
Define server.MCP_ServerInfo
Define line.s
Define response.s

OpenConsole()

JSONRPC_Dispatcher_Init(@dispatcher)
MCP_ToolRegistry_Init(@registry)
MCP_ServerInfo_Init(@server, "sqlite-admin", JSONRPC_LibraryVersion(), "SQLite Admin", "Administer approved local SQLite files from a PureBasic stdio MCP server.")
server\toolsListChanged = #True

MCP_SQLiteAdmin_SetConfig(ServerAllowedRoot())
MCP_RegisterLifecycle(@dispatcher, @server)
MCP_SQLiteAdmin_Register(@dispatcher, @registry)

Repeat
  line = Input()
  If line <> ""
    response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, line)
    ServerWriteProtocol(response)
  EndIf
Until line = ""
; IDE Options = PureBasic 6.40 - C Backend (MacOS X - arm64)
; ExecutableFormat = Console
; EnableXP
; DPIAware
; Executable = sqlite_admin_server
