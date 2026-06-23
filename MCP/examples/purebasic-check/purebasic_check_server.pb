EnableExplicit

XIncludeFile "../../../src/jsonrpc/version.pbi"
XIncludeFile "purebasic_check_tool.pbi"

Procedure.s ServerProjectRoot()
  ProcedureReturn GetCurrentDirectory()
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
MCP_ServerInfo_Init(@server, "purebasic-check", JSONRPC_LibraryVersion(), "PureBasic Check", "Runs the repository PureBasic verification workflow.")
server\toolsListChanged = #True

MCP_RegisterLifecycle(@dispatcher, @server)
MCP_CheckTool_Register(@dispatcher, @registry)
MCP_CheckTool_SetConfig(ServerProjectRoot())

Repeat
  line = Input()
  If line <> ""
    response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, line)
    ServerWriteProtocol(response)
  EndIf
Until line = ""
; IDE Options = PureBasic 6.40 - C Backend (MacOS X - arm64)
; ExecutableFormat = Console
; CursorPosition = 5
; Folding = -
; EnableXP
; DPIAware
; Executable = purebasic_check_server
