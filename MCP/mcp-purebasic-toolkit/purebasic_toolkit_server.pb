EnableExplicit

XIncludeFile "../../src/jsonrpc/version.pbi"
XIncludeFile "purebasic_toolkit_tools.pbi"

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
MCP_ServerInfo_Init(@server, "mcp-purebasic-toolkit", JSONRPC_LibraryVersion(), "PureBasic Development Toolkit", "Pair-development, project inspection, harness, documentation, Git, and MCP authoring support for PureBasic projects.")
server\toolsListChanged = #True

MCP_Toolkit_SetConfig(ServerProjectRoot())
MCP_RegisterLifecycle(@dispatcher, @server)
MCP_Toolkit_Register(@dispatcher, @registry)

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
; Executable = purebasic_toolkit_server
