EnableExplicit

XIncludeFile "../../MCP/mcp-purebasic-toolkit/purebasic_toolkit_tools.pbi"

PureUnitOptions(Thread)

Procedure.s ToolkitRoot()
  Protected root.s

  root = GetCurrentDirectory()
  If FileSize(root + "MCP/mcp-purebasic-toolkit/purebasic_toolkit_tools.pbi") >= 0
    ProcedureReturn root
  EndIf

  If FileSize(root + "../../MCP/mcp-purebasic-toolkit/purebasic_toolkit_tools.pbi") >= 0
    ProcedureReturn root + "../../"
  EndIf

  ProcedureReturn root
EndProcedure

Procedure.s WorkstationAbsolutePathMarker()
  ProcedureReturn "/" + "Users" + "/"
EndProcedure

Procedure ToolkitInit(*dispatcher.JSONRPC_Dispatcher, *registry.MCP_ToolRegistry)
  Protected server.MCP_ServerInfo

  JSONRPC_Dispatcher_Init(*dispatcher)
  MCP_ToolRegistry_Init(*registry)
  MCP_ServerInfo_Init(@server, "toolkit-test", "0", "Toolkit Test", "")
  MCP_Toolkit_SetConfig(ToolkitRoot())
  MCP_RegisterLifecycle(*dispatcher, @server)
  MCP_Toolkit_Register(*dispatcher, *registry)
EndProcedure

ProcedureUnit ToolkitRegistersProjectIntelligenceTools()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":1}")

  Assert(FindString(response, #MCP_Toolkit_IncludeGraphName$, 1) > 0, "tools/list should include include graph.")
  Assert(FindString(response, #MCP_Toolkit_SymbolSearchName$, 1) > 0, "tools/list should include symbol search.")
  Assert(FindString(response, #MCP_Toolkit_ProcedureListName$, 1) > 0, "tools/list should include procedure list.")
  Assert(FindString(response, #MCP_Toolkit_PbpListTargetsName$, 1) > 0, "tools/list should include pbp target list.")
EndProcedureUnit

ProcedureUnit IncludeGraphContainsJsonRpcEdges()
  Protected text.s

  MCP_Toolkit_SetConfig(ToolkitRoot())
  text = MCP_Toolkit_IncludeGraphText()

  Assert(FindString(text, "src/jsonrpc/jsonrpc.pbi -> version.pbi", 1) > 0, "Include graph should include the consolidated include.")
  Assert(FindString(text, "MCP/mcp-purebasic-toolkit/purebasic_toolkit_server.pb -> ../../src/jsonrpc/version.pbi", 1) > 0, "Include graph should include toolkit server includes.")
EndProcedureUnit

ProcedureUnit SymbolSearchFindsDispatcher()
  Protected text.s

  MCP_Toolkit_SetConfig(ToolkitRoot())
  text = MCP_Toolkit_SymbolSearchText("JSONRPC_Dispatcher_Dispatch")

  Assert(FindString(text, "src/jsonrpc/dispatch.pbi", 1) > 0, "Symbol search should find dispatcher implementation.")
  Assert(FindString(text, WorkstationAbsolutePathMarker(), 1) = 0, "Symbol search should use repository-relative paths.")
EndProcedureUnit

ProcedureUnit ProcedureListFiltersToolkitPrefix()
  Protected text.s

  MCP_Toolkit_SetConfig(ToolkitRoot())
  text = MCP_Toolkit_ProcedureListText("MCP_Toolkit")

  Assert(FindString(text, "MCP_Toolkit_Register", 1) > 0, "Procedure list should find toolkit registration.")
  Assert(FindString(text, "src/jsonrpc/", 1) = 0, "Prefix-filtered toolkit list should avoid unrelated JSON-RPC procedures.")
EndProcedureUnit

ProcedureUnit PbpTargetsListIncludesToolkitConsoleTargets()
  Protected text.s

  MCP_Toolkit_SetConfig(ToolkitRoot())
  text = MCP_Toolkit_PbpTargetsText()

  Assert(FindString(text, "MCP/mcp-purebasic-toolkit/purebasic_toolkit.pbp", 1) > 0, "PBP target list should include toolkit project.")
  Assert(FindString(text, "mcp-purebasic-toolkit stdio server [console]", 1) > 0, "Toolkit server should be a console target.")
  Assert(FindString(text, WorkstationAbsolutePathMarker(), 1) = 0, "PBP target list should use repository-relative paths.")
EndProcedureUnit

ProcedureUnit SymbolSearchRequiresQuery()
  Protected dispatcher.JSONRPC_Dispatcher
  Protected registry.MCP_ToolRegistry
  Protected response.s

  ToolkitInit(@dispatcher, @registry)
  response = JSONRPC_Dispatcher_Dispatch(@dispatcher, 0, ~"{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"purebasic/symbol/search\",\"arguments\":{}},\"id\":2}")

  Assert(FindString(response, ~"\"code\":-32602", 1) > 0, "Missing query should return invalid params.")
EndProcedureUnit
